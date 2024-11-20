
;;======================================================================================================================
#MAX_PATH_EXTEND = 32767
XIncludeFile "PP_Debug.pbi"
XIncludeFile "PP_Extension.pbi"
;;======================================================================================================================
CompilerIf Not Defined(DBG_EXTENSION,#PB_Constant) : #DBG_EXTENSION = 0 : CompilerEndIf
CompilerIf #DBG_EXTENSION And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf
CompilerIf #DBG_EXTENSION
	Global DbgExtMode = #DBG_EXTENSION
	Procedure DbgExt(txt.s)
		If DbgExtMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgExt(txt) : EndMacro
CompilerEndIf
;;======================================================================================================================
Global PrgPath.s ; полный путь к исполняемому файлу программы
Global PrgDir.s	 ; директория программы с "\" на конце
Global PrgDirN.s ; директория программы без "\" на конце
Global PrgName.s ; имя программы (без расширения)
Global DllPath.s, DllName.s
Global ExtPrefs.s ; файл конфигурации расширения
;;======================================================================================================================
XIncludeFile "proc\CorrectPath.pbi"
XIncludeFile "proc\CreatePath.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"
XIncludeFile "proc\Exist.pbi"
XIncludeFile "proc\NormalizePath.pbi"
;;======================================================================================================================
Procedure.s PreferencePath(Path.s="",Dir.s="") ; Преобразование относительных путей
	Protected Result.s
	If Path=""
		Path = PreferenceKeyValue()
	EndIf
	If Dir=""
		Dir = PrgDirN
	EndIf
	Path = ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34)))
	If Path="."
		Path = Dir
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = Dir+"\"+Path
	EndIf
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================

Global DllInstance ; будет иметь то же значение, что и одноимённый параметр в AttachProcess
Global ProcessId

Procedure ExtensionInitialization()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
	CompilerEndIf
	ProcessId = GetCurrentProcessId_()
	Protected buf.s = Space(#MAX_PATH_EXTEND)
	GetModuleFileName_(DllInstance,@buf,#MAX_PATH_EXTEND)
	DllPath = PeekS(@buf)
	DllName = GetFilePart(DllPath,#PB_FileSystem_NoExtension)
	PrgDir = GetPathPart(DllPath)
	PrgDirN = RTrim(PrgDir,"\")
	ExtPrefs = PrgDir+DllName
	If FileExist(ExtPrefs+".prefs")
		ExtPrefs+".prefs"
	Else ;If FileExist(ExtPrefs+".ini")
		ExtPrefs+".ini"
	EndIf
EndProcedure
ExtensionInitialization()
;;======================================================================================================================
Declare ExtensionProcedure()
ProcedureDLL PurePortableExtension(*PPD)
	;*EXT = *PPD
	
	ExtensionProcedure()
	ProcedureReturn 0
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 79
; FirstLine = 51
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant