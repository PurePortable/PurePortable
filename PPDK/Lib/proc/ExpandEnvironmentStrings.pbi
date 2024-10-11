
; https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-expandenvironmentstringsw

Procedure.s ExpandEnvironment(Txt.s)
	Protected *Buf
	Protected LenBuf = ExpandEnvironmentStrings_(@Txt,#Null,0)
	If LenBuf
		*Buf = AllocateMemory(LenBuf*2)
		ExpandEnvironmentStrings_(@Txt,*Buf,LenBuf)
		Txt = PeekS(*Buf)
		FreeMemory(*Buf)
	EndIf
	ProcedureReturn Txt
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 8
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant