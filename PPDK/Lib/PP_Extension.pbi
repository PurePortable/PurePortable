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
Prototype MH_HookApi(pszModule.s,pszProcName.s,*pDetour,*ppOriginal,*ppTarget.Integer,flags=0)
Prototype.s MH_Error(ErrorNum)

Structure MH_DATA
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
	MH_HookApi.MH_HookApi
	MH_Error.MH_Error
EndStructure

Structure PP_DATA
	Version.i
	SubVersion.i
	*PrgPath ; полный путь к программе
	*DllPath ; полный путь к основной dll
	*PrefsFile ; полный путь к файлу конфигурации PurePortableSimple (в том числе выбраном в MultiConfig)
EndStructure

Prototype PurePortableExtension(*PPD.PP_DATA) ; прототип экспортируемой функции

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 44
; FirstLine = 12
; EnableThread
; DisableDebugger
; EnableExeConstant