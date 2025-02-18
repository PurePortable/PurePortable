﻿;;======================================================================================================================
; PurePortableSimple
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.6
;RES_DESCRIPTION PurePortableSimple
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePort.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\PPDK\Lib"
XIncludeFile "PurePortableCustom.pbi"

#PROXY_DLL = "pureport"
#PROXY_DLL_COMPATIBILITY = 0 ; Совместимость: 0 - по умолчанию, 5 - XP, 7 - Windows 7 (default), 10 - Windows 10

#CONFIG_FILENAME = ""
#CONFIG_PERMANENT = #CONFIG_FILENAME+"-init"
;#CONFIG_INITIAL = #CONFIG_FILENAME+"-Init"
;#PREFERENCES_FILENAME = #CONFIG_FILENAME ; Имя файла конфигурации PurePortable

;;----------------------------------------------------------------------------------------------------------------------
;{ Общие параметры компиляции
#PORTABLE = 1 ; Управление портабелизацией: 0 - прозрачный режим, 1 - перехват
#PORTABLE_REGISTRY = 1 ; Перехват функций для работы с реестром
;{ Управление хуками PORTABLE_REGISTRY
#DETOUR_REG_SHLWAPI = 1 ; Перехват функций для работы с реестром из shlwapi
#DETOUR_REG_TRANSACTED = 1
;}
#PORTABLE_SPECIAL_FOLDERS = 1 ; Перехват функций для работы со специальными папками
;{ Управление хуками PORTABLE_SPECIAL_FOLDERS
#DETOUR_SHFOLDER = 1 ; Перехват функций из shfolder.dll
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
#PORTABLE_CLEANUP = 1
#PORTABLE_CHECK_PROGRAM = 1
;}
;{ Обработка ошибок
;#PROXY_ERROR_MODE = 1
#MIN_HOOK_ERROR_MODE = 2
;}
;{ Мониторинг
#DBG_REGISTRY = #DBG_REG_MODE_MAX
#DBG_SPECIAL_FOLDERS = #DBG_SF_MODE_MAX
#DBG_ENVIRONMENT_VARIABLES = 1
#DBG_PROFILE_STRINGS = 0
#DBG_CBT_HOOK = 0
#DBG_MIN_HOOK = 0
#DBG_IAT_HOOK = 0
#DBG_PROXY_DLL = 0
#DBG_CLEANUP = 1
#DBG_ANY = 1
;}
;{ Мониторинг некоторых вызовов WinApi
#DBGX_EXECUTE = 0 ; 1 - ShellExecute/CreateProcess, 2 - CreateProcess
#DBGX_LOAD_LIBRARY = 0 ; 1 - всё, 2 - без GetProcAddress
#DBGX_FILE_OPERATIONS = 0
#DBGX_PROFILE_STRINGS = 0
;}
;{ Блокировка интернета
#BLOCK_WININET = 1 ; wininet.dll
#BLOCK_WINHTTP = 1 ; winhttp.dll
#BLOCK_WINSOCKS = 2 ; по умолчанию будет ws2_32
;#BLOCK_WINSOCKS2 = 1 ; ws2_32.dll
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
#PROC_CORRECTPATH = 1 ; Процедуры коррекции локальных путей. 1: если не найдено, возвращает пустую строку, 2: если не найдено, возвращает прежнее значение.
#PROC_CORRECTCFGPATH = 1 ; Если используется, должна быть установлена #PROC_CORRECTPATH
;}
#INCLUDE_MIN_HOOK = 1 ; Принудительное включение MinHook
#INCLUDE_IAT_HOOK = 0 ; Принудительное включение IatHook
XIncludeFile "PurePortableSimple.pbi"
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
CompilerIf #PORTABLE_REGISTRY
	Structure KEYDATA
		chk.s
		clen.i
		exact.i
		virt.s
	EndStructure
	Global Dim KeyData.KEYDATA(0), nKeyData
	Procedure.s CheckKey(hKey.l,Key.s)
		Protected i, l, c, k.s
		For i=1 To nKeyData
			l = KeyData(i)\clen
			k = KeyData(i)\chk
			; было If Left(Key,KeyData(i)\clen)=KeyData(i)\chk
			If KeyData(i)\exact
				If StrCmp(@Key,@k)=0 Or (StrCmpN(@Key,@k,l)=0 And PeekW(@Key+l<<1)=92)
					ProcedureReturn KeyData(i)\virt+Mid(Key,l+1)
				EndIf
			ElseIf StrCmpN(@Key,@k,l)=0
				ProcedureReturn KeyData(i)\virt+Mid(Key,l+1)
			EndIf
		Next
		ProcedureReturn ""
	EndProcedure
	Procedure AddKeyData(k.s,v.s)
		If k
			nKeyData+1
			ReDim KeyData(nKeyData)
			KeyData(nKeyData)\exact = Bool(Right(k,1)="\")
			KeyData(nKeyData)\chk = RTrim(k,"\")
			KeyData(nKeyData)\clen = Len(KeyData(nKeyData)\chk)
			KeyData(nKeyData)\virt = RTrim(v,"\")
		EndIf
	EndProcedure
CompilerEndIf
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
		;;-------------------         1         2         3         4         5         6         7         8         9
		;;-------------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		If Left(Title,10) = "cicmarshalwnd"
			ProcedureReturn #PORTABLE_CBTR_EXIT
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
;{ Перехват VolumeSerialNumber
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
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-getfileinformationbyhandle
Prototype GetFileInformationByHandle(hFile,*FileInformation.BY_HANDLE_FILE_INFORMATION)
Global Original_GetFileInformationByHandle.GetFileInformationByHandle
Procedure Detour_GetFileInformationByHandle(hFile,*FileInformation.BY_HANDLE_FILE_INFORMATION)
	Protected Result = Original_GetFileInformationByHandle(hFile,*FileInformation)
	;dbg("GetFileInformationByHandle: "+Str(hFile))
	;dbg("  VolumeSerialNumber: "+StrU(*FileInformation\dwVolumeSerialNumber,#PB_Long))
	*FileInformation\dwVolumeSerialNumber = VolumeSerialNumber
	ProcedureReturn Result
EndProcedure
;}
;;======================================================================================================================
;{ Подделка даты
; https://learn.microsoft.com/en-us/windows/win32/sysinfo/time-functions
; https://learn.microsoft.com/en-us/windows/win32/sysinfo/windows-time
; https://learn.microsoft.com/en-us/windows/win32/sysinfo/local-time
Global SpoofDateTimeout.q
Global SpoofDateShift.q
Global SpoofDateFlag
;;----------------------------------------------------------------------------------------------------------------------
Declare CheckSpoofDate()
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetSystemTimeAsFileTime(*SystemTimeAsFileTime.QUAD)
Global Original_GetSystemTimeAsFileTime.GetSystemTimeAsFileTime
Procedure Detour_GetSystemTimeAsFileTime(*SystemTimeAsFileTime.QUAD)
	;dbg("GetSystemTimeAsFileTime")
	If CheckSpoofDate()
		Protected TempFT.q
		Original_GetSystemTimeAsFileTime(*SystemTimeAsFileTime)
		*SystemTimeAsFileTime\q = *SystemTimeAsFileTime\q - SpoofDateShift
		ProcedureReturn #True
	EndIf
	ProcedureReturn Original_GetSystemTimeAsFileTime(*SystemTimeAsFileTime)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetSystemTime(*SystemTime.SYSTEMTIME)
Global Original_GetSystemTime.GetSystemTime
Procedure Detour_GetSystemTime(*SystemTime.SYSTEMTIME)
	;dbg("GetSystemTime")
	If CheckSpoofDate()
		Protected TempFT.q
		Original_GetSystemTimeAsFileTime(@TempFT)
		TempFT = TempFT - SpoofDateShift
		ProcedureReturn FileTimeToSystemTime_(@TempFT,*SystemTime)
	EndIf
	ProcedureReturn Original_GetSystemTime(*SystemTime)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetLocalTime(*SystemTime.SYSTEMTIME)
Global Original_GetLocalTime.GetLocalTime
Procedure Detour_GetLocalTime(*SystemTime.SYSTEMTIME)
	;dbg("GetLocalTime")
	If CheckSpoofDate()
		Protected TempST.SYSTEMTIME, TempFT.q
		Original_GetLocalTime(@TempST)
		SystemTimeToFileTime_(@TempST,@TempFT)
		TempFT = TempFT - SpoofDateShift
		ProcedureReturn FileTimeToSystemTime_(@TempFT,*SystemTime)
	EndIf
	ProcedureReturn Original_GetLocalTime(*SystemTime)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getprocesstimes
Procedure CheckSpoofDate()
	;Protected CreationTime.q, ExitTime.q, KernelTime.q, UserTime.q
	If SpoofDateTimeout = 0
		ProcedureReturn #True
	EndIf
	If SpoofDateFlag
		; не работает GetProcessTimes
		;If GetProcessTimes_(GetCurrentProcessId_(),@CreationTime,@ExitTime,@KernelTime,@UserTime)
		;EndIf
		Protected TempFT.q
		If Original_GetSystemTimeAsFileTime(@TempFT)
			;dbg("SpoofDateCurrent: "+RSet(Str(TempFT),24))
			;dbg("SpoofDateTimeout: "+RSet(Str(SpoofDateTimeout),24))
			SpoofDateFlag = Bool(SpoofDateTimeout>TempFT)
			;dbg("Flag: "+SpoofDateFlag)
		EndIf
	EndIf
	ProcedureReturn SpoofDateFlag	
EndProcedure
;}
;;----------------------------------------------------------------------------------------------------------------------
Global ComputerName.s
;;======================================================================================================================
Global PureSimplePrefs.s
Global PureSimplePrev.s ; предыдущий конфиг при MultiConfig
Global ExtData.EXT_DATA
Global DbgRegMode
Global DbgSpecMode
Global DbgEnvMode
Global DbgAnyMode
Global DbgDetach
;;----------------------------------------------------------------------------------------------------------------------
Procedure _OpenPreference(Prefs.s)
	If OpenPreferences(Prefs,#PB_Preference_NoSpace) = 0
		MessageBox_(0,"Config file not found!","PurePortable",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		ProcedureReturn 0
	EndIf
	If PreferenceGroup("Portable") = 0
		MessageBox_(0,"Section [Portable] not found!","PurePortable",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		ProcedureReturn 0
	EndIf
	ProcedureReturn 1
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Declare RunFrom(k.s,p.s)
;;----------------------------------------------------------------------------------------------------------------------
Procedure CheckProgram()
	Protected k.s, v.s, p.s, n.s, o.s, t.s ; для обработки preferences
	Protected RetCode
	;{ Файл конфигурации
	PureSimplePrefs = PrgDir+DllName
	Protected MultiConfigPrefs.s 
	If FileExist(PureSimplePrefs+".prefs")
		PureSimplePrefs+".prefs"
	ElseIf FileExist(PureSimplePrefs+".ini")
		PureSimplePrefs+".ini"
	ElseIf FileExist(PrgDir+"PurePort.prefs")
		PureSimplePrefs = PrgDir+"PurePort.prefs"
	ElseIf FileExist(PrgDir+"PurePort.ini")
		PureSimplePrefs = PrgDir+"PurePort.ini"
	EndIf
	_OpenPreference(PureSimplePrefs) ; текущая группа будет Portable
	;}
	;{ Мультиконфиг
	; После _OpenPreference текущая группа Portable
	If ReadPreferenceInteger("MultiConfig",0)
		ExaminePreferenceGroups()
		Protected Group.s
		While NextPreferenceGroup()
			Group = PreferenceGroupName()
			If LCase(Left(Group,7))="config:"
				ExaminePreferenceKeys()
				While NextPreferenceKey()
					k = PreferenceKeyName()
					v= PreferenceKeyValue()
					Select LCase(k)
						Case "reaction" ; пропускаем
						Case "programname","programfilename"
							If CompareWithList(PrgName,v,1)
								MultiConfigPrefs = Mid(Group,8)
								Break 2
							EndIf
						Default
							If CompareWithList(GetFileVersionInfo(PrgPath,k),v,1)
								MultiConfigPrefs = Mid(Group,8)
								Break 2
							EndIf
					EndSelect
				Wend
			EndIf
		Wend
		If MultiConfigPrefs ; была обнаружена подходящая группа "Config:"
			MultiConfigPrefs = PreferencePath(MultiConfigPrefs)
			ClosePreferences()
			PureSimplePrefs = MultiConfigPrefs ; другой файл конфигурации
			_OpenPreference(PureSimplePrefs)
		EndIf
	EndIf
	;}
	;{ Проверка, та ли программа запущена
	Protected InvalidProgram = 1
	Protected InvalidReaction = 1
	If PreferenceGroup("Portable")
		If ReadPreferenceInteger("ValidateProgram",1)
			If PreferenceGroup("ValidateProgram") = 0
				MessageBox_(0,"Section [ValidateProgram] not found!","PurePortable",#MB_ICONERROR)
				TerminateProcess_(GetCurrentProcess_(),0)
				ProcedureReturn #INVALID_PROGRAM
			EndIf
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				k = PreferenceKeyName()
				v = PreferenceKeyValue()
				Select LCase(k)
					Case "programname","programfilename"
						If CompareWithList(PrgName,v,1)
							InvalidProgram = 0
							Break
						EndIf
					Case "reaction"
						InvalidReaction = Val(v)
					Default ; остальные это ресурсы VersionInfo
						If CompareWithList(GetFileVersionInfo(PrgPath,k),v,1)
							InvalidProgram = 0
							Break
						EndIf
				EndSelect
			Wend
			If InvalidProgram ; если не выполнилось ни одного условия
				If InvalidReaction=3 ; Выдать предупреждение
					MessageBox_(0,"Invalid program "+PrgName+"!","PurePortable",#MB_ICONERROR)
				ElseIf InvalidReaction=1 Or InvalidReaction=2 ; Выдать запрос на продолжение
					Protected MessageBoxType = #MB_ICONERROR+#MB_YESNO
					If InvalidReaction=2
						MessageBoxType+#MB_DEFBUTTON2
					EndIf
					RetCode = MessageBox_(0,"Invalid program "+PrgName+"!"+#CR$+"Continue the program execution?","PurePortable",MessageBoxType)
					If RetCode<>#IDYES
						InvalidReaction = 4 ; далее это завершит работу
					EndIf
				EndIf
				If InvalidReaction=3 Or InvalidReaction=4 ; завершить работу
					TerminateProcess_(GetCurrentProcess_(),0)
				EndIf
				ProcedureReturn #INVALID_PROGRAM
			EndIf
		EndIf
	EndIf
	;}
	ClosePreferences()
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Действия выполняемые при запуске программы.
Procedure AttachProcedure()
	Protected i, j
	Protected k.s, v.s, p.s, n.s, o.s, t.s ; для обработки preferences
	Protected RetCode
	
	OpenPreferences(PureSimplePrefs)
	
	;{ Установка переменных среды
	SetEnvironmentVariable("PP_PrgPath",PrgPath)
	SetEnvironmentVariable("PP_PrgDir",PrgDirN)
	SetEnvironmentVariable("PP_PrgName",PrgName)
	;SetEnvironmentVariable("PP_PrgPath",DllPath)
	;SetEnvironmentVariable("PP_DllDir",DllDirN)
	If PreferenceGroup("EnvironmentVariables")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			p = PreferenceKeyValue()
			If p
				SetEnvironmentVariable(k,ExpandEnvironmentStrings(p))
			Else
				RemoveEnvironmentVariable(k)
			EndIf
		Wend
	EndIf
	If PreferenceGroup("EnvironmentVariables.SetPaths")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			;v = PreferenceKeyValue()
			p = PreferencePath()
			If p
				;CreatePath(p)
				SetEnvironmentVariable(k,p)
			EndIf
		Wend
	EndIf
	;}
	;{ Общие параметры
	Protected SpoofDateP.s
	If PreferenceGroup("Portable")
		CompilerIf #PORTABLE_REGISTRY
			RegistryPermit = ReadPreferenceInteger("Registry",0)
			If RegistryPermit
				RegistryShlwapiPermit = ReadPreferenceInteger("RegistryShlwapi",1)
			EndIf
			ConfigFile = ReadPreferenceString("DataFile","")
			If ConfigFile
				If GetExtensionPart(ConfigFile)=""
					ConfigFile + #CONFIG_FILEEXT
				EndIf
				ConfigFile = PreferencePath(ConfigFile)
			EndIf
			InitialFile = ReadPreferenceString("InitFile","")
			If InitialFile
				If GetExtensionPart(InitialFile)=""
					InitialFile + #CONFIG_INITIALEXT
				EndIf
				InitialFile = PreferencePath(InitialFile)
			EndIf
			If ReadPreferenceInteger("RegistryDll",0)=1
				RegistryDll = "kernelbase"
			EndIf
		CompilerEndIf
		SpecialFoldersPermit = ReadPreferenceInteger("SpecialFolders",0)
		GetUserProfileDirectoryMode = ReadPreferenceInteger("GetUserProfileDirectory",1)
		EnvironmentVariablesPermit = ReadPreferenceInteger("EnvironmentVariables",0)
		ProxyErrorMode = ReadPreferenceInteger("ProxyErrorMode",0)
		MinHookErrorMode = ReadPreferenceInteger("MinHookErrorMode",0)
		BlockConsolePermit = ReadPreferenceInteger("BlockConsole",0)
		CompilerIf Defined(BLOCK_WININET,#PB_Constant)
			BlockWinInetPermit = ReadPreferenceInteger("BlockWinInet",0)
		CompilerEndIf
		CompilerIf Defined(BLOCK_WINHTTP,#PB_Constant)
			BlockWinHttpPermit = ReadPreferenceInteger("BlockWinHttp",0)
		CompilerEndIf
		CompilerIf Defined(BLOCK_WINSOCKS,#PB_Constant)
			BlockWinSocksPermit = ReadPreferenceInteger("BlockWinSocks",0)
			If BlockWinSocksPermit = 1 ; wsock32 иначе ws2_32, т.к. #BLOCK_WINSOCKS=2 
				WinSocksDll = "wsock32"
			EndIf
		CompilerEndIf
		p = ReadPreferenceString("CurrentDirectory","")
		If p <> ""
			SetCurrentDirectory(PreferencePath(p))
		EndIf
		VolumeSerialNumber = ReadPreferenceInteger("VolumeSerialNumber",0)
		SpoofDateP = ReadPreferenceString("SpoofDate","")
		SpoofDateTimeout = ReadPreferenceInteger("SpoofDateTimeout",0) * 10000 ; миллисекунды в 100-наносекундные интервалы
	EndIf
	;}
	;{ Вывод отладочной информации
	DbgRegMode = 0
	DbgSpecMode = 0
	DbgEnvMode = 0
	DbgAnyMode = 0
	DbgDetach = 1
	If PreferenceGroup("Debug")
		DbgRegMode = ReadPreferenceInteger("Registry",0)
		DbgSpecMode = ReadPreferenceInteger("SpecialFolders",0)
		DbgEnvMode = ReadPreferenceInteger("EnvironmentVariables",0)
		;DbgAnyMode = ReadPreferenceInteger("Attach",0)
		DbgDetach = ReadPreferenceInteger("Detach",1)
	EndIf
	;}
	;{ Создание папок
	If PreferenceGroup("CreateDirectories")
		While NextPreferenceKey()
			CreatePath(PreferencePath(PreferenceKeyName()))
		Wend
	EndIf
	;}
	;{ Обрабатываемые ключи реестра
	CompilerIf #PORTABLE_REGISTRY
		If RegistryPermit And PreferenceGroup("Registry")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				k = LCase(PreferenceKeyName())
				v = LCase(PreferenceKeyValue())
				If v
					AddKeyData(k,v)
				ElseIf Left(k,9)="software\" ; Специальная форма вида "Software\MyCompany" без значения или с пустым значением
					v = Mid(k,10)
					AddKeyData(k,v)
					AddKeyData(v,v)
				Else ; используем as is
					AddKeyData(k,k)
				EndIf
			Wend
		EndIf
	CompilerEndIf
	;}
	;{ Перенаправление специальных папок
	If (SpecialFoldersPermit Or EnvironmentVariablesPermit) And PreferenceGroup("SpecialFolders")
		v = Trim(ReadPreferenceString("AllDirs",""),"\")
		If v
			p = PreferencePath(v)
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
			v = RTrim(PreferenceKeyValue(),"\")
			If v
				p = PreferencePath(v)
			Else
				p = ""
			EndIf
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
				Case "temp"
					TempRedir = p
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
			Select LCase(k) ; если значение не задано, для некоторых устанавливаем то же, что и для SpecialFolders.
				Case "userprofile"
					If p="" And ProfileRedir<>p : p = ProfileRedir : EndIf
				Case "allusersprofile","programdata"
					If p="" And CommonAppDataRedir<>p : p = CommonAppDataRedir : EndIf
				Case "appdata"
					If p="" And AppDataRedir<>p : p = AppDataRedir : EndIf
				Case "localappdata"
					If p="" And AppDataRedir<>p : p = AppDataRedir : EndIf
				Case "temp","tmp"
					If p="" And TempRedir<>p : p = TempRedir : EndIf
				Default
					p = v
			EndSelect
			If p
				SetEnvironmentVariable(k,p)
			EndIf
		Wend
	EndIf
	;}
	;{ Чтение реестра
	CompilerIf #PORTABLE_REGISTRY
		ReadCfg()
	CompilerEndIf
	;}
	;{ Реестр
	CompilerIf #PORTABLE_REGISTRY
		If RegistryPermit
			; Установка данных
			If PreferenceGroup("Registry.SetData")
				ExaminePreferenceKeys()
				While NextPreferenceKey()
					k = PreferenceKeyName()
					p = PreferenceKeyValue()
					i = FindString(k,"|")
					If i
						v = Mid(k,i+1)
						k = Left(k,i-1)
						i = FindString(p,":")
						t = LCase(Left(p,i-1))
						p = Mid(p,i+1)
						Select t
							Case "s"
								SetCfgS(k,v,p)
							Case "d"
								SetCfgD(k,v,Val(p))
							Case "b"
								SetCfgB(k,v,p)
						EndSelect
					EndIf
				Wend
			EndIf
			; Установка путей
			If PreferenceGroup("Registry.SetPaths")
				ExaminePreferenceKeys()
				While NextPreferenceKey()
					k = PreferenceKeyName()
					p = PreferencePath()
					i = FindString(k,"|")
					If i
						v = Mid(k,i+1)
						k = Left(k,i-1)
						SetCfgS(k,v,p)
						;CreatePath(p)
					Else ; значение по умолчанию?
					EndIf
				Wend
			EndIf
			; Коррекция путей
			If PreferenceGroup("Registry.CorrectPaths")
				ExaminePreferenceKeys()
				While NextPreferenceKey()
					k = PreferenceKeyName()
					p = PreferencePath()
					i = FindString(k,"|")
					If i
						v = Mid(k,i+1)
						k = Left(k,i-1)
						o = GetCfgS(k,v)
						If p=""
							p = PrgDirN
						EndIf
						n = CorrectPath(o,p)
						If n And n<>o
							SetCfgS(k,v,n)
						EndIf
					Else ; дефолтное значение?
					EndIf
				Wend
			EndIf
		EndIf
	CompilerEndIf
	;}
	;{ Установка хуков для подмены серийного номера диска
	If VolumeSerialNumber
		MH_HookApi(kernel32,GetVolumeInformationA)
		MH_HookApi(kernel32,GetVolumeInformationW)
		MH_HookApi(kernel32,GetFileInformationByHandle)
	EndIf
	;}
	;{ Установка хуков для подмены даты
	If SpoofDateP
		Protected TempST.SYSTEMTIME, TempFT.q
		Protected SpoofST.SYSTEMTIME, SpoofFT.q
		SpoofDateP = ReplaceString(SpoofDateP,".","-")
		SpoofDateP = ReplaceString(SpoofDateP,"/","-")
		i = FindString(SpoofDateP,"-")
		If i
			SpoofST\wYear = Val(Left(SpoofDateP,i-1)) ; Дата для подстановки
			j = FindString(SpoofDateP,"-",i+1)
			If j
				; Дата для подстановки
				SpoofST\wMonth = Val(Mid(SpoofDateP,i+1,j-i))
				SpoofST\wDay = Val(Mid(SpoofDateP,j+1))
				SystemTimeToFileTime_(@SpoofST,@SpoofFT)
				;dbg("SpoofDate:        "+RSet(Str(SpoofFT),24))
				; Текущая дата
				GetSystemTimeAsFileTime_(@TempFT)
				;dbg("CurrentTime:      "+RSet(Str(TempFT),24))
				; Когда выключить подстановку
				If SpoofDateTimeout <> 0
					SpoofDateFlag = #True
					SpoofDateTimeout = TempFT + SpoofDateTimeout
				EndIf
				;dbg("SpoofDateTimeout: "+RSet(Str(SpoofDateTimeout),24))
				;dbg("Flag: "+SpoofDateFlag)
				; Текущая дата на 00:00:00.000
				FileTimeToSystemTime_(@TempFT,@TempST)
				TempST\wHour = 0
				TempST\wMinute = 0
				TempST\wSecond = 0
				TempST\wMilliseconds = 0
				SystemTimeToFileTime_(@TempST,@TempFT)
				; Вычисляем сдвиг во времени
				SpoofDateShift = TempFT - SpoofFT
				;dbg("SpoofDateShift:   "+RSet(Str(SpoofDateShift),24))
				;SpoofDateLimit = SpoofDateLimit + SpoofDateShift
				;dbg("SpoofDateLimit:   "+RSet(Str(SpoofDateLimit),24))
				
				;dbg("SPOOF DATE: "+Str(SpoofDateST\wYear)+" :: "+Str(SpoofDateST\wMonth)+" :: "+Str(SpoofDateST\wDay))
				;SystemTimeToFileTime_(@SpoofDateST,@SpoofDateFT)
				
				MH_HookApi(kernel32,GetLocalTime)
				MH_HookApi(kernel32,GetSystemTime)
				MH_HookApi(kernel32,GetSystemTimeAsFileTime)
				;MH_HookApi(kernel32,CompareFileTime)
			EndIf
		EndIf
	EndIf
	;}
	;{ Загрузка сторонных библиотек
	Protected LoadableLibrary.s, hLoadableLibrary
	If PreferenceGroup("LoadLibrary")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			LoadableLibrary = PreferencePath(PreferenceKeyName())
			dbg("ATTACHPROCESS: DLL: "+LoadableLibrary)
			hLoadableLibrary = LoadLibrary_(@LoadableLibrary)
			If hLoadableLibrary
				dbg("ATTACHPROCESS: DLL: OK")
			EndIf
		Wend
	EndIf
	;}
	;{ Загрузка расширений
	Protected PurePortableExtension.PurePortableExtension
	Protected *PurePortableExtensionNameA = Ascii("PurePortableExtension")
	If PreferenceGroup("Extensions")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			;k = PreferenceKeyName()
			;v = PreferenceKeyValue()
			LoadableLibrary = PreferencePath(PreferenceKeyName())
			;dbg("ATTACHPROCESS: EXT: "+LoadableLibrary)
			hLoadableLibrary = LoadLibrary_(@LoadableLibrary)
			If hLoadableLibrary
				PurePortableExtension = GetProcAddress_(hLoadableLibrary,*PurePortableExtensionNameA)
				If PurePortableExtension
					If ExtData\Version = 0 ; надо инициализировать структуру
						ExtData\Version = 1
						ExtData\ProcessCnt = ProcessCnt
						ExtData\PrgPath = @PrgPath
						ExtData\DllPath = @DllPath
						ExtData\PrefsFile = @PureSimplePrefs
						ExtData\PP\dbg = @dbg()
						ExtData\MH\MH_Initialize = @MH_Initialize()
						ExtData\MH\MH_CreateHook = @MH_CreateHook()
						ExtData\MH\MH_CreateHookApi = @MH_CreateHookApi()
						ExtData\MH\MH_CreateHookApiEx = @MH_CreateHookApiEx()
						ExtData\MH\MH_EnableHook = @MH_EnableHook()
						ExtData\MH\MH_DisableHook = @MH_DisableHook()
						ExtData\MH\MH_RemoveHook = @MH_RemoveHook()
						ExtData\MH\MH_QueueEnableHook = @MH_QueueEnableHook()
						ExtData\MH\MH_QueueDisableHook = @MH_QueueDisableHook()
						ExtData\MH\MH_ApplyQueued = @MH_ApplyQueued()
						ExtData\MH\MH_Uninitialize = @MH_Uninitialize()
						ExtData\MH\_MHX_HookApi = @_MH_HookApi()
						ExtData\MH\_MHX_Error = @_MH_Error()
					EndIf
					; Код возврата:
					; 1 - Выгрузить dll после завершения
					i = PurePortableExtension(@ExtData)
					If i = 1
						FreeLibrary_(hLoadableLibrary)
					EndIf
				EndIf
				;dbg("ATTACHPROCESS: EXT: OK")
			EndIf
		Wend
	EndIf
	FreeMemory(*PurePortableExtensionNameA)
	;}
	;{ Запуск приложений
	If SingleProcess And PreferenceGroup("RunFromAttachProcess")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			RunFrom(PreferenceKeyName(),PreferenceKeyValue())
		Wend
	EndIf		
	;}
	ClosePreferences()
EndProcedure

;;======================================================================================================================
; Действия выполняемые при завершении работы программы.
; Процедура должна вернуть 1 если не требуется выполнение процедуры завершения (снятие хуков, выполнение очистки и т.п.).
; Для rundll32 не выполняется.
Procedure DetachProcedure()
	CompilerIf #PORTABLE_REGISTRY
		If RegistryPermit
			WriteCfg()
		EndIf
	CompilerEndIf
	If OpenPreferences(PureSimplePrefs,#PB_Preference_NoSpace) = 0
		ProcedureReturn 1
	EndIf
	
	If SingleProcess
		If PreferenceGroup("RunFromDetachProcess")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				RunFrom(PreferenceKeyName(),PreferenceKeyValue())
			Wend
		EndIf
		
		; Удаление ненужных файлов и папок.
		Protected CleanupDirectory.s, lCleanupDirectory, CleanupItem.s, Cleanup
		If PreferenceGroup("Portable")
			Cleanup = ReadPreferenceInteger("Cleanup",0)
			CleanupDirectory = ReadPreferenceString("CleanupDirectory","")
		EndIf
		If Cleanup
			If PreferenceGroup("Debug")
				DbgClnMode = ReadPreferenceInteger("Cleanup",0)
			EndIf
			If CleanupDirectory = ""
				CleanupDirectory = PrgDirN
			EndIf
			DbgCln("CleanupDirectory: "+CleanupDirectory)
			Protected Dim ClnDirs.s(0), iClnDir
			Protected nClnDir = SplitArray(ClnDirs(),CleanupDirectory)
			If nClnDir = 0
				nClnDir = AddArrayS(ClnDirs(),PrgDirN)
			EndIf
			For iClnDir=1 To nClnDir
				ClnDirs(iClnDir) = PreferencePath(ClnDirs(iClnDir))
			Next
			ClnDirs(0) = TempDir ; всегда разрешено во временной папке
			If PreferenceGroup("Cleanup")
				ExaminePreferenceKeys()
				While NextPreferenceKey()
					CleanupItem = PreferencePath(PreferenceKeyName())
					DbgCln("Cleanup: "+CleanupItem)
					; Для безопасности проверим путь - начало пути должно совпадать с одним из путей из ClnDirs
					Cleanup = 0
					For iClnDir=0 To nClnDir ; проверяем, что очистка производится только в разрешённых папках
						DbgCln("Cleanup: Chk: "+ClnDirs(iClnDir))
						If StartWithPath(CleanupItem,ClnDirs(iClnDir))
							Cleanup = 1
							DbgCln("Cleanup: Into: "+ClnDirs(iClnDir))
							Break
						EndIf
					Next
					If Cleanup
						AddCleanItem(CleanupItem)
					EndIf
				Wend
			EndIf
		EndIf
	EndIf
	ClosePreferences()
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
XIncludeFile "PP_ExecuteDll.pbi"
;;----------------------------------------------------------------------------------------------------------------------
Procedure RunFrom(k.s,p.s)
	Protected i
	Protected Dim Flags.s(0)
	Protected ExecuteFlags
	SplitArray(Flags(),k,",")
	For i=1 To ArraySize(Flags())
		Select LCase(Flags(i))
			Case "nowait"
				ExecuteFlags & (~#EXECUTE_WAIT)
			Case "wait"
				ExecuteFlags | #EXECUTE_WAIT
			Case "hide"
				ExecuteFlags | #EXECUTE_HIDE
		EndSelect
	Next
	;Execute("",ExpandEnvironmentStrings(p),ExecuteFlags)
	ExecuteDll(ExpandEnvironmentStrings(p),ExecuteFlags)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 412
; FirstLine = 240
; Folding = 2HcgPoDAQ-
; Optimizer
; EnableThread
; Executable = PureSimple.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.6
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.6
; VersionField6 = PurePortableSimple
; VersionField7 = PurePort.dll
; VersionField9 = (c) Smitis, 2017-2025