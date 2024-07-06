; https://learn.microsoft.com/ru-ru/windows/win32/procthread/creating-processes
; https://learn.microsoft.com/ru-ru/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessa
; https://learn.microsoft.com/ru-ru/windows/win32/api/synchapi/nf-synchapi-waitforsingleobject
; https://learn.microsoft.com/ru-ru/windows/win32/api/synchapi/nf-synchapi-waitforsingleobjectex

; https://www.transl-gunsmoker.ru/2011/08/undocumented-createprocess.html
; https://www.gunsmoker.ru/2009/07/createprocess.html

; https://www.gunsmoker.ru/2015/01/never-use-ShellExecute.html

#EXECUTE_WAIT = 1
#EXECUTE_HIDE = 2

Procedure Execute(Prg.s,Prm.s,Flags=0,Dir.s="") ; TODO: Dir
	Protected StartupInfo.STARTUPINFO
	Protected ProcessInfo.PROCESS_INFORMATION
	Protected Error
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
	If flags & #EXECUTE_HIDE
		StartupInfo\dwFlags | #STARTF_USESHOWWINDOW
		StartupInfo\wShowWindow = #SW_HIDE
	;Else
	;	StartupInfo\dwFlags | #STARTF_USESHOWWINDOW
	;	StartupInfo\wShowWindow = #SW_SHOW
	EndIf
	;https://translated.turbopages.org/proxy_u/en-ru.ru.ba073929-6686a092-110882e6-74722d776562/https/stackoverflow.com/questions/17336227/how-can-i-wait-until-an-external-process-has-completed
	If CreateProcess_(#Null,@CmdLine,#Null,#Null,#False,flags,#Null,#Null,@StartupInfo,@ProcessInfo)
		If flags & #EXECUTE_WAIT ; Ждём завершения процесса
			WaitForSingleObject_(ProcessInfo\hProcess,#INFINITE)
			;WaitForSingleObjectEx_(ProcessInfo\hProcess,#INFINITE,#True)
			;GetExitCodeProcess_(ProcessInfo\hProcess,@ExitCode)
		EndIf
		CloseHandle_(ProcessInfo\hProcess)
		CloseHandle_(ProcessInfo\hThread)
	EndIf
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 39
; FirstLine = 12
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant