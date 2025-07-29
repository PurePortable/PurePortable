; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletetreew

XIncludeFile "DeclareImportMacro.pbi"

DeclareImport(advapi32,_RegDeleteKeyValueW@12,RegDeleteKeyValueW,RegDeleteKeyValue_(hKey.l,*lpSubKey,*lpValueName))

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 5
; EnableThread
; DisableDebugger
; EnableExeConstant