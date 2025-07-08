
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfullpathnamew
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathcanonicalizew
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathremovebackslashw
; https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats

;CanonicalizePath

Procedure.s NormalizePath(Path.s,Dir.s="")
	If Path ; Если не проверить, для пустой строки вернёт корень текущего диска
		Protected NewPath.s, Ending.s
		If Right(Path,1) = "\" ; сохраним завершающий «\» для папок
			NewPath = Path + "."
			Ending = "\"
		Else
			NewPath = Path + "\."
		EndIf
		If Mid(Path,2,1) <> ":" ; относительный путь
			If Dir=""
				Dir = GetCurrentDirectory()
			Else
				Dir = RTrim(Dir,"\")+"\"
			EndIf
			NewPath = Dir+NewPath ; TODO: пути, начинающиеся с "\"
		EndIf
		Protected *Buf
		Protected LenBuf = GetFullPathName_(@NewPath,0,#Null,#Null)
		If LenBuf
			*Buf = AllocateMemory(LenBuf*2)
			GetFullPathName_(@NewPath,LenBuf,*Buf,#Null)
			NewPath = PeekS(*Buf)
			FreeMemory(*Buf)
			ProcedureReturn NewPath+Ending
		EndIf
	EndIf
	ProcedureReturn Path
EndProcedure

; Procedure.s NormalizePath2(Path.s)
; 	If Path ; Иначе вернём корень текущего диска
; 		Path + "\."
; 		Protected Len = GetFullPathName_(@NewPath,0,#Null,#Null)
; 		Protected Result.s
; 		If Len
; 			Result = Space(Len)
; 			GetFullPathName_(@Path,Len,@Result,#Null)
; 			ProcedureReturn Result
; 		EndIf
; 	EndIf
; 	ProcedureReturn Path
; EndProcedure

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 23
; FirstLine = 3
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant