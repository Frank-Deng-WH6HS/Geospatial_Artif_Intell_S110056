; 创建一个与现有栅格空间基准和采样方法相同的新栅格
; Create a new raster containing same spatial references and sampling methods
;   as an existant raster

; 输入: 
;   FID = fid
;     在ENVI会话中打开的现有栅格数据集的FID
;   R_FID = r_fid
;     使用r_fid变量返回结果栅格在ENVI会话中打开期间的FID
;   OUT_NAME = out_name
;     创建的栅格数据集的文件名
;   NBANDS = nbands
;     新栅格的波段数目, 默认值为指定的现有栅格的波段数目
;   DATA_TYPE = data_type
;     新栅格的数据类型, 默认值为指定的现有栅格的数据类型
;   INTERLEAVE = interleave
;     新栅格的数据组织形式, 默认值为指定的现有栅格的数据组织形式

Pro RASTER_SPATIAL_INHERIT, $
  FID = fid, R_FID = r_fid, OUT_NAME = out_name, $
  NBANDS = nbands, DATA_TYPE = data_type, INTERLEAVE = interleave
  
  msg_invalid_var = " is undefined, result may be invalid. "
  ; 输入值处理
  ; Process input keywords
  If Not Keyword_set(FID) Then Begin
    Message, "Variable FID" + msg_invalid_var
  Endif Else Begin
    raster = EnviFidToRaster(fid)
    If Not Keyword_set(NBANDS) Then nbands = raster.NBands
    If Not Keyword_Set(DATA_TYPE) Then data_type = raster.TypeCode
    If Not Keyword_Set(INTERLEAVE) Then interleave = raster.Interleave
  EndElse
  If Not Keyword_Set(OUT_NAME) Then Begin
    Message, "Variable OUT_NAME" + msg_invalid_var
  EndIf
  ; 构建新栅格
  ; Construct new raster
  r_raster = EnviRaster(URI = out_name, Inherits_From = raster, $
    NBands = nbands, Data_Type = data_type, Interleave = interleave $
  )
  r_fid = EnviRasterToFid(r_raster)
End