; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-addfontresourceexw
; https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-removefontresourceexw

#FR_PRIVATE = $10
#FR_NOT_ENUM = $20

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	Import "gdi32.lib" : AddFontResourceEx(name,fl,pdv) As "_AddFontResourceExW@12" : EndImport
	Import "gdi32.lib" : RemoveFontResourceEx(name,fl,pdv) As "_RemoveFontResourceExW@12" : EndImport
CompilerElse
	Import "gdi32.lib" : AddFontResourceEx(name,fl,pdv) As "AddFontResourceExW" : EndImport
	Import "gdi32.lib" : RemoveFontResourceEx(name,fl,pdv) As "RemoveFontResourceExW" : EndImport
CompilerEndIf
