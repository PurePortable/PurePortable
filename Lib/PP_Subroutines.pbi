;;======================================================================================================================
; TODO:
; - https://vsokovikov.narod.ru/New_MSDN_API/Strings/functions_string.htm
;   CompareMemoryString -> lstrcmpi или CompareString/CompareStringEx
; - https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-strrchra
;;======================================================================================================================

;;======================================================================================================================
; Макросы для упрощения описания имортируемой функции
;;======================================================================================================================
UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro
Macro DeclareImport(LibName,Name32,Name64,FuncDeclaration)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		Import DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
EndMacro
Macro DeclareImportC(LibName,Name32,Name64,FuncDeclaration)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		ImportC DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		ImportC DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
EndMacro

;;======================================================================================================================
; Дополнительных импорты, отсутствующие или неправильные в стандартной поставке.
;;======================================================================================================================

; https://learn.microsoft.com/ru-ru/windows/win32/api/psapi/nf-psapi-getmoduleinformation
DeclareImport(psapi,_GetModuleInformation@16,GetModuleInformation,GetModuleInformation_(hProcess,hModule,*lpmodinfo,cb))

;;======================================================================================================================
; Выделение памяти в байтах
;;======================================================================================================================
;Macro SpaceX(size) : Space((size+1)/2) : EndMacro

; В MSDN написано, что у строковых данных в реестре иногда может отсутствовать завершающий ноль.
; Поэтому следует выделять буфер чуть большего размера и заполнять его окончание нулями.
; Так устраняются возможные проблемы с отсутствующим терминальным нулем.
Macro SpaceS(size) : Space(size+1) : EndMacro
; Выделение памяти в байтах для бинарных данных.
Macro SpaceB(size) : Space((size-1)/2) : EndMacro ; для чётного будет выделенно точно, для нечётного на один больше
;Macro SpaceB(size) : Space((size+1)/2) : EndMacro
; Выделение памяти в байтах для строки ascii с учётом нулевого.
Macro SpaceA(size) : Space(size/2) : EndMacro ; для чётного будет выделенно на один больше, для нечётного точно

