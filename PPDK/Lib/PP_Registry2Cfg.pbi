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
; Прцедуры для работы с данными из куста реестра.
;;======================================================================================================================
;https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-reggetvaluea
;https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regsetkeyvaluea
;https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletekeyvaluea
;https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-regdeletetreea
#RRF_RT_REG_BINARY=$00000008
#RRF_RT_REG_DWORD=$00000010
#RRF_RT_DWORD=$00000018 ; #RRF_RT_REG_BINARY|#RRF_RT_REG_DWORD
#RRF_RT_REG_SZ=$00000002
#RRF_RT_ANY=$0000FFFF
DeclareImport(kernel32,_RegGetValueW@28,RegGetValueW,RegGetValue_(hKey,*SubKey,*ValueName,dwFlags.l,*dwType,*Data,*cbData))
DeclareImport(kernel32,_RegSetKeyValueW@24,RegSetKeyValueW,RegSetKeyValue_(hKey,*SubKey,*ValueName,dwType.l,*Data,*cbData))
DeclareImport(kernel32,_RegDeleteKeyValueW@12,RegDeleteKeyValueW,RegDeleteKeyValue_(hKey,*SubKey,*ValueName))
DeclareImport(kernel32,_RegDeleteTreeW@8,RegDeleteTreeW,RegDeleteTree_(hKey,*SubKey))

Procedure.s GetCfgS(sKey.s,sName.s)
	Protected dwType, cbData, Result.s
	Protected ret
	If Original_RegGetValueW ; если хук установлен, через оригинальную функцию
		ret = Original_RegGetValueW(hAppKey,@sKey,@sName,#RRF_RT_REG_SZ,@dwType,#Null,@cbData)
	Else ; иначе напрямую
		ret = RegGetValue_(hAppKey,@sKey,@sName,#RRF_RT_REG_SZ,@dwType,#Null,@cbData)
	EndIf
	If cbData And (dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ)
		Result = Space((cbData+1)/2)
		If Original_RegGetValueW ; если хук установлен, через оригинальную функцию
			If Original_RegGetValueW(hAppKey,@sKey,@sName,#RRF_RT_REG_SZ,@dwType,@Result,@cbData)=#NO_ERROR
				ProcedureReturn Result
			EndIf
		Else ; иначе напрямую
			If RegGetValue_(hAppKey,@sKey,@sName,#RRF_RT_REG_SZ,@dwType,@Result,@cbData)=#NO_ERROR
				ProcedureReturn Result
			EndIf
		EndIf
	EndIf
	;ProcedureReturn ""
EndProcedure
Procedure.l GetCfgD(sKey.s,sName.s,DefVal.l=0)
	Protected dwType, dwData.l, cbData=SizeOf(Long)
	Protected ret
	If Original_RegGetValueW ; если хук установлен, через оригинальную функцию
		If Original_RegGetValueW(hAppKey,@sKey,@sName,#RRF_RT_DWORD,@dwType,@dwData,@cbData)=#NO_ERROR
			ProcedureReturn dwData
		EndIf
	Else ; иначе напрямую
		If RegGetValue_(hAppKey,@sKey,@sName,#RRF_RT_DWORD,@dwType,@dwData,@cbData)=#NO_ERROR
			ProcedureReturn dwData
		EndIf
	EndIf
	ProcedureReturn DefVal
EndProcedure
Procedure CfgExist(sKey.s,sName.s)
	If Original_RegGetValueW
		ProcedureReturn Bool(Original_RegGetValueW(hAppKey,@sKey,@sName,#RRF_RT_ANY,#Null,#Null,#Null)=#NO_ERROR)
	EndIf
	ProcedureReturn Bool(RegGetValue_(hAppKey,@sKey,@sName,#RRF_RT_ANY,#Null,#Null,#Null)=#NO_ERROR)
EndProcedure
Procedure SetCfgS(sKey.s,sName.s,sData.s)
	If Original_RegSetKeyValueW
		ProcedureReturn Bool(Original_RegSetKeyValueW(hAppKey,@sKey,@sName,#REG_SZ,@sData,StringByteLength(sData)+2)=#NO_ERROR)
	EndIf
	ProcedureReturn Bool(RegSetKeyValue_(hAppKey,@sKey,@sName,#REG_SZ,@sData,StringByteLength(sData)+2)=#NO_ERROR)
EndProcedure
Procedure SetCfgD(sKey.s,sName.s,dData.l)
	If Original_RegSetKeyValueW
		ProcedureReturn Bool(Original_RegSetKeyValueW(hAppKey,@sKey,@sName,#REG_DWORD,@dData,SizeOf(Long))=#NO_ERROR)
	EndIf
	ProcedureReturn Bool(RegSetKeyValue_(hAppKey,@sKey,@sName,#REG_DWORD,@dData,SizeOf(Long))=#NO_ERROR)
EndProcedure
Procedure SetCfgB(sKey.s,sName.s,sHex.s)
	sHex = ReplaceString(ReplaceString(sHex,",","")," ","")+"0" ; плюс "0" для нейтрализации ошибки если было нечётное количество символов
	Protected Result, cbData
	Protected *Bin = Hex2Bin(sHex,#Null,@cbData)
	If Original_RegSetKeyValueW
		Result = Bool(Original_RegSetKeyValueW(hAppKey,@sKey,@sName,#REG_BINARY,*Bin,cbData)=#NO_ERROR)
	Else
		Result = Bool(RegSetKeyValue_(hAppKey,@sKey,@sName,#REG_BINARY,*Bin,cbData)=#NO_ERROR)
	EndIf
	FreeMemory(*Bin)
	ProcedureReturn Result
EndProcedure
Procedure DelCfg(sKey.s,sName.s)
	If Original_RegDeleteKeyValueW
		ProcedureReturn Bool(Original_RegDeleteKeyValueW(hAppKey,@sKey,@sName)=#NO_ERROR)
	EndIf
	ProcedureReturn Bool(RegDeleteKeyValue_(hAppKey,@sKey,@sName)=#NO_ERROR)
EndProcedure
Procedure DelTree(sKey.s)
	If Original_RegDeleteTreeW
		ProcedureReturn Bool(Original_RegDeleteTreeW(hAppKey,@sKey)=#NO_ERROR)
	EndIf
	ProcedureReturn Bool(RegDeleteTree_(hAppKey,@sKey)=#NO_ERROR)
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
; Экспорт из файла конфигурации.
;;======================================================================================================================

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
	Protected s.s, hKey, sKey.s, sData.s, bData.s, dData.q, sType.s, dwType.l, sName.s
	Protected cbData.i ; Должен быть i для правильной работы Hex2Bin
	Protected x1, x2, x3, i
	Protected *ptr
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
								dwType = #REG_SZ
							Case "m"
								dwType = #REG_MULTI_SZ
							Case "x"
								dwType = #REG_EXPAND_SZ
							Case "b"
								dwType = #REG_BINARY
							Case "d"
								dwType = #REG_DWORD
							Default
								dwType = Val("$"+sType)
						EndSelect
						Select sType
							Case "s","m","x"
								cbData = StringByteLength(sData)+2
							Case "d"
								cbData = SizeOf(Long)
							Default ; всё остальное хранится в виде hex-строки
								cbData = Len(sData)/2 ; два символа кодируют один байт
						EndSelect
						; Тип проверяем в строковом виде, так как могут встретиться стандартные типы нестандартной длины.
						; Такие данные сохраняются с типом в hex виде и сами данные в виде hex-строки.
						If sType="s" Or sType="m" Or sType="x"
							DecodeCtrl(@sData)
							RegSetValueEx_(hKey,@sName,0,dwType,@sData,cbData)
						ElseIf sType="d" ;And cbData=4
							dData = Val("$"+sData)
							RegSetValueEx_(hKey,@sName,0,dwType,@dData,cbData)
						Else ; данные закодированны в бинарном виде, в том числе и для REG_DWORD нестандартной длины
							*ptr = Hex2Bin(sData,#Null,@cbData)
							RegSetValueEx_(hKey,@sName,0,dwType,*ptr,cbData)
							FreeMemory(*ptr)
						EndIf
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
; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 122
; FirstLine = 98
; Folding = -D9
; EnableThread
; DisableDebugger
; EnableExeConstant