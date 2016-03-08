create function [dbo].[fnManualOriginalCurrency](@CurrencyID char(3),@CallType	int)
returns char(3)
as
begin	
	return
	(
		case				
			when @CurrencyID = 'USD' and @CallType = 1 then 'USM'
			when @CurrencyID = 'EUR' and @CallType = 1 then 'EUM'
			when @CurrencyID = 'GBP' and @CallType = 1 then 'GBM'
			when @CurrencyID = 'CAD' and @CallType = 1 then 'CDM'			
			when @CurrencyID = 'CHF' and @CallType = 1 then 'CHM'
			when @CurrencyID = 'KRW' and @CallType = 1 then 'KRM'
						
			when @CurrencyID = 'USM' and @CallType = 2 then 'USD'
			when @CurrencyID = 'EUM' and @CallType = 2 then 'EUR'
			when @CurrencyID = 'GBM' and @CallType = 2 then 'GBP'
			when @CurrencyID = 'CDM' and @CallType = 2 then 'CAD'			
			when @CurrencyID = 'CHM' and @CallType = 2 then 'CHF'
			when @CurrencyID = 'KRM' and @CallType = 2 then 'KRW'
			
			when isnull(@CurrencyID,'') = '' and @CallType = 1 then 'USM'
			when isnull(@CurrencyID,'') = '' and @CallType = 2 then 'USD'			
			
			else @CurrencyID
		end			
	)
end  


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[fnManualOriginalCurrency] TO [PE_datareader]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[fnManualOriginalCurrency] TO [PE_datawriter]
    AS [dbo];