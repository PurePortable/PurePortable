﻿;;======================================================================================================================
; PurePortable main lib 4.10.03
#PP_MAINVERSION = 4.10
;;======================================================================================================================

CompilerIf Not Defined(PB_Compiler_Backend,#PB_Constant) : #PB_Compiler_Backend = 0 : CompilerEndIf
CompilerIf Not Defined(PB_Backend_Asm,#PB_Constant) : #PB_Backend_Asm = 0 : CompilerEndIf
CompilerIf #PB_Compiler_Backend<>#PB_Backend_Asm
	CompilerError "Compiler Backend must be ASM in Compiler-Option"
CompilerEndIf

;;======================================================================================================================

CompilerIf Not Defined(PROXY_DLL_COMPATIBILITY,#PB_Constant) : #PROXY_DLL_COMPATIBILITY = 7 : CompilerEndIf
;#PROXY_DLL_COMPATIBILITY_DEFAULT = 7 ; Это совместимость по умолчанию для #PROXY_DLL_COMPATIBILITY=0 ???

#MAX_PATH_EXTEND = 32767
;XIncludeFile "PurePortableCustom.pbi"
CompilerIf Not Defined(dbg,#PB_Procedure)
	Procedure dbg(txt.s="") : OutputDebugString_("PORT: "+txt) : EndProcedure
CompilerEndIf

;;======================================================================================================================
; Инициализация основных переменных
;Global WinDir.s
Global SysDir.s
;Global TempDir.s
;Global DllPath.s, DllDir.s, DllDirN.s, DllName.s
Global DllDir.s
Global DllDirN.s
Global DllInstance ; будет иметь то же значение, что и одноимённый параметр в AttachProcess
;Global DllReason ; будет иметь то же значение, что и параметр fdwReason в DllMain
Procedure _GlobalInitialization()
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		!MOV EAX, [_PB_Instance]
		!MOV [v_DllInstance], EAX
	CompilerElse
		!MOV RAX, [_PB_Instance]
		!MOV [v_DllInstance], RAX
	CompilerEndIf

	;DisableThreadLibraryCalls_(Instance)
	
	;Protected buf.s = Space(#MAX_PATH_EXTEND)
	
	;GetModuleFileName_(0,@buf,#MAX_PATH_EXTEND)
	;PrgPath = PeekS(@buf) ; полный путь к исполняемому файлу программы
	;PrgDir = GetPathPart(PrgPath)
	;PrgDirN = RTrim(PrgDir,"\")
	;PrgName = GetFilePart(PrgPath,#PB_FileSystem_NoExtension)
	
	;GetModuleFileName_(DllInstance,@buf,#MAX_PATH_EXTEND)
	;DllPath = PeekS(@buf) ; полный путь к прокси-dll
	;DllDir = GetPathPart(DllPath)
	;DllDirN = RTrim(DllDir,"\")
	;DllName = GetFilePart(DllPath,#PB_FileSystem_NoExtension)
	
	;GetWindowsDirectory_(@buf,#MAX_PATH_EXTEND)
	;WinDir = RTrim(buf,"\")
	;GetSystemDirectory_(@buf,#MAX_PATH_EXTEND)
	;SysDir = RTrim(buf,"\")
	;GetTempPath_(#MAX_PATH_EXTEND,@buf)
	;TempDir = RTrim(buf,"\")
	
	Protected *buf = AllocateMemory(#MAX_PATH_EXTEND*2)
	GetModuleFileName_(DllInstance,*buf,#MAX_PATH_EXTEND)
	; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-pathremovefilespeca
	PathRemoveFileSpec_(*buf) ; Удаляет имя файла в конце и обратную косую черту из пути, если они присутствуют.
	DllDirN = PeekS(*buf)
	DllDir = DllDirN+"\"
	; https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemdirectorya
	GetSystemDirectory_(*buf,#MAX_PATH_EXTEND) ; Системная директория без \
	SysDir = PeekS(*buf)
	FreeMemory(*buf)
	
EndProcedure
_GlobalInitialization()

;;======================================================================================================================
XIncludeFile "PP_Proxy.pbi"
XIncludeFile "Proxy\"+#PROXY_DLL+".pbi"

;;======================================================================================================================
; Вывод общей информации при аттаче dll

;dbg("ATTACHPROCESS: "+PrgPath)
;dbg("ATTACHPROCESS: "+DllPath)

;=======================================================================================================================
; https://www.rsdn.org/article/qna/baseserv/fileexist.xml
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathfileexistsa
Procedure FileExist(fn.s)
	ProcedureReturn Bool(GetFileAttributes_(@fn)&#FILE_ATTRIBUTE_DIRECTORY=0)
EndProcedure
; https://learn.microsoft.com/ru-ru/windows/win32/api/shlwapi/nf-shlwapi-pathisdirectorya
; Procedure DirectoryExist(fn.s)
; 	Protected attr = GetFileAttributes_(@fn)
; 	ProcedureReturn Bool(attr<>#INVALID_FILE_ATTRIBUTES And (attr&#FILE_ATTRIBUTE_DIRECTORY))
; EndProcedure

;;======================================================================================================================
CompilerIf Not Defined(PurePortable,#PB_Procedure) And #PB_Compiler_ExecutableFormat=#PB_Compiler_DLL
	ProcedureDLL PurePortable(id.l,*param1,*param2,reserved)
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;;======================================================================================================================
; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 96
; FirstLine = 73
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant
; EnableUnicode