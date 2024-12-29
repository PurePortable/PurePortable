;;======================================================================================================================
; Мониторинг различных методов запуска программ.
;;======================================================================================================================

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DBGX_EXECUTE = 1
	CompilerIf Not Defined(DETOUR_CREATEPROCESS,#PB_Constant) : #DETOUR_CREATEPROCESS = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHELLEXECUTE,#PB_Constant) : #DETOUR_SHELLEXECUTE = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHELLEXECUTEEX,#PB_Constant) : #DETOUR_SHELLEXECUTEEX = 1 : CompilerEndIf
CompilerElseIf #DBGX_EXECUTE = 2
	CompilerIf Not Defined(DETOUR_CREATEPROCESS,#PB_Constant) : #DETOUR_CREATEPROCESS = 1 : CompilerEndIf
CompilerEndIf

CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutew
CompilerIf Not Defined(DETOUR_SHELLEXECUTE,#PB_Constant) : #DETOUR_SHELLEXECUTE=0 : CompilerEndIf
CompilerIf #DETOUR_SHELLEXECUTE
	Prototype ShellExecute(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
	Global Original_ShellExecuteA.ShellExecute
	Procedure Detour_ShellExecuteA(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
		dbg("ShellExecuteA: «"+PeekSZ(lpOperation,-1,#PB_Ascii)+"» «"+PeekSZ(lpFile,-1,#PB_Ascii)+"» «"+PeekSZ(lpParameters,-1,#PB_Ascii)+"»")
		ProcedureReturn Original_ShellExecuteA(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
	EndProcedure
	Global Original_ShellExecuteW.ShellExecute
	Procedure Detour_ShellExecuteW(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
		dbg("ShellExecuteW: «"+PeekSZ(lpOperation)+"» «"+PeekSZ(lpFile)+"» «"+PeekSZ(lpParameters)+"»")
		ProcedureReturn Original_ShellExecuteW(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecuteexw
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-shellexecuteinfow
CompilerIf Not Defined(DETOUR_SHELLEXECUTEEX,#PB_Constant) : #DETOUR_SHELLEXECUTEEX=0 : CompilerEndIf
CompilerIf #DETOUR_SHELLEXECUTEEX
	Prototype ShellExecuteEx(*pExecInfo.SHELLEXECUTEINFO)
	Global Original_ShellExecuteExA.ShellExecuteEx
	Procedure Detour_ShellExecuteExA(*pExecInfo.SHELLEXECUTEINFO)
		dbg("ShellExecuteExA: «"+PeekSZ(*pExecInfo\lpVerb,-1,#PB_Ascii)+"» «"+PeekSZ(*pExecInfo\lpFile,-1,#PB_Ascii)+"» «"+PeekSZ(*pExecInfo\lpParameters,-1,#PB_Ascii)+"»")
		ProcedureReturn Original_ShellExecuteExA(*pExecInfo)
	EndProcedure
	Global Original_ShellExecuteExW.ShellExecuteEx
	Procedure Detour_ShellExecuteExW(*pExecInfo.SHELLEXECUTEINFO)
		dbg("ShellExecuteExW: «"+PeekSZ(*pExecInfo\lpVerb)+"» «"+PeekSZ(*pExecInfo\lpFile)+"» «"+PeekSZ(*pExecInfo\lpParameters)+"»")
		ProcedureReturn Original_ShellExecuteExW(*pExecInfo)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
;Global ApplicationNameEx.s, CommandLineEx.s
CompilerIf Not Defined(DETOUR_CREATEPROCESS,#PB_Constant) : #DETOUR_CREATEPROCESS=0 : CompilerEndIf
CompilerIf #DETOUR_CREATEPROCESS
	Prototype CreateProcess(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
	Global Original_CreateProcessA.CreateProcess
	Procedure Detour_CreateProcessA(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
		Protected ApplicationName.s = PeekSZ(lpApplicationName,-1,#PB_Ascii)
		Protected CommandLine.s = PeekSZ(lpCommandLine,-1,#PB_Ascii)
		dbg("CreateProcessA: «"+ApplicationName+"» «"+CommandLine+"»")
		;ApplicationNameEx = ExpandEnvironmentStrings(ApplicationName)
		;CommandLineEx = ExpandEnvironmentStrings(CommandLine)
		;ProcedureReturn Original_CreateProcessA(@ApplicationNameEx,@CommandLineEx,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo,*ProcessInformation)
		Protected Result = Original_CreateProcessA(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo,*ProcessInformation)
		dbg("CreateProcessA: "+StrU(*ProcessInformation\dwProcessId))
		ProcedureReturn Result
	EndProcedure
	Global Original_CreateProcessW.CreateProcess
	Procedure Detour_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
		Protected ApplicationName.s = PeekSZ(lpApplicationName)
		Protected CommandLine.s = PeekSZ(lpCommandLine)
		dbg("CreateProcessW: «"+ApplicationName+"» «"+CommandLine+"»")
		;ApplicationNameEx = ExpandEnvironmentStrings(ApplicationName)
		;CommandLineEx = ExpandEnvironmentStrings(CommandLine)
		;ProcedureReturn Original_CreateProcessW(@ApplicationNameEx,@CommandLineEx,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation)
		Protected Result = Original_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation)
		dbg("CreateProcessW: "+StrU(*ProcessInformation\dwProcessId))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

Procedure _InitDbgxExecuteHooks()
	CompilerIf #DETOUR_SHELLEXECUTE Or #DETOUR_SHELLEXECUTEEX
		LoadLibrary_(@"shell32.dll")
	CompilerEndIf
	CompilerIf #DETOUR_SHELLEXECUTE : MH_HookApi(shell32,ShellExecuteA) : CompilerEndIf
	CompilerIf #DETOUR_SHELLEXECUTE : MH_HookApi(shell32,ShellExecuteW) : CompilerEndIf
	CompilerIf #DETOUR_SHELLEXECUTEEX : MH_HookApi(shell32,ShellExecuteExA) : CompilerEndIf
	CompilerIf #DETOUR_SHELLEXECUTEEX : MH_HookApi(shell32,ShellExecuteExW) : CompilerEndIf
	;CompilerIf #DETOUR_GETCOMMANDLINE : MH_HookApi(kernel32,GetCommandLineA) : CompilerEndIf
	;CompilerIf #DETOUR_GETCOMMANDLINE : MH_HookApi(kernel32,GetCommandLineW) : CompilerEndIf
	CompilerIf #DETOUR_CREATEPROCESS : MH_HookApi(kernel32,CreateProcessA) : CompilerEndIf
	CompilerIf #DETOUR_CREATEPROCESS : MH_HookApi(kernel32,CreateProcessW) : CompilerEndIf
EndProcedure
AddInitProcedure(_InitDbgxExecuteHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; Folding = A+
; EnableThread
; DisableDebugger
; EnableExeConstant