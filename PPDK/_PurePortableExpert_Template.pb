;;======================================================================================================================
; PurePortable for XXX
;;======================================================================================================================
; Особенности портабелизации:
;
;;======================================================================================================================
; История изменений:
;
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.0
;RES_DESCRIPTION PurePortableExpert
;RES_COPYRIGHT (c) Smitis, 2017-2026
;RES_INTERNALNAME 411.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS "..\..\Programs\proxy32.dll"
;PP_X64_COPYAS "..\..\Programs\proxy64.dll"
;PP_CLEAN 2

EnableExplicit
IncludePath "..\PPDK\Lib" ; Для доступа к файлам рядом с исходником можно использовать #PB_Compiler_FilePath
XIncludeFile "PurePortableCustom.pbi"

; Для подменяемой dll для объявление экспорта прокси-dll
; Поддерживаемые dll: avifil32 dbghelp ddraw dnsapi dwmapi iphlpapi ktmw32 mpr msacm32 mscms msi msvfw32
; opengl32 secur32 shfolder urlmon userenv uxtheme version wer winhttp wininet winmm winspool wintrust wtsapi32
; advapi32 comdlg32 kernel32 shell32 user32: с патчем исполняемого файла
; msimg32 с ограничениями (AlphaBlend) или правкой таблицы экспорта
#PROXY_DLL = "version"
;#PROXY_DLL_COMPATIBILITY = 7 ; Совместимость: 0 - по умолчанию, 5 - XP, 7 - Windows 7, 10 - Windows 10

; Если эта константа определена и строка не пустая, константа используется как имя файла конфигурации.
; Если эта константа определена и строка пустая, имя будет то же, что и у программы плюс расширение, заданное константой #CONFIG_FILEEXT.
; Если эта константа не определена, имя файла конфигурации надо задавать вручную (полный путь к файлу).
#CONFIG_FILENAME = "PurePortable"
;#CONFIG_INITIAL = #CONFIG_FILENAME+"-Init"
;#PREFERENCES_FILENAME = #CONFIG_FILENAME ; Имя файла конфигурации PurePortable

;;----------------------------------------------------------------------------------------------------------------------
#PORTABLE = 0 ; Управление портабелизацией: 0 - прозрачный режим, 1 - перехват
#PORTABLE_REGISTRY = 1 ; Перехват функций для работы с реестром
;{ Управление хуками PORTABLE_REGISTRY
#DETOUR_REG_SHLWAPI = 0 ; Перехват функций для работы с реестром из shlwapi
#DETOUR_REG_TRANSACTED = 0
;}
#PORTABLE_SPECIAL_FOLDERS = 1 ; Перехват функций для работы со специальными папками
;{ Управление хуками PORTABLE_SPECIAL_FOLDERS
#DETOUR_SHFOLDER = 0 ; Перехват функций из shfolder.dll
#DETOUR_USERENV = 0 ; Перехват функций из userenv.dll
;}
#PORTABLE_ENVIRONMENT_VARIABLES = 0
#PORTABLE_ENVIRONMENT_VARIABLES_CRT = 0
;{ Управление хуками PORTABLE_ENVIRONMENT_VARIABLES
#DETOUR_ENVIRONMENTVARIABLE = 1
#DETOUR_ENVIRONMENTSTRINGS = 0
#DETOUR_EXPANDENVIRONMENTSTRINGS = 0
#DETOUR_ENVIRONMENT_CRT = "" ; msvcrt ucrtbase
;}
#PORTABLE_PROFILE_STRINGS = 0
;{ Управление хуками PORTABLE_PROFILE_STRINGS
#PROFILE_STRINGS_FILENAME = "PurePortable"
#DETOUR_PRIVATEPROFILESTRING = 1
#DETOUR_PROFILESTRING = 1
;}
#PORTABLE_CBT_HOOK = 0 ; Хук для отслеживания закрытия окон для сохранение конфигурации
#PORTABLE_ENTRYPOINT = 0
#PORTABLE_USE_MUTEX = 0

#PORTABLE_CLEANUP = 0

#PORTABLE_REG_ARRAY = 0

;;----------------------------------------------------------------------------------------------------------------------
;{ Мониторинг
#DBG_REGISTRY = 0
#DBG_SPECIAL_FOLDERS = 0
#DBG_ENVIRONMENT_VARIABLES = 0 ; 1 - только переопределяемые, 2 - все
#DBG_PROFILE_STRINGS = 0
#DBG_CBT_HOOK = 0
#DBG_MIN_HOOK = 0
#DBG_IAT_HOOK = 0
#DBG_PROXY_DLL = 0
#DBG_CLEANUP = 0
#DBG_EXECUTEDLL = 0
#DBG_ANY = 0
;}
;{ Мониторинг некоторых вызовов WinApi
#DBGX_EXECUTE = 0 ; 1 - ShellExecute/CreateProcess, 2 - CreateProcess
#DBGX_LOAD_LIBRARY = 0 ; 1 - всё, 2 - без GetProcAddress
#DBGX_FILE_OPERATIONS = 0
#DBGX_PROFILE_STRINGS = 0
;}
;;----------------------------------------------------------------------------------------------------------------------
;{ Блокировки
#BLOCK_WININET = 0 ; wininet.dll
#BLOCK_WINHTTP = 0 ; winhttp.dll
#BLOCK_WINSOCKS = 0
#DBG_BLOCK_INTERNET = 0
#BLOCK_CONSOLE = 0
#DBG_BLOCK_CONSOLE = 0
#BLOCK_RECENT_DOCS = 0
#DBG_BLOCK_RECENT_DOCS = 0
;}
;{ Некоторые дополнительные процедуры
#PROC_GETVERSIONINFO = 1 ; Получение информации о файле
#PROC_CORRECTPATH = 0
#PROC_CORRECTCFGPATH = 0
#PROC_ICFG = 0 ; макросы и процедуры для работы с массивами виртуального реестра
;#PROC_GUID2S = 0 ; Преобразование GUID/CLSID в строку вида {4AABE186-2666-4663-9E3E-5DFD6EAAAB60}
;}
#PORTABLE_CHECK_PROGRAM = 1 ; Использовать CheckProgram
#INCLUDE_MIN_HOOK = 0 ; Принудительное включение MinHook
#INCLUDE_IAT_HOOK = 0 ; Принудительное включение IatHook
XIncludeFile "PurePortable.pbi"
;;======================================================================================================================
;{ SPECIAL FOLDERS
CompilerIf #PORTABLE_SPECIAL_FOLDERS
	Procedure.s CheckKFID(kfid)
; 		If CompareMemory(kfid,?FOLDERID_ProgramFiles,16)
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
CompilerIf #PORTABLE_REGISTRY
	; Key будет передан в нижнем регистре! Возвращаемое значение также должно быть в нижнем регистре!
	; Если первым символом будет символ «?», такой ключ не будет сохранён.
	CompilerIf #PORTABLE_REG_ARRAY
		; Для добавления ключей используется функция AddCheckedKey.
		; Но при необходимости можно использовать прямое сравнение.
		Procedure.s CheckKey(hKey.l,Key.s)
			ProcedureReturn CheckKeyArray(hKey,Key)
		EndProcedure
	CompilerElse
		Procedure.s CheckKey(hKey.l,Key.s)
			;;---------------         1         2         3         4         5         6         7         8         9
			;;---------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			If Left(Key,24)="software\company\program"
				ProcedureReturn Mid(Key,10)
			EndIf
			;;---------------         1         2         3         4         5         6         7         8         9
			;;---------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			If Left(Key,15)="company\program"
				ProcedureReturn Key
			EndIf
			; Разные мусорные ключи можно перехватить, но не сохранять.
			;If Left(Key,15)="software\python" : ProcedureReturn "?"+Key : EndIf
			;If Left(Key,18)="software\qtproject" : ProcedureReturn "?"+Key : EndIf
			;If Left(Key,18)="software\trolltech" : ProcedureReturn "?"+Key : EndIf
			;If Left(Key,18)="software\asprotect" : ProcedureReturn "?"+Key : EndIf
			;If Left(Key,18)="software\eurekalab" : ProcedureReturn "?"+Key : EndIf
			;If Left(Key,20)="software\embarcadero" Or Left(Key,16)="software\borland" Or Left(Key,17)="software\codegear" : ProcedureReturn "?"+Key : EndIf
			ProcedureReturn ""
		EndProcedure
	CompilerEndIf
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
CompilerIf #PORTABLE_CBT_HOOK
	; Заголовок передаётся в нижнем регистре не более 64 символов.
	; Процедура должна возвратить:
	; #PORTABLE_CBTR_EXIT если это закрытие главного окна программы. В этом случае принудительно будет выполнена процедура DetachProcess,
	; при этом при реальном выполнении DetachProcess никаких действий повторно произведено не будет.
	; #PORTABLE_CBTR_SAVECFG если требуется только сохранение реестра, например, при закрытии окна настроек.
	; #PORTABLE_CBTR_NONE (0) если никаких действий не требуется.
	Procedure CheckTitle(nCode,Title.s)
		;;-------------------         1         2         3         4         5         6         7         8         9
		;;-------------------123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		If Left(Title,08) = "settings"
			ProcedureReturn #PORTABLE_CBTR_SAVECFG ; только сохранение реестра
		EndIf
		If Title = "qtpowerdummywindow" ; QT5
			ProcedureReturn #PORTABLE_CBTR_EXIT ; завершение работы программы как при DetachProcess
		EndIf
		If Title = "cicmarshalwnd" ; QT5
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
; Если установленна константа #PORTABLE_CHECK_PROGRAM=1 и описана эта процедура, она должна проверить, к той ли программе приатачена dll.
; В этом случае нет необходимости делать проверку в AttachProcedure.
; Процедура должна вернуть #INVALID_PROGRAM (1), если проверка не пройдена или #VALID_PROGRAM (0), если проверка пройдена.
; По умолчанию возвращается #VALID_PROGRAM (0).
; При #PORTABLE_CHECK_PROGRAM=0 (по умолчанию, для совместимости) эта проверка должна осуществляться из AttachProcedure.
Procedure CheckProgram()
	; Первый параметр макросов:
	; #VALIDATE_PROGRAM_OFF (0) - Не проверять.
	; #VALIDATE_PROGRAM_TERMINATE (1) - Проверить, если программа не та, завершить неправильный процесс.
	; #VALIDATE_PROGRAM_CONTINUE (2) - Проверить, если программа не та, не проводить инициализацию хуков. Программа запустится как обычно.
	; Третий параметр макросов:
	; #COMPARE_WITH_EXACT (0) - Точное сравнение.
	; #COMPARE_WITH_BEGIN (1) - Должно совпасть начало (по умолчанию).
	; #COMPARE_WITH_END (-1) - Должен совпасть конец.
	; Макросы ValidateProgram* при первом параметре = #VALIDATE_PROGRAM_CONTINUE (2) вставят ProcedureReturn #INVALID_PROGRAM автоматически.
	; Регистр символов при сравнении макросами игнорируется.
	;ValidateProgram(#VALIDATE_PROGRAM_TERMINATE,"InternalName","program",#COMPARE_WITH_BEGIN) ; Проверка, та ли программа запущена
	;ValidateProgram(#VALIDATE_PROGRAM_TERMINATE,"ProductName","program",#COMPARE_WITH_BEGIN) ; Проверка, та ли программа запущена
	;ValidateProgramName(#VALIDATE_PROGRAM_TERMINATE,"ProgramName",#COMPARE_WITH_BEGIN) ; Проверка по имени, та ли программа запущена
EndProcedure
;;======================================================================================================================
; Действия выполняемые при запуске программы.
; Для rundll32 не выполняется.
Procedure AttachProcedure()
	;Protected FileInfo.s = LCase(GetFileVersionInfo(PrgPath,"InternalName"))
	;Protected FileInfo.s = LCase(GetFilePart(GetFileVersionInfo(PrgPath,"OriginalFilename"),#PB_FileSystem_NoExtension))

	;{ Папки
	CompilerIf #PORTABLE_SPECIAL_FOLDERS Or #PORTABLE_ENVIRONMENT_VARIABLES
		;ProfileRedir = NormalizePath(PrgDir+"..")
		ProfileRedir = PrgDirN
		AppDataRedir = PrgDirN
		LocalAppDataRedir = PrgDirN
		;LocalLowAppDataRedir = PrgDirN
		CommonAppDataRedir = PrgDirN
		;DocumentsRedir = PrgDirN+"\Documents"
		;PublicRedir = PrgDirN
		;CommonDocumentsRedir = DocumentsRedir
		;CreatePath(DocumentsRedir)
	CompilerEndIf
	;}

	;{ Переменные среды
	;SetEnvironmentVariable("APPDATA",PrgDirN)
	;SetEnvironmentVariable("LOCALAPPDATA",PrgDirN)
	;SetEnvironmentVariable("USERPROFILE",PrgDirN)
	;SetEnvironmentVariable("ALLUSERSPROFILE",PrgDirN)
	;SetEnvironmentVariable("PROGRAMDATA",PrgDirN)
	;SetEnvironmentVariable("PUBLIC",PrgDirN)
	;SetEnvironmentVariable("HOME",PrgDirN)
	;SetEnvironmentVariable("HOMEDRIVE",Left(PrgDirN,2))
	;SetEnvironmentVariable("HOMEPATH",Mid(PrgDirN,3))
	;SetEnvironmentVariable("TEMP",PrgDir+".temp")
	;SetEnvironmentVariable("TMP",PrgDir+".temp")
	;SetEnvironmentVariable("TMPDIR",PrgDir+".temp")
	;SetEnvironmentVariable("PROGRAMDIR",PrgDirN)
	;}

	;{ Реестр
	CompilerIf #PORTABLE_REGISTRY
		;ConfigFile = PrgDir+GetFilePart(GetFileVersionInfo(PrgPath,"InternalName"),#PB_FileSystem_NoExtension)+#CONFIG_FILEEXT
		ReadCfg()

		; Коррекция путей
		;Protected SettingsKey.s = "programs\settings"
		;Protected NewPath.s
		;NewPath = GetCfgS(SettingsKey,"lastpath")
		;If NewPath
		;	CorrectPath(NewPath,PrgDirN,#CORRECTPATH_FROM_DEEP|#CORRECTPATH_FORWARD_SLASH)
		;EndIf
		; Для использования CorrectCfgPath установить #PROC_CORRECTCFGPATH=1
		;CorrectCfgPath(SettingsKey,"lastdatabasepath",PrgDirN,#CORRECTPATH_FORWARD_SLASH)
	CompilerEndIf
	;}

EndProcedure

;;======================================================================================================================
; Действия выполняемые при завершении работы программы.
; Процедура должна вернуть 1 если не требуется выполнение процедуры завершения (снятие хуков, выполнение очистки и т.п.).
; Для rundll32 не выполняется.
Procedure DetachProcedure()
	;{ Сохранение реестра
	CompilerIf #PORTABLE_REGISTRY
		WriteCfg()
	CompilerEndIf
	;}
	;{ Удаление ненужных файлов и папок.
	; Для работы необходимо установить #PORTABLE_CLEANUP=1
	; Если процессов было запущено несколько, удаление файлов и папок будет выполнено только при завершении последнего процесса.
	; Команда Clean добавляет файл или папку в список.
	; Относительные пути рассматриваются относительно папки программы.
	;Clean(AppDataRedir+".\NVIDIA")
	;Clean(AppDataRedir+".\Microsoft")
	;}
EndProcedure

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 152
; FirstLine = 93
; Folding = 15LOy
; Markers = 109
; Optimizer
; EnableThread
; Executable = 400.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.0
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.0
; VersionField6 = PurePortableExpert
; VersionField7 = 411.dll
; VersionField9 = (c) Smitis, 2017-2026