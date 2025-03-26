;;======================================================================================================================
; Коррекция таблицы экспорта
;;======================================================================================================================

;PP_SILENT 1
;PP_BACKUP 0
;PP_PUREPORTABLE 1
;RES_VERSION 1.0.2.0
;RES_PRODUCTVERSION 1.0.2.0
;RES_DESCRIPTION PurePortable correct export
;RES_COPYRIGHT (c) Smitis, 2020-2025
;RES_INTERNALNAME PPCorrectExport
;PP_ENABLETHREAD 0
;PP_OPTIMIZER 0

EnableExplicit
OpenConsole()

;;----------------------------------------------------------------------------------------------------------------------
Macro PrintT : PrintN : EndMacro
;;----------------------------------------------------------------------------------------------------------------------

Declare CorrectExport(BinFile.s)

;;----------------------------------------------------------------------------------------------------------------------

Define BinFile.s = ProgramParameter()
PrintN("PurePortable correct export: "+BinFile)
If FileSize(BinFile) < 0 ; Файл не найден
	PrintN("ERROR: File not found!")
	End 1
EndIf
CorrectExport(BinFile)

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
; «таблица экспортируемых имён в 32-битных Windows должна быть отсортирована, чтобы система могла воспользоваться (эффективным) двоичным поиском для ускорения поиска имён.»
; Поэтому пришлось изменять имена не только конфликтных функций, но и похожих.

Procedure CorrectExport(BinFile.s)
	;Static FuncList1.s = ";CreateThre__;CreateThre__pool;CreateThre__poolCleanupGroup;CreateThre__poolIo;CreateThre__poolTimer;CreateThre__poolWait;CreateThre__poolWork;FlushFileBuffe__;OpenFi__;OpenFi__ById;OpenFi__MappingA;OpenFi__MappingW;ReadFi__;ReadFi__Ex;ReadFi__Scatter;ResumeThre__;CloseWind__;CloseWind__Station;CopyIma__;CreateMe__;CreatePopupMe__;GetActiveWind__;IsMe__;IsWind__;IsWind__Enabled;IsWind__Unicode;IsWind__Visible;SetActiveWind__;AlphaBle__;CreateToolba_;"
	;Static FuncList2.s = ";CreateThread;CreateThreadpool;CreateThreadpoolCleanupGroup;CreateThreadpoolIo;CreateThreadpoolTimer;CreateThreadpoolWait;CreateThreadpoolWork;FlushFileBuffers;OpenFile;OpenFileById;OpenFileMappingA;OpenFileMappingW;ReadFile;ReadFileEx;ReadFileScatter;ResumeThread;CloseWindow;CloseWindowStation;CopyImage;CreateMenu;CreatePopupMenu;GetActiveWindow;IsMenu;IsWindow;IsWindowEnabled;IsWindowUnicode;IsWindowVisible;SetActiveWindow;AlphaBlend;CreateToolbar;"
	Static FuncList1.s = ";CreateThre__;FlushFileBuffe__;OpenFi__;ReadFi__;ResumeThre__;CloseWind__;CopyIma__;CreateMe__;CreatePopupMe__;GetActiveWind__;IsMe__;IsWind__;SetActiveWind__;AlphaBle__;CreateToolb__;"
	Static FuncList2.s = ";CreateThread;FlushFileBuffers;OpenFile;ReadFile;ResumeThread;CloseWindow;CopyImage;CreateMenu;CreatePopupMenu;GetActiveWindow;IsMenu;IsWindow;SetActiveWindow;AlphaBlend;CreateToolbar;"
	Protected n
	Protected *FileBase.IMAGE_DOS_HEADER ; *FileBase = *DosHdr
	Protected *NtHdr32.IMAGE_NT_HEADERS32
	Protected *NtHdr64.IMAGE_NT_HEADERS64
	Protected *ExportDir.IMAGE_EXPORT_DIRECTORY
	Protected *AddressOfNames.QuadLong, NumberOfNames, *AddressOfName, FuncName1.s, FuncName2.s
	Protected iExportName, FileSize.l, LargeFileSize.q, HeaderSum.l, CheckSum.l
	Protected Is64, PSize, Changed
	Protected hFile, hFileMapping, *BaseAddress.IMAGE_DOS_HEADER
	
	hFile = CreateFile_(@BinFile,#GENERIC_READ|#GENERIC_WRITE,#FILE_SHARE_READ|#FILE_SHARE_WRITE,#Null,#OPEN_EXISTING,#FILE_ATTRIBUTE_NORMAL,0)
	If hFile
		;FileSize = GetFileSize_(hFile,#Null)
		If GetFileSizeEx_(hFile,@LargeFileSize)
			FileSize = LargeFileSize
		EndIf
		; https://learn.microsoft.com/ru-ru/windows/win32/api/memoryapi/nf-memoryapi-mapviewoffile
		; https://learn.microsoft.com/ru-ru/windows/win32/memory/creating-a-view-within-a-file
		hFileMapping = CreateFileMapping_(hFile,#Null,#PAGE_READWRITE,0,0,#Null)
		;hFileMapping = CreateFileMapping_(hFile,#Null,#PAGE_READWRITE,0,FileSize,#Null)
		;https://forum.sources.ru/index.php?showtopic=414244
		;CloseHandle_(hFile) ; можно вызывать прямо здесь
		If hFileMapping
			*BaseAddress = MapViewOfFile_(hFileMapping,#FILE_MAP_ALL_ACCESS,0,0,0)
			If *BaseAddress
				*NtHdr32 = *BaseAddress+*BaseAddress\e_lfanew
				*NtHdr64 = *NtHdr32
				Is64 = Bool((*NtHdr32\FileHeader\Machine & $0000FFFF) = #IMAGE_FILE_MACHINE_AMD64) ; = $8664
				If Is64
					*ExportDir = *NtHdr64\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_EXPORT]\VirtualAddress
					;PrintT("ExportDir 64: RVA: "+Hex(*ExportDir)+" FOA: "+Hex(RVA2FOA(*BaseAddress,*ExportDir)))
					PSize = 8
				Else
					*ExportDir = *NtHdr32\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_EXPORT]\VirtualAddress
					;PrintT("ExportDir 32: RVA: "+Hex(*ExportDir)+" FOA: "+Hex(RVA2FOA(*BaseAddress,*ExportDir)))
					PSize = 4
				EndIf
				*ExportDir = RVA2A(*BaseAddress,*ExportDir)
				;PrintT("ExportDir: "+Hex(*ExportDir))
				;PrintT("NumberOfNames: "+Str(*ExportDir\NumberOfNames))
				;PrintT("AddressOfNames: "+Hex(*ExportDir\AddressOfNames))
				NumberOfNames = *ExportDir\NumberOfNames-1
				*AddressOfNames = RVA2A(*BaseAddress,*ExportDir\AddressOfNames)
				For iExportName=0 To NumberOfNames
					*AddressOfName = RVA2A(*BaseAddress,*AddressOfNames\l)
					FuncName1 = PeekS(*AddressOfName,-1,#PB_Ascii)
					;PrintT(Str(iExportName)+" "+FuncName1)
					n = FindString(FuncList1,";"+FuncName1+";")
					If n
						Changed = #True
						FuncName2 = Mid(FuncList2,n+1)
						n = FindString(FuncName2,";")
						If n
							FuncName2 = Trim(Left(FuncName2,n-1))
						EndIf
						PrintN("  "+FuncName1+" -> "+FuncName2)
						PokeS(*AddressOfName,FuncName2,-1,#PB_Ascii)
					EndIf
					*AddressOfNames+4
				Next
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
; CursorPosition = 175
; FirstLine = 153
; Folding = -
; Optimizer
; EnableThread
; Executable = ..\PPCorrectExportC.exe
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1.0.2.0
; VersionField1 = 1.0.2.0
; VersionField4 = 1.0.2.0
; VersionField5 = 1.0.2.0
; VersionField6 = PurePortable correct export
; VersionField7 = PPCorrectExport
; VersionField9 = (c) Smitis, 2020-2025