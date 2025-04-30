;;======================================================================================================================
; Модуль BlockRecentDocs
; Блокировка истории открытых файлов
;;======================================================================================================================

CompilerIf Not Defined(DBG_BLOCK_RECENT_DOCS,#PB_Constant) : #DBG_BLOCK_RECENT_DOCS = 0 : CompilerEndIf

CompilerIf #DBG_BLOCK_RECENT_DOCS And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_BLOCK_RECENT_DOCS
	Global DbgRecDocMode = #DBG_BLOCK_RECENT_DOCS
	Procedure DbgRecDoc(txt.s)
		If DbgRecDocMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgRecDoc(txt) : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shaddtorecentdocs
Prototype SHAddToRecentDocs(uFlags,*pv)
Global Original_SHAddToRecentDocs.SHAddToRecentDocs
Procedure Detour_SHAddToRecentDocs(uFlags,*pv)
	DbgRecDoc("SHAddToRecentDocs")
	; Никакое значение не возвращается.
EndProcedure
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

;;======================================================================================================================

Global BlockRecentDocsPermit = 1
Procedure _InitBlockRecentDocsHooks()
	If BlockRecentDocsPermit
		MH_HookApi(shell32,SHAddToRecentDocs)
	EndIf
EndProcedure
AddInitProcedure(_InitBlockRecentDocsHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 29
; FirstLine = 9
; Folding = -
; DisableDebugger
; EnableExeConstant