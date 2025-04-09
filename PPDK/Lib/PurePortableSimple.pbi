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

#IHELPFUL_INIT = 1
#IMINHOOK_INIT = 1
XIncludeFile "PP_Extension.pbi"
;;======================================================================================================================

Global *EXT.EXTDATA

;;======================================================================================================================
Procedure.s NormalizePPath(Path.s="",Dir.s="") ; Преобразование относительных путей
	If Dir="" : Dir = PrgDirN : EndIf
	Path = ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34)))
	If Path="."
		Path = Dir
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = Dir+"\"+Path
	EndIf
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 33
; FirstLine = 8
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant