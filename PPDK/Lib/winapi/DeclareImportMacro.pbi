;;======================================================================================================================
; Макросы для упрощения описания имортируемой функции
;;======================================================================================================================
; Пример:
; DeclareImport(kernel32,_GetModuleHandleExW@12,GetModuleHandleExW,GetModuleHandleEx_(dwFlags.l,*lpModuleName,*phModule))
;;======================================================================================================================

UndefineMacro DoubleQuote
Macro DoubleQuote
	"
EndMacro

Macro DeclareImport(LibName,Name32,Name64,FuncDeclaration)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		Import DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
EndMacro

Macro DeclareImportC(LibName,Name32,Name64,FuncDeclaration)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		ImportC DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name32#DoubleQuote
		EndImport
	CompilerElse
		ImportC DoubleQuote#LibName.lib#DoubleQuote
			FuncDeclaration As DoubleQuote#Name64#DoubleQuote
		EndImport
	CompilerEndIf
EndMacro

;;======================================================================================================================
