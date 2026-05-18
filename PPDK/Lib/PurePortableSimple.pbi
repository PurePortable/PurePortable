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
; Procedure.s ReadPreferenceStringQ(Key.s,DefaultValue.s="")
; 	ProcedureReturn Trim(ReadPreferenceString(Key,DefaultValue),Chr(34))
; EndProcedure
;;======================================================================================================================
; Procedure.s PreferenceKeyValueQ()
; 	ProcedureReturn Trim(PreferenceKeyValue(),Chr(34))
; EndProcedure
;;======================================================================================================================
Procedure.q ValX(Num.s)
	If UCase(Left(Num,2)) = "0X"
		Num = "$"+Mid(Num,3)
	EndIf
	ProcedureReturn Val(Num)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 40
; FirstLine = 11
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant