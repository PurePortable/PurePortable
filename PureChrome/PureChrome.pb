;;======================================================================================================================
; PurePortable for Chrome and clones
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.30.1
;RES_DESCRIPTION PurePortableExpert
;RES_COPYRIGHT (c) Smitis, 2017-2026
;RES_INTERNALNAME 400.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS "..\..\Browsers\Chrome\version.dll"
;PP_X64_COPYAS "..\..\Browsers\Yandex\version.dll"
;;PP_X64_COPYAS "%ProgramFiles%\Google\Chrome\Application\version.dll"
;;PP_X64_COPYAS "%LocalAppData%\Yandex\YandexBrowser\Application\version.dll"

;PP_CLEAN 2
;PP_CORRECTEXPORT 1


EnableExplicit
IncludePath "..\PPDK\Lib" ; Для доступа к файлам рядом с исходником можно использовать #PB_Compiler_FilePath
XIncludeFile "PurePortableCustom.pbi"

#PROXY_DLL = "version"
;#PROXY_DLL_ADDITIONAL = "kernel32" ; добавляем через XInclude специальную версию и включаем PP_CORRECTEXPORT

#CONFIG_FILENAME = "browser"
;#CONFIG_INITIAL = #CONFIG_FILENAME+"-Init"
#PREFERENCES_FILENAME = "portable.ini"
;#LOGGING_FILENAME = ""

;;----------------------------------------------------------------------------------------------------------------------
; Компиляции модулей для браузеров
#FakeGetVolumeInformation = 1
#FakeGetComputerName = 1
#FakeNetUserGetInfo = 1
#FakeLogonUser = 1
#FakeIsOS = 1

;;----------------------------------------------------------------------------------------------------------------------
#PORTABLE = 1 ; Управление портабелизацией: 0 - прозрачный режим, 1 - перехват
#PORTABLE_REGISTRY = 2 ;$101 ; Перехват функций для работы с реестром
;{ Управление хуками PORTABLE_REGISTRY
#DETOUR_REG_SHLWAPI = 0 ; Перехват функций для работы с реестром из shlwapi
#DETOUR_REG_TRANSACTED = 0
;}
#PORTABLE_SPECIAL_FOLDERS = 1 ; Перехват функций для работы со специальными папками
;{ Управление хуками PORTABLE_SPECIAL_FOLDERS
#DETOUR_SHFOLDER = 0 ; Перехват функций из shfolder.dll
#DETOUR_USERENV = 0	; Перехват функций из userenv.dll
;}
#PORTABLE_ENVIRONMENT_VARIABLES = 1
;{ Управление хуками PORTABLE_ENVIRONMENT_VARIABLES
#DETOUR_ENVIRONMENTVARIABLE = 1
#DETOUR_ENVIRONMENTSTRINGS = 0
#DETOUR_EXPANDENVIRONMENTSTRINGS = 0
#DETOUR_ENVIRONMENT_CRT = "" ; msvcrt
;}
#PORTABLE_PROFILE_STRINGS = 0
#PROFILE_STRINGS_FILENAME = "PurePortable"
#PORTABLE_CBT_HOOK = 0 ; Хук для отслеживания закрытия окон для сохранение конфигурации
#PORTABLE_ENTRYPOINT = 0
#PORTABLE_CLEANUP = 1
#PORTABLE_CHECK_PROGRAM = 1 ; Использовать CheckProgram
;;----------------------------------------------------------------------------------------------------------------------
#PORTABLE_REG_IGNORE_ERR = 1
#PORTABLE_REG_ARRAY = 1
;;----------------------------------------------------------------------------------------------------------------------
;{ Диагностика
#DBG_REGISTRY = 1
#DBG_SPECIAL_FOLDERS = 0
#DBG_ENVIRONMENT_VARIABLES = 0 ; 1 - только переопределяемые, 2 - все
#DBG_PROFILE_STRINGS = 0
#DBG_CBT_HOOK = 0
#DBG_MIN_HOOK = 0
#DBG_IAT_HOOK = 0
#DBG_PROXY_DLL = 0
#DBG_CLEANUP = 1
#DBG_EXECUTEDLL = 1
#DBG_ANY = 1
;}
;{ Дополнительная диагностика
#DBGX_EXECUTE = 0 ; 1 - ShellExecute/CreateProcess, 2 - CreateProcess
#DBGX_LOAD_LIBRARY = 0 ; 1 - всё, 2 - без GetProcAddress
#DBGX_FILE_OPERATIONS = 0
#DBGX_PROFILE_STRINGS = 0
;}
;;----------------------------------------------------------------------------------------------------------------------
;{ Блокировка консоли
#BLOCK_CONSOLE = 0
#DBG_BLOCK_CONSOLE = 0
;}
;{ Некоторые дополнительные процедуры
#PROC_GETVERSIONINFO = 1 ; Получение информации о файле
#PROC_CORRECTPATH = 0 ; Процедуры коррекции локальных путей. 1: если не найдено, возвращает пустую строку, 2: если не найдено, возвращает прежнее значение.
#PROC_CORRECTCFGPATH = 0 ; Если используется, должна быть установлена #PROC_CORRECTPATH
;}
#INCLUDE_MIN_HOOK = 1 ; Принудительное включение MinHook
#INCLUDE_IAT_HOOK = 0 ; Принудительное включение IatHook
XIncludeFile "PurePortable.pbi"
;XIncludeFile #PB_Compiler_FilePath+"kernel32-d.pbi"
XIncludeFile "PP_ExecuteDll.pbi"
;XIncludeFile "proc\guid2s.pbi"
;;======================================================================================================================
Declare.i FindInList(Text.s,Find.s)
Declare RunFrom(k.s,p.s)
Declare.s NormalizePPath(Path.s="")
Declare.s ReadPreferenceStringQ(Key.s,DefaultValue.s="")
Declare.s PreferenceKeyValueQ()
;;======================================================================================================================
;{ SPECIAL FOLDERS
CompilerIf #PORTABLE_SPECIAL_FOLDERS
	Procedure.s CheckKFID(rfid)
; 		If CompareMemory(rfid,?FOLDERID_ProgramFiles,16)
; 			ProcedureReturn ProfileRedir
; 		EndIf
 		ProcedureReturn ""
	EndProcedure
	DataSection
; 		FOLDERID_ProgramFiles: ; {905E63B6-C1BF-494E-B29C-65B732D3D21A}
; 		Data.l $905E63B6
; 		Data.w $C1BF,$494E
; 		Data.b $B2,$9C,$65,$B7,$32,$D3,$D2,$1A
; 		FOLDERID_ProgramFilesCommon: ; {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}
; 		Data.l $F7F1ED05
; 		Data.w $9F6D,$47A2
; 		Data.b $AA,$AE,$29,$D3,$17,$C6,$F0,$66
	EndDataSection
	Procedure.s CheckCSIDL(csidl) ; Принимается csidl & ~#CSIDL_FLAG_MASK
; 		Select csidl
; 			Case #CSIDL_PROGRAM_FILES_COMMON ; 0x2B
; 				ProcedureReturn ProfileRedir
; 		EndSelect
		ProcedureReturn ""
	EndProcedure
CompilerEndIf
;}
;{ REGISTRY
; software\yandex\yandexbrowser
; software\yandex\yandex.disk
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
					dbg("REG: "+KeyData(i)\virt+Mid(Key,l+1))
					ProcedureReturn KeyData(i)\virt+Mid(Key,l+1)
				EndIf
			ElseIf StrCmpN(@Key,@k,l)=0
				dbg("REG: "+KeyData(i)\virt+Mid(Key,l+1))
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
	; Процедура должна возвратить:
	; #PORTABLE_CBTR_EXIT если это закрытие главного окна программы. В этом случае принудительно будет выполнена процедура DetachProcess,
	; при этом при реальном выполнении DetachProcess никаких действий повторно произведено не будет.
	; #PORTABLE_CBTR_SAVECFG если требуется только сохранение реестра, например, при закрытии окна настроек.
	; 0 если никаких действий не требуется.
	Procedure CheckTitle(nCode,Title.s)
		;;-------------------         1         2         3         4         5         6         7         8         9
		;;-------------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		If Left(Title,08) = "settings"
			ProcedureReturn #PORTABLE_CBTR_SAVECFG ; только сохранение реестра
		EndIf
		If Title = "qtpowerdummywindow"
			ProcedureReturn #PORTABLE_CBTR_EXIT ; завершение работы программы как при DetachProcess
		EndIf
		If Title = "cicmarshalwnd"
			ProcedureReturn #PORTABLE_CBTR_EXIT ; завершение работы программы как при DetachProcess
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
Global AppDataDir.s, LocalAppDataDir.s
Global MainDir.s ; папка где лежит browser.dll/chrome.dll или подобная
Global MainDirN.s ; папка где лежит browser.dll/chrome.dll или подобная
Global BrowserVersion.s ; имя папки-версии
Global BrowserProductName.s
Global BrowserInternalName.s
Global BrowserOriginalFilename.s
Global BrowserPortable = 1 ; из portable.ini использовать портабелизацию
Global BrowserSecondary
Global BrowserExe.s
Global BrowserDll.s
Global InstallerExe.s
Global InstallerProductName.s = "Google Chrome Installer"
Global IsBrowser
Global IsInstaller ; 1 если запущен инсталлятор
Global IsUpdater

Global DbgRegMode
Global DbgExecMode
Global DbgCreateProcess
Global DbgCreateProcessLog

;;======================================================================================================================
Global CmdLine.s
Prototype GetCommandLine()
Global Original_GetCommandLineW.GetCommandLine
Procedure Detour_GetCommandLineW()
	; Саму строку читаем и формируем новую в AttachProcedure
	ProcedureReturn @CmdLine
EndProcedure
;;======================================================================================================================
Global LogFile.s
Procedure WriteL(txt.s)
	Protected log
	If LogFile = ""
		LogFile = PrgDir+"CreateProcess-"+FormatDate("%yyyy-%mm-%dd-%hh-%ii-%ss.log",Date())
	EndIf
	If FileExist(LogFile)
		log = OpenFile(#PB_Any,LogFile,#PB_UTF8|#PB_File_Append|#PB_File_SharedWrite)
	Else
		log = CreateFile(#PB_Any,LogFile,#PB_UTF8|#PB_File_Append|#PB_File_SharedWrite)
		WriteStringFormat(log,#PB_UTF8)
	EndIf
	WriteStringN(log,txt)
	CloseFile(log)
EndProcedure
;;======================================================================================================================
;{ CreateProcess
; Перехватываем CreateProcess для выявления запуска инсталятора

DeclareImport(shell32,_CommandLineToArgvW@12,CommandLineToArgvW,CommandLineToArgvW(*lpCmdLine,*pNumArgs.Integer))

; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
#EXTENDED_STARTUPINFO_PRESENT = $00080000
Prototype CreateProcess(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
Global Original_CreateProcessW.CreateProcess
Procedure Detour_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
	Protected ApplicationName.s = PeekSZ(lpApplicationName)
	Protected CommandLine.s = PeekSZ(lpCommandLine)
	Protected ProcessFullPath.s
	If DbgCreateProcess
		dbg("CreateProcessW: «"+ApplicationName+"» «"+CommandLine+"»")
	EndIf
	If DbgCreateProcessLog
		WriteL("CreateProcessW: «"+ApplicationName+"» «"+CommandLine+"»")
	EndIf
	
	Protected ProductName.s
	If ApplicationName
		ProcessFullPath = ApplicationName
	Else
		ProcessFullPath = CommandLine
		PathRemoveArgs_(@ProcessFullPath)
		PathUnquoteSpaces_(@ProcessFullPath)
		;ProcessFullPath = Trim(ProcessFullPath,Chr(34))
	EndIf
	If DbgCreateProcess
		dbg("  PROCESS FULL PATH: "+ProcessFullPath)
	EndIf
	If DbgCreateProcessLog
		WriteL("  PROCESS FULL PATH: "+ProcessFullPath)
	EndIf
	Protected nArgs
	Protected *Args.Integer, *ArgsMem
	If DbgCreateProcess Or DbgCreateProcessLog
		*ArgsMem = CommandLineToArgvW(@CommandLine,@nArgs)
		If DbgCreateProcess
			dbg("  Parameters: "+Str(nArgs))
		EndIf
		If DbgCreateProcessLog
			WriteL("  Parameters: "+Str(nArgs))
		EndIf
		If *ArgsMem
			*Args = *ArgsMem
			While nArgs ;And *Args\i
				If DbgCreateProcess
					dbg("  «"+PeekSZ(*Args\i)+"»")
				EndIf
				If DbgCreateProcessLog
					WriteL("  «"+PeekSZ(*Args\i)+"»")
				EndIf
				*Args+SizeOf(Integer)
				nArgs-1
			Wend
			LocalFree_(*ArgsMem)
		EndIf
	EndIf
	
	ProductName = GetFileVersionInfo(ProcessFullPath,"ProductName")
; 	If IsInstaller
; 		; Если процесс создае из инсталлятора, проверяем, запускается ли основной браузер.
; 		; Если да, то при необходимости патчим через rundll32 GetPathPart(ProcessFullPath)+"dllname.dll",MakePortable.
; 		; dllname берём из browsers.ini
; 		; Дожидаемся завершения работы rundll32.
; 		; Запускаем основной процесс
; 		If StrCmpI(@BrowserProductName,@ProductName)=0
; 			dbg("  START BROWSER: "+ProcessFullPath)
; 		EndIf
; 	Else
; 		; Иначе, процесс запущен из браузера, проверяем, если это запускается инсталлятор
; 		; то копируем dll под нужным именем в папку инсталлятора,
; 		; при необходимости патчим инсталлятор (все, если их несколько),
; 		; и запускаем инсталлятор
; 		If StrCmpI(@InstallerProductName,@ProductName)=0
; 			dbg("  START INSTALLER: "+ProcessFullPath)
; 		EndIf
; 	EndIf
	;If *StartupInfo\dwFlags & #EXTENDED_STARTUPINFO_PRESENT
	;	dbg("EXTENDED_STARTUPINFO_PRESENT")
	;EndIf
	;ProcedureReturn Original_CreateProcessW(@ApplicationNameEx,@CommandLineEx,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation)
	Protected Result = Original_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation)
	;dbg("CreateProcessW: "+StrU(*ProcessInformation\dwProcessId))
	
	ProcedureReturn Result
EndProcedure
;}
;;======================================================================================================================
;{ UpdateProcThreadAttribute
; Требуется перехватить UpdateProcThreadAttribute и при значении параметра Attribute равным PROC_THREAD_ATTRIBUTE_MITIGATION_POLICY
; обнулить бит PROCESS_CREATION_MITIGATION_POLICY_BLOCK_NON_MICROSOFT_BINARIES_ALWAYS_ON в политиках (передаётся в параметре lpValue)
; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-updateprocthreadattribute
#PROC_THREAD_ATTRIBUTE_MITIGATION_POLICY = 131079 ; $20007
#NON_MICROSOFT_BINARIES_ALWAYS_ON = $100000000000 ; (0x00000001 << 44)
#NON_MICROSOFT_BINARIES_ALWAYS_ON_OFF = ~$100000000000
#WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_ON = $10000000 ; (0x00000001 << 28)
#WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_OFF = $20000000 ; (0x00000002 << 28)
#PROCESS_CREATION_MITIGATION_POLICY_MASK = ~(#NON_MICROSOFT_BINARIES_ALWAYS_ON|#WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_ON)
Prototype UpdateProcThreadAttribute(lpAttributeList,dwFlags.l,Attribute,*lpValue.INTEGER,cbSize,lpPreviousValue,lpReturnSize)
Global Original_UpdateProcThreadAttribute.UpdateProcThreadAttribute
Procedure Detour_UpdateProcThreadAttribute(lpAttributeList,dwFlags.l,Attribute,*lpValue.INTEGER,cbSize,lpPreviousValue,lpReturnSize)
	;dbg("UpdateProcThreadAttribute: "+Str(Attribute))
	If Attribute = #PROC_THREAD_ATTRIBUTE_MITIGATION_POLICY And cbSize >= 8 ; SizeOf(DWORD64)
; 		If *lpValue\i & #NON_MICROSOFT_BINARIES_ALWAYS_ON
; 			;dbg("UpdateProcThreadAttribute: NON_MICROSOFT_BINARIES_ALWAYS_ON")
; 			*lpValue\i & ~#NON_MICROSOFT_BINARIES_ALWAYS_ON
; 		EndIf
; 		If *lpValue\i & #WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_ON
; 			;dbg("UpdateProcThreadAttribute: WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_ON")
; 			*lpValue\i & ~#WIN32K_SYSTEM_CALL_DISABLE_ALWAYS_ON
; 		EndIf
		*lpValue\i & #PROCESS_CREATION_MITIGATION_POLICY_MASK
		; на Win32 ??? *lpValue.QUAD ???
	EndIf
	ProcedureReturn Original_UpdateProcThreadAttribute(lpAttributeList,dwFlags,Attribute,*lpValue,cbSize,lpPreviousValue,lpReturnSize)
EndProcedure
;}
;;======================================================================================================================
;{ PSStringFromPropertyKey
; PSStringFromPropertyKey
; https://learn.microsoft.com/en-us/windows/win32/api/propsys/nf-propsys-psstringfrompropertykey
Prototype PSStringFromPropertyKey(*pkey, *psz, cch)
Global Original_PSStringFromPropertyKey.PSStringFromPropertyKey
Procedure Detour_PSStringFromPropertyKey(*pkey, *psz, cch) ; *pkey.REFPROPERTYKEY
	ProcedureReturn 0
EndProcedure
;}
;;======================================================================================================================
;{ Crypt
Global CryptMode = 0

; https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa381414(v=vs.85)
Structure CRYPTOAPI_BLOB Align #PB_Structure_AlignC
	cbData.l
	*pbData
EndStructure

; https://learn.microsoft.com/en-us/windows/win32/api/dpapi/ns-dpapi-cryptprotect_promptstruct
Structure CRYPTPROTECT_PROMPTSTRUCT Align #PB_Structure_AlignC
	cbSize.l
	dwPromptFlags.l
	hwndApp.i
	*szPromptl
EndStructure

; https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectdata
Prototype CryptProtectData(*pDataIn.CRYPTOAPI_BLOB,*szDataDescr,*pOptionalEntropy.CRYPTOAPI_BLOB,*pvReserved,*pPromptStruct.CRYPTPROTECT_PROMPTSTRUCT,dwFlags.l,*pDataOut.CRYPTOAPI_BLOB)
Global Original_CryptProtectData.CryptProtectData
; https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptunprotectdata
Prototype CryptUnprotectData(*pDataIn.CRYPTOAPI_BLOB,*szDataDescr,*pOptionalEntropy.CRYPTOAPI_BLOB,*pvReserved,*pPromptStruct.CRYPTPROTECT_PROMPTSTRUCT,dwFlags.l,*pDataOut.CRYPTOAPI_BLOB)
Global Original_CryptUnprotectData.CryptUnprotectData

Procedure Detour_CryptProtectData(*pDataIn.CRYPTOAPI_BLOB,*szDataDescr,*pOptionalEntropy.CRYPTOAPI_BLOB,*pvReserved,*pPromptStruct.CRYPTPROTECT_PROMPTSTRUCT,dwFlags.l,*pDataOut.CRYPTOAPI_BLOB)
	Protected Result
	Protected Size.i = *pDataIn\cbData
	;dbg("CryptProtectData: DataDescr: "+PeekSZ(*szDataDescr))
	;dbg("  OptionalEntropy: "+Str(*pOptionalEntropy))
		
	; Размер выходных данных равен размеру входных
	*pDataOut\cbData = *pDataIn\cbData
	
	; Выделить фиксированную память для блока выходных данных
	*pDataOut\pbData = LocalAlloc_(#LMEM_FIXED,*pDataIn\cbData)
	
	; Скопировать входные данные в блок выходных данных
	;CopyMemory(*pDataIn\pbData,*pDataOut\pbData,*pDataIn\cbData)
	CopyMemory_(*pDataOut\pbData,*pDataIn\pbData,*pDataOut\cbData)
	
	;SetLastError_(#NO_ERROR) ; ???
	ProcedureReturn #True
EndProcedure

Procedure Detour_CryptUnprotectData(*pDataIn.CRYPTOAPI_BLOB,*szDataDescr,*pOptionalEntropy.CRYPTOAPI_BLOB,*pvReserved,*pPromptStruct.CRYPTPROTECT_PROMPTSTRUCT,dwFlags.l,*pDataOut.CRYPTOAPI_BLOB)
	Protected Result
	Protected Size.i = *pDataIn\cbData
	;dbg("CryptUnprotectData: DataDescr: "+PeekSZ(*szDataDescr))
	
	; Размер выходных данных равен размеру входных
	*pDataOut\cbData = *pDataIn\cbData
	
	; Выделить фиксированную память для блока выходных данных
	*pDataOut\pbData = LocalAlloc_(#LMEM_FIXED,*pDataIn\cbData)
	
	; Скопировать входные данные в блок выходных данных
	;CopyMemory(*pDataIn\pbData,*pDataOut\pbData,*pDataOut\cbData)
	CopyMemory_(*pDataOut\pbData,*pDataIn\pbData,*pDataOut\cbData)
	
	;SetLastError_(#NO_ERROR) ; ???
	ProcedureReturn #True
EndProcedure
;}
;;======================================================================================================================
;{ GetComputerName
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getcomputernamew
; https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getcomputernameexw
Global ComputerName.s
CompilerIf #FakeGetComputerName
	Prototype GetComputerName(*lpBuffer,*nSize.LONG)
	Global Original_GetComputerNameW.GetComputerName
	Procedure Detour_GetComputerNameW(*lpBuffer,*nSize.LONG)
		dbg("GetComputerName")
		Protected L = Len(ComputerName)
		If *nSize\l < L+1
			; If the buffer is too small, the function fails and GetLastError returns ERROR_BUFFER_OVERFLOW.
			; The lpnSize parameter specifies the size of the buffer required, including the terminating null character.
			*nSize\l = L+1
			SetLastError_(#ERROR_BUFFER_OVERFLOW)
			ProcedureReturn 0
		EndIf
		; On output, the number of TCHARs copied to the destination buffer, not including the terminating null character.
		*nSize\l = L
		PokeS(*lpBuffer,ComputerName)
		SetLastError_(0)
		ProcedureReturn 1
	EndProcedure
	Prototype GetComputerNameEx(NameType,*lpBuffer,*nSize.LONG)
	Global Original_GetComputerNameExW.GetComputerNameEx
	Procedure Detour_GetComputerNameExW(NameType,*lpBuffer,*nSize.LONG)
		dbg("GetComputerNameEx")
		Protected L = Len(ComputerName)
		If *nSize\l < L+1
			; If the buffer is too small, the function fails and GetLastError returns ERROR_BUFFER_OVERFLOW.
			; The lpnSize parameter specifies the size of the buffer required, including the terminating null character.
			*nSize\l = L+1
			SetLastError_(#ERROR_BUFFER_OVERFLOW)
			ProcedureReturn 0
		EndIf
		; On output, the number of TCHARs copied to the destination buffer, not including the terminating null character.
		*nSize\l = L
		PokeS(*lpBuffer,ComputerName)
		SetLastError_(0)
		ProcedureReturn 1
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
;{ LogonUser
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-logonuserw
CompilerIf #FakeLogonUser
	Prototype LogonUser(*lpszUsername,*lpszDomain,*lpszPassword,dwLogonType.l,dwLogonProvider.l,*phToken)
	Global Original_LogonUserW.LogonUser
	Procedure Detour_LogonUserW(*lpszUsername,*lpszDomain,*lpszPassword,dwLogonType.l,dwLogonProvider.l,*phToken)
		Protected Result
		dbg("LogonUser")
		Result = Original_LogonUserW(*lpszUsername,*lpszDomain,*lpszPassword,dwLogonType,dwLogonProvider,*phToken)
		SetLastError_(#ERROR_ACCOUNT_RESTRICTION)
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
;{ NetUserGetInfo
; https://learn.microsoft.com/en-us/windows/win32/api/lmaccess/nf-lmaccess-netusergetinfo
; https://learn.microsoft.com/en-us/windows/win32/api/lmaccess/ns-lmaccess-user_info_1
CompilerIf #FakeNetUserGetInfo
	Structure USER_INFO_1
		*usri1_name
		*usri1_password
		usri1_password_age.l
		usri1_priv.l
		*usri1_home_dir
		*usri1_comment
		usri1_flags.l
		*usri1_script_path
	EndStructure
	Prototype NetUserGetInfo(*servername,*username,level.l,*bufptr)
	Global Original_NetUserGetInfo.NetUserGetInfo
	Procedure Detour_NetUserGetInfo(*servername,*username,level.l,*bufptr.USER_INFO_1)
		Protected Result
		dbg("NetUserGetInfo: "+PeekSZ(*servername)+" / "+PeekSZ(*username))
		Result = Original_NetUserGetInfo(*servername,*username,level,*bufptr)
		If level=1 And Result=0
			*bufptr\usri1_password_age = 0
		EndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
;{ GetVolumeInformation
; https://learn.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-getvolumeinformationw
CompilerIf #FakeGetVolumeInformation
	Prototype GetVolumeInformation(*lpRootPathName,*lpVolumeNameBuffer,nVolumeNameSize.l,*lpVolumeSerialNumber,*lpMaximumComponentLength.LONG,*lpFileSystemFlags.LONG,*lpFileSystemNameBuffer,nFileSystemNameSize.l)
	Global Original_GetVolumeInformationW.GetVolumeInformation
	Procedure Detour_GetVolumeInformationW(*lpRootPathName,*lpVolumeNameBuffer,nVolumeNameSize.l,*lpVolumeSerialNumber,*lpMaximumComponentLength.LONG,*lpFileSystemFlags.LONG,*lpFileSystemNameBuffer,nFileSystemNameSize.l)
		Protected Result
		If *lpVolumeSerialNumber
			dbg("GetVolumeInformation: get VolumeSerialNumber")
			ProcedureReturn #False
		EndIf
		dbg("GetVolumeInformation")
		Result = Original_GetVolumeInformationW(*lpRootPathName,*lpVolumeNameBuffer,nVolumeNameSize,*lpVolumeSerialNumber,*lpMaximumComponentLength,*lpFileSystemFlags,*lpFileSystemNameBuffer,nFileSystemNameSize)
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
;{ IsOS
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-isos
CompilerIf #FakeIsOS
	#OS_DOMAINMEMBER = 28
	Prototype IsOS(dwOS.l)
	Global Original_IsOS.IsOS
	Procedure Detour_IsOS(dwOS.l)
		Protected Result
		dbg("IsOS")
		If dwOS = #OS_DOMAINMEMBER
			ProcedureReturn #False
		EndIf
		ProcedureReturn Original_IsOS(dwOS)
	EndProcedure
CompilerEndIf
;}
;;======================================================================================================================
;{ Переменные
Structure VARDATA
	n.s
	v.s
EndStructure
Global Dim Vars.VARDATA(0), nVars
Procedure.i FindVar(Name.s)
	CharLower_(@Name)
	Protected i
	For i=1 To nVars
		If Vars(i)\n = Name
			ProcedureReturn i
		EndIf
	Next
	ProcedureReturn 0
EndProcedure
Procedure.s GetVar(Name.s)
	CharLower_(@Name)
	Protected i
	For i=1 To nVars
		If Vars(i)\n = Name
			ProcedureReturn Vars(i)\v
		EndIf
	Next
	ProcedureReturn ""
EndProcedure
Procedure.s ExpVar(Str.s)
	Protected PNext=1, PVar1, PVar2, Var.s, IVar
	PVar1 = FindString(Str,"<",PNext)
	While PVar1
		PVar2 = FindString(Str,">",PVar1)
		If PVar2 = 0 ; завершённых переменных больше нет
			Break
		EndIf
		Var = Mid(Str,PVar1+1,PVar2-PVar1-1)
		IVar = FindVar(Var)
		If IVar
			Var = Vars(IVar)\v
			Str = Left(Str,PVar1-1) + Var + Mid(Str,PVar2+1)
			PNext = PVar1+Len(Var)
		Else ; Удалить неправильную переменную или оставить как есть?
			PNext = PVar2+1
		EndIf
		PVar1 = FindString(Str,"<",PNext)
	Wend
	ProcedureReturn Str
EndProcedure
Procedure SetVar(Name.s,Val.s)
	CharLower_(@Name)
	Protected i
	For i=1 To nVars
		If Vars(i)\n = Name
			Break
		EndIf
	Next
	; После завершения цикла for, i будет равен либо индексу найденного значения, либо на единицу больше nVars
	If i > nVars
		nVars = i
		ReDim Vars(nVars)
	EndIf
	Vars(i)\n = Name
	Vars(i)\v = ExpVar(ExpandEnvironmentStrings(Val))
EndProcedure
;}
;;======================================================================================================================
Procedure _OpenPreference(Prefs.s)
	If OpenPreferences(Prefs,#PB_Preference_NoSpace) = 0
		MessageBox_(0,"Config file not found!","PureChrome",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		ProcedureReturn 0
	EndIf
	If PreferenceGroup("General") = 0
		MessageBox_(0,"Section [General] not found!","PureChrome",#MB_ICONERROR)
		TerminateProcess_(GetCurrentProcess_(),0)
		ProcedureReturn 0
	EndIf
	ProcedureReturn 1
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Procedure CheckProgram()
	Protected k.s, v.s
	
	BrowserProductName = GetFileVersionInfo(PrgPath,"ProductName")
	BrowserInternalName = GetFileVersionInfo(PrgPath,"InternalName")
	BrowserOriginalFilename = GetFileVersionInfo(PrgPath,"OriginalFilename")
	BrowserVersion = GetFileVersionInfo(PrgPath,"ProductVersion")
	
	;dbg("ProductName: "+ProductName)
	
	PreferenceFile = PrgDir+"portable.ini"
	_OpenPreference(PreferenceFile) ; текущая секция будет General
	Protected ValidateProgram = ReadPreferenceInteger("ValidateProgram",1)
	
; 	If PreferenceGroup("Browser")
; 		; Это инсталлятор если:
; 		; - Имя программы есть в секции [Browser] в списке InstallerExe
; 		; Установить IsInstaller = #True
; 		IsInstaller = FindInList(ReadPreferenceString("InstallerExe",""),PrgName)
; 		
; 		; Это браузер если:
; 		; - В секции [Browser] имя программы есть в списке BrowserExe
; 		; Установить IsBrowser = #True
; 		IsBrowser = FindInList(ReadPreferenceString("BrowserExe",""),PrgName)
; 		BrowserDll = ReadPreferenceString("BrowserDll","chrome.dll")
; 	EndIf
	
	;;------------------------------------------------------------------------------------------------------------------
	Protected InvalidProgram = 1
	If ValidateProgram
		If PreferenceGroup("ValidateProgram") = 0
			MessageBox_(0,"Section [ValidateProgram] not found!","PurePortable",#MB_ICONERROR)
			TerminateProcess_(GetCurrentProcess_(),0)
			ProcedureReturn #INVALID_PROGRAM
		EndIf
		; Текущая секция ValidateProgram
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
				Default ; остальные это ресурсы VersionInfo
					If CompareWithList(GetFileVersionInfo(PrgPath,k),v,1)
						InvalidProgram = 0
						Break
					EndIf
			EndSelect
		Wend
		If InvalidProgram ; если не выполнилось ни одного условия
			MessageBox_(0,"Invalid program "+PrgName+"!","PureChrome",#MB_ICONERROR)
			TerminateProcess_(GetCurrentProcess_(),0)
			ProcedureReturn #INVALID_PROGRAM
		EndIf
	EndIf
	ClosePreferences()
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexa
;DeclareImport(kernel32,_GetModuleHandleExW@4,GetModuleHandleExW,GetModuleHandleEx_(dwFlags,lpModuleName,phModule))
Procedure AttachProcedure()
	Protected k.s, v.s, p.s, n, i
	Protected MainParameters.s, AddParameter.s
	Protected Program.s, Parameters.s
	
	;;------------------------------------------------------------------------------------------------------------------
	_OpenPreference(PreferenceFile) ; Текущая секция General
	RegistryPermit = ReadPreferenceInteger("Registry",1)
	SpecialFoldersPermit = ReadPreferenceInteger("SpecialFolders",1)
	ComputerName = ReadPreferenceString("ComputerName","Portable")
		
	If PreferenceGroup("Debug")
		DbgRegMode = ReadPreferenceInteger("Registry",0)
		DbgExecMode = ReadPreferenceInteger("Execute",0)
		DbgCreateProcess = ReadPreferenceInteger("CreateProcess",0)
		DbgCreateProcessLog = ReadPreferenceInteger("CreateProcessLog",0)
	EndIf
	;{ Переменные
	If PreferenceGroup("Paths")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			k = PreferenceKeyName()
			v = ExpVar(ExpandEnvironmentStrings(PreferenceKeyValue()))
			SetVar(k,NormalizePPath(v))
		Wend
	EndIf
	;}
	;{ Папки
	i = FindVar("AppData")
	If i
		AppDataDir = Vars(i)\v
	Else
		AppDataDir = NormalizePPath(".\AppData.Roaming")
	EndIf
	i = FindVar("LocalAppData")
	If i
		LocalAppDataDir = Vars(i)\v
	Else
		LocalAppDataDir = NormalizePPath(".\AppData.Local")
	EndIf
	;ProfileRedir = AppDataDir
	AppDataRedir = AppDataDir
	LocalAppDataRedir = LocalAppDataDir
	LocalLowAppDataRedir = LocalAppDataDir
	;CommonAppDataRedir = PrgDirN
	CreatePath(AppDataDir)
	CreatePath(LocalAppDataDir)
	;}
	;{ Реестр
	If RegistryPermit
		ReadCfg()
		AddKeyData("Software\Google","Google")
		AddKeyData("Software\Yandex","Yandex")
		If PreferenceGroup("Registry")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				k = PreferenceKeyName()
				v = PreferenceKeyValueQ()
				If v
					AddKeyData(k,v)
				ElseIf LCase(Left(k,9))="software\" ; Специальная форма вида "Software\MyCompany" без значения или с пустым значением
					v = Mid(k,10) ; все подстановки будут на этот путь
					i = 0
					Repeat
						k = Mid(k,i+1)
						AddKeyData(k,v)
						i = FindString(k,"\")
					Until i=0
				Else ; используем as is
					AddKeyData(k,k)
				EndIf
			Wend
		EndIf
	EndIf
	;}
	
	;;------------------------------------------------------------------------------------------------------------------
	;DisableThreadLibraryCalls_(DllInstance) ; нафига???
	;Global hModule
	;GetModuleHandleEx_(#GET_MODULE_HANDLE_EX_FLAG_PIN,@DllPath,@hModule)
	;;------------------------------------------------------------------------------------------------------------------
	
	; Дополнительные переменные среды
	SetEnvironmentVariable("BrowserDir",PrgDirN)
	SetEnvironmentVariable("BrowserVersion",BrowserVersion)
		
	;;------------------------------------------------------------------------------------------------------------------
	; Обработка командной строки
	CmdLine = PeekS(GetCommandLine_())
	Program = CmdLine
	Parameters = PeekS(PathGetArgs_(@CmdLine))
	PathRemoveArgs_(@Program)
	;PathUnquoteSpaces_(@Program)
	
	; TODO: для точности надо проверять все параметры ком.строки, мало ли какой url будет передан.
	; Как альтернативный вариант, проверять только первый параметр, который должен быть --type=
	BrowserSecondary = FindString(CmdLine,"--type=")
	
	dbg("CommandLine: «"+CmdLine+"»")
	If Not BrowserSecondary ; FirstProcess
		; Добавление в конец командной строки параметров для портабелизации
		;If Not UseAppDataDir
		;	MainParameters + ~" --user-data-dir=\""+DataDir+~"\" --disk-cache-dir=\""+CacheDir+~"\""
		;EndIf
		If PreferenceGroup("Parameters")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				k = PreferenceKeyName()
				If k
					AddParameter + " --"+k
					v = PreferenceKeyValue()
					p = Trim(v,Chr(34))
					If p<>v Or FindString(p," ")
						p = Chr(34)+p+Chr(34)
					EndIf
					If p
						AddParameter + "=" + p
					EndIf
				EndIf
			Wend
			MainParameters + AddParameter
		EndIf
		dbg("First: «"+CmdLine+"»")
		dbg("  "+MainParameters)
		dbg("  "+Program+" :: "+Parameters)
		CmdLine = Program + " " + Parameters + " " + MainParameters
		;dbg("  "+Program + " " + CmdLine + " " + MainParameters)
		dbg("  "+CmdLine)
	Else
		dbg("Second: «"+CmdLine+"»")
	EndIf
	
	;;------------------------------------------------------------------------------------------------------------------
	; Хуки
	
	LoadLibrary_(@"propsys.dll")
	MH_HookApi(propsys,PSStringFromPropertyKey)
	
	MH_HookApi(kernel32,UpdateProcThreadAttribute)
	
	MH_HookApi(kernel32,CreateProcessW)
	MH_HookApi(kernel32,GetCommandLineW)
	
	;LoadLibrary_(@"crypt32.dll")
	MH_HookApi(crypt32,CryptProtectData)
	MH_HookApi(crypt32,CryptUnprotectData)
	
	CompilerIf #FakeGetComputerName
		MH_HookApi(kernel32,GetComputerNameW)
		MH_HookApi(kernel32,GetComputerNameExW)
	CompilerEndIf
	CompilerIf #FakeGetVolumeInformation
		MH_HookApi(kernel32,GetVolumeInformationW)
	CompilerEndIf
	CompilerIf #FakeLogonUser
		MH_HookApi(advapi32,LogonUserW)
	CompilerEndIf
	CompilerIf #FakeNetUserGetInfo
		LoadLibrary_(@"netapi32.dll")
		MH_HookApi(netapi32,NetUserGetInfo)
	CompilerEndIf
	CompilerIf #FakeIsOS
		LoadLibrary_(@"shlwapi.dll")
		MH_HookApi(shlwapi,IsOS)
	CompilerEndIf
	
	;;------------------------------------------------------------------------------------------------------------------
	If FirstProcess And PreferenceGroup("Execute.Start")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			RunFrom(PreferenceKeyName(),PreferenceKeyValueQ())
		Wend
	EndIf
	;;------------------------------------------------------------------------------------------------------------------
	
	ClosePreferences()
EndProcedure

DeclareImport(crypt32,_CryptProtectData@28,CryptProtectData,_CryptProtectData(*pDataIn,*ppszDataDescr,*pOptionalEntropy,*pvReserved,*pPromptStruct,dwFlags.l,*pDataOut))
DeclareImport(crypt32,_CryptUnprotectData@28,CryptUnprotectData,_CryptUnprotectData(*pDataIn,*ppszDataDescr,*pOptionalEntropy,*pvReserved,*pPromptStruct,dwFlags.l,*pDataOut))
If 0 ; для статической линковки на всякий случай
	_CryptProtectData(0,0,0,0,0,0,0)
	_CryptUnprotectData(0,0,0,0,0,0,0)
EndIf
;;----------------------------------------------------------------------------------------------------------------------
Procedure DetachProcedure()
	If LastProcess And RegistryPermit
		WriteCfg()
	EndIf
	If OpenPreferences(PreferenceFile) = 0
		ProcedureReturn
	EndIf
	DbgClnMode = 0
	If LastProcess And PreferenceGroup("Debug")
		DbgClnMode = ReadPreferenceInteger("Cleanup",0)
	EndIf
	If LastProcess And PreferenceGroup("Cleanup")
		Protected CleanupItem.s
		DbgCln("CleanupDirectory: "+PrgDirN)
		If PreferenceGroup("Cleanup")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				CleanupItem = NormalizePPath(PreferenceKeyName())
				DbgCln("Cleanup: "+CleanupItem)
				AddCleanItem(CleanupItem)
			Wend
		EndIf
	EndIf
	If LastProcess And PreferenceGroup("Execute.End")
		ExaminePreferenceKeys()
		While NextPreferenceKey()
			RunFrom(PreferenceKeyName(),PreferenceKeyValueQ())
		Wend			
	EndIf
	ClosePreferences()
EndProcedure
;;======================================================================================================================
Procedure.s NormalizePPath(Path.s="") ; Преобразование относительных путей
	Path = ExpVar(ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34))))
	If Path="" Or Path="."
		Path = PrgDirN
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = PrgDir+Path
	EndIf
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================
Procedure.i FindInList(Text.s,Find.s)
	ProcedureReturn FindString(LCase("|"+Text+"|"),LCase("|"+Find+"|"))
EndProcedure
;;======================================================================================================================
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
Procedure.s ReadPreferenceStringQ(Key.s,DefaultValue.s="")
	ProcedureReturn Trim(ReadPreferenceString(Key,DefaultValue),Chr(34))
EndProcedure
;;======================================================================================================================
Procedure.s PreferenceKeyValueQ()
	ProcedureReturn Trim(PreferenceKeyValue(),Chr(34))
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 663
; FirstLine = 179
; Folding = Q9VLEWV---
; Markers = 818
; Optimizer
; EnableThread
; Executable = 400.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.30.1
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.30.1
; VersionField6 = PurePortableExpert
; VersionField7 = 400.dll
; VersionField9 = (c) Smitis, 2017-2026