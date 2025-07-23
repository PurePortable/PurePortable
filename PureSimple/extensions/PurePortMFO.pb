;;======================================================================================================================
; PurePortableSimple Extention MFO
; Расширение для мониторинга файловых операций.
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.11.0.10
;RES_DESCRIPTION Monitoring file operations
;RES_COPYRIGHT (c) Smitis, 2017-2025
;RES_INTERNALNAME PurePortMFO
;RES_PRODUCTNAME PurePortable
;RES_PRODUCTVERSION 4.11.0.0
;PP_X32_COPYAS nul
;PP_X64_COPYAS nul
;PP_CLEAN 2

EnableExplicit
IncludePath "..\..\PPDK\Lib"

XIncludeFile "PurePortableExtension.pbi"
XIncludeFile "proc\GuidInfo.pbi"
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
; https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw
Prototype CreateProcess(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
Global Original_CreateProcessA.CreateProcess
Procedure Detour_CreateProcessA(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
	dbg("CreateProcessA: «"+PeekSZ(lpApplicationName,-1,#PB_Ascii)+"» «"+PeekSZ(lpCommandLine,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_CreateProcessA(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo,*ProcessInformation)
EndProcedure
Global Original_CreateProcessW.CreateProcess
Procedure Detour_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation.PROCESS_INFORMATION)
	dbg("CreateProcessW: «"+PeekSZ(lpApplicationName)+"» «"+PeekSZ(lpCommandLine)+"»")
	ProcedureReturn Original_CreateProcessW(lpApplicationName,lpCommandLine,lpProcessAttributes,lpThreadAttributes,bInheritHandles,dwCreationFlags,lpEnvironment,lpCurrentDirectory,*StartupInfo.STARTUPINFO,*ProcessInformation)
EndProcedure
;;======================================================================================================================
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutew
Prototype ShellExecute(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
Global Original_ShellExecuteA.ShellExecute
Procedure Detour_ShellExecuteA(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
	dbg("ShellExecuteA: «"+PeekSZ(lpOperation,-1,#PB_Ascii)+"» «"+PeekSZ(lpFile,-1,#PB_Ascii)+"» «"+PeekSZ(lpParameters,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_ShellExecuteA(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
EndProcedure
Global Original_ShellExecuteW.ShellExecute
Procedure Detour_ShellExecuteW(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
	dbg("ShellExecuteW: «"+PeekSZ(lpOperation)+"» «"+PeekSZ(lpFile)+"» «"+PeekSZ(lpParameters)+"»")
	ProcedureReturn Original_ShellExecuteW(hwnd,lpOperation,lpFile,lpParameters,lpDirectory,nShowCmd)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecuteexw
; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-shellexecuteinfow
Prototype ShellExecuteEx(*pExecInfo.SHELLEXECUTEINFO)
Global Original_ShellExecuteExA.ShellExecuteEx
Procedure Detour_ShellExecuteExA(*pExecInfo.SHELLEXECUTEINFO)
	dbg("ShellExecuteExA: «"+PeekSZ(*pExecInfo\lpVerb,-1,#PB_Ascii)+"» «"+PeekSZ(*pExecInfo\lpFile,-1,#PB_Ascii)+"» «"+PeekSZ(*pExecInfo\lpParameters,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_ShellExecuteExA(*pExecInfo)
EndProcedure
Global Original_ShellExecuteExW.ShellExecuteEx
Procedure Detour_ShellExecuteExW(*pExecInfo.SHELLEXECUTEINFO)
	dbg("ShellExecuteExW: «"+PeekSZ(*pExecInfo\lpVerb)+"» «"+PeekSZ(*pExecInfo\lpFile)+"» «"+PeekSZ(*pExecInfo\lpParameters)+"»")
	ProcedureReturn Original_ShellExecuteExW(*pExecInfo)
EndProcedure
;;======================================================================================================================
XIncludeFile "proc\GuidInfo.pbi"
XIncludeFile "proc\guid2s.pbi"
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-clsidfromprogid
Prototype CLSIDFromProgID(lpszProgID,*clsid)
Global Original_CLSIDFromProgID.CLSIDFromProgID
Procedure Detour_CLSIDFromProgID(lpszProgID,*clsid)
	Protected Result = Original_CLSIDFromProgID(lpszProgID,*clsid)
	;Protected clsid.s
	If Result
		dbg("CLSIDFromProgID: "+PeekSZ(lpszProgID)+" CLSID: "+guid2s(*clsid))
	Else
		dbg("CLSIDFromProgID: "+PeekSZ(lpszProgID)+" CLSID: "+guid2s(*clsid)+" ???")
	EndIf
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-progidfromclsid
Prototype ProgIDFromCLSID(*clsid,*ProgID.Integer)
Global Original_ProgIDFromCLSID.ProgIDFromCLSID
Procedure Detour_ProgIDFromCLSID(*clsid,*ProgID.Integer)
	Protected Result = Original_ProgIDFromCLSID(*clsid,*ProgID)
	If Result
		dbg("ProgIDFromCLSID: "+guid2s(*clsid)+" ProgID: "+PeekSZ(*ProgID\i))
	Else
		dbg("ProgIDFromCLSID: "+guid2s(*clsid)+" ProgID: "+PeekSZ(*ProgID\i)+" ???")
	EndIf
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cocreateinstance
; ole32.lib, combaseapi.h (include objbase.h)
Prototype CoCreateInstance(rclsid,pUnkOuter,dwClsContext,riid,*ppv)
Global Original_CoCreateInstance.CoCreateInstance
Procedure Detour_CoCreateInstance(rclsid,pUnkOuter,dwClsContext,riid,*ppv)
	Protected Result = Original_CoCreateInstance(rclsid,pUnkOuter,dwClsContext,riid,*ppv)
	dbg("CoCreateInstance: ("+Str(Result)+") "+GuidInfo(rclsid))
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cocreateinstanceex
Prototype CoCreateInstanceEx(rclsid,*punkOuter,dwClsCtx.l,*pServerInfo,dwCount.l,*pResults)
Global Original_CoCreateInstanceEx.CoCreateInstanceEx
Procedure Detour_CoCreateInstanceEx(rclsid,*punkOuter,dwClsCtx.l,*pServerInfo,dwCount.l,*pResults)
	Protected Result = Original_CoCreateInstanceEx(rclsid,*punkOuter,dwClsCtx,*pServerInfo,dwCount,*pResults)
	dbg("CoCreateInstanceEx: ("+Str(Result)+") "+GuidInfo(rclsid))
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/objbase/nf-objbase-cogetinstancefromfile
; CoGetInstanceFromFile ???
;Prototype CoGetInstanceFromFile(*pServerInfo,*pClsid,*punkOuter,dwClsCtx.l,grfMode.l,*pwszName,dwCount,*pResults)
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/combaseapi/nf-combaseapi-cogetclassobject
Prototype CoGetClassObject(rclsid,dwClsContext.l,*pvReserved,riid,*ppv)
Global Original_CoGetClassObject.CoGetClassObject
Procedure Detour_CoGetClassObject(rclsid,dwClsContext.l,*pvReserved,riid,*ppv)
	Protected Result = Original_CoGetClassObject(rclsid,dwClsContext,*pvReserved,riid,*ppv)
	dbg("CoGetClassObject: ("+Str(Result)+") "+GuidInfo(rclsid))
	ProcedureReturn Result
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; CoGetObject ???
; https://learn.microsoft.com/en-us/windows/win32/api/objbase/nf-objbase-cogetobject
;;======================================================================================================================

#EXT_SECTION_MAIN = "EXT:MFO"

Global MonitorFileOp = 1
Global MonitorShellOp = 1
Global MonitorCreateProcess = 1
Global MonitorShellExecute = 1
Global MonitorCOM = 0

Procedure ExtensionProcedure()
	DbgExt("EXTENSION: Monitoring file operations")
	If OpenPreferences(PureSimplePrefs,#PB_Preference_NoSpace)
		If PreferenceGroup(#EXT_SECTION_MAIN)
			MonitorFileOp = ReadPreferenceInteger("FileOp",1)
			MonitorShellOp = ReadPreferenceInteger("ShellOp",1)
			MonitorCreateProcess = ReadPreferenceInteger("CreateProcess",1)
			MonitorShellExecute = ReadPreferenceInteger("ShellExecute",1)
			MonitorCOM = ReadPreferenceInteger("COM",0)
		EndIf
		ClosePreferences()
	EndIf
	
	If MonitorFileOp
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
	EndIf
	If MonitorShellOp
		LoadLibrary_(@"shell32.dll")
		MH_HookApi(shell32,SHCreateDirectoryExA)
		MH_HookApi(shell32,SHCreateDirectoryExW)
		MH_HookApi(shell32,SHFileOperationA)
		MH_HookApi(shell32,SHFileOperationW)
	EndIf
	If MonitorCreateProcess
		MH_HookApi(kernel32,CreateProcessA)
		MH_HookApi(kernel32,CreateProcessW)
	EndIf
	If MonitorShellExecute
		MH_HookApi(shell32,ShellExecuteA)
		MH_HookApi(shell32,ShellExecuteW)
		MH_HookApi(shell32,ShellExecuteExA)
		MH_HookApi(shell32,ShellExecuteExW)
	EndIf
	If MonitorCOM
		;LoadLibrary_(@"ole32.dll")
		MH_HookApi(ole32,CoCreateInstance)
		MH_HookApi(ole32,CoCreateInstanceEx)
		MH_HookApi(ole32,CoGetClassObject)
		MH_HookApi(ole32,CLSIDFromProgID)
		MH_HookApi(ole32,ProgIDFromCLSID)
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 244
; FirstLine = 148
; Folding = AAAA5-
; Optimizer
; EnableThread
; Executable = PurePortIni.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.11.0.10
; VersionField1 = 4.11.0.0
; VersionField3 = PurePortable
; VersionField4 = 4.11.0.0
; VersionField5 = 4.11.0.10
; VersionField6 = Monitoring file operations
; VersionField7 = PurePortMFO
; VersionField9 = (c) Smitis, 2017-2025
