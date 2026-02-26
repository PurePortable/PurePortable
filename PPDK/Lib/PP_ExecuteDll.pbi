;;======================================================================================================================
; CommandLineToArgvW
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-commandlinetoargvw
; https://vsokovikov.narod.ru/New_MSDN_API/Process_thread/fn_commandlinetoargvw.htm

XIncludeFile "proc\Execute.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"

CompilerIf Not Defined(DBG_EXECUTEDLL,#PB_Constant) : #DBG_EXECUTEDLL = 0 : CompilerEndIf

CompilerIf #DBG_EXECUTEDLL And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

Global DbgExecMode = #DBG_EXECUTEDLL
CompilerIf #DBG_EXECUTEDLL
	Procedure DbgExec(txt.s)
		If DbgExecMode
			dbg("PurePortableExecute: "+txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgExec(txt) : EndMacro
CompilerEndIf

Procedure ExecuteDll(CmdLine.s,ExecuteFlags=0)
	CmdLine = Chr(34)+DllPath+Chr(34)+",PurePortableExecute "+Str(ExecuteFlags)+" "+ExpandEnvironmentStrings(CmdLine)
	DbgExec(SysDir+"\rundll32.exe "+CmdLine)
	Execute(SysDir+"\rundll32.exe",CmdLine,ExecuteFlags&#EXECUTE_WAIT)
EndProcedure

ProcedureDLL PurePortableExecute(hWnd,hInst,*lpszCmdLine,nCmdShow)
	; Командная строка: rundll32 путь_к_dll,PurePortableExecute флаги Командная_строка_запускаемой программы
	Protected ExecuteFlags = Val(ProgramParameter(2))
	Protected CmdLine.s = PeekS(GetCommandLine_())
	DbgExecMode = ExecuteFlags & #EXECUTE_DBG
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем вызов rundll32.exe
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем dll и имя функции
	;dbg("«"+CmdLine+"»")
	CmdLine = PeekS(PathGetArgs_(@CmdLine)) ; отбрасываем первый параметр
	;dbg("«"+CmdLine+"»")
	DbgExec(CmdLine)
	Execute("",CmdLine,ExecuteFlags)
EndProcedure

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 18
; FirstLine = 5
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant