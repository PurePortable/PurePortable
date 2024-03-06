;;======================================================================================================================
; Описание и иницилизация экспортируемых прокси-функций
;;======================================================================================================================
CompilerIf Not Defined(DBG_PROXY_DLL,#PB_Constant) : #DBG_PROXY_DLL = 0 : CompilerEndIf
CompilerIf Not Defined(PROXY_DLL_ERROR_IGNORE,#PB_Constant) : #PROXY_DLL_ERROR_IGNORE = 0 : CompilerEndIf
CompilerIf #DBG_PROXY_DLL
	;UndefineMacro dbgany : DbgAnyDef
	Macro dbgproxy(txt) : dbg(txt) : EndMacro
	;Macro dbgproxy2(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro dbgproxy(txt) : EndMacro
	;Macro dbgproxy2(txt) : EndMacro
CompilerEndIf

UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro
UndefineMacro SingleQuote
Macro SingleQuote
	'
EndMacro

; Макросы для описания экспортируемых прокси-функции в dll, компилируемых не под своим именем (comdlg32, advapi32 и др.)
;CompilerIf Not Defined(PROXY_INDIRECT,#PB_Constant) : #PROXY_INDIRECT = 0 : CompilerEndIf
; Трамплин на оригинальную функцию через импорт (компиляция с использованием библиотеки импорта).
; Перехват нужен - в Detour-функцию попадём только через перехват.
Macro DeclareExportFunc(FuncName,LibName,Name32,Name64)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			ProcedureDLL FuncName()
				!JMP Name32
			EndProcedure
		CompilerElse
			ProcedureDLL FuncName()
				!ADD RSP,40
				!JMP Name64
			EndProcedure
		CompilerEndIf
EndMacro
; Только x32
Macro DeclareExportFunc32(FuncName,LibName,Name32)
	Import DoubleQuote#LibName.lib#DoubleQuote
		Import_#FuncName As DoubleQuote#Name32#DoubleQuote
	EndImport
	ProcedureDLL FuncName()
		!JMP Name32
	EndProcedure
EndMacro
; Только x64
Macro DeclareExportFunc64(FuncName,LibName,Name64)
	Import DoubleQuote#LibName.lib#DoubleQuote
		Import_#FuncName As DoubleQuote#Name64#DoubleQuote
	EndImport
	ProcedureDLL FuncName()
		!ADD RSP,40
		!JMP Name64
	EndProcedure
EndMacro
; Перехват не обязателен - в Detour-функцию попадём через JMP.
; Переменная Original_FuncName будет указывать на статически импортируемую функцию.
; Если хук будет установлен, Original_FuncName будет переписана, всё будет работать как при обычном перехвате.
; Первоначальная инициализация Original_FuncName в последнем случае будет лишней, но на работу это не повлияет.
; TODO: Можно сделать проверку на то, есть ли установка хуков.
Macro DeclareExportFuncDetour(FuncName,LibName,Name32,Name64)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
	CompilerIf Defined(Detour_#FuncName,#PB_Procedure)
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			ProcedureDLL FuncName()
				!JMP [v_Trampoline_#FuncName]
			EndProcedure
		CompilerElse
			ProcedureDLL FuncName()
				!ADD RSP,40
				!JMP [v_Trampoline_#FuncName]
			EndProcedure
		CompilerEndIf
		Global Trampoline_#FuncName = @Detour_#FuncName()
		Global Original_#FuncName = @Import_#FuncName
	CompilerElse
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			ProcedureDLL FuncName()
				!JMP Name32
			EndProcedure
		CompilerElse
			ProcedureDLL FuncName()
				!ADD RSP,40
				!JMP Name64
			EndProcedure
		CompilerEndIf
	CompilerEndIf
EndMacro

; https://docs.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexa
#LOAD_LIBRARY_SEARCH_SYSTEM32 = $00000800
#LOAD_LIBRARY_SEARCH_USER_DIRS = $00000400
#LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR = $00000100
#LOAD_LIBRARY_SEARCH_APPLICATION_DIR = $00000200
#LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = $00001000
#LOAD_WITH_ALTERED_SEARCH_PATH = $00000008

; DLL загружаем, но не выгружаем!
; Эта функция может быть вызвана до AttachProcess!
Global SysDir.s
Procedure.i LoadDll(DllName.s,fSystem=1)
	; GetWindowsDirectory(lpBuffer,uSize) https://docs.microsoft.com/ru-ru/windows/win32/api/sysinfoapi/nf-sysinfoapi-getwindowsdirectorya
	; GetSystemWindowsDirectoryA(lpBuffer,uSize) https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemwindowsdirectorya
	Protected DllFull.s = DllName
	If GetExtensionPart(DllFull) = ""
		DllFull + ".dll"
	EndIf
	If fSystem
		If SysDir=""
			SysDir = Space(#MAX_PATH)
			GetSystemDirectory_(@SysDir,#MAX_PATH)
			SysDir = RTrim(SysDir,"\")
			;dbg("GET SYSTEM DIR: "+SysDir)
		EndIf
		DllFull = SysDir+"\"+DllFull
	EndIf
	Protected hDll = LoadLibrary_(DllFull)
	;Protected hDll = LoadLibraryEx_(DllFull,#Null,#LOAD_LIBRARY_SEARCH_SYSTEM32)
	;dbg(DllName+" :: "+Str(hDll))
	If hDll = #Null
		MessageBox_(0,"Failed load original dll"+Chr(10)+DllName,"PurePortable",#MB_ICONERROR)
		;RaiseError(#ERROR_DLL_INIT_FAILED)
		TerminateProcess_(GetCurrentProcess_(),0)
	EndIf
	ProcedureReturn hDll
EndProcedure
Procedure.i LoadDllX(*DllName,fSystem=1)
	ProcedureReturn LoadDll(PeekS(*DllName,fSystem))
EndProcedure

; Макросы и процедуры для иницилизации экспортируемой функции в прокси-dll.
Macro ProxyFuncCalledMsg
	"CALLED PROXY FUNC:
EndMacro
Macro ProxyFuncInitMsg
	"INIT PROXY FUNC:
EndMacro
Macro DeclareProxyFunc(DllName,FuncName)
	;Global hdll_#DllName
	ProcedureDLL FuncName()
		dbgproxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			!JMP [v_Trampoline_#FuncName]
		CompilerElse
			!ADD RSP,40
			!JMP [v_Trampoline_#FuncName]
		CompilerEndIf
	EndProcedure
	Global Trampoline_#FuncName = _InitProxyFunc(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote)
	;dbgproxy(ProxyFuncInitMsg FuncName#DoubleQuote)
EndMacro
Macro DeclareProxyConflictFunc(DllName,FuncName,ConflictFuncName)
	;Global hdll_#DllName
	;Import DoubleQuote/export:#ConflictFuncName=#FuncName#DoubleQuote : EndImport
	ProcedureDLL ConflictFuncName()
		dbgproxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			!JMP [v_Trampoline_#FuncName]
		CompilerElse
			!ADD RSP,40
			!JMP [v_Trampoline_#FuncName]
		CompilerEndIf
	EndProcedure
	Global Trampoline_#FuncName = _InitProxyFunc(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote)
	;dbgproxy(ProxyFuncInitMsg FuncName#DoubleQuote)
EndMacro
Macro DeclareProxyFuncExt(DllName,DllExt,FuncName,Compat=0)
	CompilerIf Compat=0 Or Compat>#PROXY_DLL_COMPATIBILITY
		;Global hdll_#DllName
		ProcedureDLL FuncName()
			dbgproxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
			CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
				!JMP [v_Trampoline_#FuncName]
			CompilerElse
				!ADD RSP,40
				!JMP [v_Trampoline_#FuncName]
			CompilerEndIf
		EndProcedure
		Global Trampoline_#FuncName = _InitProxyFuncExt(DoubleQuote#DllName#DoubleQuote,DoubleQuote#DllExt#DoubleQuote,DoubleQuote#FuncName#DoubleQuote)
		;dbgproxy(ProxyFuncInitMsg FuncName#DoubleQuote)
	CompilerEndIf
EndMacro
Macro DeclareProxyFuncDelay(DllName,FuncName)
	Global Trampoline_#FuncName
	ProcedureDLL FuncName()
		dbgproxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			!MOV EAX, DWORD [v_Trampoline_#FuncName]
			!AND EAX, EAX
			!JNE @f
			!MOV EAX, FuncAsciiName_#FuncName
			!PUSH EAX
			!MOV EAX, DllUnicodeName_#DllName
			!PUSH EAX
			!CALL [v__InitProxyFuncX]
			!MOV DWORD [v_Trampoline_#FuncName], EAX
			!@@:
			!JMP [v_Trampoline_#FuncName]
		CompilerElse
			!MOV RAX, QWORD [v_Trampoline_#FuncName]
			!AND RAX, RAX
			!JNE @f
			!PUSH RCX
			!PUSH RDX
			!PUSH R8
			!PUSH R9
			!MOV RCX, DllUnicodeName_#DllName
			!MOV RDX, FuncAsciiName_#FuncName
			!CALL [v__InitProxyFuncX]
			!MOV QWORD [v_Trampoline_#FuncName], RAX
			!POP R9
			!POP R8
			!POP RDX
			!POP RCX
			!@@:
			!ADD RSP,40
			!JMP [v_Trampoline_#FuncName]
		CompilerEndIf
		!FuncAsciiName_#FuncName DB SingleQuote#FuncName#SingleQuote, 0
		CompilerIf Not Defined(DLLUNICODENAME_#DllName,#PB_Constant)
			#DLLUNICODENAME_#DllName = 1
			!DllUnicodeName_#DllName DU SingleQuote#DllName#SingleQuote, 0
		CompilerEndIf
	EndProcedure
EndMacro
;Macro InitProxyFunc(DllName,FuncName)
;	_InitProxyFunc(DoubleQuote#DllName#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Original_#FuncName)
;EndMacro
;Macro InitProxyFuncExt(DllName,DllExt,FuncName)
;	_InitProxyFunc(DoubleQuote#DllName.DllExt#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Original_#FuncName)
;EndMacro
Procedure.i _InitProxyFuncX(*DllName,*AsciiFuncName)
	Protected DllName.s = PeekS(*DllName)
	Protected hDll = LoadDll(DllName)
	Protected ProcAddr = GetProcAddress_(hDll,*AsciiFuncName)
	If Not ProcAddr
		dbgproxy("InitProxyFunc: "+PeekS(*AsciiFuncName,-1,#PB_Ascii)+" ERROR "+Str(GetLastError_()))
		CompilerIf Not #PROXY_DLL_ERROR_IGNORE
			MessageBox_(0,"Error init proxy function "+PeekS(*AsciiFuncName,-1,#PB_Ascii),"PurePortable",#MB_ICONERROR)
			;RaiseError(#ERROR_DLL_INIT_FAILED)
			TerminateProcess_(GetCurrentProcess_(),0)
			ProcedureReturn
		CompilerEndIf
	EndIf
	dbgproxy("InitProxyFunc: "+PeekS(*AsciiFuncName,-1,#PB_Ascii)+" OK")
	ProcedureReturn ProcAddr
EndProcedure
Global _InitProxyFuncX = @_InitProxyFuncX()
Procedure.i _InitProxyFunc(DllName.s,FuncName.s)
	Protected *AsciiFuncName = Ascii(FuncName)
	Protected Result = _InitProxyFuncX(@DllName,*AsciiFuncName)
	FreeMemory(*AsciiFuncName)
	ProcedureReturn Result
EndProcedure
Procedure.i _InitProxyFuncExt(DllName.s,DllExt.s,FuncName.s)
	Protected *AsciiFuncName = Ascii(FuncName)
	DllName + "." + DllExt
	Protected Result = _InitProxyFuncX(@DllName,*AsciiFuncName)
	FreeMemory(*AsciiFuncName)
	ProcedureReturn Result
EndProcedure
Global _InitProxyFunc = @_InitProxyFunc()
;;======================================================================================================================


; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 57
; FirstLine = 22
; Folding = ----
; Markers = 174
; EnableThread
; DisableDebugger
; EnableExeConstant