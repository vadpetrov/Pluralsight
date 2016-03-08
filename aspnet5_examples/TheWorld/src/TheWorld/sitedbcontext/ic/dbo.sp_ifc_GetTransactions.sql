create procedure dbo.sp_ifc_GetTransactions
@ProductIDList				varchar(max) = null,
@DealIDList					varchar(max) = null,
@InvestorIDList				varchar(max) = null,
@VehicleIDList  			varchar(max) = null,
@InvolvmtIDList 			varchar(max) = null,
@AsOfDate 					datetime,
@CurrencyConversion			char(1)	      = 'N',
@TransSide					char(1)	      = 'B',   -- L - Left-Side; R - Right-Side; B - Both
@CurrencyID					char(3)	      = 'USD',
@ApplyCutoffLogic			char(1)	      = 'N',   -- N - Cutoff not applied; Y - Cutoff applied;
@TransStatus				varchar(20)	  = '3;4',
@UseOriginalDealId			char(1)		  = 'N',
@AddOnAIVDeals				char(1)		  = 'Y',
@AddOnPriorPcap				char(1)		  = 'N',	-- Real Time IRR Run
@GetMaxDtsDate				char(1)		  = 'N',
@ApplySoldDealLogic			char(1)	      = 'N',
@ApplyEffectiveDateLogic	char(1)		  = 'Y'

as

declare @Msg varchar(2000);

create table #Eff_Batch_Process(BatchID		int);
		
create table #DTS_BatchExclude
(
	pei_batch_id_c				int,
	pei_investran_batch_id_c	int,
	PeriodGL					datetime,
	EffectiveDate				datetime
);
create table #dtsProductPostedDate
(
	ProductID			int,			
	InvestranProductID	int,
	EffectiveDate		datetime,
	InvestranPostDate	datetime
);
/********************************************
Temp tables defined in the calling stored proc
=============================================

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
	pei_amount_m				decimal(30,2)
)

********************************************/

create table #Transactions_Local
(
	pei_orig_deal_id_c			int,
	pei_deal_id_c				int,
	pei_invst_fnd_id_c			int,
	pei_vhcl_id_c				int,
	pei_invstr_id_c				int,
	pei_trans_typ_id_c			int,
	pei_eff_trans_d				datetime,
	pei_trans_status_id_c		int,
	le_cur_id_c					char(3),
	loc_cur_id_c				char(3),
	pei_le_amount_m				decimal(30,2),
	pei_loc_amount_m			decimal(30,2),
	pei_batch_id_c				int,
	pei_investran_trans_id_c	int,
	pei_acct_id_c				int,
	pei_pos_id_c				int,
	pei_posted_d				datetime,
	pei_master_invst_fnd_id_c	int
);

create table #Deals   		(DealID		int, cur_id_c char(3), pei_direct_invst_i char(1))
create table #Prods   		(ProdID		int, cur_id_c char(3), pei_invst_fnd_excel_grp_id_c int null)
create table #Vhcls   		(VhclID		int)
create table #Invstrs 		(InvstrID	int)
create table #Involv  		(InvolvID	int, pei_investran_hei_typ_i char(1))
create table #TransSt 		(TransStID	int)
create table #TransTypXref	(pei_involvmt_typ_id_c	int, pei_trans_typ_id_c	int, pei_trans_wt_m float)
create table #FxDates		(TransDate	datetime, CurrencyID char(3), FxDate datetime)
create table #FxRates		(TransDate	datetime, FxDate datetime, CurrencyID char(3), CurrencyRate	float)

create unique clustered index GetTrans_Deals_ClstIndx		on #Deals(DealID)
create unique clustered index GetTrans_Prods_ClstIndx		on #Prods(ProdID)
create unique clustered index GetTrans_Invstrs_ClstIndx		on #Invstrs(InvstrID)
create unique clustered index GetTrans_Vhcls_ClstIndx		on #Vhcls(VhclID)
create unique clustered index GetTrans_Involv_ClstIndx		on #Involv(InvolvID)
create unique clustered index GetTrans_TransSt_ClstIndx		on #TransSt(TransStID)
create unique clustered index GetTrans_FxDates_ClstIndx		on #FxDates(CurrencyID,TransDate)
create unique clustered index GetTrans_FxRates_ClstIndx		on #FxRates(TransDate,CurrencyID)

begin
set nocount on

	set @ProductIDList				= nullif(@ProductIDList,'');
	set @DealIDList					= nullif(@DealIDList,'');
	set @VehicleIDList				= nullif(@VehicleIDList,'');
	set @InvestorIDList				= nullif(@InvestorIDList,'');	
	set @CurrencyID					= isnull(nullif(@CurrencyID,''), 'USD');

	if isnull(@InvolvmtIDList, '') = ''
	begin
		set @Msg = 'Must pass at least one involvment type to the calling transaction stored proc!'
		raiserror (@Msg,15,1) with seterror
		return
	end
	
	insert into #DTS_BatchExclude  (pei_batch_id_c,
									pei_investran_batch_id_c,
									PeriodGL,
									EffectiveDate)
	select  be.pei_batch_id_c,
			be.pei_investran_batch_id_c,
			be.PeriodGL,
			be.EffectiveDate
	  from  DTS_BatchExclude be
	 where	be.EffectiveDate > @AsOfDate
	   and  not exists (select 1
					     from ifc_rpt_trans_xref bi -- see ifc_rpt_trans_xref view which includes pei_irr_incl_batch where pei_irr_incl_i = 'I'
					    where bi.ifc_qt_signoff_dz = @AsOfDate
						  and bi.pei_batch_id_c	   = be.pei_batch_id_c);
	
	
	set @CurrencyID = dbo.fnManualOriginalCurrency(@CurrencyID,2);
	
/****************************
 Load Products
*****************************/

	with products(ProductID) as
	(
		select a.id
		  from dbo.Split(@ProductIDList,';') a
		 where @ProductIDList is not null
		union
		select a.pei_invst_fnd_id_c
		  from pei_invst_fnd_vhcl_ref				a
			   join dbo.Split(@VehicleIDList,';')	b 	on a.pei_vhcl_id_c = b.ID			
		 where @ProductIDList	is null
		   and @VehicleIDList	is not null
		union
		select a.pei_invst_fnd_id_c
		  from pei_invst_fnd_invstr					a
			   join dbo.Split(@InvestorIDList,';')	b	on a.pei_invstr_id_c = b.ID			
		 where @ProductIDList	is null
		   and @VehicleIDList	is null		
		   and @InvestorIDList	is not null
		union
		select a.pei_invst_fnd_id_c
		  from pei_invst_fnd_deal_xref				a
			   join dbo.Split(@DealIDList,';')		b	on a.pei_deal_id_c = b.ID
		 where @ProductIDList	is null
		   and @VehicleIDList	is null		
		   and @InvestorIDList	is null	
		   and @DealIDList		is not null
	)
	
	insert into #Prods(ProdID, cur_id_c, pei_invst_fnd_excel_grp_id_c)
	select a.ProductID,
		   b.cur_id_c,
		   b.pei_invst_fnd_excel_grp_id_c
	  from products					a
		   join pei_invst_fnd_ref	b	on a.ProductID = b.pei_invst_fnd_id_c
	union
	select a.pei_invst_fnd_id_c,
		   a.cur_id_c,
		   a.pei_invst_fnd_excel_grp_id_c
	  from pei_invst_fnd_ref a
	 where @ProductIDList	is null
	   and @VehicleIDList	is null
	   and @InvestorIDList	is null						
	   and @DealIDList		is null;
/****************************
 Load Deals
*****************************/	
	with deals(DealID) as
	(
		select	a.ID
		from	dbo.Split(@DealIDList,';') a
		where	@DealIDList is not null
		union
		select	a.pei_deal_id_c
		from	pei_invst_fnd_deal_xref a
				inner join #Prods b
					on a.pei_invst_fnd_id_c = b.ProdID
		where	@DealIDList is null	
	)
	insert into #Deals(DealID, cur_id_c, pei_direct_invst_i)
	select	a.DealID,
			b.cur_id_c,
			b.pei_direct_invst_i
	from	deals a
			inner join pei_deal_ref b
				on a.DealID = b.pei_deal_id_c;

	if isnull(@DealIDList, '') != '' and @AddOnAIVDeals = 'Y'
	begin
		/*************************************************************************
	 	Insert any deal dependency deals based on investran prod-deal relationship
		**************************************************************************/
		if @AddOnAIVDeals = 'Y'
		begin
			insert into #Deals (DealID, cur_id_c, pei_direct_invst_i)
			select distinct
				   d.pei_deal_id_c,
				   d.cur_id_c,
				   d.pei_direct_invst_i
			  from pei_invst_fnd_deal_xref	dx
				   join #Deals					on dx.pei_deal_id_c_AIVFamily	= DealID
				   join #Prods					on dx.pei_invst_fnd_id_c		= ProdID
				   join pei_deal_ref		d	on d.pei_deal_id_c				= DealID
			 where not exists(select 1 
								from #Deals dd 
							   where dd.DealID = d.pei_deal_id_c)
		end
	end;	
/****************************
 Load Investors
*****************************/
	with investors(InvestorID) as
	(
		select	a.ID
		from	dbo.Split(@InvestorIDList,';') a
		where	@InvestorIDList is not null
		union
		select	a.pei_invstr_id_c
		from	pei_invst_fnd_invstr a
				inner join #Prods b
					on a.pei_invst_fnd_id_c = b.ProdID
		where	@InvestorIDList is null
	)
	insert into #Invstrs(InvstrID)
	select a.InvestorID
	from investors a;
/****************************
 Load Vehicles
*****************************/	
	with vehicles(VehicleID) as
	(
		select	a.ID
		from	dbo.Split(@VehicleIDList,';') a
		where	@VehicleIDList is not null
		union
		select	a.pei_vhcl_id_c
		from	pei_invst_fnd_vhcl_ref a
				inner join #Prods b
					on a.pei_invst_fnd_id_c = b.ProdID			
		where	@VehicleIDList is null		
	)
	insert into #Vhcls(VhclID)
	select a.VehicleID
	from vehicles a;	  
/****************************
 Load Involvment & Trans Codes
*****************************/
	insert into #Involv (InvolvID, pei_investran_hei_typ_i)
	select	i.pei_involvmt_typ_id_c,
			i.pei_investran_hei_typ_i
	from	dbo.Split(@InvolvmtIDList,';') a
			inner join pei_involvmt_typ_ref	i
				on a.id = i.pei_involvmt_typ_id_c
	where	i.pei_involvmt_typ_id_c	not in (27, 28)	
			and i.pei_investran_hei_typ_i	= 'T';   
	------------------------------------------------------	   
	if @@rowcount = 0
	begin
		set @Msg = 'Involvment Types 27/28 are not processed by the calling transaction stored proc!'
		raiserror (@Msg,15,1) with seterror
		return
	end   
	------------------------------------------------------	
	insert into #TransTypXref (pei_involvmt_typ_id_c,pei_trans_typ_id_c,pei_trans_wt_m)
	select	x.pei_involvmt_typ_id_c,
			x.pei_trans_typ_id_c,
			x.pei_trans_wt_m
	from	pei_trans_typ_xref x
			inner join #Involv i
				on x.pei_involvmt_typ_id_c = i.InvolvID;
/****************************
 Load Trans Status Codes
*****************************/
	insert into #TransSt (TransStID)
	select	a.id
	from	dbo.Split(@TransStatus,';') a
	where	isnull(@TransStatus, '') != ''
	union
	select	pei_trans_status_id_c 
	from	pei_trans_status_ref 
	where	isnull(@TransStatus, '') = ''
			and pei_investran_trans_status_id_c in (2,3); -- Posted,Exported	 	
/***************************************
 Determine cutoff date for each product
****************************************/
	
	set @ApplyCutoffLogic = isnull(@ApplyCutoffLogic, 'Y')

	if @ApplyCutoffLogic = 'Y' 
	begin
		exec dbo.sp_ifcxGetDTS_CutOffDates @ProductIDList, @AsOfDate, @GetMaxDtsDate
		
		if @GetMaxDtsDate = 'Y'
		begin
			delete #dtsProductPostedDate where InvestranPostDate is null
			
			delete #dtsProductPostedDate
			  from #dtsProductPostedDate		d1
				   join (select ProductID,
								max(InvestranPostDate) as InvestranPostDate
						   from #dtsProductPostedDate
						  group by ProductID)	d2 on d1.ProductID		   = d2.ProductID
												  and d1.InvestranPostDate < d2.InvestranPostDate
		end
		
		if @ApplySoldDealLogic = 'Y'
		begin
		-- fake DTS sign-offs for sold products that no longer get DTS
			update #dtsProductPostedDate
			   set EffectiveDate = @AsOfDate,
				   InvestranPostDate = @AsOfDate --z.solddate
			  from ( select ref.pei_invst_fnd_id_c,
							max(pei_invst_fnd_vhcl_sold_dt) as solddate
					   from pei_invst_fnd_vhcl_ref ref
					  where ref.pei_invst_fnd_vhcl_sold_dt is not null
					    and ref.pei_invst_fnd_vhcl_sold_dt <= @AsOfDate
					    and not exists ( select 1 from pei_invst_fnd_vhcl_ref ref1
										  where ref1.pei_invst_fnd_id_c = ref.pei_invst_fnd_id_c
										    and ref1.pei_invst_fnd_vhcl_sold_dt is null)
					 group by ref.pei_invst_fnd_id_c ) z
			 where #dtsProductPostedDate.ProductID		= z.pei_invst_fnd_id_c
			   and #dtsProductPostedDate.EffectiveDate	is null		-- no DTS signoff found				
		end
	end
	
/**************************************************
 Get Transactions
***************************************************/
	
	if isnull(@DealIDList, '') != ''
	begin
		set @TransSide = 'R'
	end
	else
	begin
		if isnull(@TransSide, '') = '' 
		begin
			set @TransSide = 'B'
		end
	end

/**************************************************
 Get data from allocation table
***************************************************/
	;with tt(TransTypeID) as
	(
		select	distinct
				a.pei_trans_typ_id_c
		from	#TransTypXref a		
	)
	insert into #Transactions_Local(
			pei_orig_deal_id_c,
			pei_deal_id_c,
			pei_invst_fnd_id_c,
			pei_vhcl_id_c,
			pei_invstr_id_c,
			pei_trans_typ_id_c,
			pei_eff_trans_d,
			pei_trans_status_id_c,
			le_cur_id_c,
			loc_cur_id_c,
			pei_le_amount_m,
			pei_loc_amount_m,
			pei_batch_id_c,
			pei_investran_trans_id_c,
			pei_acct_id_c,
			pei_posted_d)
	select  T.pei_orig_deal_id_c,
			T.pei_deal_id_c,
			T.pei_invst_fnd_id_c,
			T.pei_vhcl_id_c,
			T.pei_invstr_id_c,
			T.pei_trans_typ_id_c,
			T.pei_eff_trans_d,
			T.pei_trans_status_id_c,
			T.le_cur_id_c,
			T.loc_cur_id_c,
			T.pei_le_alloc_amt_m,
			T.pei_loc_alloc_amt_m,
			T.pei_batch_id_c,
			T.pei_investran_trans_id_c,
			T.pei_acct_id_c,
			T.pei_investran_post_dz
	from 	pei_allc_data 			T
			inner join #Prods Prods
				on T.pei_invst_fnd_id_c = Prods.ProdID	
			inner join #Vhcls Vhcl
				on T.pei_vhcl_id_c = Vhcl.VhclID
			inner join #Invstrs	Invstrs
				on T.pei_invstr_id_c = Invstrs.InvstrID
			inner join #TransSt ts
				on t.pei_trans_status_id_c = ts.TransStID
			inner join tt 
				on t.pei_trans_typ_id_c = tt.TransTypeID	
	where	t.pei_eff_trans_d <= @AsOfDate;
/**************************************************
 Remove unwanted data
***************************************************/
	if @TransSide = 'R'
	begin		
		delete #Transactions_Local where pei_deal_id_c is null;
		------------------------------------------------------
		delete	a
		from	#Transactions_Local a
		where	not exists(	select	1 
							from	#Deals b
							where	a.pei_deal_id_c = b.DealID);
	end     
	
	if @ApplyCutoffLogic = 'Y'
	begin
		delete #Transactions_Local where pei_posted_d is null	
	
		delete #Transactions_Local
		 where #Transactions_Local.pei_batch_id_c in (select be.pei_batch_id_c from #DTS_BatchExclude be)
					
		delete #Transactions_Local
		 where #Transactions_Local.pei_posted_d > (select dts.InvestranPostDate
													 from #dtsProductPostedDate dts
													where dts.ProductID = #Transactions_Local.pei_invst_fnd_id_c)
		   and #Transactions_Local.pei_batch_id_c not in (select bx.pei_batch_id_c
		      												from ifc_rpt_trans_xref bx -- see ifc_rpt_trans_xref view which includes pei_irr_incl_batch where pei_irr_incl_i = 'I'
		     											   where bx.ifc_qt_signoff_dz  = @AsOfDate
	       				 									 and bx.pei_invst_fnd_id_c = #Transactions_Local.pei_invst_fnd_id_c)
/**************************************************
 1. Remove SPV if SPV's transaction posted date is
    greater than cutoff date of the master product
 2. Remove SPV if SPV's batch is not included for
    selected statement period
***************************************************/
						      
		update #Transactions_Local
		   set pei_master_invst_fnd_id_c = invstr.pei_invstr_invst_fnd_id_c
		  from pei_invst_fnd_ref prod,
			   pei_invstr_ref	 invstr
		 where prod.pei_invst_fnd_feeder_i				= 'Y'
		   and #Transactions_Local.pei_invst_fnd_id_c	= prod.pei_invst_fnd_id_c
		   and #Transactions_Local.pei_invstr_id_c		= invstr.pei_invstr_id_c
		   and invstr.pei_invstr_invst_fnd_id_c			is not null

		delete #Transactions_Local
		 where #Transactions_Local.pei_master_invst_fnd_id_c is not null
		   and #Transactions_Local.pei_posted_d > (select cpd.InvestranPostDate
													 from #dtsProductPostedDate cpd
													where cpd.ProductID = #Transactions_Local.pei_master_invst_fnd_id_c)
		   and #Transactions_Local.pei_batch_id_c not in (select bx.pei_batch_id_c
		      												from ifc_rpt_trans_xref bx -- see ifc_rpt_trans_xref view which includes pei_irr_incl_batch where pei_irr_incl_i = 'I'
		     											   where bx.ifc_qt_signoff_dz  = @AsOfDate
	       				 									 and bx.pei_invst_fnd_id_c = #Transactions_Local.pei_invst_fnd_id_c)
	end		
/***************************************
 Transfer data to output table
***************************************/
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
			le_cur_id_c,
			loc_cur_id_c,
			pei_le_amount_m,
			pei_loc_amount_m,
			pei_batch_id_c,
			pei_investran_trans_id_c,
			pei_acct_id_c,
			pei_pos_id_c,
			pei_cur_id_c,
			pei_amount_m)
	select	tl.pei_orig_deal_id_c,
			tl.pei_deal_id_c,
			tl.pei_invst_fnd_id_c,
			tl.pei_vhcl_id_c,
			tl.pei_invstr_id_c,
			tl.pei_trans_typ_id_c,
			tx.pei_involvmt_typ_id_c,
			tl.pei_eff_trans_d,
			tl.pei_trans_status_id_c,
			tl.le_cur_id_c,
			tl.loc_cur_id_c,
			tl.pei_le_amount_m	* tx.pei_trans_wt_m,
			tl.pei_loc_amount_m	* tx.pei_trans_wt_m,
			tl.pei_batch_id_c,
			tl.pei_investran_trans_id_c,
			tl.pei_acct_id_c,
			tl.pei_pos_id_c,
			@CurrencyID,		   
			case
				when @CurrencyConversion = 'Y' and tl.le_cur_id_c  = @CurrencyID then tl.pei_le_amount_m * tx.pei_trans_wt_m
				when @CurrencyConversion = 'Y' and tl.loc_cur_id_c = @CurrencyID and tl.pei_le_amount_m <> tl.pei_loc_amount_m then tl.pei_loc_amount_m * tx.pei_trans_wt_m
				else null
			end
	  from	#Transactions_Local	tl
			inner join #TransTypXref tx
				on tl.pei_trans_typ_id_c = tx.pei_trans_typ_id_c
	----------------------------------------------------------			
	truncate table #Transactions_Local;		   
	drop table #Transactions_Local;
/***************************************************************
 Apply Currency conversion
****************************************************************/	       
	if isnull(@CurrencyConversion, 'N') = 'Y'
	begin			
		update #FCntl_Transactions_Cur
		   set pei_amount_m = case when le_cur_id_c  = pei_cur_id_c then pei_le_amount_m 
								   when loc_cur_id_c = pei_cur_id_c and pei_le_amount_m <> pei_loc_amount_m then pei_loc_amount_m
								   else null
							  end
		 where @CurrencyConversion		= 'Y'
		   and pei_involvmt_typ_id_c	= 35  
		   and pei_amount_m				is null; 	
		------------------------------------------------------------	
		insert into #FxDates (TransDate, CurrencyID)
		select t.pei_eff_trans_d,
			   c.cur_id_c
		  from #FCntl_Transactions_Cur t
				cross join pei_cur_ref c
		 where c.pei_cur_used_i = 'Y'
		group by t.pei_eff_trans_d, 
				 c.cur_id_c
				 
		update #FxDates
		   set FxDate	= (select max(pei_fx_rte_ef_d)
							from pei_cur_fx_ref  b
						   where b.cur_id_c			 = #FxDates.CurrencyID
							 and b.pei_fx_rte_ef_d  <= #FxDates.TransDate) 

		insert into #FxRates (TransDate, FxDate, CurrencyID, CurrencyRate)
		select a.TransDate,
			   a.FxDate,
			   a.CurrencyID,
			   b.pei_cur_fx_p
		  from #FxDates				a
			   join pei_cur_fx_ref	b	on a.CurrencyID = b.cur_id_c
									   and a.FxDate		= b.pei_fx_rte_ef_d
			   
		update #FCntl_Transactions_Cur
		   set pei_amount_m = isnull(atc.pei_le_amount_m * (fx2.CurrencyRate/fx1.CurrencyRate),0)
		  from #FCntl_Transactions_Cur		atc
			   join #FxRates				fx1 on atc.pei_eff_trans_d	= fx1.TransDate
											   and atc.le_cur_id_c		= fx1.CurrencyID
			   join #FxRates				fx2 on atc.pei_eff_trans_d	= fx2.TransDate
											   and atc.pei_cur_id_c		= fx2.CurrencyID
		 where atc.pei_amount_m			 is null	
		   and atc.pei_involvmt_typ_id_c != 45	   
	end
	
	if isnull(@ApplyEffectiveDateLogic, 'N') = 'Y'
	begin
		delete #Prods where pei_invst_fnd_excel_grp_id_c = 2
		truncate table #Eff_Batch_Process;

		if exists (select 1 from #Prods) 
		begin	 	
			insert into #Eff_Batch_Process (BatchID)
			select pei_batch_id_c
			  from DTS_BatchExclude
			 where EffectiveDate > @AsOfDate
			group by pei_batch_id_c
		   	
			delete #FCntl_Transactions_Cur
			  from #FCntl_Transactions_Cur  tr
				   join #Prods				pr on tr.pei_invst_fnd_id_c		= pr.ProdID
				   join #Eff_Batch_Process	bt on abs(tr.pei_batch_id_c)	= abs(bt.BatchID)
		end
	end
	
	drop table #Deals
	drop table #Prods
	drop table #Vhcls
	drop table #Invstrs
	drop table #Involv
	drop table #TransSt
	drop table #dtsProductPostedDate
	drop table #DTS_BatchExclude
end 
GO
grant execute on dbo.sp_ifc_GetTransactions to PE_datawriter, PE_datareader;
GO