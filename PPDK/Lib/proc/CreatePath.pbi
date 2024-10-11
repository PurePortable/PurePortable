
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shcreatedirectoryexw

;DeclareImport(shell32,_SHCreateDirectoryExW@12,SHCreateDirectoryExW,SHCreateDirectoryEx_(hWnd,*pszPath,*psa))
;SHCreateDirectoryEx_(0,@Path,#Null) ; может неправильно работать из dllmain

Procedure CreatePath(Path.s)
	Path = RTrim(Path,"\")+"\"
	Protected p = FindString(Path,"\")
	While p
		CreateDirectory(Left(Path,p-1))
		p = FindString(Path,"\",p+1)
	Wend
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 5
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant