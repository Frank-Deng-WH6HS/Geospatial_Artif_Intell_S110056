; 基于排序不等式的排序指数
; Sequential Indices based on rearrangement inequality

; 输入:
;   time_ser
;     某像元n时相的时间序列信息, 按时间先后顺序组合成一维数组
; Input:
;   time_ser
;     An 1-D array as a combination of n-phase time series information
;     of certain pixel arranged by time sequence
; 
; 输出: 像元的排序指数
; Output: Sequential index of certain pixel
Function SEQ_INDEX, time_ser
  ; 排序
  ; Sort
  time_ser_asc = time_ser[Sort(time_ser)]
  time_ser_desc = Reverse(time_ser_asc)
  ; 计算正序和, 反序合, 乱序和
  ; Calculate sum of sorted, inversed and random ordering
  n_phase = Size(time_ser, /N_Element)
  time_phase = DIndGen(n_phase, Start = 1)
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
End