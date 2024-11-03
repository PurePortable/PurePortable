; Замена в памяти
Procedure.i ReplaceMemoryHexBin(*mem,*end,hex1.s,hex2.s,binlen=0,num=0)
	Protected cnt
	Protected *last = *end-binlen
	Protected *adr = *mem
	If Len(hex1)<>Len(hex2)
		ProcedureReturn 0
	EndIf
	Protected binlen1, binlen2
	Protected *bin1 = Hex2Bin(hex1,#Null,@binlen1)
	Protected *bin2 = Hex2Bin(hex2,#Null,@binlen2)
	If binlen1<>binlen2
		ProcedureReturn 0
	EndIf
	If binlen=0
		binlen = binlen1
	EndIf
	While *adr < *last
		If CompareMemory(*adr,*bin1,binlen)
			cnt+1
			CopyMemory(*bin2,*adr,binlen)
			If cnt = num
				Break
			EndIf
		EndIf
		*adr + 1
	Wend
	ProcedureReturn cnt
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant