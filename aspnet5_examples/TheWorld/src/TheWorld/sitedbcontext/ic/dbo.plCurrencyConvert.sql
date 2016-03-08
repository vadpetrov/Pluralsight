create function dbo.plCurrencyConvert
(
@Amount 		float,
@RateDate 		datetime = getdate,
@CurrencyIn 	char(3)= 'USD',
@CurrencyOut 	char(3)= 'USD'
)
returns float
as
begin
	declare @IN_RATE 	float
	declare @OUT_RATE 	float
	declare @RATE_DATE_F	datetime
	
	set @CurrencyIn		= dbo.fnManualOriginalCurrency(@CurrencyIn,2);
	set @CurrencyOut	= dbo.fnManualOriginalCurrency(@CurrencyOut,2);

	set @RATE_DATE_F = convert(varchar,Month(@RateDate)) + '/' + convert(varchar,Day(@RateDate)) + '/' + convert(varchar,Year(@RateDate))
	set @IN_RATE 	= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @CurrencyIn 	and pei_fx_rte_ef_d<=@RATE_DATE_F order by pei_fx_rte_ef_d DESC)
	set @OUT_RATE 	= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @CurrencyOut 	and pei_fx_rte_ef_d<=@RATE_DATE_F order by pei_fx_rte_ef_d DESC)

	declare @RetVal float

	if @OUT_RATE is null or @IN_RATE is null 
		set @RetVal = null
	else
		set @RetVal = @Amount / @IN_RATE * @OUT_RATE

	return @RetVal
end  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[plCurrencyConvert] TO [PE_datareader]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[plCurrencyConvert] TO [PE_datawriter]
    AS [dbo];