;;======================================================================================================================
CompilerIf Not Defined(DBG_CBT_HOOK,#PB_Constant) : #DBG_CBT_HOOK = 0 : CompilerEndIf

CompilerIf #DBG_CBT_HOOK And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_CBT_HOOK
	;UndefineMacro DbgAny : DbgAnyDef
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
	Protected title.s = Space(64)
	Select nCode
		;Case #HCBT_CREATEWND
		;	Protected *cw.CBT_CREATEWND
		;	Protected *cs.CREATESTRUCT
		;	Protected *as.CBTACTIVATESTRUCT
		;	DbgCbt("CBTHook: CREATEWND: "+Str(wParam)+" 0x"+Hex(wParam))
		;	*cw = *lParam
		;	*cs = *cw\lpcs
		;	If *cs\lpszClass
		;		DbgCbt("CBTHook: CLASS: "+PeekS(*cs\lpszClass))
		;	EndIf
		;	DbgCbt("CBTHook: CREATEWND: "+Str(wParam)+" 0x"+Hex(wParam)+" «"+PeekSZ(*cs\lpszName)+"»")
		Case #HCBT_DESTROYWND
			;DbgCbt("CBTHook: DESTROYWND: "+Str(wParam)+" 0x"+Hex(wParam))
			GetWindowText_(wParam,@title,64)
			DbgCbt("CBTHook: DESTROYWND: "+Str(wParam)+" 0x"+Hex(wParam)+" «"+title+"»")
			CharLower_(title)
			Protected ct = CheckTitle(nCode,title)
			If ct & #PORTABLE_CBTR_SAVECFG
				DbgCbt("CBTHook: WriteCfg")
				WriteCfg()
			EndIf
			CompilerIf Defined(MH_Initialize,#PB_Procedure)
				If ct & #PORTABLE_CBTR_UNINITIALIZE
					DbgCbt("CBTHook: Unhook MH")
					MH_Uninitialize()
				EndIf
			CompilerEndIf
			If ct & #PORTABLE_CBTR_UNHOOK
				DbgCbt("CBTHook: Unhook CBT")
				UnhookWindowsHookEx_(hCBTHook)
			EndIf
			If ct & $100
				ProcedureReturn
			EndIf
	EndSelect
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
; CursorPosition = 3
; Folding = -
; EnableAsm
; DisableDebugger
; EnableExeConstant