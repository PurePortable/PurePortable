;;======================================================================================================================
; Общие переменные
;;======================================================================================================================

Global PrgPath.s ; полный путь к исполняемому файлу программы
Global PrgDir.s	 ; директория программы с "\" на конце
Global PrgDirN.s ; директория программы без "\" на конце
Global PrgName.s ; имя программы (без расширения)
Global DllPath.s, DllDir.s, DllDirN.s, DllName.s

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
Procedure _GlobalInitialization()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
	CompilerEndIf

	;DisableThreadLibraryCalls_(Instance)
	
	Protected buf.s = Space(#MAX_PATH_EXTEND)
	
	GetModuleFileName_(0,@buf,#MAX_PATH_EXTEND)
	PrgPath = PeekS(@buf) ; полный путь к исполняемому файлу программы
	PrgDir = GetPathPart(PrgPath)
	PrgDirN = RTrim(PrgDir,"\")
	PrgName = GetFilePart(PrgPath,#PB_FileSystem_NoExtension)
	
	GetModuleFileName_(DllInstance,@buf,#MAX_PATH_EXTEND)
	DllPath = PeekS(@buf) ; полный путь к прокси-dll
	DllDir = GetPathPart(DllPath)
	DllDirN = RTrim(DllDir,"\")
	DllName = GetFilePart(DllPath,#PB_FileSystem_NoExtension)
	
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
EndProcedure
_GlobalInitialization()

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 73
; FirstLine = 40
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant