;-----------------------------------------------------------------------------------------------------------------------
;+
; NAME:
; SENSITIVITY_AUTO_DP
;
; SouthTRAC ECD: automatization: get rR for all flights for sensitivity studies
; Platform: IAU_DataProc
;
; AUTHOR: Thomas Wagenhäuser
;-
;------------------------------------------------------------------------------------------------------------------------

@dp_def_common
;------------------------------------------------------------------------------------------------------------------------
PRO SENSITIVITY_AUTO_DP


  COMMON DP_DATA
  COMMON DP_WIDID

  dp_def_common, '1.29' ; string == version

  path_wd = 'D:\'

  error_handler_IO = 0


  chrompath = 
  expinfopath = 
;load chrom ;from dp_wid_main_handle
;    'restore_chrom' : $
;        IF SIZE(dp_chrom, /TYPE) EQ 11 THEN BEGIN ; dp_chrom is already a LIST, i.e. data was loaded before
;          quest=DIALOG_MESSAGE('Loaded data found. Replace?', /QUESTION, /DEFAULT_NO, $
;                               DIALOG_PARENT=dp_widid.dp_mainwid)
;          IF quest EQ 'No' THEN RETURN
;        ENDIF

  dp_chrom = dp_restore_chrom(dp_chrom, dp_vers, PATH=path_wd, VERBOSE=verbose)
  dp_chrom = dp_correct_time(dp_chrom, VERBOSE=verbose, /LOUD) ; correct for "jumps" in Chemstation cdf timestamps
  dp_expcfg = !NULL


;from config_dp_mainwid        
  IF SIZE(dp_chrom, /TYPE) EQ 11 THEN BEGIN
    chromlist=[]
    FOR i=0, N_ELEMENTS(dp_chrom)-1 DO BEGIN
      chromlist=[chromlist, ((dp_chrom[i]).exp_fname)[0]]
      IF i EQ 0 THEN substlist=LIST(((dp_chrom[0]).subst.name)[*,0]) $
      ELSE substlist.add, ((dp_chrom[i]).subst.name)[*,0]
    ENDFOR
  ENDIF ELSE chromlist=''
  IF SIZE(dp_chrom, /TYPE) EQ 11 THEN BEGIN
    instr_type=((dp_chrom[0]).instr_type)[0]
        
    ;******************************************************************************************
;    load expinfo ;from dp_wid_main_handle

  del_results=0
;        IF SIZE(dp_expcfg, /TYPE) EQ 11 THEN BEGIN ; dp_expcfg is already a LIST, i.e. data was loaded before
;          quest=DIALOG_MESSAGE('Loaded ExpInfo found. Replace? Previous Results will be deleted...', $
;                                /QUESTION, /DEFAULT_NO, DIALOG_PARENT=dp_widid.dp_mainwid)
;          IF quest EQ 'Yes' THEN BEGIN
;            del_results=1
;            dp_destroy_wids, ID=dp_widid.dp_dataproc
;          ENDIF ELSE RETURN
;        ENDIF

  dp_call_expinfo, FNAME=expinfopath, OVERWRITE=del_results, VERBOSE=verbose
        
;from config_dp_mainwid

  expinflist=[]
  IF SIZE(dp_expcfg, /TYPE) EQ 11 THEN $
    FOR i=0, N_ELEMENTS(dp_chrom)-1 DO expinflist=[expinflist, ((dp_expcfg[i]).expinfo.expinfo_fname)[0]]

  FOR n=0, N_ELEMENTS(dp_expcfg)-1 DO BEGIN
    ITS = {instrument: instr, type: etype, spec: espec}
    tmp_strct=(dp_expcfg)[n]  ; move structure out of list
    tmp_strct.setup=ITS
    (dp_expcfg)[n]=TEMPORARY(tmp_strct)  ; put strct with loaded values back into list
  ENDFOR   
    ;******************************************************************************************


END