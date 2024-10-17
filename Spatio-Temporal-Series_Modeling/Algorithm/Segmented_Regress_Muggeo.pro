; 分段线性回归算法
; Piecewise linear regression algorithm

; 参考文献: 
; Referrence: 
; [1]MUGGEO V. Estimating Regression Models with Unknown Break-Points[J]. 
;    Statistics in medicine, 2003, 22: 3055-3071. DOI:10.1002/sim.1545.
; [2]MUGGEO V M R. segmented: An R package to Fit Regression Models with 
;    Broken-Line Relationships[J]. R News, 2008, 8(1): 20-25.
; 如需在学术成果中使用本算法及由其衍生的计算结果, 必须对文本中有关文献中的引用内容加以重述, 并在文后正确标引.
; If using this algorithm and derived results in academic projects, it is 
;   COMPULSORY to PARAPHASE contents cited from literatures above and DECLARE
;   ALL of the citations after the body text in appropriate format. 

; 计算多元线性回归的R^2
; Calculate R squared of multivariate linear regression
Function REGRESS_R2, x, y, DOUBLE = double
  ; 配置可选参数的默认值
  ; Configurate default values of optional parameters
  If Not Keyword_Set(DOUBLE) Then double = 0
  ; 获取回归分析的部分计算结果
  ; Obtain certain result of linear regression
  coef = Regress(x, y, Double = double, YFit = y_pred)
  y_mean = Mean(y)
  ; 计算SST, SSE, R2
  ; Calculate SST, SSE, and R squared
  sum_sq_total = Total((y - y_mean) ^ 2)
  sum_sq_estim = Total((y_pred - y_mean) ^ 2)
  r_sq = sum_sq_estim / sum_sq_total
  Return, r_sq
End

; Muggeo分段点搜索算法的变量代换
; Variable alternation for Muggeo segmentation algorithm
; 
; 输入: 
;   time_ser
;     某像元n时相的时间序列信息, 按时间先后顺序组合成一维数组
;   x_sgm_pnt
;     包含m个分段点的一维数组
;   /DOUBLE (可选参数)
;     指定在变量代换过程中, 运算强制使用双精度浮点数
; Input: 
;   time_ser
;     An 1-D array as a combination of n-phase time series information 
;     of certain pixel arranged by time sequence
;   x_sgm_pnt
;     An 1-D array consisting of m segmentation points
;   /DOUBLE (Optional)
;     Force computations to be done in double-precision arithmetic.
;     
; 输出: 存放变量代换结果的二维数组, (2m+1)列n行
; Output: A 2-D array storing alternation result, (2m+1) columns by n rows
Function MUGGEO_VAR_ALTER, time_ser, x_sgm_pnt, DOUBLE = double
  ; 获取时间序列的时相数目, 以及分段点的数目
  ; Get number of phases in time series and segmentation points
  n_phase = Size(time_ser, /N_Element)
  n_sgm_pnt = Size(x_sgm_pnt, /N_Element)
  ; 指定变量代换结果的数据类型
  ; Assign data type of result of variable alternation
  ; 先设置为单精度浮点数 
  ; Set to single-prec first
  dtype_result = 4
  ; 以下任意条件满足则设置为双精度浮点数
  ; Set to double-prec if any of following conditions matches
    ; 调用本函数时, 启用/DOUBLE选项
    ; Enable /DOUBLE option when invoking this function
  If Keyword_Set(DOUBLE) Then Begin
    If double Then Begin
      dtype_result = 5
    EndIf 
  EndIf
    ; 传入time_ser或者x_sgm_pnt的数组数据类型为双精度
    ; Data type of array passed to time_ser or x_sgm_pnt is double-prec
  If Size(time_ser, /Type) Eq 5 || Size(x_sgm_pnt, /Type) Eq 5 Then Begin
    dtype_result = 5 
    double = 1
  EndIf 
  ; 初始化存放变量代换结果的列表
  ; Initialize array to store result of variable alternation
  time_ser_var_alt = Make_Array( $
    n_phase, 2 * n_sgm_pnt + 1, Type = dtype_result $
  )
  ; 变量代换
  ; Variable alternation
  time_phase = DIndGen(n_phase, Start = 1)
  time_ser_var_alt[*, 0] = time_phase
  For idx_row = 1, 2 * n_sgm_pnt Do Begin
    ; 取出某个分段点
    ; Pick up certain segmentation point
    x_sgm = x_sgm_pnt[(idx_row - 1) / 2]
    If idx_row Mod 2 Then Begin
      ; 取最大值[1-2]
      ; Get maximum value[1-2]
      time_ser_var_alt[*, idx_row] = time_phase - x_sgm > 0 
    EndIf Else Begin
      ; 计算阶跃函数[1-2]
      ; Get stepped function[1-2]
      time_ser_var_alt[*, idx_row] = time_phase Gt x_sgm 
    EndElse
  EndFor
  ; 输出结果
  ; Output result
  Return, Transpose(time_ser_var_alt)
End

; Muggeo分段点搜索算法的分段点迭代
; Iteration of segmentation point for Muggeo segmentation algorithm
; 
; 输入: 
;   time_ser 
;     某像元n时相的时间序列信息, 按时间先后顺序组合成一维数组
;   n_sgm_pnt 
;     分段点数量m
;   /DOUBLE (可选参数)
;     指定在迭代过程中, 运算强制使用双精度浮点数
;   MAX_ITERATION = max_iteration (可选参数)
;     指定最大迭代次数(必须为正数), 默认值为16
;   THRESHOLD = threshold (可选参数)
;     迭代终止的阈值(必须为正数), 默认值为0.01
;   COEFFICIENT = coefficient (可选参数)
; Input:
;   time_ser
;     An 1-D array as a combination of n-phase time series information 
;     of certain pixel arranged by time sequence
;   n_sgm_pnt - Number of segmentation points
;   /DOUBLE (Optional)
;     Force computations to be done in double-precision arithmetic.
;   MAX_ITERATION = max_iteration (Optional) 
;     Maximum iteration (which must be a positive number), 
;     whose default value is 16
;   THRESHOLD = threshold (Optional)
;     Threshold for termination of iteration (which must be a positive 
;     number), whose default value is 0.01
;     
; 输出: 包含m个分段点的一维数组
; Output: An 1-D array consisting of m segmentation points
Function MUGGEO_SGM_PNT_ITER, time_ser, n_sgm_pnt, $
  DOUBLE = double, MAX_ITERATION = max_iteration, THRESHOLD = threshold, $
  COEFFICIENT = coefficient, R_SQUARED = r_squared
  ; 获取时间序列的时相数目
  ; Get number of phases in time series
  n_phase = Size(time_ser, /N_Element)
  ; 指定分段点搜索结果的数据类型
  ; Assign data type of result of segmentation point searching
  ; 先设置为单精度浮点数
  ; Set to single-prec first
  dtype_result = 4
  ; 以下任意条件满足则设置为双精度浮点数
  ; Set to double-prec if any of following conditions matches
    ; 调用本函数时, 启用/DOUBLE选项
    ; Enable /DOUBLE option when invoking this function
  If Keyword_Set(DOUBLE) Then Begin
    If Double Then Begin
      dtype_result = 5
    Endif
  Endif
    ; 传入time_ser的数组数据类型为双精度
    ; Data type of array passed to time_ser is double-prec
  If Size(time_ser, /Type) Eq 5 Then Begin
    dtype_result = 5 
    double = 1
  EndIf 
  ; 初始化分段点, 以均匀间隔采样
  ; Initialize segmentation points with uniform interval
  x_sgm_pnt = Make_Array(n_sgm_pnt + 2, Type = dtype_result)
  x_sgm_pnt[*] = DIndGen(n_sgm_pnt + 2) $
    * (n_phase - 1) / (n_sgm_pnt + 1) + 1
  x_sgm_pnt = x_sgm_pnt[1: -2]
  ; 确定最大迭代次数, 并定义存放迭代中间数据的数组
  ; Verify maximum iteration and declare array to store imtermediate data
  ;   during iteration
  If Not Keyword_Set(MAX_ITERATION) Then max_iteration = 16
  If max_iteration Le 0 Then Begin
    Message, /Continue, $
      "Maximum iterations can not be set to a negative number. "
  EndIf
  displacement_list = Make_Array(n_sgm_pnt, 2, max_iteration, $
    Type = dtype_result $
  )
  ; 确定迭代终止的阈值
  ; Verify threshold for termination of iteration
  If Not Keyword_Set(THRESHOLD) Then threshold = 0.01d
  If max_iteration Le 0 Then Begin
    Message, /Continue, $
      "Threshold can no be set to a negative number. "
  Endif
  ; 迭代过程
  ; Process of iteration
  For idx_iter = 0, max_iteration - 1 Do Begin
    ; 建立拟合模型并收集系数
    ; Establish regress model and gather coefficients
    time_ser_var_alt = MUGGEO_VAR_ALTER(time_ser, x_sgm_pnt, $
      DOUBLE = double)
    coef = Regress(time_ser_var_alt, time_ser, $
      Double = double, Const = beta_0 $
    )
    beta_1 = coef[0]
    beta_sgm = coef[1: -1: 2]
    gamma_sgm = coef[2: -1: 2]
    displacement = gamma_sgm / beta_sgm
    displacement_list[*, 0, idx_iter] = x_sgm_pnt
    displacement_list[*, 1, idx_iter] = displacement
    ; 更新分段点
    ; Update segmentation break point
    x_sgm_pnt -= displacement
    ; 特定条件下提前终止迭代
    ; Terminate iteration ahead of time in certain conditions
      ; βi中出现零值
      ; Zero value appears in βi
    idx_member = Where(beta_sgm Eq 0, n_member)
    If n_member Ge 1 Then Break 
      ; γi中出现零值
      ; Zero value appears in γi
    idx_member = Where(gamma_sgm Eq 0, n_member)
    If n_member Ge 1 THen Break
      ; 部分分段点落入时序范围以外
      ; A part of segmentation points exceed the range of phases
    idx_member = Where(x_sgm_pnt Lt 1, n_member)
    If n_member Ge 1 Then Break
    idx_member = Where(x_sgm_pnt Gt n_phase, n_member)
    If n_member Ge 1 Then Break
      ; 分段点向量在相邻两次迭代之间的距离小于预设的阈值
      ; Distance of vectors of segmentation points between neighbored 
      ;   iterations is less than preset threshold 
    If Norm(displacement, Double = double, LNorm = 2) Lt threshold Then Break
  EndFor
  If idx_iter Eq max_iteration Then idx_iter -= 1
  ; 截断迭代中间数据记录数组, 并对其反序
  ; Trim and reverse array storing intermediate data
  displacement_list = displacement_list[*, *, idx_iter: 0: -1]
  ; 识别迭代过程中开始出现循环的部分
  ; Identify step from which iteration cycles
  If idx_iter Eq 0 Then Begin
    displacement_accu = displacement_list[*, 1, *]
  EndIf Else Begin
    displacement_accu = Total(displacement_list[*, 1, *], $
      3, /Cumulative, Double = double $
    )
  EndElse
  displacement_accu = displacement_accu.Reform( $
    [n_sgm_pnt, idx_iter + 1], /Overwrite $
  )
  displacement_accu_mag = Make_Array(idx_iter + 1, Type = dtype_result)
  For idx_member = 0, idx_iter Do Begin
    displacement_accu_mag[idx_member] = Sqrt( $
      Total(Abs(displacement_accu[*, idx_member])^2, Double = double) $
    )
  EndFor
  n_cycle = Where(displacement_accu_mag Lt threshold)
  n_phase_cycle = n_cycle[0] + 1
  If n_phase_cycle Lt idx_iter && n_phase_cycle Ge 1 Then Begin
    ; 对单次循环中每一组分段点, 计算回归模型的R2
    ; Calculate R squared of regression models for segmentation points
    ;   in each phase of cycle
    displacement_list = displacement_list[*, 0, 0: n_phase_cycle - 1]
    displacement_list = displacement_list.Reform( $
      [n_sgm_pnt, n_phase_cycle], /Overwrite $  
    )
    r_sq = FltArr(n_phase_cycle)
    For idx_member = 0, n_phase_cycle - 1 Do Begin
      time_ser_var_alt = MUGGEO_VAR_ALTER( $
        time_ser, displacement_list[*, idx_member], DOUBLE = double $
      )
      r_sq[idx_member] = REGRESS_R2( $
        time_ser_var_alt, time_ser, Double = double $
      )
    EndFor
    ; 确认单次循环中R2最大的分段点
    ; Validate the segmentation points yielding largest R squared
    r_sq_max = Max(r_sq, idx_member)
    x_sgm_pnt = displacement_list[*, idx_member]
    ; 根据上述分段点, 重新计算回归模型的有关参数
    ; Calculate regression model parameters again based on 
    ;   segmentation points above
    If Keyword_Set(COEFFICIENT) Then Begin
      time_ser_var_alt = MUGGEO_VAR_ALTER( $
        time_ser, displacement_list[*, idx_member], DOUBLE = double $
      )
      coef = Regress(time_ser_var_alt, time_ser, $
        Double = double, CONST = beta_0 $
      )
      beta_1 = coef[0]
      beta_sgm = coef[1: -1: 2]
    EndIf
  EndIf Else Begin
    r_sq_max = REGRESS_R2( $
      time_ser_var_alt, time_ser, Double = double $
    )
  EndElse
  If Keyword_set(COEFFICIENT) Then Begin
    coefficient = [beta_0, beta_1, beta_sgm]
  EndIf
  r_squared = r_sq_max
  Return, x_sgm_pnt
End
