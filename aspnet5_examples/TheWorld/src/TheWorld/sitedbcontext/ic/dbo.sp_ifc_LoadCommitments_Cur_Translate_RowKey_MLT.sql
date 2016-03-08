create procedure [dbo].[sp_ifc_LoadCommitments_Cur_Translate_RowKey_MLT]
@InvolvmtIDList		varchar(max)	= '28',
@ProductIDList 		varchar(max)  	= null,
@DealIDList 		varchar(max)  	= null,
@InvestorIDList 	varchar(max)  	= null,
@VehicleIDList 		varchar(max)  	= null,
@ReportDate			datetime 		= null,
@CurrencyID 		char(3)			= 'USM',
@Status				varchar(max)    = null,
@MultCurrency		char(1)			= 'D', -- 'P' = Product , 'D' = Deal
@MultCurrencyManual	char(1)			= 'N',
@CutOffStatement	datetime		= null,
@GroupOutput		int				= 0,	-- use only 0, all others are not tested
@AddPosition		char(1)			= 'N'
as
	set nocount on
begin
/* ===============================================================================================================
create table #AllocationData
(
	pei_deal_id_c 				int,
	pei_invst_fnd_id_c 			int,
	pei_vhcl_id_c 				int,
	pei_invstr_id_c				int,
	pei_eff_trans_d				datetime,	
	pei_involvmt_typ_id_c		int,
	pei_trans_typ_id_c 			int,
	pei_trans_status_id_c		int,	
	pei_investran_trans_id_c	int,
	pei_investran_post_dz		datetime,	
	pei_pos_id_c				int,
	pei_batch_id_c				int,
	cur_id_c					char(3),
	pei_alloc_amt_m				decimal(30,2),
	pei_mlt_cur_id_c			char(3),
	pei_alloc_amt_mlt			decimal(30,2),
	pei_adj_typ_i				char(1)
)
=============================================================================================================== */
	if exists(	select	1
				from	tempdb.INFORMATION_SCHEMA.COLUMNS a
				where	a.TABLE_NAME			= object_name(object_id('tempdb..#AllocationData'),db_id('tempdb'))						
						and a.COLUMN_NAME		= 'pei_alloc_amt_m'
						and a.NUMERIC_PRECISION	<> 30)
	begin
		alter table #AllocationData
		alter column pei_alloc_amt_m decimal(30,2);
		alter table #AllocationData
		alter column pei_alloc_amt_mlt decimal(30,2);	
	end
/* =========================================================================================================== */
	if @MultCurrency = 'D' and @MultCurrencyManual = 'Y'
	begin
		declare @msg varchar(2000)
		set @msg = 'Unable to run procedure in Multiple mode for Deal Manual currency.' + char(13) + 'Manual currency conversion available only for Products (USM,EUM,GBM,CDM,CHM).'
		raiserror (@msg,15,1) with seterror
		return
	end
/* =============================================================================================================== */
	create table #lcctDeals		(DealID			int)
	create table #lcctProducts	(ProductID 		int)
	create table #lcctInvestors	(InvestorID		int)
	create table #lcctVehicles	(VehicleID		int)
	create table #lcctInvolvmt	(InvolvementID  int)
	-----------------------------------------------------------------
	create table #lcctStatus
	(
		StatusID	int,
		row_type	bit
	)
	create unique index LCCT_TRANS_STATUS_ID on #lcctStatus(StatusID,row_type)
	-----------------------------------------------------------------
	create table #lcctRowKeys
	(
		RowKey			int,
		MltCurrencyID	char(3)
	)
	create unique clustered index LCCT_ROW_KEYS_ID on #lcctRowKeys(RowKey)
	-----------------------------------------------------------------
	create table #lcctCutoffPostedDate
	(
		ProductID			int,
		InvestranPostDate	datetime
	)	
	create unique index LCCT_CPD_PRODUCTID	on #lcctCutoffPostedDate(ProductID);
	create index LCCT_CPD_EFFD				on #lcctCutoffPostedDate(InvestranPostDate);
	-----------------------------------------------------------------
	create table #dtsProductPostedDate
	(
		ProductID			int,			
		InvestranProductID	int,
		EffectiveDate		datetime,
		InvestranPostDate	datetime
	)
	-----------------------------------------------------------------
	create table #lcctData
	(
		pei_deal_id_c 				int,
		pei_invst_fnd_id_c 			int,
		pei_vhcl_id_c 				int,
		pei_invstr_id_c				int,
		pei_trans_typ_id_c 			int,
		pei_eff_trans_d				datetime,
		pei_trans_status_id_c		int,		
		pei_batch_id_c				int,
		pei_pos_id_c				int,
		pei_investran_trans_id_c	int,
		pei_investran_post_dz		datetime,		
		pei_alloc_amt_m				decimal(30,2),
		pei_alloc_amt_mlt			decimal(30,2),
		pei_adj_typ_i				char(1),
		pei_mlt_cur_id_c			char(3)	
	)
/* =============================================================================================================== */
	declare @PDComm					char(1)
	declare @IPComm					char(1)	
	declare @Involvement 			char(1)
	declare	@ManualCurrency			char(1)
	declare @ExcludeType			char(1)
	declare @MultCurrencyManualFlag	char(1)
	-----------------------------------------------------------------
	set @PDComm	= 'N'
	set @IPComm = 'N'
	-----------------------------------------------------------------
	if @CurrencyID 			is null set @CurrencyID			= 'USD'
	if @ReportDate			is null	set @ReportDate 		= getdate()	
	if @InvolvmtIDList		is null set @InvolvmtIDList 	= '28'
	if @Status				is null	set @Status				= '1;3;4'	
	if @MultCurrency		is null set @MultCurrency		= 'D'
	if @AddPosition			is null	set @AddPosition		= 'N'
	if @GroupOutput			is null set @GroupOutput		= 0
	-----------------------------------------------------------------	
	set @ManualCurrency =	dbo.IsManualCurrency(@CurrencyID);
	-----------------------------------------------------------------
	set @MultCurrencyManualFlag =
							case									
								when @MultCurrencyManual = 'Y' and @MultCurrency = 'P' then 'Y'
								else ''								
							end
	-----------------------------------------------------------------
	set @ExcludeType	=	case
									when @ManualCurrency = 'Y'			then 'A'
									when @MultCurrencyManualFlag = 'Y'	then ''									
									when @ManualCurrency = 'N'			then 'M'
							end
/* =============================================================================================================== */
	if @CutOffStatement is not null
	begin
		exec dbo.sp_ifcxGetDTS_CutOffDates @ProductIDList,@CutOffStatement,'N'
		insert into #lcctCutoffPostedDate(ProductID, InvestranPostDate)
		select	ProductID,InvestranPostDate from #dtsProductPostedDate	
		truncate table #dtsProductPostedDate
	end	
/* =============================================================================================================== */
	insert into #lcctInvolvmt
	select distinct ID from dbo.Split(@InvolvmtIDList,';')
	-----------------------------------------------------------------
	if (select count(*) from #lcctInvolvmt) > 1
		set @Involvement = 'Y'
	else
		set @Involvement = 'N'
	-----------------------------------------------------------------
	if exists(select 1 from #lcctInvolvmt where InvolvementID = 28) set @PDComm = 'Y'
	if exists(select 1 from #lcctInvolvmt where InvolvementID = 27) set @IPComm = 'Y'
	-----------------------------------------------------------------
	if @PDComm = 'N' and @IPComm = 'N' return
/* =========================================================================================================================== */
	if @IPComm = 'Y'
	begin
		insert into #lcctStatus select 1,0
		insert into #lcctStatus select 3,0
		insert into #lcctStatus select 4,0
		
		if @ManualCurrency = 'N' insert into #lcctStatus select -1 , 0	
	end
	-----------------------------------------------------------------
	if @PDComm = 'Y'
	begin
		if @Status is not null
			begin
				insert into #lcctStatus
				select distinct ID, 1 from dbo.Split(@Status,';')
			end
		else
			begin
				insert into #lcctStatus
				select 	pei_trans_status_id_c,1
				from 	pei_trans_status_ref
				where	pei_investran_trans_status_id_c in (0,2,3)--Posted,Held,Exported
			end
		----------------------------------------------------------------
		if @ManualCurrency = 'N' and @Status <> '1' insert into #lcctStatus select -1 , 1	
	end
/* =========================================================================================================================== */
	if @ProductIDList is not null
		begin	
			insert into #lcctProducts
			select distinct ID from dbo.Split(@ProductIDList,';')
		end
	else
		begin
			insert into #lcctProducts select pei_invst_fnd_id_c from pei_invst_fnd_ref
		end
/* =========================================================================================================================== */
	if @PDComm = 'Y'
	begin
		if @DealIDList is not null
			begin
				insert into #lcctDeals
				select distinct ID from dbo.Split(@DealIDList,';') 
			end
		else
			begin
				insert into #lcctDeals select pei_deal_id_c from pei_deal_ref
			end
	end
	-----------------------------------------------------------------
	if @IPComm = 'Y' insert into #lcctDeals select -1
/* =========================================================================================================================== */
	if @InvestorIDList is not null
		begin
			insert into #lcctInvestors
			select distinct ID from dbo.Split(@InvestorIDList,';')  
		end
	else
		begin
			insert into #lcctInvestors select pei_invstr_id_c from pei_invstr_ref
		end
/* =========================================================================================================================== */
	if @VehicleIDList is not null
		begin
			insert into #lcctVehicles
			select distinct ID from dbo.Split(@VehicleIDList,';') 
		end
	else
		begin
			insert into #lcctVehicles select pei_vhcl_id_c from pei_vhcl_ref
		end
/* =========================================================================================================================== */
	if @DealIDList is not null or @ProductIDList is not null or @InvestorIDList is not null or @VehicleIDList is not null
		begin
			insert into #lcctRowKeys
			select	a.pei_adj_id_c,
					case @MultCurrency
						when 'P' then a.pei_le_cur_id_c
						when 'D' then isnull(a.pei_loc_cur_id_c,a.pei_le_cur_id_c)
					end	
			from	pei_adj_pvidat_xref a
					inner join #lcctProducts b
						on a.pei_invst_fnd_id_c = b.ProductID	
					inner join #lcctInvestors c
						on a.pei_invstr_id_c = c.InvestorID
					inner join #lcctVehicles d
						on a.pei_vhcl_id_c = d.VehicleID
					inner join #lcctDeals e
						on a.pei_deal_id_c = e.DealID			
					inner join #lcctStatus f
						on a.pei_trans_status_id_c = f.StatusID 
			where	a.pei_row_type = f.row_type and a.pei_adj_typ_i <> @ExcludeType
		end
	else
		begin
			if @PDComm = 'Y' and @IPComm = 'N'
			begin
				insert into #lcctRowKeys
				select	a.pei_adj_id_c,
						case @MultCurrency
							when 'P' then a.pei_le_cur_id_c
							when 'D' then a.pei_loc_cur_id_c
						end	
				from	pei_adj_pvidat_xref a			
						inner join #lcctStatus f
							on a.pei_trans_status_id_c = f.StatusID
				where	a.pei_row_type = 1 and a.pei_adj_typ_i <> @ExcludeType 
			end

			if @PDComm = 'N' and @IPComm = 'Y'
			begin
				insert into #lcctRowKeys
				select	a.pei_adj_id_c,
						case @MultCurrency
							when 'P' then a.pei_le_cur_id_c
							when 'D' then a.pei_loc_cur_id_c
						end	
				from	pei_adj_pvidat_xref a									
				where	a.pei_row_type = 0 and a.pei_adj_typ_i <> @ExcludeType
			end
		end	
/* ================================================================================================================== */	
	insert into #lcctData(	
			pei_deal_id_c,
			pei_invst_fnd_id_c,
			pei_vhcl_id_c,
			pei_invstr_id_c,
			pei_trans_typ_id_c,
			pei_eff_trans_d,
			pei_trans_status_id_c,				
			pei_batch_id_c,
			pei_pos_id_c,
			pei_investran_trans_id_c,
			pei_investran_post_dz,
			pei_alloc_amt_m,
			pei_alloc_amt_mlt,
			pei_adj_typ_i,
			pei_mlt_cur_id_c)
	select	a.pei_deal_id_c,
			a.pei_invst_fnd_id_c,
			a.pei_vhcl_id_c,
			a.pei_invstr_id_c,
			a.pei_trans_typ_id_c,
			a.pei_eff_trans_d,				
			a.pei_trans_status_id_c,		
			a.pei_batch_id_c,
			null,
			a.pei_investran_trans_id_c,					
			a.pei_investran_post_dz,
			case @CurrencyID
				when 'USD' then a.pei_amt_m_USD
				when 'EUR' then a.pei_amt_m_EUR
				when 'AUD' then a.pei_amt_m_AUD
				when 'GBP' then a.pei_amt_m_GBP
				when 'CAD' then a.pei_amt_m_CAD
				when 'ZAR' then a.pei_amt_m_ZAR
				when 'SEK' then a.pei_amt_m_SEK
				when 'CHF' then a.pei_amt_m_CHF
				when 'NOK' then a.pei_amt_m_NOK
				when 'JPY' then a.pei_amt_m_JPY
				when 'INR' then a.pei_amt_m_INR
				when 'PLN' then a.pei_amt_m_PLN
				when 'BRL' then a.pei_amt_m_BRL
				when 'KWD' then a.pei_amt_m_KWD
				when 'SGD' then a.pei_amt_m_SGD
				when 'SAR' then a.pei_amt_m_SAR
				when 'DKK' then a.pei_amt_m_DKK
				when 'KRW' then a.pei_amt_m_KRW
				when 'IDR' then a.pei_amt_m_IDR
				when 'YER' then a.pei_amt_m_YER
				when 'USM' then a.pei_amt_m_USD_man
				when 'EUM' then a.pei_amt_m_EUR_man
				when 'GBM' then a.pei_amt_m_GBP_man
				when 'CDM' then a.pei_amt_m_CAD_man
				when 'CHM' then a.pei_amt_m_CHF_man
				when 'KRM' then a.pei_amt_m_KRW_man
			end,
			case b.MltCurrencyID + @MultCurrencyManualFlag
				when null	then null		
				when 'USD'	then a.pei_amt_m_USD
				when 'EUR'	then a.pei_amt_m_EUR
				when 'AUD'	then a.pei_amt_m_AUD
				when 'GBP'	then a.pei_amt_m_GBP
				when 'CAD'	then a.pei_amt_m_CAD
				when 'ZAR'	then a.pei_amt_m_ZAR
				when 'SEK'	then a.pei_amt_m_SEK
				when 'CHF'	then a.pei_amt_m_CHF
				when 'NOK'	then a.pei_amt_m_NOK
				when 'JPY'  then a.pei_amt_m_JPY
				when 'INR'  then a.pei_amt_m_INR
				when 'PLN'	then a.pei_amt_m_PLN
				when 'BRL'	then a.pei_amt_m_BRL
				when 'KWD'	then a.pei_amt_m_KWD
				when 'SGD'	then a.pei_amt_m_SGD
				when 'SAR'	then a.pei_amt_m_SAR
				when 'DKK'	then a.pei_amt_m_DKK
				when 'KRW'	then a.pei_amt_m_KRW
				when 'IDR'	then a.pei_amt_m_IDR
				when 'YER'	then a.pei_amt_m_YER				
				when 'USDY'	then a.pei_amt_m_USD_man
				when 'EURY'	then a.pei_amt_m_EUR_man
				when 'GBPY' then a.pei_amt_m_GBP_man
				when 'CADY' then a.pei_amt_m_CAD_man	
				when 'CHFY' then a.pei_amt_m_CHF_man
				when 'KRWY' then a.pei_amt_m_KRW_man
			end,		
			a.pei_adj_typ_i,
			b.MltCurrencyID
	from	pei_adj_comm_data a
			inner join #lcctRowKeys b
				on a.row_key = b.RowKey		
	where	a.pei_eff_trans_d <= @ReportDate
/* ================================================================================================ */
	if @CutOffStatement is not null and @PDComm = 'Y'
	begin
		delete	#lcctData
		from	#lcctData a
				inner join #lcctCutoffPostedDate b
					on a.pei_invst_fnd_id_c = b.ProductID				
		where	a.pei_deal_id_c is not null
				and a.pei_investran_post_dz is not null 
				and a.pei_investran_post_dz > b.InvestranPostDate
				and not exists(
					select 	1
					from 	ifc_rpt_trans_xref c
					where 	c.pei_invst_fnd_id_c	= a.pei_invst_fnd_id_c
							and c.ifc_qt_signoff_dz	= @CutOffStatement
							and c.pei_batch_id_c	= a.pei_batch_id_c)
	end
/* ================================================================================================ */
	if @AddPosition = 'Y'
	begin
		update	#lcctData
		set		pei_pos_id_c = b.pei_pos_id_c
		from	#lcctData a
				inner join pei_allc_data b
					on	a.pei_deal_id_c					= b.pei_deal_id_c
						and a.pei_invst_fnd_id_c		= b.pei_invst_fnd_id_c
						and a.pei_vhcl_id_c				= b.pei_vhcl_id_c								
						and a.pei_invstr_id_c			= b.pei_invstr_id_c									
						and a.pei_eff_trans_d			= b.pei_eff_trans_d
						and a.pei_trans_typ_id_c		= b.pei_trans_typ_id_c
						and a.pei_investran_trans_id_c	= b.pei_investran_trans_id_c						
		where	a.pei_investran_trans_id_c is not null
	end
/* ================================================================================================ */
	if @GroupOutput = 0
	begin
		insert into #AllocationData(
				pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,	
				pei_involvmt_typ_id_c,
				pei_trans_typ_id_c,
				pei_trans_status_id_c,	
				pei_investran_trans_id_c,
				pei_investran_post_dz,
				pei_pos_id_c,
				pei_batch_id_c,
				cur_id_c,
				pei_alloc_amt_m,
				pei_mlt_cur_id_c,
				pei_alloc_amt_mlt,
				pei_adj_typ_i)
		select	pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,
				case 
					when pei_deal_id_c is not null then 28
					else 27
				end,
				pei_trans_typ_id_c,			
				pei_trans_status_id_c,
				pei_investran_trans_id_c,
				pei_investran_post_dz,
				pei_pos_id_c,
				pei_batch_id_c,
				@CurrencyID,
				pei_alloc_amt_m,			
				pei_mlt_cur_id_c,
				pei_alloc_amt_mlt,
				pei_adj_typ_i
		from	#lcctData		
		where	pei_adj_typ_i in ('C','M') or (pei_adj_typ_i = 'A' and pei_alloc_amt_m <> 0)
	end
/* ================================================================================================ */
	if @GroupOutput = 1
	begin
		insert into #AllocationData(
				pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,	
				pei_involvmt_typ_id_c,
				cur_id_c,
				pei_alloc_amt_m,
				pei_mlt_cur_id_c,
				pei_alloc_amt_mlt)
		select	pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,
				case 
					when pei_deal_id_c is not null then 28
					else 27
				end,				
				@CurrencyID,
				sum(pei_alloc_amt_m),			
				min(pei_mlt_cur_id_c),
				sum(pei_alloc_amt_mlt)			
		from	#lcctData
		group by pei_deal_id_c,pei_invst_fnd_id_c,pei_vhcl_id_c,pei_invstr_id_c,pei_eff_trans_d		
	end
