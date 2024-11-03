;;======================================================================================================================
CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 0
CompilerEndIf
;;======================================================================================================================
; Общая секция для межпроцессного взаимодействия.
DataSection
	!section '.share' data readable writeable shareable notpageable
	ProcessCnt:
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!ProcessCnt: DD 0
	CompilerElse
		!ProcessCnt: DQ 0
	CompilerEndIf
	!section '.data' data readable writeable
EndDataSection
;;======================================================================================================================
; Иницилизация
;;======================================================================================================================
Macro BeginInitHooks : EndMacro ; заглушка
Macro EndInitHooks : EndMacro ; заглушка

Global DllInstance ; будет иметь то же значение, что и одноимённый параметр в AttachProcess
;Global DllReason ; будет иметь то же значение, что и параметр fdwReason в DllMain
Global ProcessCnt
Global FirstProcess
Global LastProcess
Procedure PPGlobalInitialization()
	CompilerIf #DBG_ALWAYS
		DbgDetach = 1
	CompilerEndIf

	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
		!MOV EAX, 1
		!LOCK XADD DWORD [ProcessCnt], EAX
		!INC EAX
		!MOV DWORD [v_ProcessCnt], EAX
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
		!MOV RAX, 1
		!LOCK XADD QWORD [ProcessCnt], RAX
		!INC RAX
		!MOV QWORD [v_ProcessCnt], RAX
	CompilerEndIf
	FirstProcess = Bool(ProcessCnt=1)
	;DisableThreadLibraryCalls_(DllInstance) ; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-disablethreadlibrarycalls
	ProcessId = GetCurrentProcessId_()
	
	Protected buf.s = Space(#MAX_PATH_EXTEND)
	
	GetModuleFileName_(0,@buf,#MAX_PATH_EXTEND)
	PrgPath = PeekS(@buf) ; полный путь к исполняемому файлу программы
	PrgName = GetFilePart(PrgPath,#PB_FileSystem_NoExtension)
	;PrgDir = GetPathPart(PrgPath)
	;PrgDirN = RTrim(PrgDir,"\")
	
	GetModuleFileName_(DllInstance,@buf,#MAX_PATH_EXTEND)
	DllPath = PeekS(@buf) ; полный путь к прокси-dll
	DllName = GetFilePart(DllPath,#PB_FileSystem_NoExtension)
	PrgDir = GetPathPart(DllPath)
	PrgDirN = RTrim(PrgDir,"\")
	
	GetWindowsDirectory_(@buf,#MAX_PATH_EXTEND)
	WinDir = RTrim(buf,"\")
	GetSystemDirectory_(@buf,#MAX_PATH_EXTEND)
	SysDir = RTrim(buf,"\")
	GetTempPath_(#MAX_PATH_EXTEND,@buf)
	TempDir = RTrim(buf,"\")
	
	CompilerIf Defined(PREFERENCES_FILENAME,#PB_Constant)
		CompilerIf #PREFERENCES_FILENAME<>""
			PreferenceFile = PrgDir+#PREFERENCES_FILENAME
			If GetExtensionPart(PreferenceFile)=""
				PreferenceFile + ".prefs"
			EndIf
		CompilerElse
			PreferenceFile = PrgDir+PrgName+".prefs"
		CompilerEndIf
	CompilerEndIf
	
	CompilerIf Defined(LOGGING_FILENAME,#PB_Constant)
		Global LoggingFile.s
		CompilerIf #LOGGING_FILENAME<>""
			LoggingFile = PrgDir+#LOGGING_FILENAME
			If GetExtensionPart(LoggingFile)=""
				LoggingFile + ".log"
			EndIf
		CompilerElse
			LoggingFile = PrgDir+PrgName+".log"
		CompilerEndIf
	CompilerEndIf
	CompilerIf #DBG_ALWAYS
		dbg("ATTACHPROCESS: "+PrgPath)
		dbg("ATTACHPROCESS: "+DllPath+" ("+Str(ProcessCnt)+")")
	CompilerEndIf
EndProcedure
;;======================================================================================================================
Procedure _PPAttachProcess()
	;DisableThreadLibraryCalls_(DllInstance) ; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-disablethreadlibrarycalls
EndProcedure
Macro PPPreparation ; depricated
	_PPAttachProcess()
EndMacro
Macro PPAttachProcess
	_PPAttachProcess()
EndMacro
;;======================================================================================================================
; Завершение
Procedure _PPDetachProcess()
	CompilerIf #DBG_ALWAYS
		If DbgDetach
			dbg("DETACHPROCESS: "+DllPath+" ("+Str(ProcessCnt)+")")
		EndIf
	CompilerEndIf
	LastProcess = Bool(ProcessCnt=1)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!PUSH EAX
		!MOV EAX, -1
		!LOCK XADD DWORD [ProcessCnt], EAX
		!DEC EAX
		!MOV DWORD [v_ProcessCnt], EAX
		!POP EAX
	CompilerElse
		!PUSH RAX
		!MOV RAX, -1
		!LOCK XADD QWORD [ProcessCnt], RAX
		!DEC RAX
		!MOV QWORD [v_ProcessCnt], RAX
		!POP RAX
	CompilerEndIf
EndProcedure
Procedure _PPDetachProcessEnd()
	CompilerIf #DBG_ALWAYS
		If DbgDetach
			dbg("DETACHPROCESS: "+PrgPath)
		EndIf
	CompilerEndIf
EndProcedure

Procedure DbgAny(txt.s)
	If Left(txt,3)="CBT" ; обеспечиваем совместимость для CBT-хуков
		dbg(txt)
	Else
		_PPDetachProcessEnd()
	EndIf
EndProcedure
Macro PPDetachProcess
	_PPDetachProcess()
EndMacro
Macro PPFinish ; depricated
	_PPDetachProcessEnd()
EndMacro
Macro PPDetachProcessEnd
	_PPDetachProcessEnd()
EndMacro
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 27
; FirstLine = 6
; Folding = XD-
; EnableThread
; DisableDebugger
; EnableExeConstant