Procedure.s UnicodeToAscii(s.s)
	Protected r.s = Space((Len(s)+1)/2)
	PokeS(@r,s,-1,#PB_Ascii)
	ProcedureReturn r
EndProcedure

;;======================================================================================================================
; Дополнительные процедуры.
;=======================================================================================================================

Procedure.i iif(c,a,b)
	If c : ProcedureReturn a : EndIf
	ProcedureReturn b
EndProcedure
Procedure.s iifs(c,a.s,b.s)
	If c : ProcedureReturn a : EndIf
	ProcedureReturn b
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; Более удобные преобразования Hex
Macro HexB(n) : Hex(n,#PB_Byte) : EndMacro
Macro HexBA(n) : RSet(Hex(n,#PB_Byte),2,"0") : EndMacro
Macro HexW(n) : Hex(n,#PB_Word) : EndMacro
Macro HexWA(n) : RSet(Hex(n,#PB_Word),4,"0") : EndMacro
Macro HexL(n) : Hex(n,#PB_Long) : EndMacro
;Macro HexL8(n) : RSet(Hex(n,#PB_Long),8,"0") : EndMacro ; depricated
Macro HexLA(n) : RSet(Hex(n,#PB_Long),8,"0") : EndMacro
Macro HexQ(n) : Hex(n,#PB_Quad) : EndMacro
Macro HexQA(n) : RSet(Hex(n,#PB_Quad),16,"0") : EndMacro

;;----------------------------------------------------------------------------------------------------------------------
; Поиск строки с конца
; Попробовать https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-strrchra
Procedure.i FindStringReverse(String.s,StringToFind.s,StartPosition=0,CaseInSensitive=#PB_String_CaseSensitive)
	If StartPosition = 0
		StartPosition = Len(String)
	;ElseIf StartPosition < 0
	;	StartPosition = Len(String)-StartPosition+1
	EndIf
	Protected length = Len(StringToFind)
	Protected *position = @String+(StartPosition-length)*SizeOf(Character)
	While *position >= @String
		If CompareMemoryString(*position,@StringToFind,CaseInSensitive,length) = 0
			ProcedureReturn (*position-@String)/SizeOf(Character)+1
		EndIf
		*position-SizeOf(Character)
	Wend
	ProcedureReturn 0
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; PeekS/PokeS с проверкой адреса.
Procedure.s PeekSZ(*MemoryBuffer,Length=-1,Format=#PB_Unicode)
	If *MemoryBuffer
		ProcedureReturn PeekS(*MemoryBuffer,Length,Format)
	EndIf
	ProcedureReturn ""
EndProcedure
Procedure PokeSZ(*MemoryBuffer,Text.s,Length=-1,Format=#PB_Unicode)
	If *MemoryBuffer
		ProcedureReturn PokeS(*MemoryBuffer,Text,Length,Format)
	EndIf
	ProcedureReturn 0
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; Чтение из памяти с проверкой указателя и преобразования в нижний регистр
Procedure.s LPeekSZU(*MemoryBuffer,cb=-1)
	If *MemoryBuffer
		ProcedureReturn LCase(PeekS(*MemoryBuffer,cb,#PB_Unicode))
	EndIf
	ProcedureReturn ""
EndProcedure
Procedure.s LPeekSZA(*MemoryBuffer,cb=-1)
	If *MemoryBuffer
		ProcedureReturn LCase(PeekS(*MemoryBuffer,cb,#PB_Ascii))
	EndIf
	ProcedureReturn ""
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; Запись в память с проверкой указателя
Procedure PokeSZU(*MemoryBuffer,Text.s,cb=-1)
	If *MemoryBuffer
		ProcedureReturn PokeS(*MemoryBuffer,Text,cb,#PB_Unicode)
	EndIf
	ProcedureReturn 0
EndProcedure
Procedure PokeSZA(*MemoryBuffer,Text.s,cb=-1)
	If *MemoryBuffer
		ProcedureReturn PokeS(*MemoryBuffer,Text,cb,#PB_Ascii)
	EndIf
	ProcedureReturn 0
EndProcedure

;=======================================================================================================================
; Коррекция путей
CompilerIf Not Defined(PROC_CORRECTPATH,#PB_Constant) : #PROC_CORRECTPATH = 0 : CompilerEndIf
CompilerIf Not Defined(PROC_CORRECTCFGPATH,#PB_Constant) : #PROC_CORRECTCFGPATH = 0 : CompilerEndIf
CompilerIf Not Defined(DBG_CORRECTPATH,#PB_Constant) : #DBG_CORRECTPATH = 0 : CompilerEndIf
CompilerIf #DBG_CORRECTPATH
	Macro DbgCorpath(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgCorpath(txt) : EndMacro
CompilerEndIf
CompilerIf #PROC_CORRECTPATH Or #PROC_CORRECTCFGPATH
	EnumerationBinary CORRECTPATH
		#CORRECTPATH_FROM_DEEP ; $0001
		#CORRECTPATH_REAL_PATH ; $0002 ; возвращается только реальный результат, если пути нет, то пустая строка, иначе строка без изменений.
		;#CORRECTPATH_CHECK_PATH = #CORRECTPATH_CHECK_PATH
		#CORRECTPATH_FORWARD_SLASH ; $0004
		#CORRECTPATH_DOUBLE_BACKSLASH ; $0008 ; TODO
		#CORRECTPATH_RELATIVE ; $0010 ; TODO возвращается путь относительно Base
		#CORRECTPATH_SAVE_BACKSLASH ; $0020 ; TODO сохранять последний слеш
	EndEnumeration
	; TODO:
	; Если Path изначально не содержит "\", файл не будет найден. Имеет ли смысл специально добавлять лидирующий "\"?
	Procedure.s CorrectPath(Path.s,Base.s,Flags=0)
		Protected i, NewPath.s, bs.s
		Protected LBase
		Base = RTrim(Base,"\")+"\"
		DbgCorpath("Base: "+Base)
		If Right(Path,1)="\"
			Path = RTrim(Path,"\")
			bs = "\" ; сохраним завершающий «\» для папок
		ElseIf Right(Path,1)="/"
			Path = RTrim(Path,"/")
			bs = "/" ; сохраним завершающий «/» для папок
		EndIf
		If Flags & #CORRECTPATH_FORWARD_SLASH
			Path = ReplaceString(Path,"/","\")
			;WindowsReplaceString_(@Path,"/","\",@Path)
		EndIf
		DbgCorpath("Path: "+Path)
		If Path
			If Flags & #CORRECTPATH_FROM_DEEP
				i = FindString(Path,"\")
				While i
					NewPath = Base+Mid(Path,i+1)
					DbgCorpath("   >> "+NewPath)
					If FileSize(NewPath)<>-1
						DbgCorpath("   == "+NewPath)
						If Flags & #CORRECTPATH_FORWARD_SLASH
							NewPath = ReplaceString(NewPath,"\","/")
						EndIf
						ProcedureReturn NewPath+bs
					EndIf
					i = FindString(Path,"\",i+1)
				Wend
			Else
				i = FindStringReverse(Path,"\")
				While i>0
					NewPath = Base+Mid(Path,i+1)
					DbgCorpath("   >> "+NewPath)
					If FileSize(NewPath)<>-1
						DbgCorpath("   == "+NewPath)
						If Flags & #CORRECTPATH_FORWARD_SLASH
							NewPath = ReplaceString(NewPath,"\","/")
						EndIf
						ProcedureReturn NewPath+bs
					EndIf
					i = FindStringReverse(Path,"\",i-1)
				Wend
			EndIf
		EndIf
		; Путь не найден
		If Flags & #CORRECTPATH_REAL_PATH
			ProcedureReturn ""
		EndIf
		If Flags & #CORRECTPATH_FORWARD_SLASH
			Path = ReplaceString(Path,"\","/")
		EndIf
		ProcedureReturn Path+bs
	EndProcedure
CompilerEndIf

;=======================================================================================================================
CompilerIf Not Defined(PROC_ADDARRAYS,#PB_Constant) : #PROC_ADDARRAYS = 0 : CompilerEndIf
;CompilerIf #PROC_ADDARRAYS
Procedure AddArrayS(Array arr.s(1),v.s)
	Protected n = ArraySize(arr())+1
	ReDim arr(n)
	arr(n) = v
	ProcedureReturn n
EndProcedure
;CompilerEndIf
	
;=======================================================================================================================
CompilerIf Not Defined(PROC_ADDARRAYI,#PB_Constant) : #PROC_ADDARRAYI = 0 : CompilerEndIf
;CompilerIf #PROC_ADDARRAYI
Procedure AddArrayI(Array arr.i(1),v.i)
	Protected n = ArraySize(arr())+1
	ReDim arr(n)
	arr(n) = v
EndProcedure
;CompilerEndIf

;=======================================================================================================================
CompilerIf Not Defined(PROC_ARRAY,#PB_Constant) : #PROC_ARRAY = 0 : CompilerEndIf
;CompilerIf #PROC_ARRAY
	; Нулевой элемент не используется.
	; Если строка (в том числе и пустая) не содержит разделителя, добавиться только один элемент.
	; Если строка заканчивается разделителем, последний элемент будет пустым.
	; Если строка состоит из одного разделителя, будет два пустых элемента и т.д.
Procedure.i SplitArray(Array a.s(1),s.s,d.s=";")
	Protected p1, p2
	Protected n
	ReDim a(0)
	If s
		p2 = FindString(s,d)
		If p2
			While p2
				n + 1
				ReDim a(n)
				a(n) = Mid(s,p1+1,p2-p1-1)
				p1 = p2
				p2 = FindString(s,d,p2+1)
			Wend
			If p1
				n + 1
				ReDim a(n)
				a(n) = Mid(s,p1+1)
			EndIf
		Else
			n = 1
			ReDim a(1)
			a(1) = s
		EndIf
	EndIf
	;Protected i
	;dbg("Split Array: "+Str(ArraySize(a())))
	;For i=1 To ArraySize(a())
	;	dbg("«"+a(i)+"»")
	;Next
	ProcedureReturn n
EndProcedure
Procedure.s JoinArray(Array a.s(1),d.s)
	Protected i
	Protected n = ArraySize(a())
	Protected Result.s
	If n
		;dbg("Join Array: "+Str(n))
		Result = a(1)
		;dbg("1: "+a(1))
		For i=2 To n
			;dbg(Str(i)+": "+a(i))
			Result + d + a(i)
		Next
	EndIf
	ProcedureReturn Result
EndProcedure
;CompilerEndIf

;=======================================================================================================================
;{ Дополнительные процедуры. Константы оставлены только для совместимости.
CompilerIf Not Defined(PROC_FINDMEMORYSTRING,#PB_Constant) : #PROC_FINDMEMORYSTRING = 0 : CompilerEndIf
CompilerIf #PROC_FINDMEMORYSTRING
	XIncludeFile "Proc\FindMemoryString.pbi"	
CompilerEndIf
CompilerIf Not Defined(PROC_REPLACEMEMORYSTRING,#PB_Constant) : #PROC_REPLACEMEMORYSTRING = 0 : CompilerEndIf
CompilerIf #PROC_REPLACEMEMORYSTRING
	XIncludeFile "Proc\FindMemoryString.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_REPLACEMEMORYBINARY,#PB_Constant) : #PROC_REPLACEMEMORYBINARY = 0 : CompilerEndIf
CompilerIf #PROC_REPLACEMEMORYBINARY
	XIncludeFile "Proc\ReplaceMemoryBinary.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_GETBITNESS,#PB_Constant) : #PROC_GETBITNESS = 0 : CompilerEndIf
CompilerIf #PROC_GETBITNESS
	XIncludeFile "Proc\GetBitness.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_GETFILEBITNESS,#PB_Constant) : #PROC_GETFILEBITNESS = 0 : CompilerEndIf
CompilerIf #PROC_GETFILEBITNESS
	XIncludeFile "Proc\GetFileBitness.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_CORRECTCHECKSUM,#PB_Constant) : #PROC_CORRECTCHECKSUM = 0 : CompilerEndIf
CompilerIf #PROC_CORRECTCHECKSUM
	XIncludeFile "Proc\CorrectCheckSum.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_CORRECTCHECKSUMADR,#PB_Constant) : #PROC_CORRECTCHECKSUMADR = 0 : CompilerEndIf
CompilerIf #PROC_CORRECTCHECKSUMADR
	XIncludeFile "Proc\CorrectCheckSumAdr.pbi"
CompilerEndIf
CompilerIf Not Defined(PROC_REMOVECERTIFICATES,#PB_Constant) : #PROC_REMOVECERTIFICATES = 0 : CompilerEndIf
CompilerIf #PROC_REMOVECERTIFICATES
	XIncludeFile "Proc\RemoveCertificates.pbi"
CompilerEndIf
;}
;=======================================================================================================================
; https://docs.microsoft.com/ru-ru/windows/win32/debug/retrieving-the-last-error-code
;CompilerIf Not Defined(PROC_GETLASTERRORSTR,#PB_Constant) : #PROC_GETLASTERRORSTR = 0 : CompilerEndIf
;CompilerIf #PROC_GETLASTERRORSTR
Procedure.s GetLastErrorStr(Error=0)
	If Error=0
		Error = GetLastError_()
	EndIf
	Protected *Buffer, Result.s
	Protected Length = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER|#FORMAT_MESSAGE_FROM_SYSTEM,0,Error,0,@*Buffer,0,0)
	If Length
		Result = PeekS(*Buffer,Length-2) ; кроме последнего перевода строки
		LocalFree_(*Buffer)
		ProcedureReturn StrU(Error)+": "+Result
	EndIf
EndProcedure
;=======================================================================================================================
Procedure PPErrorMessage(Msg.s,Error=-1)
	If Error<>-1
		Msg + #CR$+GetLastErrorStr(Error)
	EndIf
	MessageBox_(0,Msg,"PurePortable ("+StrU(GetCurrentProcessID_())+")",#MB_ICONERROR)
EndProcedure
;=======================================================================================================================
CompilerIf Not Defined(PROC_NORMALIZEPATH,#PB_Constant) : #PROC_NORMALIZEPATH = 0 : CompilerEndIf
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfullpathnamew
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathcanonicalizew
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathremovebackslashw
; https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats
;CanonicalizePath
;CompilerIf #PROC_NORMALIZEPATH
Procedure.s NormalizePath(Path.s)
	If Path ; Иначе вернём корень текущего диска
		Protected NewPath.s = Path + "\."
		Protected *Buf
		Protected LenBuf = GetFullPathName_(@NewPath,0,#Null,#Null)
		If LenBuf
			*Buf = AllocateMemory(LenBuf*2)
			GetFullPathName_(@NewPath,LenBuf,*Buf,#Null)
			NewPath = PeekS(*Buf)
			FreeMemory(*Buf)
			ProcedureReturn NewPath
		EndIf
	EndIf
	ProcedureReturn Path
EndProcedure
;{ Procedure.s NormalizePath2(Path.s)
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
;}
;CompilerEndIf

;=======================================================================================================================
; https://www.rsdn.org/article/qna/baseserv/fileexist.xml
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsa
; Функции PathFileExists и PathIsDirectory работают неадекватно!
Procedure FileExist(fn.s)
	ProcedureReturn Bool(GetFileAttributes_(@fn)&#FILE_ATTRIBUTE_DIRECTORY=0)
	;ProcedureReturn PathFileExists_(@fn)
EndProcedure
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectorya
Procedure DirectoryExist(fn.s)
	Protected attr = GetFileAttributes_(@fn)
	ProcedureReturn Bool(attr<>#INVALID_FILE_ATTRIBUTES And (attr&#FILE_ATTRIBUTE_DIRECTORY))
	;ProcedureReturn PathIsDirectory_(@fn)
EndProcedure
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shcreatedirectoryexw
;DeclareImport(shell32,_SHCreateDirectoryExW@12,SHCreateDirectoryExW,SHCreateDirectoryEx_(hWnd,*pszPath,*psa))
Procedure CreatePath(Path.s)
	;SHCreateDirectoryEx_(0,@Path,#Null) ; может неправильно работать из dllmain
	Path = RTrim(Path,"\")+"\"
	Protected p = FindString(Path,"\")
	While p
		CreateDirectory(Left(Path,p-1))
		p = FindString(Path,"\",p+1)
	Wend
EndProcedure
;=======================================================================================================================
;{ Проверка версии/имени файла

; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfoa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfoexa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfosizea
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-getfileversioninfosizeexa
; https://learn.microsoft.com/ru-ru/windows/win32/api/winver/nf-winver-verqueryvaluew

Macro ValidateProgram(N,R,V,L=0,CP="")
	If Not _ValidateProgram(GetFileVersionInfo(PrgPath,R,CP),V,L)
		CompilerSelect N
			CompilerCase 1		
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerCase 2		
				ProcedureReturn
			CompilerCase 3		
				Goto EndAttach
		CompilerEndSelect
	EndIf
EndMacro
Macro ValidateProgramL(N,R,V,L=0,CP="")
	If Not _ValidateProgramL(GetFileVersionInfo(PrgPath,R,CP),V,L)
		CompilerSelect N
			CompilerCase 1		
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerCase 2		
				ProcedureReturn
			CompilerCase 3		
				Goto EndAttach
		CompilerEndSelect
	EndIf
EndMacro
Macro ValidateProgramName(N,V,L=0)
	If Not _ValidateProgram(PrgName,V,L)
		CompilerSelect N
			CompilerCase 1		
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerCase 2		
				ProcedureReturn
			CompilerCase 3		
				Goto EndAttach
		CompilerEndSelect
	EndIf
EndMacro
Macro ValidateProgramNameL(N,V,L=0)
	If Not _ValidateProgramL(PrgName,V,L)
		CompilerSelect N
			CompilerCase 1		
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			CompilerCase 2		
				ProcedureReturn
			CompilerCase 3		
				Goto EndAttach
		CompilerEndSelect
	EndIf
EndMacro

CompilerIf Not Defined(PROC_GETVERSIONINFO,#PB_Constant) : #PROC_GETVERSIONINFO = 1 : CompilerEndIf
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
Procedure _ValidateProgram(w.s,v.s,l=0)
	CharLower_(@w)
	CharLower_(@v)
	ProcedureReturn Bool((l=0 And w=v) Or (l=1 And Left(w,Len(v))=v) Or (l>1 And Left(w,l)=v) Or (l=-1 And Right(w,Len(v))=v) Or (l<0 And Right(w,-l)=v))
EndProcedure
Procedure _ValidateProgramL(w.s,v.s,l=0)
	CharLower_(@w)
	CharLower_(@v)
	Protected Dim a.s(0)
	Protected n = SplitArray(a(),v)
	Protected i
	For i=1 To n
		v = a(i)
		If (l=0 And w=v) Or (l=1 And Left(w,Len(v))=v) Or (l>1 And Left(w,l)=v) Or (l=-1 And Right(w,Len(v))=v) Or (l<0 And Right(w,-l)=v)
			ProcedureReturn i
		EndIf
	Next
	ProcedureReturn 0
EndProcedure
;CompilerEndIf
;}
;=======================================================================================================================
Procedure.s bin2hex(*pb.Byte,cb)
	Protected *end = *pb + cb
	Protected Result.s = Space(cb*2) ; по два символа на каждый байт
	Protected *pc = @Result
	While *pb < *end
		PokeS(*pc,RSet(Hex(*pb\b,#PB_Byte),2,"0")) ; пишем по два символа + 0; последний 0 ляжет на 0 в конце строки
		*pb + 1
		*pc + 2 + 2
	Wend
	ProcedureReturn Result
EndProcedure
;=======================================================================================================================
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpnw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpiw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpniw
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	Import "shlwapi.lib" : StrCmp(psz1,psz2) As "_StrCmpW@8" : EndImport
	Import "shlwapi.lib" : StrCmpI(psz1,psz2) As "_StrCmpIW@8" : EndImport
	Import "shlwapi.lib" : StrCmpN(psz1,psz2,nChar) As "_StrCmpNW@12" : EndImport
	Import "shlwapi.lib" : StrCmpNI(psz1,psz2,nChar) As "_StrCmpNIW@12" : EndImport
CompilerElse
	Import "shlwapi.lib" : StrCmp(psz1,psz2) As "StrCmpW" : EndImport
	Import "shlwapi.lib" : StrCmpI(psz1,psz2) As "StrCmpIW" : EndImport
	Import "shlwapi.lib" : StrCmpN(psz1,psz2,nChar) As "StrCmpNW" : EndImport
	Import "shlwapi.lib" : StrCmpNI(psz1,psz2,nChar) As "StrCmpNIW" : EndImport
CompilerEndIf
Procedure.i StartWith(s.s,t.s,cs=0)
	Protected l = Len(t)
	If cs
		ProcedureReturn Bool(StrCmpN(@s,@t,l)=0)
	EndIf
	ProcedureReturn Bool(StrCmpNI(@s,@t,l)=0)
EndProcedure
Procedure.i StartWithPath(s.s,t.s,cs=0)
	StrTrim_(@t,"\")
	Protected l = Len(t)
	;dbg("StartWithPath")
	;dbg("  "+s)
	;dbg("  "+t)
	;dbg("  "+Str(StrCmpNI(@s,@t,l)))
	;dbg("  "+Chr(PeekW(@s+l<<1)))
	If cs
		ProcedureReturn Bool(StrCmp(@s,@t)=0 Or (StrCmpN(@s,@t,l)=0 And PeekW(@s+l<<1)=92))
	EndIf
	ProcedureReturn Bool(StrCmpI(@s,@t)=0 Or (StrCmpNI(@s,@t,l)=0 And PeekW(@s+l<<1)=92))
EndProcedure
;=======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 632
; FirstLine = 235
; Folding = ---ADMQ9-
; EnableAsm
; EnableThread
; DisableDebugger
; EnableExeConstant