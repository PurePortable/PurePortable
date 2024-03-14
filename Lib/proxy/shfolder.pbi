
DeclareProxyDll(shfolder)

DeclareExportFuncDetour(SHGetFolderPathA,shell32,_SHGetFolderPathA@20,SHGetFolderPathA)
DeclareExportFuncDetour(SHGetFolderPathW,shell32,_SHGetFolderPathW@20,SHGetFolderPathW)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 4
; EnableAsm
; DisableDebugger
; EnableExeConstant