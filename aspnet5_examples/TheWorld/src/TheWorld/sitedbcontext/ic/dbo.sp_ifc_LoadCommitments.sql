create procedure [dbo].[sp_ifc_LoadCommitments]
@ProductID 			varchar(max)  	= null,
@DealID 			varchar(max)  	= null,
@InvestorID 		varchar(max)  	= null,
@VehicleID 			varchar(max)  	= null,
@Status				varchar(max)  	= null,
@ReportDate			datetime		= null,
@CutOffStatement	datetime		= null,
@CurrencyID 		char(3)			= 'USM',
@MultCurrency		char(1)			= 'D', -- 'P' = Product , 'D' = Deal
@MultCurrencyManual	char(1)			= 'Y',
@PurchaseDiscount	char(1)			= 'N',
@FilterZeros		char(1)			= 'N',
@ProcessType		int				= 0, -- 0 -Direct / 1 - SPV / 2 - FOF
@CalculateAmounts	char(1)			= 'N',
@MaxLevel			int				= 32
as
	set nocount on
begin	
/*
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
		MltCmtmtAmount				decimal(30,2),
		MultCurrency				char(1),
		MultCurrencyManual			char(1),		
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
	*/
/* ================================================================================ */	
	create table #lcsfCmtmKeys
	(
		Iteration		int,
		RowKey			int,
		RowType			char(1),
		ProductID		int,
		DealID			int,
		LECurrencyID	char(3),
		LocalCurrencyID char(3)
	);
	create unique clustered index LCSF_CMTMT_ROW_KEY_UCIDX on #lcsfCmtmKeys(RowKey);
	create index LCSF_CMTMT_PID_IDX on #lcsfCmtmKeys(ProductID);
	create index LCSF_CMTMT_ROWTYPE_IDX on #lcsfCmtmKeys(RowType);
	-------------------------------------------------------------------	
	create table #lcsfAdjType	(AdjTypeID char(1));
	create table #lcsfStatus	(StatusID int, AdjTypeID char(1));		
	create unique clustered index LCSF_TRANS_SATUS_ADJ_TYPE_UCIDX on #lcsfStatus(StatusID,AdjTypeID);
	-------------------------------------------------------------------
	create table #dtsProductPostedDate
	(
		ProductID			int,			
		InvestranProductID	int,
		EffectiveDate		datetime,
		InvestranPostDate	datetime
	);	
	create unique clustered index LCSF_DTSPPD_PIDEFFD_UCIDX on #dtsProductPostedDate(ProductID,EffectiveDate);
	-------------------------------------------------------------------		
	create table #lcsfMasterLoad
	(
		ProductID					int,
		VehicleID					int,
		InvestorID					int,
		DealID						int,
		EffectiveDate				datetime,
		TransTypeID					int,
		TransStatusID				int,
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
		LECurrencyID				char(3),
		LEAmount					decimal(30,2),
		LocCurrencyID				char(3),
		LocAmount					decimal(30,2)
	)
	create clustered index LCSF_MASTER_LOAD_PVID_CIDX on #lcsfMasterLoad(ProductID,VehicleID,InvestorID,DealID);
	----------------------------------------------------------------
	create table #lcsfPDTotal
	(
		ProductID					int,		
		DealID						int,
		RunTotal					decimal(30,2),
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
		pei_amt_m_KRW_man			decimal(30,2)
	)
	create unique clustered index LCSF_PDTOTAL_PDID_UCIDX on #lcsfPDTotal(ProductID,DealID);	
	----------------------------------------------------------------
	create table #lcsfPDTotalAdj
	(
		ProductID					int,			
		DealID						int,
		RunTotal					decimal(30,2),
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
		pei_amt_m_KRW_man			decimal(30,2)
	)
	create unique clustered index LCSF_PDTOTALADJ_PDID_UCIDX on #lcsfPDTotalAdj(ProductID,DealID);	
/* ================================================================================ */
	set @ReportDate			= isnull(@ReportDate,getdate());
	set @FilterZeros		= isnull(@FilterZeros,'N');
	set @Status				= isnull(@Status,'3;4');
	set @ProcessType		= isnull(@ProcessType,0);	
	set @MaxLevel			= isnull(@MaxLevel,32);	
	set @MultCurrencyManual = case @MultCurrency when 'P' then @MultCurrencyManual else 'N' end;
/* ================================================================================ */	
	declare @Keys			tvp_allc_key;
	declare @KeysStart		tvp_allc_key;
	declare @RunType		int; -- 1 Product / 2 - Deal
	--------------------------------------------------	
	set @RunType =	case
						when	isnull(@ProductID,'')		<> '' 
								or isnull(@InvestorID,'')	<> ''
								or isnull(@VehicleID,'')	<> ''
								or isnull(@DealID,'')	= '' then 1						
						else 2		
					end;
/* ================================================================================ */
	declare	@ManualCurrency			char(1);
	declare @ExcludeType			char(1);
	declare @MultCurrencyManualFlag	char(1);	
	--------------------------------------------------		
	set	@MultCurrency		= isnull(@MultCurrency,'P');
	set @ManualCurrency		= dbo.IsManualCurrency(@CurrencyID);		
	-----------------------------------------------------------------
	set @MultCurrencyManualFlag =
							case									
								when @MultCurrencyManual = 'Y' and @MultCurrency = 'P' then 'Y'
								else ''								
							end;
	-----------------------------------------------------------------
	set @ExcludeType	=	case
									when @ManualCurrency = 'Y'			then 'A'									
									when @MultCurrencyManualFlag = 'Y'  then ''																	
									when @ManualCurrency = 'N'			then 'M'
							end;
	-----------------------------------------------------------------	
	insert into #lcsfAdjType select 'C';
	-----------------------------------------------------------------
	if @ExcludeType <> 'M' insert into #lcsfAdjType select 'M';
	-----------------------------------------------------------------
	if @ExcludeType <> 'A' and @Status <> '1' insert into #lcsfStatus select -1, 'A';
	-----------------------------------------------------------------
	insert into #lcsfStatus(StatusID,AdjTypeID)
	select	distinct
			ID,AdjTypeID
	from	dbo.Split(@Status,';'),
			#lcsfAdjType;	
/* ================================================================================ */			
	if @CutOffStatement is not null	
		exec dbo.sp_ifcxGetDTS_CutOffDates null,@CutOffStatement,'N';
/* ================================================================================ */
	if @RunType = 1
	begin
		with run_prod(ProductID) as
		(
			select	distinct
					id
			from	dbo.Split(@ProductID,';')
			where	@ProductID is not null
			union		
			select	a.pei_invst_fnd_id_c
			from	pei_invst_fnd_vhcl_ref a
					inner join dbo.Split(@VehicleID,';') b
						on a.pei_vhcl_id_c = b.id
			where	@ProductID is null
					and @VehicleID is not null 	
			union 
			select	a.pei_invst_fnd_id_c
			from	pei_invst_fnd_invstr a
					inner join dbo.Split(@InvestorID,';') b
						on a.pei_invstr_id_c = b.id
			where	@ProductID is null
					and @InvestorID is not null
			union
			select	pei_invst_fnd_id_c
			from	pei_invst_fnd_ref
			where	@ProductID		is null 
					and @InvestorID is null
					and @VehicleID	is null 	
					and @DealID		is null
		)
		insert into @Keys(ProductID)
		select	ProductID
		from	run_prod;
	end
	-------------------------------------------------------------
	if @RunType = 2
	begin
		with run_prod_deal(ProductID,DealID) as
		(
			select	distinct
					a.pei_invst_fnd_id_c,
					a.pei_deal_id_c
			from	pei_invst_fnd_deal_xref a
					inner join dbo.Split(@DealID,';') b
						on a.pei_deal_id_c = b.id
			where	@DealID is not null		
			union
			select	distinct
					a.pei_invst_fnd_id_c,
					a.pei_deal_id_c
			from	pei_invst_fnd_deal_xref a
			where	@DealID is null
		)
		insert into @Keys(ProductID,DealID)
		select	ProductID,
				DealID
		from	run_prod_deal;
	end
/* ================================================================================ */
	exec dbo.sp_ifc_LoadCommitments_LoadKeys
	@ProcessType	= @ProcessType,
	@RunType		= @RunType,
	@Iteration		= 1,
	@Keys			= @Keys,
	@MaxLevel		= @MaxLevel;	
