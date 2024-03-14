;;======================================================================================================================

Global ConfigFile.s
Global PermanentFile.s ; Для совместимости с Registry1
Global hAppKey.l

CompilerIf Not Defined(CONFIG_FILEEXT,#PB_Constant) : #CONFIG_FILEEXT = ".pphiv" : CompilerEndIf
CompilerIf Defined(CONFIG_FILENAME,#PB_Constant)
	CompilerIf #CONFIG_FILENAME<>""
		ConfigFile = PrgDir+#CONFIG_FILENAME
		If GetExtensionPart(ConfigFile)=""
			ConfigFile + #CONFIG_FILEEXT
		EndIf
	CompilerElse
		ConfigFile = PrgDir+PrgName+#CONFIG_FILEEXT
	CompilerEndIf
CompilerEndIf

;;======================================================================================================================
; https://docs.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regloadappkeya
; https://docs.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regloadkeya
; https://learn.microsoft.com/ru-ru/windows/win32/sysinfo/registry-key-security-and-access-rights
CompilerSelect #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
	CompilerCase 2
		DeclareImport(advapi32,_RegLoadAppKeyW@20,RegLoadAppKeyW,RegLoadAppKey_(lpFile,phkResult,samDesired,dwOptions,Reserved))
		;Global AppRootKey.s = "PurePortable"
		Procedure ReadCfg()
			Protected err = RegLoadAppKey_(@ConfigFile,@hAppKey,#KEY_ALL_ACCESS,0,0)
			DbgReg("REGLOADAPPKEY: "+Str(err)+" «"+ConfigFile+"»")
			If err<>#ERROR_SUCCESS
				MessageBox_(0,"Error load hive "+#CR$+GetLastErrorStr(),"PurePortable",#MB_ICONERROR)
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			EndIf
		EndProcedure
	CompilerCase 3
		Global AppRootKey.s = "PurePortable"
		Procedure ReadCfg()
			Protected err = RegLoadKey_(#HKEY_USERS,@ConfigFile,@AppRootKey)
			DbgReg("REGLOADKEY: "+Str(err)+" «"+ConfigFile+"»")
			If err<>#ERROR_SUCCESS
				MessageBox_(0,"Error load hive "+#CR$+GetLastErrorStr(),"PurePortable",#MB_ICONERROR)
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			EndIf
		EndProcedure
CompilerEndSelect
;;----------------------------------------------------------------------------------------------------------------------
Procedure WriteCfg()
	; Ничего не делаем
EndProcedure
;;======================================================================================================================
Procedure.s GetCfgS(sKey.s,sName.s)
	Protected dwType, cbData, Result.s
	Protected ret = SHGetValue_(hAppKey,@sKey,@sName,@dwType,#Null,@cbData)
	If cbData And (dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ)
		Result = Space((cbData+1)/2)
		If SHGetValue_(hAppKey,@sKey,@sName,@dwType,@Result,@cbData)=#NO_ERROR
			ProcedureReturn Result
		EndIf
	EndIf
	;ProcedureReturn ""
EndProcedure
Procedure.l GetCfgD(sKey.s,sName.s,Result.l=0)
	Protected dwType, cbData
	Protected ret = SHGetValue_(hAppKey,@sKey,@sName,@dwType,#Null,@cbData)
	If cbData And dwType=#REG_DWORD
		If SHGetValue_(hAppKey,@sKey,@sName,@dwType,@Result,@cbData)=#NO_ERROR
			ProcedureReturn Result
		EndIf
	EndIf
	;ProcedureReturn 0
EndProcedure
Procedure CfgExist(sKey.s,sName.s)
	ProcedureReturn Bool(SHGetValue_(hAppKey,@sKey,@sName,#Null,#Null,#Null)=#NO_ERROR)
EndProcedure
Procedure SetCfgS(sKey.s,sName.s,sData.s)
	ProcedureReturn Bool(SHSetValue_(hAppKey,@sKey,@sName,#REG_SZ,@sData,StringByteLength(sData)+2)=#NO_ERROR)
EndProcedure
Procedure SetCfgD(sKey.s,sName.s,dData.l)
	ProcedureReturn Bool(SHSetValue_(hAppKey,@sKey,@sName,#REG_SZ,@dData,SizeOf(Long))=#NO_ERROR)
EndProcedure
Procedure SetCfgB(sKey.s,sName.s,dData.l,cbData=1)
	ProcedureReturn Bool(SHSetValue_(hAppKey,@sKey,@sName,#REG_SZ,@dData,cbData)=#NO_ERROR)
EndProcedure
Procedure DelCfg(sKey.s,sName.s)
	ProcedureReturn Bool(SHDeleteValue_(hAppKey,@sKey,@sName)=#NO_ERROR)
EndProcedure
Procedure DelTree(sKey.s)
	ProcedureReturn Bool(SHDeleteKey_(hAppKey,@sKey)=#NO_ERROR)
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(PROC_CORRECTCFGPATH,#PB_Constant) : #PROC_CORRECTCFGPATH = 0 : CompilerEndIf
CompilerIf #PROC_CORRECTCFGPATH
	Procedure CorrectCfgPath(Key.s,Value.s,Base.s,Flags=0)
		SetCfgS(Key,Value,CorrectPath(GetCfgS(Key,Value),Base,Flags))
	EndProcedure
CompilerEndIf 
;;======================================================================================================================
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 3
; Folding = ---
; EnableThread
; DisableDebugger
; EnableExeConstant