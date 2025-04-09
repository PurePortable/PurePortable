
Prototype Proto_dbg(txt.s)
Prototype.s GetLastErrorStr(Error=0)
Prototype PPErrorMessage(Msg.s,Error)
Prototype PPLastErrorMessage(Msg.s)
Prototype.s Bin2Hex(*Bin.Byte,BinCnt)
Prototype.i Hex2Bin(sHex.s,*Buf=#Null,*cb.Integer=#Null)
Prototype EncodeCtrl(*s.Unicode,t=0)
Prototype DecodeCtrl(*s.Unicode)

Structure IHelpful
	dbg.Proto_dbg
	GetLastErrorStr.GetLastErrorStr
	PPErrorMessage.PPErrorMessage
	PPLastErrorMessage.PPLastErrorMessage
	Bin2Hex.Bin2Hex
	Hex2Bin.Hex2Bin
	EncodeCtrl.EncodeCtrl
	DecodeCtrl.DecodeCtrl
EndStructure

CompilerIf Not Defined(IHELPFUL_INIT,#PB_Constant) : #IHELPFUL_INIT = 0 : CompilerEndIf

CompilerIf #IHELPFUL_INIT
	
	;Global IHelpful.IHelpful
	;IHelpful\dbg = @dbg()
	
	DataSection
		IHelpful:
		Data.i @dbg()
		Data.i @GetLastErrorStr()
		Data.i @PPErrorMessage()
		Data.i @PPLastErrorMessage()
		Data.i @Bin2Hex()
		Data.i @Hex2Bin()
		Data.i @EncodeCtrl()
		Data.i @DecodeCtrl()
		Data.i 0
	EndDataSection
	
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 18
; FirstLine = 3
; EnableThread
; DisableDebugger
; EnableExeConstant