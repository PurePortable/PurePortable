; Замена в памяти
; txt2 усекается или дополняется нулями до длины txt1!
Procedure.i ReplaceMemoryString(*mem,*end,txt1.s,txt2.s,num=0,codepage=#PB_Ascii)
	Protected cnt
	Protected sizechar = 1
	If codepage = #PB_Unicode : sizechar = 2 : EndIf
	Protected bufsize = Len(txt1)*sizechar
	Protected *buf1 = AllocateMemory(bufsize+sizechar)
	PokeS(*buf1,txt1,-1,codepage)
	Protected *buf2 = AllocateMemory(bufsize+sizechar)
	PokeS(*buf2,txt2,Len(txt1),codepage)
	Protected *last = *end-bufsize
	Protected *adr = *mem
	While *adr < *last
		If CompareMemoryString(*adr,*buf1,#PB_String_NoCase,-1,codepage) = #PB_String_Equal
			cnt+1
			CopyMemory(*buf2,*adr,bufsize)
			If cnt = num
				Break
			EndIf
		EndIf
		*adr + sizechar
	Wend
	FreeMemory(*buf1)
	FreeMemory(*buf2)
	ProcedureReturn cnt
EndProcedure
