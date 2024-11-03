;;======================================================================================================================
; Модуль BlockConsole
; Блокировка вывода в консоль для возможности запуска из-под консольных программ без вывода на экран мусора
;;======================================================================================================================
; Вопросы:
; - Достаточно перехватывать AttachConsole?
;;======================================================================================================================

CompilerIf Not Defined(DBG_BLOCK_CONSOLE,#PB_Constant) : #DBG_BLOCK_CONSOLE = 0 : CompilerEndIf

CompilerIf #DBG_BLOCK_CONSOLE And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_BLOCK_CONSOLE
	;UndefineMacro DbgAny : DbgAnyDef
	Global DbgConMode = #DBG_BLOCK_CONSOLE
	Procedure DbgCon(txt.s)
		If DbgConMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgCon(txt) : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/console/allocconsole
Prototype AllocConsole()
Global Original_AllocConsole.AllocConsole
Procedure Detour_AllocConsole()
	DbgCon("AllocConsole")
	ProcedureReturn 0
EndProcedure
;Global Trampoline_AllocConsole = @Detour_AllocConsole()
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/console/attachconsole
Prototype AttachConsole(dwProcessId)
Global Original_AttachConsole.AttachConsole
Procedure Detour_AttachConsole(dwProcessId)
	DbgCon("AttachConsole")
	ProcedureReturn 0
EndProcedure
;Global Trampoline_AttachConsole = @Detour_AttachConsole()
;;----------------------------------------------------------------------------------------------------------------------
; Prototype FreeConsole()
; Global Original_FreeConsole.AttachConsole
; Procedure Detour_FreeConsole()
; 	DbgCon("FreeConsole")
; 	ProcedureReturn 0
; EndProcedure
; ;Global Trampoline_FreeConsole = @Detour_FreeConsole()
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/ru-ru/windows/console/setconsolemode
; Prototype SetConsoleMode(hConsoleHandle,dwMode)
; Global Original_SetConsoleMode.SetConsoleMode
; Procedure Detour_SetConsoleMode(hConsoleHandle,dwMode)
; 	DbgCon("SetConsoleMode")
; 	ProcedureReturn 0
; EndProcedure
; ;Global Trampoline_SetConsoleMode = @Detour_SetConsoleMode()
;;----------------------------------------------------------------------------------------------------------------------
; WriteConsoleW
; Prototype WriteConsole(hConsoleOutput,*lpBuffer,nNumberOfCharsToWrite,lpNumberOfCharsWritten,lpReserved)
; Global Original_WriteConsoleA.WriteConsole
; Procedure Detour_WriteConsoleA(hConsoleOutput,*lpBuffer,nNumberOfCharsToWrite,lpNumberOfCharsWritten,lpReserved)
; 	DbgCon("WriteConsoleA")
; 	ProcedureReturn 0
; EndProcedure
; ;Global Trampoline_WriteConsoleA = @Detour_WriteConsoleA()
; Global Original_WriteConsoleW.WriteConsole
; Procedure Detour_WriteConsoleW(hConsoleOutput,*lpBuffer,nNumberOfCharsToWrite,lpNumberOfCharsWritten,lpReserved)
; 	DbgCon("WriteConsoleW")
; 	ProcedureReturn 0
; EndProcedure
; ;Global Trampoline_WriteConsoleW = @Detour_WriteConsoleW()
;;----------------------------------------------------------------------------------------------------------------------
; Prototype SetStdHandle(nStdHandle,hHandle)
; Global Original_SetStdHandle.SetStdHandle
; Procedure Detour_SetStdHandle(nStdHandle,hHandle)
; 	DbgCon("SetStdHandle")
; 	ProcedureReturn 0
; EndProcedure
; ;Global Trampoline_SetStdHandle = @Detour_SetStdHandle()
;;----------------------------------------------------------------------------------------------------------------------
; Prototype GetStdHandle(nStdHandle)
; Global Original_GetStdHandle.GetStdHandle
; Procedure Detour_GetStdHandle(nStdHandle)
; 	DbgCon("GetStdHandle")
; 	SetLastError_(0)
; 	ProcedureReturn #INVALID_HANDLE_VALUE
; EndProcedure
; ;Global Trampoline_GetStdHandle = @Detour_GetStdHandle()
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================

Global BlockConsolePermit = 1
Procedure _InitBlockConsoleHooks()
	If BlockConsolePermit
		MH_HookApi(kernel32,AllocConsole)
		MH_HookApi(kernel32,AttachConsole)
		;MH_HookApi(kernel32,FreeConsole)
		;MH_HookApi(kernel32,SetConsoleMode)
		;MH_HookApi(kernel32,WriteConsoleA)
		;MH_HookApi(kernel32,WriteConsoleW)
		;MH_HookApi(kernel32,SetStdHandle)
		;MH_HookApi(kernel32,GetStdHandle)
	EndIf
EndProcedure
AddInitProcedure(_InitBlockConsoleHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 13
; Folding = -
; DisableDebugger
; EnableExeConstant