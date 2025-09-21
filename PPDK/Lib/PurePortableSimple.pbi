;;======================================================================================================================
EnableExplicit

XIncludeFile "PurePortable.pbi"
XIncludeFile "proc\s2guid.pbi"
XIncludeFile "proc\guid2s.pbi"
XIncludeFile "proc\Execute.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"

;;----------------------------------------------------------------------------------------------------------------------

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

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 10
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant