; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletetreew

XIncludeFile "DeclareImportMacro.pbi"

DeclareImport(advapi32,_RegDeleteTreeW@8,RegDeleteTreeW,RegDeleteTree_(hKey.l,*lpSubKey))

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; EnableThread
; DisableDebugger
; EnableExeConstant