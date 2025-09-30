
#EXECUTE_WAIT = 1
#EXECUTE_HIDE = 2
#EXECUTE_MAX = 4
#EXECUTE_MIN = 8

Procedure.i Execute(Prg.s,Prm.s,ExecuteFlags=0,Dir.s="") ; TODO: Dir
	Protected StartupInfo.STARTUPINFO
	Protected ProcessInfo.PROCESS_INFORMATION
	Protected CreationFlags = #CREATE_DEFAULT_ERROR_MODE | #CREATE_NEW_PROCESS_GROUP
	Protected ExitCode
	StartupInfo\cb = SizeOf(STARTUPINFO)
	;StartupInfo\wShowWindow = #SW_SHOWMAXIMIZED
	Protected CmdLine.s
	If Prg
		CmdLine = Chr(34)+Prg+Chr(34)
		If Prm
			CmdLine+" "+Prm
		EndIf
	Else
		CmdLine = Prm
	EndIf
	If ExecuteFlags & #EXECUTE_HIDE
		StartupInfo\dwFlags | #STARTF_USESHOWWINDOW
		StartupInfo\wShowWindow = #SW_HIDE
	EndIf
	If ExecuteFlags & #EXECUTE_MAX
		StartupInfo\dwFlags | #STARTF_USESHOWWINDOW
		StartupInfo\wShowWindow | #SW_SHOWMAXIMIZED
	EndIf
	If ExecuteFlags & #EXECUTE_MIN
		StartupInfo\dwFlags | #STARTF_USESHOWWINDOW
		StartupInfo\wShowWindow | #SW_SHOWMINIMIZED
	EndIf
	;https://translated.turbopages.org/proxy_u/en-ru.ru.ba073929-6686a092-110882e6-74722d776562/https/stackoverflow.com/questions/17336227/how-can-i-wait-until-an-external-process-has-completed
	;dbg("CreateProcess: "+CmdLine)
	If CreateProcess_(#Null,@CmdLine,#Null,#Null,0,CreationFlags,#Null,#Null,@StartupInfo,@ProcessInfo)
		;dbg("CreateProcess: OK")
		If ExecuteFlags & #EXECUTE_WAIT ; Ждём завершения процесса
			;dbg("WaitForSingleObject")
			WaitForSingleObject_(ProcessInfo\hProcess,#INFINITE)
			;WaitForSingleObjectEx_(ProcessInfo\hProcess,#INFINITE,#True)
			GetExitCodeProcess_(ProcessInfo\hProcess,@ExitCode)
		EndIf
		CloseHandle_(ProcessInfo\hProcess)
		CloseHandle_(ProcessInfo\hThread)
	EndIf
	;dbg("CreateProcess: END")
	ProcedureReturn ExitCode
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 43
; FirstLine = 9
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant