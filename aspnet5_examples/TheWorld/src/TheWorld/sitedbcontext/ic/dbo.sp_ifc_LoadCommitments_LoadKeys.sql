create procedure [dbo].[sp_ifc_LoadCommitments_LoadKeys]
@ProcessType		int = 0, -- 0 - Direct / 1 - SPV / 2 - FOF
@RunType			int = 1, -- 1 - Product / 2 - Deal
@Iteration			int	= 1,
@Keys				tvp_allc_key readonly,
@MaxLevel			int = 32
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
	-------------------------------------------------------------------	
	create table #lcsfStatus	(StatusID int, AdjTypeID char(1));		
	create unique clustered index LCSF_TRANS_SATUS_ADJ_TYPE_UCIDX on #lcsfStatus(StatusID,AdjTypeID);	
	*/
/* ================================================================================*/
	if @RunType = 1
	begin
		insert into #lcsfCmtmKeys(
				Iteration,
				RowKey,
				RowType,
				ProductID,
				DealID,
				LECurrencyID,
				LocalCurrencyID)
		select	distinct			
				@Iteration,			
				a.pei_adj_id_c,
				a.pei_adj_typ_i,
				a.pei_invst_fnd_id_c,
				a.pei_deal_id_c,
				a.pei_le_cur_id_c,
				a.pei_loc_cur_id_c
		from	pei_adj_pvidat_xref a
				inner join @Keys b
					on a.pei_invst_fnd_id_c		= b.ProductID
				inner join #lcsfStatus c
					on a.pei_trans_status_id_c	= c.StatusID
					and a.pei_adj_typ_i			= c.AdjTypeID
		where	a.pei_row_type = 1;
	end
	------------------------------------------------------
	if @RunType = 2
	begin
		insert into #lcsfCmtmKeys(
				Iteration,
				RowKey,				
				RowType,
				ProductID,
				DealID,
				LECurrencyID,
				LocalCurrencyID)
		select	distinct			
				@Iteration,			
				a.pei_adj_id_c,
				a.pei_adj_typ_i,
				a.pei_invst_fnd_id_c,
				a.pei_deal_id_c,
				a.pei_le_cur_id_c,
				a.pei_loc_cur_id_c
		from	pei_adj_pvidat_xref a
				inner join @Keys b
					on a.pei_invst_fnd_id_c		= b.ProductID
					and a.pei_deal_id_c			= b.DealID
				inner join #lcsfStatus c
					on a.pei_trans_status_id_c	= c.StatusID
					and a.pei_adj_typ_i			= c.AdjTypeID
		where	a.pei_row_type = 1;
	end		
/* ================================================================================*/
	if @ProcessType <> 0
	begin
		declare @Keys1 tvp_allc_key;
		---------------------------------------------
		if @RunType = 1
		begin
			insert into @Keys1(ProductID)
			select	distinct
					b.pei_deal_invst_fnd_id_c
			from	#lcsfCmtmKeys a
					inner join pei_deal_ref b
						on a.DealID = b.pei_deal_id_c
			where	a.Iteration = @Iteration
					and b.pei_deal_invst_fnd_id_c is not null
					and not exists(	select	1
									from	#lcsfCmtmKeys d
									where	b.pei_deal_invst_fnd_id_c = d.ProductID);
		end
		---------------------------------------------
		if @RunType = 2
		begin	
			insert into @Keys1(ProductID,DealID)
			select	distinct
					c.pei_invst_fnd_id_c,
					c.pei_deal_id_c
			from	#lcsfCmtmKeys a
					inner join pei_deal_ref b
						on a.ProductID = b.pei_deal_invst_fnd_id_c
					inner join pei_invst_fnd_deal_xref c
						on b.pei_deal_id_c = c.pei_deal_id_c	
			where	a.Iteration = @Iteration					
					and not exists(	select	1
									from	#lcsfCmtmKeys d
									where	d.ProductID		= c.pei_invst_fnd_id_c
											and d.DealID	= c.pei_deal_id_c);
		end		
		---------------------------------------------
		if (select count(*) from @Keys1) > 0
		begin
			set @Iteration = @Iteration + 1;
			if @Iteration > @MaxLevel return;
			---------------------------------
			exec dbo.sp_ifc_LoadCommitments_LoadKeys
			@ProcessType		= @ProcessType,
			@RunType			= @RunType,
			@Iteration			= @Iteration,						
			@Keys				= @Keys1,
			@MaxLevel			= @MaxLevel;
		end
	end			
end
GO
grant execute on dbo.sp_ifc_LoadCommitments_LoadKeys to PE_datawriter, PE_datareader
GO
		