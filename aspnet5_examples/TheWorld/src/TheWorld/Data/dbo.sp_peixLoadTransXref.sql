create procedure dbo.sp_peixLoadTransXref
@User	varchar(16) = 'system'
as
	set nocount on;
	set xact_abort on;
begin
begin try
	create table #ParentChildTransType
	(
		ParentTransMember int,
		ChildTransmember int,
		TransTypeID int
	);
	----------------------------------------------
	create table #ParentChild
	(
		ParentWorkID int,
		ChildWorkID int
	);
	----------------------------------------------
	create table #WeightsBasedOnRollup
	(
		pei_involvmt_typ_id_c   int,
		pei_rollup_col_i	int
	);
	----------------------------------------------
	create table #trans_xref
	(
		InvolvementID		int,
		TransactionTypeID	int,
		TransactionWT		decimal(5,0)
	)	
/*============================================================================================================ */
	declare	@InvolvmtID	int;
	declare @RollupID	int;
	declare @SQL		varchar(max);
	declare @TrCount	float;
	declare @Row0Count  float;
	declare @RunDate	datetime;
	-----------------------------
	set @RunDate = getdate();

	--- test code only begin
	--declare @a int;
	--declare @b int;
	--select @a=0,
	--       @b = 1
	--select @b/@a
	-- test code only end
/*============================================================================================================ */
	update 	pei_involvmt_typ_ref
	set 	pei_rollup_col_i	= b.RollUpMap,
			user_nt_id_updt_c	= @User,
			stamp_updt_dz		= getdate()
	from 	pei_involvmt_typ_ref a
			inner join Hie_TransMembers b
				on a.pei_investran_hie_trans_mem_n = b.Name
	where 	a.pei_investran_hei_typ_i = 'T';
	----------------------------------------------
	insert into  #ParentChild(
			ParentWorkID,
			ChildWorkID)
	select 	b.ID,
			b.ID
	from 	pei_involvmt_typ_ref 	   a
	       	inner join Hie_TransMembers b
				on a.pei_investran_hie_trans_mem_n = b.Name
	where 	a.pei_investran_hie_trans_mem_n is not null
	  		and a.pei_investran_hei_typ_i = 'T';
	----------------------------------------------
	while (1=1) 
 	begin
		insert into #ParentChildTransType(
				ParentTransMember,
				ChildTransmember,
				TransTypeID)
		select	a.ParentWorkID,
				b.ChildID,
				LinkID
		from	#ParentChild a
				inner join Hie_TransRelations b
					on a.ChildWorkID = b.ParentID
				inner join Hie_TransMembers c
					on c.ID = b.ChildID		
		----------------------------------------------
		truncate table #ParentChild;
		----------------------------------------------	
		insert into  #ParentChild(
				ParentWorkID,
				ChildWorkID)
		select	ParentTransMember,
				ChildTransmember
		from	#ParentChildTransType
		where	TransTypeID is null;
		----------------------------------------------
		if not exists(select 1 from #ParentChildTransType where TransTypeID is null)break;
		----------------------------------------------
     	delete #ParentChildTransType where TransTypeID is null;
	end	
/*============================================================================================================ */	
	insert into #trans_xref(
			InvolvementID,
			TransactionTypeID)
	select	distinct
			a.pei_involvmt_typ_id_c,
			d.pei_trans_typ_id_c 
	from	pei_involvmt_typ_ref a
			inner join Hie_TransMembers	b
				on b.Name = a.pei_investran_hie_trans_mem_n
			inner join #ParentChildTransType c
				on c.ParentTransMember = b.ID
			inner join pei_trans_typ_ref d
				on d.pei_investran_trans_typ_id_c = c.TransTypeID
	where	a.pei_investran_hei_typ_i	= 'T'
			and d.pei_origin_i			= 'FOF';
	----------------------------------------------
	insert into #WeightsBasedOnRollup(
			pei_involvmt_typ_id_c,
			pei_rollup_col_i)
	select	pei_involvmt_typ_id_c,
			pei_rollup_col_i
	from	pei_involvmt_typ_ref
	where	pei_rollup_col_i is not null
			and pei_investran_hei_typ_i = 'T'
	order by pei_involvmt_typ_id_c;				
/*============================================================================================================ */	
	set rowcount 1;

	while (1=1)
	begin
		select	@InvolvmtId = pei_involvmt_typ_id_c,
				@RollupId = pei_rollup_col_i
		from	#WeightsBasedOnRollup;
		---------------------------------------
		if @@rowcount = 0 break;
		---------------------------------------
		set rowcount 0;

		select @Sql = '	update	#trans_xref	
						set		TransactionWT = H.[' + convert(varchar(20),@RollupID) + ']		
		                from	pei_trans_typ_ref R
								inner join Hie_TransRollupWeights H
									on R.pei_investran_trans_typ_id_c = H.LinkID
		                where	R.pei_origin_i = ''' + 'FOF' + '''
								and #trans_xref.TransactionTypeID = R.pei_trans_typ_id_c
								and #trans_xref.InvolvementID = ' + convert(varchar(20),@InvolvmtID);
		---------------------------------------
		exec (@Sql);
		---------------------------------------
		set rowcount 1;
		---------------------------------------
		delete #WeightsBasedOnRollup where pei_involvmt_typ_id_c = @InvolvmtId  and pei_rollup_col_i = @RollupId
	end;
	---------------------------------------
	set rowcount 0;
/*============================================================================================================ */
	set @TrCount = (select count(*) from #trans_xref);	
	
	set @Row0Count = (	select	count(*)
						from	#trans_xref
						where	isnull(TransactionWT,0) = 0);

	---- test code begin
	--set @Row0Count = 0.3 * @TrCount
	---- test code end
/*============================================================================================================ */
	if @TrCount = 0 or (@Row0Count/@TrCount*100) > 19
	begin
		exec dbo.sp_peixCreateWebReportRequest  @UserId		= 5240,
												@RptTitle	= 'Sync Process - Load Transaction XREF Error',
												@SPName		= '',
												@SendTo		= 'sdprvtmktfundcentralsystems@gcmlp.com',
												@SendCc		= '',
												@TimeStamp  = @RunDate,
												@Status		= 'Waiting',
												@Message	= 'Sync Process - Load Transaction XREF Error',
												@Attachment	= 'N',
												@HtmlFormat = 'N',
												@Subject	= 'Sync Process - Load Transaction XREF Error',
												@SendBcc	= null,
												@OutMessage	= 'N',
												@ExcelName	= null;		
		return;
	end
/*============================================================================================================ */
	begin transaction;
		delete	pei_trans_typ_xref 
		from	pei_trans_typ_xref a
		where	a.pei_involvmt_typ_id_c in (
					select	involvmt.pei_involvmt_typ_id_c
					from	pei_involvmt_typ_ref involvmt
					where	involvmt.pei_investran_hei_typ_i = 'T');
		-------------------------------------
		insert into pei_trans_typ_xref (
				pei_involvmt_typ_id_c,
				pei_trans_typ_id_c,
				pei_trans_wt_m,
				user_nt_id_add_c,
				stamp_add_dz,
				user_nt_id_updt_c ,
				stamp_updt_dz)		
		select	a.InvolvementID,
				a.TransactionTypeID,
				a.TransactionWT,
				@User,
				@RunDate,
				@User,
				@RunDate
		from	#trans_xref a
		where	not exists(	select	1
							from	pei_trans_typ_xref b
							where	a.InvolvementID = b.pei_involvmt_typ_id_c
									and a.TransactionTypeID = b.pei_trans_typ_id_c);
					
	commit transaction;	
	-------------------------------------------
	truncate table #trans_xref;
/*============================================================================================================ */	
	exec dbo.sp_peixLoadAcctTransXref @User;
end try	
begin catch
	declare @ErrorMessage	varchar(4000);
	declare @ErrorSeverity	int;
	declare @ErrorState		int;
	
	--if @@trancount > 0 rollback transaction;	
	if (xact_state()) = -1 rollback transaction;
	if (xact_state()) = 1 commit transaction;

	set @ErrorSeverity	= isnull(error_severity(),15)
	set @ErrorState		= isnull(error_state(),0)
	set @ErrorMessage	= error_message();	
	raiserror(@ErrorMessage,@ErrorSeverity,@ErrorState);
end catch	
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sp_peixLoadTransXref] TO [PE_datareader]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sp_peixLoadTransXref] TO [PE_datawriter]
    AS [dbo];

