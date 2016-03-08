create function [dbo].[IsManualCurrency](@CurrencyID char(3))
returns char(1)
as
begin	
	return
	(	
		case	isnull(@CurrencyID,'')					
				when 'USM' 	then 'Y'
				when 'EUM' 	then 'Y'
				when 'GBM' 	then 'Y'
				when 'CDM' 	then 'Y'
				when 'CHM' 	then 'Y'
				when 'KRM' 	then 'Y'
				else 'N'
		end			
	)
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IsManualCurrency] TO [PE_datareader]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IsManualCurrency] TO [PE_datawriter]
    AS [dbo];

