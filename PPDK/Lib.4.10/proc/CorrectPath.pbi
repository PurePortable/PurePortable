
CompilerIf Not Defined(DBG_CORRECTPATH,#PB_Constant) : #DBG_CORRECTPATH = 0 : CompilerEndIf
CompilerIf #DBG_CORRECTPATH
	Macro DbgCorPath(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgCorPath(txt) : EndMacro
CompilerEndIf

XIncludeFile "FindStringReverse.pbi"

EnumerationBinary CORRECTPATH
	#CORRECTPATH_FROM_DEEP ; $0001
	#CORRECTPATH_REAL_PATH ; $0002 ; возвращается только реальный результат, если пути нет, то пустая строка, иначе строка без изменений.
	;#CORRECTPATH_CHECK_PATH = #CORRECTPATH_CHECK_PATH
	#CORRECTPATH_FORWARD_SLASH ; $0004
	#CORRECTPATH_DOUBLE_BACKSLASH ; $0008 ; TODO
	#CORRECTPATH_RELATIVE ; $0010 ; TODO возвращается путь относительно Base
	#CORRECTPATH_SAVE_BACKSLASH ; $0020 ; TODO сохранять последний слеш
EndEnumeration
; TODO:
; Если Path изначально не содержит "\", файл не будет найден. Имеет ли смысл специально добавлять лидирующий "\"?
Procedure.s CorrectPath(Path.s,Base.s,Flags=0)
	Protected i, NewPath.s, Ending.s
	Protected LBase
	Base = RTrim(Base,"\")+"\"
	DbgCorPath("Base: "+Base)
	If Right(Path,1)="\"
		Path = RTrim(Path,"\")
		Ending = "\" ; сохраним завершающий «\» для папок
	ElseIf Right(Path,1)="/"
		Path = RTrim(Path,"/")
		Ending = "/" ; сохраним завершающий «/» для папок
	EndIf
	If Flags & #CORRECTPATH_FORWARD_SLASH
		Path = ReplaceString(Path,"/","\")
		;WindowsReplaceString_(@Path,"/","\",@Path)
	EndIf
	DbgCorPath("Path: "+Path)
	If Path
		If Flags & #CORRECTPATH_FROM_DEEP
			i = FindString(Path,"\")
			While i
				NewPath = Base+Mid(Path,i+1)
				DbgCorPath("   >> "+NewPath)
				If FileSize(NewPath)<>-1
					DbgCorPath("   == "+NewPath)
					If Flags & #CORRECTPATH_FORWARD_SLASH
						NewPath = ReplaceString(NewPath,"\","/")
					EndIf
					ProcedureReturn NewPath+Ending
				EndIf
				i = FindString(Path,"\",i+1)
			Wend
		Else
			i = FindStringReverse(Path,"\")
			While i>0
				NewPath = Base+Mid(Path,i+1)
				DbgCorPath("   >> "+NewPath)
				If FileSize(NewPath)<>-1
					DbgCorPath("   == "+NewPath)
					If Flags & #CORRECTPATH_FORWARD_SLASH
						NewPath = ReplaceString(NewPath,"\","/")
					EndIf
					ProcedureReturn NewPath+Ending
				EndIf
				i = FindStringReverse(Path,"\",i-1)
			Wend
		EndIf
	EndIf
	; Путь не найден
	If Flags & #CORRECTPATH_REAL_PATH
		ProcedureReturn ""
	EndIf
	If Flags & #CORRECTPATH_FORWARD_SLASH
		Path = ReplaceString(Path,"\","/")
	EndIf
	ProcedureReturn Path+Ending
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant