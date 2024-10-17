Pro REGRESS_R2, _EXTRA = _EXTRA

  overview = $
    "The REGRESS_R2 function " + $
    "calculates R squared of multivariate linear regression"

  syn_descr = $
    "result = REGRESS_R2( x, y, [/DOUBLE] )"

  arg_descr = Hash( { $
    x: $
      "An Nterms by Npoints array of independent variable data, where " + $
      "Nterms is the number of coefficients (independent variables) and " + $
      "Npoints is the number of samples. ", $
    y: $
      "An Npoints-element vector of dependent variable points. " $
  } )
  
  kw_descr = Hash( { $
    DOUBLE: $
      "Set this keyword to force computations to be done in double-" + $
      "precision arithmetic. " $
  } )
  
  CLI_HELP, overview, syn_descr, return_descr, arg_descr, kw_descr, $
    _EXTRA = _EXTRA
    
End

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