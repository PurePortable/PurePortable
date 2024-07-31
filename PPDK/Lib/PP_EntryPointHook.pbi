;;======================================================================================================================
; Установка хука на EntryPoint программы
;;======================================================================================================================
XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================

Declare EntryPoint()
!JMP l_detour_entry_point_end
Detour_EntryPoint:
EntryPoint()
!JMP [v_Original_EntryPoint]
detour_entry_point_end:

;;======================================================================================================================
Global Original_EntryPoint
; ExeMain, Entry, MainEntry, EntryPoint
Procedure _InitEntryPointHook()
	Protected mi.MODULEINFO
	GetModuleInformation_(GetCurrentProcess_(),GetModuleHandle_(#Null),@mi,SizeOf(MODULEINFO))
	MH_CreateHook(mi\EntryPoint,?Detour_EntryPoint,@Original_EntryPoint)
	MH_EnableHook(mi\EntryPoint)
	;dbg(Str(mi\EntryPoint)+" "+Str(?Detour_EntryPoint)+" "+Str(Original_EntryPoint))
EndProcedure
AddInitProcedure(_InitEntryPointHook)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant