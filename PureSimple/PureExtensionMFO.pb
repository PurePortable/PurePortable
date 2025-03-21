;;======================================================================================================================
; PurePortableSimple Extention MFO
; Расширение для мониторинга файловых операций.
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.6
;RES_DESCRIPTION PurePortableSimpleExtension
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePortExecute.dll
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\PPDK\Lib"

#DBG_EXTENSION = 0
XIncludeFile "PurePortableExtension.pbi"
;;----------------------------------------------------------------------------------------------------------------------
Procedure.s PeekSZ(*MemoryBuffer,Length=-1,Format=#PB_Unicode)
	If *MemoryBuffer
		ProcedureReturn PeekS(*MemoryBuffer,Length,Format)
	EndIf
	ProcedureReturn ""
EndProcedure
;;======================================================================================================================
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfullpathnamew
Prototype GetFullPathName(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
Global Original_GetFullPathNameA.GetFullPathName
Procedure Detour_GetFullPathNameA(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	dbg("GetFullPathNameA: «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetFullPathNameA(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
EndProcedure
Global Original_GetFullPathNameW.GetFullPathName
Procedure Detour_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
	dbg("GetFullPathNameW: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_GetFullPathNameW(lpFileName,nBufferLength,lpBuffer,*lpFilePart)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilew
Prototype FindFirstFile(lpFileName,lpFindFileData)
Global Original_FindFirstFileA.FindFirstFile
Procedure Detour_FindFirstFileA(lpFileName,lpFindFileData)
	dbg("FindFirstFileA: «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_FindFirstFileA(lpFileName,lpFindFileData)
EndProcedure
Global Original_FindFirstFileW.FindFirstFile
Procedure Detour_FindFirstFileW(lpFileName,lpFindFileData)
	dbg("FindFirstFileW: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_FindFirstFileW(lpFileName,lpFindFileData)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfileexw
Prototype FindFirstFileEx(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
Global Original_FindFirstFileExA.FindFirstFileEx
Procedure Detour_FindFirstFileExA(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	dbg("FindFirstFileExA: «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_FindFirstFileExA(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
EndProcedure
Global Original_FindFirstFileExW.FindFirstFileEx
Procedure Detour_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
	dbg("FindFirstFileExW: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_FindFirstFileExW(lpFileName,fInfoLevelId,lpFindFileData,fSearchOp,lpSearchFilter,dwAdditionalFlags)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesw
Prototype.l GetFileAttributes(lpFileName)
Global Original_GetFileAttributesA.GetFileAttributes
Procedure.l Detour_GetFileAttributesA(lpFileName)
	dbg("GetFileAttributesA: «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetFileAttributesA(lpFileName)
EndProcedure
Global Original_GetFileAttributesW.GetFileAttributes
Procedure.l Detour_GetFileAttributesW(lpFileName)
	dbg("GetFileAttributesW: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_GetFileAttributesW(lpFileName)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesexw
Prototype GetFileAttributesEx(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
Global Original_GetFileAttributesExA.GetFileAttributesEx
Procedure Detour_GetFileAttributesExA(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
	dbg("GetFileAttributesExA: "+Str(fInfoLevelId)+" «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetFileAttributesExA(lpFileName,fInfoLevelId,*lpFileInformation)
EndProcedure
Global Original_GetFileAttributesExW.GetFileAttributesEx
Procedure Detour_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
	dbg("GetFileAttributesExW: "+Str(fInfoLevelId)+" «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_GetFileAttributesExW(lpFileName,fInfoLevelId,*lpFileInformation)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Prototype CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
Global Original_CreateFile2.CreateFile2
Procedure Detour_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams) ; всегда unicode?
	dbg("CreateFile2: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_CreateFile2(lpFileName,dwDesiredAccess,dwShareMode,dwCreationDisposition,pCreateExParams)
EndProcedure
Prototype CreateFile(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
Global Original_CreateFileA.CreateFile
Procedure Detour_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	dbg("CreateFileA: «"+PeekS(lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
EndProcedure
Global Original_CreateFileW.CreateFile
Procedure Detour_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
	dbg("CreateFileW: «"+PeekS(lpFileName)+"»")
	ProcedureReturn Original_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createdirectorya
Prototype CreateDirectory(lpPathName,lpSecurityAttributes)
Global Original_CreateDirectoryA.CreateDirectory
Procedure Detour_CreateDirectoryA(lpPathName,lpSecurityAttributes)
	dbg("CreateDirectoryA: «"+PeekS(lpPathName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_CreateDirectoryA(lpPathName,lpSecurityAttributes)
EndProcedure
Global Original_CreateDirectoryW.CreateDirectory
Procedure Detour_CreateDirectoryW(lpPathName,lpSecurityAttributes)
	dbg("CreateDirectoryW: «"+PeekS(lpPathName)+"»")
	ProcedureReturn Original_CreateDirectoryW(lpPathName,lpSecurityAttributes)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createdirectoryexa
Prototype CreateDirectoryEx(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
Global Original_CreateDirectoryExA.CreateDirectoryEx
Procedure Detour_CreateDirectoryExA(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
	dbg("CreateDirectoryExA: «"+PeekSZ(lpTemplateDirectory,-1,#PB_Ascii)+"» «"+PeekSZ(lpNewDirectory,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_CreateDirectoryExA(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
EndProcedure
Global Original_CreateDirectoryExW.CreateDirectoryEx
Procedure Detour_CreateDirectoryExW(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
	dbg("CreateDirectoryExW: «"+PeekSZ(lpTemplateDirectory)+"» «"+PeekSZ(lpNewDirectory)+"»")
	ProcedureReturn Original_CreateDirectoryExW(lpTemplateDirectory,lpNewDirectory,lpSecurityAttributes)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shcreatedirectoryexa
Prototype SHCreateDirectoryEx(hwnd,pszPath,*psa)
Global Original_SHCreateDirectoryExA.CreateDirectoryEx
Procedure Detour_SHCreateDirectoryExA(hwnd,pszPath,*psa)
	dbg("SHCreateDirectoryExA: «"+PeekSZ(pszPath,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_SHCreateDirectoryExA(hwnd,pszPath,*psa)
EndProcedure
Global Original_SHCreateDirectoryExW.CreateDirectoryEx
Procedure Detour_SHCreateDirectoryExW(hwnd,pszPath,*psa)
	dbg("SHCreateDirectoryExW: «"+PeekSZ(pszPath)+"»")
	ProcedureReturn Original_SHCreateDirectoryExW(hwnd,pszPath,*psa)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shfileoperationa
Prototype SHFileOperation(*FileOp.SHFILEOPSTRUCT)
Global Original_SHFileOperationA.SHFileOperation
Procedure Detour_SHFileOperationA(*FileOp.SHFILEOPSTRUCT)
	dbg("SHFileOperationA: "+PeekSZ(*FileOp\pFrom,-1,#PB_Ascii)+" «"+PeekSZ(*FileOp\pTo,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_SHFileOperationA(*FileOp)
EndProcedure
Global Original_SHFileOperationW.SHFileOperation
Procedure Detour_SHFileOperationW(*FileOp.SHFILEOPSTRUCT)
	dbg("SHFileOperationW: "+PeekSZ(*FileOp\pFrom)+" «"+PeekSZ(*FileOp\pTo)+"»")
	ProcedureReturn Original_SHFileOperationW(*FileOp)
EndProcedure
;;======================================================================================================================

Procedure ExtensionProcedure()
	DbgExt("PurePortableSimple Extention MFO")
	MH_HookApi(kernel32,GetFullPathNameA)
	MH_HookApi(kernel32,GetFullPathNameW)
	MH_HookApi(kernel32,FindFirstFileA)
	MH_HookApi(kernel32,FindFirstFileW)
	MH_HookApi(kernel32,FindFirstFileExA)
	MH_HookApi(kernel32,FindFirstFileExW)
	MH_HookApi(kernel32,GetFileAttributesA)
	MH_HookApi(kernel32,GetFileAttributesW)
	MH_HookApi(kernel32,GetFileAttributesExA)
	MH_HookApi(kernel32,GetFileAttributesExW)
	MH_HookApi(kernel32,CreateFile2,#MH_HOOKAPI_NOCHECKRESULT)
	MH_HookApi(kernel32,CreateFileA)
	MH_HookApi(kernel32,CreateFileW)
	MH_HookApi(kernel32,CreateDirectoryA)
	MH_HookApi(kernel32,CreateDirectoryW)
	MH_HookApi(kernel32,CreateDirectoryExA)
	MH_HookApi(kernel32,CreateDirectoryExW)
	LoadLibrary_(@"shell32.dll")
	MH_HookApi(shell32,SHCreateDirectoryExA)
	MH_HookApi(shell32,SHCreateDirectoryExW)
	MH_HookApi(shell32,SHFileOperationA)
	MH_HookApi(shell32,SHFileOperationW)
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 169
; FirstLine = 160
; Folding = ----
; Optimizer
; EnableThread
; Executable = PurePortIni.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.31
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.31
; VersionField6 = PurePortableSimpleExtension
; VersionField7 = PurePortIni.dll
; VersionField9 = (c) Smitis, 2017-2025