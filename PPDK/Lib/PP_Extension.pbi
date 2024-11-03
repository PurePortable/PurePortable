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
	
Structure PPDATA
	Version.i
	SubVersion.i
	Prefs.s ; путь к файлу конфигурации PurePortableSimple (в том числе выбраном в MultiConfig)
EndStructure

Prototype PurePortableExtension(*PPD.PPDATA) ; прототип экспортируемой функции

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 17
; EnableThread
; DisableDebugger
; EnableExeConstant