/* ================================================================================================ */
	if @GroupOutput = 2
	begin
		insert into #AllocationData(
				pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,	
				cur_id_c,
				pei_alloc_amt_m,
				pei_mlt_cur_id_c,
				pei_alloc_amt_mlt)
		select	pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,			
				@CurrencyID,
				sum(pei_alloc_amt_m),			
				min(pei_mlt_cur_id_c),
				sum(pei_alloc_amt_mlt)			
		from	#lcctData
		group by pei_deal_id_c,pei_invst_fnd_id_c,pei_vhcl_id_c,pei_invstr_id_c,pei_eff_trans_d		
	end
/* ================================================================================================ */
	if @GroupOutput = 3
	begin
		insert into #AllocationData(
				pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				pei_eff_trans_d,	
				cur_id_c,
				pei_alloc_amt_m,
				pei_mlt_cur_id_c,
				pei_alloc_amt_mlt)
		select	pei_deal_id_c,
				pei_invst_fnd_id_c,
				pei_vhcl_id_c,
				pei_invstr_id_c,
				min(pei_eff_trans_d),				
				@CurrencyID,
				sum(pei_alloc_amt_m),			
				min(pei_mlt_cur_id_c),
				sum(pei_alloc_amt_mlt)			
		from	#lcctData		
		group by pei_deal_id_c,pei_invst_fnd_id_c,pei_vhcl_id_c,pei_invstr_id_c				
	end
/* ================================================================================================ */	
	truncate table #lcctRowKeys;
	truncate table #lcctData;	
	truncate table #lcctDeals;
	truncate table #lcctProducts;
	truncate table #lcctInvestors;
	truncate table #lcctVehicles;
/* ================================================================================================ */
	drop table #lcctRowKeys;
	drop table #lcctData;
	drop table #lcctDeals;
	drop table #lcctProducts;
	drop table #lcctInvestors;
	drop table #lcctVehicles;
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_Cur_Translate_RowKey_MLT to PE_datawriter, PE_datareader
GO