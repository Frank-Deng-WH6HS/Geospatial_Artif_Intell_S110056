Function TIME_SER_RASTER_REG_CAPTN_STEP, step
  ; 为GUI的每个步骤的窗口指定标题文字
  ; Configure captions of window for each step
  Case step Of 
    1: captn = "Select time-serial raster"
    2: captn = "Select regression model"
    3: captn = "Configure regression model"
  EndCase
  Return, captn
End

Pro TIME_SER_RASTER_REG_GUI
  Compile_Opt IDL2
  e = ENVI(/Current)
  whitespace = ' '
  ; 通用错误处理
  ; General Error Handler
  Catch, err
  If err Ne 0 Then Begin
    Catch, /Cancel
    If Obj_Valid(e) Then $
      e.ReportError,'ERROR: ' + !error_state.msg
    Message, /Reset
    Return
  Endif
  ; 第一步: 选取栅格用于输入
  ; Step 1: Select raster as input
  e.Show
  ENVI_Select, Fid = fid, Dims = dims, Pos = pos, $
    /File_Only, /No_Dims, /No_Spec, $
    Title = TIME_SER_RASTER_REG_CAPTN_STEP(1)
    ; 异常处理: 用户取消选取, 后续操作不再进行
    ; Anormaly handling: Operation canceled by user
  If fid[0] Eq -1 Then Return
  raster = EnviFidToRaster(fid)
  n_time_ser = raster.nBands
  ; 第二步: 选择回归模型类型
  ; Step 2: Configure type of regression model
    ; 定义对话框需要包含的要素
    ; Define features contained in dialog box
  dlg_mdl = Widget_Auto_Base( $
    Title = TIME_SER_RASTER_REG_CAPTN_STEP(2) $
  )
    ; 一个组合框, 提示用户指定回归模型类型
    ; A combo box prompting user to assign type of regression model
  cmb_mdl_type_captn = "Select type of regression model: "
  cmb_mdl_type = Widget_PMenu(dlg_mdl, $
    Prompt = cmb_mdl_type_captn, List = [ $
      "Simple Linear Regression", "Segmented(Piecewise) Linear Regression" $
    ], UValue = "model_type", /Auto_Manage $
  )
  mdl_config = Auto_Wid_Mng(dlg_mdl)
    ; 异常处理: 用户取消选取, 后续操作不再进行
    ; Anormaly handling: Operation canceled by user
  If Not mdl_config.Accept Then Return
  mdl_type = Fix(mdl_config.model_type)
  ; 第三步: 选择回归模型类型
  ; Step 3: Configure type of regression model
  segmented = (mdl_type Ge 1)
    ; 定义对话框需要包含的要素
    ; Define features contained in dialog box
  dlg_mdl = Widget_Auto_Base( $
    Title = TIME_SER_RASTER_REG_CAPTN_STEP(3) $
  )
      ; 一个标签, 告知模型类型
      ; A label indicating type of model
  lbl_mdl_name_captn = segmented? 'Segmented(Piecewise)': 'Simple'
  lbl_mdl_name_captn = 'Model: ' + lbl_mdl_name_captn + $
    whitespace + 'linear regression. '
  lbl_mdl_name = Widget_SLabel(dlg_mdl, Prompt = lbl_mdl_name_captn)
      ; 以下控件仅当指定"分段线性回归"模型时显示
      ; The following idgets displays in case of selection of 
      ;   segmented linear regression only
  If segmented Then Begin
        ; 一个滑块(只能填入整数), 提示用户指定分段点数目
        ; A slider prompting user to assign number of segmentation points
        ;   which can accept integers only
    sld_mdl_n_sgm_captn = 'Select number of segmentation POINTS: '
    sld_mdl_n_sgm = Widget_SSlider(dlg_mdl, /Drag, $
      Title = txt_mdl_n_sgm_captn, XS = [300, 5], $
        ; 支持自动处理非法输入
        ; Support handling illegal input automatically
      DT = 2, Value = 1, Floor = 1, Ceil = n_time_ser - 2, $
      Min = 1, Max = n_time_ser - 2, Scale = 1, $
      UValue = 'num_of_segment_point', /Auto_Manage $
    )
        ; 一个列表编辑框, 提示用户指定分段线性模型迭代有关的参数
        ; A listed editing box prompt user to assign parameters related to
        ;   iterations in segmented linear regression
    edit_mdl_captn = "Parameters of iteration: "
    edit_mdl_param_item = ['Maximum iterations', 'Threshold of iterations']
    edit_mdl_param_val = [16us, 1d-2]
    edit_mdl_iter = Widget_Edit(dlg_mdl, $
      Prompt = edit_mdl_captn, Field = 3, $ 
      List = edit_mdl_param_item, Vals = edit_mdl_param_val, $
      DT = 5, UValue = 'param_iter', /Auto_Manage $
    )
  EndIf
  outf_mdl_out_prfx_captn = "Enter ROOTNAME for output files: "
  outf_mdl_out_prfx = Widget_OutF(dlg_mdl, $
    Prompt = outf_mdl_out_prfx_captn, $
    UValue = 'out_filename', /Auto_Manage $
  )
  mdl_config = Auto_Wid_Mng(dlg_mdl)
    ; 异常处理: 用户取消选取, 后续操作不再进行
    ; Anormaly handling: Operation canceled by user

  If Not mdl_config.Accept Then Return
  out_name = mdl_config.out_filename
  If segmented Then Begin
    n_sgm_pnt = Fix(mdl_config.num_of_segment_point)
    max_iteration = Fix(mdl_config.param_iter[0])
    threshold = mdl_config.param_iter[1]
    PW_LIN_REG_RASTER, $
      FID = fid, OUT_NAME = out_name, N_SGM_PNT = n_sgm_pnt, $
      MAX_ITERATION = max_iteration, THRESHOLD = threshold, $
      /R_SQUARED, /STATUS
  EndIf Else Begin
    LIN_REG_RASTER, FID = fid, OUT_NAME = out_name, /R_SQUARED
  EndElse
End
