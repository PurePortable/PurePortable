; https://www.rsdn.org/article/qna/baseserv/fileexist.xml
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsa
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectorya
; Функции PathFileExists и PathIsDirectory работают неадекватно!

Procedure FileExist(fn.s)
	Protected attr = GetFileAttributes_(@fn)
	ProcedureReturn Bool(attr<>#INVALID_FILE_ATTRIBUTES And (attr&#FILE_ATTRIBUTE_DIRECTORY)=0)
	;ProcedureReturn PathFileExists_(@fn)
EndProcedure

Procedure DirectoryExist(fn.s)
	Protected attr = GetFileAttributes_(@fn)
	ProcedureReturn Bool(attr<>#INVALID_FILE_ATTRIBUTES And (attr&#FILE_ATTRIBUTE_DIRECTORY))
	;ProcedureReturn PathIsDirectory_(@fn)
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 7
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant