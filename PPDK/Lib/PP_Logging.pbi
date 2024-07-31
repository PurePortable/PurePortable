
;=======================================================================================================================
CompilerIf Defined(LOGGING_FILENAME,#PB_Constant)
	Procedure WriteLog(s.s)
		Global LoggingFile.s
		Protected h
		If FileSize(LoggingFile)>=0
			h = OpenFile(#PB_Any,LoggingFile,#PB_File_Append)
		Else
			h = CreateFile(#PB_Any,LoggingFile)
		EndIf
		If h
			WriteStringN(h,s)
			CloseFile(h)
		EndIf
	EndProcedure
CompilerElse
	Macro WriteLog(s) : EndMacro
CompilerEndIf
;=======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 9
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant