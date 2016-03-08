create function dbo.fn_Fx_CurrencyConvert
(
@InputCurrencyID 	char(3),
@OutputCurrencyID 	char(3),
@RateDate 			datetime,
@Amount 			decimal(30,2),
@LatestRate			bit
)
returns @ReturnTable table(
InputCurrencyID		char(3),
OutputCurrencyID	char(3),
RateDate			datetime,
InputUSDRate		float,
OutputUSDRate		float,
FxRate				float,
FxRateReverse		float,
InputAmount			decimal(30,2),
OutputAmount		decimal(30,2),
LatestRate			bit)
as
begin
	declare @in_rate		float;
	declare @out_rate 		float;
	declare @rate_date_fx	datetime;
	declare @cur_in			char(3);
	declare @cur_out		char(3);
	-----------------------------------------------
	set @RateDate	= isnull(@RateDate,getdate());
	set @cur_in		= dbo.fnManualOriginalCurrency(@InputCurrencyID,2);
	set @cur_out	= dbo.fnManualOriginalCurrency(@OutputCurrencyID,2);
	
	set @rate_date_fx	= convert(varchar,month(@RateDate)) + '/' + convert(varchar,day(@RateDate)) + '/' + convert(varchar,year(@RateDate))
	if @LatestRate = 1
		begin
			set @in_rate 		= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @cur_in 	and pei_fx_rte_ef_d<=@rate_date_fx order by pei_fx_rte_ef_d desc)
			set @out_rate 		= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @cur_out 	and pei_fx_rte_ef_d<=@rate_date_fx order by pei_fx_rte_ef_d desc)	
		end
	else
		begin
			set @in_rate 		= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @cur_in 	and pei_fx_rte_ef_d=@rate_date_fx order by pei_fx_rte_ef_d desc)
			set @out_rate 		= (select top 1 pei_cur_fx_p from pei_cur_fx_ref where cur_id_c = @cur_out 	and pei_fx_rte_ef_d=@rate_date_fx order by pei_fx_rte_ef_d desc)	
		end		
	-----------------------------------------------
	insert into @ReturnTable(
			InputCurrencyID,
			OutputCurrencyID,
			RateDate,
			InputUSDRate,
			OutputUSDRate,
			FxRate,
			FxRateReverse,
			InputAmount,
			OutputAmount,
			LatestRate)
	select	@InputCurrencyID,
			@OutputCurrencyID,
			@RateDate,
			@in_rate,
			@out_rate,
			case when isnull(@in_rate,0) = 0 then null else  @out_rate/@in_rate end,
			case when isnull(@out_rate,0) = 0 then null else  @in_rate/@out_rate end,			
			@Amount,
			case when isnull(@in_rate,0) = 0 then null else  @Amount*@out_rate/@in_rate end,
			@LatestRate;
	-----------------------------------------------
	return;
end
GO
GRANT SELECT
    ON OBJECT::[dbo].[fn_Fx_CurrencyConvert] TO [PE_datareader]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[fn_Fx_CurrencyConvert] TO [PE_datawriter]
    AS [dbo];
