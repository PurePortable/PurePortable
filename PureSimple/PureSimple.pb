;;======================================================================================================================
; PurePortable for PurePortableSimple
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.10.0.26
;RES_DESCRIPTION PurePortableSimple
;RES_COPYRIGHT (c) Smitis, 2017-2024
;RES_INTERNALNAME 400.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.10.0.0
;PP_X32_COPYAS "Temp\PurePort32.dll"
;PP_X64_COPYAS "Temp\PurePort64.dll"
;PP_CLEAN 2

EnableExplicit
IncludePath "..\PPDK\Lib"
XIncludeFile "PurePortableCustom.pbi"

#PROXY_DLL = "pureport"
#PROXY_DLL_COMPATIBILITY = 0 ; Совместимость: 0 - по умолчанию, 5 - XP, 7 - Windows 7 (default), 10 - Windows 10

#CONFIG_FILENAME = "registry"
#CONFIG_PERMANENT = #CONFIG_FILENAME+"-init"
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
#BLOCK_WININET = 1 ; wininet.dll
#BLOCK_WINHTTP = 1 ; winhttp.dll
#BLOCK_WINSOCKS = 1 ; wsock32.dll
#BLOCK_WINSOCKS2 = 1 ; ws2_32.dll
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
;{ Преобразование относительных путей
Procedure.s PreferencePath(Path.s="",Dir.s="")
	Protected Result.s
	If Path=""
		Path = PreferenceKeyValue()
	EndIf
	If Dir=""
		Dir = PrgDirN
	EndIf
	;dbg("PreferencePath: <"+Path)
	Path = ExpandEnvironment(Trim(Trim(Path),Chr(34)))
	;dbg("PreferencePath: *"+Path)
	If Path="."
		Path = Dir
	;ElseIf Path=".." Or Left(Path,2)=".\" Or Left(Path,3)="..\"
	;	Path = Dir+"\"+Path
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = Dir+"\"+Path
	EndIf
	;dbg("PreferencePath: >"+NormalizePath(Path))
	ProcedureReturn NormalizePath(Path)
EndProcedure
;}
;;======================================================================================================================
XIncludeFile "proc\s2guid.pbi"
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
Global SpoofDate.SYSTEMTIME
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetSystemTime(*SystemTime.SYSTEMTIME)
Global Original_GetSystemTime.GetSystemTime
Procedure Detour_GetSystemTime(*SystemTime.SYSTEMTIME)
	Protected Result = Original_GetSystemTime(*SystemTime)
	*SystemTime\wDay = SpoofDate\wDay
	*SystemTime\wDayOfWeek = SpoofDate\wDayOfWeek
	*SystemTime\wMonth = SpoofDate\wMonth
	*SystemTime\wYear = SpoofDate\wYear
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetSystemTimeAsFileTime(*SystemTimeAsFileTime.FILETIME)
Global Original_GetSystemTimeAsFileTime.GetSystemTimeAsFileTime
Procedure Detour_GetSystemTimeAsFileTime(*SystemTimeAsFileTime.FILETIME)
	Protected FileTime.FILETIME
	Protected Result = Original_GetSystemTimeAsFileTime(@FileTime)
	Protected SystemTime.SYSTEMTIME
	FileTimeToSystemTime_(@FileTime,@SystemTime)
	SystemTime\wDay = SpoofDate\wDay
	SystemTime\wDayOfWeek = SpoofDate\wDayOfWeek
	SystemTime\wMonth = SpoofDate\wMonth
	SystemTime\wYear = SpoofDate\wYear
	ProcedureReturn SystemTimeToFileTime_(@SystemTime,*SystemTimeAsFileTime)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetLocalTime(*SystemTime.SYSTEMTIME)
Global Original_GetLocalTime.GetLocalTime
Procedure Detour_GetLocalTime(*SystemTime.SYSTEMTIME)
	Protected Result = Original_GetLocalTime(*SystemTime)
	*SystemTime\wDay = SpoofDate\wDay
	*SystemTime\wDayOfWeek = SpoofDate\wDayOfWeek
	*SystemTime\wMonth = SpoofDate\wMonth
	*SystemTime\wYear = SpoofDate\wYear
	ProcedureReturn Result
EndProcedure
;}
;;======================================================================================================================
Global PureAppsPrefs.s
XIncludeFile "proc\Execute.pbi"
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
	Execute("",ExpandEnvironment(p),ExecuteFlags)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
ProcedureDLL.l AttachProcess(Instance)
	PPPreparation
	Protected i, j

	;{ Файл конфигурации
	PureAppsPrefs = PrgDir+DllName
	
	If FileExist(PureAppsPrefs+".prefs")
		PureAppsPrefs+".prefs"
	ElseIf FileExist(PureAppsPrefs+".ini")
		PureAppsPrefs+".ini"
	ElseIf FileExist(PrgDir+"PurePort.prefs")
		PureAppsPrefs = PrgDir+"PurePort.prefs"
	ElseIf FileExist(PrgDir+"PurePort.ini")
		PureAppsPrefs = PrgDir+"PurePort.ini"
	EndIf
	If OpenPreferences(PureAppsPrefs,#PB_Preference_NoSpace) = 0
		MessageBox_(0,"Config file not found!","PurePortable",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		Goto EndAttach
	EndIf
	If PreferenceGroup("Portable") = 0
		MessageBox_(0,"Section [Portable] not found!","PurePortable",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		Goto EndAttach
	EndIf
	;}
	
	Protected k.s, v.s, p.s, n.s, o.s ; для обработки preferences
	Protected f
	Protected retcode

	;{ Проверка, та ли программа запущена
	Protected ValidateProgram
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
				Case "programname","programfilename"
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
	SetEnvironmentVariable("PP_PrgDir",PrgDirN)
	;SetEnvironmentVariable("PP_PrgName",PrgName)
	;SetEnvironmentVariable("PP_PrgPath",DllPath)
	;SetEnvironmentVariable("PP_DllDir",DllDirN)
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
	Protected SpoofDateP.s
	If PreferenceGroup("Portable")
		CompilerIf #PORTABLE_REGISTRY
			RegistryPermit = ReadPreferenceInteger("Registry",0)
			If RegistryPermit
				RegistryShlwapiPermit = ReadPreferenceInteger("RegistryShlwapi",1)
			EndIf
			p = ReadPreferenceString("DataFile","")
			If p
				ConfigFile = PreferencePath(p)
			EndIf
			If GetExtensionPart(ConfigFile)=""
				ConfigFile + #CONFIG_FILEEXT
			EndIf
			p = ReadPreferenceString("InitFile","")
			If p
				InitialFile = PreferencePath(p)
			EndIf
			If GetExtensionPart(InitialFile)=""
				InitialFile + #CONFIG_INITIALEXT
			EndIf
		CompilerEndIf
		SpecialFoldersPermit = ReadPreferenceInteger("SpecialFolders",0)
		EnvironmentVariablesPermit = ReadPreferenceInteger("EnvironmentVariables",0)
		ProxyErrorMode = ReadPreferenceInteger("ProxyErrorMode",0)
		MinHookErrorMode = ReadPreferenceInteger("MinHookErrorMode",0)
		VolumeSerialNumber = ReadPreferenceInteger("VolumeSerialNumber",0)
		SpoofDateP = ReadPreferenceString("SpoofDate","")
		BlockWinInetPermit = ReadPreferenceInteger("BlockWinInet",0)
		BlockWinHttpPermit = ReadPreferenceInteger("BlockWinHttp",0)
		BlockWinSocksPermit = ReadPreferenceInteger("BlockWinSocks",0)
		p = ReadPreferenceString("CurrentDirectory","")
		If p <> ""
			SetCurrentDirectory(PreferencePath(p))
		EndIf
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
				EndIf
			Wend
		EndIf
	CompilerEndIf
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
	;{ Чтение реестра
	CompilerIf #PORTABLE_REGISTRY
		ReadCfg()
	CompilerEndIf
	;}
	;{ Пути в реестре
	CompilerIf #PORTABLE_REGISTRY
		; Установка путей
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
		; Коррекция путей
		If RegistryPermit And PreferenceGroup("Registry.CorrectPaths")
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
		SpoofDateP = ReplaceString(SpoofDateP,".","-")
		SpoofDateP = ReplaceString(SpoofDateP,"/","-")
		i = FindString(SpoofDateP,"-")
		If i
			SpoofDate\wYear = Val(Left(SpoofDateP,i-1))
			j = FindString(SpoofDateP,"-",i+1)
			If j
				SpoofDate\wMonth = Val(Mid(SpoofDateP,i+1,j-i))
				SpoofDate\wDay = Val(Mid(SpoofDateP,j+1))
				;dbg("SPOOF DATE: "+Str(SpoofDate\wYear)+" :: "+Str(SpoofDate\wMonth)+" :: "+Str(SpoofDate\wDay))
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
			;k = PreferenceKeyName()
			;v = PreferenceKeyValue()
			LoadableLibrary = PreferencePath(PreferenceKeyName())
			hLoadableLibrary = LoadLibrary_(@LoadableLibrary)
		Wend
	EndIf
	;}
	;{ Запуск приложений
	If FirstProcess And PreferenceGroup("RunFromAttachProcess")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			RunFrom(PreferenceKeyName(),PreferenceKeyValue())
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
ProcedureDLL.l DetachProcess(Instance)
	If LCase(PrgName) = "rundll32"
		ProcedureReturn
	EndIf
		
	MH_Uninitialize()
	
	CompilerIf #PORTABLE_REGISTRY
		If RegistryPermit
			WriteCfg()
		EndIf
	CompilerEndIf
	
	If OpenPreferences(PureAppsPrefs,#PB_Preference_NoSpace) = 0
		Goto EndDetach
	EndIf
	
	If PreferenceGroup("Portable")
		If ReadPreferenceInteger("Cleanup",0)
			Execute(SysDir+"\rundll32.exe",Chr(34)+DllPath+Chr(34)+",PurePortableCleanup")
		EndIf
	EndIf
	
	If PreferenceGroup("RunFromDetachProcess")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			RunFrom(PreferenceKeyName(),PreferenceKeyValue())
		Wend
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
	Protected CleanupDirectory.s, lCleanupDirectory
	If PreferenceGroup("Debug")
		DbgClnMode = ReadPreferenceInteger("Cleanup",0)
	EndIf
	If PreferenceGroup("Portable")
		;If ReadPreferenceInteger("Cleanup",0) = 0
		;	ProcedureReturn
		;EndIf
		CleanupDirectory = PreferencePath(ReadPreferenceString("CleanupDirectory",""))
	EndIf
	If CleanupDirectory = ""
		CleanupDirectory = PrgDirN
	EndIf
	DbgCln("CleanupDirectory: "+CleanupDirectory)
	SetCurrentDirectory(CleanupDirectory)
	CleanupDirectory = LCase(CleanupDirectory+"\") ; обязательно "\" в конце
	lCleanupDirectory = Len(CleanupDirectory)
	
	; Чистка
	Protected SHFileOp.SHFILEOPSTRUCT
	If PreferenceGroup("Cleanup")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			p = PreferencePath(PreferenceKeyName())
			DbgCln("Cleanup: "+p)
			; Для безопасности проверим путь - начало пути должно совпадать с CleanupRootDir
			;If LCase(Left(p,lCleanupDirectory)) <> CleanupDirectory
			If Not StartWithPath(p,CleanupDirectory) And Not StartWithPath(p,TempDir)
				DbgCln("Cleanup: Wrong path! "+p)
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

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 334
; FirstLine = 71
; Folding = PAbAA5AAg
; Optimizer
; EnableThread
; Executable = ..\PureBasic\400.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.10.0.26
; VersionField1 = 4.10.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.10.0.0
; VersionField5 = 4.10.0.26
; VersionField6 = PurePortableSimple
; VersionField7 = 400.dll
; VersionField9 = (c) Smitis, 2017-2024