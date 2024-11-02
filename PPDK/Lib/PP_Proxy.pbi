;;======================================================================================================================
; Иницилизация экспортируемых прокси-функций
;;======================================================================================================================

EnableExplicit

CompilerIf Not Defined(DBG_PROXY_DLL,#PB_Constant) : #DBG_PROXY_DLL = 0 : CompilerEndIf

CompilerIf #DBG_PROXY_DLL
	Macro DbgProxy(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgProxy(txt) : EndMacro
CompilerEndIf
CompilerIf #DBG_PROXY_DLL
	Macro DbgProxyInit(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgProxyInit(txt) : EndMacro
CompilerEndIf
CompilerIf Defined(PROXY_ERROR_MODE,#PB_Constant)
	Macro DbgProxyError(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgProxyError(txt) : EndMacro
CompilerEndIf
CompilerIf Not Defined(PROXY_ERROR_MODE,#PB_Constant)
	CompilerIf Defined(PROXY_DLL_ERROR_IGNORE,#PB_Constant)
		CompilerIf #PROXY_DLL_ERROR_IGNORE
			#PROXY_ERROR_MODE = 0
		CompilerElse
			#PROXY_ERROR_MODE = 2
		CompilerEndIf
	CompilerElse
		#PROXY_ERROR_MODE = 2
	CompilerEndIf
CompilerEndIf
CompilerIf #DBG_PROXY_DLL And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro
UndefineMacro SingleQuote
Macro SingleQuote
	'
EndMacro

;;----------------------------------------------------------------------------------------------------------------------
; Макросы для описания прокси-dll
; Используются в начале каждого файла в папке proxy
; DLL загружаем, но не выгружаем!
Macro DeclareProxyDll(DllName)
	Global hDll_#DllName = LoadDll(DoubleQuote#DllName#DoubleQuote)
	;Global hDll = hDll_#DllName
EndMacro
Macro DeclareProxyDllExt(DllName,DllExt)
	Global hDll_#DllName = LoadDll(DoubleQuote#DllName.DllExt#DoubleQuote)
	;Global hDll = hDll_#DllName
EndMacro

;;----------------------------------------------------------------------------------------------------------------------
; Макросы для описания экспортируемых прокси-функции в dll, компилируемых не под своим именем (comdlg32, advapi32 и др.)
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
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name32#DoubleQuote
		EndImport
		ProcedureDLL FuncName()
			!JMP Name32
		EndProcedure
	CompilerEndIf
EndMacro
; Только x64
Macro DeclareExportFunc64(FuncName,LibName,Name64)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
		Import DoubleQuote#LibName.lib#DoubleQuote
			Import_#FuncName As DoubleQuote#Name64#DoubleQuote
		EndImport
		ProcedureDLL FuncName()
			!ADD RSP,40
			!JMP Name64
		EndProcedure
	CompilerEndIf
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

;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibrarya
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryexa
; https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexa
#LOAD_LIBRARY_SEARCH_SYSTEM32 = $00000800
#LOAD_LIBRARY_SEARCH_USER_DIRS = $00000400
#LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR = $00000100
#LOAD_LIBRARY_SEARCH_APPLICATION_DIR = $00000200
#LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = $00001000
#LOAD_WITH_ALTERED_SEARCH_PATH = $00000008

;DeclareImport(kernel32,_GetModuleHandleExW@12,GetModuleHandleExW,GetModuleHandleEx_(dwFlags.l,*lpModuleName,*phModule))
#GET_MODULE_HANDLE_EX_FLAG_PIN = 1
#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = 4

Procedure.i LoadDll(DllName.s,fSystem=1)
	; GetWindowsDirectory(lpBuffer,uSize) https://docs.microsoft.com/ru-ru/windows/win32/api/sysinfoapi/nf-sysinfoapi-getwindowsdirectorya
	; GetSystemWindowsDirectoryA(lpBuffer,uSize) https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemwindowsdirectorya
	Protected DllFull.s = DllName
	If GetExtensionPart(DllFull) = "" : DllFull + ".dll" : EndIf
	If fSystem : DllFull = SysDir+"\"+DllFull : EndIf
	;Protected hDll = LoadLibraryEx_(@DllFull,#Null,0) ; #LOAD_LIBRARY_SEARCH_SYSTEM32
	Protected hDll = LoadLibrary_(@DllFull)
	If hDll = 0
		PPErrorMessage("Failed load original dll:"+#LF$+DllName)
		;RaiseError(#ERROR_DLL_INIT_FAILED)
		TerminateProcess_(GetCurrentProcess_(),0)
	EndIf
	;dbg(DllName+" :: "+Str(hDll))
	;Protected hDll2 ; заменить на hDll?
	;GetModuleHandleEx_(#GET_MODULE_HANDLE_EX_FLAG_PIN,@DllFull,@hDll2) ; запретить выгрузку из памяти
	ProcedureReturn hDll
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; Макросы и процедуры для описания экспортируемой прокси-функции.
Macro ProxyFuncCalledMsg
	"CALLED PROXY FUNC:
EndMacro
Macro ProxyFuncInitMsg
	"INIT PROXY FUNC:
EndMacro

; Основной макрос для описания функции.
Macro DeclareProxyFunc(DllName,FuncName,Compat=0)
	CompilerIf Compat=0 Or Compat<=#PROXY_DLL_COMPATIBILITY
		ProcedureDLL FuncName()
			DbgProxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
			CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
				!JMP [v_Trampoline_#FuncName]
			CompilerElse
				!ADD RSP,40
				!JMP [v_Trampoline_#FuncName]
			CompilerEndIf
		EndProcedure
		DataSection
			FuncAsciiName_#FuncName:
			!DB SingleQuote#FuncName#SingleQuote, 0
		EndDataSection
		Global Trampoline_#FuncName = _InitProxyFunc(hDll_#DllName,?FuncAsciiName_#FuncName)
		;DbgProxy(ProxyFuncInitMsg FuncName#DoubleQuote)
	CompilerEndIf
EndMacro

; Макрос для описания функций, имена которых конфликтуют с процедурами PureBasic.
; Имена этих функций будут заменены в экспорте внешней утилитой.
Macro DeclareProxyConflictFunc(DllName,FuncName,ConflictFuncName,Compat=0)
	CompilerIf Compat=0 Or Compat<=#PROXY_DLL_COMPATIBILITY
		ProcedureDLL ConflictFuncName()
			DbgProxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
			CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
				!JMP [v_Trampoline_#FuncName]
			CompilerElse
				!ADD RSP,40
				!JMP [v_Trampoline_#FuncName]
			CompilerEndIf
		EndProcedure
		DataSection
			FuncAsciiName_#FuncName:
			!DB SingleQuote#FuncName#SingleQuote, 0
		EndDataSection
		Global Trampoline_#FuncName = _InitProxyFunc(hDll_#DllName,?FuncAsciiName_#FuncName)
		;DbgProxy(ProxyFuncInitMsg FuncName#DoubleQuote)
	CompilerEndIf
EndMacro

; Для dll с расширением, отличным от dll (winspool.drv).
; На данный момент нет различий, между DeclareProxyFunc и DeclareProxyFuncExt.
; Макрос оставлен для совместимости.
Macro DeclareProxyFuncExt(DllName,DllExt,FuncName,Compat=0)
	CompilerIf Compat=0 Or Compat<=#PROXY_DLL_COMPATIBILITY
		ProcedureDLL FuncName()
			DbgProxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
			CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
				!JMP [v_Trampoline_#FuncName]
			CompilerElse
				!ADD RSP,40
				!JMP [v_Trampoline_#FuncName]
			CompilerEndIf
		EndProcedure
		DataSection
			FuncAsciiName_#FuncName:
			!DB SingleQuote#FuncName#SingleQuote, 0
		EndDataSection
		Global Trampoline_#FuncName = _InitProxyFunc(hDll_#DllName,?FuncAsciiName_#FuncName)
		;DbgProxy(ProxyFuncInitMsg FuncName#DoubleQuote)
	CompilerEndIf
EndMacro

; Описание функции с отложенной инициализацией (инициализация при первом вызове).
Macro DeclareProxyFuncDelay(DllName,FuncName)
	Global Trampoline_#FuncName
	ProcedureDLL FuncName()
		DbgProxy(ProxyFuncCalledMsg FuncName#DoubleQuote)
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			!MOV EAX, DWORD [v_Trampoline_#FuncName]
			!AND EAX, EAX
			!JNE @f
			!MOV EAX, FuncAsciiName_#FuncName
			!PUSH EAX
			!MOV EAX, hDll_#DllName
			!PUSH EAX
			!CALL [v__InitProxyFunc]
			!MOV DWORD [v_Trampoline_#FuncName], EAX
			!@@:
			!JMP [EAX] ;!JMP [v_Trampoline_#FuncName]
		CompilerElse
			!MOV RAX, QWORD [v_Trampoline_#FuncName]
			!AND RAX, RAX
			!JNE @f
			!PUSH RCX
			!PUSH RDX
			!PUSH R8
			!PUSH R9
			!MOV RDX, FuncAsciiName_#FuncName
			!PUSH RDX
			!MOV RCX, hDll_#DllName
			!PUSH RCX
			!CALL [v__InitProxyFunc]
			!MOV QWORD [v_Trampoline_#FuncName], RAX
			!POP R9
			!POP R8
			!POP RDX
			!POP RCX
			!@@:
			!ADD RSP,40
			!JMP [RAX] ;!JMP [v_Trampoline_#FuncName]
		CompilerEndIf
		!FuncAsciiName_#FuncName DB SingleQuote#FuncName#SingleQuote, 0
	EndProcedure
EndMacro

;;----------------------------------------------------------------------------------------------------------------------
; Режим обработаки ошибок инициализации прокси-функций
; 0 - Выключен, ошибки выводятся только dbg.
; 1 - При первой ошибке выдаётся предупреждение, программа продолжает работу.
; 2 - При первой ошибке выдаётся предупреждение, программа завершает работу.
Global ProxyErrorMode = #PROXY_ERROR_MODE
; Обёртка над GetProcAddress
Procedure.i _InitProxyFunc(hDll,*AsciiFuncName)
	Protected ProcAddr = GetProcAddress_(hDll,*AsciiFuncName)
	If Not ProcAddr
		DbgProxyError("InitProxyFunc: "+PeekS(*AsciiFuncName,-1,#PB_Ascii)+" ERROR "+Str(GetLastError_()))
		If ProxyErrorMode
			PPErrorMessage("Error init proxy function "+PeekS(*AsciiFuncName,-1,#PB_Ascii))
			If ProxyErrorMode=2
				;RaiseError(#ERROR_DLL_INIT_FAILED)
				TerminateProcess_(GetCurrentProcess_(),0)
			EndIf
			ProxyErrorMode = 0
		EndIf
		ProcedureReturn #Null
	EndIf
	DbgProxyInit("InitProxyFunc: "+PeekS(*AsciiFuncName,-1,#PB_Ascii)+" OK")
	ProcedureReturn ProcAddr
EndProcedure
Global _InitProxyFunc = @_InitProxyFunc() ; Для вызова из ассемблера
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 34
; FirstLine = 6
; Folding = -wF9
; EnableThread
; DisableDebugger
; EnableExeConstant