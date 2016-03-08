create procedure [dbo].[sp_fc_LoadCommitments_SPV_Adapter]
@ReportDate 			datetime 		= null,
@ProdVhclInvstrFilter 	char(1) 		= 'N',
@ThroughFeeder			char(1) 		= 'Y',
@LoadDetails			char(1) 		= 'Y',
@CurrencyID 			char(3) 		= 'USM',
@Status					varchar(max)  	= null,
@CutOffStatement		datetime		= null,
@MultCurrency			char(1)			= 'D',
@MultCurrencyManual		char(1)			= 'N',
@PurchaseDiscount		char(1)			= 'N',
@FeederShortNames		char(1)			= 'Y',
@FilterZeros			char(1)			= 'Y',
@Threshold				decimal(30,0)	= 1,
@MaxLevel				int				= null
as
	set nocount on;
begin
/* ==================================================================================================================
	create table #tmpFilterDeals	(pei_deal_id_c			int)
	create table #tmpFilterProds	(pei_invst_fnd_id_c		int)
	create table #tmpFilterInvestors(pei_invstr_id_c		int)		
	create table #tmpFilterVehicles	(pei_vhcl_id_c			int)

	create table #tmpAlloc_Feeder
	(
		pei_deal_id_c 			int,
		pei_invst_fnd_id_c 		int,
		pei_vhcl_id_c 			int,
		pei_invstr_id_c			int,
		pei_trans_typ_id_c 		int,
		pei_eff_trans_d			datetime,
		pei_alloc_amt_m			decimal(30,2),
		pei_trans_status_id_c	int,
		cur_id_c				char(3),
		pei_mlt_cur_id_c		char(3),
		pei_alloc_amt_mlt		decimal(30,2),
		IsFeeder				char(1),
		HasFeeder				char(1),
		FeederFundID			int,
		FeederVhclID			int
	);
	create index LCSPV_ALLC_FEEDER_ADAPTER_PVD_IDX on #tmpAlloc_Feeder(pei_invst_fnd_id_c,pei_vhcl_id_c,pei_deal_id_c);
	
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
	);
	create unique index LCSPV_ALLC_FEEDER_DET_ADAPTER_PVD_UIDX on #tmpAlloc_Feeder(pei_invst_fnd_id_c,pei_vhcl_id_c,pei_deal_id_c);
================================================================================================================== */
	if object_id('tempdb..#tmpAlloc_Feeder') is not null	
		and
		not exists(
		select	1 
		from	tempdb.sys.indexes 
		where	object_id = object_id('tempdb..#tmpAlloc_Feeder')
				and name = 'LCSPV_ALLC_FEEDER_ADAPTER_PVD_IDX')
	begin	
		create index LCSPV_ALLC_FEEDER_ADAPTER_PVD_IDX on #tmpAlloc_Feeder(pei_invst_fnd_id_c,pei_vhcl_id_c,pei_deal_id_c);
	end	
	---------------------------------------
	if object_id('tempdb..#tmpFeederDtl') is not null	
		and
		not exists(
		select	1 
		from	tempdb.sys.indexes 
		where	object_id = object_id('tempdb..#tmpFeederDtl')
				and name = 'LCSPV_ALLC_FEEDER_DET_ADAPTER_PVD_UIDX')
	begin	
		create unique index LCSPV_ALLC_FEEDER_DET_ADAPTER_PVD_UIDX	on #tmpFeederDtl(pei_invst_fnd_id_c,pei_vhcl_id_c,pei_deal_id_c);
	end	
/* ================================================================================================================== */
	create table #lcsfMasterData
	(
		RowID						int identity(1,1),
		Iteration					int,
		ReferenceID					int default 0,
		ProductID					int,
		VehicleID					int,
		InvestorID					int,
		DealID						int,
		EffectiveDate				datetime,
		TransTypeID					int,		
		TransStatusID				int,
		PVDTotal					decimal(30,2),
		PVDTotalAdj					decimal(30,2),
		MltPVDTotal					decimal(30,2),
		MltPVDTotalAdj				decimal(30,2),
		CurrencyID					char(3),
		CmtmtAmount					decimal(30,2),
		MltCurrencyID				char(3),
		MultCurrency				char(1),
		MultCurrencyManual			char(1),
		MltCmtmtAmount				decimal(30,2),		
		pei_amt_m_USD				decimal(30,2),
		pei_amt_m_EUR				decimal(30,2),
		pei_amt_m_AUD				decimal(30,2),
		pei_amt_m_GBP				decimal(30,2),
		pei_amt_m_CAD				decimal(30,2),
		pei_amt_m_ZAR				decimal(30,2),
		pei_amt_m_SEK				decimal(30,2),
		pei_amt_m_CHF				decimal(30,2),
		pei_amt_m_NOK				decimal(30,2),
		pei_amt_m_JPY				decimal(30,2),
		pei_amt_m_INR				decimal(30,2),
		pei_amt_m_PLN				decimal(30,2),
		pei_amt_m_BRL				decimal(30,2),
		pei_amt_m_KWD				decimal(30,2),
		pei_amt_m_SGD				decimal(30,2),
		pei_amt_m_SAR				decimal(30,2),
		pei_amt_m_DKK				decimal(30,2),
		pei_amt_m_KRW				decimal(30,2),
		pei_amt_m_IDR				decimal(30,2),
		pei_amt_m_YER				decimal(30,2),		
		pei_amt_m_USD_man			decimal(30,2),
		pei_amt_m_EUR_man			decimal(30,2),
		pei_amt_m_GBP_man			decimal(30,2),
		pei_amt_m_CAD_man			decimal(30,2),	
		pei_amt_m_CHF_man			decimal(30,2),
		pei_amt_m_KRW_man			decimal(30,2),	
		RowType						char(1),
		BatchID						int,
		PostDate					datetime,		
		TransactionID				int,
		RefProductID				int default 0,
		RefVehicleID				int default 0,
		RefInvestorID				int default 0,
		RefDealID					int	default 0,
		ReportProductID				int	default 0,
		ReportVehicleID				int default 0,
		ReportInvestorID			int default 0,
		ReportDealID				int default 0,
		ReportEffectiveDate			datetime,
		RunProductID				int default 0,
		RunVehicleID				int default 0,
		RunInvestorID				int default 0,
		RunDealID					int default 0
	)
	create clustered index LCSF_MASTER_IPDIV_CIDX on #lcsfMasterData(Iteration,ProductID,DealID,InvestorID,VehicleID);	
	create index LCSF_MASTER_REFID_IDX on #lcsfMasterData(ReferenceID);
	------------------------------------------------------------
	create table #lcsfAdapterFeeders
	(
		Iteration	int,
		RowID		int,
		ProductID	int,
		VehicleID	int,
		DealID		int,
		FeederID	varchar(max),
		FeederName	varchar(max)
	);
	create index LCSF_MASTER_ADAPTER_FEEDERS_ROWID_IDX on #lcsfAdapterFeeders (RowID);	
/* ============================================================================================================= */		
	declare @ProductID		varchar(max);
	declare @DealID 		varchar(max);
	declare @InvestorID		varchar(max);
	declare @VehicleID 		varchar(max);
	declare @ProcessType	int;
	declare @RunType		int;
	------------------------------------------------------
	set @Threshold				= isnull(@Threshold,1);
	set @MultCurrency			= isnull(@MultCurrency,'D');
	set @CurrencyID				= isnull(@CurrencyID,'USM');
	set @FilterZeros			= isnull(@FilterZeros,'N');
	set @PurchaseDiscount		= isnull(@PurchaseDiscount,'N');
	set @FeederShortNames		= isnull(@FeederShortNames,'Y');
	set @ProcessType			= case isnull(@ThroughFeeder,'Y') when 'Y' then 1 else 0 end;
	set @RunType				= case isnull(@ProdVhclInvstrFilter,'Y') when 'N' then 2 else 1 end;
