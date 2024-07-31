;;======================================================================================================================
; Модуль ProfileString
; Портабелизация функций для работы с ini-файлами
;;======================================================================================================================

; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestringw

; WritePrivateProfileStringA(lpSection,lpKeyName,lpString,lpFileName)
; GetPrivateProfileStringA(lpSection,lpKeyName,lpDefault,lpReturnedString,nSize,lpFileName)

; Если lpAppName равно NULL, GetPrivateProfileString копирует имена всех секций указанного файла в буфер.
; Если lpKeyName равно NULL, функция копирует имена всех ключей указанной секции (т.е. lpAppName не должен быть NULL) в буфер.
; Приложение может использовать этот способ для перечисления всех секций и ключей в файле.
; В каждом из случаев каждая строка оканчивается NULL символом и последняя строка завершается дополнительным NULL символом (т.е. двумя NULL символами).
; Если указанный буфер слишком мал для хранения всех строк, то последняя строка обрезается и завершается двумя NULL символами.
;;----------------------------------------------------------------------------------------------------------------------

Global ProfileStringFileName.s
Global *ProfileStringFileNameA

CompilerIf Not Defined(DBG_PROFILE_STRINGS,#PB_Constant) : #DBG_PROFILE_STRINGS = 0 : CompilerEndIf

CompilerIf #DBG_PROFILE_STRINGS And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_PROFILE_STRINGS
	Global DbgProfMode = #DBG_PROFILE_STRINGS
	Procedure DbgProf(txt.s)
		If DbgProfMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgProf(txt) : EndMacro
CompilerEndIf

CompilerIf Not Defined(CheckIni,#PB_Procedure) : Declare.s CheckIni(IniFile.s) : CompilerEndIf

CompilerIf Defined(PROFILE_STRINGS_FILENAME,#PB_Constant)
	CompilerIf Not Defined(PORTABLE_PROFILE_STRINGS_FILEEXT,#PB_Constant) : #PROFILE_STRINGS_FILEEXT = ".ini" : CompilerEndIf
	CompilerIf #PROFILE_STRINGS_FILENAME = ""
		ProfileStringFileName = PrgDir+PrgName+#PROFILE_STRINGS_FILEEXT
	CompilerElse
		ProfileStringFileName = PrgDir+#PROFILE_STRINGS_FILENAME
		If GetExtensionPart(ProfileStringFileName)=""
			ProfileStringFileName + #PROFILE_STRINGS_FILEEXT
		EndIf
	CompilerEndIf
	*ProfileStringFileNameA = Ascii(ProfileStringFileName)
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSection(*lpAppName,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionA.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,lpReturnedString,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("GetPrivateProfileSectionA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_GetPrivateProfileSectionW.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("GetPrivateProfileSectionW: -> "+FileName)
			ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,@FileName)
		EndIf
		ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSectionNames(*lpReturnBuffer,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionNamesA.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionNamesA: «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("GetPrivateProfileSectionNamesA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_GetPrivateProfileSectionNamesW.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
	DbgProf("GetPrivateProfileSectionNamesW: «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("GetPrivateProfileSectionNamesW: -> "+FileName)
			ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,@FileName)
		EndIf
		ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestring
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestringa
Prototype.l GetPrivateProfileString(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileStringA.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("GetPrivateProfileStringA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_GetPrivateProfileStringW.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("GetPrivateProfileStringW: -> "+FileName)
			ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,@FileName)
		EndIf
		ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
Global Original_GetPrivateProfileStructA.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("GetPrivateProfileStructA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_GetPrivateProfileStructW.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	DbgProf("GetPrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("GetPrivateProfileStructW: -> "+FileName)
			ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,@FileName)
		EndIf
		ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileInt(*lpAppName,*lpKeyName,nDefault,*lpFileName)
Global Original_GetPrivateProfileIntA.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	DbgProf("GetPrivateProfileIntA: «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("GetPrivateProfileIntA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_GetPrivateProfileIntW.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	DbgProf("GetPrivateProfileIntW: «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("GetPrivateProfileIntW: -> "+FileName)
			ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,@FileName)
		EndIf
		ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetProfileSection(*lpAppName,*lpReturnedString,nSize)
Global Original_GetProfileSectionA.GetProfileSection
Procedure.l Detour_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
	DbgProf("GetProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*ProfileStringFileNameA)
	CompilerEndIf
EndProcedure
Global Original_GetProfileSectionW.GetProfileSection
Procedure.l Detour_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
	DbgProf("GetProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,@ProfileStringFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprofilestringa
; Возврат: количество скопированных символов, исключая нулевой
Prototype.l GetProfileString(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
Global Original_GetProfileStringA.GetProfileString
Procedure.l Detour_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	DbgProf("GetProfileStringA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*ProfileStringFileNameA)
	CompilerEndIf
EndProcedure
Global Original_GetProfileStringW.GetProfileString
Procedure.l Detour_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	DbgProf("GetProfileStringW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize,@ProfileStringFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype GetProfileInt(*lpAppName,*lpKeyName,nDefault)
Global Original_GetProfileIntA.GetProfileInt
Procedure Detour_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
	DbgProf("GetProfileIntA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*ProfileStringFileNameA)
	CompilerEndIf
EndProcedure
Global Original_GetProfileIntW.GetProfileInt
Procedure Detour_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
	DbgProf("GetProfileIntW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
	CompilerElse
		ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,@ProfileStringFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileSection(*lpAppName,*lpString,*lpFileName)
Global Original_WritePrivateProfileSectionA.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpString,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("WritePrivateProfileSectionA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_WritePrivateProfileSectionW.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileSectionW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpString)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("WritePrivateProfileSectionW: -> "+FileName)
			ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,@FileName)
		EndIf
		ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-writeprivateprofilesectiona
Prototype.l WritePrivateProfileString(*lpSection,*lpKeyName,*lpString,*lpFileName)
Global Original_WritePrivateProfileStringA.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("WritePrivateProfileStringA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_WritePrivateProfileStringW.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
	DbgProf("WritePrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("WritePrivateProfileStringW: -> "+FileName)
			ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,@FileName)
		EndIf
		ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
Global Original_WritePrivateProfileStructA.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	DbgProf("WritePrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName,-1,#PB_Ascii))
		If FileName
			DbgProf("WritePrivateProfileStructA: -> "+FileName)
			Protected *FileNameA = Ascii(FileName)
			Protected Result = Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*FileNameA)
			FreeMemory(*FileNameA)
			ProcedureReturn Result
		EndIf
		ProcedureReturn Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	CompilerEndIf
EndProcedure
Global Original_WritePrivateProfileStructW.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	DbgProf("WritePrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	CompilerElse
		Protected FileName.s = CheckIni(PeekSZ(*lpFileName))
		If FileName
			DbgProf("WritePrivateProfileStructW: -> "+FileName)
			ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,@FileName)
		EndIf
		ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileSection(*lpAppName,*lpString)
Global Original_WriteProfileSectionA.WriteProfileSection
Procedure.l Detour_WriteProfileSectionA(*lpAppName,*lpString)
	DbgProf("WriteProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WriteProfileSectionA(*lpAppName,*lpString)
	CompilerElse
		ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*ProfileStringFileNameA)
	CompilerEndIf
EndProcedure
Global Original_WriteProfileSectionW.WriteProfileSection
Procedure.l Detour_WriteProfileSectionW(*lpAppName,*lpString)
	DbgProf("WriteProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WriteProfileSectionW(*lpAppName,*lpString)
	CompilerElse
		ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,@ProfileStringFileName)
	CompilerEndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileString(*lpSection,*lpKeyName,*lpString)
Global Original_WriteProfileStringA.WriteProfileString
Procedure.l Detour_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
	DbgProf("WriteProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
	CompilerElse
		ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*ProfileStringFileNameA)
	CompilerEndIf
EndProcedure
Global Original_WriteProfileStringW.WriteProfileString
Procedure.l Detour_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
	DbgProf("WriteProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"»")
	CompilerIf Not #PORTABLE
		ProcedureReturn Original_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
	CompilerElse
		ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,@ProfileStringFileName)
	CompilerEndIf
EndProcedure
;;======================================================================================================================
CompilerIf Defined(PORTABLE_PROFILE_STRINGS_FILENAME,#PB_Constant)
	CompilerIf #PORTABLE_PROFILE_STRINGS_FILENAME<>""
		ProfileStringsFileName = PrgDir+#PORTABLE_PROFILE_STRINGS_FILENAME
	CompilerElse
		ProfileStringsFileName = PrgDir+PrgName+#PORTABLE_PROFILE_STRINGS_FILEEXT
	CompilerEndIf
	ProfileStringsFileNameA = SpaceA(ProfileStringsFileName)
	PokeS(@ProfileStringsFileNameA,ProfileStringsFileName,-1,#PB_Ascii)
CompilerEndIf
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================

Global ProfileStringsPermit = 1
Procedure _InitProfileStringsHooks()
	If ProfileStringsPermit
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
EndProcedure
AddInitProcedure(_InitProfileStringsHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = CAAAg
; EnableAsm
; EnableThread
; DisableDebugger
; EnableExeConstant