create procedure [dbo].[sp_ifc_LoadCommitments_SPV_Adapter_Investor_AllcPercent]
@Iteration			int,
@RunType			int		= 1
as
	set nocount on;
begin
	declare @Rows table (RowID int);
	declare @PrvIteration int;
/* ========================================================================================== */	
	if @Iteration = 1
	begin	
		with fdata(InvestorID,ProductID,VehicleID,DealID,Pct) as
		(
			select	a.InvestorID,
					a.ProductID,
					a.VehicleID,
					a.DealID,
					case when a.MltPVDTotal = 0 then 0 else cast(sum(a.MltCmtmtAmount) as float)/a.MltPVDTotal end
			from	#lcsfMasterData a 
			where	a.Iteration = 1
					and a.RowType ='C'--in ('C','P')					
					and exists(select	1
							from	#lcsfMasterData b
							where	a.RowID = b.ReferenceID)		
			group by a.InvestorID,a.ProductID,a.VehicleID,a.DealID,a.MltPVDTotal
		)	
		insert into #lcsfAdapterIAP(
				Iteration,
				RowID,
				InvestorID,
				ProductID,
				VehicleID,
				DealID,
				FeederProductID,
				FeederVehicleID,
				FeederInvestorID,
				Pct)
		output	inserted.RowID into @Rows
		select	1,
				b.RowID,
				a.InvestorID,
				a.ProductID,
				a.VehicleID,
				a.DealID,
				0,0,0,
				a.Pct		
		from	fdata a
				inner join #lcsfMasterData b
					on b.Iteration		= 1
					and b.ProductID		= a.ProductID
					and b.DealID		= a.DealID
					and b.InvestorID	= a.InvestorID
					and b.VehicleID		= a.VehicleID
		where	b.RowType = 'C'
	end
/* ========================================================================================== */
	if @Iteration <> 1
	begin
		set @PrvIteration = @Iteration - 1;
		--------------------------------------
		insert into #lcsfAdapterIAP(
				Iteration,
				RowID,
				InvestorID,
				ProductID,
				VehicleID,
				DealID,
				FeederProductID,
				FeederVehicleID,
				FeederInvestorID,
				Pct)
		output	inserted.RowID into @Rows		
		select	@Iteration,
				a.RowID,
				a.ReportInvestorID,
				a.ReportProductID,
				a.ReportVehicleID,
				a.ReportDealID,
				case @RunType when 1 then a.ProductID else a.RefProductID end,
				case @RunType when 1 then a.VehicleID else a.RefVehicleID end,
				case @RunType when 1 then a.InvestorID else a.RefInvestorID end,				
				b.Pct
		from	#lcsfMasterData a
				inner join #lcsfAdapterIAP b
					on a.ReferenceID = b.RowID	
		where	a.RowType		= 'C'
				and a.Iteration	= @Iteration
				and b.Iteration	= @PrvIteration;
	end	
/* ========================================================================================== */
	if (select count(*)from @Rows) <> 0
		begin
			set @Iteration = @Iteration + 1;
			----------------------------------------
			exec dbo.sp_ifc_LoadCommitments_SPV_Adapter_Investor_AllcPercent
				@Iteration			= @Iteration,
				@RunType			= @RunType;	
		end	
	else
		begin
			with ipvd_feeders(InvestorID,ProductID,VehicleID,DealID,
					FeederProductID,FeederVehicleID,FeederInvestorID,Pct) as
			(
				select	a.InvestorID,
						a.ProductID,
						a.VehicleID,
						a.DealID,
						a.FeederProductID,
						a.FeederVehicleID,
						a.FeederInvestorID,
						max(a.Pct)
				from	#lcsfAdapterIAP a
				group by a.InvestorID,a.ProductID,a.VehicleID,a.DealID,
							a.FeederProductID,a.FeederVehicleID,a.FeederInvestorID
			)
			update	a
			set		InvestorAllcPct		= isnull(b.Pct,0)
			from	#tmpFeederDtl a			
					left join ipvd_feeders b
						on	a.pei_invstr_id_c		= b.InvestorID
						and a.pei_invst_fnd_id_c	= b.ProductID
						and a.pei_vhcl_id_c			= b.VehicleID
						and a.pei_deal_id_c			= b.DealID
						and a.FeederFundID			= b.FeederProductID
						and a.FeederVhclID			= b.FeederVehicleID
						and a.FeederInvestorID		= b.FeederInvestorID
			where	a.HasFeeder	= 'Y';
			-------------------------------------------------------------
			update	#tmpFeederDtl
			set		InvestorAllcPct	= CmtmtPctMlt/100
			where	HasFeeder = 'N';			
		end	
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_SPV_Adapter_Investor_AllcPercent to PE_datawriter, PE_datareader
GO