create procedure [dbo].[sp_ifc_LoadCommitments_UpdateSizes]
@Iteration	int,
@CallType	int
as
begin
	if @CallType = 1
	begin
		update	#lcsfMasterData
		set		MltCmtmtAmount =	case (a.MltCurrencyID +  a.MultCurrencyManual)
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
				
				PVDTotal	=		b.RunTotal,
				PVDTotalAdj	=		c.RunTotal,
				
				MltPVDTotal = 		case (a.MltCurrencyID +  a.MultCurrencyManual)
										when null	then null		
										when 'USD'	then b.pei_amt_m_USD
										when 'EUR'	then b.pei_amt_m_EUR
										when 'AUD'	then b.pei_amt_m_AUD
										when 'GBP'	then b.pei_amt_m_GBP
										when 'CAD'	then b.pei_amt_m_CAD
										when 'ZAR'	then b.pei_amt_m_ZAR
										when 'SEK'	then b.pei_amt_m_SEK
										when 'CHF'	then b.pei_amt_m_CHF
										when 'NOK'	then b.pei_amt_m_NOK
										when 'JPY'  then b.pei_amt_m_JPY
										when 'INR'  then b.pei_amt_m_INR
										when 'PLN'  then b.pei_amt_m_PLN
										when 'BRL'  then b.pei_amt_m_BRL
										when 'KWD'  then b.pei_amt_m_KWD
										when 'SGD'	then b.pei_amt_m_SGD
										when 'SAR'	then b.pei_amt_m_SAR
										when 'DKK'	then b.pei_amt_m_DKK
										when 'KRW'	then b.pei_amt_m_KRW
										when 'IDR'	then b.pei_amt_m_IDR
										when 'YER'	then b.pei_amt_m_YER								
										when 'USDY'	then b.pei_amt_m_USD_man
										when 'EURY'	then b.pei_amt_m_EUR_man
										when 'GBPY' then b.pei_amt_m_GBP_man
										when 'CADY' then b.pei_amt_m_CAD_man
										when 'CHFY' then b.pei_amt_m_CHF_man
										when 'KRWY' then b.pei_amt_m_KRW_man
									end,
				MltPVDTotalAdj = 	case (a.MltCurrencyID +  a.MultCurrencyManual)
										when null	then null		
										when 'USD'	then c.pei_amt_m_USD
										when 'EUR'	then c.pei_amt_m_EUR
										when 'AUD'	then c.pei_amt_m_AUD
										when 'GBP'	then c.pei_amt_m_GBP
										when 'CAD'	then c.pei_amt_m_CAD
										when 'ZAR'	then c.pei_amt_m_ZAR
										when 'SEK'	then c.pei_amt_m_SEK
										when 'CHF'	then c.pei_amt_m_CHF
										when 'NOK'	then c.pei_amt_m_NOK
										when 'JPY'  then c.pei_amt_m_JPY
										when 'INR'  then c.pei_amt_m_INR
										when 'PLN'  then c.pei_amt_m_PLN
										when 'BRL'  then c.pei_amt_m_BRL
										when 'KWD'  then c.pei_amt_m_KWD
										when 'SGD'	then c.pei_amt_m_SGD
										when 'SAR'	then c.pei_amt_m_SAR
										when 'DKK'	then c.pei_amt_m_DKK
										when 'KRW'	then c.pei_amt_m_KRW
										when 'IDR'	then c.pei_amt_m_IDR
										when 'YER'	then c.pei_amt_m_YER								
										when 'USDY'	then c.pei_amt_m_USD_man
										when 'EURY'	then c.pei_amt_m_EUR_man
										when 'GBPY' then c.pei_amt_m_GBP_man
										when 'CADY' then c.pei_amt_m_CAD_man
										when 'CHFY' then c.pei_amt_m_CHF_man
										when 'KRWY' then c.pei_amt_m_KRW_man
									end					
		from	#lcsfMasterData a
				inner join #lcsfPDTotal b
					on a.RunProductID	= b.ProductID					
					and a.RunDealID		= b.DealID
				inner join #lcsfPDTotalAdj c
					on a.RunProductID	= c.ProductID					
					and a.RunDealID		= c.DealID				
		where	a.Iteration = @Iteration;
	end
/* =================================================================================================== */	
	if @CallType = 2
	begin	
		update	#lcsfMasterData
		set		MltCmtmtAmount =	case (a.MltCurrencyID +  a.MultCurrencyManual)
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
				
				PVDTotal	=		b.RunTotal,
				PVDTotalAdj	=		c.RunTotal,
				
				MltPVDTotal = 		case (a.MltCurrencyID +  a.MultCurrencyManual)
										when null	then null		
										when 'USD'	then b.pei_amt_m_USD
										when 'EUR'	then b.pei_amt_m_EUR
										when 'AUD'	then b.pei_amt_m_AUD
										when 'GBP'	then b.pei_amt_m_GBP
										when 'CAD'	then b.pei_amt_m_CAD
										when 'ZAR'	then b.pei_amt_m_ZAR
										when 'SEK'	then b.pei_amt_m_SEK
										when 'CHF'	then b.pei_amt_m_CHF
										when 'NOK'	then b.pei_amt_m_NOK
										when 'JPY'  then b.pei_amt_m_JPY
										when 'INR'  then b.pei_amt_m_INR
										when 'PLN'  then b.pei_amt_m_PLN
										when 'BRL'  then b.pei_amt_m_BRL
										when 'KWD'  then b.pei_amt_m_KWD
										when 'SGD'	then b.pei_amt_m_SGD
										when 'SAR'	then b.pei_amt_m_SAR
										when 'DKK'	then b.pei_amt_m_DKK
										when 'KRW'	then b.pei_amt_m_KRW
										when 'IDR'	then b.pei_amt_m_IDR
										when 'YER'	then b.pei_amt_m_YER								
										when 'USDY'	then b.pei_amt_m_USD_man
										when 'EURY'	then b.pei_amt_m_EUR_man
										when 'GBPY' then b.pei_amt_m_GBP_man
										when 'CADY' then b.pei_amt_m_CAD_man
										when 'CHFY' then b.pei_amt_m_CHF_man
										when 'KRWY' then b.pei_amt_m_KRW_man
									end,
				MltPVDTotalAdj = 	case (a.MltCurrencyID +  a.MultCurrencyManual)
										when null	then null		
										when 'USD'	then c.pei_amt_m_USD
										when 'EUR'	then c.pei_amt_m_EUR
										when 'AUD'	then c.pei_amt_m_AUD
										when 'GBP'	then c.pei_amt_m_GBP
										when 'CAD'	then c.pei_amt_m_CAD
										when 'ZAR'	then c.pei_amt_m_ZAR
										when 'SEK'	then c.pei_amt_m_SEK
										when 'CHF'	then c.pei_amt_m_CHF
										when 'NOK'	then c.pei_amt_m_NOK
										when 'JPY'  then c.pei_amt_m_JPY
										when 'INR'  then c.pei_amt_m_INR
										when 'PLN'  then c.pei_amt_m_PLN
										when 'BRL'  then c.pei_amt_m_BRL
										when 'KWD'  then c.pei_amt_m_KWD
										when 'SGD'	then c.pei_amt_m_SGD
										when 'SAR'	then c.pei_amt_m_SAR
										when 'DKK'	then c.pei_amt_m_DKK
										when 'KRW'	then c.pei_amt_m_KRW
										when 'IDR'	then c.pei_amt_m_IDR
										when 'YER'	then c.pei_amt_m_YER								
										when 'USDY'	then c.pei_amt_m_USD_man
										when 'EURY'	then c.pei_amt_m_EUR_man
										when 'GBPY' then c.pei_amt_m_GBP_man
										when 'CADY' then c.pei_amt_m_CAD_man
										when 'CHFY' then c.pei_amt_m_CHF_man
										when 'KRWY' then c.pei_amt_m_KRW_man
									end																			
		from	#lcsfMasterData a
				inner join #lcsfPDTotal b
					on a.RefProductID		= b.ProductID
					and a.RefDealID			= b.DealID
				inner join #lcsfPDTotalAdj c
					on a.RefProductID		= c.ProductID
					and a.RefDealID			= c.DealID				
		where	a.Iteration = @Iteration;			
	end
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_UpdateSizes to PE_datawriter, PE_datareader
GO