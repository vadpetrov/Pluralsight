create procedure [dbo].[sp_fc_LoadCommitments_Deal]
@Iteration			int,
@ProcessType		int = 0, -- 0 -Direct / 1 - SPV / 2 - FOF
@Keys				tvp_allc_key readonly,
@MaxLevel			int	= 32
as
	set nocount on;
begin	
		/* ======================================================================================================= 
	 ================================== FIRST RUN  ============================================================ 
	 ========================================================================================================== */
	if @Iteration = 1
	begin
		insert into #lcsfMasterData(
				Iteration,
				ReferenceID,
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
				ReportProductID,
				ReportVehicleID,
				ReportInvestorID,
				ReportDealID,
				ReportEffectiveDate,
				RunProductID,
				RunVehicleID,
				RunInvestorID,
				RunDealID)				
		select	@Iteration,
				0,
				a.ProductID,
				a.VehicleID,
				a.InvestorID,
				a.DealID,
				a.EffectiveDate,
				a.TransTypeID,
				a.TransStatusID,					
				a.CurrencyID,
				a.CmtmtAmount,
				a.MltCurrencyID,
				a.MultCurrency,
				a.MultCurrencyManual,
				a.MltCmtmtAmount,
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
				a.RowType,
				a.BatchID,
				a.PostDate,
				a.TransactionID,				
				a.ProductID,
				a.VehicleID,
				a.InvestorID,
				a.DealID,
				a.EffectiveDate,
				a.ProductID,
				a.VehicleID,
				a.InvestorID,
				a.DealID				
		from	#lcsfMasterLoad a
				inner join @Keys b				
					on a.ProductID		= b.ProductID				
					and a.VehicleID		= b.VehicleID				
					and a.InvestorID	= b.InvestorID				
					and a.DealID		= b.DealID;
		---------------------------------------------------------------------------------			
		exec dbo.sp_fc_LoadCommitments_UpdateSizes @Iteration = 1, @CallType = 1;
	end	
	/* ======================================================================================================== 
	 ================================== NEXT RUN ============================================================= 
	 ========================================================================================================== */
	if @Iteration > 1 and @ProcessType <> 0 
	begin
		declare @PrvIteration int;
		set @PrvIteration = @Iteration - 1;
		------------------------------------------
		insert into #lcsfMasterData(
				Iteration,
				ReferenceID,
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
				RefProductID,
				RefVehicleID,
				RefInvestorID,
				RefDealID,
				ReportProductID,
				ReportVehicleID,
				ReportInvestorID,
				ReportDealID,
				ReportEffectiveDate,
				RunProductID,
				RunVehicleID,
				RunInvestorID,
				RunDealID)
		select	@Iteration,
				a.RowID,
				c.ProductID,
				c.VehicleID,				
				c.InvestorID,				
				c.DealID,
				c.EffectiveDate,
				c.TransTypeID,
				c.TransStatusID,				
				c.CurrencyID,				
				case 
					when round(e.RunTotal,-1) = 0 then 0
					when c.RowType = 'A' and c.MltCmtmtAmount = 0 then 0
					else (c.CmtmtAmount/e.RunTotal) * a.CmtmtAmount
				end,				
				
								
				case a.MultCurrency when 'P' then c.MltCurrencyID when 'D' then a.MltCurrencyID end,
				a.MultCurrency,
				a.MultCurrencyManual,
				
				case when round(e.pei_amt_m_USD,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_USD/e.pei_amt_m_USD) * a.pei_amt_m_USD end,
				case when round(e.pei_amt_m_EUR,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_EUR/e.pei_amt_m_EUR) * a.pei_amt_m_EUR end,
				case when round(e.pei_amt_m_AUD,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_AUD/e.pei_amt_m_AUD) * a.pei_amt_m_AUD end,
				case when round(e.pei_amt_m_GBP,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_GBP/e.pei_amt_m_GBP) * a.pei_amt_m_GBP end,
				
				case when round(e.pei_amt_m_CAD,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_CAD/e.pei_amt_m_CAD) * a.pei_amt_m_CAD end,
				case when round(e.pei_amt_m_ZAR,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_ZAR/e.pei_amt_m_ZAR) * a.pei_amt_m_ZAR end,
				case when round(e.pei_amt_m_SEK,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_SEK/e.pei_amt_m_SEK) * a.pei_amt_m_SEK end,
				case when round(e.pei_amt_m_CHF,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_CHF/e.pei_amt_m_CHF) * a.pei_amt_m_CHF end,
				
				case when round(e.pei_amt_m_NOK,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_NOK/e.pei_amt_m_NOK) * a.pei_amt_m_NOK end,
				case when round(e.pei_amt_m_JPY,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_JPY/e.pei_amt_m_JPY) * a.pei_amt_m_JPY end,
				case when round(e.pei_amt_m_INR,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_INR/e.pei_amt_m_INR) * a.pei_amt_m_INR end,
				case when round(e.pei_amt_m_PLN,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_PLN/e.pei_amt_m_PLN) * a.pei_amt_m_PLN end,
				
				case when round(e.pei_amt_m_BRL,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_BRL/e.pei_amt_m_BRL) * a.pei_amt_m_BRL end,
				case when round(e.pei_amt_m_KWD,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_KWD/e.pei_amt_m_KWD) * a.pei_amt_m_KWD end,
				case when round(e.pei_amt_m_SGD,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_SGD/e.pei_amt_m_SGD) * a.pei_amt_m_SGD end,
				case when round(e.pei_amt_m_SAR,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_SAR/e.pei_amt_m_SAR) * a.pei_amt_m_SAR end,
				
				case when round(e.pei_amt_m_DKK,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_DKK/e.pei_amt_m_DKK) * a.pei_amt_m_DKK end,
				case when round(e.pei_amt_m_KRW,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_KRW/e.pei_amt_m_KRW) * a.pei_amt_m_KRW end,
				case when round(e.pei_amt_m_IDR,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_IDR/e.pei_amt_m_IDR) * a.pei_amt_m_IDR end,
				case when round(e.pei_amt_m_YER,-1) = 0 or (c.RowType = 'A' and c.MltCmtmtAmount = 0) then 0 else (c.pei_amt_m_YER/e.pei_amt_m_YER) * a.pei_amt_m_YER end,
				
				case when round(e.pei_amt_m_USD_man,-1) = 0 then 0 else (c.pei_amt_m_USD_man/e.pei_amt_m_USD_man) * a.pei_amt_m_USD_man end,
				case when round(e.pei_amt_m_EUR_man,-1) = 0 then 0 else (c.pei_amt_m_EUR_man/e.pei_amt_m_EUR_man) * a.pei_amt_m_EUR_man end,
				case when round(e.pei_amt_m_GBP_man,-1) = 0 then 0 else (c.pei_amt_m_GBP_man/e.pei_amt_m_GBP_man) * a.pei_amt_m_GBP_man end,
				case when round(e.pei_amt_m_CAD_man,-1) = 0 then 0 else (c.pei_amt_m_CAD_man/e.pei_amt_m_CAD_man) * a.pei_amt_m_CAD_man end,
				case when round(e.pei_amt_m_CHF_man,-1) = 0 then 0 else (c.pei_amt_m_CHF_man/e.pei_amt_m_CHF_man) * a.pei_amt_m_CHF_man end,
				case when round(e.pei_amt_m_KRW_man,-1) = 0 then 0 else (c.pei_amt_m_KRW_man/e.pei_amt_m_KRW_man) * a.pei_amt_m_KRW_man end,
				
				c.RowType,
				c.BatchID,
				c.PostDate,				
				c.TransactionID,				
				a.ProductID,
				a.VehicleID,
				a.InvestorID,
				a.DealID,								
				c.ProductID,
				c.VehicleID,
				c.InvestorID,				
				a.ReportDealID,
				case when a.ReportEffectiveDate < c.EffectiveDate then c.EffectiveDate else a.ReportEffectiveDate end,
				a.RunProductID,
				a.RunVehicleID,
				a.RunInvestorID,
				a.RunDealID				
		from	#lcsfMasterData a
				inner join @Keys b				
					on a.ProductID		= b.ProductID				
					and a.VehicleID		= b.VehicleID				
					and a.InvestorID	= b.InvestorID				
					and a.DealID		= b.DealID
				inner join #lcsfMasterLoad c
					on  b.ProductDealID = c.DealID
				inner join pei_invstr_ref d
					on c.ProductID		= d.pei_invstr_invst_fnd_id_c
					and a.InvestorID	= d.pei_invstr_id_c
				inner join #lcsfPDTotal e
					on c.ProductID		= e.ProductID					
					and c.DealID		= e.DealID
		where	a.Iteration = @PrvIteration;		
		---------------------------------------------------------------------------------
		exec dbo.sp_fc_LoadCommitments_UpdateSizes @Iteration = @Iteration, @CallType = 1;
	end		
