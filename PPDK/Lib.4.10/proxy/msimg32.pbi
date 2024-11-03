; Конфликты имён:
; AlphaBlend

DeclareProxyDll(msimg32)

DeclareProxyConflictFunc(msimg32,AlphaBlend,AlphaBle__) ; conflict name
DeclareProxyFunc(msimg32,GradientFill)
DeclareProxyFunc(msimg32,TransparentBlt)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 4
; EnableAsm
; DisableDebugger
; EnableExeConstant