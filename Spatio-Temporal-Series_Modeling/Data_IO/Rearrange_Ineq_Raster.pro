; 计算栅格时序数据的排序指数: 基于排序不等式
; Calculate sequential indices of raster data based on rearrangement inequality
Pro SEQ_INDEX_RASTER, $
  FID = fid, R_FID = r_fid, OUT_NAME = out_name
  E = ENVI()
  ; 获取现有栅格, 并构造分块迭代器
  ; Obtain existant raster and construct tile iterator
  raster = ENVIFidToRaster(fid)
  n_clm = raster.NColumns
  raster_iter = raster.CreateTileIterator(Mode = 'Spectral')
  ; 构造与原栅格空间基准和采样方式相同的新栅格
  ; Create new raster containing same spatial references and sampling methods
  ;   as the original raster
  RASTER_SPATIAL_INHERIT, FID = fid, R_FID = r_fid, OUT_NAME = out_name, $
    NBANDS = 1, DATA_TYPE = 'float', INTERLEAVE = 'bsq'
  r_raster = ENVIFidToRaster(r_fid) 
  ; 分块迭代过程
  ; Tiled iteration
  ForEach tile, raster_iter, idx_row Do Begin
    r_line = SEQUENTIAL_INDEX(Transpose(tile))
    r_line = r_line.Reform(n_clm, 1, 1, /Overwrite)
    r_raster.SetData, r_line, Sub_Rect = raster_iter.Current_Subrect
  EndForEach
  r_raster.Save
End 