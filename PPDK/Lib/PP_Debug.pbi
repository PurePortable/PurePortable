﻿;;======================================================================================================================
; Управление выводом отладочных (диагностических) сообщений
;;======================================================================================================================

CompilerIf Not Defined(dbg,#PB_Procedure)
	CompilerIf Not Defined(DBG_PROCESS_ID,#PB_Constant) : #DBG_PROCESS_ID = 0 : CompilerEndIf
	CompilerIf #DBG_PROCESS_ID
		Global DbgProcessId.s = "PORT: ["+Str(ProcessId)+"] "
		Procedure dbg(txt.s="") : OutputDebugString_(DbgProcessId+txt) : EndProcedure
	CompilerElse
		Procedure dbg(txt.s="") : OutputDebugString_("PORT: "+txt) : EndProcedure
	CompilerEndIf
CompilerEndIf
CompilerIf Not Defined(dbgclear,#PB_Procedure)
	Procedure dbgclear() : OutputDebugString_("DBGVIEWCLEAR") : EndProcedure
CompilerEndIf

CompilerIf Not Defined(DBG_ANY,#PB_Constant) : #DBG_ANY = 0 : CompilerEndIf
CompilerIf #DBG_ANY And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;======================================================================================================================
; CompilerIf Not Defined(LOGGING,#PB_Constant) : #LOGGING = 0 : CompilerEndIf
; CompilerIf Not Defined(LOGGING_DBG,#PB_Constant) : #LOGGING_DBG = 0 : CompilerEndIf
; CompilerIf #LOGGING ;Or Not #PORTABLE
; 	CompilerIf #LOGGING_DBG
; 		Macro Logging(s) : dbg(s) : EndMacro
; 		Macro LoggingStart(s) : EndMacro
; 		Macro LoggingEnd(s) : EndMacro
; 	CompilerElse
; 		Global LogFile.s
; 		Procedure Logging(s.s)
; 			Protected hLog = OpenFile(#PB_Any,LogFile,#PB_File_Append)
; 			If hLog
; 				WriteStringN(hLog,s,#PB_Unicode)
; 				CloseFile(hLog)
; 			EndIf
; 		EndProcedure
; 		Procedure LoggingStart(s.s)
; 			Logging(s)
; 		EndProcedure
; 		Procedure LoggingEnd(s.s)
; 			Logging(s)
; 		EndProcedure
; 	CompilerEndIf
; CompilerElse
; 	Macro Logging(s) : EndMacro
; 	Macro LoggingStart(s) : EndMacro
; 	Macro LoggingEnd(s) : EndMacro
; CompilerEndIf

Macro Logging(s) : EndMacro
Macro LoggingStart(s) : EndMacro
Macro LoggingEnd(s) : EndMacro

;;======================================================================================================================
; Procedure _InitDebug()
; 	Global LogFile = PrgDir+PrgName+FormatDate("-%yyyy%mm%dd-%hh%ii%ss.log",Date())
; 	Protected hLog = CreateFile(#PB_Any,LogFile)
; 	If hLog
; 		WriteStringFormat(hLog,#PB_Unicode)
; 		WriteStringN(hLog,PrgPath,#PB_Unicode)
; 		CloseFile(hLog)
; 	EndIf
; EndProcedure
; AddInitProcedure(_InitDebug)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 21
; Folding = --
; EnableThread
; DisableDebugger
; EnableExeConstant