﻿;;======================================================================================================================
; Portable WINAPI wrapper for PureApps
;;======================================================================================================================

;PP_SILENT
;PP_PUREPORTABLE 1
;PP_FORMAT DLL
;PP_ENABLETHREAD 1
;RES_VERSION 4.10.0.6
;RES_DESCRIPTION Proxy dll
;RES_COPYRIGHT (c) Smitis, 2017-2024
;RES_INTERNALNAME 400.dll
;RES_PRODUCTNAME Pure Portable
;RES_PRODUCTVERSION 4.10.0.0
;RES_COMMENT PAM Project
;PP_X32_COPYAS "Proxy32.dll"
;PP_X64_COPYAS "Proxy64.dll"
;PP_CLEAN 2

EnableExplicit
IncludePath "..\lib" ; Для доступа к файлам рядом с исходником можно использовать #PB_Compiler_FilePath
;XIncludeFile "PurePortableCustom.pbi"

#PROXY_DLL = "winmm"
;#PROXY_DLL_COMPATIBILITY = 7 ; Совместимость: 5 - XP, 7 - Windows 7 (default), 10 - Windows 10

XIncludeFile "PurePortableProxy.pbi"
;;======================================================================================================================
ProcedureDLL.l AttachProcess(Instance)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Protected dll.s = "PurePort32.dll"
	CompilerElse
		Protected dll.s = "PurePort64.dll"
	CompilerEndIf
	If FileExist(DllDir+dll)
		dll = DllDir+dll
	ElseIf FileExist(DllDir+"PurePort.dll")
		dll = DllDir+"PurePort.dll"
	EndIf
	LoadLibrary_(@dll)
	;PPInitialization
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; ProcedureDLL.l DetachProcess(Instance)
; 	
; 	PPFinish
; EndProcedure

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 37
; FirstLine = 15
; Folding = -
; Optimizer
; EnableThread
; Executable = 400.dll
; DisableDebugger
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 4.00.1.0
; VersionField1 = 4.0.10.0
; VersionField3 = Pure Portable
; VersionField4 = 4.0.10.0
; VersionField5 = 4.00.1.0
; VersionField6 = Proxy dll
; VersionField7 = 400.dll
; VersionField9 = (c) Smitis, 2017-2024
; VersionField18 = Comments
; VersionField21 = PAM Project