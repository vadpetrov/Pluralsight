create procedure [dbo].[sp_ifc_LoadCommitments_SPV_Adapter_Feeders]
@Iteration			int,
@RunType			int		= 1,
@FeederShortNames	char(1)	= 'Y'
as
	set nocount on;
begin
	declare @Rows table (RowID int);
	declare @PrvIteration int;
/* ========================================================================================== */	
	if @Iteration = 1
	begin
			with fdata(RowID,ProductID,VehicleID,DealID,FeederID) as
			(
				select	a.RowID,						
						a.ReportProductID,
						a.ReportVehicleID,						
						a.ReportDealID,
						case @RunType when 1 then a.ProductID else a.RefProductID end						
				from	#lcsfMasterData a	
				where	a.Iteration = 1
			)
			insert into #lcsfAdapterFeeders(
					Iteration,
					RowID,
					ProductID,
					VehicleID,
					DealID)
			output	inserted.RowID into @Rows		
			select	1,
					a.RowID,
					a.ProductID,
					a.VehicleID,
					a.DealID
			from	fdata a					
			where	exists(	select	1
							from	#lcsfMasterData b
							where	a.RowID = b.ReferenceID);
	end
/* ========================================================================================== */
	if @Iteration <> 1
	begin
		set @PrvIteration = @Iteration - 1;
		--------------------------------------
		with fdata(RowID,ProductID,VehicleID,DealID,FeederID,RefFeederID,RefFeederName) as
		(
			select	a.RowID,
					a.ReportProductID,
					a.ReportVehicleID,						
					a.ReportDealID,
					case @RunType when 1 then a.ProductID else a.RefProductID end,					
					b.FeederID,
					b.FeederName
			from	#lcsfMasterData a
					inner join #lcsfAdapterFeeders b
						on a.ReferenceID = b.RowID	
			where	a.Iteration			= @Iteration
					and b.Iteration		= @PrvIteration
		)
		insert into #lcsfAdapterFeeders(
				Iteration,
				RowID,
				ProductID,
				VehicleID,
				DealID,
				FeederID,
				FeederName)
		output	inserted.RowID into @Rows		
		select	@Iteration,
				a.RowID,
				a.ProductID,
				a.VehicleID,						
				a.DealID,
				case when a.RefFeederID is null		then '' else a.RefFeederID + ';' end
				+ convert(varchar(max),b.pei_invst_fnd_id_c),
				case when a.RefFeederName is null	then '' else a.RefFeederName + ';' end + 
				case @FeederShortNames when 'Y' then ltrim(rtrim(b.pei_invst_fnd_shrt_n)) else ltrim(rtrim(b.pei_invst_fnd_n)) end
		from	fdata a
				inner join pei_invst_fnd_ref b
					on a.FeederID = b.pei_invst_fnd_id_c;
	end
/* ========================================================================================== */
	if (select count(*)from @Rows) <> 0
		begin
			set @Iteration = @Iteration + 1;
			----------------------------------------
			exec dbo.sp_ifc_LoadCommitments_SPV_Adapter_Feeders
				@Iteration			= @Iteration,
				@RunType			= @RunType,
				@FeederShortNames	= @FeederShortNames;		
		end	
	else
		begin
			with pvd_feeders(ProductID,VehicleID,DealID,FeederID,FeederName) as
			(
					select	distinct
							a.ProductID,
							a.VehicleID,
							a.DealID,
							a.FeederID,
							a.FeederName
					from	#lcsfAdapterFeeders a
			)			
			update	#tmpFeederDtl
			set		FeederFundIDList		= nullif(b.FeederID,''),
					FeederFundShrtNameList	= nullif(b.FeederName,'')
			from	#tmpFeederDtl a			
					inner join pvd_feeders b
						on a.pei_invst_fnd_id_c = b.ProductID
						and a.pei_vhcl_id_c		= b.VehicleID
						and a.pei_deal_id_c		= b.DealID;
			----------------------------------------------------------
			if @RunType = 2
			begin
				update	#tmpFeederDtl
				set		FeederFundIDList	=		stuff(( 
													select ';' + reverse(id) 
													from  dbo.split(reverse(FeederFundIDList),';')
													for xml path(''), type).value('.[1]','varchar(max)'), 1, 1, ''),
						FeederFundShrtNameList	=	stuff(( 
													select ';' + reverse(id) 
													from  dbo.split(reverse(FeederFundShrtNameList),';')
													for xml path(''), type).value('.[1]','varchar(max)'), 1, 1, '')			
				where	HasFeeder = 'Y'
						and charindex(';',FeederFundIDList)<>0;
			end						
		end
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_SPV_Adapter_Feeders to PE_datawriter, PE_datareader
GO