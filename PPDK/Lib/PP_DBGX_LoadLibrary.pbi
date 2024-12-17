;;======================================================================================================================
; TODO:
; - AfxLoadLibrary (MFC42, MFC42U)
; - https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-disablethreadlibrarycalls
; - https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-removedlldirectory

;;======================================================================================================================

CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-adddlldirectory
CompilerIf Not Defined(DETOUR_ADDDLLDIRECTORY,#PB_Constant) : #DETOUR_ADDDLLDIRECTORY=1 : CompilerEndIf
CompilerIf #DETOUR_ADDDLLDIRECTORY
	Prototype AddDllDirectory(*NewDirectory)
	Global Original_AddDllDirectory.AddDllDirectory
	Procedure Detour_AddDllDirectory(*NewDirectory)
		dbg("AddDllDirectory: "+PeekS(*NewDirectory))
		ProcedureReturn Original_AddDllDirectory(*NewDirectory)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-setdefaultdlldirectories
CompilerIf Not Defined(DETOUR_SETDEFAULTDLLDIRECTORIES,#PB_Constant) : #DETOUR_SETDEFAULTDLLDIRECTORIES=1 : CompilerEndIf
CompilerIf #DETOUR_SETDEFAULTDLLDIRECTORIES
	Prototype SetDefaultDllDirectories(DirectoryFlags.l)
	Global Original_SetDefaultDllDirectories.SetDefaultDllDirectories
	Procedure Detour_SetDefaultDllDirectories(DirectoryFlags.l)
		Protected DirectoryFlagsText.s = Bin(DirectoryFlags)
		If DirectoryFlags & #LOAD_LIBRARY_SEARCH_APPLICATION_DIR ; 0x00000200
			DirectoryFlagsText + " LOAD_LIBRARY_SEARCH_APPLICATION_DIR"
		EndIf
		If DirectoryFlags & #LOAD_LIBRARY_SEARCH_DEFAULT_DIRS ; 0x00001000
			DirectoryFlagsText + " LOAD_LIBRARY_SEARCH_DEFAULT_DIRS"
		EndIf
		If DirectoryFlags & #LOAD_LIBRARY_SEARCH_SYSTEM32 ; 0x00000800
			DirectoryFlagsText + " LOAD_LIBRARY_SEARCH_SYSTEM32"
		EndIf
		If DirectoryFlags & #LOAD_LIBRARY_SEARCH_USER_DIRS ; 0x00000400
			DirectoryFlagsText + " LOAD_LIBRARY_SEARCH_USER_DIRS"
		EndIf
		dbg("SetDefaultDllDirectories: "+DirectoryFlagsText)
		ProcedureReturn Original_SetDefaultDllDirectories(DirectoryFlags)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setdlldirectorya
CompilerIf Not Defined(DETOUR_SETDLLDIRECTORY,#PB_Constant) : #DETOUR_SETDLLDIRECTORY=1 : CompilerEndIf
CompilerIf #DETOUR_SETDLLDIRECTORY
	Prototype SetDllDirectory(*lpPathName)
	Global Original_SetDllDirectoryA.SetDllDirectory
	Procedure Detour_SetDllDirectoryA(*lpPathName)
		dbg("SetDllDirectoryA: "+PeekSZ(*lpPathName,-1,#PB_Ascii))
		ProcedureReturn Original_SetDllDirectoryA(*lpPathName)
	EndProcedure
	Global Original_SetDllDirectoryW.SetDllDirectory
	Procedure Detour_SetDllDirectoryW(*lpPathName)
		dbg("SetDllDirectoryW: "+PeekSZ(*lpPathName))
		ProcedureReturn Original_SetDllDirectoryW(*lpPathName)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setsearchpathmode
CompilerIf Not Defined(DETOUR_SETSEARCHPATHMODE,#PB_Constant) : #DETOUR_SETSEARCHPATHMODE=1 : CompilerEndIf
CompilerIf #DETOUR_SETSEARCHPATHMODE
	#BASE_SEARCH_PATH_ENABLE_SAFE_SEARCHMODE = $00000001
	#BASE_SEARCH_PATH_DISABLE_SAFE_SEARCHMODE = $00010000
	#BASE_SEARCH_PATH_PERMANENT = $00008000
	Prototype SetSearchPathMode(Flags.l)
	Global Original_SetSearchPathMode.SetSearchPathMode
	Procedure Detour_SetSearchPathMode(Flags.l)
		Protected FlagsText.s = Bin(Flags)
		If Flags & #BASE_SEARCH_PATH_ENABLE_SAFE_SEARCHMODE ; 0x00000001
			FlagsText + " BASE_SEARCH_PATH_ENABLE_SAFE_SEARCHMODE"
		EndIf
		If Flags & #BASE_SEARCH_PATH_DISABLE_SAFE_SEARCHMODE ; 0x00010000
			FlagsText + " BASE_SEARCH_PATH_DISABLE_SAFE_SEARCHMODE"
		EndIf
		If Flags & #BASE_SEARCH_PATH_PERMANENT ;0x00008000
			FlagsText + " BASE_SEARCH_PATH_PERMANENT"
		EndIf
		dbg("SetSearchPathMode: "+FlagsText)
		ProcedureReturn Original_SetSearchPathMode(Flags)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryw
CompilerIf Not Defined(DETOUR_LOADLIBRARY,#PB_Constant) : #DETOUR_LOADLIBRARY=1 : CompilerEndIf
CompilerIf #DETOUR_LOADLIBRARY
	Prototype LoadLibrary(*LibFileName)
	Global Original_LoadLibraryA.LoadLibrary
	Procedure Detour_LoadLibraryA(*LibFileName)
		Protected Result = Original_LoadLibraryA(*LibFileName)
		dbg("LoadLibraryA: "+Str(Result)+" "+PeekSZ(*LibFileName,-1,#PB_Ascii))
		ProcedureReturn Result
	EndProcedure
	Global Original_LoadLibraryW.LoadLibrary
	Procedure Detour_LoadLibraryW(*LibFileName)
		Protected Result = Original_LoadLibraryW(*LibFileName)
		dbg("LoadLibraryW: "+Str(Result)+" "+PeekSZ(*LibFileName))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexw
CompilerIf Not Defined(DETOUR_LOADLIBRARYEX,#PB_Constant) : #DETOUR_LOADLIBRARYEX=1 : CompilerEndIf
CompilerIf #DETOUR_LOADLIBRARYEX
	Prototype LoadLibraryEx(*LibFileName,hFile,dwFlags)
	Global Original_LoadLibraryExA.LoadLibraryEx
	Procedure Detour_LoadLibraryExA(*LibFileName,hFile,dwFlags)
		Protected Result = Original_LoadLibraryExA(*LibFileName,hFile,dwFlags)
		dbg("LoadLibraryExA: "+Str(Result)+" "+PeekSZ(*LibFileName,-1,#PB_Ascii))
		ProcedureReturn Result
	EndProcedure
	Global Original_LoadLibraryExW.LoadLibraryEx
	Procedure Detour_LoadLibraryExW(*LibFileName,hFile,dwFlags)
		Protected Result = Original_LoadLibraryExW(*LibFileName,hFile,dwFlags)
		dbg("LoadLibraryExW: "+Str(Result)+" "+PeekSZ(*LibFileName))
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress
CompilerIf Not Defined(DETOUR_GETPROCADDRESS,#PB_Constant) : #DETOUR_GETPROCADDRESS=1 : CompilerEndIf
CompilerIf #DETOUR_GETPROCADDRESS
	Prototype GetProcAddress(hModule,*ProcName)
	Global Original_GetProcAddress.GetProcAddress
	Procedure Detour_GetProcAddress(hModule,*ProcName)
		Protected Result = Original_GetProcAddress(hModule,*ProcName)
		If *ProcName<$10000
			dbg("GetProcAddress: "+Str(Result)+" "+HexLA(*ProcName))
		Else
			dbg("GetProcAddress: "+Str(Result)+" "+PeekSZ(*ProcName,-1,#PB_Ascii))
		EndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandlea
CompilerIf Not Defined(DETOUR_GETMODULEHANDLE,#PB_Constant) : #DETOUR_GETMODULEHANDLE=1 : CompilerEndIf
CompilerIf #DETOUR_GETMODULEHANDLE
	Prototype GetModuleHandle(*lpModuleName)
	Global Original_GetModuleHandleA.GetModuleHandle
	Procedure Detour_GetModuleHandleA(*lpModuleName)
		dbg("GetModuleHandleA: "+PeekSZ(*lpModuleName,-1,#PB_Ascii))
		ProcedureReturn Original_GetModuleHandleA(*lpModuleName)
	EndProcedure
	Global Original_GetModuleHandleW.GetModuleHandle
	Procedure Detour_GetModuleHandleW(*lpModuleName)
		dbg("GetModuleHandleW: "+PeekSZ(*lpModuleName))
		ProcedureReturn Original_GetModuleHandleW(*lpModuleName)
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/ru-ru/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexa
; GetModuleHandleExW
CompilerIf Not Defined(DETOUR_GETMODULEHANDLEEX,#PB_Constant) : #DETOUR_GETMODULEHANDLEEX=1 : CompilerEndIf
CompilerIf #DETOUR_GETMODULEHANDLEEX
	Prototype GetModuleHandleEx(dwFlags.l,*lpModuleName,*phModule)
	Global Original_GetModuleHandleExA.GetModuleHandleEx
	Procedure Detour_GetModuleHandleExA(dwFlags.l,*lpModuleName,*phModule)
		dbg("GetModuleHandleExA: "+PeekSZ(*lpModuleName,-1,#PB_Ascii))
		ProcedureReturn Original_GetModuleHandleExA(dwFlags.l,*lpModuleName,*phModule)
	EndProcedure
	Global Original_GetModuleHandleExW.GetModuleHandleEx
	Procedure Detour_GetModuleHandleExW(dwFlags.l,*lpModuleName,*phModule)
		dbg("GetModuleHandleExW: "+PeekSZ(*lpModuleName))
		ProcedureReturn Original_GetModuleHandleExW(dwFlags.l,*lpModuleName,*phModule)
	EndProcedure
CompilerEndIf
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

Procedure _InitDbgxLoadLibrary()
	CompilerIf #DETOUR_ADDDLLDIRECTORY
		MH_HookApi(kernel32,AddDllDirectory)
	CompilerEndIf
	CompilerIf #DETOUR_SETDEFAULTDLLDIRECTORIES
		MH_HookApi(kernel32,SetDefaultDllDirectories)
	CompilerEndIf
	CompilerIf #DETOUR_SETDLLDIRECTORY
		MH_HookApi(kernel32,SetDllDirectoryA)
		MH_HookApi(kernel32,SetDllDirectoryW)
	CompilerEndIf
	CompilerIf #DETOUR_SETSEARCHPATHMODE
		MH_HookApi(kernel32,SetSearchPathMode)
	CompilerEndIf
	CompilerIf #DETOUR_LOADLIBRARY
		MH_HookApi(kernel32,LoadLibraryA)
		MH_HookApi(kernel32,LoadLibraryW)
	CompilerEndIf
	CompilerIf #DETOUR_LOADLIBRARYEX
		MH_HookApi(kernel32,LoadLibraryExA)
		MH_HookApi(kernel32,LoadLibraryExW)
	CompilerEndIf
	CompilerIf #DETOUR_GETPROCADDRESS And #DBGX_LOAD_LIBRARY=1
		MH_HookApi(kernel32,GetProcAddress)
	CompilerEndIf
EndProcedure
AddInitProcedure(_InitDbgxLoadLibrary)

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = AA5
; EnableThread
; DisableDebugger
; EnableExeConstant