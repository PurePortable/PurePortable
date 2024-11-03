;;======================================================================================================================
Global hAppKey.l
;;======================================================================================================================
Prototype.l RegCreateKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGCREATEKEY
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyEx(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition.Long)
CompilerIf #DETOUR_REGCREATEKEYEX
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegCreateKeyTransacted(hKey.l,*lpSubKey,Reserved.l,*lpClass,dwOptions.l,samDesired.l,*lpSecurityAttributes.SECURITY_ATTRIBUTES,*phkResult.Long,*lpdwDisposition,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGCREATEKEYTRANSACTED
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKey(hKey.l,*lpSubKey,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEY
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKeyEx(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long)
CompilerIf #DETOUR_REGOPENKEYEX
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegOpenKeyTransacted(hKey.l,*lpSubKey,ulOptions.l,samDesired.l,*phkResult.Long,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGOPENKEYTRANSACTED
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETEKEY
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyEx(hKey.l,*lpSubKey,samDesired.l,Reserved.l)
CompilerIf #DETOUR_REGDELETEKEYEX
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyTransacted(hKey.l,*lpSubKey,samDesired.l,Reserved.l,hTransaction,*pExtendedParameter)
CompilerIf #DETOUR_REGDELETEKEYTRANSACTED
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteTree(hKey.l,*lpSubKey)
CompilerIf #DETOUR_REGDELETETREE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHDeleteKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEKEY
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHDeleteEmptyKey(hKey.l,*lpSubKey)
CompilerIf #DETOUR_SHDELETEEMPTYKEY
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegDeleteKeyValue(hkey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_REGDELETEKEYVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shdeletevaluea
Prototype.l SHDeleteValue(hKey.l,*lpSubKey,*lpValueName)
CompilerIf #DETOUR_SHDELETEVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegQueryValue(hKey.l,*lpSubKey,*lpData,*lpcbData)
CompilerIf #DETOUR_REGQUERYVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l RegGetValue(hKey.l,*lpSubKey,*lpValueName,rrfFlags.l,*lpType,*lpData,*lpcbData)
CompilerIf #DETOUR_REGGETVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHGetValue(hKey.l,*lpSubKey,*lpValueName,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHGETVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHRegGetValue(hKey.l,*lpSubKey,*lpValueName,srrfFlags,*pdwType,*pvData,*pcbData)
CompilerIf #DETOUR_SHREGGETVALUE
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
				Protected Size = SizeOf(Long)
				If Original_SHRegGetValueA(hAppKey,*lpSubKey,*lpValueName,0,#REG_DWORD,@Result,@Size) <> #NO_ERROR
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
				Protected Size = SizeOf(Long)
				If Original_SHRegGetValueW(hAppKey,*lpSubKey,*lpValueName,0,#REG_DWORD,@Result,@Size) <> #NO_ERROR
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
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shreggetpatha
;Prototype.l SHRegGetPath(hKey.l,*lpSubKey,*lpValueName,*pszPath,dwFlags.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetvaluea
Prototype.l RegSetValue(hKey.l,*lpSubKey,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetkeyvaluea
Prototype.l RegSetKeyValue(hKey.l,*lpSubKey,*lpValueName,dwType.l,*lpData,cbData.l)
CompilerIf #DETOUR_REGSETKEYVALUE
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
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shcopykeya
Prototype.l SHCopyKey(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
CompilerIf #DETOUR_SHCOPYKEY
	Global Original_SHCopyKeyA.SHCopyKey
	Procedure Detour_SHCopyKeyA(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		Protected Result.l
		DbgReg("SHCopyKeyA: "+HKey2Str(hKeySrc)+" "+HKey2Str(hKeyDest)+" "+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHCopyKeyA(hKeySrc,*lpSubKey,hKeyDest,fReserved)
		CompilerElse
			Protected SubKey.s = CheckKey(hKeySrc,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHCopyKeyA(hAppKey,*SubKeyA,hKeyDest,fReserved)
				FreeMemory(*SubKeyA)
			Else
				DbgRegAliens("SHCopyKeyA (ALIEN): "+LPeekSZA(*lpSubKey))
				Result = Original_SHCopyKeyA(hKeySrc,*lpSubKey,hKeyDest,fReserved)
			EndIf
		CompilerEndIf
		DbgRegExt("SHCopyKeyA: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
	Global Original_SHCopyKeyW.SHCopyKey
	Procedure Detour_SHCopyKeyW(hKeySrc.l,*lpSubKey,hKeyDest,fReserved.l)
		Protected Result.l
		DbgReg("SHCopyKeyW: "+HKey2Str(hKeySrc)+" "+HKey2Str(hKeyDest)+" "+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHCopyKeyW(hKeySrc,*lpSubKey,hKeyDest,fReserved)
		CompilerElse
			Protected SubKey.s = CheckKey(hKeySrc,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHCopyKeyW(hAppKey,@SubKey,hKeyDest,fReserved)
			Else
				DbgRegAliens("SHCopyKeyW (ALIEN): "+LPeekSZU(*lpSubKey))
				Result = Original_SHCopyKeyW(hKeySrc,*lpSubKey,hKeyDest,fReserved)
			EndIf
		CompilerEndIf
		DbgRegExt("SHCopyKeyW: "+Result2Str(Result))
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
		DbgReg("SHQueryInfoKeyA: "+HKey2Str(hKey)+LPeekSZA(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHQueryInfoKeyA(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZA(*lpSubKey))
			If SubKey
				Protected *SubKeyA = Ascii(SubKey)
				Result = Original_SHQueryInfoKeyA(hAppKey,*SubKeyA,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
				FreeMemory(*SubKeyA)
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
		DbgReg("SHQueryInfoKeyW: "+HKey2Str(hKey)+LPeekSZU(*lpSubKey))
		CompilerIf Not #PORTABLE
			Result = Original_SHQueryInfoKeyW(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
		CompilerElse
			Protected SubKey.s = CheckKey(hKey,LPeekSZU(*lpSubKey))
			If SubKey
				Result = Original_SHQueryInfoKeyW(hAppKey,@SubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
			Else
				Result = Original_SHQueryInfoKeyW(hKey,*lpSubKey,*lpcMaxSubKeyLen,*lpcValues,*lpcMaxValueNameLen)
			EndIf

		CompilerEndIf
		DbgRegExt("SHQueryInfoKeyW: "+Result2Str(Result))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 784
; FirstLine = 162
; Folding = AAAAAgDw
; EnableThread
; DisableDebugger
; EnableExeConstant