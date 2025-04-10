;;======================================================================================================================
; PurePortableSimple Extention
; Расширение для обработки ini-файлов
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.7
;RES_DESCRIPTION Work with ini-files
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePortIni.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\..\PPDK\Lib"

XIncludeFile "PurePortableExtension.pbi"

;;======================================================================================================================
;{ Перехват процедур WinApi для работы с ini-файлами
Global IniFileName.s
;Global *IniFileNameA
Global DefaultFileName.s
Global *DefaultFileNameA
Structure SUBST
	File.s
	Subst.s
EndStructure
Global Dim Subst.SUBST(0), nSubst

Global DbgProfMode
Procedure DbgProf(txt.s)
	If DbgProfMode
		dbg(txt)
	EndIf
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
Declare.s CheckIni(IniFile.s)

;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSection(*lpAppName,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionA.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("GetPrivateProfileSectionA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
EndProcedure
Global Original_GetPrivateProfileSectionW.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("GetPrivateProfileSectionW: -> "+FileName)
		ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,@FileName)
	EndIf
	ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSectionNames(*lpReturnBuffer,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionNamesA.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionNamesA: «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("GetPrivateProfileSectionNamesA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
EndProcedure
Global Original_GetPrivateProfileSectionNamesW.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionNamesW: «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("GetPrivateProfileSectionNamesW: -> "+FileName)
		ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,@FileName)
	EndIf
	ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestring
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestringa
Prototype.l GetPrivateProfileString(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileStringA.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("GetPrivateProfileStringA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
EndProcedure
Global Original_GetPrivateProfileStringW.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("GetPrivateProfileStringW: -> "+FileName)
		ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,@FileName)
	EndIf
	ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
Global Original_GetPrivateProfileStructA.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("GetPrivateProfileStructA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
EndProcedure
Global Original_GetPrivateProfileStructW.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("GetPrivateProfileStructW: -> "+FileName)
		ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,@FileName)
	EndIf
	ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileInt(*lpAppName,*lpKeyName,nDefault,*lpFileName)
Global Original_GetPrivateProfileIntA.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	DbgProf("GetPrivateProfileIntA: «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("GetPrivateProfileIntA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
EndProcedure
Global Original_GetPrivateProfileIntW.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	DbgProf("GetPrivateProfileIntW: «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("GetPrivateProfileIntW: -> "+FileName)
		ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,@FileName)
	EndIf
	ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetProfileSection(*lpAppName,*lpReturnedString,nSize)
Global Original_GetProfileSectionA.GetProfileSection
Procedure.l Detour_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
	DbgProf("GetProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*DefaultFileNameA)
	EndIf
	ProcedureReturn Original_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
EndProcedure
Global Original_GetProfileSectionW.GetProfileSection
Procedure.l Detour_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
	DbgProf("GetProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,@DefaultFileName)
	EndIf
	ProcedureReturn Original_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprofilestringa
; Возврат: количество скопированных символов, исключая нулевой
Prototype.l GetProfileString(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
Global Original_GetProfileStringA.GetProfileString
Procedure.l Detour_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	DbgProf("GetProfileStringA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*DefaultFileNameA)
	EndIf
	ProcedureReturn Original_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
EndProcedure
Global Original_GetProfileStringW.GetProfileString
Procedure.l Detour_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	DbgProf("GetProfileStringW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize,@DefaultFileName)
	EndIf
	ProcedureReturn Original_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetProfileInt(*lpAppName,*lpKeyName,nDefault)
Global Original_GetProfileIntA.GetProfileInt
Procedure Detour_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
	DbgProf("GetProfileIntA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*DefaultFileNameA)
	EndIf
	ProcedureReturn Original_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
EndProcedure
Global Original_GetProfileIntW.GetProfileInt
Procedure Detour_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
	DbgProf("GetProfileIntW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,@DefaultFileName)
	EndIf
	ProcedureReturn Original_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileSection(*lpAppName,*lpString,*lpFileName)
Global Original_WritePrivateProfileSectionA.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpString,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("WritePrivateProfileSectionA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
EndProcedure
Global Original_WritePrivateProfileSectionW.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileSectionW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpString)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("WritePrivateProfileSectionW: -> "+FileName)
		ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,@FileName)
	EndIf
	ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-writeprivateprofilesectiona
Prototype.l WritePrivateProfileString(*lpSection,*lpKeyName,*lpString,*lpFileName)
Global Original_WritePrivateProfileStringA.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("WritePrivateProfileStringA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
EndProcedure
Global Original_WritePrivateProfileStringW.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("WritePrivateProfileStringW: -> "+FileName)
		ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,@FileName)
	EndIf
	ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
Global Original_WritePrivateProfileStructA.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	DbgProf("WritePrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
	If FileName
		DbgProf("WritePrivateProfileStructA: -> "+FileName)
		Protected *FileNameA = Ascii(FileName)
		Protected Result = Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*FileNameA)
		FreeMemory(*FileNameA)
		ProcedureReturn Result
	EndIf
	ProcedureReturn Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
EndProcedure
Global Original_WritePrivateProfileStructW.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	DbgProf("WritePrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
	If FileName
		DbgProf("WritePrivateProfileStructW: -> "+FileName)
		ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,@FileName)
	EndIf
	ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileSection(*lpAppName,*lpString)
Global Original_WriteProfileSectionA.WriteProfileSection
Procedure.l Detour_WriteProfileSectionA(*lpAppName,*lpString)
	DbgProf("WriteProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*DefaultFileNameA)
	EndIf
	ProcedureReturn Original_WriteProfileSectionA(*lpAppName,*lpString)
EndProcedure
Global Original_WriteProfileSectionW.WriteProfileSection
Procedure.l Detour_WriteProfileSectionW(*lpAppName,*lpString)
	DbgProf("WriteProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,@DefaultFileName)
	EndIf
	ProcedureReturn Original_WriteProfileSectionW(*lpAppName,*lpString)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileString(*lpSection,*lpKeyName,*lpString)
Global Original_WriteProfileStringA.WriteProfileString
Procedure.l Detour_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
	DbgProf("WriteProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*DefaultFileNameA)
	EndIf
	ProcedureReturn Original_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
EndProcedure
Global Original_WriteProfileStringW.WriteProfileString
Procedure.l Detour_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
	DbgProf("WriteProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"»")
	If *DefaultFileNameA
		ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,@DefaultFileName)
	EndIf
	ProcedureReturn Original_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
EndProcedure
;}
;;======================================================================================================================
;{ Работа с ini-файлами
Declare IniFileCorrectPaths(IniFile.s)
Declare IniFileSetPaths(IniFile.s)

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

#EXT_SECTION_MAIN = "EXT:Ini"
#EXT_SECTION_FILES = "EXT:Ini.Files"

Procedure ExtensionProcedure()
	DbgExt("EXTENSION: Work With ProfileStrings")
	
	If Not OpenPreferences(PureSimplePrefs,#PB_Preference_NoSpace)
		DbgExt("Can't open preference file")
		ProcedureReturn #PP_EXT_ALLOW_UNLOAD
	EndIf
	
	;{ Коррекция ini-файлов
	Protected x
	ExaminePreferenceGroups()
	Protected IniGroup.s, IniParams.s
	While NextPreferenceGroup()
		IniGroup = PreferenceGroupName()
		; IniSetPaths:<ini-file>|<codepage>
		; IniCorrectPaths:<ini-file>|<codepage>
		; Записи
		; section|key=value
		If LCase(Left(IniGroup,16)) = "inicorrectpaths:"
			DbgExt("  Section: "+IniGroup)
			IniFile = Mid(IniGroup,17)
			x = FindString(IniFile,"|")
			If x
				IniParams = Mid(IniFile,x+1)
				IniFile = NormalizePPath(Left(IniFile,x-1))
			EndIf
			DbgExt("  IniCorrectPath: "+IniFile)
			If FileExist(IniFile)
				PreferenceGroup(IniGroup)
				IniRead(IniFile)
				IniFileCorrectPaths(IniFile)
				IniWrite()
			EndIf
		ElseIf LCase(Left(IniGroup,12)) = "inisetpaths:"
			DbgExt("  Section: "+IniGroup)
			IniFile = Mid(IniGroup,13)
			x = FindString(IniFile,"|")
			If x
				IniParams = Mid(IniFile,x+1)
				IniFile = NormalizePPath(Left(IniFile,x-1))
			EndIf
			DbgExt("  IniSetPath: "+IniFile)
			If FileExist(IniFile)
				PreferenceGroup(IniGroup)
				IniRead(IniFile)
				IniFileSetPaths(IniFile)
				IniWrite()
			EndIf
		EndIf
	Wend
	FreeArray(IniData())
	;}
	
	DbgProfMode = DbgExtMode
	If OpenPreferences(PureSimplePrefs,#PB_Preference_NoSpace)
		If PreferenceGroup(#EXT_SECTION_MAIN)
			DbgProfMode = ReadPreferenceInteger("Debug",0) | DbgExtMode
			DefaultFileName = ReadPreferenceString("Default","")
			IniFileName = NormalizePPath(ReadPreferenceString("IniFile",DefaultFileName))
			DefaultFileName = NormalizePPath(DefaultFileName)
		EndIf
		;If PreferenceGroup(#EXT_SECTION_FILES)
		;EndIf
		
		MH_HookApi(kernel32,GetPrivateProfileSectionA)
		MH_HookApi(kernel32,GetPrivateProfileSectionW)
		MH_HookApi(kernel32,GetPrivateProfileSectionNamesA)
		MH_HookApi(kernel32,GetPrivateProfileSectionNamesW)
		MH_HookApi(kernel32,GetPrivateProfileStringA)
		MH_HookApi(kernel32,GetPrivateProfileStringW)
		MH_HookApi(kernel32,GetPrivateProfileStructA)
		MH_HookApi(kernel32,GetPrivateProfileStructW)
		MH_HookApi(kernel32,GetPrivateProfileIntA)
		MH_HookApi(kernel32,GetPrivateProfileIntW)
		
		MH_HookApi(kernel32,GetProfileSectionA)
		MH_HookApi(kernel32,GetProfileSectionW)
		MH_HookApi(kernel32,GetProfileStringA)
		MH_HookApi(kernel32,GetProfileStringW)
		MH_HookApi(kernel32,GetProfileIntA)
		MH_HookApi(kernel32,GetProfileIntW)
		
		MH_HookApi(kernel32,WritePrivateProfileSectionA)
		MH_HookApi(kernel32,WritePrivateProfileSectionW)
		MH_HookApi(kernel32,WritePrivateProfileStringA)
		MH_HookApi(kernel32,WritePrivateProfileStringW)
		MH_HookApi(kernel32,WritePrivateProfileStructA)
		MH_HookApi(kernel32,WritePrivateProfileStructW)
		
		MH_HookApi(kernel32,WriteProfileSectionA)
		MH_HookApi(kernel32,WriteProfileSectionW)
		MH_HookApi(kernel32,WriteProfileStringA)
		MH_HookApi(kernel32,WriteProfileStringW)
	EndIf

	ClosePreferences()
	;ProcedureReturn #PP_EXT_ALLOW_UNLOAD
EndProcedure

;;======================================================================================================================
; Процедура проверяет имя ini-файла.
; Если ini-файл требуется подменить, возвращает новое имя (полный путь!).
; Иначе - пустую строку.
Procedure.s CheckIni(IniFile.s)
	Protected ini.s
	
	If nSubst ; если список не пуст, ищем в нём
		
	ElseIf IniFileName ; если задано, подменяем на это
		ProcedureReturn IniFileName
	ElseIf DefaultFileName ; или на это
		ProcedureReturn DefaultFileName
	EndIf
	
	ProcedureReturn ini
EndProcedure
;;======================================================================================================================
; Коррекция ini-файлов
Procedure IniFileCorrectPaths(IniFile.s)
	Protected i, k.s, v.s, g.s, p.s
	;Protected IniGroup.s = PreferenceGroupName()
	ExaminePreferenceKeys()
	While NextPreferenceKey()
		k = PreferenceKeyName()
		v = PreferenceKeyValue()
		If v
			v = NormalizePPath(v)
		Else
			v = PrgDirN
		EndIf
		i = FindString(k,"|")
		If i
			g = Left(k,i-1)
			k = Mid(k,i+1)
			DbgExt("  "+g+" :: "+k)
			IniCorrect(g,k,v)
		EndIf
	Wend
EndProcedure
Procedure IniFileSetPaths(IniFile.s)
	Protected i, k.s, v.s, g.s, p.s
	ExaminePreferenceKeys()
	While NextPreferenceKey()
		k = PreferenceKeyName()
		v = NormalizePPath(ExpandEnvironmentStrings(PreferenceKeyValue()))
		i = FindString(k,"|")
		If i
			g = Left(k,i-1)
			k = Mid(k,i+1)
			DbgExt("  "+g+" :: "+k)
			IniSet(g,k,v)
		EndIf
	Wend
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 16
; Folding = CAAAQg-
; Optimizer
; EnableThread
; Executable = PurePortIni.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.7
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.7
; VersionField6 = Work with ini-files
; VersionField7 = PurePortIni.dll
; VersionField9 = (c) Smitis, 2017-2025
