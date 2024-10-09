; 在命令行中显示帮助提示
; Prompt help on console. 

Pro CLI_PRINT, str, INDENT = indent, BUFFER_SIZE = buffer_size
  If Not Keyword_Set(INDENT) Then indent = 0
  If Not Keyword_Set(BUFFER_SIZE) Then buffer_size = 80
  empty_line = ""
  str_rest = str
  While StrLen(str_rest) Gt 0 Do Begin
    str_line = StrMid(str_rest, 0, buffer_size - indent)
    Print, str_line, $
      Format = '($, T' + StrTrim(String(indent + 1), 2) + ', A)'
    str_rest = StrMid(str_rest, buffer_size - indent)
  EndWhile
  Print, empty_line
End

Pro CLI_HELP, overview, syn_descr, return_descr, arg_descr, kw_descr, $
  HELP = help, $
  SYNTAX = syntax, $
  RETURN_VALUES = return_values, RV = rv, $
  ARGUMENTS = arguments, $
  KEYWORDS = keywords, KW = kw
  If Not Keyword_Set(SYNTAX) Then syntax = 0
  If Not Keyword_Set(ARGUMENTS) Then arguments = 0
  If Not Keyword_Set(RETURN_VALUES) Then Begin
    return_values = Keyword_Set(RV)? rv: 0
  EndIf
  If Not Keyword_Set(KEYWORDS) Then Begin
    keywords = Keyword_Set(KW)? kw: 0
  EndIf
  empty_line = ""
  ; 使用/HELP选项时, 显示完整的帮助信息
  ; Display full information in case of using /HELP option
  If Keyword_Set(HELP) Then Begin
    syntax = 1
    return_values = 1s
    arguments = 1
    keywords = 1
  EndIf
  ; 输出对过程或者函数的总体介绍
  ; Display overall introduction of proc or func
  CLI_PRINT, overview
  Print, ""
  ; 输出对调用语法的介绍
  ; Display introduction of invoking syntaces
  If syntax Then Begin
    Print, "Syntax: "
    CLI_PRINT, syn_descr, INDENT = 4
    Print, empty_line
  EndIf
    ; 输出对返回值的介绍
    ; Display introduction of return values
  If return_values Then Begin
    Print, "Return Value: "
    CLI_PRINT, return_descr, INDENT = 4
    Print, empty_line
  EndIf
  ; 输出对参数的介绍
  ; Display introduction of arguments
  If arguments Then Begin
    Print, "Arguments: "
    ForEach descr, arg_descr, arg Do Begin
      CLI_PRINT, arg, INDENT = 4
      CLI_PRINT, descr, INDENT = 8
    EndForEach
    Print, empty_line
  EndIf
  ; 输出对关键字的介绍
  ; Display introduction of keywords
  If keywords Then Begin
    Print, "Keywords: "
    Foreach descr, kw_descr, kw Do Begin
      CLI_PRINT, kw, INDENT = 4
      CLI_PRINT, descr, INDENT = 8
    Endforeach
    Print, empty_line
  Endif
End

