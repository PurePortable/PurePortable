; Поиск в памяти
Procedure.i FindMemoryString(*mem,*end,txt.s,codepage=#PB_Ascii)
	Protected sizechar = 1
	If codepage = #PB_Unicode : sizechar = 2 : EndIf
	Protected bufsize = Len(txt)*sizechar
	Protected *last = *end-bufsize
	Protected *buf = AllocateMemory(bufsize+sizechar)
	PokeS(*buf,txt,-1,codepage)
	Protected *adr = *mem
	While *adr < *last
		If CompareMemoryString(*adr,*buf,#PB_String_NoCase,-1,codepage) = #PB_String_Equal
			FreeMemory(*buf)
			ProcedureReturn *adr
		EndIf
		*adr + sizechar ; или лучше всё-таки 1???
	Wend
	FreeMemory(*buf)
	ProcedureReturn #Null
EndProcedure
