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
	Global Original_GetFullPathNameW.GetFullPathName
	Procedure Detour_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
		dbg("GetFullPathNameW: "+PeekS(lpFileName))
		ProcedureReturn Original_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	EndProcedure
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
	Global Original_FindFirstFileW.FindFirstFile
	Procedure Detour_FindFirstFileW(lpFileName,lpFindFileData)
		dbg("FindFirstFileW: "+PeekS(lpFileName))
		ProcedureReturn Original_FindFirstFileW(lpFileName,lpFindFileData)
	EndProcedure
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
	Global Original_FindFirstFileExW.FindFirstFileEx
	Procedure Detour_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
		dbg("FindFirstFileExW: "+PeekS(lpFileName))
		ProcedureReturn Original_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	EndProcedure
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
	Global Original_GetFileAttributesW.GetFileAttributes
	Procedure.l Detour_GetFileAttributesW(lpFileName)
		dbg("GetFileAttributesW: "+PeekS(lpFileName))
		ProcedureReturn Original_GetFileAttributesW(lpFileName)
	EndProcedure
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
	Global Original_GetFileAttributesExW.GetFileAttributesEx
	Procedure Detour_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
		dbg("GetFileAttributesExW: "+Str(fInfoLevelId)+" "+PeekS(lpFileName))
		ProcedureReturn Original_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation)
	EndProcedure
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
	Prototype CreateFile(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	Global Original_CreateFileA.CreateFile
	Procedure Detour_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
		dbg("CreateFileA: "+PeekS(lpFileName,-1,#PB_Ascii))
		ProcedureReturn Original_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	EndProcedure
	Global Original_CreateFileW.CreateFile
	Procedure Detour_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
		dbg("CreateFileW: "+PeekS(lpFileName))
		ProcedureReturn Original_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createdirectorya
CompilerIf Not Defined(DETOUR_CREATEDIRECTORY,#PB_Constant) : #DETOUR_CREATEDIRECTORY=1 : CompilerEndIf
CompilerIf #DETOUR_CREATEDIRECTORY
	Prototype CreateDirectory(lpPathName,lpSecurityAttributes)
	Global Original_CreateDirectoryA.CreateDirectory
	Procedure Detour_CreateDirectoryA(lpPathName,lpSecurityAttributes)
		dbg("CreateDirectoryA: "+PeekS(lpPathName,-1,#PB_Ascii))
		ProcedureReturn Original_CreateDirectoryA(lpPathName,lpSecurityAttributes)
	EndProcedure
	Global Original_CreateDirectoryW.CreateDirectory
	Procedure Detour_CreateDirectoryW(lpPathName,lpSecurityAttributes)
		dbg("CreateDirectoryW: "+PeekS(lpPathName))
		ProcedureReturn Original_CreateDirectoryW(lpPathName,lpSecurityAttributes)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createdirectoryexa
CompilerIf Not Defined(DETOUR_CREATEDIRECTORYEX,#PB_Constant) : #DETOUR_CREATEDIRECTORYEX=1 : CompilerEndIf
CompilerIf #DETOUR_CREATEDIRECTORYEX
	Prototype CreateDirectoryEx(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
	Global Original_CreateDirectoryExA.CreateDirectoryEx
	Procedure Detour_CreateDirectoryExA(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
		dbg("CreateDirectoryExA: "+PeekSZ(lpTemplateDirectory,-1,#PB_Ascii)+" :: "+PeekSZ(lpNewDirectory,-1,#PB_Ascii))
		ProcedureReturn Original_CreateDirectoryExA(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
	EndProcedure
	Global Original_CreateDirectoryExW.CreateDirectoryEx
	Procedure Detour_CreateDirectoryExW(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
		dbg("CreateDirectoryExW: "+PeekSZ(lpTemplateDirectory)+" :: "+PeekSZ(lpNewDirectory))
		ProcedureReturn Original_CreateDirectoryExW(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shcreatedirectoryexa
CompilerIf Not Defined(DETOUR_SHCREATEDIRECTORYEX,#PB_Constant) : #DETOUR_SHCREATEDIRECTORYEX=1 : CompilerEndIf
CompilerIf #DETOUR_SHCREATEDIRECTORYEX
	Prototype SHCreateDirectoryEx(hwnd,pszPath,*psa)
	Global Original_SHCreateDirectoryExA.CreateDirectoryEx
	Procedure Detour_SHCreateDirectoryExA(hwnd,pszPath,*psa)
		dbg("SHCreateDirectoryExA: "+PeekSZ(pszPath,-1,#PB_Ascii))
		ProcedureReturn Original_SHCreateDirectoryExA(hwnd,pszPath,*psa)
	EndProcedure
	Global Original_SHCreateDirectoryExW.CreateDirectoryEx
	Procedure Detour_SHCreateDirectoryExW(hwnd,pszPath,*psa)
		dbg("SHCreateDirectoryExW: "+PeekSZ(pszPath))
		ProcedureReturn Original_SHCreateDirectoryExW(hwnd,pszPath,*psa)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shfileoperationa
CompilerIf Not Defined(DETOUR_SHFILEOPERATION,#PB_Constant) : #DETOUR_SHFILEOPERATION=1 : CompilerEndIf
CompilerIf #DETOUR_SHFILEOPERATION
	Prototype SHFileOperation(*FileOp.SHFILEOPSTRUCT)
	Global Original_SHFileOperationA.SHFileOperation
	Procedure Detour_SHFileOperationA(*FileOp.SHFILEOPSTRUCT)
		dbg("SHFileOperationA: "+PeekSZ(*FileOp\pFrom,-1,#PB_Ascii)+" :: "+PeekSZ(*FileOp\pTo,-1,#PB_Ascii))
		ProcedureReturn Original_SHFileOperationA(*FileOp)
	EndProcedure
	Global Original_SHFileOperationW.SHFileOperation
	Procedure Detour_SHFileOperationW(*FileOp.SHFILEOPSTRUCT)
		dbg("SHFileOperationW: "+PeekSZ(*FileOp\pFrom)+" :: "+PeekSZ(*FileOp\pTo))
		ProcedureReturn Original_SHFileOperationW(*FileOp)
	EndProcedure
CompilerEndIf

;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

Procedure _InitDbgxFileOperations()
	CompilerIf #DETOUR_GETFULLPATHNAME
		MH_HookApi(kernel32,GetFullPathNameA)
		MH_HookApi(kernel32,GetFullPathNameW)
	CompilerEndIf
	CompilerIf #DETOUR_FINDFIRSTFILE
		MH_HookApi(kernel32,FindFirstFileA)
		MH_HookApi(kernel32,FindFirstFileW)
	CompilerEndIf
	CompilerIf #DETOUR_FINDFIRSTFILEEX
		MH_HookApi(kernel32,FindFirstFileExA)
		MH_HookApi(kernel32,FindFirstFileExW)
	CompilerEndIf
	CompilerIf #DETOUR_GETFILEATTRIBUTES
		MH_HookApi(kernel32,GetFileAttributesA)
		MH_HookApi(kernel32,GetFileAttributesW)
	CompilerEndIf
	CompilerIf #DETOUR_GETFILEATTRIBUTESEX
		MH_HookApi(kernel32,GetFileAttributesExA)
		MH_HookApi(kernel32,GetFileAttributesExW)
	CompilerEndIf
	CompilerIf #DETOUR_CREATEFILE
		MH_HookApi(kernel32,CreateFile2,#MH_HOOKAPI_NOCHECKRESULT)
		MH_HookApi(kernel32,CreateFileA)
		MH_HookApi(kernel32,CreateFileW)
	CompilerEndIf
	CompilerIf #DETOUR_CREATEDIRECTORY
		MH_HookApi(kernel32,CreateDirectoryA)
		MH_HookApi(kernel32,CreateDirectoryW)
	CompilerEndIf
	CompilerIf #DETOUR_CREATEDIRECTORYEX
		MH_HookApi(kernel32,CreateDirectoryExA)
		MH_HookApi(kernel32,CreateDirectoryExW)
	CompilerEndIf
	CompilerIf #DETOUR_SHCREATEDIRECTORYEX Or #DETOUR_SHFILEOPERATION
		LoadLibrary_(@"shell32.dll")
	CompilerEndIf
	CompilerIf #DETOUR_SHCREATEDIRECTORYEX
		MH_HookApi(shell32,SHCreateDirectoryExA)
		MH_HookApi(shell32,SHCreateDirectoryExW)
	CompilerEndIf
	CompilerIf #DETOUR_SHFILEOPERATION
		MH_HookApi(shell32,SHFileOperationA)
		MH_HookApi(shell32,SHFileOperationW)
	CompilerEndIf
EndProcedure
AddInitProcedure(_InitDbgxFileOperations)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = AAAw
; EnableAsm
; DisableDebugger
; EnableExeConstant