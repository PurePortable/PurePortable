;;======================================================================================================================
; Общие переменные
;;======================================================================================================================

Global PrgPath.s ; полный путь к исполняемому файлу программы
Global PrgDir.s	 ; директория программы с "\" на конце
Global PrgDirN.s ; директория программы без "\" на конце
Global PrgName.s ; имя программы (без расширения)
Global DllPath.s, DllName.s
;Global DllDir.s, DllDirN.s
;Global ProcessID.l

;Global LogFile.s
Global PreferenceFile.s

Global WinDir.s, SysDir.s, TempDir.s

;;======================================================================================================================
; Иницилизация глобальных переменных
;;======================================================================================================================
Global Dim InitProcedures(0)
Macro AddInitProcedure(Proc)
	AddArrayI(InitProcedures(),@Proc())
EndMacro
Macro BeginInitHooks : EndMacro ; заглушка
Macro EndInitHooks : EndMacro ; заглушка

Global DllInstance ; будет иметь то же значение, что и одноимённый параметр в AttachProcess
;Global DllReason ; будет иметь то же значение, что и параметр fdwReason в DllMain
Global FirstProcess
Procedure _GlobalInitialization()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
		!CMP DWORD [AttachProcessCnt],0
		!JNE @f
		!INC [v_FirstProcess]
		!@@:
		!INC DWORD [AttachProcessCnt]
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
		!CMP DWORD [AttachProcessCnt],0
		!JNE @f
		!INC [v_FirstProcess]
		!@@:
		!INC DWORD [AttachProcessCnt]
	CompilerEndIf
	DisableThreadLibraryCalls_(DllInstance) ; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-disablethreadlibrarycalls
	;dbg("AttachProcessCnt: "+StrU(PeekL(?AttachProcessCnt)))
	;ProcessID = GetCurrentProcessId_()
	
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
EndProcedure
DataSection
	!section '.share' data readable writeable shareable
	AttachProcessCnt:
	!AttachProcessCnt: DD 0
	!section '.data' Data readable writeable
EndDataSection
_GlobalInitialization()

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 48
; FirstLine = 18
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant