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

; Muggeo分段点搜索算法的变量代换
; Variable alternation for Muggeo segmentation algorithm
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
  If Size(time_ser, /Type) Eq 5 Then Begin
    dtype_result = 5 
  EndIf 
  If Size(x_sgm_pnt, /Type) Eq 5 Then Begin
    dtype_result = 5
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
