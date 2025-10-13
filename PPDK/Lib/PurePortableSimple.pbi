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
#IREGISTRY_INIT = 1
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
Procedure.s ReadPreferenceStringQ(Key.s,DefaultValue.s="")
	ProcedureReturn Trim(ReadPreferenceString(Key,DefaultValue),Chr(34))
EndProcedure
;;======================================================================================================================
Procedure.s PreferenceKeyValueQ()
	ProcedureReturn Trim(PreferenceKeyValue(),Chr(34))
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 13
; FirstLine = 4
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant