Pro MUGGEO_VAR_ALTER, _EXTRA = _EXTRA
  
  overview = $
    "The MUGGEO_VAR_ALTER function " + $
    "performs variable alternation for Muggeo segmentation algorithm. "
  
  syn_descr = $
    "result = MUGGEO_VAR_ALTER( time_ser, x_sgm_pnt, [/DOUBLE] )"
  
  return_descr = $
    "The result of the function is a 2-D array storing alternation " + $
    "result, (2m+1) columns by n rows"
  
  arg_descr = Hash( { $
    time_ser: $
      "An 1-D array as a combination Of n-phase time series information " + $
      "of certain pixel arranged by time sequence", $
    x_sgm_pnt: $
      "An 1-D array consisting of m segmentation points" $
  } )
  
  kw_descr = Hash( { $
    DOUBLE: $
       "Set this keyword to force computations to be done in double-" + $
       "precision arithmetic. " $
  } )
  
  CLI_HELP, overview, syn_descr, return_descr, arg_descr, kw_descr, $
    _EXTRA = _EXTRA
End