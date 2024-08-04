;;======================================================================================================================
; Аналоги некоторых функций Registry1 для работы с кустом реестра
;;======================================================================================================================

Global ConfigFile.s
Global PermanentFile.s ; depricated
Global InitialFile.s
Global hAppKey.l

CompilerIf Not Defined(CONFIG_FILEEXT,#PB_Constant) : #CONFIG_FILEEXT = ".pphiv" : CompilerEndIf
CompilerIf Not Defined(CONFIG_ADDITIONALEXT,#PB_Constant) : #CONFIG_INITIALEXT = ".pport" : CompilerEndIf
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
CompilerIf Defined(CONFIG_INITIAL,#PB_Constant)
	CompilerIf #CONFIG_INITIAL<>""
		InitialFile = PrgDir+#CONFIG_INITIAL
		If GetExtensionPart(InitialFile)=""
			InitialFile + #CONFIG_INITIALEXT
		EndIf
	CompilerElse
		InitialFile = PrgDir+PrgName+"-Init"+#CONFIG_INITIALEXT
	CompilerEndIf
CompilerEndIf
;;======================================================================================================================
; Экспорт параметров из файла pport

#CONFIG_SEPARATOR = $E800 ; Из набора символов для частного использования
#CFG_CHR_NUL = $E000 ; 57344 - Из набора символов для частного использования
#CFG_CHR_SPACE = #CFG_CHR_NUL+$20

Procedure FindCtrl(s.s,start=1)
	Protected i, c.c, l=Len(s)
	Protected istart = @s+start*2-2
	Protected iend = @s+l*2-2
	For i=istart To iend
		c = PeekC(i)
		If c=#CONFIG_SEPARATOR Or (c<32 And c>13) Or c=#TAB
			ProcedureReturn (i-@s)/2+1
		EndIf
	Next
	ProcedureReturn 0
EndProcedure

Procedure ImportCfg(Config.s)
	Protected s.s, hKey, sKey.s, sData.s, bData.s, dData.q, pData, cbData, sType.s, bType, sName.s
	Protected x1, x2, x3, i
	Protected *pb.Byte, *pc.Character, *end
	Protected CodePage
	Protected hCfg = ReadFile(#PB_Any,Config,#PB_File_SharedRead|#PB_File_SharedWrite)
	If hCfg
		CodePage = ReadStringFormat(hCfg)
		While Not Eof(hCfg)
			s = ReadString(hCfg,CodePage)
			x1 = FindCtrl(s)
			If x1
				x2 = FindCtrl(s,x1+1)
				x3 = FindCtrl(s,x2+1)
				If x2 And x3
					sKey = LCase(Left(s,x1-1))
					sName = LCase(Mid(s,x1+1,x2-x1-1))
					sType = Mid(s,x2+1,x3-x2-1)
					sData = Mid(s,x3+1)
					If RegCreateKey_(hAppKey,@sKey,@hKey) = #NO_ERROR
						Select sType
							Case "s"
								bType = #REG_SZ
							Case "m"
								bType = #REG_MULTI_SZ
							Case "x"
								bType = #REG_EXPAND_SZ
							Case "b"
								bType = #REG_BINARY
							Case "d"
								bType = #REG_DWORD
							Default
								bType = Val("$"+sType)
						EndSelect
						Select sType
							Case "s","m","x"
								cbData = StringByteLength(sData)+2
							Case "d"
								cbData = SizeOf(Long)
							Default
								cbData = Len(sData)/2 ; два символа кодируют один байт
						EndSelect
						; Тип проверяем в строковом виде, так как могут встретиться стандартные типы нестандартной длины.
						; Такие данные сохраняются с типом в HEX виде.
						If sType="s" Or sType="m" Or sType="x"
							pData = @sData
							*pc = pData
							*end = *pc + cbData
							While *pc < *end ; декодирование управляющих символов 0-31
								If *pc\c>=#CFG_CHR_NUL And *pc\c<#CFG_CHR_SPACE
									*pc\c - #CFG_CHR_NUL
								EndIf
								*pc + 2
							Wend
						ElseIf sType="d" ;And cbData=4
							dData = Val("$"+sData)
							pData = @dData
						Else ; данные закодированны в бинарном виде, в том числе и для нестандартной длины REG_DWORD
							;cbData = Len(sData)/2 ; два символа кодируют один байт
							If bType=#REG_BINARY
								bData = SpaceB(cbData)
								pData = @bData
							Else ; bType=#REG_DWORD
								dData = 0
								pData = @dData
							EndIf
							*pc = @sData
							*pb = pData
							*end = *pb+cbData
							While *pb < *end
								*pb\b = Val("$"+PeekS(*pc,2))
								*pb + 1
								*pc + 4 ; hex представление байта - два символа в юникоде
							Wend
						EndIf
						RegSetValueEx_(hKey,@sName,0,bType,pData,cbData)
						RegCloseKey_(hKey)
					EndIf
				EndIf
			Else ; ключ без значения
				If RegCreateKey_(hAppKey,@sKey,@hKey) = #NO_ERROR
					RegCloseKey_(hKey)
				EndIf
			EndIf
		Wend
		CloseFile(hCfg)
	EndIf
EndProcedure
;;======================================================================================================================
; https://docs.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regloadappkeya
; https://docs.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regloadkeya
; https://learn.microsoft.com/ru-ru/windows/win32/sysinfo/registry-key-security-and-access-rights
CompilerSelect #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
	CompilerCase 2
		DeclareImport(advapi32,_RegLoadAppKeyW@20,RegLoadAppKeyW,RegLoadAppKey_(lpFile,phkResult,samDesired,dwOptions,Reserved))
		Procedure ReadCfg()
			Protected err.l = RegLoadAppKey_(@ConfigFile,@hAppKey,#KEY_ALL_ACCESS,0,0)
			DbgReg("REGLOADAPPKEY: "+Str(err)+" "+ConfigFile)
			WriteLog("REGLOADAPPKEY: "+Str(err)+" "+ConfigFile)
			If err<>#ERROR_SUCCESS
				DbgReg("REGLOADAPPKEY: "+GetLastErrorStr(err))
				WriteLog("REGLOADAPPKEY: "+GetLastErrorStr(err))
				PPErrorMessage("RegLoadAppKey"+#CR$+"Error load hive ",err)
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			EndIf
			If FileExist(InitialFile)
				ImportCfg(InitialFile)
			EndIf
		EndProcedure
	CompilerCase 3
		Global AppRootKey.s = "PurePortable"
		Procedure ReadCfg()
			Protected err.l = RegLoadKey_(#HKEY_USERS,@ConfigFile,@AppRootKey)
			DbgReg("REGLOADKEY: "+Str(err)+" "+ConfigFile)
			If err<>#ERROR_SUCCESS
				DbgReg("REGLOADKEY: "+GetLastErrorStr(err))
				PPErrorMessage("RegLoadKey"+#CR$+"Error load hive ",err)
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			EndIf
			If FileExist(InitialFile)
				ImportCfg(InitialFile)
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
		Protected Path.s = CorrectPath(GetCfgS(Key,Value),Base,Flags)
		If Flags & #CORRECTPATH_REAL_PATH
			If Path
				SetCfgS(Key,Value,Path)
			EndIf
		Else
			SetCfgS(Key,Value,Path)
		EndIf
	EndProcedure
CompilerEndIf 
;;======================================================================================================================
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 70
; FirstLine = 99
; Folding = PE9
; EnableThread
; DisableDebugger
; EnableExeConstant