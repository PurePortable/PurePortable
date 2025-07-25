; https://learn.microsoft.com/ru-ru/windows/win32/api/psapi/nf-psapi-getmodulefilenameexa

XIncludeFile "DeclareImportMacro.pbi"

DeclareImport(psapi,_GetModuleFileNameExW@16,GetModuleFileNameExW,GetModuleFileNameEx_(hProcess,hModule,lpFilename,nSize))

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 5
; EnableThread
; DisableDebugger
; EnableExeConstant