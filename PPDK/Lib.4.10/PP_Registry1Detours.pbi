﻿;;======================================================================================================================
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regclosekey
CompilerIf #CFG_SAVE_ON_CLOSE=2
	Global CfgSaveOnClose
CompilerEndIf
Prototype.l RegCloseKey(hKey.l)
CompilerIf #DETOUR_REGCLOSEKEY
	Global Original_RegCloseKey.RegCloseKey
	Procedure.l Detour_RegCloseKey(hKey.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCloseKey: "+HKey2Str(hKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCloseKey(hKey)
		CompilerElse
			If IsKey(hKey)
				CompilerIf #DBG_REGISTRY And #CFG_SAVE_ON_CLOSE=1
					Static RegCloseKeyCnt
					If ConfigChanged
						RegCloseKeyCnt + 1
						DbgRegExt("RegCloseKey: "+HKey2Str(hKey))
						DbgRegExt("RegCloseKey: Cnt: "+Str(RegCloseKeyCnt))
					EndIf
				CompilerElseIf #DBG_REGISTRY And #CFG_SAVE_ON_CLOSE=2
					Static RegCloseKeyCnt
					If CfgSaveOnClose And ConfigChanged
						RegCloseKeyCnt + 1
						DbgRegExt("RegCloseKey: "+HKey2Str(hKey))
						DbgRegExt("RegCloseKey: Cnt: "+Str(RegCloseKeyCnt))
					EndIf
				CompilerEndIf
				CompilerIf #CFG_SAVE_ON_CLOSE=1
					WriteCfg()
				CompilerElseIf #CFG_SAVE_ON_CLOSE=2
					If CfgSaveOnClose
						WriteCfg()
					EndIf
				CompilerEndIf
				Result = #NO_ERROR
			Else
				Result = Original_RegCloseKey(hKey)
			EndIf
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regcreatekeya
; TODO: lpSubKey = Null
Prototype.l RegCreateKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGCREATEKEY
	Global Original_RegCreateKeyA.RegCreateKey
	Procedure.l Detour_RegCreateKeyA(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyA(hKey,*lpSubKey,*phkResult)
		CompilerElse
			If Not CreateKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result)
				Result = Original_RegCreateKeyA(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegCreateKeyW.RegCreateKey
	Procedure.l Detour_RegCreateKeyW(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyW(hKey,*lpSubKey,*phkResult)
		CompilerElse
			If Not CreateKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result)
				Result = Original_RegCreateKeyW(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regcreatekeyexa
Prototype.l RegCreateKeyEx(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
CompilerIf #DETOUR_REGCREATEKEYEX
	Global Original_RegCreateKeyExA.RegCreateKeyEx
	Procedure.l Detour_RegCreateKeyExA(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyExA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			CompilerIf #DBG_REGISTRY_MODE
				If DbgRegMode >= #DBG_REG_MODE_KEYS And *lpdwDisposition
					DbgReg("RegCreateKeyExA: dwDisposition: "+Str(*lpdwDisposition\l))
				EndIf
			CompilerEndIf
		CompilerElse
			If *lpSubKey = 0 Or *phkResult = 0
				Result = 1010
				DbgReg("RegCreateKeyExA (?): *lpSubKey: "+Hex(*lpSubKey)+" *phkResult: "+Hex(*phkResult)+" "+Result2Str(Result))
			ElseIf Not CreateKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result,*lpdwDisposition)
				Result = Original_RegCreateKeyExA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyExA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegCreateKeyExW.RegCreateKeyEx
	Procedure.l Detour_RegCreateKeyExW(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyExW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			CompilerIf #DBG_REGISTRY_MODE
				If DbgRegMode >= #DBG_REG_MODE_KEYS And *lpdwDisposition
					DbgReg("RegCreateKeyExW: dwDisposition: "+Str(*lpdwDisposition\l))
				EndIf
			CompilerEndIf
		CompilerElse
			If *lpSubKey = 0 Or *phkResult = 0
				Result = 1010
				DbgReg("RegCreateKeyExW (?): *lpSubKey: "+Hex(*lpSubKey)+" *phkResult: "+Hex(*phkResult)+" "+Result2Str(Result))
			ElseIf Not CreateKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result,*lpdwDisposition)
				Result = Original_RegCreateKeyExW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyExW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyTransacted(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGCREATEKEYTRANSACTED
	Global Original_RegCreateKeyTransactedA.RegCreateKeyTransacted
	Procedure.l Detour_RegCreateKeyTransactedA(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyTransactedA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
		CompilerElse
			If *lpSubKey = 0 Or *phkResult = 0
				Result = 1010
				DbgReg("RegCreateKeyTransactedA (?): *lpSubKey: "+Hex(*lpSubKey)+" *phkResult: "+Hex(*phkResult)+" "+Result2Str(Result))
			ElseIf Not CreateKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result,*lpdwDisposition)
				Result = Original_RegCreateKeyTransactedA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyTransactedA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegCreateKeyTransactedW.RegCreateKeyTransacted
	Procedure.l Detour_RegCreateKeyTransactedW(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegCreateKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyTransactedW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
		CompilerElse
			If *lpSubKey = 0 Or *phkResult = 0
				Result = 1010
				DbgReg("RegCreateKeyTransactedW (?): *lpSubKey: "+Hex(*lpSubKey)+" *phkResult: "+Hex(*phkResult)+" "+Result2Str(Result))
			ElseIf Not CreateKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result,*lpdwDisposition)
				Result = Original_RegCreateKeyTransactedW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyTransactedW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regopenkeya
Prototype.l RegOpenKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEY
	Global Original_RegOpenKeyA.RegOpenKey
	Procedure.l Detour_RegOpenKeyA(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyA(hKey,*lpSubKey,*phkResult)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyA(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegOpenKeyW.RegOpenKey
	Procedure.l Detour_RegOpenKeyW(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyW(hKey,*lpSubKey,*phkResult)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyW(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regopenkeyexa
Prototype.l RegOpenKeyEx(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYEX
	Global Original_RegOpenKeyExA.RegOpenKeyEx
	Procedure.l Detour_RegOpenKeyExA(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyExA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyExA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyExA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegOpenKeyExW.RegOpenKeyEx
	Procedure.l Detour_RegOpenKeyExW(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyExW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyExW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyExW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKeyTransacted(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGOPENKEYTRANSACTED
	Global Original_RegOpenKeyTransactedA.RegOpenKeyTransacted
	Procedure.l Detour_RegOpenKeyTransactedA(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyTransactedA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZA(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyTransactedA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyTransactedA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegOpenKeyTransactedW.RegOpenKeyTransacted
	Procedure.l Detour_RegOpenKeyTransactedW(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegOpenKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyTransactedW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
		CompilerElse
			If Not OpenKey(hKey,LPeekSZU(*lpSubKey),*phkResult,@Result)
				Result = Original_RegOpenKeyTransactedW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyTransactedW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeya
Prototype.l RegDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETEKEY
	Global Original_RegDeleteKeyA.RegDeleteKey
	Procedure.l Detour_RegDeleteKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyA(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZA(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteKeyW.RegDeleteKey
	Procedure.l Detour_RegDeleteKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyW(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZU(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeyexa
Prototype.l RegDeleteKeyEx(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
CompilerIf #DETOUR_REGDELETEKEYEX
	Global Original_RegDeleteKeyExA.RegDeleteKeyEx
	Procedure.l Detour_RegDeleteKeyExA(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyExA(hKey,*lpSubKey,samDesired,Reserved)
		CompilerElse
			If Not DelKey(hKey,LPeekSZA(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyExA(hKey,*lpSubKey,samDesired,Reserved)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyExA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteKeyExW.RegDeleteKeyEx
	Procedure.l Detour_RegDeleteKeyExW(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyExW(hKey,*lpSubKey,samDesired,Reserved)
		CompilerElse
			If Not DelKey(hKey,LPeekSZU(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyExW(hKey,*lpSubKey,samDesired,Reserved)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyExW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyTransacted(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGDELETEKEYTRANSACTED
	Global Original_RegDeleteKeyTransactedA.RegDeleteKeyTransacted
	Procedure.l Detour_RegDeleteKeyTransactedA(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyTransactedA(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
		CompilerElse
			If Not DelKey(hKey,LPeekSZA(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyTransactedA(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyTransactedA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteKeyTransactedW.RegDeleteKeyTransacted
	Procedure.l Detour_RegDeleteKeyTransactedW(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyTransactedW(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
		CompilerElse
			If Not DelKey(hKey,LPeekSZU(*lpSubKey),@Result)
				Result = Original_RegDeleteKeyTransactedW(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyTransactedW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletetreea
Prototype.l RegDeleteTree(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETETREE
	Global Original_RegDeleteTreeA.RegDeleteTree
	Procedure.l Detour_RegDeleteTreeA(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteTreeA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZA(*lpSubKey),@Result)
				Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteTreeA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteTreeW.RegDeleteTree
	Procedure.l Detour_RegDeleteTreeW(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteTreeW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZU(*lpSubKey),@Result)
				Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteTreeW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeletekeya
Prototype.l SHDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEKEY
	Global Original_SHDeleteKeyA.SHDeleteKey
	Procedure.l Detour_SHDeleteKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteKeyA(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZA(*lpSubKey),@Result)
				Result = Original_SHDeleteKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteKeyA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHDeleteKeyW.SHDeleteKey
	Procedure.l Detour_SHDeleteKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteKeyW(hKey,*lpSubKey)
		CompilerElse
			If Not DelKey(hKey,LPeekSZU(*lpSubKey),@Result)
				Result = Original_SHDeleteKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteKeyW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeleteemptykeya
Prototype.l SHDeleteEmptyKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEEMPTYKEY
	Global Original_SHDeleteEmptyKeyA.SHDeleteEmptyKey
	Procedure.l Detour_SHDeleteEmptyKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteEmptyKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteEmptyKeyA(hKey,*lpSubKey)
		CompilerElse
			Protected sKey.s, SubKey.s
			sKey = GetKey(hKey)
			If sKey
				SubKey = LPeekSZA(*lpSubKey)
				If SubKey : sKey + "\" + SubKey : EndIf
				If IsEmptyKey(sKey)
					DelKey(hKey,SubKey,@Result)
				EndIf
			Else
				Result = Original_SHDeleteEmptyKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteEmptyKeyA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHDeleteEmptyKeyW.SHDeleteEmptyKey
	Procedure.l Detour_SHDeleteEmptyKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteEmptyKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteEmptyKeyW(hKey,*lpSubKey)
		CompilerElse
			Protected sKey.s, SubKey.s
			sKey = GetKey(hKey)
			If sKey
				SubKey = LPeekSZU(*lpSubKey)
				If SubKey : sKey + "\" + SubKey : EndIf
				If IsEmptyKey(sKey)
					DelKey(hKey,SubKey,@Result)
				EndIf
			Else
				Result = Original_SHDeleteEmptyKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteEmptyKeyW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletevaluea
Prototype.l RegDeleteValue(hKey.l,*lpValueName)
CompilerIf #DETOUR_REGDELETEVALUE
	Global Original_RegDeleteValueA.RegDeleteValue
	Procedure.l Detour_RegDeleteValueA(hKey.l,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteValueA(hKey,*lpValueName)
		CompilerElse
			If Not DelData(hKey,LPeekSZA(*lpValueName),@Result)
				Result = Original_RegDeleteValueA(hKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteValueW.RegDeleteValue
	Procedure.l Detour_RegDeleteValueW(hKey.l,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteValueW(hKey,*lpValueName)
		CompilerElse
			If Not DelData(hKey,LPeekSZU(*lpValueName),@Result)
				Result = Original_RegDeleteValueW(hKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeyvaluea
Prototype.l RegDeleteKeyValue(hkey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_REGDELETEKEYVALUE
	Global Original_RegDeleteKeyValueA.RegDeleteKeyValue
	Procedure.l Detour_RegDeleteKeyValueA(hkey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyValueA(hkey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected vKey
			If OpenKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				DelData(vKey,LPeekSZA(*lpValueName),@Result)
			Else
				Result = Original_RegDeleteKeyValueA(hkey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegDeleteKeyValueW.RegDeleteKeyValue
	Procedure.l Detour_RegDeleteKeyValueW(hkey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegDeleteKeyValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyValueW(hkey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				DelData(vKey,LPeekSZU(*lpValueName),@Result)
			Else
				Result = Original_RegDeleteKeyValueW(hkey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeletevaluea
Prototype.l SHDeleteValue(hKey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_SHDELETEVALUE
	Global Original_SHDeleteValueA.SHDeleteValue
	Procedure.l Detour_SHDeleteValueA(hKey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteValueA(hKey,*lpSubKey,*lpValueName)
		CompilerElse
			If Not DelData(hKey,LPeekSZU(*lpValueName),@Result)
				Result = DelCfg(RTrim(GetKey(hKey)+"\"+LPeekSZU(*lpSubKey),"\"),LPeekSZA(*lpValueName))
			Else
				Result = Original_SHDeleteValueA(hKey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHDeleteValueW.SHDeleteValue
	Procedure.l Detour_SHDeleteValueW(hKey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHDeleteValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteValueW(hKey,*lpSubKey,*lpValueName)
		CompilerElse
			If IsKey(hKey)
				Result = DelCfg(RTrim(GetKey(hKey)+"\"+LPeekSZU(*lpSubKey),"\"),LPeekSZU(*lpValueName))
			Else
				Result = Original_SHDeleteValueW(hKey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumkeyw
Prototype.l RegEnumKey(hKey.l,dwIndex.l,*lpName,cbName.l)
CompilerIf #DETOUR_REGENUMKEY
	Global Original_RegEnumKeyA.RegEnumKey
	Procedure.l Detour_RegEnumKeyA(hKey.l,dwIndex.l,*lpName,cbName.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumKeyA: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumKeyA(hKey,dwIndex.l,*lpName,cbName)
		CompilerElse
			If IsKey(hKey)
				Result = EnumKeyA(hKey,dwIndex,*lpName,@cbName)
			Else
				Result = Original_RegEnumKeyA(hKey,dwIndex,*lpName,cbName)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT And Result = #NO_ERROR
				DbgReg("RegEnumKeyA: "+LPeekSZA(*lpName,cbName)) ; ??? cbName
			EndIf
			DbgRegExt("RegEnumKeyA: "+Result2Str(Result))
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegEnumKeyW.RegEnumKey
	Procedure.l Detour_RegEnumKeyW(hKey.l,dwIndex.l,*lpName,cbName.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumKeyW: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumKeyW(hKey,dwIndex.l,*lpName,cbName)
		CompilerElse
			If IsKey(hKey)
				Result = EnumKeyW(hKey,dwIndex,*lpName,@cbName)
			Else
				Result = Original_RegEnumKeyW(hKey,dwIndex,*lpName,cbName)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT And Result = #NO_ERROR
				DbgReg("RegEnumKeyW: "+LPeekSZU(*lpName,cbName)) ; ??? cbName
			EndIf
			DbgRegExt("RegEnumKeyW: "+Result2Str(Result))
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumkeyexwa
Prototype.l RegEnumKeyEx(hKey.l,dwIndex.l,*lpName,*lpcbName.Long,*lpReserved.Long,*lpClass,*lpcbClass.Long,*lpftLastWriteTime.FILETIME)
CompilerIf #DETOUR_REGENUMKEYEX
	Global Original_RegEnumKeyExA.RegEnumKeyEx
	Procedure.l Detour_RegEnumKeyExA(hKey.l,dwIndex.l,*lpName,*lpcbName.Long,*lpReserved.Long,*lpClass,*lpcbClass.Long,*lpftLastWriteTime.FILETIME)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumKeyExA: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumKeyExA(hKey,dwIndex,*lpName,*lpcbName,*lpReserved,*lpClass,*lpcbClass,*lpftLastWriteTime)
		CompilerElse
			If IsKey(hKey)
				Result = EnumKeyA(hKey,dwIndex,*lpName,*lpcbName)
			Else
				Result = Original_RegEnumKeyExA(hKey,dwIndex,*lpName,*lpcbName,*lpReserved,*lpClass,*lpcbClass,*lpftLastWriteTime)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT And Result = #NO_ERROR ; ??? Or Result = #ERROR_MORE_DATA)
				DbgReg("RegEnumKeyExA: "+LPeekSZA(*lpName)) ; ??? cbName
			EndIf
			DbgRegExt("RegEnumKeyExA: "+Result2Str(Result))
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegEnumKeyExW.RegEnumKeyEx
	Procedure.l Detour_RegEnumKeyExW(hKey.l,dwIndex.l,*lpName,*lpcbName.Long,*lpReserved.Long,*lpClass,*lpcbClass.Long,*lpftLastWriteTime.FILETIME)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumKeyExW: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumKeyExW(hKey,dwIndex,*lpName,*lpcbName,*lpReserved,*lpClass,*lpcbClass,*lpftLastWriteTime)
		CompilerElse
			If IsKey(hKey)
				Result = EnumKeyW(hKey,dwIndex,*lpName,*lpcbName)
			Else
				Result = Original_RegEnumKeyExW(hKey,dwIndex,*lpName,*lpcbName,*lpReserved,*lpClass,*lpcbClass,*lpftLastWriteTime)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT And Result = #NO_ERROR ; ??? Or Result = #ERROR_MORE_DATA
				DbgReg("RegEnumKeyExW: "+LPeekSZU(*lpName)) ; ??? cbName
			EndIf
			DbgRegExt("RegEnumKeyExW: "+Result2Str(Result))
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumvaluea
Prototype.l RegEnumValue(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpReserved,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGENUMVALUE
	Global Original_RegEnumValueA.RegEnumValue
	Procedure.l Detour_RegEnumValueA(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpReserved,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumValueA: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumValueA(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpReserved,*lpType,*lpData,*lpcbData)
		CompilerElse
			If IsKey(hKey)
				Result = EnumDataA(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpType,*lpData,*lpcbData)
			Else
				Result = Original_RegEnumValueA(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpReserved,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegEnumValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegEnumValueW.RegEnumValue
	Procedure.l Detour_RegEnumValueW(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpReserved,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegEnumValueW: "+HKey2Str(hKey)+" index: "+Str(dwIndex))
		CompilerIf Not #PORTABLE
			Result = Original_RegEnumValueW(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpReserved,*lpType,*lpData,*lpcbData)
		CompilerElse
			If IsKey(hKey)
				Result = EnumDataW(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpType,*lpData,*lpcbData)
			Else
				Result = Original_RegEnumValueW(hKey,dwIndex,*lpValueName,*lpcbValueName,*lpReserved,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegEnumValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryvaluea
Prototype.l RegQueryValue(hKey.l,*lpSubKey,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGQUERYVALUE
	Global Original_RegQueryValueA.RegQueryValue
	Procedure.l Detour_RegQueryValueA(hKey.l,*lpSubKey,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueA(hKey,*lpSubKey,*lpData,*lpcbData)
		CompilerElse
			Protected ValueType.l, vKey.l
			If OpenKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = GetDataA(vKey,"",@ValueType,*lpData,*lpcbData)
			Else
				Result = Original_RegQueryValueA(hKey,*lpSubKey,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegQueryValueW.RegQueryValue
	Procedure.l Detour_RegQueryValueW(hKey.l,*lpSubKey,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueW(hKey,*lpSubKey,*lpData,*lpcbData)
		CompilerElse
			Protected ValueType.l, vKey.l
			If OpenKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = GetDataW(vKey,"",@ValueType,*lpData,*lpcbData)
			Else
				Result = Original_RegQueryValueW(hKey,*lpSubKey,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryvalueexa
Prototype.l RegQueryValueEx(hKey.l,*lpValueName,*lpReserved.Long,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGQUERYVALUEEX
	Global Original_RegQueryValueExA.RegQueryValueEx
	Procedure.l Detour_RegQueryValueExA(hKey.l,*lpValueName,*lpReserved.Long,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryValueExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueExA(hKey,*lpValueName,*lpReserved,*lpType,*lpData,*lpcbData)
		CompilerElse
			If IsKey(hKey)
				Result = GetDataA(hKey,LPeekSZA(*lpValueName),*lpType,*lpData,*lpcbData)
			Else
				Result = Original_RegQueryValueExA(hKey,*lpValueName,*lpReserved,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryValueExA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegQueryValueExW.RegQueryValueEx
	Procedure.l Detour_RegQueryValueExW(hKey.l,*lpValueName,*lpReserved.Long,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryValueExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueExW(hKey,*lpValueName,*lpReserved,*lpType,*lpData,*lpcbData)
		CompilerElse
			If IsKey(hKey)
				Result = GetDataW(hKey,LPeekSZU(*lpValueName),*lpType,*lpData,*lpcbData)
			Else
				Result = Original_RegQueryValueExW(hKey,*lpValueName,*lpReserved,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryValueExW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-reggetvaluea
Prototype.l RegGetValue(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGGETVALUE
	Global Original_RegGetValueA.RegGetValue
	Procedure.l Detour_RegGetValueA(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegGetValueA(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData,*lpcbData)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey.l,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = GetDataA(vKey,LPeekSZA(*lpValueName),*lpType,*lpData,*lpcbData,rrfFlags)
			Else
				Result = Original_RegGetValueA(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegGetValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegGetValueW.RegGetValue
	Procedure.l Detour_RegGetValueW(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType.Long,*lpData,*lpcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegGetValueW(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData,*lpcbData)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey.l,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = GetDataW(vKey,LPeekSZU(*lpValueName),*lpType,*lpData,*lpcbData,rrfFlags)
			Else
				Result = Original_RegGetValueW(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegGetValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shgetvaluea
Prototype.l SHGetValue(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHGETVALUE
	Global Original_SHGetValueA.SHGetValue
	Procedure.l Detour_SHGetValueA(hKey.l,*lpSubKey,*lpValueName,*pdwType.Long,*pvData,*pcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetValueA(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey.l,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = GetDataA(vKey,LPeekSZA(*lpValueName),*pdwType,*pvData,*pcbData)
			Else
				Result = Original_SHGetValueA(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHGetValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHGetValueW.SHGetValue
	Procedure.l Detour_SHGetValueW(hKey.l,*lpSubKey,*lpValueName,*pdwType.Long,*pvData,*pcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetValueW(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey.l,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = GetDataW(vKey,LPeekSZU(*lpValueName),*pdwType,*pvData,*pcbData)
			Else
				Result = Original_SHGetValueW(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHGetValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryvalueexa
; These functions behave just like RegQueryValueEx(), except if the data type is REG_SZ, REG_EXPAND_SZ or REG_MULTI_SZ
; then the string is guaranteed to be properly null terminated.
; Additionally, if the data type is REG_EXPAND_SZ these functions will go ahead and expand out the string,
; and "massage" the returned *pdwType to be REG_SZ.
Prototype.l SHQueryValueEx(hKey.l,*lpValueName,*pdwReserved.Long,*pdwType.Long,*pvData,*pcbData.Long)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shreggetvaluea
; TODO: srrfFlags https://learn.microsoft.com/ru-ru/windows/win32/shell/srrf
Prototype.l SHRegGetValue(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHREGGETVALUE
	Global Original_SHRegGetValueA.SHRegGetValue
	Procedure.l Detour_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType.Long,*pvData,*pcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHRegGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected vKey.l
			If OpenKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = GetDataA(vKey,LPeekSZA(*lpValueName),*pdwType,*pvData,*pcbData)
			Else
				Result = Original_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHRegGetValueW.SHRegGetValue
	Procedure.l Detour_SHRegGetValueW(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType.Long,*pvData,*pcbData.Long)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHRegGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetValueW(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		CompilerElse
			If IsKey(hKey)
				Result = GetDataW(hKey,LPeekSZU(*lpValueName),*pdwType,*pvData,*pcbData)
			Else
				Result = Original_SHRegGetValueW(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-shreggetboolusvaluea
Prototype SHRegGetBoolUSValue(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
CompilerIf #DETOUR_SHREGGETBOOLUSVALUE
	Global Original_SHRegGetBoolUSValueA.SHRegGetBoolUSValue
	Procedure Detour_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		Protected Result
		RegCriticalEnter
		DbgReg("SHRegGetBoolUSValueA: "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		CompilerElse
			Protected SubKey.s = CheckKey(0,LPeekSZA(*lpSubKey))
			If SubKey
				Protected iCfg = CfgExist(SubKey,LPeekSZA(*lpValueName))
				If iCfg
					Result = Cfg(iCfg)\l
				Else
					Result = fDefault
				EndIf
			Else
				Result = Original_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
			EndIf
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHRegGetBoolUSValueW.SHRegGetBoolUSValue
	Procedure Detour_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		Protected Result
		RegCriticalEnter
		DbgReg("SHRegGetBoolUSValueW: "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		CompilerElse
			Protected SubKey.s = CheckKey(0,LPeekSZU(*lpSubKey))
			If SubKey
				Protected iCfg = CfgExist(SubKey,LPeekSZU(*lpValueName))
				If iCfg
					Result = Cfg(iCfg)\l
				Else
					Result = fDefault
				EndIf
			Else
				Result = Original_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
			EndIf
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shreggetintw
;Prototype.l SHRegGetInt(hKey.l,*pwzKey,iDefault) ; только unicode

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shreggetpatha
;Prototype.l SHRegGetPath(hKey.l,*lpSubKey,*lpValueName,*pszPath,dwFlags.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetvaluea
Prototype.l RegSetValue(hKey.l,*lpSubKey,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETVALUE
	Global Original_RegSetValueA.RegSetValue
	Procedure.l Detour_RegSetValueA(hKey.l,*lpSubKey,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueA(hKey,*lpSubKey,dwType,*lpData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = SetDataA(vKey,"",dwType,*lpData,cbData)
			Else
				Result = Original_RegSetValueA(hKey,*lpSubKey,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegSetValueW.RegSetValue
	Procedure.l Detour_RegSetValueW(hKey.l,*lpSubKey,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueW(hKey,*lpSubKey,dwType,*lpData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = SetDataW(vKey,"",dwType,*lpData,cbData)
			Else
				Result = Original_RegSetValueW(hKey,*lpSubKey,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetvalueexa
Prototype.l RegSetValueEx(hKey.l,*lpValueName,dwReserved.l,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETVALUEEX
	Global Original_RegSetValueExA.RegSetValueEx
	Procedure.l Detour_RegSetValueExA(hKey.l,*lpValueName,dwReserved.l,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetValueExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueExA(hKey,*lpValueName,dwReserved,dwType,*lpData,cbData)
		CompilerElse
			If IsKey(hKey)
				Result = SetDataA(hKey,LPeekSZA(*lpValueName),dwType,*lpData,cbData)
			Else
				Result = Original_RegSetValueExA(hKey,*lpValueName,dwReserved,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueExA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegSetValueExW.RegSetValueEx
	Procedure.l Detour_RegSetValueExW(hKey.l,*lpValueName,dwReserved.l,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetValueExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueExW(hKey,*lpValueName,dwReserved,dwType,*lpData,cbData)
		CompilerElse
			If IsKey(hKey)
				Result = SetDataW(hKey,LPeekSZU(*lpValueName),dwType,*lpData,cbData)
			Else
				Result = Original_RegSetValueExW(hKey,*lpValueName,dwReserved,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueExW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetkeyvaluea
Prototype.l RegSetKeyValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETKEYVALUE
	Global Original_RegSetKeyValueA.RegSetKeyValue
	Procedure.l Detour_RegSetKeyValueA(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetKeyValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetKeyValueA(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = SetDataA(vKey,LPeekSZA(*lpValueName),dwType,*lpData,cbData)
			Else
				Result = Original_RegSetKeyValueA(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetKeyValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegSetKeyValueW.RegSetKeyValue
	Procedure.l Detour_RegSetKeyValueW(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegSetKeyValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetKeyValueW(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = SetDataW(vKey,LPeekSZU(*lpValueName),dwType,*lpData,cbData)
			Else
				Result = Original_RegSetKeyValueW(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetKeyValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shsetvaluea
Prototype.l SHSetValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*pvData,cbData.l)
CompilerIf #DETOUR_SHSETVALUE
	Global Original_SHSetValueA.SHSetValue
	Procedure.l Detour_SHSetValueA(hKey.l,*lpSubKey,*lpValueName,dwType.l,*pvData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHSetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHSetValueA(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = SetDataA(vKey,LPeekSZA(*lpValueName),dwType,*pvData,cbData)
			Else
				Result = Original_SHSetValueA(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHSetValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_SHSetValueW.SHSetValue
	Procedure.l Detour_SHSetValueW(hKey.l,*lpSubKey,*lpValueName,dwType.l,*pvData,cbData.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHSetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHSetValueW(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
		CompilerElse
			Protected vKey.l
			If CreateKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = SetDataW(vKey,LPeekSZU(*lpValueName),dwType,*pvData,cbData)
			Else
				Result = Original_SHSetValueW(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHSetValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregsetvalue
; TODO: srrfFlags
; Prototype.l SHRegSetValue(hkey.l,*lpSubKey,*lpValueName,srrfFlags,dwType.l,*pvData,cbData.l)
; CompilerIf #DETOUR_SHREGSETVALUE
; 	Global Original_SHRegSetValue.SHRegSetValue
; 	Procedure.l Detour_SHRegSetValue(hkey.l,*lpSubKey,*lpValueName,srrfFlags,dwType.l,*pvData,cbData.l)
; 		Protected Result.l
; 		RegCriticalEnter
; 		DbgReg("SHRegSetValue: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
; 		CompilerIf Not #PORTABLE
; 			Result = Original_SHSetValueW(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
; 		CompilerElse
; 			Protected vKey.l
; 			If CreateKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
; 				Result = SetDataW(vKey,LPeekSZU(*lpValueName),dwType,*pvData,cbData)
; 			Else
; 				Result = Original_SHSetValueW(hKey,*lpSubKey,*lpValueName,dwType,*pvData,cbData)
; 			EndIf
; 		CompilerEndIf
; 		DbgRegExt("SHRegSetValue: "+Result2Str(Result))
; 		RegCriticalLeave
; 		ProcedureReturn Result
; 	EndProcedure
; CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregsetpatha
;Prototype.l SHRegSetPath(hKey.l,*lpSubKey,*lpValueName,*pcszPath,dwFlags.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryinfokeya
Prototype.l RegQueryInfoKey(hKey.l,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys.Long,*lpcMaxSubKeyLen.Long,*lpcMaxClassLen.Long,*lpcValues.Long,*lpcMaxValueNameLen.Long,*lpcMaxValueLen.Long,*lpcbSecurityDescriptor.Long,*lpftLastWriteTime)
CompilerIf #DETOUR_REGQUERYINFOKEY
	Global Original_RegQueryInfoKeyA.RegQueryInfoKey
	Procedure.l Detour_RegQueryInfoKeyA(hKey.l,*lpClass,*lpcbClass.Long,*lpReserved,*lpcSubKeys.Long,*lpcMaxSubKeyLen.Long,*lpcMaxClassLen.Long,*lpcValues.Long,*lpcMaxValueNameLen.Long,*lpcMaxValueLen.Long,*lpcbSecurityDescriptor.Long,*lpftLastWriteTime)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryInfoKeyA: "+HKey2Str(hKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryInfoKeyA(hKey,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen,*lpcbSecurityDescriptor,*lpftLastWriteTime)
		CompilerElse
			If IsKey(hKey)
				Result = KeyInfo(hKey,*lpClass,*lpcbClass,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen)
			Else
				Result = Original_RegQueryInfoKeyA(hKey,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen,*lpcbSecurityDescriptor,*lpftLastWriteTime)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT
				If *lpClass
					DbgRegVirt("RegQueryInfoKeyA: Class: "+PeekS(*lpClass,-1,#PB_Ascii))
				EndIf
				If *lpcbClass
					DbgRegVirt("RegQueryInfoKeyA: cbClass: "+Str(*lpcbClass\l))
				EndIf
				If *lpcSubKeys
					DbgRegVirt("RegQueryInfoKeyA: cSubKeys: "+Str(*lpcSubKeys\l))
				EndIf
				If *lpcMaxSubKeyLen
					DbgRegVirt("RegQueryInfoKeyA: cMaxSubKeyLen: "+Str(*lpcMaxSubKeyLen\l))
				EndIf
				If *lpcValues
					DbgRegVirt("RegQueryInfoKeyA: cValues: "+Str(*lpcValues\l))
				EndIf
				If *lpcMaxValueNameLen
					DbgRegVirt("RegQueryInfoKeyA: cMaxValueNameLen: "+Str(*lpcMaxValueNameLen\l))
				EndIf
				If *lpcMaxValueLen
					DbgRegVirt("RegQueryInfoKeyA: cMaxValueLen: "+Str(*lpcMaxValueLen\l))
				EndIf
				If *lpcbSecurityDescriptor
					DbgRegVirt("RegQueryInfoKeyA: cbSecurityDescriptor: "+Str(*lpcbSecurityDescriptor\l))
				EndIf
				If *lpftLastWriteTime
					DbgRegVirt("RegQueryInfoKeyA: ftLastWriteTime")
				EndIf
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryInfoKeyA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	Global Original_RegQueryInfoKeyW.RegQueryInfoKey
	Procedure.l Detour_RegQueryInfoKeyW(hKey.l,*lpClass,*lpcbClass.Long,*lpReserved,*lpcSubKeys.Long,*lpcMaxSubKeyLen.Long,*lpcMaxClassLen.Long,*lpcValues.Long,*lpcMaxValueNameLen.Long,*lpcMaxValueLen.Long,*lpcbSecurityDescriptor.Long,*lpftLastWriteTime)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryInfoKeyW: "+HKey2Str(hKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryInfoKeyW(hKey,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen,*lpcbSecurityDescriptor,*lpftLastWriteTime)
		CompilerElse
			If IsKey(hKey)
				Result = KeyInfo(hKey,*lpClass,*lpcbClass,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen)
			Else
				Result = Original_RegQueryInfoKeyA(hKey,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys,*lpcMaxSubKeyLen,*lpcMaxClassLen,*lpcValues,*lpcMaxValueNameLen,*lpcMaxValueLen,*lpcbSecurityDescriptor,*lpftLastWriteTime)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_REGISTRY_MODE
			If DbgRegMode >= #DBG_REG_MODE_EXT
				If *lpClass
					DbgRegVirt("RegQueryInfoKeyW: Class: "+PeekS(*lpClass))
				EndIf
				If *lpcbClass
					DbgRegVirt("RegQueryInfoKeyW: cbClass: "+Str(*lpcbClass\l))
				EndIf
				If *lpcSubKeys
					DbgRegVirt("RegQueryInfoKeyW: cSubKeys: "+Str(*lpcSubKeys\l))
				EndIf
				If *lpcMaxSubKeyLen
					DbgRegVirt("RegQueryInfoKeyW: cMaxSubKeyLen: "+Str(*lpcMaxSubKeyLen\l))
				EndIf
				If *lpcValues
					DbgRegVirt("RegQueryInfoKeyW: cValues: "+Str(*lpcValues\l))
				EndIf
				If *lpcMaxValueNameLen
					DbgRegVirt("RegQueryInfoKeyW: cMaxValueNameLen: "+Str(*lpcMaxValueNameLen\l))
				EndIf
				If *lpcMaxValueLen
					DbgRegVirt("RegQueryInfoKeyW: cMaxValueLen: "+Str(*lpcMaxValueLen\l))
				EndIf
				If *lpcbSecurityDescriptor
					DbgRegVirt("RegQueryInfoKeyW: cbSecurityDescriptor: "+Str(*lpcbSecurityDescriptor\l))
				EndIf
				If *lpftLastWriteTime
					DbgRegVirt("RegQueryInfoKeyW: ftLastWriteTime")
				EndIf
			EndIf
		CompilerEndIf
		DbgRegExt("RegQueryInfoKeyW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryinfokeya
Prototype.l SHQueryInfoKey(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
CompilerIf #DETOUR_SHQUERYINFOKEY
	Global Original_SHQueryInfoKeyA.SHQueryInfoKey
	Procedure Detour_SHQueryInfoKeyA(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHQueryInfoKeyA: "+HKey2Str(hKey)+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHQueryInfoKeyA(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		CompilerElse
			Protected vKey
			If OpenKey(hKey,LPeekSZA(*lpSubKey),@vKey,@Result)
				Result = KeyInfo(vKey,#Null,#Null,#Null,*lpcMaxSubKeyLen,#Null,*lpcValues,*lpcMaxValueNameLen,#Null)
			Else
				Result = Original_SHQueryInfoKeyA(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
			EndIf
		CompilerEndIf
		DbgRegExt("SHQueryInfoKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	Global Original_SHQueryInfoKeyW.SHQueryInfoKey
	Procedure Detour_SHQueryInfoKeyW(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHQueryInfoKeyW: "+HKey2Str(hKey)+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHQueryInfoKeyW(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		CompilerElse
			Protected vKey
			If OpenKey(hKey,LPeekSZU(*lpSubKey),@vKey,@Result)
				Result = KeyInfo(vKey,#Null,#Null,#Null,*lpcMaxSubKeyLen,#Null,*lpcValues,*lpcMaxValueNameLen,#Null)
			Else
				Result = Original_SHQueryInfoKeyW(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
			EndIf
		CompilerEndIf
		DbgRegExt("SHQueryInfoKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegFlushKey(hKey.l)
CompilerIf #DETOUR_REGFLUSHKEY
	Global Original_RegFlushKey.RegFlushKey
	Procedure.l Detour_RegFlushKey(hKey.l)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegFlushKey: "+HKey2Str(hKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegFlushKey(hKey)
		CompilerElse
			If IsKey(hKey)
				WriteCfg()
				Result = #NO_ERROR
			Else
				Result = Original_RegFlushKey(hKey)
			EndIf
		CompilerEndIf
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = AAAAAAAAAA9
; EnableThread
; DisableDebugger
; EnableExeConstant