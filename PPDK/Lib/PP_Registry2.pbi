;;======================================================================================================================
; Модуль Registry2
; Портабелизация реестра
;;======================================================================================================================
; TODO
; - Проверять RegClose на закрытие hAppKey
; - Надо что-то делать с DbgRegAliens

;;======================================================================================================================
; Вопрос
; Вызывающий процесс должен иметь привилегии SE_RESTORE_NAME и SE_BACKUP_NAME на компьютере, на котором находится реестр.
; RegLoadKey() is the API and you must have backup/restore priviledges
; SeBackupPrivilege SeRestorePrivilege AdjustTokenPrivileges
; https://learn.microsoft.com/ru-ru/windows/win32/secauthz/privilege-constants нет упоминания RegLoadAppKey
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regloadkeya
;;----------------------------------------------------------------------------------------------------------------------
; Вызывающий процесс должен иметь права SE_RESTORE_NAME и SE_BACKUP_NAME на компьютере, на котором находится реестр.
; Дополнительные сведения см. в разделе Выполнение с особыми привилегиями.
; Чтобы загрузить куст без этих специальных привилегий, используйте функцию RegLoadAppKey
;;======================================================================================================================
; https://learn.microsoft.com/en-us/windows/win32/sysinfo/registry-hives
;;======================================================================================================================

CompilerIf Not Defined(DETOUR_REG_SHLWAPI,#PB_Constant) : #DETOUR_REG_SHLWAPI = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REG_TRANSACTED,#PB_Constant) : #DETOUR_REG_TRANSACTED = 0 : CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------

;{ Дополнительное управление функциями
CompilerIf Not Defined(DETOUR_REGCLOSEKEY,#PB_Constant)        : #DETOUR_REGCLOSEKEY = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGFLUSHKEY,#PB_Constant)        : #DETOUR_REGFLUSHKEY = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYA,#PB_Constant)      : #DETOUR_REGCREATEKEYA = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYW,#PB_Constant)      : #DETOUR_REGCREATEKEYW = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYEXA,#PB_Constant)    : #DETOUR_REGCREATEKEYEXA = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYEXW,#PB_Constant)    : #DETOUR_REGCREATEKEYEXW = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYA,#PB_Constant)        : #DETOUR_REGOPENKEYA = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYW,#PB_Constant)        : #DETOUR_REGOPENKEYW = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYEXA,#PB_Constant)      : #DETOUR_REGOPENKEYEXA = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYEXW,#PB_Constant)      : #DETOUR_REGOPENKEYEXW = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYA,#PB_Constant)      : #DETOUR_REGDELETEKEYA = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYW,#PB_Constant)      : #DETOUR_REGDELETEKEYW = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYEXA,#PB_Constant)    : #DETOUR_REGDELETEKEYEXA = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYEXW,#PB_Constant)    : #DETOUR_REGDELETEKEYEXW = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETETREEA,#PB_Constant)     : #DETOUR_REGDELETETREEA = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETETREEW,#PB_Constant)     : #DETOUR_REGDELETETREEW = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYVALUEA,#PB_Constant) : #DETOUR_REGDELETEKEYVALUEA = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYVALUEW,#PB_Constant) : #DETOUR_REGDELETEKEYVALUEW = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGQUERYVALUEA,#PB_Constant)     : #DETOUR_REGQUERYVALUEA = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGQUERYVALUEW,#PB_Constant)     : #DETOUR_REGQUERYVALUEW = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGGETVALUEA,#PB_Constant)       : #DETOUR_REGGETVALUEA = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGGETVALUEW,#PB_Constant)       : #DETOUR_REGGETVALUEW = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETVALUEA,#PB_Constant)       : #DETOUR_REGSETVALUEA = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETVALUEW,#PB_Constant)       : #DETOUR_REGSETVALUEW = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETKEYVALUEA,#PB_Constant)    : #DETOUR_REGSETKEYVALUEA = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETKEYVALUEW,#PB_Constant)    : #DETOUR_REGSETKEYVALUEW = 1    : CompilerEndIf

CompilerIf #DETOUR_REG_TRANSACTED Or #PORTABLE_REG_TRANSACTED
	CompilerIf Not Defined(DETOUR_REGCREATEKEYTRANSACTEDA,#PB_Constant) : #DETOUR_REGCREATEKEYTRANSACTEDA = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGCREATEKEYTRANSACTEDW,#PB_Constant) : #DETOUR_REGCREATEKEYTRANSACTEDW = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGDELETEKEYTRANSACTEDA,#PB_Constant) : #DETOUR_REGDELETEKEYTRANSACTEDA = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGDELETEKEYTRANSACTEDW,#PB_Constant) : #DETOUR_REGDELETEKEYTRANSACTEDW = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGOPENKEYTRANSACTEDA,#PB_Constant)   : #DETOUR_REGOPENKEYTRANSACTEDA = 1   : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGOPENKEYTRANSACTEDW,#PB_Constant)   : #DETOUR_REGOPENKEYTRANSACTEDW = 1   : CompilerEndIf
CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYTRANSACTEDA,#PB_Constant) : #DETOUR_REGCREATEKEYTRANSACTEDA = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYTRANSACTEDW,#PB_Constant) : #DETOUR_REGCREATEKEYTRANSACTEDW = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYTRANSACTEDA,#PB_Constant) : #DETOUR_REGDELETEKEYTRANSACTEDA = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYTRANSACTEDW,#PB_Constant) : #DETOUR_REGDELETEKEYTRANSACTEDW = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYTRANSACTEDA,#PB_Constant)   : #DETOUR_REGOPENKEYTRANSACTEDA = 0   : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYTRANSACTEDW,#PB_Constant)   : #DETOUR_REGOPENKEYTRANSACTEDW = 0   : CompilerEndIf

CompilerIf #DETOUR_REG_SHLWAPI Or #PORTABLE_REG_SHLWAPI
	CompilerIf Not Defined(DETOUR_SHDELETEKEYA,#PB_Constant)      : #DETOUR_SHDELETEKEYA = 1      : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEKEYW,#PB_Constant)      : #DETOUR_SHDELETEKEYW = 1      : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEYA,#PB_Constant) : #DETOUR_SHDELETEEMPTYKEYA = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEYW,#PB_Constant) : #DETOUR_SHDELETEEMPTYKEYW = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEVALUEA,#PB_Constant)    : #DETOUR_SHDELETEVALUEA = 1    : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEVALUEW,#PB_Constant)    : #DETOUR_SHDELETEVALUEW = 1    : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHGETVALUEA,#PB_Constant)       : #DETOUR_SHGETVALUEA = 1       : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHGETVALUEW,#PB_Constant)       : #DETOUR_SHGETVALUEW = 1       : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHREGGETVALUEA,#PB_Constant)    : #DETOUR_SHREGGETVALUEA = 1    : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHREGGETVALUEW,#PB_Constant)    : #DETOUR_SHREGGETVALUEW = 1    : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHCOPYKEYA,#PB_Constant)        : #DETOUR_SHCOPYKEYA = 1        : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHCOPYKEYW,#PB_Constant)        : #DETOUR_SHCOPYKEYW = 1        : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHQUERYINFOKEYA,#PB_Constant)   : #DETOUR_SHQUERYINFOKEYA = 1   : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHQUERYINFOKEYW,#PB_Constant)   : #DETOUR_SHQUERYINFOKEYW = 1   : CompilerEndIf
CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEKEYA,#PB_Constant)      : #DETOUR_SHDELETEKEYA = 0      : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEKEYW,#PB_Constant)      : #DETOUR_SHDELETEKEYW = 0      : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEYA,#PB_Constant) : #DETOUR_SHDELETEEMPTYKEYA = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEYW,#PB_Constant) : #DETOUR_SHDELETEEMPTYKEYW = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEVALUEA,#PB_Constant)    : #DETOUR_SHDELETEVALUEA = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEVALUEW,#PB_Constant)    : #DETOUR_SHDELETEVALUEW = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETVALUEA,#PB_Constant)       : #DETOUR_SHGETVALUEA = 0       : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETVALUEW,#PB_Constant)       : #DETOUR_SHGETVALUEW = 0       : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHREGGETVALUEA,#PB_Constant)    : #DETOUR_SHREGGETVALUEA = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHREGGETVALUEW,#PB_Constant)    : #DETOUR_SHREGGETVALUEW = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHCOPYKEYA,#PB_Constant)        : #DETOUR_SHCOPYKEYA = 0        : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHCOPYKEYW,#PB_Constant)        : #DETOUR_SHCOPYKEYW = 0        : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHQUERYINFOKEYA,#PB_Constant)   : #DETOUR_SHQUERYINFOKEYA = 0   : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHQUERYINFOKEYW,#PB_Constant)   : #DETOUR_SHQUERYINFOKEYW = 0   : CompilerEndIf
;}

CompilerIf #DETOUR_SHDELETEKEYA Or #DETOUR_SHDELETEEMPTYKEYA Or #DETOUR_SHDELETEVALUEA
	#DETOUR_REG_SHLWAPI_ANY = 1
CompilerElseIf #DETOUR_SHDELETEKEYW Or #DETOUR_SHDELETEEMPTYKEYW Or #DETOUR_SHDELETEVALUEW
	#DETOUR_REG_SHLWAPI_ANY = 1
CompilerElseIf #DETOUR_SHGETVALUEA Or #DETOUR_SHGETVALUEW Or #DETOUR_SHREGGETVALUEA Or #DETOUR_SHREGGETVALUEW
	#DETOUR_REG_SHLWAPI_ANY = 1
CompilerElseIf #DETOUR_SHCOPYKEYA Or #DETOUR_SHCOPYKEYW Or #DETOUR_SHQUERYINFOKEYA Or #DETOUR_SHQUERYINFOKEYW
	#DETOUR_REG_SHLWAPI_ANY = 1
CompilerElse
	#DETOUR_REG_SHLWAPI_ANY = 0
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/sysinfo/predefined-keys
; Для правильного сравнения в режиме x64
Global HKCR.l = #HKEY_CLASSES_ROOT
Global HKLM.l = #HKEY_LOCAL_MACHINE
Global HKCU.l = #HKEY_CURRENT_USER
Global HKU.l = #HKEY_USERS

CompilerIf Not Defined(CheckKey,#PB_Procedure) : Declare.s CheckKey(hKey.l,Key.s) : CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
;{ Процедуры для диагностики обращений к реестру
; #DBG_REGISTRY - задаёт основной режим из шаблона
; #DBG_REGISTRY_MODE - режим на основе #DBG_REGISTRY с учётом совместимости со старыми константами

; Обеспечиваем совместимость со старыми константами
CompilerIf Not Defined(DBG_REGISTRY,#PB_Constant) : #DBG_REGISTRY = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_REGISTRY_ALIENS,#PB_Constant) : #DBG_REGISTRY_ALIENS = 0 : CompilerEndIf
CompilerIf Not Defined(LOGGING,#PB_Constant) : #LOGGING = 0 : CompilerEndIf
CompilerIf Not Defined(LOGGING_CFG,#PB_Constant) : #LOGGING_CFG = 0 : CompilerEndIf
CompilerIf Not Defined(LOGGING_REG,#PB_Constant) : #LOGGING_REG = 0 : CompilerEndIf
CompilerIf Not Defined(LOGGING_SUB,#PB_Constant) : #LOGGING_SUB = 0 : CompilerEndIf

CompilerIf #LOGGING ; будет полная диагностика
	#DBG_REGISTRY_MODE = #DBG_REG_MODE_VIRT
CompilerElseIf #DBG_REGISTRY_ALIENS And (#DBG_REGISTRY = 0) ; только ключи не прошедшие фильтр
	#DBG_REGISTRY_MODE = #DBG_REG_MODE_ALIENS
CompilerElse
	#DBG_REGISTRY_MODE = #DBG_REGISTRY & #DBG_REG_MODE_MASK
CompilerEndIf

; Вспомогательные процедуры для преобразования данных
CompilerIf #DBG_REGISTRY_MODE
	;UndefineMacro DbgAny : DbgAnyDef
	Procedure.s HKey2Str(hKey.l)
		Protected sKey.s
		If hKey = HKLM
			sKey = "HKLM"
		ElseIf hKey = HKCU
			sKey = "HKCU"
		ElseIf hKey = HKCR
			sKey = "HKCR"
		ElseIf hKey = HKU
			sKey = "HKU"
		Else
			sKey = HexL(hKey)
		EndIf
		ProcedureReturn sKey
	EndProcedure
	Procedure.s Type2Str(dwType.l)
		Protected sType.s
		Select dwType
			Case #REG_SZ
				sType = "REG_SZ"
			Case #REG_EXPAND_SZ
				sType = "REG_EXPAND_SZ"
			Case #REG_MULTI_SZ
				sType = "REG_MULTI_SZ"
			Case #REG_DWORD
				sType = "REG_DWORD"
			Case #REG_BINARY
				sType = "REG_BINARY"
			Case #REG_NONE
				sType = "REG_NONE"
			Case #REG_QWORD
				sType = "REG_QWORD"
			Default
				sType = "REG_"+Str(dwType)
		EndSelect
		ProcedureReturn sType
	EndProcedure
	Procedure.s Result2Str(n)
		Protected v.s
		Select n
			Case #NO_ERROR ; 0
				v = "NO_ERROR"
			Case #ERROR_NO_MORE_ITEMS
				v = "ERROR_NO_MORE_ITEMS" ; 259
			Case #ERROR_MORE_DATA
				v = "ERROR_MORE_DATA" ; 234
			Case #ERROR_FILE_NOT_FOUND
				v = "ERROR_FILE_NOT_FOUND" ; 2
			Case #ERROR_ACCESS_DENIED ; 5
				v = "ERROR_ACCESS_DENIED"
			Case #ERROR_INVALID_HANDLE ; 6
				v = "ERROR_INVALID_HANDLE"
		EndSelect
		ProcedureReturn "RESULT: "+Str(n)+" #"+HexL(n)+" "+v
	EndProcedure
CompilerElse
 	Macro HKey2Str(hKey) : EndMacro
 	Macro Type2Str(dwType) : EndMacro
 	Macro Result2Str(n) : EndMacro
CompilerEndIf

; Процедуры вывода диагностики
CompilerIf #DBG_REGISTRY_MODE And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf
CompilerIf #DBG_REGISTRY_MODE
	Global DbgRegMode = #DBG_REGISTRY_MODE
	;dbg(Str(DbgRegMode))
	Procedure DbgReg(txt.s)
		If DbgRegMode>=#DBG_REG_MODE_KEYS
			If txt<>"software" And Left(txt,5)<>"clsid"
				dbg(txt)
			EndIf
		EndIf
	EndProcedure
	Procedure DbgRegExt(txt.s)
		If DbgRegMode>=#DBG_REG_MODE_EXT
			dbg(txt)
		EndIf
	EndProcedure
	; !!! Так как мы не можем определить, где открывается ключ, данная процедура не имеет смысла
	Procedure DbgRegAliens(txt.s)
		;If DbgRegMode=#DBG_REG_MODE_ALIENS
		;	;Global KeyExclude.s = "clsid|software\classes|"
		;	If txt<>"software" And Left(txt,5)<>"clsid" And Left(txt,16)<>"software\classes"
		;		dbg("ALIEN: "+txt)
		;	EndIf
		;EndIf
	EndProcedure
CompilerElse
	Macro DbgReg(txt) : EndMacro
	Macro DbgRegAliens(txt) : EndMacro
	Macro DbgRegExt(s) : EndMacro
CompilerEndIf
;}

;{ Структуры для работы с записываемыми/считываемыми в реестр данными
Structure AnyBytes
	b0.b
	b1.b
	b2.b
	b3.b
EndStructure
Structure AnyWords
	w0.w
	w1.w
EndStructure
Structure AnyType
	StructureUnion
		l.l
		w.w
		b.b
		x.b[3]
		bx.AnyBytes
		wx.AnyWords
	EndStructureUnion
EndStructure
;}

;{ Критическая секция
CompilerIf Not Defined(REG_CRITICAL_SECTION,#PB_Constant) : #REG_CRITICAL_SECTION = 1 : CompilerEndIf
CompilerSelect #REG_CRITICAL_SECTION
	CompilerCase 1
		Global RegCritical.CRITICAL_SECTION
		Macro RegCriticalInitialize
			InitializeCriticalSection_(RegCritical)
		EndMacro
		Macro RegCriticalEnter
			EnterCriticalSection_(RegCritical)
		EndMacro
		Macro RegCriticalLeave
			LeaveCriticalSection_(RegCritical)
		EndMacro
	CompilerCase 2 ; с логированием
		Global RegCritical.CRITICAL_SECTION
		Global RegCriticalCnt
		Macro RegCriticalInitialize
			dbg("RegCriticalInitialize")
			InitializeCriticalSection_(RegCritical)
		EndMacro
		Macro RegCriticalEnter
			RegCriticalCnt+1
			dbg("RegCriticalEnter: "+Str(RegCriticalCnt))
			EnterCriticalSection_(RegCritical)
		EndMacro
		Macro RegCriticalLeave
			LeaveCriticalSection_(RegCritical)
			dbg("RegCriticalLeave: "+Str(RegCriticalCnt))
			RegCriticalCnt-1
		EndMacro
	CompilerDefault ; 0 - отключить
		Macro RegCriticalInitialize
		EndMacro
		Macro RegCriticalEnter
		EndMacro
		Macro RegCriticalLeave
		EndMacro
CompilerEndSelect
;}

XIncludeFile "PP_Registry2Detours.pbi"
XIncludeFile "PP_Registry2Cfg.pbi"

;;======================================================================================================================
; Принудительная статическая линковка dll, так как если программа имеет только отложенный импорт, MinHook вызывается с ошибкой.
; https://learn.microsoft.com/en-us/cpp/build/reference/include-force-symbol-references
CompilerIf #True
	Import "advapi32.lib" : EndImport
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import "/INCLUDE:_RegCloseKey@4" : EndImport
	CompilerElse
		Import "/INCLUDE:RegCloseKey" : EndImport
	CompilerEndIf
CompilerEndIf
CompilerIf #DETOUR_REG_SHLWAPI_ANY
	Import "shlwapi.lib" : EndImport
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import "/INCLUDE:_SHGetValueW@24" : EndImport
	CompilerElse
		Import "/INCLUDE:SHGetValueW" : EndImport
	CompilerEndIf
CompilerEndIf
XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================
Global RegistryPermit = 1
Global RegistryShlwapiPermit = 1
Procedure _InitRegistryHooks()
	If RegistryPermit
		CompilerIf (#PORTABLE_REGISTRY & #PORTABLE_REG_KERNELBASE) = 0
			CompilerIf #DETOUR_REGCREATEKEYA : MH_HookApi(advapi32,RegCreateKeyA) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYW : MH_HookApi(advapi32,RegCreateKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYEXA : MH_HookApi(advapi32,RegCreateKeyExA) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYEXW : MH_HookApi(advapi32,RegCreateKeyExW) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDA : MH_HookApi(advapi32,RegCreateKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDW : MH_HookApi(advapi32,RegCreateKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYA : MH_HookApi(advapi32,RegOpenKeyA) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYW : MH_HookApi(advapi32,RegOpenKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYEXA : MH_HookApi(advapi32,RegOpenKeyExA) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYEXW : MH_HookApi(advapi32,RegOpenKeyExW) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYTRANSACTEDA : MH_HookApi(advapi32,RegOpenKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYTRANSACTEDW : MH_HookApi(advapi32,RegOpenKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYA: MH_HookApi(advapi32,RegDeleteKeyA) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYW: MH_HookApi(advapi32,RegDeleteKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETETREEA : MH_HookApi(advapi32,RegDeleteTreeA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETETREEW : MH_HookApi(advapi32,RegDeleteTreeW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYEXA : MH_HookApi(advapi32,RegDeleteKeyExA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYEXW : MH_HookApi(advapi32,RegDeleteKeyExW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDA : MH_HookApi(advapi32,RegDeleteKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDW : MH_HookApi(advapi32,RegDeleteKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEVALUEA : MH_HookApi(advapi32,RegDeleteValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEVALUEW : MH_HookApi(advapi32,RegDeleteValueW) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYVALUEA : MH_HookApi(advapi32,RegDeleteKeyValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYVALUEW : MH_HookApi(advapi32,RegDeleteKeyValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYA : MH_HookApi(advapi32,RegEnumKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYW : MH_HookApi(advapi32,RegEnumKeyW) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYEXA : MH_HookApi(advapi32,RegEnumKeyExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYEXW : MH_HookApi(advapi32,RegEnumKeyExW) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMVALUEA : MH_HookApi(advapi32,RegEnumValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMVALUEW : MH_HookApi(advapi32,RegEnumValueW) : CompilerEndIf
			CompilerIf #DETOUR_REGQUERYVALUEA : MH_HookApi(advapi32,RegQueryValueA) : CompilerEndIf
			CompilerIf #DETOUR_REGQUERYVALUEW : MH_HookApi(advapi32,RegQueryValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEEXA : MH_HookApi(advapi32,RegQueryValueExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEEXW : MH_HookApi(advapi32,RegQueryValueExW) : CompilerEndIf
			CompilerIf #DETOUR_REGGETVALUEA : MH_HookApi(advapi32,RegGetValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGGETVALUEW : MH_HookApi(advapi32,RegGetValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGSETVALUEA : MH_HookApi(advapi32,RegSetValueA) : CompilerEndIf
			CompilerIf #DETOUR_REGSETVALUEW : MH_HookApi(advapi32,RegSetValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEEXA : MH_HookApi(advapi32,RegSetValueExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEEXW : MH_HookApi(advapi32,RegSetValueExW) : CompilerEndIf
			CompilerIf #DETOUR_REGSETKEYVALUEA : MH_HookApi(advapi32,RegSetKeyValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			CompilerIf #DETOUR_REGSETKEYVALUEW : MH_HookApi(advapi32,RegSetKeyValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYINFOKEYA : MH_HookApi(advapi32,RegQueryInfoKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYINFOKEYW : MH_HookApi(advapi32,RegQueryInfoKeyW) : CompilerEndIf
		CompilerElse ;If (#PORTABLE_REGISTRY & $100) <> 0
			;CompilerIf #DETOUR_REGCREATEKEYA : MH_HookApi(kernelbase,RegCreateKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGCREATEKEYW : MH_HookApi(kernelbase,RegCreateKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYEXA : MH_HookApi(kernelbase,RegCreateKeyExA) : CompilerEndIf
			CompilerIf #DETOUR_REGCREATEKEYEXW : MH_HookApi(kernelbase,RegCreateKeyExW) : CompilerEndIf
			;CompilerIf #DETOUR_REGOPENKEYA : MH_HookApi(kernelbase,RegOpenKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGOPENKEYW : MH_HookApi(kernelbase,RegOpenKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYEXA : MH_HookApi(kernelbase,RegOpenKeyExA) : CompilerEndIf
			CompilerIf #DETOUR_REGOPENKEYEXW : MH_HookApi(kernelbase,RegOpenKeyExW) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEKEYA: MH_HookApi(kernelbase,RegDeleteKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEKEYW: MH_HookApi(kernelbase,RegDeleteKeyW) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETETREEA : MH_HookApi(kernelbase,RegDeleteTreeA) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETETREEW : MH_HookApi(kernelbase,RegDeleteTreeW) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYEXA : MH_HookApi(kernelbase,RegDeleteKeyExA) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYEXW : MH_HookApi(kernelbase,RegDeleteKeyExW) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEVALUEA : MH_HookApi(kernelbase,RegDeleteValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEVALUEW : MH_HookApi(kernelbase,RegDeleteValueW) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYVALUEA : MH_HookApi(kernelbase,RegDeleteKeyValueA) : CompilerEndIf
			CompilerIf #DETOUR_REGDELETEKEYVALUEW : MH_HookApi(kernelbase,RegDeleteKeyValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYA : MH_HookApi(kernelbase,RegEnumKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYW : MH_HookApi(kernelbase,RegEnumKeyW) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYEXA : MH_HookApi(kernelbase,RegEnumKeyExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMKEYEXW : MH_HookApi(kernelbase,RegEnumKeyExW) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMVALUEA : MH_HookApi(kernelbase,RegEnumValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGENUMVALUEW : MH_HookApi(kernelbase,RegEnumValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEA : MH_HookApi(kernelbase,RegQueryValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEW : MH_HookApi(kernelbase,RegQueryValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEEXA : MH_HookApi(kernelbase,RegQueryValueExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYVALUEEXW : MH_HookApi(kernelbase,RegQueryValueExW) : CompilerEndIf
			CompilerIf #DETOUR_REGGETVALUEA : MH_HookApi(kernelbase,RegGetValueA) : CompilerEndIf
			CompilerIf #DETOUR_REGGETVALUEW : MH_HookApi(kernelbase,RegGetValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEA : MH_HookApi(kernelbase,RegSetValueA) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEW : MH_HookApi(kernelbase,RegSetValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEEXA : MH_HookApi(kernelbase,RegSetValueExA) : CompilerEndIf
			;CompilerIf #DETOUR_REGSETVALUEEXW : MH_HookApi(kernelbase,RegSetValueExW) : CompilerEndIf
			CompilerIf #DETOUR_REGSETKEYVALUEA : MH_HookApi(kernelbase,RegSetKeyValueA) : CompilerEndIf
			CompilerIf #DETOUR_REGSETKEYVALUEW : MH_HookApi(kernelbase,RegSetKeyValueW) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYINFOKEYA : MH_HookApi(kernelbase,RegQueryInfoKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_REGQUERYINFOKEYW : MH_HookApi(kernelbase,RegQueryInfoKeyW) : CompilerEndIf
			;CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDA : MH_HookApi(kernelbase,RegCreateKeyTransactedA) : CompilerEndIf
			;CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDW : MH_HookApi(kernelbase,RegCreateKeyTransactedW) : CompilerEndIf
			;CompilerIf #DETOUR_REGOPENKEYTRANSACTEDA : MH_HookApi(kernelbase,RegOpenKeyTransactedA) : CompilerEndIf
			;CompilerIf #DETOUR_REGOPENKEYTRANSACTEDW : MH_HookApi(kernelbase,RegOpenKeyTransactedW) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDA : MH_HookApi(kernelbase,RegDeleteKeyTransactedA) : CompilerEndIf
			;CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDW : MH_HookApi(kernelbase,RegDeleteKeyTransactedW) : CompilerEndIf
		CompilerEndIf
		CompilerIf #DETOUR_REG_SHLWAPI_ANY
			If RegistryShlwapiPermit
				CompilerIf #DETOUR_SHDELETEKEYA : MH_HookApi(shlwapi,SHDeleteKeyA) : CompilerEndIf
				CompilerIf #DETOUR_SHDELETEKEYW : MH_HookApi(shlwapi,SHDeleteKeyW) : CompilerEndIf
				CompilerIf #DETOUR_SHDELETEEMPTYKEYA : MH_HookApi(shlwapi,SHDeleteEmptyKeyA) : CompilerEndIf
				CompilerIf #DETOUR_SHDELETEEMPTYKEYW : MH_HookApi(shlwapi,SHDeleteEmptyKeyW) : CompilerEndIf
				CompilerIf #DETOUR_SHDELETEVALUEA : MH_HookApi(shlwapi,SHDeleteValueA) : CompilerEndIf
				CompilerIf #DETOUR_SHDELETEVALUEW : MH_HookApi(shlwapi,SHDeleteValueW) : CompilerEndIf
				CompilerIf #DETOUR_SHGETVALUEA : MH_HookApi(shlwapi,SHGetValueA) : CompilerEndIf
				CompilerIf #DETOUR_SHGETVALUEW : MH_HookApi(shlwapi,SHGetValueW) : CompilerEndIf
				;CompilerIf #DETOUR_SHQUERYVALUEEXA : MH_HookApi(shlwapi,SHQueryValueA) : CompilerEndIf
				;CompilerIf #DETOUR_SHQUERYVALUEEXW : MH_HookApi(shlwapi,SHQueryValueW) : CompilerEndIf
				CompilerIf #DETOUR_SHREGGETVALUEA : MH_HookApi(shlwapi,SHRegGetValueA) : CompilerEndIf
				CompilerIf #DETOUR_SHREGGETVALUEW : MH_HookApi(shlwapi,SHRegGetValueW) : CompilerEndIf
				;CompilerIf #DETOUR_SHSETVALUEA : MH_HookApi(shlwapi,SHSetValueA) : CompilerEndIf
				;CompilerIf #DETOUR_SHSETVALUEW : MH_HookApi(shlwapi,SHSetValueW) : CompilerEndIf
				CompilerIf #DETOUR_SHCOPYKEYA : MH_HookApi(shlwapi,SHCopyKeyA) : CompilerEndIf
				CompilerIf #DETOUR_SHCOPYKEYW : MH_HookApi(shlwapi,SHCopyKeyW) : CompilerEndIf
				CompilerIf #DETOUR_SHQUERYINFOKEYA : MH_HookApi(shlwapi,SHQueryInfoKeyA) : CompilerEndIf
				CompilerIf #DETOUR_SHQUERYINFOKEYW : MH_HookApi(shlwapi,SHQueryInfoKeyW) : CompilerEndIf
			EndIf
		CompilerEndIf
	EndIf
EndProcedure
AddInitProcedure(_InitRegistryHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 102
; FirstLine = 87
; Folding = jj4-0
; EnableAsm
; DisableDebugger
; EnableExeConstant
; EnableUnicode