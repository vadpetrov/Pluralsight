create procedure [dbo].[sp_ifc_Transactions_Thru_SPV_Investor]
@RunType					int			  = 1,
@InvolvmtIDList_RightSide	varchar(max)  = null -- By passing null stored procedure will buiild only #Feeders part
as
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
declare @UnwantedDeals table  (pei_deal_id_c int);
declare @FCNodes table (pei_involvmt_typ_id_c int);

create table #ttsFeeders
(
	InvestorID				int,
	ProductID				int,
	VehicleID				int,
	DealID					int,
	DealCurrencyID			char(3),
	FeederProductID			int,
	FeederVehicleID			int,
	FeederInvestorID		int,	
	FeederProdIdAsDealId	int,
	SPVType					int default 0,
	Pct						float,
	Pct2					float
)
create unique clustered index TTSPV_FEEDERS_TABLE_IPVDFPFVFI_UCIDX on #ttsFeeders(InvestorID,ProductID,VehicleID,DealID,FeederProductID,FeederVehicleID,FeederInvestorID);
/* ================================================================================================================================ 
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
 ================================================================================================================================ */
begin
set nocount on;
	----------------------------------------------------------------------------
	if len(rtrim(ltrim(isnull(@InvolvmtIDList_RightSide,'')))) = 0 return
	----------------------------------------------------------------------------
	insert into @FCNodes (pei_involvmt_typ_id_c)
	select	s.id
	from	dbo.Split(@InvolvmtIDList_RightSide,';') s
	----------------------------------------------------------------------------
	insert into @UnwantedDeals (pei_deal_id_c)
	select	pei_deal_id_c
	from	pei_deal_ref
	where	pei_unwanted_i = 'Y';
	----------------------------------------------------------------------------
	delete	cm
	from	#tmpAlloc_Feeder cm
			inner join @UnwantedDeals ud
				on cm.pei_deal_id_c = ud.pei_deal_id_c;
	----------------------------------------------------------------------------
	delete	cm
	from	#tmpFeederDtl cm
			inner join @UnwantedDeals ud
				on cm.pei_deal_id_c = ud.pei_deal_id_c;
/* =============================================================================================================================== */
	insert into #ttsFeeders(
			InvestorID,
			ProductID,
			VehicleID,
			DealID,
			DealCurrencyID,
			FeederProductID,
			FeederVehicleID,
			FeederInvestorID,	
			FeederProdIdAsDealId,
			SPVType,
			Pct,
			Pct2)
	select  a.pei_invstr_id_c,
			a.pei_invst_fnd_id_c,
			a.pei_vhcl_id_c,
			a.pei_deal_id_c,
			c.cur_id_c,
			a.FeederFundID,
			a.FeederVhclID,
			a.FeederInvestorID,
			b.pei_deal_id_c,
			case
				when charindex(';', a.FeederFundIDList)= 0 then 1
				else 3
			end,
			a.CmtmtPctMlt/100,
			a.InvestorAllcPct
	from	#tmpFeederDtl a
			inner join pei_deal_ref b
				on a.FeederFundID = b.pei_deal_invst_fnd_id_c
			inner join pei_deal_ref c
				on a.pei_deal_id_c = c.pei_deal_id_c	
	where	a.HasFeeder = 'Y';	
	--------------------------------------------------------------------------------------------
	with spv2 as
	(
		select	a.ProductID,
				a.FeederProductID			
		from	#ttsFeeders a
		where	a.SPVType = 1
				and
				exists(	select	1
						from	#ttsFeeders b
						where	b.SPVType				= 1
								and	a.ProductID			= b.ProductID
								and a.FeederProductID	= b.FeederProductID
								and a.DealID			<> b.DealID)
	)
	update	b
	set		SPVType = 2
	from	spv2 a
			inner join #ttsFeeders b
				on a.ProductID			= b.ProductID
				and a.FeederProductID	= b.FeederProductID;
/* ================================================================================================================================ */	
	If @RunType = 1
	begin
		delete	trn
		from	#FCntl_Transactions_Cur	trn
				inner join @UnwantedDeals udl
					on isnull(trn.pei_deal_id_c, 412) = udl.pei_deal_id_c
				inner join @FCNodes fcn
					on trn.pei_involvmt_typ_id_c = fcn.pei_involvmt_typ_id_c;
		----------------------------------------------------------------------------------------------------
		update	tr
		set		pei_deal_id_c		= fd.DealID,
				FeederProdId		= fd.FeederProductID,
				FeederVhclId		= fd.FeederVehicleID,				
				pei_loc_amount_m	=	case 
											when tr.loc_cur_id_c = fd.DealCurrencyID then tr.pei_loc_amount_m
											else dbo.plCurrencyConvert(tr.pei_le_amount_m,tr.pei_eff_trans_d,tr.le_cur_id_c,fd.DealCurrencyID)
										end,
				loc_cur_id_c		= fd.DealCurrencyID
		from	#FCntl_Transactions_Cur	tr
				inner join #ttsFeeders fd
					on tr.pei_invst_fnd_id_c	= fd.ProductID
					and tr.pei_vhcl_id_c		= fd.VehicleID
					and tr.pei_deal_id_c		= fd.FeederProdIdAsDealId
				inner join @FCNodes fc
					on tr.pei_involvmt_typ_id_c = fc.pei_involvmt_typ_id_c
		where	fd.SPVType = 1;
		----------------------------------------------------------------------------------------------------
		delete	tr	
		from	#FCntl_Transactions_Cur	tr
				inner join #ttsFeeders fd
					on tr.pei_invst_fnd_id_c	= fd.ProductID
					and tr.pei_vhcl_id_c		= fd.VehicleID
					and tr.pei_deal_id_c		= fd.FeederProdIdAsDealId
				inner join @FCNodes fc
					on tr.pei_involvmt_typ_id_c = fc.pei_involvmt_typ_id_c
		where	fd.SPVType = 2;
		----------------------------------------------------------------------------------------------------
		insert into #FCntl_Transactions_Cur(
				pei_orig_deal_id_c,
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
		select  tr.pei_deal_id_c,
				tr.pei_deal_id_c,
				fd.ProductID,
				fd.VehicleID,
				fd.InvestorID,
				tr.pei_trans_typ_id_c,
				tr.pei_involvmt_typ_id_c,
				tr.pei_eff_trans_d,
				tr.pei_trans_status_id_c,
				tr.pei_batch_id_c,
				tr.le_cur_id_c,
				tr.pei_le_amount_m * fd.Pct,
				tr.loc_cur_id_c,
				tr.pei_loc_amount_m * fd.Pct,
				tr.pei_cur_id_c,
				tr.pei_amount_m * fd.Pct,
				fd.FeederProductID,
				fd.FeederVehicleID
		 from	#ttsFeeders	fd
				inner join #FCntl_Transactions_Cur	tr
					on	pei_invst_fnd_id_c	= fd.FeederProductID
					and tr.pei_vhcl_id_c	= fd.FeederVehicleID
					and tr.pei_deal_id_c	= fd.DealId
				inner join @FCNodes fc
					on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c					
		where	fd.SPVType = 3;
		----------------------------------------------------------------------------------------------------
		with ipvd_data(InvestorID,ProductID,VehicleID,DealID) as
		(
			select	pei_invstr_id_c,
					pei_invst_fnd_id_c, 
					pei_vhcl_id_c,
					pei_deal_id_c
			from	#tmpAlloc_Feeder
			group by pei_invstr_id_c, pei_invst_fnd_id_c, pei_vhcl_id_c, pei_deal_id_c
			having sum(pei_alloc_amt_m) <> 0		
		)		
		insert into #FCntl_Transactions_Cur(
				pei_orig_deal_id_c,
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
		select  tr.pei_deal_id_c,
				tr.pei_deal_id_c,
				fd.ProductID,
				fd.VehicleID,
				fd.InvestorID,
				tr.pei_trans_typ_id_c,
				tr.pei_involvmt_typ_id_c,
				tr.pei_eff_trans_d,
				tr.pei_trans_status_id_c,
				tr.pei_batch_id_c,
				tr.le_cur_id_c,
				tr.pei_le_amount_m * fd.Pct2,
				tr.loc_cur_id_c,
				tr.pei_loc_amount_m * fd.Pct2,
				tr.pei_cur_id_c,
				tr.pei_amount_m * fd.Pct2,
				fd.FeederProductID,
				fd.FeederVehicleID
		 from	#ttsFeeders	fd
				inner join #FCntl_Transactions_Cur	tr
					on	tr.pei_invstr_id_c		= fd.FeederInvestorID
					and tr.pei_invst_fnd_id_c	= fd.FeederProductID
					and tr.pei_vhcl_id_c		= fd.FeederVehicleID
					and tr.pei_deal_id_c		= fd.DealID
				inner join @FCNodes fc
					on tr.pei_involvmt_typ_id_c	= fc.pei_involvmt_typ_id_c
				inner join ipvd_data cm 
					on	cm.InvestorID			= fd.InvestorID
						and cm.ProductID		= fd.ProductID
						and cm.VehicleID		= fd.VehicleID	 
						and cm.DealID			= fd.DealID										
		where	fd.SPVType = 2;
	end
end 

GO
grant execute on dbo.sp_ifc_Transactions_Thru_SPV_Investor to PE_datawriter, PE_datareader;
GO
