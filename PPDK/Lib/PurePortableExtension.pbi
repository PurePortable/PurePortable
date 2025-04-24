;;======================================================================================================================
#PUREPORTABLEEXTENSION = 1
#MIN_HOOK = 1 ; Так как испоьзуется MinHookInterface, избежать включения MinHook
;;======================================================================================================================
#MAX_PATH_EXTEND = 32767
;XIncludeFile "PP_Debug.pbi"
XIncludeFile "PP_Extension.pbi"
Global *EXT.EXTDATA
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
;DeclareImport(kernel32,_OutputDebugStringW@4,OutputDebugStringW,OutputDebugStringW(*txt))
;Procedure dbg(txt.s="") : OutputDebugStringW("PORT: "+txt) : EndProcedure
Procedure dbg(txt.s="") : *EXT\HF\dbg(txt) : EndProcedure
;CompilerIf Not Defined(DBG_EXTENSION,#PB_Constant) : #DBG_EXTENSION = 0 : CompilerEndIf
Global DbgExtMode
Procedure DbgExt(txt.s)
	If DbgExtMode
		*EXT\HF\dbg(txt)
	EndIf
EndProcedure
;;======================================================================================================================
Global PrgPath.s ; полный путь к исполняемому файлу программы
Global PrgDir.s	 ; директория программы с "\" на конце
Global PrgDirN.s ; директория программы без "\" на конце
Global PrgName.s ; имя программы (без расширения)
Global DllPath.s, DllName.s
Global ExtPrefs.s ; файл конфигурации расширения
Global PureSimplePrefs.s

;;======================================================================================================================
XIncludeFile "proc\CorrectPath.pbi"
XIncludeFile "proc\CreatePath.pbi"
XIncludeFile "proc\ExpandEnvironmentStrings.pbi"
XIncludeFile "proc\Exist.pbi"
XIncludeFile "proc\NormalizePath.pbi"
;;======================================================================================================================
EnumerationBinary MH_HOOKAPI
	#MH_HOOKAPI_NOCHECKRESULT
	#MH_HOOKAPI_INIT
EndEnumeration
UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro
Macro MH_HookApi(DllName,FuncName,flags=0)
	Global Target_#FuncName
	*EXT\MH\_MH_HookApi(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Detour_#FuncName(),@Original_#FuncName,@Target_#FuncName,flags)
EndMacro
;;======================================================================================================================
Procedure.s NormalizePPath(Path.s="",Dir.s="") ; Преобразование относительных путей
	If Path
		If Dir="" : Dir = PrgDirN : EndIf
		Path = ExpandEnvironmentStrings(Trim(Trim(Path),Chr(34)))
		If Path="."
			Path = Dir
		ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
			Path = Dir+"\"+Path
		EndIf
		ProcedureReturn NormalizePath(Path)
	EndIf
EndProcedure
;;======================================================================================================================
Procedure.s PeekSZ(*MemoryBuffer,Length=-1,Format=#PB_Unicode)
	If *MemoryBuffer
		ProcedureReturn PeekS(*MemoryBuffer,Length,Format)
	EndIf
	ProcedureReturn ""
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
	;ProcessId = GetCurrentProcessId_()
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
ProcedureDLL PurePortableExtension(*ExtData,*ExtParam)
	*EXT = *ExtData
	DbgExtMode = *EXT\AllowDbg
	DbgExt("EXTENSION: "+DllPath)
	PureSimplePrefs = PeekS(*EXT\PrefsFile)
	ExtensionProcedure()
	ProcedureReturn 0
EndProcedure
;;======================================================================================================================
; ProcedureDLL.l AttachProcess(Instance)
; EndProcedure
;;======================================================================================================================
ProcedureDLL.l DetachProcess(Instance)
	DbgExt("EXTENSION UNLOAD: "+DllPath)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 36
; Folding = 5--
; EnableThread
; DisableDebugger
; EnableExeConstant