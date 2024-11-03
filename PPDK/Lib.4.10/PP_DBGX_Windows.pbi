;;======================================================================================================================

CompilerIf Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;======================================================================================================================

; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowexa
CompilerIf Not Defined(DETOUR_CREATEWINDOWEX,#PB_Constant) : #DETOUR_CREATEWINDOWEX=1 : CompilerEndIf
CompilerIf #DETOUR_CREATEWINDOWEX
	Prototype CreateWindowEx(dwExStyle,*lpClassName,*lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam)
	Global Original_CreateWindowExA.CreateWindowEx
	Procedure Detour_CreateWindowExA(wExStyle,*lpClassName,*lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam)
		Protected Result = Original_CreateWindowExA(wExStyle,*lpClassName,*lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam)
		dbg("CreateWindowExA: "+Result+"ClassName: «"+PeekSZ(*lpClassName,-1,#PB_Ascii)+"» WindowName: «"+PeekSZ(*lpWindowName,-1,#PB_Ascii)+"»")
		ProcedureReturn Result
	EndProcedure
	Global Original_CreateWindowExW.CreateWindowEx
	Procedure Detour_CreateWindowExW(wExStyle,*lpClassName,*lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam)
		Protected Result = Original_CreateWindowExW(wExStyle,*lpClassName,*lpWindowName,dwStyle,X,Y,nWidth,nHeight,hWndParent,hMenu,hInstance,lpParam)
		dbg("CreateWindowExW: "+Result+"ClassName: «"+PeekSZ(*lpClassName)+"» WindowName: «"+PeekSZ(*lpWindowName)+"»")
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-closewindow
CompilerIf Not Defined(DETOUR_CLOSEWINDOW,#PB_Constant) : #DETOUR_CLOSEWINDOW=1 : CompilerEndIf
CompilerIf #DETOUR_CLOSEWINDOW
	Prototype CloseWindow(hWnd)
	Global Original_CloseWindow.CloseWindow
	Procedure Detour_CloseWindow(hWnd)
		Protected Result = Original_CloseWindow(hWnd)
		dbg("CloseWindow: "+Result)
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-destroywindow
CompilerIf Not Defined(DETOUR_DESTROYWINDOW,#PB_Constant) : #DETOUR_DESTROYWINDOW=1 : CompilerEndIf
CompilerIf #DETOUR_DESTROYWINDOW
	Prototype DestroyWindow(hWnd)
	Global Original_DestroyWindow.DestroyWindow
	Procedure Detour_DestroyWindow(hWnd)
		Protected Result = Original_DestroyWindow(hWnd)
		dbg("DestroyWindow: "+Result)
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;======================================================================================================================


; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 5
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant