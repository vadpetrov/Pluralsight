create function dbo.Split
(
@SearchString	varchar(max),
@Separator		varchar(5) 
)
returns @ReturnTable table (id varchar(8000))
as
begin
	
	if isnull(@SearchString,'') <> ''
	begin
		declare @tmpStr				varchar(max)
		declare @intSeparatorLength int
		declare @n int

		set @intSeparatorLength = len(@Separator)
		set @tmpStr				= @SearchString

		while 1=1
		begin
			set @n	= charindex(@Separator,@tmpStr)
			if @n	= 0
			begin
				insert into @ReturnTable values(@tmpStr)	
				break
			end
			insert into @ReturnTable values(substring(@tmpStr,0,@n))
			set @tmpStr = rtrim(ltrim(substring(@tmpStr,@n + @intSeparatorLength,len(@tmpStr) - @intSeparatorLength)))
		end
	end
	return
end
/* =============================================================================================================== */

GO
GRANT SELECT
    ON OBJECT::[dbo].[Split] TO [PE_datareader]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Split] TO [PE_datawriter]
    AS [dbo];

