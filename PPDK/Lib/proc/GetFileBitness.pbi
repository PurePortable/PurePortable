; Определение битности файла

Procedure GetFileBitness(file.s)
	Define IMAGE_DOS_HEADER.IMAGE_DOS_HEADER
	Define IMAGE_NT_HEADERS32.IMAGE_NT_HEADERS32
	Define hfile = ReadFile(#PB_Any,file)
	If hfile
		ReadData(hfile,@IMAGE_DOS_HEADER,SizeOf(IMAGE_DOS_HEADER))
		If (IMAGE_DOS_HEADER\e_magic & $0000FFFF) <> $5A4D ; #IMAGE_DOS_HEADER_MAGIC
			CloseFile(hfile)
			ProcedureReturn 0
		EndIf
		FileSeek(hfile,IMAGE_DOS_HEADER\e_lfanew)
		ReadData(hfile,@IMAGE_NT_HEADERS32,SizeOf(IMAGE_NT_HEADERS32))
		;If (IMAGE_NT_HEADERS32\Signature & $0000FFFF) <> $00004550
		;	CloseFile(hfile)
		;	ProcedureReturn 0
		;EndIf
		CloseFile(hfile)
	EndIf
	Define Bitness = IMAGE_NT_HEADERS32\FileHeader\Machine & $0000FFFF
	If Bitness=$8664 ; #IMAGE_FILE_MACHINE_AMD64
		ProcedureReturn 2
	EndIf
	If Bitness=$014C ; #IMAGE_FILE_MACHINE_I386
		ProcedureReturn 1
	EndIf
	ProcedureReturn 0
EndProcedure
