;;======================================================================================================================
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
	;Global Trampoline_RegCloseKey = @Detour_RegCloseKey()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regcreatekeya
; TODO: lpSubKey = Null
Prototype.l RegCreateKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGCREATEKEYA
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
	;Global Trampoline_RegCreateKeyA = @Detour_RegCreateKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYW
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
	;Global Trampoline_RegCreateKeyW = @Detour_RegCreateKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regcreatekeyexa
Prototype.l RegCreateKeyEx(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
CompilerIf #DETOUR_REGCREATEKEYEXA
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
	;Global Trampoline_RegCreateKeyExA = @Detour_RegCreateKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYEXW
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
	;Global Trampoline_RegCreateKeyExW = @Detour_RegCreateKeyExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyTransacted(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDA
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
	;Global Trampoline_RegCreateKeyTransactedA = @Detour_RegCreateKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDW
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
	;Global Trampoline_RegCreateKeyTransactedW = @Detour_RegCreateKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regopenkeya
Prototype.l RegOpenKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYA
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
	;Global Trampoline_RegOpenKeyA = @Detour_RegOpenKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYW
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
	;Global Trampoline_RegOpenKeyW = @Detour_RegOpenKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regopenkeyexa
Prototype.l RegOpenKeyEx(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYEXA
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
	;Global Trampoline_RegOpenKeyExA = @Detour_RegOpenKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYEXW
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
	;Global Trampoline_RegOpenKeyExW = @Detour_RegOpenKeyExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKeyTransacted(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGOPENKEYTRANSACTEDA
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
	;Global Trampoline_RegOpenKeyTransactedA = @Detour_RegOpenKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYTRANSACTEDW
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
	;Global Trampoline_RegOpenKeyTransactedW = @Detour_RegOpenKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeya
Prototype.l RegDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETEKEYA
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
	;Global Trampoline_RegDeleteKeyA = @Detour_RegDeleteKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYW
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
	;Global Trampoline_RegDeleteKeyW = @Detour_RegDeleteKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeyexa
Prototype.l RegDeleteKeyEx(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
CompilerIf #DETOUR_REGDELETEKEYEXA
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
	;Global Trampoline_RegDeleteKeyExA = @Detour_RegDeleteKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYEXW
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
	;Global Trampoline_RegDeleteKeyExW = @Detour_RegDeleteKeyExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyTransacted(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDA
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
	;Global Trampoline_RegDeleteKeyTransactedA = @Detour_RegDeleteKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDW
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
	;Global Trampoline_RegDeleteKeyTransactedW = @Detour_RegDeleteKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletetreea
Prototype.l RegDeleteTree(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETETREEA
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
	;Global Trampoline_RegDeleteTreeA = @Detour_RegDeleteTreeA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETETREEW
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
	;Global Trampoline_RegDeleteTreeW = @Detour_RegDeleteTreeW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeletekeya
Prototype.l SHDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEKEYA
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
	;Global Trampoline_SHDeleteKeyA = @Detour_SHDeleteKeyA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEKEYW
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
	;Global Trampoline_SHDeleteKeyW = @Detour_SHDeleteKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeleteemptykeya
Prototype.l SHDeleteEmptyKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEEMPTYKEYA
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
	;Global Trampoline_SHDeleteEmptyKeyA = @Detour_SHDeleteEmptyKeyA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEEMPTYKEYW
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
	;Global Trampoline_SHDeleteEmptyKeyW = @Detour_SHDeleteEmptyKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletevaluea
Prototype.l RegDeleteValue(hKey.l,*lpValueName)
CompilerIf #DETOUR_REGDELETEVALUEA
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
	;Global Trampoline_RegDeleteValueA = @Detour_RegDeleteValueA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEVALUEW
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
	;Global Trampoline_RegDeleteValueW = @Detour_RegDeleteValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeyvaluea
Prototype.l RegDeleteKeyValue(hkey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_REGDELETEKEYVALUEA
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
	;Global Trampoline_RegDeleteKeyValueA = @Detour_RegDeleteKeyValueA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYVALUEW
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
	;Global Trampoline_RegDeleteKeyValueW = @Detour_RegDeleteKeyValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeletevaluea
Prototype.l SHDeleteValue(hKey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_SHDELETEVALUEA
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
	;Global Trampoline_SHDeleteValueA = @Detour_SHDeleteValueA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEVALUEW
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
	;Global Trampoline_SHDeleteValueW = @Detour_SHDeleteValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumkeyw
Prototype.l RegEnumKey(hKey.l,dwIndex.l,*lpName,cbName.l)
CompilerIf #DETOUR_REGENUMKEYA
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
	;Global Trampoline_RegEnumKeyA = @Detour_RegEnumKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGENUMKEYW
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
	;Global Trampoline_RegEnumKeyW = @Detour_RegEnumKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumkeyexwa
Prototype.l RegEnumKeyEx(hKey.l,dwIndex.l,*lpName,*lpcbName.Long,*lpReserved.Long,*lpClass,*lpcbClass.Long,*lpftLastWriteTime.FILETIME)
CompilerIf #DETOUR_REGENUMKEYEXA
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
	;Global Trampoline_RegEnumKeyExA = @Detour_RegEnumKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGENUMKEYEXW
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
	;Global Trampoline_RegEnumKeyExW = @Detour_RegEnumKeyExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regenumvaluea
Prototype.l RegEnumValue(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpReserved,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGENUMVALUEA
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
	;Global Trampoline_RegEnumValueA = @Detour_RegEnumValueA()
CompilerEndIf
CompilerIf #DETOUR_REGENUMVALUEW
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
	;Global Trampoline_RegEnumValueW = @Detour_RegEnumValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryvaluea
Prototype.l RegQueryValue(hKey.l,*lpSubKey,*lpValue,*lpcbValue.Long)
CompilerIf #DETOUR_REGQUERYVALUEA
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
		DbgRegExt("RegEnumValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegQueryValueA = @Detour_RegQueryValueA()
CompilerEndIf
CompilerIf #DETOUR_REGQUERYVALUEW
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
		DbgRegExt("RegEnumValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegQueryValueW = @Detour_RegQueryValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryvalueexa
Prototype.l RegQueryValueEx(hKey.l,*lpValueName,*lpReserved.Long,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGQUERYVALUEEXA
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
	;Global Trampoline_RegQueryValueExA = @Detour_RegQueryValueExA()
CompilerEndIf
CompilerIf #DETOUR_REGQUERYVALUEEXW
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
	;Global Trampoline_RegQueryValueExW = @Detour_RegQueryValueExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-reggetvaluea
Prototype.l RegGetValue(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType.Long,*lpData,*lpcbData.Long)
CompilerIf #DETOUR_REGGETVALUEA
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
	;Global Trampoline_RegGetValueA = @Detour_RegGetValueA()
CompilerEndIf
CompilerIf #DETOUR_REGGETVALUEW
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
	;Global Trampoline_RegGetValueW = @Detour_RegGetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shgetvaluea
Prototype.l SHGetValue(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHGETVALUEA
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
	;Global Trampoline_SHGetValueA = @Detour_SHGetValueA()
CompilerEndIf
CompilerIf #DETOUR_SHGETVALUEW
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
	;Global Trampoline_SHGetValueW = @Detour_SHGetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryvalueexa
; These functions behave just like RegQueryValueEx(), except if the data type is REG_SZ, REG_EXPAND_SZ or REG_MULTI_SZ
; then the string is guaranteed to be properly null terminated.
; Additionally, if the data type is REG_EXPAND_SZ these functions will go ahead and expand out the string,
; and "massage" the returned *pdwType to be REG_SZ.
Prototype.l SHQueryValueEx(hkey.l,*lpValueName,*pdwReserved.Long,*pdwType.Long,*pvData,*pcbData.Long)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shreggetvaluea
; TODO: srrfFlags https://learn.microsoft.com/ru-ru/windows/win32/shell/srrf
Prototype.l SHRegGetValue(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHREGGETVALUEA
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
	;Global Trampoline_SHRegGetValueA = @Detour_SHRegGetValueA()
CompilerEndIf
CompilerIf #DETOUR_SHREGGETVALUEW
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
	;Global Trampoline_SHRegGetValueW = @Detour_SHRegGetValueW()
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
CompilerIf #DETOUR_REGSETVALUEA
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
	;Global Trampoline_RegSetValueA = @Detour_RegSetValueA()
CompilerEndIf
CompilerIf #DETOUR_REGSETVALUEW
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
	;Global Trampoline_RegSetValueW = @Detour_RegSetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetvalueexa
Prototype.l RegSetValueEx(hKey.l,*lpValueName,dwReserved.l,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETVALUEEXA
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
	;Global Trampoline_RegSetValueExA = @Detour_RegSetValueExA()
CompilerEndIf
CompilerIf #DETOUR_REGSETVALUEEXW
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
	;Global Trampoline_RegSetValueExW = @Detour_RegSetValueExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetkeyvaluea
Prototype.l RegSetKeyValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETKEYVALUEA
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
	;Global Trampoline_RegSetKeyValueA = @Detour_RegSetKeyValueA()
CompilerEndIf
CompilerIf #DETOUR_REGSETKEYVALUEW
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
	;Global Trampoline_RegSetKeyValueW = @Detour_RegSetKeyValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shsetvaluea
Prototype.l SHSetValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*pvData,cbData.l)
CompilerIf #DETOUR_SHSETVALUEA
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
	;Global Trampoline_SHSetValueA = @Detour_SHSetValueA()
CompilerEndIf
CompilerIf #DETOUR_SHSETVALUEW
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
	;Global Trampoline_SHSetValueW = @Detour_SHSetValueW()
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
; 	;Global Trampoline_SHRegSetValue = @Detour_SHRegSetValue()
; CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregsetpatha
;Prototype.l SHRegSetPath(hKey.l,*lpSubKey,*lpValueName,*pcszPath,dwFlags.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regqueryinfokeya
Prototype.l RegQueryInfoKey(hKey.l,*lpClass,*lpcbClass,*lpReserved,*lpcSubKeys.Long,*lpcMaxSubKeyLen.Long,*lpcMaxClassLen.Long,*lpcValues.Long,*lpcMaxValueNameLen.Long,*lpcMaxValueLen.Long,*lpcbSecurityDescriptor.Long,*lpftLastWriteTime)
CompilerIf #DETOUR_REGQUERYINFOKEYA
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
	;Global Trampoline_RegQueryInfoKeyA = @Detour_RegQueryInfoKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGQUERYINFOKEYW
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
	;Global Trampoline_RegQueryInfoKeyW = @Detour_RegQueryInfoKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryinfokeya
Prototype.l SHQueryInfoKey(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
CompilerIf #DETOUR_SHQUERYINFOKEYA
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
CompilerEndIf
CompilerIf #DETOUR_SHQUERYINFOKEYW
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
	;Global Trampoline_RegFlushKey = @Detour_RegFlushKey()
CompilerEndIf
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1443
; FirstLine = 1432
; Folding = -----------
; EnableThread
; DisableDebugger
; EnableExeConstant