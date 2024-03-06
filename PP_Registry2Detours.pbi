;;======================================================================================================================
Global hAppKey.l
;;======================================================================================================================
Prototype.l RegCreateKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGCREATEKEYA
	Global Original_RegCreateKeyA.RegCreateKey
	Procedure.l Detour_RegCreateKeyA(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		DbgReg("RegCreateKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyA(hKey,*lpSubKey,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegCreateKeyA(hAppKey,*SubKeyA,*phkResult)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegCreateKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegCreateKeyA(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyA = @Detour_RegCreateKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYW
	Global Original_RegCreateKeyW.RegCreateKey
	Procedure.l Detour_RegCreateKeyW(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		DbgReg("RegCreateKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyW(hKey,*lpSubKey,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegCreateKeyW(hAppKey,@SubKey,*phkResult)
			Else
				DbgRegAliens("RegCreateKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegCreateKeyW(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyW = @Detour_RegCreateKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyEx(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
CompilerIf #DETOUR_REGCREATEKEYEXA
	Global Original_RegCreateKeyExA.RegCreateKeyEx
	Procedure.l Detour_RegCreateKeyExA(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
		Protected Result.l
		DbgReg("RegCreateKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyExA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegCreateKeyExA(hAppKey,*SubKeyA,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegCreateKeyExA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegCreateKeyExA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyExA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyExA = @Detour_RegCreateKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYEXW
	Global Original_RegCreateKeyExW.RegCreateKeyEx
	Procedure.l Detour_RegCreateKeyExW(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
		Protected Result.l
		DbgReg("RegCreateKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyExW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegCreateKeyExW(hAppKey,@SubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			Else
				DbgRegAliens("RegCreateKeyExW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegCreateKeyExW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyExW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyExW = @Detour_RegCreateKeyExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyTransacted(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDA
	Global Original_RegCreateKeyTransactedA.RegCreateKeyTransacted
	Procedure.l Detour_RegCreateKeyTransactedA(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition,hTransaction,*pExtendedParameter)
		Protected Result.l
		DbgReg("RegCreateKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyTransactedA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegCreateKeyTransactedA(hAppKey,*SubKeyA,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegCreateKeyTransactedA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegCreateKeyTransactedA(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyTransactedA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyTransactedA = @Detour_RegCreateKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGCREATEKEYTRANSACTEDW
	Global Original_RegCreateKeyTransactedW.RegCreateKeyTransacted
	Procedure.l Detour_RegCreateKeyTransactedW(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition,hTransaction,*pExtendedParameter)
		Protected Result.l
		DbgReg("RegCreateKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegCreateKeyTransactedW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegCreateKeyTransactedW(hAppKey,@SubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
			Else
				DbgRegAliens("RegCreateKeyTransactedW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegCreateKeyTransactedW(hKey,*lpSubKey,Reserved,*lpClass,dwOptions,samDesired,*lpSecurityAttributes,*phkResult,*lpdwDisposition,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegCreateKeyTransactedW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegCreateKeyTransactedW = @Detour_RegCreateKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYA
	Global Original_RegOpenKeyA.RegOpenKey
	Procedure.l Detour_RegOpenKeyA(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		DbgReg("RegOpenKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyA(hKey,*lpSubKey,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegOpenKeyA(hAppKey,*SubKeyA,*phkResult)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegOpenKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegOpenKeyA(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegOpenKeyA = @Detour_RegOpenKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYW
	Global Original_RegOpenKeyW.RegOpenKey
	Procedure.l Detour_RegOpenKeyW(hKey.l,*lpSubKey,*phkResult.Long)
		Protected Result.l
		DbgReg("RegOpenKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyW(hKey,*lpSubKey,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegOpenKeyW(hAppKey,@SubKey,*phkResult)
			Else
				DbgRegAliens("RegOpenKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegOpenKeyW(hKey,*lpSubKey,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegOpenKeyW = @Detour_RegOpenKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKeyEx(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYEXA
	Global Original_RegOpenKeyExA.RegOpenKeyEx
	Procedure.l Detour_RegOpenKeyExA(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
		Protected Result.l
		DbgReg("RegOpenKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyExA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegOpenKeyExA(hAppKey,*SubKeyA,ulOptions,samDesired,*phkResult)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegOpenKeyExA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegOpenKeyExA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyExA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegOpenKeyExA = @Detour_RegOpenKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYEXW
	Global Original_RegOpenKeyExW.RegOpenKeyEx
	Procedure.l Detour_RegOpenKeyExW(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
		Protected Result.l
		DbgReg("RegOpenKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyExW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegOpenKeyExW(hAppKey,@SubKey,ulOptions,samDesired,*phkResult)
			Else
				DbgRegAliens("RegOpenKeyExW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegOpenKeyExW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyExW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
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
		DbgReg("RegOpenKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyTransactedA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegOpenKeyTransactedA(hAppKey,*SubKeyA,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegOpenKeyTransactedA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegOpenKeyTransactedA(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyTransactedA: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegOpenKeyTransactedA = @Detour_RegOpenKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGOPENKEYTRANSACTEDW
	Global Original_RegOpenKeyTransactedW.RegOpenKeyTransacted
	Procedure.l Detour_RegOpenKeyTransactedW(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
		Protected Result.l
		DbgReg("RegOpenKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegOpenKeyTransactedW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegOpenKeyTransactedW(hAppKey,@SubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
			Else
				DbgRegAliens("RegOpenKeyTransactedW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegOpenKeyTransactedW(hKey,*lpSubKey,ulOptions,samDesired,*phkResult,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		DbgRegExt("RegOpenKeyTransactedW: "+HKey2Str(*phkResult\l)+" "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegOpenKeyTransactedW = @Detour_RegOpenKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregopenuskeya
Prototype.l SHRegOpenUSKey(*pszPath,samDesired,hRelativeUSKey.l,*phNewUSKey.Long,fIgnoreHKCU)

;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETEKEYA
	Global Original_RegDeleteKeyA.RegDeleteKey
	Procedure.l Detour_RegDeleteKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("RegDeleteKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyA(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegDeleteKeyA(hAppKey,*SubKeyA)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegDeleteKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegDeleteKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyA = @Detour_RegDeleteKeyA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYW
	Global Original_RegDeleteKeyW.RegDeleteKey
	Procedure.l Detour_RegDeleteKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("RegDeleteKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyW(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegDeleteKeyW(hAppKey,@SubKey)
			Else
				DbgRegAliens("RegDeleteKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegDeleteKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyW = @Detour_RegDeleteKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyEx(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
CompilerIf #DETOUR_REGDELETEKEYEXA
	Global Original_RegDeleteKeyExA.RegDeleteKeyEx
	Procedure.l Detour_RegDeleteKeyExA(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
		Protected Result.l
		DbgReg("RegDeleteKeyExA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyExA(hKey,*lpSubKey,samDesired,Reserved)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegDeleteKeyExA(hAppKey,*SubKeyA,samDesired,Reserved)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegDeleteKeyExA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegDeleteKeyExA(hKey,*lpSubKey,samDesired,Reserved)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyExA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyExA = @Detour_RegDeleteKeyExA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYEXW
	Global Original_RegDeleteKeyExW.RegDeleteKeyEx
	Procedure.l Detour_RegDeleteKeyExW(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
		Protected Result.l
		DbgReg("RegDeleteKeyExW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyExW(hKey,*lpSubKey,samDesired,Reserved)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegDeleteKeyExW(hAppKey,@SubKey,samDesired,Reserved)
			Else
				DbgRegAliens("RegDeleteKeyExW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegDeleteKeyExW(hKey,*lpSubKey,samDesired,Reserved)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyExW: "+Result2Str(Result))
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
		DbgReg("RegDeleteKeyTransactedA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyTransactedA(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegDeleteKeyTransactedA(hAppKey,*SubKeyA,samDesired,Reserved,hTransaction,*pExtendedParameter)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegDeleteKeyTransactedA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegDeleteKeyTransactedA(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyTransactedA = @Detour_RegDeleteKeyTransactedA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYTRANSACTEDW
	Global Original_RegDeleteKeyTransactedW.RegDeleteKeyTransacted
	Procedure.l Detour_RegDeleteKeyTransactedW(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
		Protected Result.l
		DbgRegExt("RegDeleteKeyTransactedW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyTransactedW(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegDeleteKeyTransactedW(hAppKey,@SubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
			Else
				DbgRegAliens("RegDeleteKeyTransactedW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegDeleteKeyTransactedW(hKey,*lpSubKey,samDesired,Reserved,hTransaction,*pExtendedParameter)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyTransactedW = @Detour_RegDeleteKeyTransactedW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteTree(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETETREEA
	Global Original_RegDeleteTreeA.RegDeleteTree
	Procedure.l Detour_RegDeleteTreeA(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("RegDeleteTreeA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegDeleteTreeA(hAppKey,*lpSubKey)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegDeleteTreeA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegDeleteTreeA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_ = @Detour_()
CompilerEndIf
CompilerIf #DETOUR_REGDELETETREEW
	Global Original_RegDeleteTreeW.RegDeleteTree
	Procedure.l Detour_RegDeleteTreeW(hKey.l,*lpSubKey)
		Protected Result.l
		DbgRegExt("RegDeleteTreeW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteTreeW(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegDeleteTreeW(hAppKey,@SubKey)
			Else
				DbgRegAliens("RegDeleteTreeW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegDeleteTreeW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_ = @Detour_()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEKEYA
	Global Original_SHDeleteKeyA.SHDeleteKey
	Procedure.l Detour_SHDeleteKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("SHDeleteKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteKeyA(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHDeleteKeyA(hAppKey,*SubKeyA)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHDeleteKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHDeleteKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteKeyA = @Detour_SHDeleteKeyA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEKEYW
	Global Original_SHDeleteKeyW.SHDeleteKey
	Procedure.l Detour_SHDeleteKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("SHDeleteKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteKeyW(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHDeleteKeyW(hAppKey,@SubKey)
			Else
				DbgRegAliens("SHDeleteKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHDeleteKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteKeyW = @Detour_SHDeleteKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHDeleteEmptyKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEEMPTYKEYA
	Global Original_SHDeleteEmptyKeyA.SHDeleteEmptyKey
	Procedure.l Detour_SHDeleteEmptyKeyA(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("SHDeleteEmptyKeyA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteEmptyKeyA(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHDeleteEmptyKeyA(hAppKey,*SubKeyA)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHDeleteEmptyKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHDeleteEmptyKeyA(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteEmptyKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteEmptyKeyA = @Detour_SHDeleteEmptyKeyA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEEMPTYKEYW
	Global Original_SHDeleteEmptyKeyW.SHDeleteEmptyKey
	Procedure.l Detour_SHDeleteEmptyKeyW(hKey.l,*lpSubKey)
		Protected Result.l
		DbgReg("SHDeleteEmptyKeyW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteEmptyKeyW(hKey,*lpSubKey)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHDeleteEmptyKeyW(hAppKey,@SubKey)
			Else
				DbgRegAliens("SHDeleteEmptyKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHDeleteEmptyKeyW(hKey,*lpSubKey)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteEmptyKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteEmptyKeyW = @Detour_SHDeleteEmptyKeyW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyValue(hkey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_REGDELETEKEYVALUEA
	Global Original_RegDeleteKeyValueA.RegDeleteKeyValue
	Procedure.l Detour_RegDeleteKeyValueA(hkey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		DbgReg("RegDeleteKeyValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyValueA(hkey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegDeleteKeyValueA(hAppKey,*SubKeyA,*lpValueName)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegDeleteKeyValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegDeleteKeyValueA(hkey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegDeleteKeyValueA = @Detour_RegDeleteKeyValueA()
CompilerEndIf
CompilerIf #DETOUR_REGDELETEKEYVALUEW
	Global Original_RegDeleteKeyValueW.RegDeleteKeyValue
	Procedure.l Detour_RegDeleteKeyValueW(hkey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		DbgReg("RegDeleteKeyValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegDeleteKeyValueW(hkey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegDeleteKeyValueW(hAppKey,@SubKey,*lpValueName)
			Else
				DbgRegAliens("RegDeleteKeyValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegDeleteKeyValueW(hkey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("RegDeleteKeyValueW: "+Result2Str(Result))
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
		DbgReg("SHDeleteValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteValueA(hKey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHDeleteValueA(hAppKey,*SubKeyA,*lpValueName)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHDeleteValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHDeleteValueA(hKey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteValueA = @Detour_SHDeleteValueA()
CompilerEndIf
CompilerIf #DETOUR_SHDELETEVALUEW
	Global Original_SHDeleteValueW.SHDeleteValue
	Procedure.l Detour_SHDeleteValueW(hKey.l,*lpSubKey,*lpValueName)
		Protected Result.l
		DbgReg("SHDeleteValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHDeleteValueW(hKey,*lpSubKey,*lpValueName)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHDeleteValueW(hAppKey,@SubKey,*lpValueName)
			Else
				DbgRegAliens("SHDeleteValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHDeleteValueW(hKey,*lpSubKey,*lpValueName)
			EndIf
		CompilerEndIf
		DbgRegExt("SHDeleteValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHDeleteValueW = @Detour_SHDeleteValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegQueryValue(hKey.l,*lpSubKey,*lpData,*lpcbData)
CompilerIf #DETOUR_REGQUERYVALUEA
	Global Original_RegQueryValueA.RegQueryValue
	Procedure.l Detour_RegQueryValueA(hKey.l,*lpSubKey,*lpData,*lpcbData)
		Protected Result.l
		DbgReg("RegQueryValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueA(hKey,*lpSubKey,*lpData,*lpcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegQueryValueA(hAppKey,*SubKeyA,*lpData,*lpcbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegQueryValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegQueryValueA(hKey,*lpSubKey,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegEnumValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegQueryValueA = @Detour_RegQueryValueA()
CompilerEndIf
CompilerIf #DETOUR_REGQUERYVALUEW
	Global Original_RegQueryValueW.RegQueryValue
	Procedure.l Detour_RegQueryValueW(hKey.l,*lpSubKey,*lpData,*lpcbData)
		Protected Result.l
		DbgReg("RegQueryValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryValueW(hKey,*lpSubKey,*lpData,*lpcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegQueryValueW(hAppKey,@SubKey,*lpData,*lpcbData)
			Else
				DbgRegAliens("RegQueryValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegQueryValueW(hKey,*lpSubKey,*lpData,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegEnumValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegQueryValueW = @Detour_RegQueryValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegGetValue(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType,*lpData,*lpcbData)
CompilerIf #DETOUR_REGGETVALUEA
	Global Original_RegGetValueA.RegGetValue
	Procedure.l Detour_RegGetValueA(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType,*lpData.Byte,*lpcbData)
		Protected Result.l
		DbgReg("RegGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" :: "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegGetValueA(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegGetValueA(hAppKey,*SubKeyA,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegGetValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegGetValueA(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegGetValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegGetValueA = @Detour_RegGetValueA()
CompilerEndIf
CompilerIf #DETOUR_REGGETVALUEW
	Global Original_RegGetValueW.RegGetValue
	Procedure.l Detour_RegGetValueW(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType,*lpData.Byte,*lpcbData)
		Protected Result.l
		DbgReg("RegGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" :: "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_RegGetValueW(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegGetValueW(hAppKey,@SubKey,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
			Else
				DbgRegAliens("RegGetValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegGetValueW(hKey,*lpSubKey,*lpValueName,rrfFlags,*lpType,*lpData.Byte,*lpcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegGetValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegGetValueW = @Detour_RegGetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHGetValue(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHGETVALUEA
	Global Original_SHGetValueA.SHGetValue
	Procedure.l Detour_SHGetValueA(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		Protected Result.l
		DbgReg("SHGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetValueA(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHGetValueA(hAppKey,*SubKeyA,*lpValueName,*pdwType,*pvData,*pcbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHGetValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHGetValueA(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHGetValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHGetValueA = @Detour_SHGetValueA()
CompilerEndIf
CompilerIf #DETOUR_SHGETVALUEW
	Global Original_SHGetValueW.SHGetValue
	Procedure.l Detour_SHGetValueW(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		Protected Result.l
		DbgReg("SHGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetValueW(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHGetValueW(hAppKey,@SubKey,*lpValueName,*pdwType,*pvData,*pcbData)
			Else
				DbgRegAliens("SHGetValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHGetValueW(hKey,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHGetValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHGetValueW = @Detour_SHGetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHRegGetValue(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHREGGETVALUEA
	Global Original_SHRegGetValueA.SHRegGetValue
	Procedure.l Detour_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		Protected Result.l
		DbgReg("SHRegGetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHRegGetValueA(hAppKey,*SubKeyA,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHRegGetValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHRegGetValueA(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHRegGetValueA = @Detour_SHRegGetValueA()
CompilerEndIf
CompilerIf #DETOUR_SHREGGETVALUEW
	Global Original_SHRegGetValueW.SHRegGetValue
	Procedure.l Detour_SHRegGetValueW(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		Protected Result.l
		DbgReg("SHRegGetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetValueW(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHRegGetValueW(hAppKey,@SubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
			Else
				DbgRegAliens("SHRegGetValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHRegGetValueW(hKey,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHRegGetValueW = @Detour_SHRegGetValueW()
CompilerEndIf
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
		DbgReg("RegSetValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueA(hKey,*lpSubKey,dwType,*lpData,cbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegSetValueA(hAppKey,*SubKeyA,dwType,*lpData,cbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegSetValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegSetValueA(hKey,*lpSubKey,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegSetValueA = @Detour_RegSetValueA()
CompilerEndIf
CompilerIf #DETOUR_REGSETVALUEW
	Global Original_RegSetValueW.RegSetValue
	Procedure.l Detour_RegSetValueW(hKey.l,*lpSubKey,dwType.l,*lpData,cbData.l)
		Protected Result.l
		DbgReg("RegSetValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetValueW(hKey,*lpSubKey,dwType,*lpData,cbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegSetValueW(hAppKey,@SubKey,dwType,*lpData,cbData)
			Else
				DbgRegAliens("RegSetValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegSetValueW(hKey,*lpSubKey,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegSetValueW = @Detour_RegSetValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetkeyvaluea
Prototype.l RegSetKeyValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETKEYVALUEA
	Global Original_RegSetKeyValueA.RegSetKeyValue
	Procedure.l Detour_RegSetKeyValueA(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
		Protected Result.l
		DbgReg("RegSetKeyValueA: "+HKey2Str(hKey)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetKeyValueA(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_RegSetKeyValueA(hAppKey,*SubKeyA,*lpValueName,dwType,*lpData,cbData)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("RegSetKeyValueA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_RegSetKeyValueA(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetKeyValueA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegSetKeyValueA = @Detour_RegSetKeyValueA()
CompilerEndIf
CompilerIf #DETOUR_REGSETKEYVALUEW
	Global Original_RegSetKeyValueW.RegSetKeyValue
	Procedure.l Detour_RegSetKeyValueW(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
		Protected Result.l
		DbgReg("RegSetKeyValueW: "+HKey2Str(hKey)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegSetKeyValueW(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_RegSetKeyValueW(hAppKey,@SubKey,*lpValueName,dwType,*lpData,cbData)
			Else
				DbgRegAliens("RegSetKeyValueW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_RegSetKeyValueW(hKey,*lpSubKey,*lpValueName,dwType,*lpData,cbData)
			EndIf
		CompilerEndIf
		DbgRegExt("RegSetKeyValueW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_RegSetKeyValueW = @Detour_RegSetKeyValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shcopykeya
Prototype.l SHCopyKey(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
CompilerIf #DETOUR_SHCOPYKEYA
	Global Original_SHCopyKeyA.SHCopyKey
	Procedure Detour_SHCopyKeyA(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		Protected Result.l
		DbgReg("SHCopyKeyA: "+HKey2Str(hKeySrc)+" "+HKey2Str(hKeyDest)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHCopyKeyA(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		CompilerElse
			Protected SubKey.s = CheckKey(hKeySrc,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHCopyKeyA(hAppKey.l,*SubKeyA,hKeyDest,fReserved.l)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHCopyKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHCopyKeyA(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
			EndIf
		CompilerEndIf
		DbgRegExt("SHCopyKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_SHCOPYKEYW
	Global Original_SHCopyKeyW.SHCopyKey
	Procedure Detour_SHCopyKeyW(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		Protected Result.l
		DbgReg("SHCopyKeyW: "+HKey2Str(hKeySrc)+" "+HKey2Str(hKeyDest)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHCopyKeyW(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		CompilerElse
			Protected SubKey.s = CheckKey(hKeySrc,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHCopyKeyW(hAppKey.l,@SubKey,hKeyDest,fReserved.l)
			Else
				DbgRegAliens("SHCopyKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHCopyKeyW(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
			EndIf
		CompilerEndIf
		DbgRegExt("SHCopyKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shqueryinfokeya
Prototype.l SHQueryInfoKey(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
CompilerIf #DETOUR_SHQUERYINFOKEYA
	Global Original_SHQueryInfoKeyA.SHQueryInfoKey
	Procedure Detour_SHQueryInfoKeyA(hKey.l,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		Protected Result.l
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

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 974
; FirstLine = 967
; Folding = --------
; EnableThread
; DisableDebugger
; EnableExeConstant