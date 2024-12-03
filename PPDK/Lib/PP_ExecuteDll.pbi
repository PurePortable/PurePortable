;;======================================================================================================================
; CommandLineToArgvW
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-commandlinetoargvw
; https://vsokovikov.narod.ru/New_MSDN_API/Process_thread/fn_commandlinetoargvw.htm

XIncludeFile "proc\Execute.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"

Procedure ExecuteDll(CmdLine.s,ExecuteFlags=0)
	Execute(SysDir+"\rundll32.exe",Chr(34)+DllPath+Chr(34)+",PurePortableExecute "+Str(ExecuteFlags)+" "+ExpandEnvironmentStrings(CmdLine),ExecuteFlags&#EXECUTE_WAIT)
EndProcedure

ProcedureDLL PurePortableExecute(hWnd,hInst,*lpszCmdLine,nCmdShow)
	; Командная строка: rundll32 путь_к_dll,PurePortableExecute флаги Командная_строка_запускаемой программы
	Protected ExecuteFlags = Val(ProgramParameter(2))
	Protected CmdLine.s = PeekS(GetCommandLine_())
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем вызов rundll32.exe
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем dll и имя функции
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем первый параметр
	;dbg("«"+CmdLine+"»")
	Execute("",CmdLine,ExecuteFlags)
EndProcedure

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant