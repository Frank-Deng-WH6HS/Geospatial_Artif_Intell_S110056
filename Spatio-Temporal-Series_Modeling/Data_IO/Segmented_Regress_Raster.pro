Function LIN_REG_PARAM_TAG
    Return, ["beta_0 (intercept)", "beta_1 (slope)"]
End

; 计算栅格时序数据的线性回归参数和R2
; Calculate parameters and R squared of linear regression of raster data
Pro LIN_REG_RASTER, $
  FID = fid, R_FID = r_fid, OUT_NAME = out_name, $
  R_SQUARED = r_squared, TIME_PHASE = time_phase
  ; 获取现有栅格, 并构造分块迭代器
  ; Obtain existant raster and construct tile iterator
  raster = ENVIFidToRaster(fid)
  n_clm = raster.NColumns
  n_phase = raster.NBands
  raster_iter = raster.CreateTileIterator(Mode = 'Spectral')
  ; 构造与原栅格空间基准和采样方式相同的新栅格
  ; Create new raster containing same spatial references and sampling methods
  ;   as the original raster
  RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid_coef, $
    OUT_NAME = out_name + "_coef.dat", $
    NBANDS = 2, DATA_TYPE = 'float', INTERLEAVE = 'bil'
  r_fid = r_fid_coef
  r_coef = ENVIFidToRaster(r_fid_coef)
  r_coef.MetaData.UpdateItem, 'band names', LIN_REG_PARAM_TAG()
  r_coef_line_0 = Dblarr(2, n_clm)
  If Not Keyword_set(TIME_PHASE) Then Begin
    time_phase = Dindgen(n_phase, Start = 1)
  EndIf
  If Not Keyword_Set(R_SQUARED) Then r_squared = 0
  If r_squared Then Begin
    RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid_r2, $
      OUT_NAME = out_name + "_rsq.dat", $
      NBANDS = 1, DATA_TYPE = 'float', INTERLEAVE = 'bil'
    r_r2 = ENVIFidToRaster(r_fid_r2)
    r_r2.MetaData.UpdateItem, 'band names', ["R^2 (R squared)"]
    r_r2_line_0 = DblArr(n_clm)
  EndIf
  ; 分块迭代过程
  ; Tiled iteration
  Foreach tile, raster_iter, idx_row Do Begin
    ; 从迭代器中提取一行内的所有像元
    ; Extract all pixels of a line from tile iterator
    line = Transpose(tile)
    ; 对一行内的每个像元, 计算回归系数和R2
    ; For each pixel in line, calculate regress coefficients and r squared 
    For idx_clm = 0, n_clm - 1 Do Begin
      r_coef_line_0[*, idx_clm] = LinFit(time_phase, line[*, idx_clm], $
        /Double, YFit = y_pred $
      )
      If r_squared Then Begin
        y_mean = Mean(line[*, idx_clm])
        ; 计算SST, SSE, R2
        ; Calculate SST, SSE, and R squared
        sum_sq_total = Total((line[*, idx_clm] - y_mean) ^ 2)
        sum_sq_estim = Total((y_pred - y_mean) ^ 2)
        r_sq = sum_sq_estim / sum_sq_total
        r_r2_line_0[idx_clm] = r_sq
      EndIf
    EndFor
    r_coef_line = Transpose(r_coef_line_0)
    r_coef.SetData, r_coef_line, Sub_Rect = raster_iter.Current_Subrect
    If r_squared Then Begin
      r_r2_line = r_r2_line_0.Reform(n_clm, 1, 1)
      r_r2.SetData, r_r2_line, Sub_Rect = raster_iter.Current_Subrect
    EndIf
  EndForEach
  r_coef.Save
  If r_squared Then r_r2.Save
End 

Function PW_LIN_REG_PARAM_TAG, n_sgm_pnt
  whitespace = ' '
  tag = StrArr(2 * (n_sgm_pnt + 1))
  For idx = 0, 2 * n_sgm_pnt + 1 Do Begin
    coef_var_stat = idx Le (n_sgm_pnt + 1)
    idx_descr = coef_var_stat? idx: idx - (n_sgm_pnt + 1)
    idx_descr = StrTrim(String(idx_descr), 2) + whitespace
    param_var_name = coef_var_stat? 'beta': 'x'
    param_var_name += '_'
    param_var_descr = idx Eq 0? 'intercept': $
      (coef_var_stat? 'coefficient': 'segmentation point')
    param_var_descr = '(' + param_var_descr + ')'
    tag[idx] = param_var_name + idx_descr + param_var_descr
  EndFor
  Return, tag
End

