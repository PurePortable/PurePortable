;;======================================================================================================================

CompilerIf Not Defined(MAX_PATH_EXTEND,#PB_Constant) : #MAX_PATH_EXTEND = 32767 : CompilerEndIf

Structure PPDATA
	Version.i
	SubVersion.i
	Prefs.s ; путь к файлу конфигурации PurePortableSimple (в том числе выбраном в MultiConfig)
EndStructure

Prototype PurePortableExtension(*PPD.PPDATA) ; прототип экспортируемой функции

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 7
; EnableThread
; DisableDebugger
; EnableExeConstant