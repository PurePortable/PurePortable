
Prototype Proto_dbg(txt.s)

Structure IHelpful
	dbg.Proto_dbg
EndStructure

CompilerIf Not Defined(IHELPFUL_INIT,#PB_Constant) : #IHELPFUL_INIT = 0 : CompilerEndIf

CompilerIf #IHELPFUL_INIT
	
	;Global IHelpful.IHelpful
	;IHelpful\dbg = @dbg()
	
	DataSection
		IHelpful:
		Data.i @dbg()
		Data.i 0
	EndDataSection
	
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 12
; EnableThread
; DisableDebugger
; EnableExeConstant