;;======================================================================================================================

#PP_EXT_ALLOW_UNLOAD = 1 ; Разрешить выгрузку расширения

;;======================================================================================================================

CompilerIf Not Defined(MAX_PATH_EXTEND,#PB_Constant) : #MAX_PATH_EXTEND = 32767 : CompilerEndIf

Prototype MH_Initialize()
Prototype MH_CreateHook(*pTarget,*pDetour,*ppOriginal)
Prototype MH_CreateHookApi(pszModule.p-unicode,pszProcName.p-ascii,*pDetour,*ppOriginal)
Prototype MH_CreateHookApiEx(pszModule.p-unicode,pszProcName.p-ascii,*pDetour,*ppOriginal,*ppTarget)
Prototype MH_EnableHook(*pTarget)
Prototype MH_DisableHook(*pTarget)
Prototype MH_RemoveHook(*pTarget)
Prototype MH_QueueEnableHook(*pTarget)
Prototype MH_QueueDisableHook(*pTarget)
Prototype MH_ApplyQueued()
Prototype MH_Uninitialize()
Prototype MH_StatusToString(Status)
Prototype _MH_HookApi(pszModule.s,pszProcName.s,*pDetour,*ppOriginal,*ppTarget.Integer,flags=0)
Prototype.s _MH_Error(ErrorNum)

Structure MH_DATA
	cbSize.i ; reserved
	MH_Initialize.MH_Initialize
	MH_CreateHook.MH_CreateHook
	MH_CreateHookApi.MH_CreateHookApi
	MH_CreateHookApiEx.MH_CreateHookApiEx
	MH_EnableHook.MH_EnableHook
	MH_DisableHook.MH_DisableHook
	MH_RemoveHook.MH_RemoveHook
	MH_QueueEnableHook.MH_QueueEnableHook
	MH_QueueDisableHook.MH_QueueDisableHook
	MH_ApplyQueued.MH_ApplyQueued
	MH_Uninitialize.MH_Uninitialize
	; функции PP
	_MH_HookApi._MH_HookApi
	_MH_Error._MH_Error
EndStructure

Prototype PP_dbg(txt.s)
Structure PP_PROC
	cbSize.i ; reserved
	dbg.PP_dbg
EndStructure

Structure EXT_DATA
	Version.i
	Reserved.i
	ProcessCnt.i
	AllowDbg.i ; разрешить вывод отладочных сообщений
	*PrgPath ; полный путь к программе
	*DllPath ; полный путь к основной dll
	*PrefsFile ; полный путь к файлу конфигурации PurePortableSimple (в том числе выбранном в MultiConfig)
	*Parameters ; параметры передаваемые через PurePort.ini
	*CallBack ; Передача данных в основную dll
	PP.PP_PROC
	MH.MH_DATA
EndStructure

Prototype PurePortableExtension(*ExtData.EXT_DATA) ; прототип экспортируемой функции

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 54
; FirstLine = 26
; EnableThread
; DisableDebugger
; EnableExeConstant