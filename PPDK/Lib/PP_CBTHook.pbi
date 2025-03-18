;;======================================================================================================================
CompilerIf Not Defined(DBG_CBT_HOOK,#PB_Constant) : #DBG_CBT_HOOK = 0 : CompilerEndIf


CompilerIf Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_CBT_HOOK_ALWAYS = #DBG_ALWAYS
CompilerElse
	#DBG_CBT_HOOK_ALWAYS = 0
CompilerEndIf

CompilerIf #DBG_CBT_HOOK And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_CBT_HOOK
	Global DbgCbtMode = #DBG_CBT_HOOK
	Procedure DbgCbt(txt.s)
		If DbgCbtMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgCbt(txt) : EndMacro
CompilerEndIf

Declare CheckTitle(nCode,Title.s)
Global hCBTHook
Procedure.l CBTProc(nCode,wParam,*lParam)
	Protected Title.s = Space(64)
	If nCode = #HCBT_DESTROYWND
		;DbgCbt("CBTHook: DESTROYWND: "+Str(wParam)+" 0x"+Hex(wParam))
		GetWindowText_(wParam,@Title,64)
		DbgCbt("CBTHook: DESTROYWND: "+Str(wParam)+" 0x"+Hex(wParam)+" «"+Title+"»")
		CharLower_(Title)
		Protected ct = CheckTitle(nCode,Title)
		If ct = #PORTABLE_CBTR_EXIT ; полное завершение работы программы
			UnhookWindowsHookEx_(hCBTHook)
			CompilerIf #DBG_CBT_HOOK_ALWAYS Or #DBG_CBT_HOOK
				Protected Inst.s = Str(ProcessCnt)
				If LastProcess
					Inst = "LAST"
				EndIf
				If DbgDetachMode
					dbg("CBTHook: Exit: "+DllPath+" (I:"+Str(DllInstancesCnt)+"/P:"+Inst+")")
				EndIf
			CompilerEndIf
			ExitProcedure()
			CompilerIf #DBG_CBT_HOOK_ALWAYS Or #DBG_CBT_HOOK
				If DbgDetachMode
					dbg("CBTHook: Exit: "+PrgPath)
				EndIf
			CompilerEndIf
			ProcedureReturn CallNextHookEx_(#Null,nCode,wParam,*lParam)
		EndIf
		CompilerIf #PORTABLE_REGISTRY
			If ct = #PORTABLE_CBTR_SAVECFG ; только сохранение конфигурации
				DbgCbt("CBTHook: WriteCfg")
				WriteCfg()
			EndIf
		CompilerEndIf
	EndIf
	ProcedureReturn CallNextHookEx_(#Null,nCode,wParam,*lParam)
EndProcedure

;;======================================================================================================================
; Установка хуков для AttachProcess
Global CBTHookPermit = 1
Procedure _InitCBTHook()
	If CBTHookPermit
		hCBTHook = SetWindowsHookEx_(#WH_CBT,@CBTProc(),#Null,GetCurrentThreadId_())
	EndIf
EndProcedure
AddInitProcedure(_InitCBTHook)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = y
; EnableAsm
; DisableDebugger
; EnableExeConstant