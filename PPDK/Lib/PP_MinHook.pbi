;;======================================================================================================================
; Враппер для работы с библиотекой MinHook
;;======================================================================================================================
CompilerIf Not Defined(DBG_MIN_HOOK,#PB_Constant) : #DBG_MIN_HOOK = 0 : CompilerEndIf

#MIN_HOOK = 1

CompilerIf #DBG_MIN_HOOK
	Macro DbgMinHook(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgMinHook(txt) : EndMacro
CompilerEndIf
CompilerIf #DBG_MIN_HOOK Or Defined(MIN_HOOK_ERROR_MODE,#PB_Constant)
	Macro DbgMinHookError(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgMinHookError(txt) : EndMacro
CompilerEndIf

;CompilerIf Not Defined(MIN_HOOK_CHECKRESULT,#PB_Constant) : #MIN_HOOK_CHECKRESULT = 1 : CompilerEndIf
CompilerIf Not Defined(MIN_HOOK_ERROR_MODE,#PB_Constant) : #MIN_HOOK_ERROR_MODE = 2 : CompilerEndIf
;#MIN_HOOK_ERROR_MODE = 2

;;======================================================================================================================
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	#MINHOOKLIB = "minhook\libMinHook.lib"
CompilerElse
	#MINHOOKLIB = "minhook\libMinHook64.lib"
CompilerEndIf
Import #MINHOOKLIB
	MH_Initialize()
	MH_CreateHook(*pTarget,*pDetour,*ppOriginal)
	MH_CreateHookApi(pszModule.p-unicode,pszProcName.p-ascii,*pDetour,*ppOriginal)
	MH_CreateHookApiEx(pszModule.p-unicode,pszProcName.p-ascii,*pDetour,*ppOriginal,*ppTarget)
	MH_EnableHook(*pTarget)
	MH_DisableHook(*pTarget)
	MH_RemoveHook(*pTarget)
	MH_QueueEnableHook(*pTarget)
	MH_QueueDisableHook(*pTarget)
	MH_ApplyQueued()
	MH_Uninitialize()
	MH_StatusToString(Status)
EndImport
Enumeration MINHOOKRESULT -1
	#MH_UNKNOWN ; = -1 ; Unknown error. Should not be returned.
	#MH_OK ; = 0 ; Successful.
	#MH_ERROR_ALREADY_INITIALIZED ; MinHook is already initialized.
	#MH_ERROR_NOT_INITIALIZED ; MinHook is not initialized yet, or already uninitialized.
	#MH_ERROR_ALREADY_CREATED ; The hook for the specified target function is already created.
	#MH_ERROR_NOT_CREATED ; The hook for the specified target function is not created yet.
	#MH_ERROR_ENABLED ; The hook for the specified target function is already enabled.
	#MH_ERROR_DISABLED ; The hook for the specified target function is not enabled yet, or already disabled.
	#MH_ERROR_NOT_EXECUTABLE ; The specified pointer is invalid. It points the address of non-allocated and/or non-executable region.
	#MH_ERROR_UNSUPPORTED_FUNCTION ; The specified target function cannot be hooked.
	#MH_ERROR_MEMORY_ALLOC ; Failed to allocate memory.
	#MH_ERROR_MEMORY_PROTECT ; Failed to change the memory protection.
	#MH_ERROR_MODULE_NOT_FOUND ; The specified module is not loaded.
	#MH_ERROR_FUNCTION_NOT_FOUND ; The specified function is not found.
EndEnumeration

#MH_ALL_HOOKS = 0

;;======================================================================================================================
EnumerationBinary MH_HOOKAPI
	#MH_HOOKAPI_NOCHECKRESULT
	#MH_HOOKAPI_INIT
EndEnumeration

UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro
Macro MH_HookApi(DllName,FuncName,flags=0)
	;CompilerIf Defined(Detour_#FuncName,#PB_Procedure)
	Global Target_#FuncName
	_MH_HookApi(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Detour_#FuncName(),@Original_#FuncName,@Target_#FuncName,flags)
	;CompilerEndIf
EndMacro
Macro MH_HookApiV(DllName,FuncName,DetourProc,VarName,flags=0)
	;CompilerIf Defined(Detour_#DetourProc,#PB_Procedure)
	Global Original_#VarName, Target_#VarName
	_MH_HookApi(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Detour_#DetourProc(),@Original_#VarName,@Target_#VarName,flags)
	;CompilerEndIf
EndMacro
Macro MH_HookApiD(DllName,FuncName,flags=0)
	;CompilerIf Defined(Detour_#FuncName,#PB_Procedure)
	Global Target_#FuncName
	_MH_HookApi(DllName,DoubleQuote#FuncName#DoubleQuote,@Detour_#FuncName(),@Original_#FuncName,@Target_#FuncName,flags)
	;CompilerEndIf
EndMacro
; Macro MH_Enable(FuncName)
; 	MH_EnableHook(Target_#FuncName)
; EndMacro

Procedure.s _MH_Error(ErrorNum)
	Protected ErrorText.s
	Select ErrorNum
		Case #MH_ERROR_ALREADY_INITIALIZED
			ErrorText = " ERROR ALREADY INITIALIZED"
		Case #MH_ERROR_NOT_INITIALIZED
			ErrorText = " ERROR NOT INITIALIZED"
		Case #MH_ERROR_ALREADY_CREATED
			ErrorText = " ERROR ALREADY CREATED"
		Case #MH_ERROR_NOT_CREATED
			ErrorText = " ERROR NOT CREATED"
		Case #MH_ERROR_ENABLED
			ErrorText = " ERROR ENABLED"
		Case #MH_ERROR_DISABLED
			ErrorText = " ERROR DISABLED"
		Case #MH_ERROR_NOT_EXECUTABLE
			ErrorText = " ERROR NOT EXECUTABLE"
		Case #MH_ERROR_UNSUPPORTED_FUNCTION
			ErrorText = " ERROR UNSUPPORTED FUNCTION"
		Case #MH_ERROR_MEMORY_ALLOC
			ErrorText = " ERROR MEMORY ALLOC"
		Case #MH_ERROR_MEMORY_PROTECT
			ErrorText = " ERROR MEMORY PROTECT"
		Case #MH_ERROR_MODULE_NOT_FOUND
			ErrorText = " ERROR MODULE NOT FOUND"
		Case #MH_ERROR_FUNCTION_NOT_FOUND
			ErrorText = " ERROR FUNCTION NOT FOUND"
		Default
			ErrorText = " (UNKNOWN)"
	EndSelect
	ProcedureReturn Str(ErrorNum)+ErrorText
EndProcedure

;{ Procedure _MH_EnableHook(pTarget)
; 	Protected Result = MH_EnableHook(pTarget)
; 	CompilerIf #DBG_MIN_HOOK Or Defined(MIN_HOOK_ERROR_MODE,#PB_Constant)
; 		If Result = #MH_OK
; 			DbgMinHook("MINHOOK ENABLE: OK")
; 		Else
; 			Protected ErrorText.s = _MH_Error(Result)
; 			DbgMinHook("MINHOOK ENABLE: ERROR: "+ErrorText)
; 		EndIf
; 	CompilerEndIf
; 	ProcedureReturn Result
; EndProcedure
;}

Global MinHookErrorMode = #MIN_HOOK_ERROR_MODE

Procedure _MH_HookApi(pszModule.s,pszProcName.s,*pDetour,*ppOriginal,*ppTarget.Integer,flags=0)
	Protected ErrorText.s
	Protected MH_Status = MH_CreateHookApiEx(pszModule,pszProcName,*pDetour,*ppOriginal,*ppTarget)
	If MH_Status = #MH_OK
		DbgMinHook("MINHOOK CREATE: "+pszModule+"."+pszProcName+" OK")
		If flags & #MH_HOOKAPI_INIT
			MH_Status = MH_EnableHook(*ppTarget\i)
			If MH_Status = #MH_OK
				DbgMinHook("MINHOOK ENABLE: "+pszModule+"."+pszProcName+" OK")
			Else
				ErrorText.s = _MH_Error(MH_Status)
				;ErrorText.s = PeekS(MH_StatusToString(MH_Status),#PB_Ascii)
				DbgMinHookError("MINHOOK ENABLE: "+pszModule+"."+pszProcName+" ERROR: "+ErrorText)
				If MinHookErrorMode And (flags & #MH_HOOKAPI_NOCHECKRESULT) = 0
					PPErrorMessage("Error enable hook "+pszModule+"."+pszProcName+#CR$+ErrorText)
					If MinHookErrorMode = 2
						;RaiseError(#ERROR_DLL_INIT_FAILED)
						TerminateProcess_(GetCurrentProcess_(),0)
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		ErrorText.s = _MH_Error(MH_Status)
		;ErrorText.s = PeekS(MH_StatusToString(MH_Status),#PB_Ascii)
		DbgMinHookError("MINHOOK CREATE: "+pszModule+"."+pszProcName+" ERROR: "+ErrorText)
		If (flags & #MH_HOOKAPI_NOCHECKRESULT) = 0
			If MinHookErrorMode
				PPErrorMessage("Error create hook "+pszModule+"."+pszProcName+#CR$+ErrorText)
				If MinHookErrorMode = 2
					;RaiseError(#ERROR_DLL_INIT_FAILED)
					TerminateProcess_(GetCurrentProcess_(),0)
				EndIf
			EndIf
		EndIf
	EndIf
	ProcedureReturn MH_Status
EndProcedure

;;======================================================================================================================
MH_Initialize()
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 5
; Folding = -z
; DisableDebugger
; EnableExeConstant