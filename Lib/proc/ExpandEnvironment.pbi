Procedure.s ExpandEnvironment(s.s)
	Protected r.s, e.s, v.s
	Protected p1, p2
	p1 = FindString(s,"%")
	While p1
		p2 = FindString(s,"%",p1+1)
		If p2
			v = Mid(s,p1+1,p2-p1-1)
			e = env2path(v)
			If e="" And v<>""
				e = GetEnvironmentVariable(v)
			EndIf
			If e=""
				e = Mid(s,p1,p2-p1+1)
			EndIf
			r + Left(s,p1-1)+e
			s = Mid(s,p2+1)
		Else ; нет парного %
			Break
		EndIf
		p1 = FindString(s,"%")
	Wend
	ProcedureReturn r+s
EndProcedure
;{Procedure.s _ExpandEnvironmentStrings2(s.s)
; 	Protected r.s
; 	Protected p0,p1, p2
; 	p1 = FindString(s,"%")
; 	While p1
; 		p2 = FindString(s,"%",p1+1)
; 		If p2
; 			r + Left(s,p1-1)+env2path(Mid(p1+1,p2-p1-1))
; 			s = Mid(s,p2+1)
; 		Else
; 			Break
; 		EndIf
; 		p1 = FindString(s,"%")
; 	Wend
; 	ProcedureReturn r+s
;EndProcedure
;}
