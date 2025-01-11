;;======================================================================================================================
; PurePortableSimple Extention
; Расширение для обработки ini-файлов
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.6
;RES_DESCRIPTION PurePortableSimpleExtension
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePortExecute.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\PPDK\Lib"

#DBG_EXTENSION = 0
XIncludeFile "PurePortableExtension.pbi"

;;======================================================================================================================
;{ Работа с ini-файлами
Structure INIDATA
	Section.s
	SectionL.s
	Key.s
	KeyL.s
	Value.s
	Deleted.i
	Plain.i
EndStructure
Global Dim IniData.INIDATA(0)
Global IniFile.s,IniChanged,IniSize,IniCodepage
Procedure IniRead(Ini.s)
	;IniFile = PrgDir+Ini
	IniFile = Ini
	IniChanged = #False
	IniSize = 0
	IniCodepage = 0
	ReDim IniData(0)
	Protected CurrentSection.s,CurrentSectionL.s
	Protected s.s, x
	Protected hIni = ReadFile(#PB_Any,IniFile)
	If hIni
		IniCodepage=ReadStringFormat(hIni)
		While Eof(hIni)=0
			s=RTrim(ReadString(hIni,IniCodepage))
			If Left(s,1)="[" And Right(s,1)="]"
				CurrentSection = Mid(s,2,Len(s)-2)
				CurrentSectionL = LCase(CurrentSection)
				;dbg("Section: "+CurrentSection)
			Else
				x=FindString(s,"=")
				IniSize+1
				ReDim IniData(IniSize)
				IniData(IniSize)\Section = CurrentSection
				IniData(IniSize)\SectionL = CurrentSectionL
				If x
					IniData(IniSize)\Key = Left(s,x-1)
					IniData(IniSize)\KeyL = LCase(IniData(IniSize)\Key)
					IniData(IniSize)\Value = Mid(s,x+1)
					;dbg(IniData(IniSize)\Key+" :: "+IniData(IniSize)\Value)
				Else
					IniData(IniSize)\Key = s
					IniData(IniSize)\Plain = #True
				EndIf
			EndIf
		Wend
		CloseFile(hIni)
	EndIf
EndProcedure
Procedure IniWrite()
	;SortStructuredArray(IniData(),#PB_Sort_Ascending+#PB_Sort_NoCase,OffsetOf(INIDATA\SectionL),TypeOf(INIDATA\SectionL),1,n)
	Protected CurrentSection.s
	Protected i, j, hIni
	If IniChanged
		hIni = CreateFile(#PB_Any,IniFile,#PB_File_SharedWrite|IniCodepage)
		If hIni
			IniChanged = #False
			For i=1 To IniSize
				If Not IniData(i)\Deleted
					If CurrentSection<>IniData(i)\SectionL ; начало новой секции
						CurrentSection = IniData(i)\SectionL
						WriteStringN(hIni,"["+IniData(i)\Section+"]",IniCodepage)
					EndIf
					If IniData(i)\Plain
						DbgExt("IniWrite: "+IniData(i)\Key)
						WriteStringN(hIni,IniData(i)\Key,IniCodepage)
					Else
						DbgExt("IniWrite: "+IniData(i)\Key+"="+IniData(i)\Value)
						WriteStringN(hIni,IniData(i)\Key+"="+IniData(i)\Value,IniCodepage)
					EndIf
					; Чтобы склеить секцию, ищем все ключи этой секции
					For j=i+1 To IniSize
						If Not IniData(j)\Deleted And CurrentSection=IniData(j)\SectionL
							If IniData(j)\Plain
								DbgExt("IniWrite: "+IniData(j)\Key)
								WriteStringN(hIni,IniData(j)\Key,IniCodepage)
							Else
								DbgExt("IniWrite: "+IniData(j)\Key+"="+IniData(j)\Value)
								WriteStringN(hIni,IniData(j)\Key+"="+IniData(j)\Value,IniCodepage)
							EndIf
							IniData(j)\Deleted = #True ; больше обрабатывать не надо
						EndIf
					Next
				EndIf
			Next
			CloseFile(hIni)
		EndIf
	EndIf
EndProcedure
Procedure IniSetKey(Key.s,Value.s)
	Protected i
	Protected k.s = LCase(Key)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k
			If IniData(i)\Value<>Value
				IniData(i)\Value = Value
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
EndProcedure
Procedure IniCorrectKey(Key.s,Base.s,Flags=0)
	Protected i, Path.s
	Protected k.s = LCase(Key)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k
			DbgExt("IniCorrectKey: < "+IniData(i)\Value)
			Path = CorrectPath(IniData(i)\Value,Base,Flags)
			If IniData(i)\Value<>Path
				DbgExt("IniCorrectKey: > "+Path)
				IniData(i)\Value = Path
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
EndProcedure
Procedure IniSet(Section.s,Key.s,Value.s)
	Protected i
	Protected k.s = LCase(Key)
	Protected s.s = LCase(Section)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k And IniData(i)\SectionL=s
			If IniData(i)\Value<>Value
				IniData(i)\Value = Value
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
	If i>IniSize ; не найдено, добавляем
		IniSize = i
		ReDim IniData(i)
		IniData(i)\Key = Key
		IniData(i)\KeyL = LCase(Key)
		IniData(i)\Value = Value
		IniData(i)\Section = Section
		IniData(i)\SectionL = LCase(Section)
		IniChanged = #True
	EndIf
EndProcedure
Procedure IniCorrect(Section.s,Key.s,Base.s,Flags=0)
	Protected i, Path.s
	Protected k.s = LCase(Key)
	Protected s.s = LCase(Section)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k And IniData(i)\SectionL=s
			DbgExt("IniCorrect: < "+IniData(i)\Value)
			Path = CorrectPath(IniData(i)\Value,Base,Flags)
			DbgExt("IniCorrect: > "+Path)
			If IniData(i)\Value<>Path
				IniData(i)\Value = Path
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
EndProcedure
;}
;;======================================================================================================================
Prototype CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
Global Original_CreateFile2.CreateFile2
Procedure Detour_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams) ; всегда unicode?
	dbg("CreateFile2: "+PeekS(lpFileName))
	ProcedureReturn Original_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
EndProcedure
Prototype CreateFile(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
Global Original_CreateFileA.CreateFile
Procedure Detour_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	dbg("CreateFileA: "+PeekS(lpFileName,-1,#PB_Ascii))
	ProcedureReturn Original_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
EndProcedure
Global Original_CreateFileW.CreateFile
Procedure Detour_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	dbg("CreateFileW: "+PeekS(lpFileName))
	ProcedureReturn Original_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
EndProcedure

;;======================================================================================================================

Procedure ExtensionProcedure()
	dbg("PurePort Extension Test")
	MHX_HookApi(kernel32,CreateFileA)
	MHX_HookApi(kernel32,CreateFileW)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 210
; FirstLine = 37
; Folding = B+
; Optimizer
; EnableThread
; Executable = PurePortIni.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.31
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.31
; VersionField6 = PurePortableSimpleExtension
; VersionField7 = PurePortIni.dll
; VersionField9 = (c) Smitis, 2017-2025