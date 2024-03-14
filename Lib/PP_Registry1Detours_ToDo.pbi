;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregcloseuskey
Prototype.l SHRegCloseUSKey(hUSKey.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregcreateuskeya
Prototype.l SHRegCreateUSKey(*pszPath,samDesired,hRelativeUSKey.l,*phNewUSKey.Long,dwFlags.l)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-shregopenuskeya
Prototype.l SHRegOpenUSKey(*pszPath,samDesired,hRelativeUSKey.l,*phNewUSKey.Long,fIgnoreHKCU)

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/ns-winreg-valenta
CompilerIf #DETOUR_REGQUERYMULTIPLEVALUESA Or #DETOUR_REGQUERYMULTIPLEVALUESW
	Structure VALENT_T
		*ve_valuename ; Имя извлекаемого значения.
		ve_valuelen.l ; Размер данных, на которые указывает ve_valueptr, в байтах.
		*ve_valueptr.LONG ; Указатель на данные для записи значения. Это указатель на данные значения, возвращаемые в буфере lpValueBuf 
		ve_type.l ; Тип данных, на которые указывает ve_valueptr.
	EndStructure
CompilerEndIf
; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regquerymultiplevaluesa
Prototype RegQueryMultipleValues(hKey.l,*val_list,num_vals.l,*lpValueBuf,*ldwTotsize.LONG)
CompilerIf #DETOUR_REGQUERYMULTIPLEVALUESA
	Procedure Detour_RegQueryMultipleValuesA(hKey.l,*val_list,num_vals.l,*lpValueBuf,*ldwTotsize.LONG)
		Protected Result.l
		RegCriticalEnter
		DbgReg("RegQueryMultipleValuesA: "+HKey2Str(hKey))
		CompilerIf Not #PORTABLE
			Result = Original_RegQueryMultipleValuesA(hKey,*val_list,num_vals.l,*lpValueBuf,*ldwTotsize)
		CompilerElse
			Protected ValueType.l, vKey.l
			If OpenKey(hKey,"",@vKey,@Result)
				;Result = GetDataA(vKey,"",@ValueType,*lpData,*lpcbData)
			Else
				Result = Original_RegQueryMultipleValuesA(hKey,*val_list,num_vals.l,*lpValueBuf,*ldwTotsize)
			EndIf
		CompilerEndIf
		
		DbgRegExt("RegQueryMultipleValuesA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_REGQUERYMULTIPLEVALUESW
	
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-shreggetboolusvalueaa
Prototype.l SHRegGetBoolUSValue(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
CompilerIf #DETOUR_SHREGGETBOOLUSVALUEA
	Global Original_SHRegGetBoolUSValueA.SHRegGetBoolUSValue
	Procedure.l Detour_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHRegGetBoolUSValueA: "+LPeekSZA(*lpSubKey)+" "+LPeekSZA(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		CompilerElse
			Protected sKey.s = CheckKey(0,LPeekSZA(*lpSubKey))
			If sKey
				Result = GetCfgD(sKey,LPeekSZA(*lpValueName),fDefault)
			Else
				Result = Original_SHRegGetBoolUSValueA(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetBoolUSValueA: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHRegGetBoolUSValueA = @Detour_SHRegGetBoolUSValueA()
CompilerEndIf
CompilerIf #DETOUR_SHREGGETBOOLUSVALUEW
	Global Original_SHRegGetBoolUSValueW.SHRegGetBoolUSValue
	Procedure.l Detour_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		Protected Result.l
		RegCriticalEnter
		DbgReg("SHRegGetBoolUSValueW: "+LPeekSZU(*lpSubKey)+" "+LPeekSZU(*lpValueName))
		CompilerIf Not #PORTABLE
			Result = Original_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
		CompilerElse
			Protected sKey.s = CheckKey(0,LPeekSZU(*lpSubKey))
			If sKey
				Result = GetCfgD(sKey,LPeekSZU(*lpValueName),fDefault)
			Else
				Result = Original_SHRegGetBoolUSValueW(*lpSubKey,*lpValueName,fIgnoreHKCU,fDefault)
			EndIf
		CompilerEndIf
		DbgRegExt("SHRegGetBoolUSValueW: "+Result2Str(Result))
		RegCriticalLeave
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_SHRegGetBoolUSValueW = @Detour_SHRegGetBoolUSValueW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 89
; FirstLine = 56
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant