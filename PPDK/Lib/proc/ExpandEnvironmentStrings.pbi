
; https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-expandenvironmentstringsw

Procedure.s ExpandEnvironmentStrings(String.s)
	Protected Result.s
	Protected Length = ExpandEnvironmentStrings_(@String,#Null,0)
	If Length
		Result = Space(Length)
		ExpandEnvironmentStrings_(@String,@Result,Length)
		ProcedureReturn Result
	EndIf
	ProcedureReturn String
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 6
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant