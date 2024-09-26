;;======================================================================================================================
; Модуль Registry1
; Портабелизация реестра
;;======================================================================================================================
; TODO
; - SHRegSetValue: только по ординалу 641 (?)
; https://geoffchappell.com/studies/windows/shell/shlwapi/api/
; https://www.geoffchappell.com/studies/windows/shell/shlwapi/history/ords600.htm
; RegOpenCurrentUser https://docs.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regopencurrentuser
; RegOpenUserClassesRoot
; RegQueryMultipleValuesA, RegQueryMultipleValuesW
; RegRenameKey
; RegOverridePredefKey
; SHQueryInfoKeyA, SHQueryInfoKeyW https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryinfokeya
; CSIDL_FLAG_CREATE
;;======================================================================================================================

CompilerIf Not Defined(DETOUR_REG_SHLWAPI,#PB_Constant) : #DETOUR_REG_SHLWAPI = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REG_TRANSACTED,#PB_Constant) : #DETOUR_REG_TRANSACTED = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REG_DLL,#PB_Constant) : #DETOUR_REG_DLL = 0 : CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------

CompilerIf #PROXY_DLL_COMPATIBILITY<>0 And #PROXY_DLL_COMPATIBILITY<6
	#DETOUR_REGDELETEKEYEX = 0 ; XP64, 2003SP1, 2008
	#DETOUR_REGDELETETREE = 0 ; Vista, 2008
	#DETOUR_REGDELETEKEYVALUE = 0 ; Vista, 2008
	#DETOUR_REGGETVALUE = 0 ; XP64, 2003SP1, Vista, 2008
	#DETOUR_REGSETKEYVALUE = 0 ; Vista, 2008
CompilerEndIf

;{ Дополнительное управление функциями
CompilerIf Not Defined(DETOUR_REGCLOSEKEY,#PB_Constant) : #DETOUR_REGCLOSEKEY = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGFLUSHKEY,#PB_Constant) : #DETOUR_REGFLUSHKEY = 1 : CompilerEndIf

CompilerIf Not Defined(DETOUR_REGCREATEKEY,#PB_Constant)      : #DETOUR_REGCREATEKEY = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGCREATEKEYEX,#PB_Constant)    : #DETOUR_REGCREATEKEYEX = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEY,#PB_Constant)        : #DETOUR_REGOPENKEY = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGOPENKEYEX,#PB_Constant)      : #DETOUR_REGOPENKEYEX = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEY,#PB_Constant)      : #DETOUR_REGDELETEKEY = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYEX,#PB_Constant)    : #DETOUR_REGDELETEKEYEX = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETETREE,#PB_Constant)     : #DETOUR_REGDELETETREE = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEVALUE,#PB_Constant)    : #DETOUR_REGDELETEVALUE = 1    : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGDELETEKEYVALUE,#PB_Constant) : #DETOUR_REGDELETEKEYVALUE = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGENUMKEY,#PB_Constant)        : #DETOUR_REGENUMKEY = 1        : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGENUMKEYEX,#PB_Constant)      : #DETOUR_REGENUMKEYEX = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGENUMVALUE,#PB_Constant)      : #DETOUR_REGENUMVALUE = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGQUERYVALUE,#PB_Constant)     : #DETOUR_REGQUERYVALUE = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGQUERYVALUEEX,#PB_Constant)   : #DETOUR_REGQUERYVALUEEX = 1   : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGGETVALUE,#PB_Constant)       : #DETOUR_REGGETVALUE = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGQUERYINFOKEY,#PB_Constant)   : #DETOUR_REGQUERYINFOKEY = 1   : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETVALUE,#PB_Constant)       : #DETOUR_REGSETVALUE = 1       : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETVALUEEX,#PB_Constant)     : #DETOUR_REGSETVALUEEX = 1     : CompilerEndIf
CompilerIf Not Defined(DETOUR_REGSETKEYVALUE,#PB_Constant)    : #DETOUR_REGSETKEYVALUE = 1    : CompilerEndIf

CompilerIf #DETOUR_REG_TRANSACTED Or #PORTABLE_REG_TRANSACTED
	CompilerIf Not Defined(DETOUR_REGCREATEKEYTRANSACTED,#PB_Constant) : #DETOUR_REGCREATEKEYTRANSACTED = 1 : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGOPENKEYTRANSACTED,#PB_Constant)   : #DETOUR_REGOPENKEYTRANSACTED = 1   : CompilerEndIf
	CompilerIf Not Defined(DETOUR_REGDELETEKEYTRANSACTED,#PB_Constant) : #DETOUR_REGDELETEKEYTRANSACTED = 1 : CompilerEndIf
CompilerEndIf
CompilerIf #DETOUR_REG_SHLWAPI Or #PORTABLE_REG_SHLWAPI Or (#PORTABLE_REGISTRY & #PORTABLE_REG_SHLWAPI)
	CompilerIf Not Defined(DETOUR_SHDELETEKEY,#PB_Constant)         : #DETOUR_SHDELETEKEY = 1         : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEY,#PB_Constant)    : #DETOUR_SHDELETEEMPTYKEY = 1    : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHDELETEVALUE,#PB_Constant)       : #DETOUR_SHDELETEVALUE = 1       : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHGETVALUE,#PB_Constant)          : #DETOUR_SHGETVALUE = 1          : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHQUERYVALUEEX,#PB_Constant)      : #DETOUR_SHQUERYVALUEEX = 1      : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHREGGETVALUE,#PB_Constant)       : #DETOUR_SHREGGETVALUE = 1       : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHSETVALUE,#PB_Constant)          : #DETOUR_SHSETVALUE = 1          : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHCOPYKEY,#PB_Constant)           : #DETOUR_SHCOPYKEY = 1           : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHQUERYINFOKEY,#PB_Constant)      : #DETOUR_SHQUERYINFOKEY = 1      : CompilerEndIf
	CompilerIf Not Defined(DETOUR_SHREGGETBOOLUSVALUE,#PB_Constant) : #DETOUR_SHREGGETBOOLUSVALUE = 0 : CompilerEndIf
CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEKEY,#PB_Constant)      : #DETOUR_SHDELETEKEY = 0      : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEEMPTYKEY,#PB_Constant) : #DETOUR_SHDELETEEMPTYKEY = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHDELETEVALUE,#PB_Constant)    : #DETOUR_SHDELETEVALUE = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETVALUE,#PB_Constant)       : #DETOUR_SHGETVALUE = 0       : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHQUERYVALUEEX,#PB_Constant)   : #DETOUR_SHQUERYVALUEEX = 0   : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHREGGETVALUE,#PB_Constant)    : #DETOUR_SHREGGETVALUE = 0    : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHSETVALUE,#PB_Constant)       : #DETOUR_SHSETVALUE = 0       : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHCOPYKEY,#PB_Constant)        : #DETOUR_SHCOPYKEY = 0        : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHQUERYINFOKEY,#PB_Constant)   : #DETOUR_SHQUERYINFOKEY = 0   : CompilerEndIf

; CompilerIf #DETOUR_SHDELETEKEY Or #DETOUR_SHDELETEEMPTYKEY Or #DETOUR_SHDELETEVALUE
; 	#DETOUR_REG_SHLWAPI_ANY = 1
; CompilerElseIf #DETOUR_SHGETVALUE Or #DETOUR_SHQUERYVALUEEX Or #DETOUR_SHREGGETVALUE Or #DETOUR_SHSETVALUE
; 	#DETOUR_REG_SHLWAPI_ANY = 1
; CompilerElseIf #DETOUR_SHREGGETBOOLUSVALUE
; 	#DETOUR_REG_SHLWAPI_ANY = 1
; CompilerElseIf #DETOUR_SHCOPYKEY Or #DETOUR_SHQUERYINFOKEY
; 	#DETOUR_REG_SHLWAPI_ANY = 1
; CompilerElse
; 	#DETOUR_REG_SHLWAPI_ANY = 0
; CompilerEndIf
;}

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
	Procedure DbgRegAliens(txt.s)
		If DbgRegMode=#DBG_REG_MODE_ALIENS
			;Global KeyExclude.s = "clsid|software\classes|"
			;If txt<>"software" And Left(txt,5)<>"clsid" And Left(txt,16)<>"software\classes"
			dbg("ALIEN: "+txt)
			;EndIf
		EndIf
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
;{ Массивы для хранения данных
Global Dim Keys.s(0)
Global nKeys = 0 ; размер Keys() для использования вместо ArraySize(Keys())
Structure CFGDATA Align #PB_Structure_AlignC
	h.l ; hkey - виртуальный хэндл
	t.l ; type
	c.l	; cb (counter bytes)
	;m.l ; выделенная память под данные (может отличаться от c)
	StructureUnion ;d.l ; dword data -> AnyType
		l.l
		w.w
		b.b
		x.b[3]
		bx.AnyBytes
		wx.AnyWords
	EndStructureUnion
	n.s	; value name (parameter name)
	a.s ; any data
EndStructure
Global Dim Cfg.CFGDATA(0) ; Массив параметров
Global nCfg = 0 ; размер Cfg() для использования вместо ArraySize(Cfg())
Global ConfigChanged = #False ; были изменения
;}
;{ Способы связать индекс массива с виртуальным дескриптором
CompilerIf Not Defined(REG_HKEY_METHOD,#PB_Constant) : #REG_HKEY_METHOD = 0 : CompilerEndIf
CompilerSelect #REG_HKEY_METHOD
	CompilerCase 0 ; Основной метод. Дескрипторы начиная со специального значения
		;#PHONYKEY = $82000000
		Global _HK_BASE.l = $82000000
		;#PHONYCHK = $FF000000
		Global _HK_CHECK_MASK.l = $FF000000
		;#PHONYIDX = $00FFFFFF
		Global _HK_INDEX_MASK.l = $00FFFFFF
		Macro IsKey(hKey) : ((hKey&_HK_CHECK_MASK)=_HK_BASE) : EndMacro
		Macro GetKey(hKey) : Keys(hKey&_HK_INDEX_MASK) : EndMacro
		Macro hkey2i(hKey) : (hKey&_HK_INDEX_MASK) : EndMacro
		Macro i2hkey(index) : (index+_HK_BASE) : EndMacro
	CompilerCase 1 ; Нечётные дескрипторы
		Global _HK_ODD_MASK.l = $80000001
		Macro IsKey(hKey) : (hKey&_HK_ODD_MASK=1) : EndMacro
		Macro GetKey(hKey) : Keys(hKey>>1) : EndMacro
		Macro hkey2i(hKey) : (hKey>>1) : EndMacro
		Macro i2hkey(index) : ((index<<1)|1) : EndMacro
	CompilerCase 10 ; Экспериментальный метод. Дескрипторы начиная со специального значения и кратны 4
		Global _HK_BASE.l = $82000000
		Global _HK_CHECK_MASK.l = $FF000000
		Global _HK_INDEX_MASK.l = $00FFFFFF
		Macro IsKey(hKey) : ((hKey&_HK_CHECK_MASK)=_HK_BASE) : EndMacro
		Macro GetKey(hKey) : Keys((hKey&_HK_INDEX_MASK)>>2) : EndMacro
		Macro hkey2i(hKey) : ((hKey&_HK_INDEX_MASK)>>2) : EndMacro
		Macro i2hkey(index) : ((index<<2)+_HK_BASE) : EndMacro
	CompilerCase 11 ; Экспериментальный метод. Дескрипторы начиная со специального значения и кратны 4
		Global _HK_BASE.l = $00880000
		Global _HK_CHECK_MASK.l = $00FF0000
		Global _HK_INDEX_MASK.l = $0000FFFF
		Macro IsKey(hKey) : ((hKey&_HK_CHECK_MASK)=_HK_BASE) : EndMacro
		Macro GetKey(hKey) : Keys((hKey&_HK_INDEX_MASK)>>2) : EndMacro
		Macro hkey2i(hKey) : ((hKey&_HK_INDEX_MASK)>>2) : EndMacro
		Macro i2hkey(index) : ((index<<2)+_HK_BASE) : EndMacro
CompilerEndSelect
;}

;{ Критическая секция
CompilerIf Not Defined(REG_CRITICAL_SECTION,#PB_Constant) : #REG_CRITICAL_SECTION = 1 : CompilerEndIf
CompilerSelect #REG_CRITICAL_SECTION
	CompilerCase 1
		Global RegCritical.CRITICAL_SECTION
		InitializeCriticalSection_(RegCritical)
		Macro RegCriticalEnter
			EnterCriticalSection_(RegCritical)
		EndMacro
		Macro RegCriticalLeave
			LeaveCriticalSection_(RegCritical)
		EndMacro
	CompilerCase 2 ; с логированием
		Global RegCritical.CRITICAL_SECTION
		Global RegCriticalCnt
		dbg("RegCriticalInitialize")
		InitializeCriticalSection_(RegCritical)
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
		Macro RegCriticalEnter
		EndMacro
		Macro RegCriticalLeave
		EndMacro
CompilerEndSelect
;}

XIncludeFile "PP_Registry1Virt.pbi"
XIncludeFile "PP_Registry1Cfg.pbi"
XIncludeFile "PP_Registry1Detours.pbi"

;;======================================================================================================================
;{ Принудительная статическая линковка dll, так как если программа имеет только отложенный импорт, MinHook вызывается с ошибкой.
; https://learn.microsoft.com/en-us/cpp/build/reference/include-force-symbol-references
CompilerIf #True
	Import "advapi32.lib" : EndImport
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import "/INCLUDE:_RegCloseKey@4" : EndImport
	CompilerElse
		Import "/INCLUDE:RegCloseKey" : EndImport
	CompilerEndIf
CompilerEndIf
; CompilerIf #DETOUR_REG_SHLWAPI_ANY ; больше нет необходимости в связи с тем, что всё равно используются функции из shlwapi
; 	Import "shlwapi.lib" : EndImport
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Import "/INCLUDE:_SHGetValueW@24" : EndImport
; 	CompilerElse
; 		Import "/INCLUDE:SHGetValueW" : EndImport
; 	CompilerEndIf
; CompilerEndIf
;}
;;======================================================================================================================
XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================
Global RegistryPermit = 1
CompilerIf #DETOUR_REG_SHLWAPI Or (#PORTABLE_REGISTRY & #PORTABLE_REG_SHLWAPI)
	Global RegistryShlwapiPermit = 1
CompilerElse
	Global RegistryShlwapiPermit = 0
CompilerEndIf
CompilerIf #PORTABLE_REGISTRY & #PORTABLE_REG_KERNELBASE
	Global RegistryDll.s = "kernelbase"
CompilerElse
	Global RegistryDll.s = "advapi32"
CompilerEndIf
Procedure _InitRegistryHooks()
	If RegistryPermit
		MH_HookApiD(RegistryDll,RegCloseKey)
		MH_HookApiD(RegistryDll,RegFlushKey)
		CompilerIf #DETOUR_REGCREATEKEY : MH_HookApiD(RegistryDll,RegCreateKeyA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGCREATEKEY : MH_HookApiD(RegistryDll,RegCreateKeyW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGCREATEKEYEX : MH_HookApiD(RegistryDll,RegCreateKeyExA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGCREATEKEYEX : MH_HookApiD(RegistryDll,RegCreateKeyExW) : CompilerEndIf
		CompilerIf #DETOUR_REGCREATEKEYTRANSACTED : MH_HookApiD(RegistryDll,RegCreateKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGCREATEKEYTRANSACTED : MH_HookApiD(RegistryDll,RegCreateKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGOPENKEY : MH_HookApiD(RegistryDll,RegOpenKeyA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGOPENKEY : MH_HookApiD(RegistryDll,RegOpenKeyW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGOPENKEYEX : MH_HookApiD(RegistryDll,RegOpenKeyExA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGOPENKEYEX : MH_HookApiD(RegistryDll,RegOpenKeyExW) : CompilerEndIf
		CompilerIf #DETOUR_REGOPENKEYTRANSACTED : MH_HookApiD(RegistryDll,RegOpenKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGOPENKEYTRANSACTED : MH_HookApiD(RegistryDll,RegOpenKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGDELETEKEY: MH_HookApiD(RegistryDll,RegDeleteKeyA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGDELETEKEY: MH_HookApiD(RegistryDll,RegDeleteKeyW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGDELETETREE : MH_HookApiD(RegistryDll,RegDeleteTreeA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGDELETETREE : MH_HookApiD(RegistryDll,RegDeleteTreeW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; Vista, 2008
		CompilerIf #DETOUR_REGDELETEKEYEX : MH_HookApiD(RegistryDll,RegDeleteKeyExA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGDELETEKEYEX : MH_HookApiD(RegistryDll,RegDeleteKeyExW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; XP64, 2003SP1, 2008
		CompilerIf #DETOUR_REGDELETEKEYTRANSACTED : MH_HookApiD(RegistryDll,RegDeleteKeyTransactedA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGDELETEKEYTRANSACTED : MH_HookApiD(RegistryDll,RegDeleteKeyTransactedW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGDELETEVALUE : MH_HookApiD(RegistryDll,RegDeleteValueA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGDELETEVALUE : MH_HookApiD(RegistryDll,RegDeleteValueW) : CompilerEndIf
		CompilerIf #DETOUR_REGDELETEKEYVALUE : MH_HookApiD(RegistryDll,RegDeleteKeyValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGDELETEKEYVALUE : MH_HookApiD(RegistryDll,RegDeleteKeyValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; Vista, 2008
		CompilerIf #DETOUR_REGENUMKEY : MH_HookApiD(RegistryDll,RegEnumKeyA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGENUMKEY : MH_HookApiD(RegistryDll,RegEnumKeyW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGENUMKEYEX : MH_HookApiD(RegistryDll,RegEnumKeyExA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGENUMKEYEX : MH_HookApiD(RegistryDll,RegEnumKeyExW) : CompilerEndIf
		CompilerIf #DETOUR_REGENUMVALUE : MH_HookApiD(RegistryDll,RegEnumValueA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGENUMVALUE : MH_HookApiD(RegistryDll,RegEnumValueW) : CompilerEndIf
		CompilerIf #DETOUR_REGQUERYVALUE : MH_HookApiD(RegistryDll,RegQueryValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGQUERYVALUE : MH_HookApiD(RegistryDll,RegQueryValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGQUERYVALUEEX : MH_HookApiD(RegistryDll,RegQueryValueExA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGQUERYVALUEEX : MH_HookApiD(RegistryDll,RegQueryValueExW) : CompilerEndIf
		CompilerIf #DETOUR_REGGETVALUE : MH_HookApiD(RegistryDll,RegGetValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGGETVALUE : MH_HookApiD(RegistryDll,RegGetValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; XP64, 2003SP1, Vista, 2008
		CompilerIf #DETOUR_REGSETVALUE : MH_HookApiD(RegistryDll,RegSetValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32
		CompilerIf #DETOUR_REGSETVALUE : MH_HookApiD(RegistryDll,RegSetValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_REGSETVALUEEX : MH_HookApiD(RegistryDll,RegSetValueExA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGSETVALUEEX : MH_HookApiD(RegistryDll,RegSetValueExW) : CompilerEndIf
		CompilerIf #DETOUR_REGSETKEYVALUE : MH_HookApiD(RegistryDll,RegSetKeyValueA,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGSETKEYVALUE : MH_HookApiD(RegistryDll,RegSetKeyValueW,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf ; Vista, 2008
		CompilerIf #DETOUR_REGQUERYINFOKEY : MH_HookApiD(RegistryDll,RegQueryInfoKeyA) : CompilerEndIf ; advapi32, kernelbase
		CompilerIf #DETOUR_REGQUERYINFOKEY : MH_HookApiD(RegistryDll,RegQueryInfoKeyW) : CompilerEndIf
		If RegistryShlwapiPermit
			CompilerIf #DETOUR_SHDELETEKEY : MH_HookApi(shlwapi,SHDeleteKeyA) : CompilerEndIf
			CompilerIf #DETOUR_SHDELETEKEY : MH_HookApi(shlwapi,SHDeleteKeyW) : CompilerEndIf
			CompilerIf #DETOUR_SHDELETEEMPTYKEY : MH_HookApi(shlwapi,SHDeleteEmptyKeyA) : CompilerEndIf
			CompilerIf #DETOUR_SHDELETEEMPTYKEY : MH_HookApi(shlwapi,SHDeleteEmptyKeyW) : CompilerEndIf
			CompilerIf #DETOUR_SHDELETEVALUE : MH_HookApi(shlwapi,SHDeleteValueA) : CompilerEndIf
			CompilerIf #DETOUR_SHDELETEVALUE : MH_HookApi(shlwapi,SHDeleteValueW) : CompilerEndIf
			CompilerIf #DETOUR_SHGETVALUE : MH_HookApi(shlwapi,SHGetValueA) : CompilerEndIf
			CompilerIf #DETOUR_SHGETVALUE : MH_HookApi(shlwapi,SHGetValueW) : CompilerEndIf
			;CompilerIf #DETOUR_SHQUERYVALUEEX : MH_HookApi(shlwapi,SHQueryValueA) : CompilerEndIf
			;CompilerIf #DETOUR_SHQUERYVALUEEX : MH_HookApi(shlwapi,SHQueryValueW) : CompilerEndIf
			CompilerIf #DETOUR_SHREGGETVALUE : MH_HookApi(shlwapi,SHRegGetValueA) : CompilerEndIf
			CompilerIf #DETOUR_SHREGGETVALUE : MH_HookApi(shlwapi,SHRegGetValueW) : CompilerEndIf
			CompilerIf #DETOUR_SHSETVALUE : MH_HookApi(shlwapi,SHSetValueA) : CompilerEndIf
			CompilerIf #DETOUR_SHSETVALUE : MH_HookApi(shlwapi,SHSetValueW) : CompilerEndIf
			;CompilerIf #DETOUR_SHCOPYKEY : MH_HookApi(shlwapi,SHCopyKeyA) : CompilerEndIf
			;CompilerIf #DETOUR_SHCOPYKEY : MH_HookApi(shlwapi,SHCopyKeyW) : CompilerEndIf
			CompilerIf #DETOUR_SHQUERYINFOKEY : MH_HookApi(shlwapi,SHQueryInfoKeyA) : CompilerEndIf
			CompilerIf #DETOUR_SHQUERYINFOKEY : MH_HookApi(shlwapi,SHQueryInfoKeyW) : CompilerEndIf
			CompilerIf #DETOUR_SHREGGETBOOLUSVALUE : MH_HookApi(shlwapi,SHRegGetBoolUSValueA) : CompilerEndIf
			CompilerIf #DETOUR_SHREGGETBOOLUSVALUE : MH_HookApi(shlwapi,SHRegGetBoolUSValueW) : CompilerEndIf
		EndIf
	EndIf
EndProcedure
AddInitProcedure(_InitRegistryHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 60
; FirstLine = 57
; Folding = hjj--4v-
; DisableDebugger
; EnableExeConstant