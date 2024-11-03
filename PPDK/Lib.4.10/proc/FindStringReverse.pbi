
; Поиск строки с конца
; Попробовать https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-strrchra

Procedure.i FindStringReverse(String.s,StringToFind.s,StartPosition=0,CaseInSensitive=#PB_String_CaseSensitive)
	If StartPosition = 0
		StartPosition = Len(String)
	;ElseIf StartPosition < 0
	;	StartPosition = Len(String)-StartPosition+1
	EndIf
	Protected length = Len(StringToFind)
	Protected *position = @String+(StartPosition-length)*SizeOf(Character)
	While *position >= @String
		If CompareMemoryString(*position,@StringToFind,CaseInSensitive,length) = 0
			ProcedureReturn (*position-@String)/SizeOf(Character)+1
		EndIf
		*position-SizeOf(Character)
	Wend
	ProcedureReturn 0
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 2
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant