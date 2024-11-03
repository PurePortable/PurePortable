;;======================================================================================================================
; Модуль BlockInternet
; Блокировка интернета
;;======================================================================================================================
; TODO:
; mswsock.dll
; https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetcheckconnectiona
; https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetgetconnectedstate
;;======================================================================================================================

CompilerIf Not Defined(DBG_BLOCK_INTERNET,#PB_Constant) : #DBG_BLOCK_INTERNET = 0 : CompilerEndIf

CompilerIf #DBG_BLOCK_INTERNET And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

CompilerIf #DBG_BLOCK_INTERNET
	Global DbgIntMode = #DBG_BLOCK_INTERNET
	Procedure DbgInt(txt.s)
		dbg("!!!")
		If DbgIntMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgInt(txt) : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
; WININET.dll
; https://docs.microsoft.com/en-us/windows/win32/api/wininet/
; https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-internetopena
; https://docs.microsoft.com/en-us/windows/win32/wininet/wininet-errors
CompilerIf Not Defined(BLOCK_WININET,#PB_Constant) : #BLOCK_WININET = 0 : CompilerEndIf
CompilerIf #BLOCK_WININET

	#ERROR_INTERNET_OUT_OF_HANDLES = 12001
	#ERROR_INTERNET_TIMEOUT = 12002
	#ERROR_INTERNET_INTERNAL_ERROR = 12004
	#ERROR_INTERNET_INVALID_URL = 12005
	#ERROR_INTERNET_NAME_NOT_RESOLVED = 12007 ; The server name could not be resolved

	Global Original_InternetOpenA
	Procedure.l Detour_InternetOpenA(lpszAgent,dwAccessType.l,lpszProxy,lpszProxyBypass,dwFlags.l)
		DbgInt("InternetOpenA: "+PeekS(lpszAgent,-1,#PB_Ascii))
		SetLastError_(#ERROR_INTERNET_INTERNAL_ERROR)
		ProcedureReturn 0
	EndProcedure
	;Global Trampoline_InternetOpenA = @Detour_InternetOpenA()
	Global Original_InternetOpenW
	Procedure.l Detour_InternetOpenW(lpszAgent,dwAccessType.l,lpszProxy,lpszProxyBypass,dwFlags.l)
		DbgInt("InternetOpenW: "+PeekS(lpszAgent))
		SetLastError_(#ERROR_INTERNET_INTERNAL_ERROR)
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; WINHTTP.dll
; https://docs.microsoft.com/en-us/windows/win32/api/winhttp/
; https://docs.microsoft.com/en-us/windows/win32/api/winhttp/nf-winhttp-winhttpreceiveresponse
; https://docs.microsoft.com/en-us/windows/win32/winhttp/error-messages
CompilerIf Not Defined(BLOCK_WINHTTP,#PB_Constant) : #BLOCK_WINHTTP = 0 : CompilerEndIf
CompilerIf #BLOCK_WINHTTP

	#ERROR_WINHTTP_INTERNAL_ERROR = 12004
	#ERROR_WINHTTP_CONNECTION_ERROR = 12030
	#ERROR_WINHTTP_CANNOT_CONNECT = 12029

	Global Original_WinHttpOpen
	Procedure.l Detour_WinHttpOpen(pszAgentW,dwAccessType.l,pszProxyW,pszProxyBypassW,dwFlags.l)
		DbgInt("WinHttpOpen: "+PeekS(pszAgentW,-1,#PB_Unicode))
		SetLastError_(#ERROR_WINHTTP_INTERNAL_ERROR)
		ProcedureReturn 0
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; WSOCK32.dll, WS2_32.dll
CompilerIf Not Defined(BLOCK_WINSOCKS,#PB_Constant) : #BLOCK_WINSOCKS = 0 : CompilerEndIf
CompilerIf Not Defined(BLOCK_WINSOCKS2,#PB_Constant) : #BLOCK_WINSOCKS2 = 0 : CompilerEndIf

; https://docs.microsoft.com/en-us/windows/win32/winsock/windows-sockets-error-codes-2

; https://docs.microsoft.com/en-us/windows/win32/api/winsock/nf-winsock-wsastartup
; https://learn.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-connect
; https://firststeps.ru/mfc/net/socket/r.php?2
; #WSASYSNOTREADY = 10091
; #WSAVERNOTSUPPORTED = 10091
; CompilerIf #BLOCK_WINSOCKS Or #BLOCK_WINSOCKS2
; 	Prototype WSAStartup(wVersionRequired.w,lpWSAData)
; 	Global Original_WSAStartup.WSAStartup
; 	Procedure Detour_WSAStartup(wVersionRequired.w,lpWSAData)
; 		Protected Result
; 		DbgInt("WSAStartup: "+Str(wVersionRequired))
; 		; https://docs.microsoft.com/en-us/windows/win32/winsock/windows-sockets-error-codes-2
; 		;#WSASYSNOTREADY #WSAVERNOTSUPPORTED #WSANOTINITIALISED #WSAEPROVIDERFAILEDINIT
; 		;#WSAEPROCLIM
; 		;WSASetLastError_(#WSAEPROTONOSUPPORT)
; 		;WSASetLastError_(#WSAESOCKTNOSUPPORT)
; 		;ProcedureReturn #WSASYSNOTREADY
; 		Result = Original_WSAStartup(wVersionRequired.w,lpWSAData)
; 		DbgInt("WSAStartup: Result: "+Str(Result)+" "+Str(WSAGetLastError_()))
; 		ProcedureReturn Result
; 	EndProcedure
; 	Prototype connect(s,name,namelen)
; 	Global Original_connect
; 	Procedure Detour_connect(s,name,namelen)
; 		ProcedureReturn #WSAENETUNREACH
; 	EndProcedure
; CompilerEndIf

; Prototype setsockopt(s,level,optname,*optval,optlen)
; Global Original_setsockopt.setsockopt
; Procedure Detour_setsockopt(s,level,optname,*optval,optlen)
; 	Protected Result = Original_setsockopt(s,level,optname,*optval,optlen)
; 	DbgInt("setsockopt: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
; 	ProcedureReturn Result
; EndProcedure

; Prototype bind(s,*addr,namelen)
; Global Original_bind.bind
; Procedure Detour_bind(s,*addr,namelen)
; 	Protected Result = Original_bind(s,*addr,namelen)
; 	DbgInt("bind: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
; 	ProcedureReturn Result
; EndProcedure

; Prototype send(s,*buf,len,flags)
; Global Original_send.send
; Procedure Detour_send(s,*buf,len,flags)
; 	Protected Result = Original_send(s,*buf,len,flags)
; 	DbgInt("send: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
; 	ProcedureReturn Result
; EndProcedure

; Prototype sendto(s,*buf,len,flags,*to,tolen)
; Global Original_sendto.sendto
; Procedure Detour_sendto(s,*buf,len,flags,*to,tolen)
; 	Protected Result = Original_sendto(s,*buf,len,flags,*to,tolen)
; 	DbgInt("sendto: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
; 	ProcedureReturn Result
; EndProcedure

; https://docs.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-socket
;#INVALID_SOCKET = -1
CompilerIf #BLOCK_WINSOCKS Or #BLOCK_WINSOCKS2
	Prototype socket(af,type,protocol)
	Global Original_socket.socket
	Procedure Detour_socket(af,type,protocol)
		;Protected Result = Original_socket(af,type,protocol)
		;DbgInt("socket: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
		;DbgInt("socket: "+Str(Result)+" "+ErrorMsg(Result))
		;ProcedureReturn Result
		DbgInt("socket: "+Str(#INVALID_SOCKET))
		ProcedureReturn #INVALID_SOCKET
	EndProcedure
CompilerEndIf

; CompilerIf #BLOCK_WINSOCKS Or #BLOCK_WINSOCKS2
; 	Prototype connect(s,*name,namelen)
; 	Global Original_connect.connect
; 	Procedure Detour_connect(s,*name,namelen)
; 		Protected Result = Original_connect(s,*name,namelen)
; 		DbgInt("connect: "+Str(Result)+" "+ErrorMsg(WSAGetLastError_()))
; 		ProcedureReturn Result
; 	EndProcedure
; CompilerEndIf

;;======================================================================================================================
; Принудительная статическая линковка dll
; CompilerIf #BLOCK_WININET
; 	Import "wininet.lib" : EndImport
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Import "/INCLUDE:_InternetOpenA@20" : EndImport
; 		Import "/INCLUDE:_InternetOpenW@20" : EndImport
; 	CompilerElse
; 		Import "/INCLUDE:InternetOpenA" : EndImport
; 		Import "/INCLUDE:InternetOpenW" : EndImport
; 	CompilerEndIf
; CompilerEndIf
; CompilerIf Not Defined(BLOCK_WINHTTP,#PB_Constant) : #BLOCK_WINHTTP = 0 : CompilerEndIf
; CompilerIf #BLOCK_WINHTTP
; 	Import "winhttp.lib" : EndImport
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Import "/INCLUDE:_WinHttpOpen@20" : EndImport
; 	CompilerElse
; 		Import "/INCLUDE:WinHttpOpen" : EndImport
; 	CompilerEndIf
; CompilerEndIf
; CompilerIf #BLOCK_WINSOCKS
; 	Import "wsock32.lib" : EndImport
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Import "/INCLUDE:_connect@12" : EndImport
; 	CompilerElse
; 		Import "/INCLUDE:connect" : EndImport
; 	CompilerEndIf
; CompilerEndIf
; CompilerIf #BLOCK_WINSOCKS2
; 	Import "ws2_32.lib" : EndImport
; 	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
; 		Import "/INCLUDE:_connect@12" : EndImport
; 	CompilerElse
; 		Import "/INCLUDE:connect" : EndImport
; 	CompilerEndIf
; CompilerEndIf
;;======================================================================================================================

XIncludeFile "PP_MinHook.pbi"

;;======================================================================================================================

Global BlockWinInetPermit = 1
Global BlockWinHttpPermit = 1
CompilerIf #BLOCK_WINSOCKS=2 Or #BLOCK_WINSOCKS2
	Global BlockWinSocksPermit = 2
CompilerElseIf #BLOCK_WINSOCKS=1
	Global BlockWinSocksPermit = 1
CompilerEndIf
Procedure _InitBlockInternetHooks()
	CompilerIf #BLOCK_WININET
		If BlockWinInetPermit
			LoadDll("wininet")
			MH_HookApi(wininet,InternetOpenA)
			MH_HookApi(wininet,InternetOpenW)
		EndIf
	CompilerEndIf
	CompilerIf #BLOCK_WINHTTP
		If BlockWinHttpPermit
			LoadDll("winhttp")
			MH_HookApi(winhttp,WinHttpOpen)
		EndIf
	CompilerEndIf
	CompilerIf #BLOCK_WINSOCKS=1
		If BlockWinSocksPermit = 1
			LoadDll("wsock32")
			MH_HookApi(wsock32,socket)
		EndIf
	CompilerEndIf
	CompilerIf #BLOCK_WINSOCKS=2 Or #BLOCK_WINSOCKS2
		If BlockWinSocksPermit = 2
			LoadDll("ws2_32")
			MH_HookApi(ws2_32,socket)
		EndIf
	CompilerEndIf
EndProcedure
AddInitProcedure(_InitBlockInternetHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 238
; FirstLine = 211
; Folding = --
; EnableAsm
; DisableDebugger
; EnableExeConstant