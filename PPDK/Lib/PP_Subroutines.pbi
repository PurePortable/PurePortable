;;======================================================================================================================
; TODO:
; - https://vsokovikov.narod.ru/New_MSDN_API/Strings/functions_string.htm
;   CompareMemoryString -> lstrcmpi или CompareString/CompareStringEx
; - https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-strrchra
;;======================================================================================================================

;;======================================================================================================================
; Макросы для упрощения описания имортируемой функции
XIncludeFile "winapi\DeclareImportMacro.pbi"

;;======================================================================================================================
; Дополнительных импорты, отсутствующие или неправильные в стандартной поставке.
;;======================================================================================================================

DeclareImport(psapi,_GetModuleInformation@16,GetModuleInformation,GetModuleInformation_(hProcess,hModule,*lpmodinfo,cb))

#GET_MODULE_HANDLE_EX_FLAG_PIN = 1
#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = 4
DeclareImport(kernel32,_GetModuleHandleExW@12,GetModuleHandleExW,GetModuleHandleEx_(dwFlags.l,*lpModuleName,*phModule))

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

; Procedure.s UnicodeToAscii(s.s)
; 	Protected r.s = Space((Len(s)+1)/2)
; 	PokeS(@r,s,-1,#PB_Ascii)
; 	ProcedureReturn r
; EndProcedure

;;======================================================================================================================
; Дополнительные процедуры.
;;======================================================================================================================

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

;;======================================================================================================================
Procedure AddArrayS(Array arr.s(1),v.s)
	Protected n = ArraySize(arr())+1
	ReDim arr(n)
	arr(n) = v
	ProcedureReturn n
EndProcedure
Procedure AddArrayI(Array arr.i(1),v.i)
	Protected n = ArraySize(arr())+1
	ReDim arr(n)
	arr(n) = v
EndProcedure

;;======================================================================================================================
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

;;======================================================================================================================
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
;;======================================================================================================================
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
;;----------------------------------------------------------------------------------------------------------------------
Procedure PPErrorMessage(Msg.s,Error)
	MessageBox_(0,Msg,"PurePortable ("+StrU(ProcessID)+")",#MB_ICONERROR)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Procedure PPLastErrorMessage(Msg.s)
	PPErrorMessage(Msg,GetLastError_())
EndProcedure
;;======================================================================================================================

XIncludeFile "proc\FindStringReverse.pbi"
XIncludeFile "proc\Exist.pbi"
XIncludeFile "proc\CreatePath.pbi"
XIncludeFile "proc\NormalizePath.pbi"
XIncludeFile "proc\CorrectPath.pbi"

; CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 	Import "shlwapi.lib" : StrTrim(psz1,psz2) As "_StrTrimW@8" : EndImport
; CompilerElse
; 	Import "shlwapi.lib" : StrTrim(psz1,psz2) As "StrTrimW" : EndImport
; CompilerEndIf

;;======================================================================================================================

; https://learn.microsoft.com/en-us/windows/win32/shell/shlwapi-string
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpnw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpiw
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strcmpniw

DeclareImport(shlwapi,_StrCmpW@8,StrCmpW,StrCmp(*psz1,*psz2))
DeclareImport(shlwapi,_StrCmpIW@8,StrCmpIW,StrCmpI(*psz1,*psz2))
DeclareImport(shlwapi,_StrCmpNW@12,StrCmpNW,StrCmpN(*psz1,*psz2,nChar))
DeclareImport(shlwapi,_StrCmpNIW@12,StrCmpNIW,StrCmpNI(*psz1,*psz2,nChar))

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
	If cs
		ProcedureReturn Bool(StrCmp(@s,@t)=0 Or (StrCmpN(@s,@t,l)=0 And PeekW(@s+l<<1)=92))
	EndIf
	ProcedureReturn Bool(StrCmpI(@s,@t)=0 Or (StrCmpNI(@s,@t,l)=0 And PeekW(@s+l<<1)=92))
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = n-BAh
; EnableAsm
; EnableThread
; DisableDebugger
; EnableExeConstant