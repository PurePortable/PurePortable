; Определение битности файла

;IMAGE_DOS_HEADER\e_magic
#IMAGE_DOS_HEADER=$5A4D ; Magic number
;IMAGE_NT_HEADERS\Signature
#IMAGE_NT_SIGNATURE=$00004550

;IMAGE_FILE_HEADER\Machine
#IMAGE_FILE_MACHINE_I386 = $014C ; x86 (стандартное значение для x32 приложений)
#IMAGE_FILE_MACHINE_I486 = $014D ; ?
#IMAGE_FILE_MACHINE_I586 = $014E ; ?
#IMAGE_FILE_MACHINE_IA64 = $0200 ; Intel Itanium
#IMAGE_FILE_MACHINE_AMD64 = $8664 ; x64 (стандартное значение для x64 приложений)
; https://www.purebasic.fr/english/viewtopic.php?f=13&t=44869
; https://www.purebasic.fr/english/viewtopic.php?f=12&t=67345
; https://habr.com/ru/post/266831/
Procedure GetBitness(file.s)
	Define IMAGE_DOS_HEADER.IMAGE_DOS_HEADER
	Define IMAGE_NT_HEADERS64.IMAGE_NT_HEADERS64
	Define IMAGE_NT_HEADERS32.IMAGE_NT_HEADERS32
	;Define hfile = ReadFile(#PB_Any,file)
	Define hfile = CreateFile_(@file,#GENERIC_READ,0,#Null,#OPEN_EXISTING,#FILE_ATTRIBUTE_NORMAL,#Null)
	If hfile<>#INVALID_HANDLE_VALUE
		;ReadData(hfile,@IMAGE_DOS_HEADER,SizeOf(IMAGE_DOS_HEADER))
		ReadFile_(hfile,@IMAGE_DOS_HEADER,SizeOf(IMAGE_DOS_HEADER),#Null,#Null)
		;If IMAGE_DOS_HEADER\e_magic <> #IMAGE_DOS_HEADER : ProcedureReturn 0 : EndIf
		;FileSeek(hfile,IMAGE_DOS_HEADER\e_lfanew)
		SetFilePointer_(hfile,IMAGE_DOS_HEADER\e_lfanew,#Null,#FILE_BEGIN) ; #FILE_CURRENT
		;ReadData(hfile,@IMAGE_NT_HEADERS32,SizeOf(IMAGE_NT_HEADERS32))
		;ReadData(hfile,@IMAGE_NT_HEADERS32,SizeOf(IMAGE_NT_HEADERS32))
		ReadFile_(hfile,@IMAGE_NT_HEADERS32,SizeOf(IMAGE_NT_HEADERS32),#Null,#Null)
		;CloseFile(hfile)
		CloseHandle_(hfile)
	EndIf
	ProcedureReturn IMAGE_NT_HEADERS32\FileHeader\Machine & $0000FFFF
EndProcedure