; 计算栅格时序数据的分段线性回归参数和R2
; Calculate parameters and R squared of piecewise linear regression
;   of raster data
Pro PW_LIN_REG_RASTER, $
  FID = fid, R_FID = r_fid, OUT_NAME = out_name, N_SGM_PNT = n_sgm_pnt, $
  MAX_ITERATION = max_iteration, THRESHOLD = threshold, $
  R_SQUARED = r_squared, STATUS = status, TIME_PHASE = time_phase
  ; 获取现有栅格, 并构造分块迭代器
  ; Obtain existant raster and construct tile iterator
  raster = ENVIFidToRaster(fid)
  n_clm = raster.NColumns
  n_phase = raster.NBands
  raster_iter = raster.CreateTileIterator(Mode = 'Spectral')
  ; 构造与原栅格空间基准和采样方式相同的新栅格
  ; Create new raster containing same spatial references and sampling methods
  ;   as the original raster
  RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid_param, $
    OUT_NAME = out_name + "_param.dat", $
    NBANDS = 2 * (n_sgm_pnt + 1), DATA_TYPE = 'float', INTERLEAVE = 'bil'
  r_fid = r_fid_param
  r_param = EnviFidToRaster(r_fid_param)
  r_param_line_sgm = DblArr(n_sgm_pnt, n_clm)
  r_param_line_coef = Dblarr(n_sgm_pnt + 2, n_clm)
  If Not Keyword_Set(TIME_PHASE) Then Begin
    time_phase = DIndGen(n_phase, Start = 1)
  Endif
  ; 如果调用函数时启用了/R_SQUARED选项, 则另行构造新栅格存放每个像元回归模型的R2
  ; If option /R_SQUARED is enabled while invoking this function, generate 
  ;   new raster to store R squared of regression model for each pixel
  If Not Keyword_Set(R_SQUARED) Then r_squared = 0
  If r_squared Then Begin
    RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid_r2, $
      OUT_NAME = out_name + "_rsq.dat", $
      NBANDS = 1, DATA_TYPE = 'float', INTERLEAVE = 'bil'
    r_r2 = EnviFidToRaster(r_fid_r2)
    r_r2_line_0 = DblArr(n_clm)
  EndIf
  ; 如果调用函数时启用了/STATUS选项, 则另行构造新栅格存放每个像元建立分段回归模型的状态值
  ; If option /STATUS is enabled while invoking this function, generate
  ;   new raster to store status during model establishment of each pixel
  If Not Keyword_set(STATUS) Then status = 0
  If status Then Begin
    RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid_status, $
      OUT_NAME = out_name + "_status.dat", $
      NBANDS = 1, DATA_TYPE = 'float', INTERLEAVE = 'bil'
    r_status = EnviFidToRaster(r_fid_status)
    r_status_line_0 = DblArr(n_clm)
  Endif
  ; 初始化迭代参数
  ; Initialize parameters for iteration
  If Not Keyword_Set(MAX_ITERATION) Then max_iteration = 16
  If Not Keyword_Set(THRESHOLD) Then threshold = 0.01d
  coef = Dblarr(n_sgm_pnt + 2)
  r_sq = 0
  ; 分块迭代过程
  ; Tiled iteration
  ForEach tile, raster_iter, idx_row Do Begin
    ; 从迭代器中提取一行内的所有像元
    ; Extract all pixels of a line from tile iterator
    line = Transpose(tile)
    ; 对一行内的每个像元, 计算回归系数和R2
    ; For each pixel in line, calculate regress coefficients and r squared
    For idx_clm = 0, n_clm - 1 Do Begin
      r_param_line_sgm[*, idx_clm] = MUGGEO_SGM_PNT_ITER( $
        line[*, idx_clm], n_sgm_pnt, /DOUBLE, $
        MAX_ITERATION = max_iteration, THRESHOLD = threshold, $
        COEFFICIENT = coef, R_SQUARED = r_sq, STATUS = status_pw_reg, $
        TIME_PHASE = time_phase, N_PHASE = n_phase $
      )
      r_param_line_coef[*, idx_clm] = coef
      If r_squared Then Begin
        r_sq = (r_sq Lt 0)? -1: r_sq
        r_sq = (r_sq Gt 1)? -1: r_sq
        r_r2_line_0[idx_clm] = r_sq
      EndIf
      If status Then Begin
        r_status_line_0[idx_clm] = status_pw_reg
      EndIf
    EndFor
    r_param_line = [Transpose(r_param_line_coef, [0, 1]), $
      Transpose(r_param_line_sgm, [0, 1])]
    r_param_line = Transpose(r_param_line)
    r_param_line = r_param_line.Reform(n_clm, 2 * (n_sgm_pnt + 1), 1)
    r_param.SetData, r_param_line, Sub_Rect = raster_iter.Current_Subrect
    If r_squared Then Begin
      r_r2_line = r_r2_line_0.Reform(n_clm, 1, 1)
      r_r2.SetData, r_r2_line, Sub_Rect = raster_iter.Current_Subrect
    EndIf
    If status Then Begin
      r_status_line = r_status_line_0.Reform(n_clm, 1, 1)
      r_status.SetData, r_status_line, Sub_Rect = raster_iter.Current_Subrect
    EndIf
  EndForEach
  r_param.Save
  If r_squared Then r_r2.Save
  If status Then r_status.Save
End