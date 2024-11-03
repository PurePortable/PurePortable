;;======================================================================================================================

CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSection(*lpAppName,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionA.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	dbg("GetPrivateProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetPrivateProfileSectionA(*lpAppName,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileSectionA = @Detour_GetPrivateProfileSectionA()
Global Original_GetPrivateProfileSectionW.GetPrivateProfileSection
Procedure.l Detour_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
	dbg("GetPrivateProfileSectionW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_GetPrivateProfileSectionW(*lpAppName,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileSectionW = @Detour_GetPrivateProfileSectionW()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileSectionNames(*lpReturnBuffer,nSize,*lpFileName)
Global Original_GetPrivateProfileSectionNamesA.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
	dbg("GetPrivateProfileSectionNamesA: «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetPrivateProfileSectionNamesA(*lpReturnBuffer,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileSectionNamesA = @Detour_GetPrivateProfileSectionNamesA()
Global Original_GetPrivateProfileSectionNamesW.GetPrivateProfileSectionNames
Procedure.l Detour_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
	dbg("GetPrivateProfileSectionNamesW: «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_GetPrivateProfileSectionNamesW(*lpReturnBuffer,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileSectionNamesW = @Detour_GetPrivateProfileSectionNamesW()
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestring
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprivateprofilestringa
Prototype.l GetPrivateProfileString(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
Global Original_GetPrivateProfileStringA.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	dbg("GetPrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetPrivateProfileStringA(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStringA = @Detour_GetPrivateProfileStringA()
Global Original_GetPrivateProfileStringW.GetPrivateProfileString
Procedure.l Detour_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
	dbg("GetPrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_GetPrivateProfileStringW(*lpSection,*lpKeyName,*lpDefault,*lpReturnedString,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStringW = @Detour_GetPrivateProfileStringW()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l GetPrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
Global Original_GetPrivateProfileStructA.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	dbg("GetPrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetPrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStructA = @Detour_GetPrivateProfileStructA()
Global Original_GetPrivateProfileStructW.GetPrivateProfileStruct
Procedure.l Detour_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
	dbg("GetPrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_GetPrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,nSize,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStructW = @Detour_GetPrivateProfileStructW()
;;----------------------------------------------------------------------------------------------------------------------
; TODO
Prototype.l GetPrivateProfileInt(*lpAppName,*lpKeyName,nDefault,*lpFileName)
Global Original_GetPrivateProfileIntA.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	dbg("GetPrivateProfileIntA: «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetPrivateProfileIntA(*lpAppName,*lpKeyName,nDefault,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileIntA = @Detour_GetPrivateProfileIntA()
Global Original_GetPrivateProfileIntW.GetPrivateProfileInt
Procedure.l Detour_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
	dbg("GetPrivateProfileIntW: «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_GetPrivateProfileIntW(*lpAppName,*lpKeyName,nDefault,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileIntW = @Detour_GetPrivateProfileIntW()
;;----------------------------------------------------------------------------------------------------------------------
; TODO
Prototype.l GetProfileSection(*lpAppName,*lpReturnedString,nSize)
Global Original_GetProfileSectionA.GetProfileSection
Procedure.l Detour_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
	dbg("GetProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetProfileSectionA(*lpAppName,*lpReturnedString,nSize)
EndProcedure
;Global Trampoline_GetProfileSectionA = @Detour_GetProfileSectionA()
Global Original_GetProfileSectionW.GetProfileSection
Procedure.l Detour_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
	dbg("GetProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	ProcedureReturn Original_GetProfileSectionW(*lpAppName,*lpReturnedString,nSize)
EndProcedure
;Global Trampoline_GetProfileSectionW = @Detour_GetProfileSectionW()
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprofilestringa
; Возврат: количество скопированных символов, исключая нулевой
; TODO
Prototype.l GetProfileString(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
Global Original_GetProfileStringA.GetProfileString
Procedure.l Detour_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	dbg("GetProfileStringA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetProfileStringA(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
EndProcedure
;Global Trampoline_GetProfileStringA = @Detour_GetProfileStringA()
Global Original_GetProfileStringW.GetProfileString
Procedure.l Detour_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
	dbg("GetProfileStringW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	ProcedureReturn Original_GetProfileStringW(*lpAppName,*lpKeyName,*lpDefault,*lpReturnedString,nSize)
EndProcedure
;Global Trampoline_GetProfileStringW = @Detour_GetProfileStringW()
;;----------------------------------------------------------------------------------------------------------------------
; TODO
Prototype GetProfileInt(*lpAppName,*lpKeyName,nDefault)
Global Original_GetProfileIntA.GetProfileInt
Procedure Detour_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
	dbg("GetProfileIntA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_GetProfileIntA(*lpAppName,*lpKeyName,nDefault)
EndProcedure
;Global Trampoline_GetProfileIntA = @Detour_GetProfileIntA()
Global Original_GetProfileIntW.GetProfileInt
Procedure Detour_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
	dbg("GetProfileIntW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpKeyName)+"»")
	ProcedureReturn Original_GetProfileIntW(*lpAppName,*lpKeyName,nDefault)
EndProcedure
;Global Trampoline_GetProfileIntA = @Detour_GetProfileIntA()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileSection(*lpAppName,*lpString,*lpFileName)
Global Original_WritePrivateProfileSectionA.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
	dbg("GetPrivateProfileStringA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpString,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_WritePrivateProfileSectionA(*lpAppName,*lpString,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStringA = @Detour_GetPrivateProfileStringA()
Global Original_WritePrivateProfileSectionW.WritePrivateProfileSection
Procedure.l Detour_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
	dbg("GetPrivateProfileStringW: «"+PeekSZ(*lpAppName)+"» «"+PeekSZ(*lpString)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_WritePrivateProfileSectionW(*lpAppName,*lpString,*lpFileName)
EndProcedure
;Global Trampoline_GetPrivateProfileStringW = @Detour_GetPrivateProfileStringW()
;;----------------------------------------------------------------------------------------------------------------------
; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-writeprivateprofilesectiona
Prototype.l WritePrivateProfileString(*lpSection,*lpKeyName,*lpString,*lpFileName)
Global Original_WritePrivateProfileStringA.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
	dbg("WritePrivateProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_WritePrivateProfileStringA(*lpSection,*lpKeyName,*lpString,*lpFileName)
EndProcedure
;Global Trampoline_WritePrivateProfileStringA = @Detour_WritePrivateProfileStringA()
Global Original_WritePrivateProfileStringW.WritePrivateProfileString
Procedure.l Detour_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
	dbg("WritePrivateProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_WritePrivateProfileStringW(*lpSection,*lpKeyName,*lpString,*lpFileName)
EndProcedure
;Global Trampoline_WritePrivateProfileStringW = @Detour_WritePrivateProfileStringW()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WritePrivateProfileStruct(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
Global Original_WritePrivateProfileStructA.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	dbg("WritePrivateProfileStructA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"» «"+PeekSZ(*lpFileName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_WritePrivateProfileStructA(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
EndProcedure
;Global Trampoline_WritePrivateProfileStructA = @Detour_WritePrivateProfileStructA()
Global Original_WritePrivateProfileStructW.WritePrivateProfileStruct
Procedure.l Detour_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
	dbg("WritePrivateProfileStructW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"» «"+PeekSZ(*lpFileName)+"»")
	ProcedureReturn Original_WritePrivateProfileStructW(*lpSection,*lpKeyName,*lpStruct,uSizeStruct,*lpFileName)
EndProcedure
;Global Trampoline_WritePrivateProfileStructW = @Detour_WritePrivateProfileStructW()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileSection(*lpAppName,*lpString)
Global Original_WriteProfileSectionA.WriteProfileSection
Procedure.l Detour_WriteProfileSectionA(*lpAppName,*lpString)
	dbg("WriteProfileSectionA: «"+PeekSZ(*lpAppName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_WriteProfileSectionA(*lpAppName,*lpString)
EndProcedure
;Global Trampoline_WriteProfileSectionA = @Detour_WriteProfileSectionA()
Global Original_WriteProfileSectionW.WriteProfileSection
Procedure.l Detour_WriteProfileSectionW(*lpAppName,*lpString)
	dbg("WriteProfileSectionW: «"+PeekSZ(*lpAppName)+"»")
	ProcedureReturn Original_WriteProfileSectionW(*lpAppName,*lpString)
EndProcedure
;Global Trampoline_WriteProfileSectionW = @Detour_WriteProfileSectionW()
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l WriteProfileString(*lpSection,*lpKeyName,*lpString)
Global Original_WriteProfileStringA.WriteProfileString
Procedure.l Detour_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
	dbg("WriteProfileStringA: «"+PeekSZ(*lpSection,-1,#PB_Ascii)+"» «"+PeekSZ(*lpKeyName,-1,#PB_Ascii)+"»")
	ProcedureReturn Original_WriteProfileStringA(*lpSection,*lpKeyName,*lpString)
EndProcedure
;Global Trampoline_WriteProfileStringA = @Detour_WriteProfileStringA()
Global Original_WriteProfileStringW.WriteProfileString
Procedure.l Detour_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
	dbg("WriteProfileStringW: «"+PeekSZ(*lpSection)+"» «"+PeekSZ(*lpKeyName)+"»")
	ProcedureReturn Original_WriteProfileStringW(*lpSection,*lpKeyName,*lpString)
EndProcedure
;Global Trampoline_WriteProfileStringW = @Detour_WriteProfileStringW()
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

Procedure _InitDbgxProfileStringsHooks()
	MH_HookApi(kernel32,GetPrivateProfileSectionA)
	MH_HookApi(kernel32,GetPrivateProfileSectionW)
	MH_HookApi(kernel32,GetPrivateProfileSectionNamesA)
	MH_HookApi(kernel32,GetPrivateProfileSectionNamesW)
	MH_HookApi(kernel32,GetPrivateProfileStringA)
	MH_HookApi(kernel32,GetPrivateProfileStringW)
	MH_HookApi(kernel32,GetPrivateProfileStructA)
	MH_HookApi(kernel32,GetPrivateProfileStructW)
	MH_HookApi(kernel32,GetPrivateProfileIntA)
	MH_HookApi(kernel32,GetPrivateProfileIntW)
	
	MH_HookApi(kernel32,GetProfileStringA)
	MH_HookApi(kernel32,GetProfileStringW)
	MH_HookApi(kernel32,GetProfileSectionA)
	MH_HookApi(kernel32,GetProfileSectionW)
	MH_HookApi(kernel32,GetProfileIntA)
	MH_HookApi(kernel32,GetProfileIntW)
	
	MH_HookApi(kernel32,WritePrivateProfileSectionA)
	MH_HookApi(kernel32,WritePrivateProfileSectionW)
	MH_HookApi(kernel32,WritePrivateProfileStringA)
	MH_HookApi(kernel32,WritePrivateProfileStringW)
	MH_HookApi(kernel32,WritePrivateProfileStructA)
	MH_HookApi(kernel32,WritePrivateProfileStructW)
	
	MH_HookApi(kernel32,WriteProfileSectionA)
	MH_HookApi(kernel32,WriteProfileSectionW)
	MH_HookApi(kernel32,WriteProfileStringA)
	MH_HookApi(kernel32,WriteProfileStringW)
EndProcedure
AddInitProcedure(_InitDbgxProfileStringsHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 200
; FirstLine = 180
; Folding = -----
; EnableAsm
; EnableThread
; DisableDebugger
; EnableExeConstant