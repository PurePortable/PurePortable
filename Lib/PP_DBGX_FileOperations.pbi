;;----------------------------------------------------------------------------------------------------------------------
; PathFileExistsW
; GetLongPathNameW https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getlongpathnamew

;CopyFileW: 0,kernel32.dll
;CreateEventW: 0,kernel32.dll
;DeleteFileW: 0,kernel32.dll
;GetCurrentDirectoryW: 0,kernel32.dll
;GetFullPathNameW: 0,kernel32.dll
;GetModuleFileNameW: 0,kernel32.dll
;GetShortPathNameW: 0,kernel32.dll
;GetSystemDirectoryW: 0,kernel32.dll
;GetTempFileNameW: 0,kernel32.dll
;GetTempPathW: 0,kernel32.dll
;GetWindowsDirectoryW: 0,kernel32.dll
;LoadLibraryExW: 0,kernel32.dll
;LoadLibraryW: 0,kernel32.dll
;SetCurrentDirectoryW: 0,kernel32.dll
;SetFileAttributesW: 0,kernel32.dll

;GetFileAttributesTransacted

;WinExec: 0,kernel32.dll
;;======================================================================================================================

CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfullpathnamew
CompilerIf Not Defined(DETOUR_GETFULLPATHNAME,#PB_Constant) : #DETOUR_GETFULLPATHNAME=1 : CompilerEndIf
CompilerIf #DETOUR_GETFULLPATHNAME
	Prototype GetFullPathName(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	Global Original_GetFullPathNameA.GetFullPathName
	Procedure Detour_GetFullPathNameA(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
		dbg("GetFullPathNameA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_GetFullPathNameA(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	EndProcedure
	;Global Trampoline_GetFullPathNameA = @Detour_GetFullPathNameA()
	Global Original_GetFullPathNameW.GetFullPathName
	Procedure Detour_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
		dbg("GetFullPathNameW: "+PeekS(lpFileName))
		ProcedureReturn Original_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	EndProcedure
	;Global Trampoline_GetFullPathNameW = @Detour_GetFullPathNameW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilew
CompilerIf Not Defined(DETOUR_FINDFIRSTFILE,#PB_Constant) : #DETOUR_FINDFIRSTFILE=1 : CompilerEndIf
CompilerIf #DETOUR_FINDFIRSTFILE
	Prototype FindFirstFile(lpFileName,lpFindFileData)
	Global Original_FindFirstFileA.FindFirstFile
	Procedure Detour_FindFirstFileA(lpFileName,lpFindFileData)
		dbg("FindFirstFileA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_FindFirstFileA(lpFileName,lpFindFileData)
	EndProcedure
	;Global Trampoline_FindFirstFileA = @Detour_FindFirstFileA()
	Global Original_FindFirstFileW.FindFirstFile
	Procedure Detour_FindFirstFileW(lpFileName,lpFindFileData)
		dbg("FindFirstFileW: "+PeekS(lpFileName))
		ProcedureReturn Original_FindFirstFileW(lpFileName,lpFindFileData)
	EndProcedure
	;Global Trampoline_FindFirstFileW = @Detour_FindFirstFileW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfileexw
CompilerIf Not Defined(DETOUR_FINDFIRSTFILEEX,#PB_Constant) : #DETOUR_FINDFIRSTFILEEX=1 : CompilerEndIf
CompilerIf #DETOUR_FINDFIRSTFILEEX
	Prototype FindFirstFileEx(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	Global Original_FindFirstFileExA.FindFirstFileEx
	Procedure Detour_FindFirstFileExA(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
		dbg("FindFirstFileExA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_FindFirstFileExA(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	EndProcedure
	;Global Trampoline_FindFirstFileExA = @Detour_FindFirstFileExA()
	Global Original_FindFirstFileExW.FindFirstFileEx
	Procedure Detour_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
		dbg("FindFirstFileExW: "+PeekS(lpFileName))
		ProcedureReturn Original_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	EndProcedure
	;Global Trampoline_FindFirstFileExW = @Detour_FindFirstFileExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesw
CompilerIf Not Defined(DETOUR_GETFILEATTRIBUTES,#PB_Constant) : #DETOUR_GETFILEATTRIBUTES=1 : CompilerEndIf
CompilerIf #DETOUR_GETFILEATTRIBUTES
	Prototype.l GetFileAttributes(lpFileName)
	Global Original_GetFileAttributesA.GetFileAttributes
	Procedure.l Detour_GetFileAttributesA(lpFileName)
		dbg("GetFileAttributesA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_GetFileAttributesA(lpFileName)
	EndProcedure
	;Global Trampoline_GetFileAttributesA = @Detour_GetFileAttributesA()
	Global Original_GetFileAttributesW.GetFileAttributes
	Procedure.l Detour_GetFileAttributesW(lpFileName)
		dbg("GetFileAttributesW: "+PeekS(lpFileName))
		ProcedureReturn Original_GetFileAttributesW(lpFileName)
	EndProcedure
	;Global Trampoline_GetFileAttributesW = @Detour_GetFileAttributesW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesexw
CompilerIf Not Defined(DETOUR_GETFILEATTRIBUTESEX,#PB_Constant) : #DETOUR_GETFILEATTRIBUTESEX=1 : CompilerEndIf
CompilerIf #DETOUR_GETFILEATTRIBUTESEX
	Prototype GetFileAttributesEx(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
	Global Original_GetFileAttributesExA.GetFileAttributesEx
	Procedure Detour_GetFileAttributesExA(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
		dbg("GetFileAttributesExA: "+Str(fInfoLevelId)+" "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_GetFileAttributesExA(lpFileName,fInfoLevelId,*lpFileInformation)
	EndProcedure
	;Global Trampoline_GetFileAttributesExA = @Detour_GetFileAttributesExA()
	Global Original_GetFileAttributesExW.GetFileAttributesEx
	Procedure Detour_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
		dbg("GetFileAttributesExW: "+Str(fInfoLevelId)+" "+PeekS(lpFileName))
		ProcedureReturn Original_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation)
	EndProcedure
	;Global Trampoline_GetFileAttributesExW = @Detour_GetFileAttributesExW()
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Prototype Open__Fi(lpFileName,lpReOpenBuff,uStyle)
; Global Original_Open__Fi.Open__Fi
; Procedure Detour_Open__Fi(lpFileName,lpReOpenBuff,uStyle)
; 	dbg("OpenFile: "+PeekS(lpFileName,-1,#PB_Ascii))
; 	ProcedureReturn Original_Open__Fi(lpFileName,lpReOpenBuff,uStyle)
; EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(DETOUR_CREATEFILE,#PB_Constant) : #DETOUR_CREATEFILE=1 : CompilerEndIf
CompilerIf #DETOUR_CREATEFILE
	Prototype CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
	Global Original_CreateFile2.CreateFile2
	Procedure Detour_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams) ; всегда unicode?
		dbg("CreateFile2: "+PeekS(lpFileName))
		ProcedureReturn Original_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
	EndProcedure
	;Global Trampoline_CreateFile2 = @Detour_CreateFile2()
	Prototype CreateFile(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	Global Original_CreateFileA.CreateFile
	Procedure Detour_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
		dbg("CreateFileA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	EndProcedure
	;Global Trampoline_CreateFileA = @Detour_CreateFileA()
	Global Original_CreateFileW.CreateFile
	Procedure Detour_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
		dbg("CreateFileW: "+PeekS(lpFileName))
		ProcedureReturn Original_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	EndProcedure
	;Global Trampoline_CreateFileW = @Detour_CreateFileW()
CompilerEndIf
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

Procedure _InitDbgxFileOperations()
	CompilerIf #DETOUR_GETFULLPATHNAME ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,GetFullPathNameA)
		MH_HookApi(kernel32,GetFullPathNameW)
	CompilerEndIf
	CompilerIf #DETOUR_FINDFIRSTFILE ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,FindFirstFileA)
		MH_HookApi(kernel32,FindFirstFileW)
	CompilerEndIf
	CompilerIf #DETOUR_FINDFIRSTFILEEX ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,FindFirstFileExA)
		MH_HookApi(kernel32,FindFirstFileExW)
	CompilerEndIf
	CompilerIf #DETOUR_GETFILEATTRIBUTES ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,GetFileAttributesA)
		MH_HookApi(kernel32,GetFileAttributesW)
	CompilerEndIf
	CompilerIf #DETOUR_GETFILEATTRIBUTESEX ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,GetFileAttributesExA)
		MH_HookApi(kernel32,GetFileAttributesExW)
	CompilerEndIf
	CompilerIf #DETOUR_CREATEFILE ;And #PROXY_DLL_KERNEL32<=0
		MH_HookApi(kernel32,CreateFile2,#MH_HOOKAPI_NOCHECKRESULT)
		MH_HookApi(kernel32,CreateFileA)
		MH_HookApi(kernel32,CreateFileW)
	CompilerEndIf
EndProcedure
AddInitProcedure(_InitDbgxFileOperations)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 175
; FirstLine = 150
; Folding = ---
; EnableAsm
; DisableDebugger
; EnableExeConstant