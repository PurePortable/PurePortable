; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-addfontresourceexw
; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-removefontresourceexw

XIncludeFile "DeclareImportMacro.pbi"

#FR_PRIVATE = $10
#FR_NOT_ENUM = $20

DeclareImport(gdi32,_AddFontResourceExW@12,AddFontResourceExW,AddFontResourceEx_(name,fl,pdv))
DeclareImport(gdi32,_RemoveFontResourceExW@12,RemoveFontResourceExW,RemoveFontResourceEx_(name,fl,pdv))

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 10
; EnableThread
; DisableDebugger
; EnableExeConstant