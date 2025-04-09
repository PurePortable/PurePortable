;;======================================================================================================================

#PP_EXT_ALLOW_UNLOAD = 1 ; Разрешить выгрузку расширения

;;======================================================================================================================

CompilerIf Not Defined(MAX_PATH_EXTEND,#PB_Constant) : #MAX_PATH_EXTEND = 32767 : CompilerEndIf

XIncludeFile "PP_HelpfulInterface.pbi"
XIncludeFile "PP_MinHookInterface.pbi"

Structure EXTDATA
	Version.i
	Reserved.i
	ProcessCnt.i
	AllowDbg.i ; разрешить вывод отладочных сообщений
	*PrgPath ; полный путь к программе
	*DllPath ; полный путь к основной dll
	*PrefsFile ; полный путь к файлу конфигурации PurePortableSimple (в том числе выбранном в MultiConfig)
	*CallBack  ; Передача данных в основную dll
	*Reserve ; Для расширения структуры в последующих версиях
	*HF.IHelpful ; Интерфейс к различным функциям
	*MH.IMinHook ; Интерфейс к MinHook
EndStructure

Structure EXTPARAM
	Version.i
	Reserved.i
	*Parameters ; Указатель на строку параметров в секции [Extensions]
EndStructure

Prototype PurePortableExtension(*ExtData.EXTDATA,*ExtParam.EXTPARAM) ; прототип экспортируемой функции

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 31
; EnableThread
; DisableDebugger
; EnableExeConstant