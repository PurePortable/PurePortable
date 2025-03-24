
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

Structure IMinHook
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
	MH_StatusToString.MH_StatusToString
	_MH_HookApi._MH_HookApi
	_MH_Error._MH_Error
EndStructure

CompilerIf Not Defined(IMINHOOK_INIT,#PB_Constant) : #IMINHOOK_INIT = 0 : CompilerEndIf

CompilerIf #IMINHOOK_INIT
	
	Global IMinHook.IMinHook
	IMinHook\MH_Initialize = @MH_Initialize()
	IMinHook\MH_CreateHook = @MH_CreateHook()
	IMinHook\MH_CreateHookApi = @MH_CreateHookApi()
	IMinHook\MH_CreateHookApiEx = @MH_CreateHookApiEx()
	IMinHook\MH_EnableHook = @MH_EnableHook()
	IMinHook\MH_DisableHook = @MH_DisableHook()
	IMinHook\MH_RemoveHook = @MH_RemoveHook()
	IMinHook\MH_QueueEnableHook = @MH_QueueEnableHook()
	IMinHook\MH_QueueDisableHook = @MH_QueueDisableHook()
	IMinHook\MH_ApplyQueued = @MH_ApplyQueued()
	IMinHook\MH_Uninitialize = @MH_Uninitialize()
	IMinHook\MH_StatusToString = @MH_StatusToString()
	IMinHook\_MH_HookApi = @_MH_HookApi()
	IMinHook\_MH_Error = @_MH_Error()
	
	DataSection
		IMinHook:
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			!DD _MH_Initialize@0
			!DD _MH_CreateHook@12
			!DD _MH_CreateHookApi@16
			!DD _MH_CreateHookApiEx@20
			!DD _MH_EnableHook@4
			!DD _MH_DisableHook@4
			!DD _MH_RemoveHook@4
			!DD _MH_QueueEnableHook@4
			!DD _MH_QueueDisableHook@4
			!DD _MH_ApplyQueued@0
			!DD _MH_Uninitialize@0
			!DD _MH_StatusToString@4
		CompilerElse
			!DQ MH_Initialize
			!DQ MH_CreateHook
			!DQ MH_CreateHookApi
			!DQ MH_CreateHookApiEx
			!DQ MH_EnableHook
			!DQ MH_DisableHook
			!DQ MH_RemoveHook
			!DQ MH_QueueEnableHook
			!DQ MH_QueueDisableHook
			!DQ MH_ApplyQueued
			!DQ MH_Uninitialize
			!DQ MH_StatusToString
		CompilerEndIf
		Data.i @_MH_HookApi()
		Data.i @_MH_Error()
	EndDataSection
	
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 78
; FirstLine = 51
; EnableThread
; DisableDebugger
; EnableExeConstant