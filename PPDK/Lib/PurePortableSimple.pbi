;;======================================================================================================================
; TODO:
; - PreferencePath - раскрытие переменных среды
;;======================================================================================================================
EnableExplicit

XIncludeFile "PurePortable.pbi"
XIncludeFile "proc\s2guid.pbi"
XIncludeFile "proc\Execute.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"

;;----------------------------------------------------------------------------------------------------------------------

; Global ProcessId
; Global DllInstance; будет иметь то же значение, что и одноимённый параметр в AttachProcess
; Global DllPath.s
; Global DllName.s
; Global PrgDir.s
; Global PrgDirN.s

; CompilerIf Not Defined(DBG_ANY,#PB_Constant) : #DBG_ANY = 0 : CompilerEndIf
; CompilerIf #DBG_ANY And Not Defined(DBG_ALWAYS,#PB_Constant)
; 	#DBG_ALWAYS = 1
; CompilerEndIf
;Global DbgAttach
Global DbgDetach

XIncludeFile "PP_Extension.pbi"

;;======================================================================================================================
Procedure.s PreferencePath(Path.s="",Dir.s="") ; Преобразование относительных путей
	Protected Result.s
	If Path=""
		Path = PreferenceKeyValue()
	EndIf
	If Dir=""
		Dir = PrgDirN
	EndIf
	;dbg("PreferencePath: <"+Path)
	Path = ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34)))
	;Path = Trim(Trim(Path),Chr(34))
	;dbg("PreferencePath: *"+Path)
	If Path="."
		Path = Dir
	;ElseIf Path=".." Or Left(Path,2)=".\" Or Left(Path,3)="..\"
	;	Path = Dir+"\"+Path
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = Dir+"\"+Path
	EndIf
	;dbg("PreferencePath: >"+NormalizePath(Path))
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 40
; FirstLine = 18
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant