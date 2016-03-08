create procedure [dbo].[sp_fc_LoadCommitments_LoadData_PD]
@ReportDate			datetime,
@CutOffStatement	datetime = null,
@CurrencyID 		char(3),
@MultCurrency		char(1),
@MultCurrencyManual	char(1)
as
	set nocount on;
begin
	create table #lcsfTransType	(TransTypeID int, WTM decimal(5,0));
	create unique clustered index LCLDPD_TRANS_TYPE_ID_UCIDX on #lcsfTransType(TransTypeID);
	-----------------------------------------------------------
	create table #lcsfBatchExclude(BatchID int)
	create unique clustered index LCLDPD_BTCH_EXLD_BACTH_ID_UCIDX on #lcsfBatchExclude(BatchID);
	-----------------------------------------------------------
	create table #lcsfPDKeys
	(
		DealID		int,
		ProductID	int,		
		VehicleID	int,
		InvestorID	int			
	);
	create unique clustered index LCLDPD_DPVI_ID_UCIDX	on #lcsfPDKeys(DealID,ProductID,VehicleID,InvestorID);
	---------------------------------------------------------------------------	
	create table #lcsfRateDates
	(
		TransDate	datetime,	
		CurrencyID	char(3),
		RateDate	datetime
	)
	create unique clustered index LCLDPD_RATE_DATES_CURR_ID_TRDT_UCIDX on #lcsfRateDates(CurrencyID,TransDate);	
	---------------------------------------------------------------------------
	create table #lcsfCurrencyRatesA
	(
		TransDate		datetime,
		RateDate		datetime,
		CurrencyID		char(3),
		CurrencyRate	float
	)
	create unique clustered index LCLDPD_CURRENCY_RATESA_TRDT_CURR_ID_UCIDX on #lcsfCurrencyRatesA (TransDate,CurrencyID);	
	---------------------------------------------------------------------------
	create table #lcsfCurrencyRatesB
	(
		TransDate		datetime,
		CurrencyID		char(3),
		CurrencyRate	float,
		USDRate			float,
		EURRate			float,
		AUDRate			float,
		GBPRate			float,
		CADRate			float,
		ZARRate			float,
		SEKRate			float,
		CHFRate			float,  
		NOKRate			float,
		JPYRate			float,
		INRRate			float, 
		PLNRate			float,
		BRLRate			float,
		KWDRate			float,
		SGDRate			float,
		SARRate			float,
		DKKRate			float,
		KRWRate			float,
		IDRRate			float,
		YERRate			float
	)
	create unique clustered index LCLDPD_CURRENCY_RATESB_TRDT_CURR_ID_UCIDX on #lcsfCurrencyRatesB (TransDate,CurrencyID);		
	---------------------------------------------------------------------------
	declare @TransCurrencyID char(3);
	
	set @TransCurrencyID = dbo.fnManualOriginalCurrency(@CurrencyID,2); 
/* ========================================================================================= */
	insert into #lcsfTransType
	select	pei_trans_typ_id_c,
			pei_trans_wt_m
	from	pei_trans_typ_xref
	where	pei_involvmt_typ_id_c = 40;
	-----------------------------------------------------------	
	delete #lcsfStatus where AdjTypeID <> 'C';
/* ========================================================================================= */	
	insert into #lcsfPDKeys(
			DealID,
			ProductID,
			VehicleID,
			InvestorID)
	select	distinct
			a.DealID,
			a.ProductID,
			a.VehicleID,
			a.InvestorID
	from	#lcsfMasterLoad a;
/* ========================================================================================= */	
	if @CutOffStatement is null
	begin
		insert into #lcsfMasterLoad(
				ProductID,
				VehicleID,
				InvestorID,
				DealID,
				EffectiveDate,
				TransTypeID,
				TransStatusID,
				CurrencyID,
				CmtmtAmount,
				MltCurrencyID,
				MultCurrency,
				MultCurrencyManual,
				MltCmtmtAmount,
				RowType,
				BatchID,
				PostDate,
				TransactionID,
				LECurrencyID,
				LEAmount,
				LocCurrencyID,
				LocAmount)
		select	a.pei_invst_fnd_id_c,
				a.pei_vhcl_id_c,			
				a.pei_invstr_id_c,
				a.pei_deal_id_c,
				a.pei_eff_trans_d,
				a.pei_trans_typ_id_c,
				a.pei_trans_status_id_c,
				@TransCurrencyID,
				(case 
						when a.le_cur_id_c	= @TransCurrencyID then a.pei_le_alloc_amt_m
						when a.loc_cur_id_c = @TransCurrencyID and a.pei_le_alloc_amt_m <> a.pei_loc_alloc_amt_m then a.pei_loc_alloc_amt_m					
				end) * c.WTM,
				case @MultCurrency
					when 'P' then a.le_cur_id_c
					when 'D' then a.loc_cur_id_c
				end,
				@MultCurrency,
				@MultCurrencyManual,
				(case
					when @MultCurrency = 'P' then a.pei_le_alloc_amt_m
					when @MultCurrency = 'D' then a.pei_loc_alloc_amt_m
				end) * c.WTM,
				'P',
				a.pei_batch_id_c,
				a.pei_investran_post_dz,
				a.pei_investran_trans_id_c,
				a.le_cur_id_c,
				pei_le_alloc_amt_m * c.WTM,
				a.loc_cur_id_c,
				a.pei_loc_alloc_amt_m * c.WTM
		from	pei_allc_data a
				inner join #lcsfPDKeys b
					on a.pei_deal_id_c			= b.DealID
					and a.pei_invst_fnd_id_c	= b.ProductID
					and a.pei_vhcl_id_c			= b.VehicleID
					and a.pei_invstr_id_c		= b.InvestorID
				inner join #lcsfTransType c
					on a.pei_trans_typ_id_c		= c.TransTypeID		
				inner join #lcsfStatus d
					on a.pei_trans_status_id_c	= d.StatusID
		where	a.pei_eff_trans_d <= @ReportDate			
	end
/* ========================================================================================= */	
	if @CutOffStatement is not null
	begin
		insert into #lcsfBatchExclude(BatchID)
		select	distinct
				a.pei_batch_id_c
		from	DTS_BatchExclude a	
		where	a.EffectiveDate > @CutOffStatement
				and not exists(	select	1
								from	ifc_rpt_trans_xref b
								where	a.pei_batch_id_c		= b.pei_batch_id_c
										and b.ifc_qt_signoff_dz	= @CutOffStatement)	
		----------------------------------------------------------------------								
		insert into #lcsfMasterLoad(
				ProductID,
				VehicleID,
				InvestorID,
				DealID,
				EffectiveDate,
				TransTypeID,
				TransStatusID,
				CurrencyID,
				CmtmtAmount,
				MltCurrencyID,
				MultCurrency,
				MultCurrencyManual,
				MltCmtmtAmount,
				RowType,
				BatchID,
				PostDate,
				TransactionID,
				LECurrencyID,
				LEAmount,
				LocCurrencyID,
				LocAmount)
		select	a.pei_invst_fnd_id_c,
				a.pei_vhcl_id_c,			
				a.pei_invstr_id_c,
				a.pei_deal_id_c,
				a.pei_eff_trans_d,
				a.pei_trans_typ_id_c,
				a.pei_trans_status_id_c,
				@TransCurrencyID,
				(case 
						when a.le_cur_id_c	= @TransCurrencyID then a.pei_le_alloc_amt_m
						when a.loc_cur_id_c = @TransCurrencyID and a.pei_le_alloc_amt_m <> a.pei_loc_alloc_amt_m then a.pei_loc_alloc_amt_m					
				end) * c.WTM,
				case @MultCurrency
					when 'P' then a.le_cur_id_c
					when 'D' then a.loc_cur_id_c
				end,
				@MultCurrency,
				@MultCurrencyManual,
				(case
					when @MultCurrency = 'P' then a.pei_le_alloc_amt_m
					when @MultCurrency = 'D' then a.pei_loc_alloc_amt_m
				end) * c.WTM,
				'P',
				a.pei_batch_id_c,
				a.pei_investran_post_dz,
				a.pei_investran_trans_id_c,
				a.le_cur_id_c,
				pei_le_alloc_amt_m * c.WTM,
				a.loc_cur_id_c,
				a.pei_loc_alloc_amt_m * c.WTM
		from	pei_allc_data a
				inner join #lcsfPDKeys b
					on a.pei_deal_id_c			= b.DealID
					and a.pei_invst_fnd_id_c	= b.ProductID
					and a.pei_vhcl_id_c			= b.VehicleID
					and a.pei_invstr_id_c		= b.InvestorID
				inner join #lcsfTransType c
					on a.pei_trans_typ_id_c		= c.TransTypeID		
				inner join #lcsfStatus d
					on a.pei_trans_status_id_c	= d.StatusID
				inner join #dtsProductPostedDate dts
						on a.pei_invst_fnd_id_c = dts.ProductID						
		where	a.pei_eff_trans_d <= @ReportDate
				and not exists(select 1 from #lcsfBatchExclude eb where a.pei_batch_id_c = eb.BatchID)
				and (dts.InvestranPostDate is null
					or a.pei_investran_post_dz <= dts.InvestranPostDate
					or exists(	select 	1
								from 	ifc_rpt_trans_xref e
								where 	e.pei_invst_fnd_id_c	= a.pei_invst_fnd_id_c
										and e.pei_batch_id_c	= a.pei_batch_id_c
										and e.ifc_qt_signoff_dz	= @CutOffStatement));
	end			
/* ========================================================================================= */	
	truncate table #lcsfPDKeys;	
	truncate table #lcsfTransType;
	truncate table #lcsfBatchExclude;
	drop table 	#lcsfPDKeys;		
	drop table #lcsfTransType;
	drop table #lcsfBatchExclude;
/* ============================================================================================================== */
	insert into #lcsfRateDates(TransDate,CurrencyID)
	select	distinct
			a.EffectiveDate,
			b.cur_id_c
	from	#lcsfMasterLoad a,
			pei_cur_ref b
	where	b.pei_cur_used_i = 'Y'
			and a.RowType = 'P';
/* ============================================================================================================== */
	with fxmd(CurrencyID,TransDate,RateDate) as
	(
		select	a.CurrencyID,
				a.TransDate,					
				max(b.pei_fx_rte_ef_d)
		from	#lcsfRateDates a
				inner join pei_cur_fx_ref b
					on a.CurrencyID = b.cur_id_c
		where	a.TransDate	>= b.pei_fx_rte_ef_d
				and b.pei_cur_fx_p <> 0
		group by a.CurrencyID,a.TransDate
	)		
	update	#lcsfRateDates
	set		RateDate = b.RateDate		
	from	#lcsfRateDates a
			inner join fxmd b
				on a.CurrencyID = b.CurrencyID
				and a.TransDate	= b.TransDate;				
/* ============================================================================================================== */
	insert into #lcsfCurrencyRatesA(
			TransDate,
			RateDate,
			CurrencyID,
			CurrencyRate)
	select	a.TransDate,
			a.RateDate,
			a.CurrencyID,
			b.pei_cur_fx_p
	from	#lcsfRateDates  a
			inner join pei_cur_fx_ref b
				on	a.CurrencyID	= b.cur_id_c
				and a.RateDate		= b.pei_fx_rte_ef_d;	
/* ============================================================================================================== */
	insert into #lcsfCurrencyRatesB(
			TransDate,
			CurrencyID,
			CurrencyRate,
			USDRate,EURRate,AUDRate,GBPRate,CADRate,
			ZARRate,SEKRate,CHFRate,NOKRate,JPYRate,
			INRRate,PLNRate,BRLRate,KWDRate,SGDRate,
			SARRate,DKKRate,KRWRate,IDRRate,YERRate)
	select	distinct
			a.TransDate,		
			a.CurrencyID,		
			isnull(a.CurrencyRate,0),
			isnull(b.CurrencyRate / a.CurrencyRate,0),
			isnull(c.CurrencyRate / a.CurrencyRate,0),
			isnull(d.CurrencyRate / a.CurrencyRate,0),
			isnull(e.CurrencyRate / a.CurrencyRate,0),
			isnull(f.CurrencyRate / a.CurrencyRate,0),
			isnull(g.CurrencyRate / a.CurrencyRate,0),
			isnull(h.CurrencyRate / a.CurrencyRate,0),
			isnull(i.CurrencyRate / a.CurrencyRate,0),
			isnull(j.CurrencyRate / a.CurrencyRate,0),
			isnull(k.CurrencyRate / a.CurrencyRate,0), 		
			isnull(l.CurrencyRate / a.CurrencyRate,0),
			isnull(m.CurrencyRate / a.CurrencyRate,0),
			isnull(n.CurrencyRate / a.CurrencyRate,0),
			isnull(o.CurrencyRate / a.CurrencyRate,0),			
			isnull(p.CurrencyRate / a.CurrencyRate,0),
			isnull(r.CurrencyRate / a.CurrencyRate,0),
			isnull(s.CurrencyRate / a.CurrencyRate,0),
			isnull(t.CurrencyRate / a.CurrencyRate,0),
			isnull(u.CurrencyRate / a.CurrencyRate,0),
			isnull(v.CurrencyRate / a.CurrencyRate,0)
	from	#lcsfCurrencyRatesA a
			left join #lcsfCurrencyRatesA b
				on a.TransDate = b.TransDate and b.CurrencyID = 'USD'
			left join #lcsfCurrencyRatesA c
				on a.TransDate = c.TransDate and c.CurrencyID = 'EUR'
			left join #lcsfCurrencyRatesA d
				on a.TransDate = d.TransDate and d.CurrencyID = 'AUD'
			left join #lcsfCurrencyRatesA e
				on a.TransDate = e.TransDate and e.CurrencyID = 'GBP'
			left join #lcsfCurrencyRatesA f
				on a.TransDate = f.TransDate and f.CurrencyID = 'CAD'
			left join #lcsfCurrencyRatesA g
				on a.TransDate = g.TransDate and g.CurrencyID = 'ZAR'
			left join #lcsfCurrencyRatesA h
				on a.TransDate = h.TransDate and h.CurrencyID = 'SEK'
			left join #lcsfCurrencyRatesA i
				on a.TransDate = i.TransDate and i.CurrencyID = 'CHF'
			left join #lcsfCurrencyRatesA j
				on a.TransDate = j.TransDate and j.CurrencyID = 'NOK'
			left join #lcsfCurrencyRatesA k
				on a.TransDate = k.TransDate and k.CurrencyID = 'JPY'
			left join #lcsfCurrencyRatesA l
				on a.TransDate = l.TransDate and l.CurrencyID = 'INR'
			left join #lcsfCurrencyRatesA m
				on a.TransDate = m.TransDate and m.CurrencyID = 'PLN'
			left join #lcsfCurrencyRatesA n
				on a.TransDate = n.TransDate and n.CurrencyID = 'BRL'
			left join #lcsfCurrencyRatesA o
				on a.TransDate = o.TransDate and o.CurrencyID = 'KWD'
			left join #lcsfCurrencyRatesA p
				on a.TransDate = p.TransDate and p.CurrencyID = 'SGD'	
			left join #lcsfCurrencyRatesA r
				on a.TransDate = r.TransDate and r.CurrencyID = 'SAR'	
			left join #lcsfCurrencyRatesA s
				on a.TransDate = s.TransDate and s.CurrencyID = 'DKK'
			left join #lcsfCurrencyRatesA t
				on a.TransDate = t.TransDate and t.CurrencyID = 'KRW'
			left join #lcsfCurrencyRatesA u
				on a.TransDate = u.TransDate and u.CurrencyID = 'IDR'
			left join #lcsfCurrencyRatesA v
				on a.TransDate = v.TransDate and v.CurrencyID = 'YER';			
/* ============================================================================================================== */
	update	#lcsfMasterLoad
	set		CmtmtAmount = isnull(a.LEAmount * (c.CurrencyRate/b.CurrencyRate),0) 
	from	#lcsfMasterLoad a
			inner join #lcsfCurrencyRatesA b
				on a.EffectiveDate	= b.TransDate
				and a.LECurrencyID	= b.CurrencyID	
			inner join #lcsfCurrencyRatesA c
				on a.EffectiveDate	= c.TransDate
				and a.CurrencyID	= c.CurrencyID					
	where	a.RowType = 'P'
			and a.CmtmtAmount is null;			
/* ============================================================================================================== */
	update	#lcsfMasterLoad
	set		pei_amt_m_USD	=
						case    
							when a.LocCurrencyID = 'USD'	then a.LocAmount        
							when a.LECurrencyID  = 'USD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.USDRate,0)  
						end,
			pei_amt_m_USD_man = 
						case    
							when a.LocCurrencyID = 'USD'	then a.LocAmount        
							when a.LECurrencyID  = 'USD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.USDRate,0)  
						end,
						  
			pei_amt_m_EUR  =
						case    
							when a.LocCurrencyID = 'EUR'	then a.LocAmount        
							when a.LECurrencyID  = 'EUR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.EURRate,0)  
						end,  	
			pei_amt_m_EUR_man =
						case    
							when a.LocCurrencyID = 'EUR'	then a.LocAmount        
							when a.LECurrencyID  = 'EUR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.EURRate,0)  
						end,  										
						
						  
			pei_amt_m_AUD  =
						case    
							when a.LocCurrencyID = 'AUD'	then a.LocAmount        
							when a.LECurrencyID  = 'AUD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.AUDRate,0)  
						end,  	  
			pei_amt_m_GBP  =
						case    
							when a.LocCurrencyID = 'GBP'	then a.LocAmount        
							when a.LECurrencyID  = 'GBP'	then a.LEAmount  								
							else isnull(a.LEAmount * b.GBPRate,0)  
						end,
			pei_amt_m_GBP_man =
						case    
							when a.LocCurrencyID = 'GBP'	then a.LocAmount        
							when a.LECurrencyID  = 'GBP'	then a.LEAmount  								
							else isnull(a.LEAmount * b.GBPRate,0)  
						end,						
						  
			pei_amt_m_CAD  =
						case    
							when a.LocCurrencyID = 'CAD'	then a.LocAmount        
							when a.LECurrencyID  = 'CAD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.CADRate,0)  
						end,
			pei_amt_m_CAD_man =
						case    
							when a.LocCurrencyID = 'CAD'	then a.LocAmount        
							when a.LECurrencyID  = 'CAD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.CADRate,0)  
						end,						
						  
			pei_amt_m_ZAR  =
						case    
							when a.LocCurrencyID = 'ZAR'	then a.LocAmount        
							when a.LECurrencyID  = 'ZAR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.ZARRate,0)  
						end,  
			pei_amt_m_SEK  =
						case    
							when a.LocCurrencyID = 'SEK'	then a.LocAmount        
							when a.LECurrencyID  = 'SEK'	then a.LEAmount  								
							else isnull(a.LEAmount * b.SEKRate,0)  
						end,  
			pei_amt_m_CHF  =
						case    
							when a.LocCurrencyID = 'CHF'	then a.LocAmount        
							when a.LECurrencyID  = 'CHF'	then a.LEAmount  								
							else isnull(a.LEAmount * b.CHFRate,0)  
						end,
			pei_amt_m_CHF_man = 
						case    
							when a.LocCurrencyID = 'CHF'	then a.LocAmount        
							when a.LECurrencyID  = 'CHF'	then a.LEAmount  								
							else isnull(a.LEAmount * b.CHFRate,0)  
						end,									
						
			pei_amt_m_NOK  =
						case    
							when a.LocCurrencyID = 'NOK'	then a.LocAmount        
							when a.LECurrencyID  = 'NOK'	then a.LEAmount  								
							else isnull(a.LEAmount * b.NOKRate,0)  
						end,  
			pei_amt_m_JPY  =
						case    
							when a.LocCurrencyID = 'JPY'	then a.LocAmount        
							when a.LECurrencyID  = 'JPY'	then a.LEAmount  								
							else isnull(a.LEAmount * b.JPYRate,0)  
						end,  
			pei_amt_m_INR =
						case    
							when a.LocCurrencyID = 'INR'	then a.LocAmount        
							when a.LECurrencyID  = 'INR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.INRRate,0)  
						end,
			pei_amt_m_PLN =
						case    
							when a.LocCurrencyID = 'PLN'	then a.LocAmount        
							when a.LECurrencyID  = 'PLN'	then a.LEAmount  								
							else isnull(a.LEAmount * b.PLNRate,0)  
						end,
			pei_amt_m_BRL =
						case    
							when a.LocCurrencyID = 'BRL'	then a.LocAmount        
							when a.LECurrencyID  = 'BRL'	then a.LEAmount  								
							else isnull(a.LEAmount * b.BRLRate,0)  
						end,
			pei_amt_m_KWD =
						case    
							when a.LocCurrencyID = 'KWD'	then a.LocAmount        
							when a.LECurrencyID  = 'KWD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.KWDRate,0)  
						end,
			pei_amt_m_SGD =
						case    
							when a.LocCurrencyID = 'SGD'	then a.LocAmount        
							when a.LECurrencyID  = 'SGD'	then a.LEAmount  								
							else isnull(a.LEAmount * b.SGDRate,0)  
						end,
			pei_amt_m_SAR =
						case    
							when a.LocCurrencyID = 'SAR'	then a.LocAmount        
							when a.LECurrencyID  = 'SAR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.SARRate,0)  
						end,
			pei_amt_m_DKK =
						case    
							when a.LocCurrencyID = 'DKK'	then a.LocAmount        
							when a.LECurrencyID  = 'DKK'	then a.LEAmount  								
							else isnull(a.LEAmount * b.DKKRate,0)  
						end,
			pei_amt_m_KRW =
						case    
							when a.LocCurrencyID = 'KRW'	then a.LocAmount        
							when a.LECurrencyID  = 'KRW'	then a.LEAmount  								
							else isnull(a.LEAmount * b.KRWRate,0)  
						end,
			pei_amt_m_KRW_man = 
						case    
							when a.LocCurrencyID = 'KRW'	then a.LocAmount
							when a.LECurrencyID  = 'KRW'	then a.LEAmount  								
							else isnull(a.LEAmount * b.KRWRate,0)  
						end,						
						
			pei_amt_m_IDR =
						case    
							when a.LocCurrencyID = 'IDR'	then a.LocAmount        
							when a.LECurrencyID  = 'IDR'	then a.LEAmount  								
							else isnull(a.LEAmount * b.IDRRate,0)  
						end,
			pei_amt_m_YER =
						case    
							when a.LocCurrencyID = 'YER'	then a.LocAmount        
							when a.LECurrencyID  = 'YER'	then a.LEAmount  								
							else isnull(a.LEAmount * b.YERRate,0)  
						end																																										
	from	#lcsfMasterLoad a
			inner join #lcsfCurrencyRatesB b
				on a.EffectiveDate	= b.TransDate
				and a.LECurrencyID	= b.CurrencyID
	where	a.RowType = 'P';				
/* ============================================================================================================== */	
	truncate table #lcsfCurrencyRatesA;		
	truncate table #lcsfCurrencyRatesB;
	truncate table #lcsfRateDates;
	drop table #lcsfCurrencyRatesA;		
	drop table #lcsfCurrencyRatesB;
	drop table #lcsfRateDates;
end
GO
grant execute on dbo.sp_fc_LoadCommitments_LoadData_PD to PE_datawriter, PE_datareader
GO	