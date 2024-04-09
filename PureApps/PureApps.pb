;;======================================================================================================================
; Portable WINAPI wrapper for PureApps
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.10.0.11
;RES_DESCRIPTION Proxy dll
;RES_COPYRIGHT (c) Smitis, 2017-2024
;RES_INTERNALNAME 400.dll
;RES_PRODUCTNAME Pure Portable
;RES_PRODUCTVERSION 4.10.0.0
;RES_COMMENT PAM Project
;PP_X32_COPYAS "Temp\PurePort32.dll"
;PP_X64_COPYAS "Temp\PurePort64.dll"
;PP_CLEAN 2

EnableExplicit
IncludePath "..\Lib"
XIncludeFile "PurePortableCustom.pbi"

#PROXY_DLL = "pureport"
#PROXY_DLL_COMPATIBILITY = 0 ; Совместимость: 0 - по умолчанию, 5 - XP, 7 - Windows 7 (default), 10 - Windows 10

;#CONFIG_FILENAME = "PurePortable"
;#CONFIG_PERMANENT = #CONFIG_FILENAME+"-Init"
;#CONFIG_INITIAL = #CONFIG_FILENAME+"-Init"
;#PREFERENCES_FILENAME = #CONFIG_FILENAME ; Имя файла конфигурации PurePortable

;;----------------------------------------------------------------------------------------------------------------------
#PORTABLE = 1 ; Управление портабелизацией: 0 - прозрачный режим, 1 - перехват
#PORTABLE_REGISTRY = 1 ; Перехват функций для работы с реестром
;{ Управление хуками PORTABLE_REGISTRY
#DETOUR_REG_SHLWAPI = 1 ; Перехват функций для работы с реестром из shlwapi
#DETOUR_REG_TRANSACTED = 1
;}
#PORTABLE_SPECIAL_FOLDERS = 1 ; Перехват функций для работы со специальными папками
;{ Управление хуками PORTABLE_SPECIAL_FOLDERS
#DETOUR_SHFOLDER = 0 ; Перехват функций из shfolder.dll
#DETOUR_USERENV = 1	; Перехват функций из userenv.dll
;}
#PORTABLE_ENVIRONMENT_VARIABLES = 1
;{ Управление хуками PORTABLE_ENVIRONMENT_VARIABLES
#DETOUR_ENVIRONMENTVARIABLE = 1
#DETOUR_ENVIRONMENTSTRINGS = 1
#DETOUR_EXPANDENVIRONMENTSTRINGS = 1
#DETOUR_ENVIRONMENT_CRT = "" ; msvcrt
;}
#PORTABLE_PROFILE_STRINGS = 0
#PROFILE_STRINGS_FILENAME = "PurePortable"
#PORTABLE_CBT_HOOK = 0 ; Хук на отслеживание закрытие окон и сохранение конфигурации
#PORTABLE_ENTRYPOINT = 0
;{ Обработка ошибок
;#PROXY_ERROR_MODE = 0
#MIN_HOOK_ERROR_MODE = 2
;}
;;----------------------------------------------------------------------------------------------------------------------
;{ Диагностика
#DBG_REGISTRY = #DBG_REG_MODE_MAX
#DBG_SPECIAL_FOLDERS = #DBG_SF_MODE_MAX
#DBG_ENVIRONMENT_VARIABLES = 1
#DBG_PROFILE_STRINGS = 0
#DBG_CBT_HOOK = 0
#DBG_MIN_HOOK = 0
#DBG_IAT_HOOK = 0
#DBG_PROXY_DLL = 0
#DBG_ANY = 0
;}
;{ Более подробная трассировка
#LOGGING = 0 ; Сохранять в log-файл
#LOGGING_CFG = 1 ; Писать логи обращения к данным конфигурации (виртуального реестра) - LoggingCfg
#LOGGING_REG = 1 ; Писать логи обращения к реальному реестру - LoggingReg
#LOGGING_SUB = 1 ; Писать логи работы подпрограмм - LoggingSub
#LOGGING_DBG = 1 ; Переключить LOGGING на DBG вместо записи в файл
;}
;{ Дополнительная трассировка
#DBGX_EXECUTE = 0 ; 1 - ShellExecute/CreateProcess, 2 - CreateProcess
#DBGX_LOAD_LIBRARY = 0 ; 1 - всё, 2 - без GetProcAddress
#DBGX_FILE_OPERATIONS = 0
#DBGX_PROFILE_STRINGS = 0
;}
;;----------------------------------------------------------------------------------------------------------------------
;{ Блокировка интернета
#BLOCK_WININET = 0 ; wininet.dll
#BLOCK_WINHTTP = 0 ; winhttp.dll
#BLOCK_WINSOCKS = 0 ; wsock32.dll
#BLOCK_WINSOCKS2 = 0 ; ws2_32.dll
#DBG_BLOCK_INTERNET = 0
;}
;{ Блокировка консоли
#BLOCK_CONSOLE = 1
#DBG_BLOCK_CONSOLE = 0
;}
;{ Управление сохранением конфигурации
#CFG_SAVE_ON_CLOSE = 0 ; Сохранять настройки при RegCloseKey (может вызвать замедление). 1 - сохранять всегда, 2 - управление через переменную CfgSaveOnClose
;}
;{ Некоторые дополнительные процедуры
#PROC_GETVERSIONINFO = 1 ; Получение информации о файле
#PROC_FINDMEMORYSTRING = 0 ; Поиск в памяти
#PROC_FINDMEMORYBINARY = 0 ; Поиск в памяти
#PROC_REPLACEMEMORYSTRING = 0 ; Поиск и замена в памяти
#PROC_REPLACEMEMORYBINARY = 0 ; Поиск и замена в памяти
#PROC_GETBITNESS = 0 ; Определение разрядность исполняемого файла
#PROC_GETFILEBITNESS = 0 ; Определение разрядность исполняемого файла
#PROC_CORRECTPATH = 1 ; Процедуры коррекции локальных путей. 1: если не найдено, возвращает пустую строку, 2: если не найдено, возвращает прежнее значение.
#PROC_CORRECTCFGPATH = 1 ; Если используется, должна быть установлена #PROC_CORRECTPATH
;#PROC_GUID2S = 0 ; Преобразование GUID/CLSID в строку вида {4AABE186-2666-4663-9E3E-5DFD6EAAAB60}
#PROC_CORRECTCHECKSUM = 0
#PROC_CORRECTCHECKSUMADR = 0
#PROC_REMOVECERTIFICATES = 0
;}
#INCLUDE_MIN_HOOK = 1 ; Принудительное включение MinHook
#INCLUDE_IAT_HOOK = 0 ; Принудительное включение IatHook
XIncludeFile "PurePortable.pbi"
;;======================================================================================================================
;{ SPECIAL FOLDERS
Structure RFID_DATA
	rfid.GUID
	path.s
EndStructure
Global Dim RFIDs.RFID_DATA(1), nRFIDs
Procedure.s CheckRFID(rfid) ; Принимается указатель на rfid
	Protected i
	For i=1 To nRFIDs
		If CompareMemory(rfid,@RFIDs(i)\rfid,16)
			ProcedureReturn RFIDs(i)\path
		EndIf
	Next
	ProcedureReturn ""
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Structure CSIDL_DATA
	csidl.l
	path.s
EndStructure
Global Dim CSIDLs.CSIDL_DATA(1), ncsidl
Procedure.s CheckCSIDL(csidl) ; Принимается csidl & ~#CSIDL_FLAG_MASK
	Protected i
	For i=1 To ncsidl
		If csidl=CSIDLs(i)\csidl
			ProcedureReturn CSIDLs(i)\path
		EndIf
	Next
	ProcedureReturn ""
EndProcedure
;}
;{ REGISTRY
Structure KEYDATA
	chk.s
	clen.i
	ccut.i
	virt.s
	;vlen.i ; ???
EndStructure
Global Dim KeyData.KEYDATA(0), nKeyData
Procedure.s CheckKey(hKey.l,Key.s)
	Protected i
	For i=1 To nKeyData
		If Left(Key,KeyData(i)\clen)=KeyData(i)\chk
			If KeyData(i)\ccut ; обрезаем символы до указанного
				ProcedureReturn KeyData(i)\virt+Mid(Key,KeyData(i)\ccut)
			Else
				ProcedureReturn KeyData(i)\virt+Mid(Key,KeyData(i)\clen+1)
			EndIf
		EndIf
	Next
	ProcedureReturn ""
EndProcedure
;}
;{ PROFILE STRINGS
CompilerIf #PORTABLE_PROFILE_STRINGS
	Procedure.s CheckIni(FileName.s)
		ProcedureReturn PrgDir+GetFilePart(FileName)
	EndProcedure
CompilerEndIf
;}
;{ CBT HOOK
; Процедура должна вернуть:
; 0 - выполнить CallNextHookEx
; Или сумму флагов
; 1 - сохранить реестр, 2 - снять CBT-хук (UnhookWindowsHookEx), 4 - снять все хуки
; $F - сохранить реестр и снять все хуки (при завершении программы)
CompilerIf #PORTABLE_CBT_HOOK
	; Заголовок передаётся в нижнем регистре не более 64 символов.
	Procedure CheckTitle(nCode,Title.s)
		If Title = "qtpowerdummywindow"
			CompilerIf Defined(MH_Initialize,#PB_Procedure) : MH_Uninitialize() : CompilerEndIf
			dbgany("CBT EXIT: "+GetFilePart(PrgPath))
			LoggingEnd("CBT EXIT: "+GetFilePart(PrgPath))
			ProcedureReturn #PORTABLE_CBTR_FULL
		EndIf
		;;-------------------         1         2         3         4         5         6         7         8         9
		;;-------------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		If Left(Title,10) = "cicmarshalwnd"
			CompilerIf Defined(MH_Initialize,#PB_Procedure) : MH_Uninitialize() : CompilerEndIf
			dbgany("CBT EXIT: "+GetFilePart(PrgPath))
			LoggingEnd("CBT EXIT: "+GetFilePart(PrgPath))
			ProcedureReturn #PORTABLE_CBTR_FULL
		EndIf
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;}
;{ ENTRY POINT
CompilerIf #PORTABLE_ENTRYPOINT
	Procedure EntryPoint()
		;dbg("ENTRYPOINT")
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
CompilerIf Not Defined(_ExpandEnvironmentStrings,#PB_Procedure)
	; Подобная процедура определена в модуле EnvironmentStrings
	Procedure.s _ExpandEnvironmentStrings(String.s)
		Protected Result.s, Length, *Buffer
		Length = ExpandEnvironmentStrings_(@String,*Buffer,0)
		If Length
			*Buffer = AllocateMemory(Length*2+2,#PB_Memory_NoClear)
			ExpandEnvironmentStrings_(@String,*Buffer,Length)
			Result = PeekS(*Buffer)
			FreeMemory(*Buffer)
		EndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Procedure.s PreferencePath(Path.s="")
	Protected Result.s
	If Path=""
		Path = PreferenceKeyValue()
	EndIf
	;dbg("PreferencePath: <"+Path)
	Path = _ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34)))
	;dbg("PreferencePath: *"+Path)
	If Path="."
		Path = DllDirN
	;ElseIf Path=".." Or Left(Path,2)=".\" Or Left(Path,3)="..\"
	;	Path = DllDir+Path
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = DllDir+Path
	EndIf
	;dbg("PreferencePath: >"+NormalizePath(Path))
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================
Prototype GUIDFromString(*psz,*pguid)
Procedure s2guid(guid.s,*guid.GUID)
	Static GUIDFromString.GUIDFromString
	Static hDll
	If hDll = 0
		hDll = LoadLibrary_("shell32.dll")
	EndIf
	If GUIDFromString = 0
		GUIDFromString = GetProcAddress_(hDll,704)
	EndIf
	ProcedureReturn GUIDFromString(@guid,*guid)
EndProcedure
; Procedure s2guid2(guid.s,*guid.GUID)
; 	*guid\Data1 = Val("$"+Mid(guid,2,8))
; 	*guid\Data2 = Val("$"+Mid(guid,11,4))
; 	*guid\Data3 = Val("$"+Mid(guid,16,4))
; 	*guid\Data4[0] = Val("$"+Mid(guid,21,2))
; 	*guid\Data4[1] = Val("$"+Mid(guid,23,2))
; 	*guid\Data4[2] = Val("$"+Mid(guid,26,2))
; 	*guid\Data4[3] = Val("$"+Mid(guid,28,2))
; 	*guid\Data4[4] = Val("$"+Mid(guid,30,2))
; 	*guid\Data4[5] = Val("$"+Mid(guid,32,2))
; 	*guid\Data4[6] = Val("$"+Mid(guid,34,2))
; 	*guid\Data4[7] = Val("$"+Mid(guid,36,2))
; EndProcedure
;;======================================================================================================================
Global VolumeSerialNumber
Prototype GetVolumeInformation(*RootPathName,*VolumeNameBuffer,nVolumeNameSize,*VolumeSerialNumber.LONG,*MaximumComponentLength,*FileSystemFlags,*FileSystemNameBuffer,nFileSystemNameSize)
Global Original_GetVolumeInformationA.GetVolumeInformation
Procedure Detour_GetVolumeInformationA(*RootPathName,*VolumeNameBuffer,nVolumeNameSize,*VolumeSerialNumber.LONG,*MaximumComponentLength,*FileSystemFlags,*FileSystemNameBuffer,nFileSystemNameSize)
	Protected Result = Original_GetVolumeInformationA(*RootPathName,*VolumeNameBuffer,nVolumeNameSize,*VolumeSerialNumber,*MaximumComponentLength,*FileSystemFlags,*FileSystemNameBuffer,nFileSystemNameSize)
	If VolumeSerialNumber And *VolumeSerialNumber
		;dbg("GetVolumeInformationA: "+PeekSZ(*RootPathName,-1,#PB_Ascii)+" "+StrU(PeekL(*VolumeSerialNumber),#PB_Long))
		*VolumeSerialNumber\l = VolumeSerialNumber
	EndIf
	ProcedureReturn Result
EndProcedure
Global Original_GetVolumeInformationW.GetVolumeInformation
Procedure Detour_GetVolumeInformationW(*RootPathName,*VolumeNameBuffer,nVolumeNameSize,*VolumeSerialNumber.LONG,*MaximumComponentLength,*FileSystemFlags,*FileSystemNameBuffer,nFileSystemNameSize)
	Protected Result = Original_GetVolumeInformationW(*RootPathName,*VolumeNameBuffer,nVolumeNameSize,*VolumeSerialNumber,*MaximumComponentLength,*FileSystemFlags,*FileSystemNameBuffer,nFileSystemNameSize)
	If VolumeSerialNumber And *VolumeSerialNumber
		;dbg("GetVolumeInformationW: "+PeekSZ(*RootPathName)+" "+StrU(PeekL(*VolumeSerialNumber),#PB_Long))
		*VolumeSerialNumber\l = VolumeSerialNumber
	EndIf
	ProcedureReturn Result
EndProcedure
;;======================================================================================================================
Prototype CallPlugin(cmd,*data)
Global PureAppsPrefs.s
ProcedureDLL.l AttachProcess(Instance)
	Protected i

	;{ Файл конфигурации
	PureAppsPrefs = DllDir+DllName
	
	If FileExist(PureAppsPrefs+".prefs")
		PureAppsPrefs+".prefs"
	ElseIf FileExist(PureAppsPrefs+".ini")
		PureAppsPrefs+".ini"
	ElseIf FileExist(DllDir+"PurePort.prefs")
		PureAppsPrefs = DllDir+"PurePort.prefs"
	ElseIf FileExist(DllDir+"PurePort.ini")
		PureAppsPrefs = DllDir+"PurePort.ini"
	ElseIf FileExist(DllDir+"PurePortable.prefs")
		PureAppsPrefs = DllDir+"PurePortable.prefs"
	ElseIf FileExist(DllDir+"PurePortable.ini")
		PureAppsPrefs = DllDir+"PurePortable.ini"
	EndIf
	If OpenPreferences(PureAppsPrefs,#PB_Preference_NoSpace) = 0
		MessageBox_(0,"Config file not found!","PurePortable",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		Goto EndAttach
	EndIf
	;}
	
	Protected k.s, v.s, p.s, n.s, o.s ; для обработки preferences
	Protected retcode

	;{ Проверка, та ли программа запущена
	Protected ValidateProgram = 1
	Protected InvalidProgram
	Protected InvalidReaction = 1
	If LCase(PrgName) = "rundll32"
		InvalidProgram = 2
	ElseIf PreferenceGroup("Portable")
		ValidateProgram = ReadPreferenceInteger("ValidateProgram",1)
	EndIf
	If ValidateProgram And PreferenceGroup("ValidateProgram")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			v = PreferenceKeyValue()
			Select LCase(k)
				Case "programname"
					If _ValidateProgramL(PrgName,v,1)
						InvalidProgram = 0
						Break
					EndIf
					InvalidProgram = 1
				Case "reaction"
					InvalidReaction = Val(v)
				Default
					If _ValidateProgramL(GetFileVersionInfo(PrgPath,k),v,1)
						InvalidProgram = 0
						Break
					EndIf
					InvalidProgram = 1
			EndSelect
		Wend
	EndIf
	If ValidateProgram And InvalidProgram = 1
		If InvalidReaction=3 ; Выдать предупреждение
			MessageBox_(0,"Invalid program "+PrgName+"!","PurePortable",#MB_ICONERROR)
		ElseIf InvalidReaction=1 Or InvalidReaction=2 ; Выдать запрос на продолжение
			Protected MessageBoxType = #MB_ICONERROR+#MB_YESNO
			If InvalidReaction=2
				MessageBoxType + #MB_DEFBUTTON2
			EndIf
			retcode = MessageBox_(0,"Invalid program "+PrgName+"!"+#CR$+"Continue the program execution?","PurePortable",MessageBoxType)
			If retcode<>#IDYES
				InvalidReaction=4
			EndIf
		EndIf
		If InvalidReaction=3 Or InvalidReaction=4 ; завершить работу
			TerminateProcess_(GetCurrentProcess_(),0)
		EndIf
		Goto EndAttach
	EndIf
	;}
	;{ Установка переменных среды
	SetEnvironmentVariable("PP_PrgPath",PrgPath)
	;SetEnvironmentVariable("PP_PrgName",PrgName)
	SetEnvironmentVariable("PP_PrgDir",PrgDirN)
	SetEnvironmentVariable("PP_DllPath",DllPath)
	SetEnvironmentVariable("PP_DllDir",DllDirN)
	If PreferenceGroup("EnvironmentVariables")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			;v = PreferenceKeyValue()
			p = PreferencePath()
			If p
				SetEnvironmentVariable(k,p)
			Else
				RemoveEnvironmentVariable(k)
			EndIf
		Wend
	EndIf
	;}
	;{ Общие параметры
	If PreferenceGroup("Portable")
		RegistryPermit = ReadPreferenceInteger("Registry",0)
		SpecialFoldersPermit = ReadPreferenceInteger("SpecialFolders",0)
		EnvironmentVariablesPermit = ReadPreferenceInteger("EnvironmentVariables",0)
		p = ReadPreferenceString("DataFile","")
		If p
			ConfigFile = PreferencePath(p)
		EndIf
		p = ReadPreferenceString("InitFile","")
		If p
			PermanentFile = PreferencePath(p)
		EndIf
		ProxyErrorMode = ReadPreferenceInteger("ProxyErrorMode",0)
		MinHookErrorMode = ReadPreferenceInteger("MinHookErrorMode",0)
		VolumeSerialNumber = ReadPreferenceInteger("VolumeSerialNumber",0)
	EndIf
	;}
	;{ Вывод отладочной информации
	Global DbgRegMode = 0
	Global DbgSpecMode = 0
	Global DbgEnvMode = 0
	Global DbgAnyMode = 0
	If PreferenceGroup("Debug")
		DbgRegMode = ReadPreferenceInteger("Registry",0)
		DbgSpecMode = ReadPreferenceInteger("SpecialFolders",0)
		DbgEnvMode = ReadPreferenceInteger("EnvironmentVariables",0)
		DbgAnyMode = ReadPreferenceInteger("Attach",0)
	EndIf
	;}
	;{ Закончить, если был запуск через rundll32
	If InvalidProgram = 2
		Goto EndAttach
	EndIf
	;}
	;{ Обрабатываемые ключи реестра
	If RegistryPermit And PreferenceGroup("Registry")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = Trim(LCase(PreferenceKeyName()),"\")
			v = LCase(PreferenceKeyValue())
			If v
				nKeyData+1
				ReDim KeyData(nKeyData)
				KeyData(nKeyData)\chk = k
				KeyData(nKeyData)\clen = Len(k)
				i = FindString(v,"|")
				If i
					KeyData(nKeyData)\ccut = Val(Mid(v,i+1))
					KeyData(nKeyData)\virt = Left(v,i-1)
				Else
					KeyData(nKeyData)\virt = v
					;KeyData(nKeyData)\vlen = Len(v)
				EndIf
			Else ; Специальная форма вида "Software\MyCompany" без значения или с пустым значением
				If Left(k,9)="software\"
					nKeyData+1
					ReDim KeyData(nKeyData)
					KeyData(nKeyData)\chk = k
					KeyData(nKeyData)\clen = Len(k)
					k = Mid(k,10)
					KeyData(nKeyData)\virt = k
					nKeyData+1
					ReDim KeyData(nKeyData)
					KeyData(nKeyData)\chk = k
					KeyData(nKeyData)\clen = Len(k)
					KeyData(nKeyData)\virt = k
				EndIf
			EndIf
		Wend
	EndIf
	;}
	;{ Перенаправляемые специальные папки
	If (SpecialFoldersPermit Or EnvironmentVariablesPermit) And PreferenceGroup("SpecialFolders")
		p = PreferencePath(ReadPreferenceString("AllDirs",""))
		If p
			ProfileRedir = p
			AppDataRedir = p
			LocalAppDataRedir = p
			LocalLowAppDataRedir = p
			CommonAppDataRedir = p
			CreatePath(p)
		EndIf
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			v = PreferenceKeyValue()
			p = PreferencePath()
			Select LCase(k)
				Case "profile"
					ProfileRedir = p
					CreatePath(p)
				Case "appdata"
					AppDataRedir = p
					CreatePath(p)
				Case "localappdata"
					LocalAppDataRedir = p
					CreatePath(p)
				Case "localappdatalow"
					LocalLowAppDataRedir = p
					CreatePath(p)
				Case "commonappdata"
					CommonAppDataRedir = p
					CreatePath(p)
				Case "documents"
					DocumentsRedir = p
					CreatePath(p)
				Case "commondocuments"
					CommonDocumentsRedir = p
					CreatePath(p)
				Default
					Protected id.s = k
					Protected rfid.GUID
					; https://learn.microsoft.com/en-us/windows/win32/shell/guidfromstring
					; Пытаемся распознать ключ как RFID (GUID в скобках {} или без)
					; или CSIDL (число dec или hex в формате C)
					If Left(k,1)="{"
						id = Mid(id,2)
					EndIf
					If s2guid(id,@rfid)
						nRFIDs+1
						ReDim RFIDs(nRFIDs)
						CopyMemory(@rfid,@RFIDs(nRFIDs)\rfid,16)
						RFIDs(nRFIDs)\path = p
						CreatePath(p)
					Else
						If Left(k,2)="0x" ; HEX CSIDL
							k = "$"+Mid(k,3)
						EndIf
						Protected csidl = Val(k)
						If csidl
							ncsidl+1
							ReDim CSIDLs(ncsidl)
							CSIDLs(ncsidl)\csidl = csidl
							CSIDLs(ncsidl)\path = p
							CreatePath(p)
						EndIf
					EndIf
			EndSelect
		Wend
	EndIf
	;}
	;{ Перенаправление переменных среды
	If EnvironmentVariablesPermit And PreferenceGroup("EnvironmentVariables")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			v = PreferenceKeyValue()
			p = PreferencePath()
			Select LCase(k)
				Case "userprofile"
					If p="" : p = ProfileRedir : EndIf
				Case "allusersprofile","programdata"
					If p="" : p = CommonAppDataRedir : EndIf
				Case "appdata"
					If p="" : p = AppDataRedir : EndIf
				Case "localappdata"
					If p="" : p = AppDataRedir : EndIf
				Default
					p = v
			EndSelect
			If p
				SetEnvironmentVariable(k,p)
			EndIf
		Wend
	EndIf
	;}
	;{ Чтение реестр
	ReadCfg()
	;}
	;{ Коррекция путей в реестре
	If RegistryPermit And PreferenceGroup("Registry.CorrectPaths")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			;p = PreferenceKeyValue()
			i = FindString(k,"|")
			If i
				v = Mid(k,i+1)
				k = Left(k,i-1)
				o = GetCfgS(k,v)
				n = CorrectPath(o,DllDirN)
				If n And n<>o
					SetCfgS(k,v,n)
				EndIf
			Else ; значение по умолчанию?
			EndIf
		Wend
	EndIf
	;}
	;{ Установка путей в реестре
	If RegistryPermit And PreferenceGroup("Registry.SetPaths")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			p = PreferencePath()
			i = FindString(k,"|")
			If i
				v = Mid(k,i+1)
				k = Left(k,i-1)
				SetCfgS(k,v,p)
			Else ; значение по умолчанию?
			EndIf
		Wend
	EndIf
	;}
	;{ Установка хуков для подмены серийного номера диска
	If VolumeSerialNumber
		MH_HookApi(kernel32,GetVolumeInformationA)
		MH_HookApi(kernel32,GetVolumeInformationW)
	EndIf
	;}
	;{ Плагины
	Protected Plugin.s, hPlugin, PluginFunc.CallPlugin, *PluginFuncAscii
	If PreferenceGroup("LoadLibrary")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			v = PreferenceKeyValue()
			Plugin = PreferencePath(k)
			hPlugin = LoadLibrary_(Plugin)
			If hPlugin And v <> ""
				*PluginFuncAscii = Ascii(v)
				PluginFunc = GetProcAddress_(hPlugin,*PluginFuncAscii)
				
				FreeMemory(*PluginFuncAscii)
			EndIf
		Wend
	EndIf
	;}
	PPInitialization

	EndAttach:
	ClosePreferences()
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
#FOF_NO_CONNECTED_ELEMENTS = $2000 ; https://learn.microsoft.com/ru-ru/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags
Global DbgClnMode
Procedure DbgCln(txt.s)
	If DbgClnMode
		dbg(txt)
	EndIf
EndProcedure
Declare Execute(prg.s,prm.s,dir.s="")
ProcedureDLL.l DetachProcess(Instance)
	If LCase(PrgName) = "rundll32"
		ProcedureReturn
	EndIf
		
	MH_Uninitialize()
	If RegistryPermit
		WriteCfg()
	EndIf
	
	If OpenPreferences(PureAppsPrefs,#PB_Preference_NoSpace) = 0
		Goto EndDetach
	EndIf
	
	If PreferenceGroup("Portable")
		If ReadPreferenceInteger("Cleanup",0)
			Execute(SysDir+"\rundll32.exe",Chr(34)+DllPath+Chr(34)+",PurePortableCleanup")
		EndIf
	EndIf
	
	EndDetach:
	PPFinish
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
ProcedureDLL PurePortableCleanup(hWnd,hInst,*lpszCmdLine,nCmdShow)
	If OpenPreferences(PureAppsPrefs,#PB_Preference_NoSpace) = 0
		ProcedureReturn
	EndIf
	
	Protected k.s, v.s, p.s ; для обработки preferences
	Protected RetCode
	Protected Heap = HeapCreate_(0,0,0)
	Protected *buf = HeapAlloc_(Heap,#HEAP_ZERO_MEMORY,4)
	Protected CleanupRootDir.s, lCleanupRootDir
	If PreferenceGroup("Debug")
		DbgClnMode = ReadPreferenceInteger("Cleanup",0)
	EndIf
	If PreferenceGroup("Portable")
		;If ReadPreferenceInteger("Cleanup",0) = 0
		;	ProcedureReturn
		;EndIf
		CleanupRootDir = PreferencePath(ReadPreferenceString("CleanupRootDir",""))
	EndIf
	If CleanupRootDir = ""
		CleanupRootDir = DllDirN
	EndIf
	DbgCln("CleanupRootDir: "+CleanupRootDir)
	CleanupRootDir = LCase(CleanupRootDir+"\") ; обязательно "\" в конце
	lCleanupRootDir = Len(CleanupRootDir)
	
	; Чистка
	Protected SHFileOp.SHFILEOPSTRUCT
	If PreferenceGroup("Cleanup")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			p = PreferencePath(PreferenceKeyName())
			DbgCln("Cleanup: "+p)
			; Для безопасности проверим путь - начало пути должно совпадать с CleanupRootDir
			If LCase(Left(p,lCleanupRootDir)) <> CleanupRootDir
				DbgCln("Cleanup: Wrong path!"+p)
				Continue
			EndIf
			v = p+"#"
			PokeW(@v+Len(v)*2-2,0) ; Эта строка должна быть завершена двойным значением NULL
			;DbgCln("Cleanup: "+v)
			; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shfileoperationa
			;SHFileOp\hwnd = 0 ; Окно не нужно
			SHFileOp\wFunc = #FO_DELETE
			; #FOF_FILESONLY Если в поле pFrom установлено *.*, то операция будет производиться только с файлами.
			; #FOF_SILENT Не показывать диалог с индикатором прогресса.
			; #FOF_NOCONFIRMATION Отвечать "yes to all" на все запросы в ходе опеации.
			; #FOF_NO_CONNECTED_ELEMENTS
			SHFileOp\fFlags = #FOF_SILENT|#FOF_NOCONFIRMATION|#FOF_NOERRORUI ;|#FOF_FILESONLY
			SHFileOp\pFrom = @v ; Эта строка должна быть завершена двойным значением NULL
			;SHFileOp\fAnyOperationsAborted = 0
			RetCode = SHFileOperation_(SHFileOp)
			; 124 == 0x7C == The path in the source or destination or both was invalid.
			; Путь в источнике или пункте назначения или в обоих случаях недействителен.
			DbgCln("Cleanup: "+Str(RetCode))
		Wend
	EndIf
	ClosePreferences()
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
Procedure Execute(prg.s,prm.s,dir.s="") ; TODO: dir
	Protected si.STARTUPINFO
	Protected pi.PROCESS_INFORMATION
	Protected flags, error
	With si
		\cb = SizeOf(STARTUPINFO)
		;\wShowWindow = #SW_SHOWMAXIMIZED
	EndWith
	Protected cmdline.s = Chr(34)+prg+Chr(34)
	If prm
		cmdline+" "+prm
	EndIf
	DbgCln("Execute: "+cmdline)
	If CreateProcess_(#Null,@cmdline,#Null,#Null,#False,flags,#Null,#Null,si,pi)
		WaitForSingleObject_(pi\hProcess,#INFINITE)
	Else
		DbgCln(GetLastErrorStr())
	EndIf
EndProcedure
;;======================================================================================================================
ProcedureDLL ShowVolumeSerialNumber(hWnd,hInst,*lpszCmdLine,nCmdShow)
	SetErrorMode_(#SEM_FAILCRITICALERRORS)
	Protected RootPathName.s = Left(WinDir,3)
	Protected VolumeNameBuffer.s = Space(#MAX_PATH)
	Protected VolumeSerialNumber, MaximumComponentLength, FileSystemFlags
	GetVolumeInformation_(@RootPathName,@VolumeNameBuffer,#MAX_PATH,@VolumeSerialNumber,@MaximumComponentLength,@FileSystemFlags,#Null,0)
	If MessageBox_(#Null,"Disk serial number:"+#CRLF$+StrU(VolumeSerialNumber,#PB_Long)+#CRLF$+"Copy to clipboard?","PurePortable",#MB_YESNO) = #IDYES
		SetClipboardText(StrU(VolumeSerialNumber,#PB_Long))
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 323
; FirstLine = 225
; Folding = fkv7PAg-
; Optimizer
; EnableThread
; Executable = ..\PureBasic\400.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.10.0.11
; VersionField1 = 4.10.0.0
; VersionField3 = Pure Portable
; VersionField4 = 4.10.0.0
; VersionField5 = 4.10.0.11
; VersionField6 = Proxy dll
; VersionField7 = 400.dll
; VersionField9 = (c) Smitis, 2017-2024
; VersionField18 = Comments
; VersionField21 = PAM Project