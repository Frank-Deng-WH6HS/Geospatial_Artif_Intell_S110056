Pro SPATIO_TEMPORAL_SERIES_MODELING_EXTENSIONS_INIT
  Compile_Opt IDL2
  e = ENVI(/Current)
  e.AddExtension, 'Piecewise Linear Regression', $
    'TIME_SER_RASTER_REG_GUI', $
    Path = "Spatiotemporal Analysis/Trend Extraction"
End