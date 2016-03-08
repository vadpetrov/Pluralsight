create procedure [dbo].[sp_fc_Transactions_Thru_SPV]
@RunType					int			  = 1,
@InvolvmtIDList_RightSide	varchar(max)  = null -- By passing null stored procedure will buiild only #Feeders part

as

declare @UnwantedDeals table  (pei_deal_id_c int)
declare @FCNodes table (pei_involvmt_typ_id_c int)

/************************************************************

Process:

Before issuing call to this stored procedure the following must
be performed by the calling stored proc:

1. Obtain commitments by calling
   sp_peixLoadAllocTable_Feeder_Cur_MLT with parameter
   @LoadDetails = 'Y'

2. Obtain transactions by calling either of the following sp
   sp_fc_GetTransactions 
   sp_irr_GetPostedTransactionsUsingCutOffDate

Required temp table definitions:

create table #tmpAlloc_Feeder  
(  
pei_deal_id_c			int,  
pei_invst_fnd_id_c		int,  
pei_vhcl_id_c			int,  
pei_invstr_id_c			int,  
pei_trans_typ_id_c		int,  
pei_eff_trans_d			datetime,  
pei_alloc_amt_m			decimal(27,2),  
pei_trans_status_id_c	int,  
cur_id_c				char(3),  
pei_mlt_cur_id_c		char(3),  
pei_alloc_amt_mlt		decimal(27,2),  
IsFeeder				char(1),  
HasFeeder				char(1),  
FeederFundID			int,  
FeederVhclID			int  
)  
create table #tmpFeederDtl
(
pei_deal_id_c 			int,
pei_invst_fnd_id_c 		int,
pei_vhcl_id_c 			int,
IsFeeder				char(1),
HasFeeder				char(1),
FeederFundID			int,
FeederVhclID			int,
CmtmtPct				float,
CmtmtPctMlt				float,
FeederFundIDList		varchar(500),
FeederFundShrtNameList	varchar(2000),
NextFundIDList			varchar(500),
NextFundShrtNameList	varchar(2000)
)

create table #Feeders
(
ProdId							int,
VhclId							int,
DealId							int,
FeederProdId					int,
FeederVhclId					int,
FeederProdIdAsDealId			int,
CmtmtPct						float,
MultiDeals						int		default 1,
MultiSpvs						int		default 1,
MultiSpvPct						float
)

If Run Type = 1: 
Output of sp_fc_GetTransactions

create table #FCntl_Transactions_Cur
(
pei_orig_deal_id_c			int,
pei_deal_id_c				int,
pei_invst_fnd_id_c			int,
pei_vhcl_id_c				int,
pei_invstr_id_c				int,
pei_trans_typ_id_c			int,
pei_involvmt_typ_id_c		int,
pei_eff_trans_d				datetime,
pei_trans_status_id_c		int,
pei_batch_id_c				int,
pei_investran_trans_id_c	int,
pei_acct_id_c				int,
pei_pos_id_c				int,
le_cur_id_c					char(3),
pei_le_amount_m				decimal(30,2),
loc_cur_id_c				char(3),
pei_loc_amount_m			decimal(30,2),
pei_cur_id_c				char(3),
pei_amount_m				decimal(30,2),
FeederProdId				int		null,
FeederVhclId				int		null
)

If Run Type = 2: Output of
Output of sp_irr_GetPostedTransactionsUsingCutOffDate

create table #Alloc_Transactions_Cur
(
pei_orig_deal_id_c			int,
pei_deal_id_c				int,
pei_invst_fnd_id_c			int,
pei_vhcl_id_c				int,
pei_invstr_id_c				int,
pei_trans_typ_id_c			int,
pei_involvmt_typ_id_c		int,
pei_eff_trans_d				datetime,
pei_trans_status_id_c		int,
le_cur_id_c					char(3),
loc_cur_id_c				char(3),
pei_le_amount_m				float,
pei_loc_amount_m			float,
pei_batch_id_c				int,
pei_investran_trans_id_c	int,
pei_acct_id_c				int,
pei_pos_id_c				int,  
FeederProdId				int,  
FeederVhclID				int  
)

create table #Alloc_Transactions
(
pei_orig_deal_id_c			int,
pei_deal_id_c				int,
pei_invst_fnd_id_c			int,
pei_vhcl_id_c				int,
pei_invstr_id_c				int,
pei_trans_typ_id_c			int,
pei_involvmt_typ_id_c		int,
pei_eff_trans_d				datetime,
pei_trans_status_id_c		int,
cur_id_c					char(3),
pei_amount_m				float,
pei_batch_id_c				int,
pei_investran_trans_id_c	int,
pei_acct_id_c				int,
pei_pos_id_c				int,
FeederProdId				int		null,
FeederVhclId				int		null
)
*************************************************************/

begin
set nocount on

/***********************************************
 Unwanted deals
************************************************/

	insert into @UnwantedDeals (pei_deal_id_c)
	select pei_deal_id_c from pei_deal_ref where pei_unwanted_i = 'Y'


/***********************************************
 Remove unwanted commitments
************************************************/
	delete cm
	  from #tmpAlloc_Feeder		cm
		   join @UnwantedDeals	ud on cm.pei_deal_id_c = ud.pei_deal_id_c

	delete cm
	  from #tmpFeederDtl		cm
		   join @UnwantedDeals	ud on cm.pei_deal_id_c = ud.pei_deal_id_c

/***********************************************
 Get all feeders
************************************************/
	
	truncate table #Feeders

	insert into #Feeders (ProdId,
						  VhclId,
						  DealId,
						  FeederProdId,
						  FeederVhclId)
	select  pei_invst_fnd_id_c,
			pei_vhcl_id_c,
			pei_deal_id_c,
			FeederFundID,
			FeederVhclID
	   from #tmpAlloc_Feeder
	  where HasFeeder = 'Y'
   group by pei_invst_fnd_id_c,
			pei_vhcl_id_c,
			pei_deal_id_c,
			FeederFundID,
			FeederVhclID

/***********************************************
 Assign Deal Id to SPV ProductId 
************************************************/
	update #Feeders 
	   set FeederProdIdAsDealId = pei_deal_id_c
	  from pei_deal_ref
	 where pei_deal_invst_fnd_id_c is not null
	   and pei_deal_invst_fnd_id_c = FeederProdId

/**************************************************
 Identify Multiple SPVs to Ultimate Deal
***************************************************/
	update fd
	   set MultiSPVs	= 999,
		   MultiSpvPct	= fdtl.CmtmtPctMlt / 100
	  from #Feeders				fd
		   join #tmpFeederDtl	fdtl	on fd.ProdId = fdtl.pei_invst_fnd_id_c
									   and fd.VhclId = fdtl.pei_vhcl_id_c
									   and fd.DealId = fdtl.pei_deal_id_c
	 where fdtl.HasFeeder = 'Y'
	   and charindex(';', fdtl.FeederFundIDList) > 0

/***********************************************
 Identify Single SPV to Ultimate Deal
************************************************/
	update #Feeders
	   set MultiDeals = (select count(distinct DealId)
						   from #Feeders fd
						  where fd.FeederProdId = #Feeders.FeederProdId
							and fd.FeederVhclId = #Feeders.FeederVhclId
							and fd.MultiSPVs	= 1)

	if len(rtrim(ltrim(isnull(@InvolvmtIDList_RightSide,'')))) = 0 return
/**************************************************************
  SPV Transactions Processing

  Thru Multi SPV:
1. Apply commitment percentage calculation to multi
   level SPVs

  Thru Single SPV:
 
1. If Feeder Product goes to multiple Ultimate Deals,
   remove "left" side transaction where product going
   into such SPV as SPV Deal

2. If Feeder Product goes to one Ultimate Deals,
   take "left" side transactions replacing SVP deal
   with Ultimate Deal

3. If Feeder Product goes to multiple Ultimate Deals,
   remove "right" side transaction from Ultimate Deal
   to SPV to Investor as Product going into SPV product

*************************************************************/	

	insert into @FCNodes (pei_involvmt_typ_id_c)
	select s.id
	  from dbo.Split(@InvolvmtIDList_RightSide,',') s

	If @RunType = 1
	begin
		delete trn
		  from #FCntl_Transactions_Cur	trn
			   join @UnwantedDeals		udl on isnull(trn.pei_deal_id_c, 412) = udl.pei_deal_id_c
			   join @FCNodes			fcn on trn.pei_involvmt_typ_id_c      = fcn.pei_involvmt_typ_id_c

		insert into #FCntl_Transactions_Cur  (pei_orig_deal_id_c,
											  pei_deal_id_c,
											  pei_invst_fnd_id_c,
											  pei_vhcl_id_c,
											  pei_invstr_id_c,
											  pei_trans_typ_id_c,
											  pei_involvmt_typ_id_c,
											  pei_eff_trans_d,
											  pei_trans_status_id_c,
											  pei_batch_id_c,
											  le_cur_id_c,
											  pei_le_amount_m,
											  loc_cur_id_c,
											  pei_loc_amount_m,
											  pei_cur_id_c,
											  pei_amount_m,
											  FeederProdId,
											  FeederVhclId)
		select tr.pei_deal_id_c,
				tr.pei_deal_id_c,
				fd.ProdId,
				fd.VhclId,
				tr.pei_invstr_id_c,
				tr.pei_trans_typ_id_c,
				tr.pei_involvmt_typ_id_c,
				tr.pei_eff_trans_d,
				tr.pei_trans_status_id_c,
				tr.pei_batch_id_c,
				tr.le_cur_id_c,
				tr.pei_le_amount_m * fd.MultiSpvPct,
				tr.loc_cur_id_c,
				tr.pei_loc_amount_m * fd.MultiSpvPct,
				tr.pei_cur_id_c,
				tr.pei_amount_m * fd.MultiSpvPct,
				fd.FeederProdId,
				fd.FeederVhclId
		 from  #Feeders						fd
			   join #FCntl_Transactions_Cur	tr on tr.pei_invst_fnd_id_c		= fd.FeederProdId
													and tr.pei_vhcl_id_c	= fd.FeederVhclId
													and tr.pei_deal_id_c	= fd.DealId
			   join @FCNodes				fc on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		 where fd.MultiSpvs	= 999

		delete tr	 
		  from #FCntl_Transactions_Cur	tr
			   join #Feeders			fd	on tr.pei_invst_fnd_id_c	= fd.ProdId
										   and tr.pei_vhcl_id_c			= fd.VhclId
										   and tr.pei_deal_id_c			= fd.FeederProdIdAsDealId
			   join @FCNodes			fc  on tr.pei_involvmt_typ_id_c = fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals > 1
		   and fd.MultiSpvs	 = 1

		update tr
		   set pei_deal_id_c	= fd.DealId,
			   FeederProdId		= fd.FeederProdId,
			   FeederVhclId		= fd.FeederVhclId
		  from #FCntl_Transactions_Cur	tr
			   join #Feeders			fd	 on tr.pei_invst_fnd_id_c	 = fd.ProdId
											and tr.pei_vhcl_id_c		 = fd.VhclId
											and tr.pei_deal_id_c		 = fd.FeederProdIdAsDealId
			   join @FCNodes			fc   on tr.pei_involvmt_typ_id_c = fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals = 1
		   and fd.MultiSpvs	 = 1

		update tr
		   set pei_invst_fnd_id_c		= fd.ProdId,
			   pei_vhcl_id_c			= fd.VhclId,
			   FeederProdId				= fd.FeederProdId,
			   FeederVhclId				= fd.FeederVhclId,
			   pei_le_amount_m			= tr.pei_le_amount_m,
			   pei_loc_amount_m			= tr.pei_loc_amount_m,
			   pei_amount_m				= tr.pei_amount_m,
			   pei_trans_status_id_c	= tr. pei_trans_status_id_c,
			   pei_batch_id_c			= tr.pei_batch_id_c
		  from #FCntl_Transactions_Cur	tr
			   join @FCNodes			fc   on tr.pei_involvmt_typ_id_c = fc.pei_involvmt_typ_id_c
			   join #Feeders			fd	 on tr.pei_deal_id_c		 = fd.DealId
											and tr.pei_invst_fnd_id_c	 = fd.FeederProdId
											and tr.pei_vhcl_id_c		 = fd.FeederVhclId		   
			   join pei_invstr_ref		ir   on fd.ProdId				 = ir.pei_invstr_invst_fnd_id_c
			   join (select pei_deal_id_c, 
							pei_invst_fnd_id_c, 
							pei_vhcl_id_c
					   from #tmpAlloc_Feeder
					group by pei_deal_id_c, pei_invst_fnd_id_c, pei_vhcl_id_c
					having sum(pei_alloc_amt_m) <> 0) cm on cm.pei_deal_id_c	  = fd.DealId 
														and cm.pei_invst_fnd_id_c = fd.ProdId	 
														and cm.pei_vhcl_id_c	  = fd.VhclId
		  where ir.pei_invstr_invst_fnd_id_c	is not null	  
		    and tr.pei_invstr_id_c				= ir.pei_invstr_id_c
			and fd.MultiDeals					> 1
			and fd.MultiSpvs					= 1
	end

	if @RunType = 2
	begin
		delete trn
		  from #Alloc_Transactions		trn
			   join @UnwantedDeals		udl on isnull(trn.pei_deal_id_c, 412) = udl.pei_deal_id_c
			   join @FCNodes			fcn on trn.pei_involvmt_typ_id_c      = fcn.pei_involvmt_typ_id_c

		delete trn
		  from #Alloc_Transactions_Cur	trn
			   join @UnwantedDeals		udl on isnull(trn.pei_deal_id_c, 412) = udl.pei_deal_id_c
			   join @FCNodes			fcn on trn.pei_involvmt_typ_id_c      = fcn.pei_involvmt_typ_id_c


		insert into #Alloc_Transactions    (pei_orig_deal_id_c,
											pei_deal_id_c,
											pei_invst_fnd_id_c,
											pei_vhcl_id_c,
											pei_invstr_id_c,
											pei_trans_typ_id_c,
											pei_involvmt_typ_id_c,
											pei_eff_trans_d,
											pei_trans_status_id_c,
											cur_id_c,
											pei_amount_m,
											pei_batch_id_c,
											pei_investran_trans_id_c,
											FeederProdId,
											FeederVhclId)
		select  tr.pei_deal_id_c,
				tr.pei_deal_id_c,
				fd.ProdId,
				fd.VhclId,
				tr.pei_invstr_id_c,
				tr.pei_trans_typ_id_c,
				tr.pei_involvmt_typ_id_c,
				tr.pei_eff_trans_d,
				tr.pei_trans_status_id_c,
				tr.cur_id_c,
				tr.pei_amount_m * fd.MultiSpvPct,
				tr.pei_batch_id_c,
				tr.pei_investran_trans_id_c,
				fd.FeederProdId,
				fd.FeederVhclId
		  from  #Feeders					fd
				join #Alloc_Transactions	tr on tr.pei_invst_fnd_id_c		= fd.FeederProdId
											  and tr.pei_vhcl_id_c			= fd.FeederVhclId
											  and tr.pei_deal_id_c			= fd.DealId
				join @FCNodes				fc on tr.pei_involvmt_typ_id_c  = fc.pei_involvmt_typ_id_c
		  where fd.MultiSpvs	= 999
		  		  
		insert into #Alloc_Transactions_Cur(pei_orig_deal_id_c,
											pei_deal_id_c,
											pei_invst_fnd_id_c,
											pei_vhcl_id_c,
											pei_invstr_id_c,
											pei_trans_typ_id_c,
											pei_involvmt_typ_id_c,
											pei_eff_trans_d,
											pei_trans_status_id_c,
											le_cur_id_c,
											loc_cur_id_c,
											pei_le_amount_m,
											pei_loc_amount_m,
											pei_batch_id_c,
											pei_investran_trans_id_c,
											pei_acct_id_c,
											pei_pos_id_c)
		select  tr.pei_orig_deal_id_c,
				tr.pei_deal_id_c,
				fd.ProdId,
				fd.VhclId,
				tr.pei_invstr_id_c,
				tr.pei_trans_typ_id_c,
				tr.pei_involvmt_typ_id_c,
				tr.pei_eff_trans_d,
				tr.pei_trans_status_id_c,
				tr.le_cur_id_c,
				tr.loc_cur_id_c,
				tr.pei_le_amount_m * fd.MultiSpvPct,
				tr.pei_loc_amount_m * fd.MultiSpvPct,
				tr.pei_batch_id_c,
				tr.pei_investran_trans_id_c,
				tr.pei_acct_id_c,
				tr.pei_pos_id_c
		  from  #Feeders					 fd
				join #Alloc_Transactions_Cur tr	 on tr.pei_invst_fnd_id_c		= fd.FeederProdId
												and tr.pei_vhcl_id_c			= fd.FeederVhclId
												and tr.pei_deal_id_c			= fd.DealId
				join @FCNodes				 fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		  where fd.MultiSpvs	= 999
		  

		delete tr	 
		  from #Alloc_Transactions	tr
			   join #Feeders		fd	 on tr.pei_invst_fnd_id_c		= fd.ProdId
										and tr.pei_vhcl_id_c			= fd.VhclId
										and tr.pei_deal_id_c			= fd.FeederProdIdAsDealId
			   join @FCNodes	    fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals	> 1
		   and fd.MultiSpvs		= 1
					

		delete tr	 
		  from #Alloc_Transactions_Cur	tr
			   join #Feeders			fd	 on tr.pei_invst_fnd_id_c		= fd.ProdId
											and tr.pei_vhcl_id_c			= fd.VhclId
											and tr.pei_deal_id_c			= fd.FeederProdIdAsDealId
			   join @FCNodes			fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals	> 1
		   and fd.MultiSpvs		= 1		   

		update tr
		   set pei_deal_id_c	= fd.DealId,
			   FeederProdId		= fd.FeederProdId,
			   FeederVhclId		= fd.FeederVhclId
		   from #Alloc_Transactions			tr
				join #Feeders				fd	on  tr.pei_invst_fnd_id_c		= fd.ProdId
												and tr.pei_vhcl_id_c			= fd.VhclId
												and tr.pei_deal_id_c			= fd.FeederProdIdAsDealId
			   join @FCNodes				fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals	= 1
		   and fd.MultiSpvs		= 1	

		update tr
		   set pei_deal_id_c	= fd.DealId,
			   FeederProdId		= fd.FeederProdId,
			   FeederVhclId		= fd.FeederVhclId
		   from #Alloc_Transactions_Cur		tr
				join #Feeders				fd	on  tr.pei_invst_fnd_id_c		= fd.ProdId
												and tr.pei_vhcl_id_c			= fd.VhclId
												and tr.pei_deal_id_c			= fd.FeederProdIdAsDealId
			   join @FCNodes				fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
		 where fd.MultiDeals	= 1
		   and fd.MultiSpvs		= 1	
		
		update tr
		   set pei_invst_fnd_id_c	= fd.ProdId,
			   pei_vhcl_id_c		= fd.VhclId,
			   FeederProdId			= fd.FeederProdId,
			   FeederVhclId			= fd.FeederVhclId,
			   pei_amount_m			= tr.pei_amount_m
		  from #Alloc_Transactions			tr
			   join @FCNodes				fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
			   join #Feeders				fd	 on tr.pei_deal_id_c			= fd.DealId
												and tr.pei_invst_fnd_id_c		= fd.FeederProdId
												and tr.pei_vhcl_id_c			= fd.FeederVhclId			   
			 join pei_invstr_ref			ir   on fd.ProdId					= ir.pei_invstr_invst_fnd_id_c
			   join (select pei_deal_id_c, 
							pei_invst_fnd_id_c, 
							pei_vhcl_id_c
					   from #tmpAlloc_Feeder
					 group by pei_deal_id_c, pei_invst_fnd_id_c, pei_vhcl_id_c
					having sum(pei_alloc_amt_m) <> 0) cm on  cm.pei_deal_id_c	  = fd.DealId 
														and cm.pei_invst_fnd_id_c = fd.ProdId	 
														and cm.pei_vhcl_id_c	  = fd.VhclId
		 where ir.pei_invstr_invst_fnd_id_c	is not null	  
		   and tr.pei_invstr_id_c			= ir.pei_invstr_id_c	
		   and fd.MultiDeals				> 1
		   and fd.MultiSpvs					= 1
		
		update tr
		   set pei_invst_fnd_id_c	= fd.ProdId,
			   pei_vhcl_id_c		= fd.VhclId,
			   FeederProdId			= fd.FeederProdId,
			   FeederVhclId			= fd.FeederVhclId,
			   pei_le_amount_m		= tr.pei_le_amount_m,
			   pei_loc_amount_m		= tr.pei_loc_amount_m
		  from #Alloc_Transactions_Cur		tr
			   join @FCNodes				fc	 on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
			   join #Feeders				fd	 on tr.pei_deal_id_c			= fd.DealId
												and tr.pei_invst_fnd_id_c		= fd.FeederProdId
												and tr.pei_vhcl_id_c			= fd.FeederVhclId			   
			   join pei_invstr_ref			ir   on fd.ProdId					= ir.pei_invstr_invst_fnd_id_c
			   join (select pei_deal_id_c, 
							pei_invst_fnd_id_c, 
							pei_vhcl_id_c
					   from #tmpAlloc_Feeder
					 group by pei_deal_id_c, pei_invst_fnd_id_c, pei_vhcl_id_c
					having sum(pei_alloc_amt_m) <> 0) cm on cm.pei_deal_id_c	  = fd.DealId 
														and cm.pei_invst_fnd_id_c = fd.ProdId	 
														and cm.pei_vhcl_id_c	  = fd.VhclId
		 where ir.pei_invstr_invst_fnd_id_c	is not null	  
		   and tr.pei_invstr_id_c			= ir.pei_invstr_id_c	
		   and fd.MultiDeals				> 1
		   and fd.MultiSpvs					= 1
	end

end



 

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sp_fc_Transactions_Thru_SPV] TO [PE_datareader]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sp_fc_Transactions_Thru_SPV] TO [PE_datawriter]
    AS [dbo];




