;;======================================================================================================================
; PurePortableSimple Extention Fonts
; Расширение для загрузки дополнительных шрифтов
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.14
;RES_DESCRIPTION Loaded fonts
;RES_COPYRIGHT (c) Smitis, 2017-2026
;RES_INTERNALNAME PurePortFonts
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\..\PPDK\Lib"

#DBG_EXTENSION = 0
XIncludeFile "PurePortableExtension.pbi"
XIncludeFile "winapi\AddFontResourceEx.pbi"
;;======================================================================================================================

#EXT_SECTION_MAIN = "EXT:Fonts"
;#EXT_SECTION_FILES = "EXT:LoadFonts."

Procedure ExtensionMain(Load=1)
	If Load
		DbgExt("EXTENTION: Load additional fonts")
	Else
		DbgExt("EXTENTION: Unload additional fonts")
	EndIf
	
	; Загрузка всех шрифтов из секции Fonts
	
	Protected r
	If OpenPreferences(PureSimplePrefs,#PB_Preference_NoSpace)
		Protected FontMask.s, FontDir.s, FontFile.s, Dir
		;If PreferenceGroup(#EXT_SECTION_MAIN)
		;EndIf
		If PreferenceGroup(#EXT_SECTION_MAIN+".Load")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				FontMask = NormalizePPath(PreferenceKeyName())
				DbgExt("  Enumeration fonts: "+FontMask)
				FontDir = GetPathPart(FontMask)
				FontMask = GetFilePart(FontMask)
				Dir = ExamineDirectory(#PB_Any,FontDir,FontMask)
				If Dir
					While NextDirectoryEntry(Dir)
						If DirectoryEntryType(Dir) = #PB_DirectoryEntry_File
							FontFile = FontDir+DirectoryEntryName(Dir)
							If Load
								DbgExt("  Load font: "+FontFile)
								r = AddFontResourceEx_(@FontFile,#FR_PRIVATE,0)
								;DbgExt("Load font: "+r)
							Else
								DbgExt("  Unload font: "+FontFile)
								r = RemoveFontResourceEx_(@FontFile,#FR_PRIVATE,0)
								;DbgExt("Load font: "+r)
							EndIf
						EndIf
					Wend
				EndIf
			Wend
		EndIf
		ClosePreferences()
	EndIf
EndProcedure

Procedure ExtensionProcedure()
	ExtensionMain(1)
EndProcedure

Procedure ExtensionExit()
	ExtensionMain(0)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 28
; FirstLine = 2
; Folding = -
; Optimizer
; EnableThread
; Executable = PurePortIni.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.14
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.14
; VersionField6 = Loaded fonts
; VersionField7 = PurePortFonts.dll
; VersionField9 = (c) Smitis, 2017-2026