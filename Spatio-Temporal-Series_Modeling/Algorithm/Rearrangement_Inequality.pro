; 基于排序不等式的排序指数
; Sequential Indices based on rearrangement inequality

; 输入:
;   time_ser
;     某像元n时相的时间序列信息, 按时间先后顺序组合成一维数组
;     支持向量化运算
;   TIME_PHASE = time_phase
;     时序的时相值, 按时间先后顺序组合成一维数组
;   
; Input:
;   time_ser
;     An 1-D array as a combination of n-phase time series information
;       of certain pixel arranged by time sequence. 
;     Vectorization is supported. 
;   TIME_PHASE = time_phase
;     An 1-D array as a combination of time phases, 
; 
; 输出: 像元的排序指数
; Output: Sequential index of certain pixel
Function SEQUENTIAL_INDEX, time_ser, TIME_PHASE = time_phase
  ; 直接计算单一像元的数据
  ; Calculate data of single pixel
  If Size(time_ser, /N_Dimensions) Eq 1 Then Begin
    n_phase = Size(time_ser, /N_Elements)
    If Not Keyword_Set(TIME_PHASE) Then Begin
      time_phase = Dindgen(n_phase, Start = 1)
    Endif
    ; 排序
    ; Sort
    time_ser_asc = time_ser[Sort(time_ser)]
    time_ser_desc = Reverse(time_ser_asc)
    ; 计算正序和, 反序和, 乱序和
    ; Calculate sum of sorted, inversed and random ordering
    sum_sorted_ord = Total(time_ser_asc * time_phase)
    sum_inversed_ord = Total(time_ser_desc * time_phase)
    sum_random_ord = Total(time_ser * time_phase)
    ; 计算排序指数
    ; Calculate sequential index
    If sum_inversed_ord Ne sum_sorted_ord Then Begin
      seq_idx = $
        (sum_random_ord - sum_inversed_ord) / (sum_sorted_ord - sum_inversed_ord)
      seq_idx = 2 * seq_idx - 1
    EndIf Else Begin
      seq_idx = 0
    EndElse
    Return, seq_idx
  EndIf 
  
  ; 向量化模式下, 计算某一行的所有像元的数据, 返回的结果是一维向量
  ; 可与ENVI的分块读取功能一同使用
  ; Calculate data of an entire row in vectorization mode
  ; This feature can be used with ENVI raster tile iterator
  If Size(time_ser, /N_Dimensions) Eq 2 Then Begin
    n_phase = Size(time_ser, /Dimensions)
    n_pixel = n_phase[1]
    n_phase = n_phase[0]
    If Not Keyword_Set(TIME_PHASE) Then Begin
      time_phase = Dindgen(n_phase, Start = 1)
    Endif
    seq_idx_row = DblArr(n_pixel)
    For idx = 0, n_pixel - 1 Do Begin
      seq_idx_row[idx] = SEQUENTIAL_INDEX( $
        time_ser[*, idx], TIME_PHASE = time_phase $
      )
    EndFor
    Return, seq_idx_row
  EndIf Else Begin
    Return, 0
  EndElse
End