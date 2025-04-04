;;======================================================================================================================
; PurePortableSimple Extention Fonts
; Расширение для загрузки дополнительных шрифтов
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.7
;RES_DESCRIPTION Loaded fonts
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePortFonts.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\..\PPDK\Lib"

#DBG_EXTENSION = 0
XIncludeFile "PurePortableExtension.pbi"
;;======================================================================================================================
#FR_PRIVATE = $10
#FR_NOT_ENUM = $20

; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-addfontresourceexw
; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-removefontresourceexw
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	Import "gdi32.lib" : AddFontResourceEx(name,fl,pdv) As "_AddFontResourceExW@12" : EndImport
	Import "gdi32.lib" : RemoveFontResourceEx(name,fl,pdv) As "_RemoveFontResourceExW@12" : EndImport
CompilerElse
	Import "gdi32.lib" : AddFontResourceEx(name,fl,pdv) As "AddFontResourceExW" : EndImport
	Import "gdi32.lib" : RemoveFontResourceEx(name,fl,pdv) As "RemoveFontResourceExW" : EndImport
CompilerEndIf
;;======================================================================================================================

Procedure ExtensionProcedure()
	DbgExt("EXTENTION: Load additional fonts")
	
	; Загрузка всех шрифтов из секции Fonts
	
	Protected r
	If OpenPreferences(ExtPrefs,#PB_Preference_NoSpace)
		Protected FontMask.s, FontDir.s, FontFile.s, Dir
		If PreferenceGroup("Fonts")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				FontMask = NormalizePath(PrgDir+PreferenceKeyName())
				DbgExt("Enumeration fonts: "+FontMask)
				FontDir = GetPathPart(FontMask)
				FontMask = GetFilePart(FontMask)
				Dir = ExamineDirectory(#PB_Any,FontDir,FontMask)
				If Dir
					While NextDirectoryEntry(Dir)
						If DirectoryEntryType(Dir) = #PB_DirectoryEntry_File
							FontFile = FontDir+DirectoryEntryName(Dir)
							DbgExt("Load font: "+FontFile)
							r = AddFontResourceEx(@FontFile,#FR_PRIVATE,0)
							;DbgExt("Load font: "+r)
						EndIf
					Wend
				EndIf
			Wend
		EndIf
		ClosePreferences()
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 16
; Folding = -
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
; VersionField6 = Loaded fonts
; VersionField7 = PurePortFonts.dll
; VersionField9 = (c) Smitis, 2017-2025