;;======================================================================================================================
; PurePortable main lib 4.10.0.30
#PP_MAINVERSION = 4.10
;;======================================================================================================================

CompilerIf Not Defined(PB_Compiler_Backend,#PB_Constant) : #PB_Compiler_Backend = 0 : CompilerEndIf
CompilerIf Not Defined(PB_Backend_Asm,#PB_Constant) : #PB_Backend_Asm = 0 : CompilerEndIf
CompilerIf #PB_Compiler_Backend <> #PB_Backend_Asm
	CompilerError "Compiler Backend must be ASM in Compiler-Option"
CompilerEndIf
CompilerIf Not #PB_Compiler_Thread
	CompilerError "Enable threadsafe in compiler options"
CompilerEndIf

;;======================================================================================================================
Global ProcessId
;;======================================================================================================================

CompilerIf Not Defined(PROXY_DLL_COMPATIBILITY,#PB_Constant) : #PROXY_DLL_COMPATIBILITY = 7 : CompilerEndIf
;#PROXY_DLL_COMPATIBILITY_DEFAULT = 7 ; Это совместимость по умолчанию для #PROXY_DLL_COMPATIBILITY=0 ???

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
#MAX_PATH_EXTEND = 32767
XIncludeFile "PurePortableCustom.pbi"
XIncludeFile "PP_Debug.pbi"
XIncludeFile "PP_Logging.pbi"
XIncludeFile "PP_Subroutines.pbi"
XIncludeFile "PP_Subroutines2.pbi"
XIncludeFile "PP_Initialization.pbi"
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
CompilerIf Not Defined(DBG_ENVIRONMENT_VARIABLES,#PB_Constant) : #DBG_ENVIRONMENT_VARIABLES = 0 : CompilerEndIf
CompilerIf #PORTABLE_ENVIRONMENT_VARIABLES
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
; Хук на отслеживание закрытие окон и сохранение конфигурации
CompilerIf Not Defined(PORTABLE_CBT_HOOK,#PB_Constant) : #PORTABLE_CBT_HOOK = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_CBT_HOOK,#PB_Constant) : #DBG_CBT_HOOK = 0 : CompilerEndIf
CompilerIf #PORTABLE_CBT_HOOK
	XIncludeFile "PP_CBTHook.pbi"
CompilerEndIf

;;======================================================================================================================
CompilerIf Not Defined(PurePortable,#PB_Procedure) And #PB_Compiler_ExecutableFormat=#PB_Compiler_DLL
	ProcedureDLL PurePortable(id.l,*param1,*param2,reserved)
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;;======================================================================================================================
; Этот блок должен быть в самом конце, так как только здесь точно становится известно, надо ли инициализировать MinHook.
Prototype InitProcedure()
Global PPInitializationComplete
Procedure _PPInitialization()
	Protected i, InitProcedure.InitProcedure
	For i=1 To ArraySize(InitProcedures())
		InitProcedure = InitProcedures(i)
		If InitProcedure
			InitProcedure()
		EndIf
	Next
	CompilerIf Defined(MIN_HOOK,#PB_Constant)
		CompilerIf #MIN_HOOK
			MH_EnableHook(#MH_ALL_HOOKS)
		CompilerEndIf
	CompilerEndIf
	PPInitializationComplete = #True
	CompilerIf #DBG_ALWAYS
		dbg("ATTACHPROCESS: Complete")
	CompilerEndIf
EndProcedure
Macro PPInitialization
	_PPInitialization()
EndMacro
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 1
; Folding = +
; EnableThread
; DisableDebugger
; EnableExeConstant
; EnableUnicode