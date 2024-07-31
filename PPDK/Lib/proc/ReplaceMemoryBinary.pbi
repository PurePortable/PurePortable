; Замена в памяти
Procedure.i ReplaceMemoryBinary(*mem,*end,*bin1,*bin2,binlen,num=0)
	Protected cnt
	Protected *last = *end-binlen
	Protected *adr = *mem
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
