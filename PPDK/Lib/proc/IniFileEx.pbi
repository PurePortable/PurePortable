;;======================================================================================================================
; TODO
; - Сделать поле Plain строкой. Если Key="" And Value="", использовать Plain для строки.
; - Section -> Group ???
; - IniDelete ???
;;======================================================================================================================

CompilerIf Not Defined(DBG_INIFILEEX,#PB_Constant) : #DBG_INIFILEEX = 0 : CompilerEndIf
CompilerIf #DBG_INIFILEEX
	Macro DbgIni(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgIni(txt) : EndMacro
CompilerEndIf

XIncludeFile "CorrectPath.pbi"

;;======================================================================================================================

Structure INIDATA
	Section.s
	SectionL.s
	Key.s
	KeyL.s
	Value.s
	Plain.i
	Deleted.i
	Written.i ;Saved.i
EndStructure
Global Dim IniData.INIDATA(0)
Global IniFile.s,IniChanged,IniSize,IniCodepage
;;----------------------------------------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------------------------------------
; После вызова этой процедуры работа с ini-файлом нежелательна.
Procedure IniWrite()
	Protected CurrentSection.s
	Protected i, j, hIni
	If IniChanged
		hIni = CreateFile(#PB_Any,IniFile,#PB_File_SharedWrite|IniCodepage)
		If hIni
			IniChanged = #False
			For i=1 To IniSize
				If Not IniData(i)\Deleted And Not IniData(i)\Written
					If CurrentSection<>IniData(i)\SectionL ; начало новой секции
						CurrentSection = IniData(i)\SectionL
						WriteStringN(hIni,"["+IniData(i)\Section+"]",IniCodepage)
						IniData(i)\Written = #True
					EndIf
					If IniData(i)\Plain
						DbgIni("IniWrite: "+IniData(i)\Key)
						WriteStringN(hIni,IniData(i)\Key,IniCodepage)
					Else
						DbgIni("IniWrite: "+IniData(i)\Key+"="+IniData(i)\Value)
						WriteStringN(hIni,IniData(i)\Key+"="+IniData(i)\Value,IniCodepage)
					EndIf
					; Чтобы склеить секцию, ищем все ключи этой секции
					For j=i+1 To IniSize
						If Not IniData(j)\Deleted And Not IniData(j)\Written And CurrentSection=IniData(j)\SectionL
							If IniData(j)\Plain
								DbgIni("IniWrite: "+IniData(j)\Key)
								WriteStringN(hIni,IniData(j)\Key,IniCodepage)
							Else
								DbgIni("IniWrite: "+IniData(j)\Key+"="+IniData(j)\Value)
								WriteStringN(hIni,IniData(j)\Key+"="+IniData(j)\Value,IniCodepage)
							EndIf
							IniData(j)\Written = #True ; больше обрабатывать не надо
						EndIf
					Next
				EndIf
			Next
			For i=1 To IniSize
				IniData(i)\Written = #False
			Next
			CloseFile(hIni)
		EndIf
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------------------------------------
Procedure IniCorrectKey(Key.s,Base.s,Flags=0)
	Protected i, Path.s
	Protected k.s = LCase(Key)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k
			DbgIni("IniCorrectKey: < "+IniData(i)\Value)
			Path = CorrectPath(IniData(i)\Value,Base,Flags)
			If IniData(i)\Value<>Path
				DbgIni("IniCorrectKey: > "+Path)
				IniData(i)\Value = Path
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------------------------------------
Procedure IniCorrect(Section.s,Key.s,Base.s,Flags=0)
	Protected i, Path.s
	Protected k.s = LCase(Key)
	Protected s.s = LCase(Section)
	For i=1 To IniSize
		If Not IniData(i)\Deleted And Not IniData(i)\Plain And IniData(i)\KeyL=k And IniData(i)\SectionL=s
			DbgIni("IniCorrect: < "+IniData(i)\Value)
			Path = CorrectPath(IniData(i)\Value,Base,Flags)
			DbgIni("IniCorrect: > "+Path)
			If IniData(i)\Value<>Path
				IniData(i)\Value = Path
				IniChanged = #True
			EndIf
			Break
		EndIf
	Next
EndProcedure
;;======================================================================================================================
; Example 1
; 	IniRead("Sch.ini") ; начало работы с ini-файлом
; 	IniSet("KeyFilename",PrgDir+"Sch.key")
; 	IniWrite() ; завершение работы с ini-файлом
	
; Example 2
; 	Protected i
; 	IniRead("WinMerge.ini") ; начало работы с ini-файлом
; 	For i=1 To IniSize ; перебор всех ключей независимо от их принадлежности группе
; 		If Left(IniData(i)\KeyL,6)="files\"
; 			IniData(i)\Deleted=#True
; 			IniChanged=#True
; 		EndIf
; 	Next
; 	IniWrite() ; завершение работы с ini-файлом
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 4
; Folding = 8-
; EnableAsm
; DisableDebugger
; EnableExeConstant