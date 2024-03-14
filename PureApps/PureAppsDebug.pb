;;======================================================================================================================
; Вспомогательная dll для вывода отладочных сообщений через 
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.10.0.0
;RES_DESCRIPTION Proxy dll
;RES_COPYRIGHT (c) Smitis, 2017-2024
;RES_INTERNALNAME 400.dll
;RES_PRODUCTNAME Pure Portable
;RES_PRODUCTVERSION 4.10.0.0
;RES_COMMENT PAM Project
;PP_X32_COPYAS "PureAppsDebug32.dll"
;PP_X64_COPYAS "PureAppsDebug64.dll"
;PP_CLEAN 0

Procedure dbg(txt.s="") : OutputDebugString_(DbgProcessId+txt) : EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------------------------------------
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

;;----------------------------------------------------------------------------------------------------------------------
Procedure.s csidl2s(csidl)
	Protected Result.s
	Select csidl & #CSIDL_ID_MASK
		Case #CSIDL_PROFILE
			Result = "CSIDL_PROFILE"
		Case #CSIDL_APPDATA
			Result = "CSIDL_APPDATA"
		Case #CSIDL_LOCAL_APPDATA
			Result = "CSIDL_LOCAL_APPDATA"
		Case #CSIDL_PERSONAL
			Result = "CSIDL_PERSONAL"
		Case #CSIDL_MYDOCUMENTS
			Result = "CSIDL_MYDOCUMENTS"
		Case #CSIDL_COMMON_APPDATA
			Result = "CSIDL_COMMON_APPDATA"
		Case #CSIDL_COMMON_DOCUMENTS
			Result = "CSIDL_COMMON_DOCUMENTS"
		Default
			Result = "CSIDL_0x"+HexL(csidl)
	EndSelect
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Procedure dbgrfid(func.s,rfid,path.s="")
	If path : path = ": «"+path+"»" : EndIf
	If CompareMemory(rfid,?FOLDERID_Profile,16)
		dbgsf(func+": "+guid2s(rfid)+" (Profile)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_RoamingAppData,16)
		dbgsf(func+": "+guid2s(rfid)+" (AppData)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_LocalAppData,16)
		dbgsf(func+": "+guid2s(rfid)+" (LocalAppData)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_LocalLowAppData,16)
		dbgsf(func+": "+guid2s(rfid)+" (LocalLowAppData)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_Documents,16)
		dbgsf(func+": "+guid2s(rfid)+" (Documents)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_ProgramData,16)
		dbgsf(func+": "+guid2s(rfid)+" (CommonAppData)"+path)
	ElseIf CompareMemory(rfid,?FOLDERID_PublicDocuments,16)
		dbgsf(func+": "+guid2s(rfid)+" (CommonDocuments)"+path)
	Else
		dbgsf(func+": "+guid2s(rfid)+path)
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
ProcedureDLL PP_DebugReg()
	
EndProcedure

;;======================================================================================================================


; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 130
; FirstLine = 95
; Folding = --
; EnableThread
; DisableDebugger
; EnableExeConstant