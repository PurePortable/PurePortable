;;======================================================================================================================
; TODO:
; - PreferencePath - раскрытие переменных среды
;;======================================================================================================================
EnableExplicit

;;----------------------------------------------------------------------------------------------------------------------
#MAX_PATH_EXTEND = 32767

Global ProcessId
Global DllInstance; будет иметь то же значение, что и одноимённый параметр в AttachProcess
Global DllPath.s
Global DllName.s
Global PrgDir.s
Global PrgDirN.s
Global ExtPrefs.s ; файл конфигурации

XIncludeFile "PP_Extension.pbi"
XIncludeFile "PP_Subroutines.pbi"

CompilerIf Not Defined(DBG_EXTENSION,#PB_Constant) : #DBG_EXTENSION = 0 : CompilerEndIf
CompilerIf #DBG_EXTENSION
	Macro DbgExt(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgExt(txt) : EndMacro
CompilerEndIf

;;======================================================================================================================
; https://www.rsdn.org/article/qna/baseserv/fileexist.xml
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsa
; Функции PathFileExists и PathIsDirectory работают неадекватно!
; Procedure FileExist(fn.s)
; 	ProcedureReturn Bool(GetFileAttributes_(@fn)&#FILE_ATTRIBUTE_DIRECTORY=0)
; 	;ProcedureReturn PathFileExists_(@fn)
; EndProcedure
; ; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectorya
; Procedure DirectoryExist(fn.s)
; 	Protected attr = GetFileAttributes_(@fn)
; 	ProcedureReturn Bool(attr<>#INVALID_FILE_ATTRIBUTES And (attr&#FILE_ATTRIBUTE_DIRECTORY))
; 	;ProcedureReturn PathIsDirectory_(@fn)
; EndProcedure
; ; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shcreatedirectoryexw
; ;DeclareImport(shell32,_SHCreateDirectoryExW@12,SHCreateDirectoryExW,SHCreateDirectoryEx_(hWnd,*pszPath,*psa))
; Procedure CreatePath(Path.s)
; 	;SHCreateDirectoryEx_(0,@Path,#Null) ; может неправильно работать из dllmain
; 	Path = RTrim(Path,"\")+"\"
; 	Protected p = FindString(Path,"\")
; 	While p
; 		CreateDirectory(Left(Path,p-1))
; 		p = FindString(Path,"\",p+1)
; 	Wend
; EndProcedure
;;======================================================================================================================
Procedure _ExtInitialization()
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
_ExtInitialization()
;;======================================================================================================================
	
ProcedureDLL.l AttachProcess(Instance)
	
EndProcedure

;;======================================================================================================================
;XIncludeFile "proc\ExpandEnvironment.pbi"
Procedure.s PreferencePath(Path.s="",Dir.s="") ; Преобразование относительных путей
	Protected Result.s
	If Path=""
		Path = PreferenceKeyValue()
	EndIf
	If Dir=""
		Dir = PrgDirN
	EndIf
	;dbg("PreferencePath: <"+Path)
	;Path = ExpandEnvironment(Trim(Trim(Path),Chr(34)))
	Path = Trim(Trim(Path),Chr(34))
	;dbg("PreferencePath: *"+Path)
	If Path="."
		Path = Dir
	;ElseIf Path=".." Or Left(Path,2)=".\" Or Left(Path,3)="..\"
	;	Path = Dir+"\"+Path
	ElseIf Mid(Path,2,1)<>":" ; Не абсолютный путь
		Path = Dir+"\"+Path
	EndIf
	;dbg("PreferencePath: >"+NormalizePath(Path))
	ProcedureReturn NormalizePath(Path)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 22
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant