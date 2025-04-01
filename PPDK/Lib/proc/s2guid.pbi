; Преобразование строки в GUID

Prototype GUIDFromString(*psz,*pguid)
Global GUIDFromString.GUIDFromString = GetProcAddress_(LoadLibrary_("shell32.dll"),704)
Procedure s2guid(guid.s,*guid.GUID)
	ProcedureReturn GUIDFromString(@guid,*guid)
EndProcedure

; Procedure s2guid2(guid.s,*guid.GUID)
; 	*guid\Data1 = Val("$"+Mid(guid,2,8))
; 	*guid\Data2 = Val("$"+Mid(guid,11,4))
; 	*guid\Data3 = Val("$"+Mid(guid,16,4))
; 	*guid\Data4[0] = Val("$"+Mid(guid,21,2))
; 	*guid\Data4[1] = Val("$"+Mid(guid,23,2))
; 	*guid\Data4[2] = Val("$"+Mid(guid,26,2))
; 	*guid\Data4[3] = Val("$"+Mid(guid,28,2))
; 	*guid\Data4[4] = Val("$"+Mid(guid,30,2))
; 	*guid\Data4[5] = Val("$"+Mid(guid,32,2))
; 	*guid\Data4[6] = Val("$"+Mid(guid,34,2))
; 	*guid\Data4[7] = Val("$"+Mid(guid,36,2))
; EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 0
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant