;;======================================================================================================================
; Модуль EnvironmentStrings
; Портабелизация переменных среды
;;======================================================================================================================
; TODO:
; - #PORTABLE_ENVIRONMENT_VARIABLES: 0: Нет, 1: kernel32, 2: kernelbase
; - #DETOUR_ENV_ANSI #DETOUR_ENV_UNICODE
; - env2path
;   - Буфер ASCII типа ProfileRedirA. Заполнять только при первом обращении.
; - Критические секции.
; - CheckEnv?
; - Для CRT всегда делать область как и для GetEnvironmentStrings и указатели возвращать прямо на эту область.
; - userenv.dll CreateEnvironmentBlock, DestroyEnvironmentBlock, ExpandEnvironmentStringsForUser
; - SetFirmwareEnvironmentVariable, SetFirmwareEnvironmentVariableEx
; - GetEnvironmentStrings (без A и W!)
;;======================================================================================================================

CompilerIf Not Defined(DETOUR_ENVIRONMENTVARIABLE,#PB_Constant)      : #DETOUR_ENVIRONMENTVARIABLE = 1      : CompilerEndIf
CompilerIf Not Defined(DETOUR_ENVIRONMENTSTRINGS,#PB_Constant)       : #DETOUR_ENVIRONMENTSTRINGS = 0       : CompilerEndIf
CompilerIf Not Defined(DETOUR_EXPANDENVIRONMENTSTRINGS,#PB_Constant) : #DETOUR_EXPANDENVIRONMENTSTRINGS = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_ENVIRONMENT_CRT,#PB_Constant)          : #DETOUR_ENVIRONMENT_CRT = ""         : CompilerEndIf
CompilerIf Not Defined(DETOUR_ENVIRONMENT_ASCII,#PB_Constant)        : #DETOUR_ENVIRONMENT_ASCII = 1        : CompilerEndIf ; ???
CompilerIf Not Defined(DETOUR_ENVIRONMENT_UNICODE,#PB_Constant)      : #DETOUR_ENVIRONMENT_UNICODE = 1      : CompilerEndIf ; ???

CompilerIf #DBG_ENVIRONMENT_VARIABLES And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf
CompilerIf #DBG_ENVIRONMENT_VARIABLES
	;UndefineMacro DbgAny : DbgAnyDef
	Global DbgEnvMode = #DBG_ENVIRONMENT_VARIABLES
	Global DbgEnvList.s = "appdata|localappdata|userprofile|allusersprofile|programdata|public|home|homedrive|homepath|temp|tmp|tmpdir|programdir|commonprogramfiles|commonprogramfiles(x86)|commonprogramw6432|programdata|programfiles|programfiles(x86)|programw6432|systemroot|windir|driverdata"
	Procedure DbgEnv(txt.s,var.s="")
		If DbgEnvMode
			If var="" Or (DbgEnvMode=1 And FindString(DbgEnvList,LCase(var))>0)
				dbg(txt)
			EndIf
		EndIf
	EndProcedure
CompilerElse
	Macro DbgEnv(txt,var="") : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; Общие переменные, если не были созданы в другом месте
CompilerIf Not Defined(ProfileRedir,#PB_Variable)         : Global ProfileRedir.s         : CompilerEndIf
CompilerIf Not Defined(AppDataRedir,#PB_Variable)         : Global AppDataRedir.s         : CompilerEndIf
CompilerIf Not Defined(LocalAppDataRedir,#PB_Variable)    : Global LocalAppDataRedir.s    : CompilerEndIf
CompilerIf Not Defined(LocalLowAppDataRedir,#PB_Variable) : Global LocalLowAppDataRedir.s : CompilerEndIf
CompilerIf Not Defined(DocumentsRedir,#PB_Variable)       : Global DocumentsRedir.s       : CompilerEndIf
CompilerIf Not Defined(CommonAppDataRedir,#PB_Variable)   : Global CommonAppDataRedir.s   : CompilerEndIf
CompilerIf Not Defined(CommonDocumentsRedir,#PB_Variable) : Global CommonDocumentsRedir.s : CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Global HomeDriveRedir.s, HomePathRedir.s
;;======================================================================================================================
Procedure.s env2path(Env.s)
	Protected Result.s
	CharLower_(@Env)
	If Env="userprofile" And ProfileRedir
		DbgEnv("env2path: "+ProfileRedir)
		Result = ProfileRedir
	ElseIf Env="home" And ProfileRedir
		DbgEnv("env2path: "+ProfileRedir)
		Result = ProfileRedir
	ElseIf Env="homedrive" And ProfileRedir
		DbgEnv("env2path: "+ProfileRedir)
		Result = HomeDriveRedir
	ElseIf Env="homepath" And ProfileRedir
		DbgEnv("env2path: "+ProfileRedir)
		Result = HomePathRedir
	ElseIf Env="appdata" And AppDataRedir
		DbgEnv("env2path: "+AppDataRedir)
		Result = AppDataRedir
	ElseIf Env="localappdata" And LocalAppDataRedir
		DbgEnv("env2path: "+LocalAppDataRedir)
		Result = LocalAppDataRedir
	ElseIf Env="allusersprofile" And CommonAppDataRedir
		DbgEnv("env2path: "+CommonAppDataRedir)
		Result = CommonAppDataRedir
	ElseIf Env="programdata" And CommonAppDataRedir
		DbgEnv("env2path: "+CommonAppDataRedir)
		Result = CommonAppDataRedir
	ElseIf Env="public" And CommonAppDataRedir
		DbgEnv("env2path: "+CommonAppDataRedir)
		Result = CommonAppDataRedir
	;Else
	;	Result = CheckEnv(Env)
	EndIf
	ProcedureReturn Result
EndProcedure
;;======================================================================================================================
CompilerIf #DETOUR_ENVIRONMENTVARIABLE
	; https://docs.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getenvironmentvariablew
	Prototype GetEnvironmentVariable(*lpName,*lpBuffer,nSize)
	Global Original_GetEnvironmentVariableA.GetEnvironmentVariable
	Procedure.l Detour_GetEnvironmentVariableA(*lpName,*lpBuffer.Byte,nSize)
		Protected Result
		DbgEnv("GetEnvironmentVariableA: "+PeekSZ(*lpName,-1,#PB_Ascii),PeekSZ(*lpName,-1,#PB_Ascii))
		CompilerIf Not #PORTABLE
			Result= Original_GetEnvironmentVariableA(*lpName,*lpBuffer,nSize)
		CompilerElse
			Protected Path.s = env2path(PeekS(*lpName,-1,#PB_Ascii))
			If Path
				Result = Len(Path)+1
				If nSize >= Result
					Result - 1
					PokeS(*lpBuffer,Path,nSize,#PB_Ascii)
				ElseIf *lpBuffer
					PokeB(*lpBuffer,0)
				EndIf
			Else
				Result = Original_GetEnvironmentVariableA(*lpName,*lpBuffer,nSize)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_GetEnvironmentVariableA = @Detour_GetEnvironmentVariableA()
	Global Original_GetEnvironmentVariableW.GetEnvironmentVariable
	Procedure.l Detour_GetEnvironmentVariableW(*lpName,*lpBuffer.Word,nSize)
		Protected Result
		DbgEnv("GetEnvironmentVariableW: "+PeekSZ(*lpName),PeekSZ(*lpName))
		CompilerIf Not #PORTABLE
			Result= Original_GetEnvironmentVariableW(*lpName,*lpBuffer,nSize)
		CompilerElse
			Protected Path.s = env2path(PeekS(*lpName))
			If Path
				Result = Len(Path)+1
				If nSize >= Result
					Result - 1
					PokeS(*lpBuffer,Path,nSize)
				ElseIf *lpBuffer
					PokeW(*lpBuffer,0)
				EndIf
			Else
				Result = Original_GetEnvironmentVariableW(*lpName,*lpBuffer,nSize)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_GetEnvironmentVariableW = @Detour_GetEnvironmentVariableW()
CompilerEndIf

;;======================================================================================================================
CompilerIf #DETOUR_ENVIRONMENTSTRINGS
	Global EnvCritical.CRITICAL_SECTION
	InitializeCriticalSection_(EnvCritical)
	Macro EnvCriticalEnter
		EnterCriticalSection_(EnvCritical)
	EndMacro
	Macro EnvCriticalLeave
		LeaveCriticalSection_(EnvCritical)
	EndMacro
	Global Dim EnvBlocks(1), nEnvBlocks

	; https://docs.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-freeenvironmentstringsa
	Declare _FreeEnvironmentStrings(*penv)

	Prototype FreeEnvironmentStrings(*penv)
	Global Original_FreeEnvironmentStringsA.FreeEnvironmentStrings
	Procedure.l Detour_FreeEnvironmentStringsA(*penv)
		Protected Result = #True
		DbgEnv("FreeEnvironmentStringsA: "+Str(*penv))
		CompilerIf Not #PORTABLE
			Result = Original_FreeEnvironmentStringsA(*penv)
		CompilerElse
			Result = _FreeEnvironmentStrings(*penv)
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_FreeEnvironmentStringsA = @Detour_FreeEnvironmentStringsA()
	Global Original_FreeEnvironmentStringsW.FreeEnvironmentStrings
	Procedure.l Detour_FreeEnvironmentStringsW(*penv)
		Protected Result = #True
		DbgEnv("FreeEnvironmentStringsW: "+Str(*penv))
		CompilerIf Not #PORTABLE
			Result = Original_FreeEnvironmentStringsW(*penv)
		CompilerElse
			Result = _FreeEnvironmentStrings(*penv)
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_FreeEnvironmentStringsW = @Detour_FreeEnvironmentStringsW()

; 	Procedure _ReAllocateMemory(*mem,size)
; 		Protected *new= ReAllocateMemory(*mem,size)
; 		;dbg("ReAllocateMemory: "+Str(*mem)+" -> "+Str(*new))
; 		If *new <> *mem
; 			FreeMemory(*mem)
; 		EndIf
; 		ProcedureReturn *new
; 	EndProcedure

	Declare _GetEnvironmentStrings(CodePage)

	; https://learn.microsoft.com/ru-ru/windows/win32/api/processenv/nf-processenv-getenvironmentstrings
	Prototype GetEnvironmentStrings()
	Global Original_GetEnvironmentStrings.GetEnvironmentStrings
	Procedure.l Detour_GetEnvironmentStrings()
		Protected Result
		DbgEnv("GetEnvironmentStrings")
		CompilerIf Not #PORTABLE
			Result = Original_GetEnvironmentStrings()
		CompilerElse
			Result = _GetEnvironmentStrings(#PB_Ascii)
		CompilerEndIf
		DbgEnv("GetEnvironmentStrings: "+Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_GetEnvironmentStrings = @Detour_GetEnvironmentStrings()
	Global Original_GetEnvironmentStringsA.GetEnvironmentStrings
	Procedure.l Detour_GetEnvironmentStringsA()
		Protected Result
		DbgEnv("GetEnvironmentStringsA")
		CompilerIf Not #PORTABLE
			Result = Original_GetEnvironmentStringsA()
		CompilerElse
			Result = _GetEnvironmentStrings(#PB_Ascii)
		CompilerEndIf
		DbgEnv("GetEnvironmentStringsA: "+Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_GetEnvironmentStringsA = @Detour_GetEnvironmentStringsA()
	Global Original_GetEnvironmentStringsW.GetEnvironmentStrings
	Procedure.l Detour_GetEnvironmentStringsW()
		Protected Result
		DbgEnv("GetEnvironmentStringsW")
		CompilerIf Not #PORTABLE
			Result = Original_GetEnvironmentStringsW()
		CompilerElse
			Result = _GetEnvironmentStrings(#PB_Unicode)
		CompilerEndIf
		DbgEnv("GetEnvironmentStringsW: "+Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_GetEnvironmentStringsW = @Detour_GetEnvironmentStringsW()

	Global EnvHeap = HeapCreate_(0,0,0)
	Procedure _GetEnvironmentStrings(CodePage)
		EnvCriticalEnter
		Protected CharSize, block

		; Ищем свободный блок
		For block=1 To nEnvBlocks
			If EnvBlocks(block)=0
				Break
			EndIf
		Next
		; По окончании block будет содержать номер свободного блока либо на 1 больше nEnvBlocks
		If block>nEnvBlocks
			nEnvBlocks = block
			ReDim EnvBlocks(block)
		EndIf

		; Блок переменных
		Protected *block
		If CodePage=#PB_Ascii
			CharSize = 1
			*block = Original_GetEnvironmentStringsA()
		Else
			CharSize = 2
			*block = Original_GetEnvironmentStringsW()
		EndIf

		; Перебираем переменные и помещаем их в буфер
		Protected *new = HeapAlloc_(EnvHeap,#HEAP_ZERO_MEMORY,CharSize) ; Пустой буфер с одним нулевым символом (HEAP_ZERO_MEMORY+HEAP_NO_SERIALIZE)
		;DbgEnv("HeapAlloc: "+Str(*new))
		Protected NewOffset, BlockOffset   ; текущие смещения для копирования
		Protected n
		Protected cBlock, cEnv
		Protected Env.s, Path.s

		cBlock = MemoryStringLength(*block)*CharSize
		While cBlock
			Env = PeekS(*block+BlockOffset,-1,CodePage)
			;dbg("Env: "+Env)
			n = FindString(Env,"=")
			If n
				Path = env2path(Left(Env,n-1))
				If Path
					Env = Left(Env,n)+Path
					;dbg("New: "+Env)
				EndIf
			EndIf
			cEnv = Len(Env)*CharSize
			*new = HeapReAlloc_(EnvHeap,#HEAP_ZERO_MEMORY,*new,NewOffset+cEnv+CharSize+CharSize) ; + два нулевых символа (конец строки и конец блока)
			;DbgEnv("HeapReAlloc: "+Str(*new))
			PokeS(*new+NewOffset,Env)

			BlockOffset+cBlock+CharSize ; следующая переменная
			NewOffset+cEnv+CharSize	 ; нулевой символ в конце блока
			cBlock = MemoryStringLength(*block+BlockOffset)*CharSize
		Wend

		; Освобождаем память
		If CodePage=#PB_Ascii
			Original_FreeEnvironmentStringsA(*block)
		Else
			Original_FreeEnvironmentStringsW(*block)
		EndIf

		EnvBlocks(block) = *new
		EnvCriticalLeave
		ProcedureReturn *new
	EndProcedure

	Procedure _FreeEnvironmentStrings(*penv)
		Protected Result, i
		EnvCriticalEnter
		For i=1 To nEnvBlocks
			If EnvBlocks(i)=*penv
				HeapFree_(EnvHeap,0,EnvBlocks(i)) ; #HEAP_NO_SERIALIZE
				EnvBlocks(i) = 0
			EndIf
		Next
		EnvCriticalLeave
		ProcedureReturn #True
	EndProcedure

CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Возврат - необходимое количество символов, ключая нулевой.
; Если буфер меньше необходимого, копируется столько, сколько заданно. Нулевой не копируется!
; Но! Переменная не раскрывается, если она существует, но не влезает в буфер. Рузультат обрезается по эту переменную.
; Здесь будет несовместимость.
CompilerIf #DETOUR_EXPANDENVIRONMENTSTRINGS
	Declare.s _ExpandEnvironmentStrings(s.s)
	Prototype.l ExpandEnvironmentStrings(lpSrc,lpDst,nSize)
	Global Original_ExpandEnvironmentStringsA.ExpandEnvironmentStrings
	Procedure.l Detour_ExpandEnvironmentStringsA(lpSrc,lpDst,nSize)
		Protected Result
		DbgEnv("ExpandEnvironmentStringsA (1): «"+PeekSZ(lpSrc,-1,#PB_Ascii)+"» nSize: "+Str(nSize))
		CompilerIf Not #PORTABLE
			Result = Original_ExpandEnvironmentStringsA(lpSrc,lpDst,nSize)
		CompilerElse
			Protected s.s = _ExpandEnvironmentStrings(PeekS(lpSrc,-1,#PB_Ascii))
			Result = Len(s)+1
			If nSize > Result
				PokeSZ(lpDst,s,-1,#PB_Ascii)
			Else
				PokeSZ(lpDst,s,nSize,#PB_Ascii|#PB_String_NoZero)
			EndIf
		CompilerEndIf
		DbgEnv("ExpandEnvironmentStringsA (2): «"+PeekSZ(lpDst,-1,#PB_Ascii)+"» Result: "+Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_ExpandEnvironmentStringsA = @Detour_ExpandEnvironmentStringsA()
	Global Original_ExpandEnvironmentStringsW.ExpandEnvironmentStrings
	Procedure.l Detour_ExpandEnvironmentStringsW(lpSrc,lpDst,nSize)
		Protected Result
		DbgEnv("ExpandEnvironmentStringsW (1): «"+PeekSZ(lpSrc)+"» nSize: "+Str(nSize))
		CompilerIf Not #PORTABLE
			Result = Original_ExpandEnvironmentStringsW(lpSrc,lpDst,nSize)
		CompilerElse
			Protected s.s = _ExpandEnvironmentStrings(PeekS(lpSrc))
			Result = Len(s)+1
			If nSize > Result
				PokeSZ(lpDst,s)
			Else
				PokeSZ(lpDst,s,nSize,#PB_Unicode|#PB_String_NoZero)
			EndIf
		CompilerEndIf
		DbgEnv("ExpandEnvironmentStringsW (2): «"+PeekSZ(lpDst)+"» Result: "+Str(Result))
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_ExpandEnvironmentStringsW = @Detour_ExpandEnvironmentStringsW()
	Procedure.s _ExpandEnvironmentStrings(s.s)
		Protected r.s, e.s, v.s
		Protected p1, p2
		p1 = FindString(s,"%")
		While p1
			p2 = FindString(s,"%",p1+1)
			If p2
				v = Mid(s,p1+1,p2-p1-1)
				e = env2path(v)
				If e="" And v<>""
					e = GetEnvironmentVariable(v)
				EndIf
				If e=""
					e = Mid(s,p1,p2-p1+1)
				EndIf
				r + Left(s,p1-1)+e
				s = Mid(s,p2+1)
			Else ; нет парного %
				Break
			EndIf
			p1 = FindString(s,"%")
		Wend
		ProcedureReturn r+s
	EndProcedure
;{ 	Procedure.s _ExpandEnvironmentStrings2(s.s)
; 		Protected r.s
; 		Protected p0,p1, p2
; 		p1 = FindString(s,"%")
; 		While p1
; 			p2 = FindString(s,"%",p1+1)
; 			If p2
; 				r + Left(s,p1-1)+env2path(Mid(p1+1,p2-p1-1))
; 				s = Mid(s,p2+1)
; 			Else
; 				Break
; 			EndIf
; 			p1 = FindString(s,"%")
; 		Wend
; 		ProcedureReturn r+s
; 	EndProcedure
;}
CompilerEndIf

;;======================================================================================================================
; msvcrt msvcr80 msvcr90 msvcr100 msvcr100clr0400 msvcr110 msvcr110clr0400 msvcr120 msvcr120clr0400 ucrtbase
; api-ms-win-crt-environment-l1-1-0 api-ms-win-crt-private-l1-1-0 -> ucrtbase
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_ENVIRONMENT_CRT<>""
	#ENVIRONMENT_CRT_DLLNAME = #DETOUR_ENVIRONMENT_CRT+".dll"
	#ENVIRONMENT_CRT_LIBNAME = #DETOUR_ENVIRONMENT_CRT+".lib"
	Global ProfileRedirA.s, AppDataRedirA.s, LocalAppDataRedirA.s, CommonAppDataRedirA.s
	;;------------------------------------------------------------------------------------------------------------------
	; https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/getenv-s-wgetenv-s
	; ??? __p__environ https://docs.microsoft.com/ru-ru/cpp/c-runtime-library/internal-crt-globals-and-functions
	#EINVAL = 22
	#ERANGE = 34
	PrototypeC Proto_getenv_s(*RequiredCount.Integer,*Buffer,BufferCount,*VarName)
	; stdlib.h
	Global Original_getenv_s.Proto_getenv_s
	ProcedureC Detour_getenv_s(*RequiredCount.Integer,*Buffer,BufferCount,*VarName)
		DbgEnv("getenv_s: «"+PeekSZ(*VarName,-1,#PB_Ascii)+"» Size: "+Str(BufferCount),PeekSZ(*VarName,-1,#PB_Ascii))
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_getenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
		CompilerElse
			Protected Path.s = env2path(PeekSZ(*VarName,-1,#PB_Ascii))
			If (*Buffer=0 And BufferCount<>0) Or (*Buffer<>0 And BufferCount=0)
				; Ошибочная ситуция, вызывающая исключение 0xC0000409.
				; Делаем неправильный вызов для получения исключения.
				Result = Original_getenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
			ElseIf Path
				If *RequiredCount
					*RequiredCount\i = Len(Path)+1
				EndIf
				If BufferCount < Len(Path)+1
					Result = #ERANGE
					PokeB(*Buffer,0)
				Else
					Result = 0
					PokeS(*Buffer,Path,-1,#PB_Ascii)
				EndIf
			Else
				Result = Original_getenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_getenv_s = @Detour_getenv_s()
	; corecrt_wstdlib.h
	Global Original__wgetenv_s.Proto_getenv_s
	ProcedureC Detour__wgetenv_s(*RequiredCount.Integer,*Buffer,BufferCount,*VarName)
		DbgEnv("_wgetenv_s: «"+PeekSZ(*VarName)+"» Size: "+Str(BufferCount),PeekSZ(*VarName))
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original__wgetenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
		CompilerElse
			Protected Path.s = env2path(PeekSZ(*VarName))
			If (*Buffer=0 And BufferCount<>0) Or (*Buffer<>0 And BufferCount=0)
				; Ошибочная ситуция, вызывающая исключение 0xC0000409.
				; Делаем неправильный вызов для получения исключения.
				Result = Original__wgetenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
			ElseIf Path
				If *RequiredCount
					*RequiredCount\i = Len(Path)+1
				EndIf
				If BufferCount < Len(Path)+1
					Result = #ERANGE
					PokeW(*Buffer,0)
				Else
					Result = 0
					PokeS(*Buffer,Path)
				EndIf
			Else
				Result = Original__wgetenv_s(*RequiredCount,*Buffer,BufferCount,*VarName)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline__wgetenv_s = @Detour__wgetenv_s()
	;;------------------------------------------------------------------------------------------------------------------
	Global HomeDriveRedirA.s, HomePathRedirA.s
	Procedure env2ptr(Env.s,Ansi=#False)
		Protected Result
		CharLower_(@Env)
		If Env="userprofile" And ProfileRedir
			DbgEnv("env2ptr: "+ProfileRedir)
			Result = iif(Ansi,@ProfileRedirA,@ProfileRedir)
		ElseIf Env="home" And ProfileRedir
			DbgEnv("env2ptr: "+ProfileRedir)
			Result = iif(Ansi,@ProfileRedirA,@ProfileRedir)
		ElseIf Env="homedrive" And ProfileRedir
			DbgEnv("env2ptr: "+ProfileRedir)
			Result = iif(Ansi,@HomeDriveRedirA,@HomeDriveRedir)
		ElseIf Env="homepath" And ProfileRedir
			DbgEnv("env2ptr: "+ProfileRedir)
			Result = iif(Ansi,@HomePathRedirA,@HomePathRedir)
		ElseIf Env="appdata" And AppDataRedir
			DbgEnv("env2ptr: "+AppDataRedir)
			Result = iif(Ansi,@AppDataRedirA,@AppDataRedir)
		ElseIf Env="localappdata" And LocalAppDataRedir
			DbgEnv("env2ptr: "+LocalAppDataRedir)
			Result = iif(Ansi,@LocalAppDataRedirA,@LocalAppDataRedir)
		ElseIf Env="allusersprofile" And CommonAppDataRedir
			DbgEnv("env2ptr: "+CommonAppDataRedir)
			Result = iif(Ansi,@CommonAppDataRedirA,@CommonAppDataRedir)
		ElseIf Env="programdata" And CommonAppDataRedir
			DbgEnv("env2ptr: "+CommonAppDataRedir)
			Result = iif(Ansi,@CommonAppDataRedirA,@CommonAppDataRedir)
		ElseIf Env="public" And CommonAppDataRedir
			DbgEnv("env2ptr: "+CommonAppDataRedir)
			Result = iif(Ansi,@CommonAppDataRedirA,@CommonAppDataRedir)
		;Else
		;	Result = #Null
		EndIf
		ProcedureReturn Result
	EndProcedure
	;;------------------------------------------------------------------------------------------------------------------
	; https://docs.microsoft.com/ru-ru/cpp/c-runtime-library/reference/getenv-wgetenv
	; https://github.com/MicrosoftDocs/cpp-docs/blob/main/docs/c-runtime-library/reference/getenv-wgetenv.md
	;;------------------------------------------------------------------------------------------------------------------
	;CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	;	#CRT_GETENV = "_getenv"
	;	#CRT_WGETENV = "__wgetenv"
	;CompilerElse
	;	#CRT_GETENV = "getenv"
	;	#CRT_WGETENV = "_wgetenv"
	;CompilerEndIf
	;ImportC #ENVIRONMENT_CRT_LIBNAME
	;	_crt_getenv(*p) As #CRT_GETENV
	;	_crt_wgetenv(*p) As #CRT_WGETENV
	;EndImport
	;Procedure fake_msvcrt()
	;	_crt_getenv(0)
	;	_crt_wgetenv(0)
	;EndProcedure

	PrototypeC Proto_getenv(env)
	; stdlib.h
	Global Original_getenv.Proto_getenv
	ProcedureC Detour_getenv(*varname)
		DbgEnv("getenv: "+PeekSZ(*varname,-1,#PB_Ascii),PeekSZ(*varname,-1,#PB_Ascii))
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_getenv(*varname)
		CompilerElse
			If *varname
				Result = env2ptr(PeekSZ(*varname,-1,#PB_Ascii),#True)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline_getenv = @Detour_getenv()
	; corecrt_wstdlib.h
	Global Original__wgetenv.Proto_getenv
	ProcedureC Detour__wgetenv(*varname)
		DbgEnv("_wgetenv: "+PeekSZ(*varname),PeekSZ(*varname))
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original__wgetenv(*varname)
		CompilerElse
			If *varname
				Result = env2ptr(PeekSZ(*varname),#False)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	;Global Trampoline__wgetenv = @Detour__wgetenv()
CompilerEndIf

;;======================================================================================================================
;CompilerIf #DETOUR_ENVIRONMENT_CRT<>""
XIncludeFile "PP_MinHook.pbi"
;CompilerEndIf

Global EnvironmentVariablesPermit = 1
Procedure _InitEnvironmentVariablesHooks()
	If EnvironmentVariablesPermit
		If ProfileRedir
			HomeDriveRedir = Left(ProfileRedir,2)
			HomePathRedir = ProfileRedir
		EndIf
		CompilerIf #DETOUR_ENVIRONMENTVARIABLE
			MH_HookApi(kernel32,GetEnvironmentVariableA)
			MH_HookApi(kernel32,GetEnvironmentVariableW)
		CompilerEndIf
		CompilerIf #DETOUR_EXPANDENVIRONMENTSTRINGS
			MH_HookApi(kernel32,ExpandEnvironmentStringsA)
			MH_HookApi(kernel32,ExpandEnvironmentStringsW)
		CompilerEndIf
		CompilerIf #DETOUR_ENVIRONMENTSTRINGS
			MH_HookApi(kernel32,GetEnvironmentStrings)
			MH_HookApi(kernel32,GetEnvironmentStringsA)
			MH_HookApi(kernel32,GetEnvironmentStringsW)
			MH_HookApi(kernel32,FreeEnvironmentStringsA)
			MH_HookApi(kernel32,FreeEnvironmentStringsW)
		CompilerEndIf
		CompilerIf #DETOUR_ENVIRONMENT_CRT<>""
			If ProfileRedir
				ProfileRedirA = SpaceA(Len(ProfileRedir))
				PokeS(@ProfileRedirA,ProfileRedir,-1,#PB_Ascii)
				HomeDriveRedirA  = SpaceA(Len(HomeDriveRedir))
				PokeS(@HomeDriveRedirA,HomeDriveRedir,-1,#PB_Ascii)
				HomePathRedirA  = SpaceA(Len(HomePathRedir))
				PokeS(@HomePathRedirA,HomePathRedir,-1,#PB_Ascii)
			EndIf
			If AppDataRedir
				AppDataRedirA = SpaceA(Len(AppDataRedir))
				PokeS(@AppDataRedirA,AppDataRedir,-1,#PB_Ascii)
			EndIf
			If LocalAppDataRedir
				LocalAppDataRedirA = SpaceA(Len(LocalAppDataRedir))
				PokeS(@LocalAppDataRedirA,LocalAppDataRedir,-1,#PB_Ascii)
			EndIf
			If CommonAppDataRedir
				CommonAppDataRedirA = SpaceA(Len(CommonAppDataRedir))
				PokeS(@CommonAppDataRedirA,CommonAppDataRedir,-1,#PB_Ascii)
			EndIf
			;OpenLibrary(#PB_Any,#ENVIRONMENT_CRT_DLLNAME)
			MH_HookApiD(#DETOUR_ENVIRONMENT_CRT,getenv)
			MH_HookApiD(#DETOUR_ENVIRONMENT_CRT,_wgetenv)
			MH_HookApiD(#DETOUR_ENVIRONMENT_CRT,getenv_s)
			MH_HookApiD(#DETOUR_ENVIRONMENT_CRT,_wgetenv_s)
		CompilerEndIf
	EndIf
EndProcedure
AddInitProcedure(_InitEnvironmentVariablesHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 30
; FirstLine = 12
; Folding = -----
; Markers = 237
; DisableDebugger
; EnableExeConstant