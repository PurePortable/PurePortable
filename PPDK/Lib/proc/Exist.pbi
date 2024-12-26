; https://www.rsdn.org/article/qna/baseserv/fileexist.xml
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsa
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectorya
; Функции PathFileExists и PathIsDirectory работают неадекватно!
; https://learn.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-getfileattributesw
; https://vsokovikov.narod.ru/New_MSDN_API/Menage_files/fn_getfileattributes.htm

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
; CursorPosition = 4
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant