; Нет в Win7:
; GetFileVersionInfoExA
; GetFileVersionInfoSizeExA

DeclareProxyDll(version)

DeclareProxyFunc(version,GetFileVersionInfoA)
DeclareProxyFunc(version,GetFileVersionInfoW)
;DeclareProxyFunc(version,GetFileVersionInfoExA)
DeclareProxyFunc(version,GetFileVersionInfoExW)
DeclareProxyFunc(version,GetFileVersionInfoSizeA)
DeclareProxyFunc(version,GetFileVersionInfoSizeW)
;DeclareProxyFunc(version,GetFileVersionInfoSizeExA)
DeclareProxyFunc(version,GetFileVersionInfoSizeExW)
DeclareProxyFunc(version,VerFindFileA)
DeclareProxyFunc(version,VerFindFileW)
;DeclareProxyFunc(version,VerInstallFileA) ; срабатывание антивирусов
;DeclareProxyFunc(version,VerInstallFileW) ; срабатывание антивирусов
;DeclareProxyFunc(version,VerLanguageNameA) ; срабатывание антивирусов
;DeclareProxyFunc(version,VerLanguageNameW) ; срабатывание антивирусов
DeclareProxyFunc(version,VerQueryValueA)
DeclareProxyFunc(version,VerQueryValueW)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 4
; EnableAsm
; DisableDebugger
; EnableExeConstant