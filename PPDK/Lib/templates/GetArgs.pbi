
; Получить аргументы командной строки "как есть", исключив из командной строки путь к программе
Protected Args.s = PeekS(PathGetArgs_(GetCommandLine_()))

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; EnableThread
; DisableDebugger
; EnableExeConstant