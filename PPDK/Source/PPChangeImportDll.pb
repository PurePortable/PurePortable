;;======================================================================================================================
; Коррекция таблицы экспорта
;;======================================================================================================================

;PP_SILENT 1
;PP_BACKUP 0
;PP_PUREPORTABLE 1
;RES_VERSION 1.0.2.0
;RES_PRODUCTVERSION 1.0.2.0
;RES_DESCRIPTION PurePortable change import dll name
;RES_COPYRIGHT (c) Smitis, 2020-2025
;RES_INTERNALNAME PPChangeImportDll
;PP_ENABLETHREAD 0
;PP_OPTIMIZER 0

EnableExplicit
OpenConsole()

;;----------------------------------------------------------------------------------------------------------------------
Macro PrintT : PrintN : EndMacro
;;----------------------------------------------------------------------------------------------------------------------

Declare CorrectImport(BinFile.s,Dll1.s,Dll2.s)

;;----------------------------------------------------------------------------------------------------------------------

Define BinFile.s = ProgramParameter()
Define Dll1.s = ProgramParameter()
Define Dll2.s = ProgramParameter()
PrintN("PurePortable correct import dll name: "+BinFile)
If FileSize(BinFile) < 0 ; Файл не найден
	PrintN("ERROR: File not found!")
	End 1
EndIf
If Len(Dll1)=0 Or Len(Dll2)=0
	PrintN("ERROR: Wrong dll names")
	End 2
EndIf
If Len(Dll1) < Len(Dll2)
	PrintN("ERROR: name of second dll longer then first dll")
	End 2
EndIf
CorrectImport(BinFile,Dll1,Dll2)

End

;;======================================================================================================================
; https://habr.com/ru/post/266831/
;IMAGE_FILE_HEADER\Machine
#IMAGE_FILE_MACHINE_I386 = $014C ; x86
#IMAGE_FILE_MACHINE_I486 = $014D
#IMAGE_FILE_MACHINE_I586 = $014E
#IMAGE_FILE_MACHINE_IA64 = $0200 ; Intel Itanium
#IMAGE_FILE_MACHINE_AMD64 = $8664 ; x64
Procedure RVA2FOA(*FileBase.IMAGE_DOS_HEADER,RVA)
	Protected *NtHdr32.IMAGE_NT_HEADERS32 = *FileBase+*FileBase\e_lfanew
	Protected *NtHdr64.IMAGE_NT_HEADERS64 = *NtHdr32
	Protected *SecHdr.IMAGE_SECTION_HEADER ; = *NtHdr32+SizeOf(IMAGE_NT_HEADERS64)
	Protected nSection = *NtHdr32\FileHeader\NumberOfSections
	If (*NtHdr32\FileHeader\Machine & $0000FFFF) = #IMAGE_FILE_MACHINE_AMD64
		*SecHdr = *NtHdr64+SizeOf(IMAGE_NT_HEADERS64)
	Else
		*SecHdr = *NtHdr32+SizeOf(IMAGE_NT_HEADERS32)
	EndIf
	Protected iSection, SectionBeginRva, SectionEndRva
	; Traverse the section table to find the section where the RVA is located
	; Each offset, whether in the file or in the memory, is always the same distance from the beginning of the section.
	; Moreover, in the section table, two start offsets are stored:
	; 1. Start offset in the file
	; 2. Start offset in memory
	; Specific process:
	; Find the section where the RVA is located, and then calculate the distance from this RVA to the starting position of the section in the memory.
	; Use this distance plus the starting position of the section in the file to get the file offset
	For iSection=0 To nSection-1
		;dbg("Section: "+iSection+" "+PeekS(@*SecHdr\SecName,8,#PB_Ascii))
		; The starting relative virtual address of the section RVA
		SectionBeginRva = *SecHdr\VirtualAddress
		; The relative virtual address of the end of the block RVA = the RVA address of the section + the alignment size of the section in the file
		SectionEndRva = SectionBeginRva+*SecHdr\SizeOfRawData
		;dbg(Hex(SectionBeginRva)+" :: "+Hex(SectionEndRva))
		If RVA >= SectionBeginRva And RVA < SectionEndRva
			; Calculate the file offset corresponding to RVA
			; Formula: file offset = RVA-the relative virtual address of the start of the section RVA + the start file offset of the section FOA
			; 1. RVA to be converted-the starting relative virtual address of the section RVA
			; 2. Add the starting file offset FOA of the section, dwOffset is FOA
			ProcedureReturn RVA - *SecHdr\VirtualAddress + *SecHdr\PointerToRawData
		EndIf
		*SecHdr+SizeOf(IMAGE_SECTION_HEADER)
	Next
	ProcedureReturn 0
EndProcedure

Procedure RVA2A(*FileBase.IMAGE_DOS_HEADER,RVA)
	Protected FOA = RVA2FOA(*FileBase,RVA)
	If FOA
		ProcedureReturn *FileBase+FOA
	EndIf
	ProcedureReturn #Null
EndProcedure

; http://cs.usu.edu.ru/docs/pe/
; https://www.cyberforum.ru/blogs/172954/blog5746.html
; https://learn.microsoft.com/ru-ru/windows/win32/api/winnt/ns-winnt-image_optional_header32
; https://learn.microsoft.com/ru-ru/windows/win32/api/winnt/ns-winnt-image_optional_header64
Structure QuadLong
	StructureUnion
		*q.Quad
		*l.Long
	EndStructureUnion
EndStructure

Procedure CorrectCheckSumAdr(*BaseAddress,FileSize)
	Protected *NTHeaders.IMAGE_NT_HEADERS
	Protected HeaderSum, CheckSum
	*NTHeaders = CheckSumMappedFile_(*BaseAddress,FileSize,@HeaderSum,@CheckSum)
	;dbg("Checksum: "+Hex(*NTHeaders\OptionalHeader\CheckSum)+"/"+Hex(CheckSum))
	*NTHeaders\OptionalHeader\CheckSum = CheckSum
EndProcedure

; https://www.transl-gunsmoker.ru/2011/08/how-are-dll-functions-exported-in-32.html

;{ IMAGE_SECTION_HEADER_ ; уже определена, для примера
Structure IMAGE_SECTION_HEADER_ ; уже определена, для примера
	SecName.b[#IMAGE_SIZEOF_SHORT_NAME] ; Name
	StructureUnion ; Misc
		PhysicalAddr.l
		VirtualSize.l
	EndStructureUnion
	VirtualAddress.l
	SizeOfRawData.l
	PointerToRawData.l
	PointerToRelocations.l
	PointerToLinenumbers.l
	NumberOfRelocations.w
	NumberOfLinenumbers.w
	Characteristics.l
EndStructure
;}
;{ IMAGE_IMPORT_DESCRIPTOR
Structure IMAGE_IMPORT_DESCRIPTOR ; Эта структура справедлива как для PE, так и для PE64
	; В этом поле содержится смещение (RVA) массива двойных слов. Каждое из этих двойных слов - объединение типа IMAGE_THUNK_DATA.
	; Каждое двойное слово IMAGE_THUNK_DATA соответствует одной функции, импортируемой данным файлом.
	; Массив _IMAGE_THUNK_DATA32 называется Import Lookup Table.
	; Каждый элемент Import Lookup Table содержит RVA на структуру IMAGE_IMPORT_BY_NAME.
	; Этот массив в процессе загрузки программы не изменяется и может совсем не использоваться.
	StructureUnion
		Characteristics.l
		OriginalFirstThunk.l
	EndStructureUnion
	TimeDateStamp.l
	ForwarderChain.l
	Name.l ; RVA строки, содержащей имя DLL, из которой будет производиться импорт.
	FirstThunk.l ; RVA массива IMAGE_THUNK_DATA32, называемого Import Address Table.
		; До загрузки программы идентичен Import Lookup Table, после загрузки элементы массива содержат проекцию адресов функций.
EndStructure
;}
;{ IMAGE_THUNK_DATA ; Размерность полей зависит от разрядности!
Structure IMAGE_THUNK_DATA ; Размерность полей зависит от разрядности!
	StructureUnion
		ForwarderString.i
		Function.i
		Ordinal.i
		AddressOfData.i
	EndStructureUnion
EndStructure
;}
;{ IMAGE_IMPORT_BY_NAME
Structure IMAGE_IMPORT_BY_NAME
	Hint.w
	Name.s{128}
EndStructure
;}

Procedure CorrectImport(BinFile.s,Dll1.s,Dll2.s)
	Protected n
	Protected *NtHdr32.IMAGE_NT_HEADERS32
	Protected *NtHdr64.IMAGE_NT_HEADERS64
	Protected *ImportDir.IMAGE_IMPORT_DESCRIPTOR
	Protected FileSize.l, LargeFileSize.q, HeaderSum.l, CheckSum.l
	Protected Is64, PSize, Changed
	Protected hFile, hFileMapping, *BaseAddress.IMAGE_DOS_HEADER
	Protected *ImportDllName, ImportDllName.s
	CharLower_(Dll1) ; для сравнения
	
	hFile = CreateFile_(@BinFile,#GENERIC_READ|#GENERIC_WRITE,#FILE_SHARE_READ|#FILE_SHARE_WRITE,#Null,#OPEN_EXISTING,#FILE_ATTRIBUTE_NORMAL,0)
	If hFile
		;FileSize = GetFileSize_(hFile,#Null)
		If GetFileSizeEx_(hFile,@LargeFileSize)
			FileSize = LargeFileSize
		EndIf
		; https://learn.microsoft.com/ru-ru/windows/win32/api/memoryapi/nf-memoryapi-mapviewoffile
		; https://learn.microsoft.com/ru-ru/windows/win32/memory/creating-a-view-within-a-file
		hFileMapping = CreateFileMapping_(hFile,#Null,#PAGE_READWRITE,0,0,#Null)
		;PrintT("  FileMapping: "+hFileMapping)
		;hFileMapping = CreateFileMapping_(hFile,#Null,#PAGE_READWRITE,0,FileSize,#Null)
		;https://forum.sources.ru/index.php?showtopic=414244
		;CloseHandle_(hFile) ; можно вызывать прямо здесь
		If hFileMapping
			*BaseAddress = MapViewOfFile_(hFileMapping,#FILE_MAP_ALL_ACCESS,0,0,0)
			;PrintT("  BaseAddress: "+*BaseAddress)
			If *BaseAddress
				*NtHdr32 = *BaseAddress+*BaseAddress\e_lfanew
				*NtHdr64 = *NtHdr32
				Is64 = Bool((*NtHdr32\FileHeader\Machine & $0000FFFF) = #IMAGE_FILE_MACHINE_AMD64) ; = $8664
				If Is64
					*ImportDir = *NtHdr64\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IMPORT]\VirtualAddress
					;PrintT("ExportDir 64: RVA: "+Hex(*ImportDir)+" FOA: "+Hex(RVA2FOA(*BaseAddress,*ImportDir)))
					PSize = 8
				Else
					*ImportDir = *NtHdr32\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IMPORT]\VirtualAddress
					;PrintT("ExportDir 32: RVA: "+Hex(*ImportDir)+" FOA: "+Hex(RVA2FOA(*BaseAddress,*ImportDir)))
					PSize = 4
				EndIf
				*ImportDir = RVA2A(*BaseAddress,*ImportDir)
				;PrintT("  ImportDir: "+*ImportDir)
				*ImportDllName = RVA2A(*BaseAddress,*ImportDir\Name)
				;PrintT("  ImportDir\Name: "+*ImportDir\Name)
				While *ImportDllName
					ImportDllName = PeekS(*ImportDllName,-1,#PB_Ascii)
					PrintN("  DLL: "+ImportDllName)
					If LCase(ImportDllName) = Dll1
						PrintN("  "+ImportDllName+" -> "+Dll2)
						PokeS(*ImportDllName,Dll2,Len(ImportDllName),#PB_Ascii)
					EndIf
					*ImportDir + SizeOf(IMAGE_IMPORT_DESCRIPTOR)
					*ImportDllName = RVA2A(*BaseAddress,*ImportDir\Name)
				Wend
			EndIf
			If Changed
				CorrectCheckSumAdr(*BaseAddress,FileSize)
			EndIf
			; https://learn.microsoft.com/ru-ru/windows/win32/api/memoryapi/nf-memoryapi-unmapviewoffile?redirectedfrom=MSDN
			; https://learn.microsoft.com/ru-ru/windows/win32/api/memoryapi/nf-memoryapi-flushviewoffile
			If FlushViewOfFile_(*BaseAddress,0) = 0
			;If FlushViewOfFile_(*BaseAddress,FileSize) = 0
				;PrintT("FlushViewOfFile: "+GetLastErrorStr())
			EndIf
			If UnmapViewOfFile_(hFileMapping) = 0 ; почему-то всегда 0
				;PrintT("UnmapViewOfFile: "+GetLastErrorStr())
			EndIf
			If CloseHandle_(hFileMapping) = 0
				;PrintT("CloseHandle (FileMapping): "+GetLastErrorStr())
			EndIf
		EndIf
		FlushFileBuffers_(hFile)
		If CloseHandle_(hFile) = 0
			;PrintT("CloseHandle (File): "+GetLastErrorStr())
		EndIf
		;If UnmapViewOfFile_(hFileMapping) = 0 ; почему-то всегда 0
		;	;PrintT("UnmapViewOfFile: "+GetLastErrorStr())
		;EndIf
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 184
; FirstLine = 140
; Folding = v9
; Optimizer
; EnableThread
; Executable = ..\PPChangeImportDll.exe
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1.0.2.0
; VersionField1 = 1.0.2.0
; VersionField4 = 1.0.2.0
; VersionField5 = 1.0.2.0
; VersionField6 = PurePortable change import dll name
; VersionField7 = PPChangeImportDll
; VersionField9 = (c) Smitis, 2020-2025