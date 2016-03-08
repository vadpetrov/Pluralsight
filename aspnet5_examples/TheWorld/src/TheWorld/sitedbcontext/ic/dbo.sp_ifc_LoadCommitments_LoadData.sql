create procedure [dbo].[sp_ifc_LoadCommitments_LoadData]
@ReportDate			datetime,
@CutOffStatement	datetime = null,
@CurrencyID 		char(3),
@MultCurrency		char(1),
@MultCurrencyManual	char(1),
@CalculateAmounts	char(1) = 'N',
@PurchaseDiscount	char(1) = 'N',
@FilterZeros		char(1) = 'N'
as
	set nocount on;
begin
	/*	
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
	*/
/* ================================================================================*/	
	if isnull(@CalculateAmounts,'N') = 'N'
	begin
		if @CutOffStatement is null
		begin
			insert into #lcsfMasterLoad(
					ProductID,
					VehicleID,
					InvestorID,
					DealID,
					EffectiveDate)			
			select	a.pei_invst_fnd_id_c,
					a.pei_vhcl_id_c,			
					a.pei_invstr_id_c,
					a.pei_deal_id_c,
					min(a.pei_eff_trans_d)
			from	pei_adj_comm_data a
					inner join #lcsfCmtmKeys b
						on a.row_key = b.RowKey
			where	b.RowType in ('C')
					and a.pei_eff_trans_d <= @ReportDate
			group by a.pei_invst_fnd_id_c,a.pei_vhcl_id_c,a.pei_invstr_id_c,a.pei_deal_id_c;
		end
		-----------------------------------------------------------------------------
		-----------------------------------------------------------------------------
		-----------------------------------------------------------------------------
		if @CutOffStatement is not null
		begin	
			insert into #lcsfMasterLoad(
					ProductID,
					VehicleID,
					InvestorID,
					DealID,
					EffectiveDate)
			select	a.pei_invst_fnd_id_c,
					a.pei_vhcl_id_c,			
					a.pei_invstr_id_c,
					a.pei_deal_id_c,
					min(a.pei_eff_trans_d)
			from	pei_adj_comm_data a
					inner join #lcsfCmtmKeys b
						on a.row_key = b.RowKey
					inner join #dtsProductPostedDate c
							on a.pei_invst_fnd_id_c = c.ProductID						
			where	b.RowType in ('C')
					and a.pei_eff_trans_d <= @ReportDate
					and (c.InvestranPostDate is null
						or a.pei_investran_post_dz <= c.InvestranPostDate
						or exists(	select 	1
									from 	ifc_rpt_trans_xref e
									where 	e.pei_invst_fnd_id_c	= a.pei_invst_fnd_id_c
											and e.pei_batch_id_c	= a.pei_batch_id_c
											and e.ifc_qt_signoff_dz	= @CutOffStatement))
			group by a.pei_invst_fnd_id_c,a.pei_vhcl_id_c,a.pei_invstr_id_c,a.pei_deal_id_c;
		end		
		return;
	end	
/* ================================================================================*/
	if @CutOffStatement is null
	begin
		insert into #lcsfMasterLoad(
				ProductID,
				VehicleID,
				InvestorID,
				DealID,
				EffectiveDate,
				TransTypeID,
				TransStatusID,
				CurrencyID,
				CmtmtAmount,
				MltCurrencyID,
				MultCurrency,
				MultCurrencyManual,
				MltCmtmtAmount,
				pei_amt_m_USD,
				pei_amt_m_EUR,
				pei_amt_m_AUD,
				pei_amt_m_GBP,
				pei_amt_m_CAD,
				pei_amt_m_ZAR,
				pei_amt_m_SEK,
				pei_amt_m_CHF,
				pei_amt_m_NOK,
				pei_amt_m_JPY,
				pei_amt_m_INR,
				pei_amt_m_PLN,
				pei_amt_m_BRL,
				pei_amt_m_KWD,
				pei_amt_m_SGD,
				pei_amt_m_SAR,
				pei_amt_m_DKK,
				pei_amt_m_KRW,
				pei_amt_m_IDR,
				pei_amt_m_YER,		
				pei_amt_m_USD_man,
				pei_amt_m_EUR_man,
				pei_amt_m_GBP_man,
				pei_amt_m_CAD_man,	
				pei_amt_m_CHF_man,
				pei_amt_m_KRW_man,
				RowType,
				BatchID,
				PostDate,
				TransactionID,
				LECurrencyID,
				LocCurrencyID)			
		select	a.pei_invst_fnd_id_c,
				a.pei_vhcl_id_c,			
				a.pei_invstr_id_c,
				a.pei_deal_id_c,
				a.pei_eff_trans_d,
				a.pei_trans_typ_id_c,
				a.pei_trans_status_id_c,
				@CurrencyID,
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
				case @MultCurrency
					when 'P' then b.LECurrencyID
					when 'D' then b.LocalCurrencyID
				end,
				@MultCurrency,
				@MultCurrencyManual,
				case (case @MultCurrency when 'P' then b.LECurrencyID when 'D' then b.LocalCurrencyID end) +  @MultCurrencyManual
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
					when 'PLN'  then a.pei_amt_m_PLN
					when 'BRL'  then a.pei_amt_m_BRL
					when 'KWD'  then a.pei_amt_m_KWD
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
				a.pei_amt_m_USD,
				a.pei_amt_m_EUR,
				a.pei_amt_m_AUD,
				a.pei_amt_m_GBP,
				a.pei_amt_m_CAD,
				a.pei_amt_m_ZAR,
				a.pei_amt_m_SEK,
				a.pei_amt_m_CHF,
				a.pei_amt_m_NOK,
				a.pei_amt_m_JPY,
				a.pei_amt_m_INR,
				a.pei_amt_m_PLN,
				a.pei_amt_m_BRL,
				a.pei_amt_m_KWD,
				a.pei_amt_m_SGD,
				a.pei_amt_m_SAR,
				a.pei_amt_m_DKK,
				a.pei_amt_m_KRW,
				a.pei_amt_m_IDR,
				a.pei_amt_m_YER,		
				a.pei_amt_m_USD_man,
				a.pei_amt_m_EUR_man,
				a.pei_amt_m_GBP_man,
				a.pei_amt_m_CAD_man,	
				a.pei_amt_m_CHF_man,
				a.pei_amt_m_KRW_man,
				a.pei_adj_typ_i,
				a.pei_batch_id_c,
				a.pei_investran_post_dz,
				a.pei_investran_trans_id_c,
				b.LECurrencyID,
				b.LocalCurrencyID
		from	pei_adj_comm_data a
				inner join #lcsfCmtmKeys b
					on a.row_key = b.RowKey
		where	b.RowType in ('C','M')
				and a.pei_eff_trans_d <= @ReportDate;
		---------------------------------------------------------------
		if exists(select 1 from #lcsfCmtmKeys where RowType = 'A')
		begin
			insert into #lcsfMasterLoad(
					ProductID,
					VehicleID,
					InvestorID,
					DealID,
					EffectiveDate,
					TransTypeID,
					TransStatusID,
					CurrencyID,
					CmtmtAmount,
					MltCurrencyID,
					MultCurrency,
					MultCurrencyManual,
					MltCmtmtAmount,
					pei_amt_m_USD,
					pei_amt_m_EUR,
					pei_amt_m_AUD,
					pei_amt_m_GBP,
					pei_amt_m_CAD,
					pei_amt_m_ZAR,
					pei_amt_m_SEK,
					pei_amt_m_CHF,
					pei_amt_m_NOK,
					pei_amt_m_JPY,
					pei_amt_m_INR,
					pei_amt_m_PLN,
					pei_amt_m_BRL,
					pei_amt_m_KWD,
					pei_amt_m_SGD,
					pei_amt_m_SAR,
					pei_amt_m_DKK,
					pei_amt_m_KRW,
					pei_amt_m_IDR,
					pei_amt_m_YER,		
					pei_amt_m_USD_man,
					pei_amt_m_EUR_man,
					pei_amt_m_GBP_man,
					pei_amt_m_CAD_man,	
					pei_amt_m_CHF_man,
					pei_amt_m_KRW_man,
					RowType,
					BatchID,
					PostDate,
					TransactionID,
					LECurrencyID,
					LocCurrencyID)
			select	a.pei_invst_fnd_id_c,
					a.pei_vhcl_id_c,			
					a.pei_invstr_id_c,
					a.pei_deal_id_c,
					max(a.pei_eff_trans_d),
					null,
					null,
					@CurrencyID,
					sum(case @CurrencyID
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
					end),
					max(case @MultCurrency
						when 'P' then b.LECurrencyID
						when 'D' then b.LocalCurrencyID
					end),
					@MultCurrency,
					@MultCurrencyManual,
					sum(case (case @MultCurrency when 'P' then b.LECurrencyID when 'D' then b.LocalCurrencyID end) +  @MultCurrencyManual
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
						when 'PLN'  then a.pei_amt_m_PLN
						when 'BRL'  then a.pei_amt_m_BRL
						when 'KWD'  then a.pei_amt_m_KWD
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
					end),			
					sum(a.pei_amt_m_USD),
					sum(a.pei_amt_m_EUR),
					sum(a.pei_amt_m_AUD),
					sum(a.pei_amt_m_GBP),
					sum(a.pei_amt_m_CAD),
					sum(a.pei_amt_m_ZAR),
					sum(a.pei_amt_m_SEK),
					sum(a.pei_amt_m_CHF),
					sum(a.pei_amt_m_NOK),
					sum(a.pei_amt_m_JPY),
					sum(a.pei_amt_m_INR),
					sum(a.pei_amt_m_PLN),
					sum(a.pei_amt_m_BRL),
					sum(a.pei_amt_m_KWD),
					sum(a.pei_amt_m_SGD),
					sum(a.pei_amt_m_SAR),
					sum(a.pei_amt_m_DKK),
					sum(a.pei_amt_m_KRW),
					sum(a.pei_amt_m_IDR),
					sum(a.pei_amt_m_YER),
					0,
					0,
					0,
					0,	
					0,
					0,
					'A',
					null,
					max(a.pei_investran_post_dz),
					null,
					max(b.LECurrencyID),
					max(b.LocalCurrencyID)
			from	pei_adj_comm_data a
					inner join #lcsfCmtmKeys b
						on a.row_key = b.RowKey
			where	b.RowType = 'A'
					and a.pei_eff_trans_d <= @ReportDate
			group by a.pei_invst_fnd_id_c,a.pei_vhcl_id_c,a.pei_invstr_id_c,a.pei_deal_id_c;
		end				
	end
/* ============================================================================================== */	
	if @CutOffStatement is not null
	begin	
		insert into #lcsfMasterLoad(
				ProductID,
				VehicleID,
				InvestorID,
				DealID,
				EffectiveDate,
				TransTypeID,
				TransStatusID,
				CurrencyID,
				CmtmtAmount,
				MltCurrencyID,
				MultCurrency,
				MultCurrencyManual,
				MltCmtmtAmount,
				pei_amt_m_USD,
				pei_amt_m_EUR,
				pei_amt_m_AUD,
				pei_amt_m_GBP,
				pei_amt_m_CAD,
				pei_amt_m_ZAR,
				pei_amt_m_SEK,
				pei_amt_m_CHF,
				pei_amt_m_NOK,
				pei_amt_m_JPY,
				pei_amt_m_INR,
				pei_amt_m_PLN,
				pei_amt_m_BRL,
				pei_amt_m_KWD,
				pei_amt_m_SGD,
				pei_amt_m_SAR,
				pei_amt_m_DKK,
				pei_amt_m_KRW,
				pei_amt_m_IDR,
				pei_amt_m_YER,		
				pei_amt_m_USD_man,
				pei_amt_m_EUR_man,
				pei_amt_m_GBP_man,
				pei_amt_m_CAD_man,	
				pei_amt_m_CHF_man,
				pei_amt_m_KRW_man,
				RowType,
				BatchID,
				PostDate,
				TransactionID,
				LECurrencyID,
				LocCurrencyID)
		select	a.pei_invst_fnd_id_c,
				a.pei_vhcl_id_c,			
				a.pei_invstr_id_c,
				a.pei_deal_id_c,
				a.pei_eff_trans_d,
				a.pei_trans_typ_id_c,
				a.pei_trans_status_id_c,
				@CurrencyID,
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
				case @MultCurrency
					when 'P' then b.LECurrencyID
					when 'D' then b.LocalCurrencyID
				end,
				@MultCurrency,
				@MultCurrencyManual,
				case (case @MultCurrency when 'P' then b.LECurrencyID when 'D' then b.LocalCurrencyID end) +  @MultCurrencyManual
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
					when 'PLN'  then a.pei_amt_m_PLN
					when 'BRL'  then a.pei_amt_m_BRL
					when 'KWD'  then a.pei_amt_m_KWD
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
				a.pei_amt_m_USD,
				a.pei_amt_m_EUR,
				a.pei_amt_m_AUD,
				a.pei_amt_m_GBP,
				a.pei_amt_m_CAD,
				a.pei_amt_m_ZAR,
				a.pei_amt_m_SEK,
				a.pei_amt_m_CHF,
				a.pei_amt_m_NOK,
				a.pei_amt_m_JPY,
				a.pei_amt_m_INR,
				a.pei_amt_m_PLN,
				a.pei_amt_m_BRL,
				a.pei_amt_m_KWD,
				a.pei_amt_m_SGD,
				a.pei_amt_m_SAR,
				a.pei_amt_m_DKK,
				a.pei_amt_m_KRW,
				a.pei_amt_m_IDR,
				a.pei_amt_m_YER,		
				a.pei_amt_m_USD_man,
				a.pei_amt_m_EUR_man,
				a.pei_amt_m_GBP_man,
				a.pei_amt_m_CAD_man,	
				a.pei_amt_m_CHF_man,
				a.pei_amt_m_KRW_man,
				a.pei_adj_typ_i,
				a.pei_batch_id_c,
				a.pei_investran_post_dz,
				a.pei_investran_trans_id_c,
				b.LECurrencyID,
				b.LocalCurrencyID				
		from	pei_adj_comm_data a
				inner join #lcsfCmtmKeys b
					on a.row_key = b.RowKey
				inner join #dtsProductPostedDate c
						on a.pei_invst_fnd_id_c = c.ProductID						
		where	b.RowType in ('C','M')
				and a.pei_eff_trans_d <= @ReportDate
				and (c.InvestranPostDate is null
					or a.pei_investran_post_dz <= c.InvestranPostDate
					or exists(	select 	1
								from 	ifc_rpt_trans_xref e
								where 	e.pei_invst_fnd_id_c	= a.pei_invst_fnd_id_c
										and e.pei_batch_id_c	= a.pei_batch_id_c
										and e.ifc_qt_signoff_dz	= @CutOffStatement));
		---------------------------------------------------------------------------------
		if exists(select 1 from #lcsfCmtmKeys where RowType = 'A')
		begin
			insert into #lcsfMasterLoad(
					ProductID,
					VehicleID,
					InvestorID,
					DealID,
					EffectiveDate,
					TransTypeID,
					TransStatusID,
					CurrencyID,
					CmtmtAmount,
					MltCurrencyID,
					MultCurrency,
					MultCurrencyManual,
					MltCmtmtAmount,
					pei_amt_m_USD,
					pei_amt_m_EUR,
					pei_amt_m_AUD,
					pei_amt_m_GBP,
					pei_amt_m_CAD,
					pei_amt_m_ZAR,
					pei_amt_m_SEK,
					pei_amt_m_CHF,
					pei_amt_m_NOK,
					pei_amt_m_JPY,
					pei_amt_m_INR,
					pei_amt_m_PLN,
					pei_amt_m_BRL,
					pei_amt_m_KWD,
					pei_amt_m_SGD,
					pei_amt_m_SAR,
					pei_amt_m_DKK,
					pei_amt_m_KRW,
					pei_amt_m_IDR,
					pei_amt_m_YER,		
					pei_amt_m_USD_man,
					pei_amt_m_EUR_man,
					pei_amt_m_GBP_man,
					pei_amt_m_CAD_man,	
					pei_amt_m_CHF_man,
					pei_amt_m_KRW_man,
					RowType,
					BatchID,
					PostDate,
					TransactionID,
					LECurrencyID,
					LocCurrencyID)	
			select	a.pei_invst_fnd_id_c,
					a.pei_vhcl_id_c,			
					a.pei_invstr_id_c,
					a.pei_deal_id_c,
					max(a.pei_eff_trans_d),
					null,
					null,
					@CurrencyID,
					sum(case @CurrencyID
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
					end),
					max(case @MultCurrency
						when 'P' then b.LECurrencyID
						when 'D' then b.LocalCurrencyID
					end),
					@MultCurrency,
					@MultCurrencyManual,
					sum(case (case @MultCurrency when 'P' then b.LECurrencyID when 'D' then b.LocalCurrencyID end) +  @MultCurrencyManual
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
						when 'PLN'  then a.pei_amt_m_PLN
						when 'BRL'  then a.pei_amt_m_BRL
						when 'KWD'  then a.pei_amt_m_KWD
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
					end),			
					sum(a.pei_amt_m_USD),
					sum(a.pei_amt_m_EUR),
					sum(a.pei_amt_m_AUD),
					sum(a.pei_amt_m_GBP),
					sum(a.pei_amt_m_CAD),
					sum(a.pei_amt_m_ZAR),
					sum(a.pei_amt_m_SEK),
					sum(a.pei_amt_m_CHF),
					sum(a.pei_amt_m_NOK),
					sum(a.pei_amt_m_JPY),
					sum(a.pei_amt_m_INR),
					sum(a.pei_amt_m_PLN),
					sum(a.pei_amt_m_BRL),
					sum(a.pei_amt_m_KWD),
					sum(a.pei_amt_m_SGD),
					sum(a.pei_amt_m_SAR),
					sum(a.pei_amt_m_DKK),
					sum(a.pei_amt_m_KRW),
					sum(a.pei_amt_m_IDR),
					sum(a.pei_amt_m_YER),
					0,
					0,
					0,
					0,	
					0,
					0,
					'A',
					null,
					max(a.pei_investran_post_dz),
					null,
					max(b.LECurrencyID),
					max(b.LocalCurrencyID)
			from	pei_adj_comm_data a
					inner join #lcsfCmtmKeys b
						on a.row_key = b.RowKey
					inner join #dtsProductPostedDate c
						on a.pei_invst_fnd_id_c = c.ProductID
			where	b.RowType = 'A'
					and a.pei_eff_trans_d <= @ReportDate
					and (c.InvestranPostDate is null
						or a.pei_investran_post_dz <= c.InvestranPostDate
						or exists(	select 	1
									from 	ifc_rpt_trans_xref e
									where 	e.pei_invst_fnd_id_c	= a.pei_invst_fnd_id_c
											and e.pei_batch_id_c	= a.pei_batch_id_c
											and e.ifc_qt_signoff_dz	= @CutOffStatement))
			group by a.pei_invst_fnd_id_c,a.pei_vhcl_id_c,a.pei_invstr_id_c,a.pei_deal_id_c;
		end
	end	
/* ============================================================================================== */
	if  isnull(@PurchaseDiscount,'N') = 'Y'
	begin	
		exec dbo.sp_ifc_LoadCommitments_LoadData_PD
		@ReportDate			= @ReportDate,
		@CutOffStatement	= @CutOffStatement,
		@CurrencyID 		= @CurrencyID,
		@MultCurrency		= @MultCurrency,
		@MultCurrencyManual	= @MultCurrencyManual;
	end
/* ============================================================================================== */	
	if isnull(@FilterZeros,'N') = 'Y'
	begin
		;with ipdv(ProductID,VehicleID,InvestorID,DealID,TotalAmount) as
		(
			select	a.ProductID,
					a.VehicleID,
					a.InvestorID,
					a.DealID,
					sum(a.CmtmtAmount)
			from	#lcsfMasterLoad a
			group by a.ProductID,a.VehicleID,a.InvestorID,a.DealID
		)
		delete	a
		from	#lcsfMasterLoad a	
				inner join ipdv b
					on a.ProductID		= b.ProductID
					and a.VehicleID		= b.VehicleID
					and a.InvestorID	= b.InvestorID
					and a.DealID		= b.DealID
		where	b.TotalAmount = 0;
	end	
/* ============================================================================================== */
	insert into #lcsfPDTotal(
			ProductID,
			DealID,
			RunTotal,
			pei_amt_m_USD,
			pei_amt_m_EUR,
			pei_amt_m_AUD,
			pei_amt_m_GBP,
			pei_amt_m_CAD,
			pei_amt_m_ZAR,
			pei_amt_m_SEK,
			pei_amt_m_CHF,
			pei_amt_m_NOK,
			pei_amt_m_JPY,
			pei_amt_m_INR,
			pei_amt_m_PLN,
			pei_amt_m_BRL,
			pei_amt_m_KWD,
			pei_amt_m_SGD,
			pei_amt_m_SAR,
			pei_amt_m_DKK,
			pei_amt_m_KRW,
			pei_amt_m_IDR,
			pei_amt_m_YER,		
			pei_amt_m_USD_man,
			pei_amt_m_EUR_man,
			pei_amt_m_GBP_man,
			pei_amt_m_CAD_man,	
			pei_amt_m_CHF_man,
			pei_amt_m_KRW_man)
	select	a.ProductID,						
			a.DealID,
			sum(a.CmtmtAmount),
			sum(pei_amt_m_USD),
			sum(pei_amt_m_EUR),
			sum(pei_amt_m_AUD),
			sum(pei_amt_m_GBP),
			sum(pei_amt_m_CAD),
			sum(pei_amt_m_ZAR),
			sum(pei_amt_m_SEK),
			sum(pei_amt_m_CHF),
			sum(pei_amt_m_NOK),
			sum(pei_amt_m_JPY),
			sum(pei_amt_m_INR),
			sum(pei_amt_m_PLN),
			sum(pei_amt_m_BRL),
			sum(pei_amt_m_KWD),
			sum(pei_amt_m_SGD),
			sum(pei_amt_m_SAR),
			sum(pei_amt_m_DKK),
			sum(pei_amt_m_KRW),
			sum(pei_amt_m_IDR),
			sum(pei_amt_m_YER),		
			sum(pei_amt_m_USD_man),
			sum(pei_amt_m_EUR_man),
			sum(pei_amt_m_GBP_man),
			sum(pei_amt_m_CAD_man),	
			sum(pei_amt_m_CHF_man),
			sum(pei_amt_m_KRW_man)
	from	#lcsfMasterLoad a
	where	a.RowType in ('C','P')
	group by a.ProductID,a.DealID;
/* ============================================================================================== */
	insert into #lcsfPDTotalAdj(
			ProductID,
			DealID,
			RunTotal,
			pei_amt_m_USD,
			pei_amt_m_EUR,
			pei_amt_m_AUD,
			pei_amt_m_GBP,
			pei_amt_m_CAD,
			pei_amt_m_ZAR,
			pei_amt_m_SEK,
			pei_amt_m_CHF,
			pei_amt_m_NOK,
			pei_amt_m_JPY,
			pei_amt_m_INR,
			pei_amt_m_PLN,
			pei_amt_m_BRL,
			pei_amt_m_KWD,
			pei_amt_m_SGD,
			pei_amt_m_SAR,
			pei_amt_m_DKK,
			pei_amt_m_KRW,
			pei_amt_m_IDR,
			pei_amt_m_YER,		
			pei_amt_m_USD_man,
			pei_amt_m_EUR_man,
			pei_amt_m_GBP_man,
			pei_amt_m_CAD_man,	
			pei_amt_m_CHF_man,
			pei_amt_m_KRW_man)
	select	a.ProductID,
			a.DealID,
			sum(a.CmtmtAmount),
			sum(pei_amt_m_USD),
			sum(pei_amt_m_EUR),
			sum(pei_amt_m_AUD),
			sum(pei_amt_m_GBP),
			sum(pei_amt_m_CAD),
			sum(pei_amt_m_ZAR),
			sum(pei_amt_m_SEK),
			sum(pei_amt_m_CHF),
			sum(pei_amt_m_NOK),
			sum(pei_amt_m_JPY),
			sum(pei_amt_m_INR),
			sum(pei_amt_m_PLN),
			sum(pei_amt_m_BRL),
			sum(pei_amt_m_KWD),
			sum(pei_amt_m_SGD),
			sum(pei_amt_m_SAR),
			sum(pei_amt_m_DKK),
			sum(pei_amt_m_KRW),
			sum(pei_amt_m_IDR),
			sum(pei_amt_m_YER),		
			sum(pei_amt_m_USD_man),
			sum(pei_amt_m_EUR_man),
			sum(pei_amt_m_GBP_man),
			sum(pei_amt_m_CAD_man),	
			sum(pei_amt_m_CHF_man),
			sum(pei_amt_m_KRW_man)
	from	#lcsfMasterLoad a
	group by a.ProductID,a.DealID;
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_LoadData to PE_datawriter, PE_datareader
GO	