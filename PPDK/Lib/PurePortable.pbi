;;======================================================================================================================
; PurePortable main lib 4.11.0.10
#PP_MAINVERSION = 4.11
;;======================================================================================================================

CompilerIf Not Defined(PB_Compiler_Backend,#PB_Constant) : #PB_Compiler_Backend = 0 : CompilerEndIf
CompilerIf Not Defined(PB_Backend_Asm,#PB_Constant) : #PB_Backend_Asm = 0 : CompilerEndIf
CompilerIf #PB_Compiler_Backend <> #PB_Backend_Asm
	CompilerError "Compiler Backend must be ASM in Compiler-Option"
CompilerEndIf
CompilerIf Not #PB_Compiler_Thread
	CompilerError "Enable threadsafe in compiler options"
CompilerEndIf

CompilerIf Not Defined(PORTABLE_CHECK_PROGRAM,#PB_Constant) : #PORTABLE_CHECK_PROGRAM = 0 : CompilerEndIf
CompilerIf Not Defined(PROXY_DLL_COMPATIBILITY,#PB_Constant) : #PROXY_DLL_COMPATIBILITY = 7 : CompilerEndIf
;#PROXY_DLL_COMPATIBILITY_DEFAULT = 7 ; Это совместимость по умолчанию для #PROXY_DLL_COMPATIBILITY=0 ???
CompilerIf Not Defined(PORTABLE_USE_MUTEX,#PB_Constant) : #PORTABLE_USE_MUTEX = 0 : CompilerEndIf

;{ Символы для кодирования данных
#XNUL = $E000 ; 57344 - Из набора символов для частного использования
#XUS = $E01F
#XSP = $E020
#SP = $0020
#XNUL$ = Chr(#XNUL)
#XUS$ = Chr(#XUS)
#XSP$ = Chr(#XSP)
#SP$ = Chr(#SP)
;}
; Прочие константы
#MAX_PATH_EXTEND = 32767 ; расширенный MAX_PATH

;;======================================================================================================================
; Общая секция для межпроцессного взаимодействия.
DataSection
	!section '.share' data readable writeable shareable notpageable
	DllInstancesCnt:
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!DllInstancesCnt: DD 0
	CompilerElse
		!DllInstancesCnt: DQ 0
	CompilerEndIf
	DllInitComplete:
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!DllInitComplete: DD 0
	CompilerElse
		!DllInitComplete: DQ 0
	CompilerEndIf
	TickCount:
	!DD 0
	bGUID:
	!DB 16 DUP(0)
	sGUID:
	!DU 40 DUP(0)
	!section '.data' data readable writeable
EndDataSection

; Общие переменные
Global ProcessId, ProcessCnt, ProcessCntPrev, SingleProcess, FirstProcess, LastProcess, DllInstancesCnt
Global OSMajorVersion.l, OSMinorVersion.l ;, OSPlatformId.l
Global PPTickCount.l, PPGUID.s
Global ProcessMutexName.s, hProcessMutex, ProcessPipeName.s, hProcessPipe
Global PrgPath.s ; полный путь к исполняемому файлу программы
Global PrgDir.s	 ; директория программы с "\" на конце
Global PrgDirN.s ; директория программы без "\" на конце
Global PrgName.s ; имя программы (без расширения)
Global PrgIsValid ; программа прошла проверку
Global DllPath.s, DllName.s
;Global DllDir.s, DllDirN.s ; это теперь PrgDir и PrgDirN !!!
;Global LogFile.s
Global PreferenceFile.s
Global WinDir.s, SysDir.s, TempDir.s
Global DllInstance ; будет иметь то же значение, что и одноимённый параметр в AttachProcess
;Global DllReason ; будет иметь то же значение, что и параметр fdwReason в DllMain
CompilerIf Not Defined(DBG_DETACH,#PB_Constant) : #DBG_DETACH = 1 : CompilerEndIf
Global DbgDetachMode = #DBG_DETACH
; Инициализация общих переменных
Declare GlobalInitialization()
GlobalInitialization()

;;======================================================================================================================
; Список процедур инициализации.
; Каждый модуль, требующий инициализацию (установку хуков), должен добавить в этот список свою процедуру.
Global Dim ModuleInitProcedures(0)
; Макрос для упрощённого добавления процедуры в список.
; Если что-то поменяется, поменяется макрос, не затрагивая модули.
Macro AddInitProcedure(Proc) : AddArrayI(ModuleInitProcedures(),@Proc()) : EndMacro

;;======================================================================================================================
; Некоторые процедуры
Declare InitProcedure()
Declare ExitProcedure()
Declare AttachProcedure()
Declare DetachProcedure()

;;======================================================================================================================
XIncludeFile "PurePortableCustom.pbi"
XIncludeFile "PP_Debug.pbi"
XIncludeFile "PP_Logging.pbi"
XIncludeFile "PP_Subroutines.pbi"
XIncludeFile "PP_Subroutines2.pbi"
XIncludeFile "PP_ValidateProgram.pbi"
;;======================================================================================================================
CompilerIf Not Defined(PORTABLE_CLEANUP,#PB_Constant) : #PORTABLE_CLEANUP = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_CLEANUP,#PB_Constant) : #DBG_CLEANUP = 0 : CompilerEndIf
CompilerIf #PORTABLE_CLEANUP
	XIncludeFile "PP_Cleanup.pbi"
CompilerElse
	Macro DetachCleanup : EndMacro
	Macro Clean(s) : EndMacro
CompilerEndIf

;;======================================================================================================================

XIncludeFile "PP_Proxy.pbi"

;;======================================================================================================================
; Реестр
CompilerIf Not Defined(PORTABLE_REGISTRY,#PB_Constant) : #PORTABLE_REGISTRY = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_REGISTRY,#PB_Constant) : #DBG_REGISTRY = 0 : CompilerEndIf
CompilerSelect #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
	CompilerCase 1
		XIncludeFile "PP_Registry1.pbi"
	CompilerCase 2
		XIncludeFile "PP_Registry2.pbi"
	CompilerCase 3
		XIncludeFile "PP_Registry2.pbi"
CompilerEndSelect

;;======================================================================================================================
; Специальные папки
CompilerIf Not Defined(PORTABLE_SPECIAL_FOLDERS,#PB_Constant) : #PORTABLE_SPECIAL_FOLDERS = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_SPECIAL_FOLDERS,#PB_Constant) : #DBG_SPECIAL_FOLDERS = 0 : CompilerEndIf
CompilerIf #PORTABLE_SPECIAL_FOLDERS
	XIncludeFile "PP_SpecialFolders.pbi"
CompilerEndIf

;;======================================================================================================================
; Переменные среды
CompilerIf Not Defined(PORTABLE_ENVIRONMENT_VARIABLES,#PB_Constant) : #PORTABLE_ENVIRONMENT_VARIABLES = 0 : CompilerEndIf
CompilerIf Not Defined(PORTABLE_ENVIRONMENT_VARIABLES_CRT,#PB_Constant) : #PORTABLE_ENVIRONMENT_VARIABLES_CRT = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_ENVIRONMENT_VARIABLES,#PB_Constant) : #DBG_ENVIRONMENT_VARIABLES = 0 : CompilerEndIf
CompilerIf #PORTABLE_ENVIRONMENT_VARIABLES Or #PORTABLE_ENVIRONMENT_VARIABLES_CRT
	XIncludeFile "PP_EnvironmentVariables.pbi"
CompilerEndIf

;;======================================================================================================================
; Profile Strings
CompilerIf Not Defined(PORTABLE_PROFILE_STRINGS,#PB_Constant) : #PORTABLE_PROFILE_STRINGS = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_PROFILE_STRINGS,#PB_Constant) : #DBG_PROFILE_STRINGS = 0 : CompilerEndIf
CompilerIf #PORTABLE_PROFILE_STRINGS
	XIncludeFile "PP_ProfileStrings.pbi"
CompilerEndIf

;;======================================================================================================================
; Блокировка интернета
CompilerIf Not Defined(BLOCK_WININET,#PB_Constant) : #BLOCK_WININET = 0 : CompilerEndIf
CompilerIf Not Defined(BLOCK_WINHTTP,#PB_Constant) : #BLOCK_WINHTTP = 0 : CompilerEndIf
CompilerIf Not Defined(BLOCK_WINSOCKS,#PB_Constant) : #BLOCK_WINSOCKS = 0 : CompilerEndIf
CompilerIf Not Defined(BLOCK_WINSOCKS2,#PB_Constant) : #BLOCK_WINSOCKS2 = 0 : CompilerEndIf
;CompilerIf Not Defined(DBG_BLOCK_INTERNET,#PB_Constant) : #DBG_BLOCK_INTERNET = 0 : CompilerEndIf
CompilerIf #BLOCK_WININET Or #BLOCK_WINHTTP Or #BLOCK_WINSOCKS Or #BLOCK_WINSOCKS2
	XIncludeFile "PP_BlockInternet.pbi"
CompilerEndIf

;;======================================================================================================================
; Блокировка консоли (для нормального вызова некоторых программ из консоли)
CompilerIf Not Defined(BLOCK_CONSOLE,#PB_Constant) : #BLOCK_CONSOLE = 0 : CompilerEndIf
CompilerIf #BLOCK_CONSOLE
	XIncludeFile "PP_BlockConsole.pbi"
CompilerEndIf

;;======================================================================================================================
; Блокировка добавления файлов в Recent
CompilerIf Not Defined(BLOCK_RECENT_DOCS,#PB_Constant) : #BLOCK_RECENT_DOCS = 0 : CompilerEndIf
CompilerIf #BLOCK_RECENT_DOCS
	XIncludeFile "PP_BlockRecentDocs.pbi"
CompilerEndIf

;;======================================================================================================================
CompilerIf Not Defined(PORTABLE_ENTRYPOINT,#PB_Constant) : #PORTABLE_ENTRYPOINT = 0 : CompilerEndIf
CompilerIf #PORTABLE_ENTRYPOINT
	XIncludeFile "PP_EntryPointHook.pbi"
CompilerEndIf

;;======================================================================================================================
; Мониторинг некоторых вызовов WinApi
;;======================================================================================================================

CompilerIf Not Defined(DBGX_EXECUTE,#PB_Constant) : #DBGX_EXECUTE = 0 : CompilerEndIf
CompilerIf #DBGX_EXECUTE
	XIncludeFile "PP_DBGX_Execute.pbi"
CompilerEndIf

CompilerIf Not Defined(DBGX_LOAD_LIBRARY,#PB_Constant) : #DBGX_LOAD_LIBRARY = 0 : CompilerEndIf
CompilerIf #DBGX_LOAD_LIBRARY
	XIncludeFile "PP_DBGX_LoadLibrary.pbi"
CompilerEndIf

CompilerIf Not Defined(DBGX_FILE_OPERATIONS,#PB_Constant) : #DBGX_FILE_OPERATIONS = 0 : CompilerEndIf
CompilerIf #DBGX_FILE_OPERATIONS
	XIncludeFile "PP_DBGX_FileOperations.pbi"
CompilerEndIf

CompilerIf Not Defined(DBGX_PROFILE_STRINGS,#PB_Constant) : #DBGX_PROFILE_STRINGS = 0 : CompilerEndIf
CompilerIf #DBGX_PROFILE_STRINGS
	XIncludeFile "PP_DBGX_ProfileStrings.pbi"
CompilerEndIf

CompilerIf Not Defined(DBGX_WINDOWS,#PB_Constant) : #DBGX_WINDOWS = 0 : CompilerEndIf
CompilerIf #DBGX_WINDOWS
	XIncludeFile "PP_DBGX_Windows.pbi"
CompilerEndIf

;;======================================================================================================================
; Список KnownDLLs
; HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs
; Эти dll могут быть использованны только не под своим именем с соответствующей правкой таблицы импорта.
;;======================================================================================================================
; Windows 11 x64
; advapi32.dll clbcatq.dll combase.dll comdlg32.dll coml2.dll difxapi.dll gdi32.dll gdiplus.dll imagehlp.dll imm32.dll kernel32.dll
; msctf.dll msvcrt.dll normaliz.dll nsi.dll ole32.dll oleaut32.dll psapi.dll rpcrt4.dll sechost.dll setupapi.dll shcore.dll shell32.dll
; shlwapi.dll user32.dll wldap32.dll wow64.dll wow64base.dll wow64con.dll wow64cpu.dll wow64win.dll wowarmhw.dll ws2_32.dll xtajit.dll xtajit64.dll

;;======================================================================================================================
; Windows 10
; advapi32.dll clbcatq.dll combase.dll comdlg32.dll coml2.dll difxapi.dll gdi32.dll gdiplus.dll imagehlp.dll imm32.dll kernel32.dll
; msctf.dll msvcrt.dll normaliz.dll nsi.dll ole32.dll oleaut32.dll psapi.dll rpcrt4.dll sechost.dll setupapi.dll shcore.dll shell32.dll
; shlwapi.dll user32.dll wldap32.dll wow64.dll wow64cpu.dll wow64win.dll wowarmhw.dll ws2_32.dll xtajit.dll
;;======================================================================================================================
; Windows 7 x32/x64
; clbcatq.dll ole32.dll advapi32.dll comdlg32.dll gdi32.dll iertutil.dll imagehlp.dll imm32.dll kernel32.dll lpk.dll
; msctf.dll msvcrt.dll normaliz.dll nsi.dll oleaut32.dll psapi.dll rpcrt4.dll sechost.dll setupapi.dll shell32.dll
; shlwapi.dll urlmon.dll user32.dll usp10.dll wininet.dll wldap32.dll ws2_32.dll difxapi.dll
;;======================================================================================================================
; Windows XP
; advapi32.dll comdlg32.dll gdi32.dll imagehlp.dll kernel32.dll lz32.dll ole32.dll oleaut32.dll olecli32.dll olecnv32.dll
; olesvr32.dll olethk32.dll rpcrt4.dll shell32.dll url.dll urlmon.dll user32.dll version.dll wininet.dll wldap32.dll
; !!! Отлиция от следующих версий: lz32.dll url.dll urlmon.dll version.dll wininet.dll

;;======================================================================================================================
; Выбор proxy-dll по имени
CompilerIf Defined(PROXY_DLL,#PB_Constant)
	CompilerIf #PROXY_DLL<>""
		XIncludeFile "Proxy\"+#PROXY_DLL+".pbi"
	CompilerElse
		XIncludeFile "Proxy\pureport.pbi"
	CompilerEndIf
CompilerElseIf Defined(PROXY_DLL_TEST,#PB_Constant)
	CompilerIf #PROXY_DLL_TEST<>""
		#PROXY_DLL = #PROXY_DLL_TEST
		XIncludeFile "ProxyTest\"+#PROXY_DLL_TEST+".pbi"
	CompilerElse
		CompilerError "Constant PROXY_DLL or PROXY_DLL_TEST not defined!"
	CompilerEndIf
CompilerEndIf
; Для принудительного добавления экспорта
CompilerIf Defined(PROXY_DLL_ADDITIONAL,#PB_Constant)
	CompilerIf #PROXY_DLL_ADDITIONAL<>""
		XIncludeFile "Proxy\"+#PROXY_DLL_ADDITIONAL+".pbi"
	CompilerEndIf
CompilerEndIf

;;======================================================================================================================
; Принудительное добавление MinHook
CompilerIf Not Defined(INCLUDE_MIN_HOOK,#PB_Constant) : #INCLUDE_MIN_HOOK = 0 : CompilerEndIf
CompilerIf #INCLUDE_MIN_HOOK
	XIncludeFile "PP_MinHook.pbi"
CompilerEndIf

;;======================================================================================================================
; Принудительное добавление IatHook
CompilerIf Not Defined(INCLUDE_IAT_HOOK,#PB_Constant) : #INCLUDE_IAT_HOOK = 0 : CompilerEndIf
CompilerIf #INCLUDE_IAT_HOOK
	XIncludeFile "PP_IatHook.pbi"
CompilerEndIf

;;======================================================================================================================
CompilerIf Not Defined(PurePortable,#PB_Procedure)
	ProcedureDLL PurePortable(id.l,*param1,*param2,reserved)
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;;======================================================================================================================
; Этот блок должен быть в самом конце, так как только здесь точно становится известно, надо ли инициализировать MinHook и пр.

;;----------------------------------------------------------------------------------------------------------------------
; Хук на отслеживание закрытие окон и сохранение конфигурации
CompilerIf Not Defined(PORTABLE_CBT_HOOK,#PB_Constant) : #PORTABLE_CBT_HOOK = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_CBT_HOOK,#PB_Constant) : #DBG_CBT_HOOK = 0 : CompilerEndIf
CompilerIf #PORTABLE_CBT_HOOK
	XIncludeFile "PP_CBTHook.pbi"
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant) : #DBG_ALWAYS = 0 : CompilerEndIf
CompilerIf #DBG_ALWAYS
	Procedure DbgAlways(Txt.s)
		dbg(Txt)
	EndProcedure
CompilerElse
	Macro DbgAlways(Txt) : EndMacro
CompilerEndIf

;;======================================================================================================================
; Инициализация глобальных переменных, счётчика процесса и пр.
; Описывается здесь, так как только здесь определены все нужные параметры компиляции (костанты).
; А вызывается в начале перед остальными модулями, так как переменные требуются везде.
Procedure GlobalInitialization()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
		!MOV EAX, DWORD [FS:30h]
		!MOV EDX, DWORD [EAX+00A4h]
		!MOV DWORD [v_OSMajorVersion], EDX
		!MOV EDX, DWORD [EAX+00A8h]
		!MOV DWORD [v_OSMinorVersion], EDX
		;!MOV EDX, DWORD [EAX+00B0h]
		;!MOV DWORD [v_OSPlatformId], EDX
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
		!MOV RAX, QWORD [GS:60h]
		!MOV EDX, DWORD [RAX+0118h]
		!MOV DWORD [v_OSMajorVersion], EDX
		!MOV EDX, DWORD [RAX+011Ch]
		!MOV DWORD [v_OSMinorVersion], EDX
		;!MOV EDX, DWORD [RAX+0124h]
		;!MOV DWORD [v_OSPlatformId], EDX
	CompilerEndIf
	
	Protected buf.s = Space(#MAX_PATH_EXTEND)
	
	GetModuleFileName_(0,@buf,#MAX_PATH_EXTEND)
	PrgPath = buf ; полный путь к исполняемому файлу программы
	PrgName = GetFilePart(PrgPath,#PB_FileSystem_NoExtension)
	;PrgDir = GetPathPart(PrgPath)
	;PrgDirN = RTrim(PrgDir,"\")
	
	GetModuleFileName_(DllInstance,@buf,#MAX_PATH_EXTEND)
	DllPath = buf ; полный путь к прокси-dll
	DllName = GetFilePart(DllPath,#PB_FileSystem_NoExtension)
	PrgDir = GetPathPart(DllPath)
	PrgDirN = RTrim(PrgDir,"\")
	
	GetWindowsDirectory_(@buf,#MAX_PATH_EXTEND)
	WinDir = RTrim(buf,"\")
	GetSystemDirectory_(@buf,#MAX_PATH_EXTEND)
	SysDir = RTrim(buf,"\")
	GetTempPath_(#MAX_PATH_EXTEND,@buf)
	TempDir = RTrim(buf,"\")
	
	ProcessId = GetCurrentProcessId_()
EndProcedure
;;======================================================================================================================
; Детач из процесса. Завершение.

; Уменьшение счётчика просессов
Procedure DecDllInstancesCnt()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, -1
		!LOCK XADD DWORD [DllInstancesCnt], EAX
		;!DEC EAX ; а здесь коррекция не нужна, для последнего процесса будет 1
		!MOV DWORD [v_DllInstancesCnt], EAX
		!RET
	CompilerElse
		!MOV RAX, -1
		!LOCK XADD QWORD [DllInstancesCnt], RAX
		;!DEC RAX ; а здесь коррекция не нужна, для последнего процесса будет 1
		!MOV QWORD [v_DllInstancesCnt], RAX
		!ADD RSP,40
		!RET
	CompilerEndIf
EndProcedure

; Общая процедура завершения.
; Может быть вызвана из разных мест, в том числе из DetachProcess и CBT-хуков.
; Отсюда выполняется пользовательская DetachProcedure.
Global ExitProcedureIsComleted ; Истина, если процедура завершения уже была выполнена, например, из CBT-хуков.
Procedure ExitProcedure()
	If ExitProcedureIsComleted
		ProcedureReturn
	EndIf
	DecDllInstancesCnt()
	CompilerIf Defined(MIN_HOOK,#PB_Constant)
		CompilerIf #MIN_HOOK
			MH_Uninitialize()
		CompilerEndIf
	CompilerEndIf
	
	; В это время может завершаться или запускаться другой процесс
	ProcessCntPrev = ProcessCnt
	GetNamedPipeHandleState_(hProcessPipe,#Null,@ProcessCnt,#Null,#Null,#Null,0)
	SingleProcess = Bool(ProcessCnt=1)
	LastProcess = SingleProcess
	CloseHandle_(hProcessPipe)
	
	CompilerIf #PORTABLE_USE_MUTEX
		hProcessMutex = CreateMutex_(#Null,#False,@ProcessMutexName)
		WaitForSingleObject_(hProcessMutex,#INFINITE)
	CompilerEndIf
	Protected r = DetachProcedure()
	CompilerIf #PORTABLE_USE_MUTEX
		ReleaseMutex_(hProcessMutex)
		CloseHandle_(hProcessMutex)
	CompilerEndIf
	If r = 0
		DetachCleanup
	EndIf
	
	ExitProcedureIsComleted = #True
EndProcedure

ProcedureDLL.l DetachProcess(Instance)
	If PrgIsValid
		ExitProcedure()
		CompilerIf #DBG_ALWAYS
			Protected Inst.s = Str(ProcessCnt)
			If LastProcess
				Inst = "LAST"
			EndIf
			If DbgDetachMode
				DbgAlways("DETACHPROCESS: "+DllPath+" ("+Str(ProcessCntPrev)+"/I:"+Str(DllInstancesCnt)+"/P:"+Inst+")")
				DbgAlways("DETACHPROCESS: "+PrgPath)
			EndIf
		CompilerEndIf
	Else
		CompilerIf #DBG_ALWAYS
			If DbgDetachMode
				DbgAlways("DETACHPROCESS: "+DllPath)
				DbgAlways("DETACHPROCESS: "+PrgPath)
			EndIf
		CompilerEndIf
	EndIf
EndProcedure
;;======================================================================================================================
; Аттач к процессу. Инициализация.

; https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/ntifs/ns-ntifs-_public_object_basic_information
; https://learn.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntqueryobject
; https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/ntifs/nf-ntifs-ntqueryobject

; Увеличение счётчика процессов
Procedure IncDllInstancesCnt()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, 1
		!LOCK XADD DWORD [DllInstancesCnt], EAX
		!INC EAX ; коррекция, так как сюда запишется предыдущее значение, для первого процесса станет 1
		!MOV DWORD [v_DllInstancesCnt], EAX
		!RET
	CompilerElse
		!MOV RAX, 1
		!LOCK XADD QWORD [DllInstancesCnt], RAX
		!INC RAX ; коррекция, так как сюда запишется предыдущее значение, для первого процесса станет 1
		!MOV QWORD [v_DllInstancesCnt], RAX
		!ADD RSP,40
		!RET
	CompilerEndIf
EndProcedure

; Общая процедура при старте.
; Нужна для совместимости с проектами, использующими CheckProgram (новые) и не использующие (старые).
Procedure StartProcedure()
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
	; Самый первый раз генерируем GUID, на основе которого будут создаваться уникальные имена.
	If IncDllInstancesCnt() = 1 And PeekI(?DllInitComplete) = 0
		PokeL(?TickCount,GetTickCount_())
		UuidCreate_(?bGUID)
		StringFromGUID2_(?bGUID,?sGUID,40)
		PokeI(?DllInitComplete,1)
	EndIf
	PPGUID = PeekS(?sGUID)
	PPTickCount = PeekL(?TickCount)
	ProcessMutexName = "PP."+PrgName+"."+PPGUID
	ProcessPipeName = "\\.\pipe\"+ProcessMutexName
	;ProcessPipeName = "\\.\pipe\PP."+PrgName+"."+PPGUID
	
	hProcessPipe = CreateNamedPipe_(@ProcessPipeName,#PIPE_ACCESS_DUPLEX,0,#PIPE_UNLIMITED_INSTANCES,16,16,0,#Null)
	If hProcessPipe
		; https://learn.microsoft.com/ru-ru/windows/win32/api/winbase/nf-winbase-getnamedpipehandlestatew
		GetNamedPipeHandleState_(hProcessPipe,#Null,@ProcessCnt,#Null,#Null,#Null,0)
		SingleProcess = Bool(ProcessCnt=1)
		FirstProcess = SingleProcess
	Else
		dbg("CreateNamedPipe: «"+ProcessPipeName+"»")
		dbg("CreateNamedPipe: "+GetLastErrorStr())
	EndIf
	
	;dbg("GUID: "+ProcessGUID+" TC: "+Str(ProcessTickCount))
	;DisableThreadLibraryCalls_(DllInstance) ; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-disablethreadlibrarycalls
EndProcedure

CompilerIf Defined(PORTABLE_CHECK_PROGRAM,#PB_Constant)
	Declare CheckProgram()	
CompilerEndIf

Prototype InitProcProto()
DeclareImport(kernel32,_GetModuleHandleExW@12,GetModuleHandleExW,GetModuleHandleEx_(dwFlags.l,*lpModuleName,*phModule))
ProcedureDLL.l AttachProcess(Instance)
	DbgAlways("ATTACHPROCESS: "+PrgPath)
	Protected hDll
	If GetFileVersionInfo(PrgPath,"InternalName") = "rundll"
		;PrgIsValid = 0
		DbgAlways("ATTACHPROCESS: "+DllPath)
		ProcedureReturn
	EndIf
	CompilerIf #PORTABLE_CHECK_PROGRAM
		If CheckProgram() = #INVALID_PROGRAM
			;PrgIsValid = 0
			DbgAlways("ATTACHPROCESS: "+DllPath)
			ProcedureReturn
		EndIf
		StartProcedure()
		CompilerIf #PORTABLE_USE_MUTEX
			hProcessMutex = CreateMutex_(#Null,#False,@ProcessMutexName)
			WaitForSingleObject_(hProcessMutex,#INFINITE)
		CompilerEndIf
		AttachProcedure()
		CompilerIf #PORTABLE_USE_MUTEX
			ReleaseMutex_(hProcessMutex)
			CloseHandle_(hProcessMutex)
		CompilerEndIf
	CompilerElse
		; Для совместимости - когда нет CheckProgram, проверка осуществляется в AttachProcedure.
		StartProcedure()
		If AttachProcedure() = #INVALID_PROGRAM
			;PrgIsValid = 0
			DbgAlways("ATTACHPROCESS: "+DllPath)
			ProcedureReturn
		EndIf
	CompilerEndIf

	PrgIsValid = 1
	GetModuleHandleEx_(#GET_MODULE_HANDLE_EX_FLAG_PIN,@DllPath,@hDll) ; запретить выгрузку из памяти https://www.manhunter.ru/assembler/1950_kak_zaschitit_dll_ot_vigruzki_cherez_freelibrary.html
	
	Protected i, InitProc.InitProcProto
	For i=1 To ArraySize(ModuleInitProcedures())
		InitProc = ModuleInitProcedures(i)
		If InitProc
			InitProc()
		EndIf
	Next
	CompilerIf Defined(MIN_HOOK,#PB_Constant)
		CompilerIf #MIN_HOOK
			MH_EnableHook(#MH_ALL_HOOKS)
		CompilerEndIf
	CompilerEndIf
	Protected Inst.s = Str(ProcessCnt)
	If FirstProcess
		Inst = "FIRST"
	EndIf
	DbgAlways("ATTACHPROCESS: "+DllPath+" (I:"+Str(DllInstancesCnt)+"/P:"+Inst+")")
	;DbgAlways("ATTACHPROCESS: Complete")
EndProcedure
;;======================================================================================================================
; Для тестирования
CompilerIf #PB_Compiler_IsMainFile
	Procedure AttachProcedure()
	EndProcedure
	Procedure DetachProcedure()
	EndProcedure
CompilerEndIf
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; Folding = OB9
; EnableThread
; DisableDebugger
; EnableExeConstant
; EnableUnicode