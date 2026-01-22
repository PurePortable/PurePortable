
Structure CHECKKEYDATA
	chk.s
	clen.i
	exact.i
	virt.s
EndStructure

Global Dim CheckedKeys.CHECKKEYDATA(0), nCheckedKeys

Procedure.s CheckKeyArray(hKey.l,Key.s)
	Protected i, l, c, k.s
	For i=1 To nCheckedKeys
		l = CheckedKeys(i)\clen
		k = CheckedKeys(i)\chk
		If CheckedKeys(i)\exact
			If StrCmp(@Key,@k)=0 Or (StrCmpN(@Key,@k,l)=0 And PeekW(@Key+l<<1)=92)
				ProcedureReturn CheckedKeys(i)\virt+Mid(Key,l+1)
			EndIf
		ElseIf StrCmpN(@Key,@k,l)=0
			ProcedureReturn CheckedKeys(i)\virt+Mid(Key,l+1)
		EndIf
	Next
	ProcedureReturn ""
EndProcedure

Procedure AddCheckedKey(k.s,v.s="")
	If k
		CharLower_(@k)
		CharLower_(@v)
		If v = ""
			v = k
		EndIf
		nCheckedKeys+1
		ReDim CheckedKeys(nCheckedKeys)
		CheckedKeys(nCheckedKeys)\exact = Bool(Right(k,1)="\")
		CheckedKeys(nCheckedKeys)\chk = RTrim(k,"\")
		CheckedKeys(nCheckedKeys)\clen = Len(CheckedKeys(nCheckedKeys)\chk)
		CheckedKeys(nCheckedKeys)\virt = RTrim(v,"\")
	EndIf
EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 26
; FirstLine = 3
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant