;;======================================================================================================================
; Проверка версии/имени файла

; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfoa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfoexa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfosizea
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfosizeexa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-verqueryvaluew

;CompilerIf Not Defined(PROC_GETVERSIONINFO,#PB_Constant) : #PROC_GETVERSIONINFO = 1 : CompilerEndIf

;CompilerIf #PROC_GETVERSIONINFO
; Enumeration
; 	#FVI_FileVersion      = $0001
; 	#FVI_FileDescription  = $0002
; 	#FVI_LegalCopyright   = $0004
; 	#FVI_InternalName     = $0008
; 	#FVI_OriginalFilename = $0010
; 	#FVI_ProductName      = $0020
; 	#FVI_ProductVersion   = $0040
; 	#FVI_CompanyName      = $0080
; 	#FVI_LegalTrademarks  = $0100
; 	#FVI_SpecialBuild     = $0200
; 	#FVI_PrivateBuild     = $0400
; 	#FVI_Comments         = $0800
; 	#FVI_Language         = $1000
; 	#FVI_Email            = $1001
; 	#FVI_Website          = $1002
; 	#FVI_Special          = $1003
; EndEnumeration

Structure LANGANDCODEPAGE
	wLanguage.w
	wCodePage.w
EndStructure
Prototype GetFileVersionInfo(*lptstrFilename,dwHandle,dwLen,*lpData)
Prototype GetFileVersionInfoEx(dwFlags.l,*lptstrFilename,dwHandle,dwLen,*lpData)
Prototype GetFileVersionInfoSize(*lptstrFilename,*lpdwHandle)
Prototype GetFileVersionInfoSizeEx(dwFlags.l,*lptstrFilename,*lpdwHandle)
Prototype VerQueryValue(pBlock,*lpSubBlock,*lplpBuffer,puLen)

Procedure.s GetFileVersionInfo(FileName.s,SubBlock.s="FileVersion",LangAndCodepage.s="")
	Protected ModulePath.s = Space(#MAX_PATH)
	GetSystemDirectory_(@ModulePath,#MAX_PATH)
	ModulePath = RTrim(ModulePath,"\")+"\version.dll"
	;Protected hModule = LoadLibrary_(ModulePath)
	;Protected _GetFileVersionInfo.GetFileVersionInfo = GetProcAddress_(hModule,"GetFileVersionInfoW")
	;Protected _GetFileVersionInfoSize.GetFileVersionInfoSize = GetProcAddress_(hModule,"GetFileVersionInfoSizeW")
	;Protected _VerQueryValue.VerQueryValue = GetProcAddress_(hModule,"VerQueryValueW")
	Protected hModule = OpenLibrary(#PB_Any,ModulePath)
	Protected _GetFileVersionInfo.GetFileVersionInfo = GetFunction(hModule,"GetFileVersionInfoW")
	Protected _GetFileVersionInfoSize.GetFileVersionInfoSize = GetFunction(hModule,"GetFileVersionInfoSizeW")
	Protected _VerQueryValue.VerQueryValue = GetFunction(hModule,"VerQueryValueW")
	Protected Bytes, Handle
	Protected *lpData, *StringBuffer
	Protected Result.s
	Protected InfoSize = _GetFileVersionInfoSize(@FileName,@Handle)
	Protected *lplpBuffer.LANGANDCODEPAGE
	If InfoSize
		*lpData = AllocateMemory(InfoSize)
		If _GetFileVersionInfo(@FileName,0,InfoSize,*lpData)
			If LangAndCodepage="" ; берём первую кодовую страницу
				If _VerQueryValue(*lpData,@"\VarFileInfo\Translation",@*lplpBuffer,@Bytes)
					LangAndCodepage = RSet(Hex(*lplpBuffer\wLanguage),4,"0") + RSet(Hex(*lplpBuffer\wCodePage),4,"0")
				EndIf
			EndIf
			If LangAndCodepage
				SubBlock ="\StringFileInfo\" + LangAndCodepage + "\" + SubBlock
				;dbg(SubBlock)
				If _VerQueryValue(*lpData,@SubBlock,@*StringBuffer,@Bytes) ;And Bytes
					;dbg("Bytes: "+Str(Bytes))
					Result = PeekS(*StringBuffer) ;,Bytes)
				EndIf
				;dbg("Result: "+Result)
			EndIf
		EndIf
		FreeMemory(*lpData)
	EndIf
	;FreeLibrary_(hModule)
	CloseLibrary(hModule)
	ProcedureReturn Result
EndProcedure

; Результат проверки программы, возвращаемые AttachProcedure и CheckProgram
#VALID_PROGRAM = 0
#INVALID_PROGRAM = 1

; Реакция на проверку программы
#VALIDATE_PROGRAM_OFF = 0
#VALIDATE_PROGRAM_TERMINATE = 1
#VALIDATE_PROGRAM_CONTINUE = 2

; Способ сравнения
#COMPARE_WITH_EXACT = 0
#COMPARE_WITH_BEGIN = 1
#COMPARE_WITH_END = -1

; Макросы ValidateProgram и ValidateProgramL идентичны, ValidateProgramL оставленно для совместимости.
Macro ValidateProgram(Reaction,SubBlock,Value,Lenght=#COMPARE_WITH_BEGIN,CodePage="")
	CompilerIf Reaction<>#VALIDATE_PROGRAM_OFF
		If Not CompareWithList(GetFileVersionInfo(PrgPath,SubBlock,CodePage),Value,Lenght)
			CompilerIf Reaction=#VALIDATE_PROGRAM_TERMINATE
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerEndIf
			ProcedureReturn #INVALID_PROGRAM
		EndIf
	CompilerEndIf
EndMacro
Macro ValidateProgramL(Reaction,SubBlock,Value,Lenght=#COMPARE_WITH_BEGIN,CodePage="")
	CompilerIf Reaction<>#VALIDATE_PROGRAM_OFF
		If Not CompareWithList(GetFileVersionInfo(PrgPath,SubBlock,CodePage),Value,Lenght)
			CompilerIf Reaction=#VALIDATE_PROGRAM_TERMINATE
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerEndIf
			ProcedureReturn #INVALID_PROGRAM
		EndIf
	CompilerEndIf
EndMacro

; Макросы ValidateProgramName и ValidateProgramNameL идентичны, ValidateProgramNameL оставленно для совместимости.
Macro ValidateProgramName(Reaction,Value,Lenght=#COMPARE_WITH_BEGIN)
	CompilerIf Reaction<>#VALIDATE_PROGRAM_OFF
		If Not CompareWithList(PrgName,Value,Lenght)
			CompilerIf Reaction=#VALIDATE_PROGRAM_TERMINATE
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerEndIf
			ProcedureReturn #INVALID_PROGRAM
		EndIf
	CompilerEndIf
EndMacro
Macro ValidateProgramNameL(Reaction,Value,Lenght=#COMPARE_WITH_BEGIN)
	CompilerIf Reaction<>#VALIDATE_PROGRAM_OFF
		If Not CompareWithList(PrgName,Value,Lenght)
			CompilerIf Reaction=#VALIDATE_PROGRAM_TERMINATE
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerEndIf
			ProcedureReturn #INVALID_PROGRAM
		EndIf
	CompilerEndIf
EndMacro

;{ Procedure CompareWith(Value1.s,Value2.s,Lenght=COMPARE_WITH_BEGIN)
; 	CharLower_(@Value1)
; 	CharLower_(@Value2)
; 	ProcedureReturn Bool((Lenght=#COMPARE_WITH_EXACT And Value1=Value2) Or (Lenght=#COMPARE_WITH_BEGIN And Left(Value1,Len(Value2))=Value2) Or (Lenght>#COMPARE_WITH_BEGIN And Left(Value1,Lenght)=Value2) Or (Lenght=#COMPARE_WITH_END And Right(Value1,Len(Value2))=Value2) Or (Lenght<#COMPARE_WITH_END And Right(Value1,-Lenght)=Value2))
;} EndProcedure

Procedure CompareWithList(Value1.s,Value2.s,Lenght=#COMPARE_WITH_BEGIN)
	CharLower_(@Value1)
	CharLower_(@Value2)
	Protected Dim a.s(0)
	Protected n = SplitArray(a(),Value2,"|")
	Protected i
	For i=1 To n
		Value2 = a(i)
		If (Lenght=#COMPARE_WITH_EXACT And Value1=Value2) Or (Lenght=#COMPARE_WITH_BEGIN And Left(Value1,Len(Value2))=Value2) Or (Lenght>#COMPARE_WITH_BEGIN And Left(Value1,Lenght)=Value2) Or (Lenght=#COMPARE_WITH_END And Right(Value1,Len(Value2))=Value2) Or (Lenght<#COMPARE_WITH_END And Right(Value1,-Lenght)=Value2)
			ProcedureReturn #True
		EndIf
	Next
	ProcedureReturn #False
EndProcedure

;CompilerEndIf
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 90
; FirstLine = 37
; Folding = +-
; EnableThread
; DisableDebugger
; EnableExeConstant