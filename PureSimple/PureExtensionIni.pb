;;======================================================================================================================
; PurePortableSimple Extention
; Расширение для обработки ini-файлов
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.31
;RES_DESCRIPTION PurePortableSimpleExtension
;RES_COPYRIGHT (c) Smitis, 2017-2024
;RES_INTERNALNAME PurePortIni.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS "..\Temp\PurePortTxt32.dll"
;PP_X64_COPYAS "..\Temp\PurePortTxt64.dll"
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

Global *ExtData.EXT_DATA

Structure INIFILE
	num.s
	ini.s
	cp.i
EndStructure
Global Dim Inis.INIFILE(0), iInis, nInis

Procedure ExtensionProcedure()
	Protected i, k.s, v.s, g.s, p.s
	Protected IniNum.s, IniFile.s, IniPref.s, IniGroup.s
	If OpenPreferences(ExtPrefs,#PB_Preference_NoSpace)
		; Составляем список ini-файлов
		If PreferenceGroup("IniFiles")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				k = LCase(PreferenceKeyName())
				v = PreferencePath()
				;dbg("PurePortIni: "+v)
				nInis+1
				ReDim Inis(nInis)
				Inis(nInis)\num = k
				Inis(nInis)\ini = v
			Wend
		EndIf
		; Перебираем все ini-файлы
		For iInis=1 To nInis
			IniNum = Inis(iInis)\num
			IniFile = Inis(iInis)\ini
			IniRead(IniFile)
			DbgExt("PurePortIni: "+IniNum+" :: "+IniFile)
			If PreferenceGroup(IniNum) ; общие данные для ini-файла
			EndIf
			IniPref = IniNum+":"
			ExaminePreferenceGroups()
			While NextPreferenceGroup()
				IniGroup = PreferenceGroupName()
				If Left(IniGroup,Len(IniPref)) = IniPref ; группа, имеющая отношение к ini-файлу
					Select LCase(Mid(IniGroup,Len(IniPref)+1))
						Case "correctpaths"
							ExaminePreferenceKeys()
							While NextPreferenceKey()
								k = PreferenceKeyName()
								v = PreferencePath()
								i = FindString(k,"|")
								If i
									IniCorrect(Left(k,i-1),Mid(k,i+1),v)
								Else
									IniCorrectKey(k,v)
								EndIf
							Wend
						Case "setpaths"
							ExaminePreferenceKeys()
							While NextPreferenceKey()
								k = PreferenceKeyName()
								v = PreferencePath(ExpandEnvironmentStrings(PreferenceKeyValue()))
								i = FindString(k,"|")
								If i
									IniSet(Left(k,i-1),Mid(k,i+1),v)
									CreatePath(v)
								EndIf
							Wend
					EndSelect
				EndIf
			Wend
			IniWrite()
		Next
		ClosePreferences()
	EndIf
	
	ProcedureReturn 1
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
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
; VersionField9 = (c) Smitis, 2017-2024