/* ============================================================================================================= */	
	if @RunType = 2
	begin
		set @DealID = ''
		update #tmpFilterDeals		set @DealID = @DealID + convert(varchar(20),pei_deal_id_c) + ';'
		if len(@DealID) > 0			set @DealID = left(@DealID,len(@DealID)-1);
	end
/* ============================================================================================================= */	
	if @RunType = 1
	begin
		set @ProductID = ''
		update #tmpFilterProds	set @ProductID = @ProductID + convert(varchar(20),pei_invst_fnd_id_c) + ';'
 		if len(@ProductID) > 0	set @ProductID = left(@ProductID,len(@ProductID)-1);
	end
/* ============================================================================================================= */
	if @RunType = 1 and (select count(*) from #tmpFilterVehicles) <> (select count(*) from pei_vhcl_ref)
	begin
		set @VehicleID = ''
		update #tmpFilterVehicles	set @VehicleID = @VehicleID + convert(varchar(20),pei_vhcl_id_c) + ';'
		if len(@VehicleID) > 0		set @VehicleID = left(@VehicleID,len(@VehicleID)-1);
	end
/* ============================================================================================================= */
	if @RunType = 1 and (select count(*) from #tmpFilterInvestors) <> (select count(*) from pei_invstr_ref)
	begin
		set @InvestorID = ''
		update #tmpFilterInvestors	set @InvestorID = @InvestorID + convert(varchar(20),pei_invstr_id_c) + ';'
		if len(@InvestorID) > 0		set @InvestorID = left(@InvestorID,len(@InvestorID)-1);
	end	
/* ============================================================================================================= */	
	exec dbo.sp_fc_LoadCommitments
	@ProductID 			= @ProductID,
	@DealID 			= @DealID,
	@InvestorID 		= @InvestorID,
	@VehicleID 			= @VehicleID,
	@Status				= @Status,
	@ReportDate			= @ReportDate,
	@CutOffStatement	= @CutOffStatement,
	@CurrencyID 		= @CurrencyID,
	@MultCurrency		= @MultCurrency, -- 'P' = Product , 'D' = Deal
	@MultCurrencyManual	= @MultCurrencyManual,
	@PurchaseDiscount	= @PurchaseDiscount,
	@ProcessType		= @ProcessType, -- 0 -Direct / 1 - SPV / 2 - FOF
	@FilterZeros		= @FilterZeros,
	@MaxLevel			= @MaxLevel;
/* ============================================================================================================= */	
	insert into #tmpAlloc_Feeder(
			pei_deal_id_c,
			pei_invst_fnd_id_c,
			pei_vhcl_id_c,
			pei_invstr_id_c,
			pei_trans_typ_id_c,
			pei_eff_trans_d,
			pei_alloc_amt_m,
			pei_trans_status_id_c,
			cur_id_c,
			pei_mlt_cur_id_c,
			pei_alloc_amt_mlt,
			IsFeeder,
			HasFeeder,
			FeederFundID,
			FeederVhclID)
	select	a.ReportDealID,
			a.ReportProductID,
			a.ReportVehicleID,
			a.ReportInvestorID,
			a.TransTypeID,
			a.ReportEffectiveDate,
			a.CmtmtAmount,
			a.TransStatusID,
			a.CurrencyID,
			a.MltCurrencyID,
			a.MltCmtmtAmount,
			'N',
			case a.Iteration when 1 then 'N' else 'Y' end,		
			case a.Iteration when 1 then null else a.RunProductID end,
			case a.Iteration when 1 then null else a.RunVehicleID end
	from	#lcsfMasterData a
	where	not exists(	select	1
						from	#lcsfMasterData b
						where	a.RowID = b.ReferenceID)
			and (@FilterZeros = 'N' or a.PVDTotalAdj > @Threshold);
/* ============================================================================================================= */
	delete #tmpAlloc_Feeder where pei_alloc_amt_m = 0 and pei_alloc_amt_mlt = 0;
	delete #lcsfMasterData where CmtmtAmount = 0 and MltCmtmtAmount = 0;
/* ============================================================================================================= */	
	delete	#tmpAlloc_Feeder
	from	#tmpAlloc_Feeder a
	where	not exists (select	1 from	#tmpFilterProds c	where a.pei_invst_fnd_id_c = c.pei_invst_fnd_id_c);
	-------------------------------
	delete	#tmpAlloc_Feeder
	from	#tmpAlloc_Feeder a
	where	not exists (select	1 from	#tmpFilterDeals b where a.pei_deal_id_c = b.pei_deal_id_c);	
	-------------------------------
	delete	#tmpAlloc_Feeder
	from	#tmpAlloc_Feeder a
	where	not exists (select	1 from	#tmpFilterInvestors d where a.pei_invstr_id_c = d.pei_invstr_id_c);
	-------------------------------
	delete	#tmpAlloc_Feeder
	from	#tmpAlloc_Feeder a
	where	not exists (select	1 from	#tmpFilterVehicles e where a.pei_vhcl_id_c = e.pei_vhcl_id_c);
/* ============================================================================================================= */	
	if @LoadDetails = 'Y'
	begin
		with pvd_total(ProductID,VehicleID,DealID,TotalAmount,MltTotalAmount) as
		(
			select	a.ReportProductID,
					a.ReportVehicleID,
					a.ReportDealID,					
					cast(max(a.PVDTotalAdj) as float),					
					cast(max(a.MltPVDTotalAdj) as float)
			from 	#lcsfMasterData a
			group by a.ReportProductID,a.ReportVehicleID,a.ReportDealID
		),	
		pvd_total_run(ProductID,VehicleID,DealID,TotalAmount,MltTotalAmount,IsFeeder,HasFeeder,FeederFundID,FeederVhclID) as
		(
			select	a.pei_invst_fnd_id_c,
					a.pei_vhcl_id_c,
					a.pei_deal_id_c,					
					cast(sum(a.pei_alloc_amt_m) as float),
					cast(sum(a.pei_alloc_amt_mlt) as float),
					max(a.IsFeeder),
					max(a.HasFeeder),
					max(a.FeederFundID),
					max(a.FeederVhclID)						
			from 	#tmpAlloc_Feeder a
			group by a.pei_invst_fnd_id_c,a.pei_vhcl_id_c,a.pei_deal_id_c
		)
		insert into #tmpFeederDtl(
				pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,	
				CmtmtPct,
				CmtmtPctMlt,
				IsFeeder,
				HasFeeder,
				FeederFundID,
				FeederVhclID)
		select 	a.DealID,
				a.ProductID,
				a.VehicleID,
				case when b.TotalAmount		= 0 then 0 else (a.TotalAmount/b.TotalAmount)*100 end,
				case when b.MltTotalAmount	= 0 then 0 else (a.MltTotalAmount/b.MltTotalAmount)*100 end,
				IsFeeder				= a.IsFeeder,
				HasFeeder				= a.HasFeeder,
				FeederFundID			= a.FeederFundID,
				FeederVhclID			= a.FeederVhclID
		from	pvd_total_run a
				inner join 	pvd_total b				
					on a.ProductID	= b.ProductID
					and a.VehicleID	= b.VehicleID
					and a.DealID	= b.DealID;
		----------------------------------------------------------								
		exec dbo.sp_fc_LoadCommitments_SPV_Adapter_Feeders
			@Iteration			= 1,
			@RunType			= @RunType,
			@FeederShortNames	= @FeederShortNames;		
	end	
	-------------------------------------------------------------------
	IF exists(	select	1 
				from	tempdb.sys.indexes 
				where	object_id = object_id('tempdb..#tmpFeederDtl')
						and name = 'LCSPV_ALLC_FEEDER_DET_ADAPTER_PVD_UIDX')
	begin
		drop index LCSPV_ALLC_FEEDER_DET_ADAPTER_PVD_UIDX on #tmpFeederDtl;
	end							
	-------------------------------------------------------------------
	truncate table #lcsfMasterData;
	truncate table #lcsfAdapterFeeders;
	drop table #lcsfMasterData;
	drop table #lcsfAdapterFeeders;
end

GO
grant execute on dbo.sp_fc_LoadCommitments_SPV_Adapter to PE_datawriter, PE_datareader
GO