/* ========================================================================================================
 ================================== RECURSIVE CALL ======================================================== 
 ========================================================================================================== */	
	if isnull(@ProcessType,0)<> 0
	begin
		set @Iteration = @Iteration + 1;
		if @Iteration > @MaxLevel return;
		-------------------------------
		declare @Keys1 tvp_allc_key;
		
		insert into @Keys1(ProductID,VehicleID,InvestorID,DealID,ProductDealID)
		select	distinct
				a.ProductID,
				a.VehicleID,
				a.InvestorID,
				a.DealID,
				b.pei_deal_id_c
		from	#lcsfMasterData a
				inner join pei_deal_ref b
					on a.ProductID = b.pei_deal_invst_fnd_id_c
				inner join pei_invst_fnd_ref c
					on b.pei_deal_invst_fnd_id_c = c.pei_invst_fnd_id_c
		where	a.Iteration = (@Iteration-1)
				and
				((@ProcessType = 1 and c.pei_invst_fnd_feeder_i = 'Y')
				or
				(@ProcessType = 2 and c.pei_invst_fnd_fof_i = 'Y'));
		-------------------------------
		if (select count(*) from @Keys1) > 0
		begin
			exec dbo.sp_fc_LoadCommitments_Deal
			@Iteration			= @Iteration,
			@ProcessType		= @ProcessType,
			@Keys				= @Keys1,
			@MaxLevel			= @MaxLevel;			
		end						
	end	
end
GO
grant execute on dbo.sp_fc_LoadCommitments_Deal to PE_datawriter, PE_datareader
GO