/* ================================================================================ */
	exec dbo.sp_ifc_LoadCommitments_LoadData
	@ReportDate			= @ReportDate,
	@CutOffStatement	= @CutOffStatement,
	@CurrencyID 		= @CurrencyID,
	@MultCurrency		= @MultCurrency,
	@MultCurrencyManual	= @MultCurrencyManualFlag,
	@CalculateAmounts	= @CalculateAmounts,
	@PurchaseDiscount	= @PurchaseDiscount,
	@FilterZeros		= @FilterZeros;
/* ================================================================================*/ 
	;with lc_prod(ProductID) as
	(
		select	distinct
				id
		from	dbo.Split(@ProductID,';')
		where	@ProductID is not null
		union		
		select	pei_invst_fnd_id_c
		from	pei_invst_fnd_ref
		where	@ProductID is null
	),
	lc_vhcl(VehicleID) as
	(
		select	distinct
				id
		from	dbo.Split(@VehicleID,';')
		where	@VehicleID is not null
		union
		select	pei_vhcl_id_c
		from	pei_vhcl_ref
		where	@VehicleID is null	
	),
	lc_instr(InvestorID) as
	(
		select	distinct
				id
		from	dbo.Split(@InvestorID,';')
		where	@InvestorID is not null
		union
		select	pei_invstr_id_c
		from	pei_invstr_ref
		where	@InvestorID is null	
	),
	lc_deal(DealID) as
	(
		select	distinct
				id
		from	dbo.Split(@DealID,';')
		where	@RunType = 2
				and @DealID is not null
		union
		select	pei_deal_id_c
		from	pei_deal_ref
		where	@RunType = 1
				or
				(@RunType = 2 and @DealID is null)
	)
	insert into @KeysStart(ProductID,VehicleID,InvestorID,DealID)
	select	distinct
			a.ProductID,
			a.VehicleID,
			a.InvestorID,
			a.DealID
	from	#lcsfMasterLoad a
			inner join lc_prod b
				on a.ProductID = b.ProductID
			inner join lc_vhcl c
				on a.VehicleID = c.VehicleID
			inner join lc_instr d
				on a.InvestorID = d.InvestorID
			inner join lc_deal e
				on a.DealID = e.DealID;	
/* ================================================================================ */
	if @RunType = 1
		begin
			exec dbo.sp_ifc_LoadCommitments_Product
			@Iteration			= 1,
			@ProcessType		= @ProcessType,
			@CalculateAmounts	= @CalculateAmounts,
			@Keys				= @KeysStart,
			@MaxLevel			= @MaxLevel;
		end	
	else
		begin
			exec dbo.sp_ifc_LoadCommitments_Deal			
			@Iteration			= 1,
			@ProcessType		= @ProcessType,
			@CalculateAmounts	= @CalculateAmounts,
			@Keys				= @KeysStart,			
			@MaxLevel			= @MaxLevel;
		end	
/* ================================================================================ */
	if @InvestorID is not null
	begin
		delete	#lcsfMasterData 
		from	#lcsfMasterData a	
		where	not exists(	select	1
							from	dbo.Split(@InvestorID,';') b
							where	a.ReportInvestorID = b.id);
	end;
	----------------------------------------
	if @VehicleID is not null
	begin
		delete	#lcsfMasterData 
		from	#lcsfMasterData a	
		where	not exists(	select	1
							from	dbo.Split(@VehicleID,';') b
							where	a.ReportVehicleID = b.id);
	end;
	----------------------------------------
	if @ProductID is null and @VehicleID is null and @InvestorID is null and @DealID is not null
	begin
		delete	#lcsfMasterData 
		from	#lcsfMasterData a	
		where	not exists(	select	1
							from	dbo.Split(@DealID,';') b
							where	a.ReportDealID = b.id);
	end;
/* ================================================================================ */	
	truncate table #lcsfMasterLoad;
	truncate table #dtsProductPostedDate;
	truncate table #lcsfCmtmKeys;
	truncate table #lcsfPDTotal;
	truncate table #lcsfPDTotalAdj;
	drop table #lcsfMasterLoad;
	drop table #dtsProductPostedDate;
	drop table #lcsfCmtmKeys;
	drop table #lcsfPDTotal;
	drop table #lcsfPDTotalAdj;
end
GO
grant execute on dbo.sp_ifc_LoadCommitments to PE_datawriter, PE_datareader
GO
