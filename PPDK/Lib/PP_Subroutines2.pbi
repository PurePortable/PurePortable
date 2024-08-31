;=======================================================================================================================
; Условная компиляция применена для тестирования других вариантов процедур
;=======================================================================================================================
CompilerIf Not Defined(Bin2Hex,#PB_Procedure)
	Procedure.s Bin2Hex(*Bin.Byte,BinCnt)
		Protected Result.s = Space(BinCnt<<1) ; по два символа на каждый байт
		Protected *Hex = @Result
		Protected *End = *Bin + BinCnt
		While *Bin < *End
			PokeS(*Hex,RSet(Hex(*Bin\b,#PB_Byte),2,"0")) ; пишем по два символа + 0; последний 0 ляжет на 0 в конце строки
			*Bin + 1
			*Hex + 4 ; hex представление байта - два символа в юникоде
		Wend
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Преобразование строки байт в hex-виде в массив байт.
CompilerIf Not Defined(Hex2Bin,#PB_Procedure)
	Procedure.i Hex2Bin(sHex.s,*Buf=#Null,*cb.Integer=#Null)
		;RemoveSpaces(@Hex)
		sHex = ReplaceString(sHex," ","")
		Protected Size = Len(sHex)/2 ; на каждый байт два символа
		If *cb
			*cb\i = Size
		EndIf
		If *Buf = #Null
			*Buf = AllocateMemory(Size+2) ; плюс два байта чтобы был не нулевой буфер.
		EndIf
		Protected *Bin.Byte = *Buf
		Protected *End = *Bin+Size
		Protected Pos = 1
		While *Bin < *End
			*Bin\b = Val("$"+Mid(sHex,Pos,2))
			*Bin + 1
			Pos + 2
		Wend
		ProcedureReturn *Buf
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Кодирование служебных символов
; 0xE000 символ из набора символов для частного использования для кодирования символа 0x0000
; Служебные символы 0x0000-0x001F кодируются, соответственно 0xE000-0xE01F
; Обработка идёт до появления нулевого символа для #REG_SZ, #REG_EXPAND_SZ или до двойного нулевого для #REG_MULTI_SZ
; #REG_MULTI_SZ = 7
CompilerIf Not Defined(EncodeCtrl,#PB_Procedure)
	Procedure EncodeCtrl(*s.Unicode,t=0)
		While 1
			If *s\u=#NUL And t=#REG_MULTI_SZ
				*s\u = #XNUL
				*s+2
			EndIf
			If *s\u=#NUL
				ProcedureReturn
			EndIf
			If *s\u<#SP
				*s\u+#XNUL
			EndIf
			*s+2
		Wend
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Декодирование служебных символов
CompilerIf Not Defined(DecodeCtrl,#PB_Procedure)
	Procedure DecodeCtrl(*s.Unicode)
		While *s\u
			If *s\u>=#XNUL And *s\u<=#XUS
				*s\u-#XNUL
			EndIf
			*s+2
		Wend
	EndProcedure
CompilerEndIf
;=======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 15
; FirstLine = 3
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant