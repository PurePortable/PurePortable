CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	Prototype IsWow64Process(hProcess,*Wow64Process)
	Prototype Wow64DisableWow64FsRedirection(*OldValue)
	Procedure IsWow64(Disable=#False)
		Protected kernel = OpenLibrary(#PB_Any,"kernel32.dll")
		Protected _IsWow64Process.IsWow64Process = GetFunction(kernel,"IsWow64Process")
		Protected _Wow64DisableWow64FsRedirection.Wow64DisableWow64FsRedirection = GetFunction(kernel,"Wow64DisableWow64FsRedirection")
		Protected IsWow64ProcessFlag, Wow64OldValue		
		If _IsWow64Process And _Wow64DisableWow64FsRedirection
			_IsWow64Process(GetCurrentProcess_(),@IsWow64ProcessFlag)
			If IsWow64ProcessFlag And Disable
				_Wow64DisableWow64FsRedirection(@Wow64OldValue)
			EndIf
		EndIf
		;CloseLibrary(kernel)
		ProcedureReturn IsWow64ProcessFlag
	EndProcedure
CompilerElse
	Macro IsWow64(Disable) : EndMacro	
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 15
; Folding = -
; EnableThread
; DisableDebugger
; EnableExeConstant