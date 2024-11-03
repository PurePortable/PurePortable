;;======================================================================================================================
; Установка хуков на таблицу импорта
;;======================================================================================================================
CompilerIf Not Defined(DBG_IAT_HOOK,#PB_Constant) : #DBG_IAT_HOOK = 0 : CompilerEndIf
CompilerIf #DBG_IAT_HOOK
	Macro DbgIatHook(txt) : dbg(txt) : EndMacro
CompilerElse
	Macro DbgIatHook(txt) : EndMacro
CompilerEndIf

;;======================================================================================================================
; https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-image_section_header
#IMAGE_SIZEOF_SHORT_NAME = 8 ; winnt.h
Structure IMAGE_SECTION_HEADER_ ; уже определена, для примера
	SecName.b[#IMAGE_SIZEOF_SHORT_NAME] ; Name
	StructureUnion ; Misc
		PhysicalAddr.l
		VirtualSize.l
	EndStructureUnion
	VirtualAddress.l
	SizeOfRawData.l
	PointerToRawData.l
	PointerToRelocations.l
	PointerToLinenumbers.l
	NumberOfRelocations.w
	NumberOfLinenumbers.w
	Characteristics.l
EndStructure

Structure IMAGE_IMPORT_DESCRIPTOR ; Эта структура справедлива как для PE, так и для PE64
	; В этом поле содержится смещение (RVA) массива двойных слов. Каждое из этих двойных слов - объединение типа IMAGE_THUNK_DATA.
	; Каждое двойное слово IMAGE_THUNK_DATA соответствует одной функции, импортируемой данным файлом.
	; Массив _IMAGE_THUNK_DATA32 называется Import Lookup Table.
	; Каждый элемент Import Lookup Table содержит RVA на структуру IMAGE_IMPORT_BY_NAME.
	; Этот массив в процессе загрузки программы не изменяется и может совсем не использоваться.
	StructureUnion
		Characteristics.l
		OriginalFirstThunk.l
	EndStructureUnion
	TimeDateStamp.l
	ForwarderChain.l
	Name.l ; RVA строки, содержащей имя DLL, из которой будет производиться импорт.
	FirstThunk.l ; RVA массива IMAGE_THUNK_DATA32, называемого Import Address Table.
		; До загрузки программы идентичен Import Lookup Table, после загрузки элементы массива содержат проекцию адресов функций.
EndStructure

Structure IMAGE_DELAYLOAD_DESCRIPTOR
	StructureUnion ; задает тип адресации, применяющийся в служебных структурах отложенного импорта (0 – VA, 1 – RVA)
		Attributes.l
		RvaBased.l
	EndStructureUnion
	DllNameRVA.l                       ; RVA To the name of the target library (NULL-terminate ASCII string)
		; содержит RVA/VA-указатель на ASCIIZ-строку с именем загружаемой DLL
	ModuleHandleRVA.l				   ; RVA to the HMODULE caching location (PHMODULE)
		; в это поле загрузчик DelayHelper помещает дескриптор динамически загружаемой DLL
	ImportAddressTableRVA.l			   ; RVA to the start of the IAT (PIMAGE_THUNK_DATA)
		; содержит указатель на таблицу адресов отложенного импорта, организованную точно так же, как и обычная IAT,
		; с той разницей, что все элементы таблицы отложенного импорта ведут к delayloadhelper'у специальному динамическому загрузчику,
		; который вызывает LoadLibrary (если библиотека еще не была загружена),
		; а затем вызывает GetProcAddress и замещает текущий элемент таблицы отложенного импорта эффективным адресом
		; импортируемой функции, поэтому все последующие вызовы данной функции будут осуществляется в обход delayloadhelper'а.
	ImportNameTableRVA.l			   ; RVA to the start of the name table (PIMAGE_THUNK_DATA::AddressOfData)
		; содержит RVA-указатель на таблицу имен, во всем повторяющую стандартную таблицу имен
	BoundImportAddressTableRVA.l	   ; RVA to an optional bound IAT
		; полю хранящее RVA-указатель на таблицу диапазонного импорта. Если таблица диапазонного
		; импорта не пуста и указанная временная метка совпадает с временной меткой соответствующей DLL, системный загрузчик
		; проецирует ее на адресное пространство данного процесса и механизм отложенного импорта дезактивируется.
	UnloadInformationTableRVA.l		   ; RVA to an optional unload info table
		; При выгрузке DLL из памяти, DLL может восстановить таблицу отложенного импорта
		; в исходное состояние, обратившись к ее оригинальной копии, RVA-указатель на которую хранится в поле pUnloadIAT.
		; Если копии нет, тогда указатель на нее будет обращен в ноль
	TimeDateStamp.l					   ; 0 if not bound, Otherwise, date/time of the target DLL
		; 0 если нет привязки, O.W. date/time stamp of DLL bound to Old BIND
EndStructure

Structure IMAGE_THUNK_DATA ; Размерность полей зависит от разрядности!
	StructureUnion
		ForwarderString.i
		Function.i
		Ordinal.i
		AddressOfData.i
	EndStructureUnion
EndStructure

Structure IMAGE_IMPORT_BY_NAME
	Hint.w
	Name.s{128}
EndStructure

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	#ORDINAL_MASK = ~$80000000
CompilerElse
	#ORDINAL_MASK = ~$8000000000000000
CompilerEndIf

; https://learn.microsoft.com/en-us/windows/win32/api/dbghelp/nf-dbghelp-imagedirectoryentrytodata
#IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT = 11
#IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT = 13
; #IMAGE_DIRECTORY_ENTRY_EXPORT = 0
; #IMAGE_DIRECTORY_ENTRY_IAT = 12
; #IMAGE_DIRECTORY_ENTRY_IMPORT = 1 ; IAT!

Structure MODULE_DATA
	ModuleName.s
	ImageBase.i
	*ImportDescr.IMAGE_IMPORT_DESCRIPTOR
	*DelayDescr.IMAGE_DELAYLOAD_DESCRIPTOR
EndStructure

Macro DbgIatHookMsg
	"IAT Module:
EndMacro
Macro IAT_Module(ModuleName,fSystem=1)
	CompilerIf Not Defined(ModuleData_#ModuleName,#PB_Variable)
		DbgIatHook(DbgIatHookMsg ModuleName#DoubleQuote)
		Global ModuleData_#ModuleName.MODULE_DATA
		_IAT_Module(@ModuleData_#ModuleName,DoubleQuote#ModuleName.dll#DoubleQuote)
	CompilerEndIf
EndMacro
Macro IAT_ModuleExt(ModuleName,ModuleExt,fSystem=1)
	CompilerIf Not Defined(ModuleData_#ModuleName,#PB_Variable)
		DbgIatHook(DbgIatHookMsg ModuleName.ModuleExt#DoubleQuote)
		Global ModuleData_#ModuleName.MODULE_DATA
		_IAT_Module(@ModuleData_#ModuleName,DoubleQuote#ModuleName.ModuleExt#DoubleQuote)
	CompilerEndIf
EndMacro

Macro IAT_Address(ModuleName,Address)
	CompilerIf Not Defined(ModuleData_#ModuleName,#PB_Variable)
		DbgIatHook(DbgIatHookMsg ModuleName#DoubleQuote)
		Global ModuleData_#ModuleName.MODULE_DATA
		_IAT_Address(@ModuleData_#ModuleName,Address)
	CompilerEndIf
EndMacro

Procedure _IAT_Address(*ModuleData.MODULE_DATA,Address)
	Protected ulSize
	If Address
		*ModuleData\ImageBase = Address
	EndIf
	*ModuleData\ImportDescr = ImageDirectoryEntryToData_(*ModuleData\ImageBase,#True,#IMAGE_DIRECTORY_ENTRY_IMPORT,@ulSize)
	*ModuleData\DelayDescr = ImageDirectoryEntryToData_(*ModuleData\ImageBase,#True,#IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT,@ulSize)
EndProcedure

Procedure _IAT_Module(*ModuleData.MODULE_DATA,ModuleName.s,fSystem=1)
	*ModuleData\ImageBase = LoadDll(ModuleName,fSystem)
	If *ModuleData\ImageBase = #Null
		PPErrorMessage("Failed load dll"+#CR$+ModuleName)
		;RaiseError(#ERROR_DLL_INIT_FAILED)
		TerminateProcess_(GetCurrentProcess_(),0)
	EndIf
	*ModuleData\ModuleName = ModuleName
	_IAT_Address(*ModuleData.MODULE_DATA,*ModuleData\ImageBase)
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
EnumerationBinary IATHOOK_ENUM
	#IATHOOK_STATICIMPORT
	#IATHOOK_DELAYIMPORT
EndEnumeration
#IATHOOK_ALLIMPORT = #IATHOOK_STATICIMPORT+#IATHOOK_DELAYIMPORT
Macro IAT_Hook(ModuleName,DllName,FuncName,flags=#IATHOOK_ALLIMPORT)
	CompilerIf Not Defined(Original_#FuncName,#PB_Variable)
		Global Original_#FuncName
	CompilerEndIf
	_IAT_Hook(@ModuleData_#ModuleName,DoubleQuote#DllName.dll#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Detour_#FuncName(),@Original_#FuncName,flags)
EndMacro
Macro IAT_HookExt(ModuleName,DllName,DllExt,FuncName,flags=#IATHOOK_ALLIMPORT)
	CompilerIf Not Defined(Original_#FuncName,#PB_Variable)
		Global Original_#FuncName
	CompilerEndIf
	_IAT_Hook(@ModuleData_#ModuleName,DoubleQuote#DllName.DllExt#DoubleQuote,DoubleQuote#FuncName#DoubleQuote,@Detour_#FuncName(),@Original_#FuncName,flags)
EndMacro

Procedure.i _IAT_Hook(*ModuleData.MODULE_DATA,DllName.s,FuncName.s,*Detour,*Original.Integer=#Null,flags=#IATHOOK_ALLIMPORT) ; TODO: *hDll.Integer=#Null
	Protected *ImportAddress.Integer, *ImportName.Integer
	Protected ImportDllName.s, ImportFuncName.s
	Protected ImageBase = *ModuleData\ImageBase
	Protected *ImportDescr.IMAGE_IMPORT_DESCRIPTOR = *ModuleData\ImportDescr
	Protected *DelayDescr.IMAGE_DELAYLOAD_DESCRIPTOR = *ModuleData\DelayDescr
	Protected *OldRef, *OldProtect, hDll
	Protected *AnsiFuncName
	
	DbgIatHook("IAT Hook: "+DllName+" :: "+FuncName)
	;DbgIatHook("IMAGE_DIRECTORY_ENTRY_IMPORT: "+Str(*ImportDescr))
	If *Original And *Original\i=0
		hDll = LoadDll(DllName,1)
		*AnsiFuncName = Ascii(FuncName)
		*Original\i = GetProcAddress_(hDll,*AnsiFuncName)
		DbgIatHook("  Get original: "+Str(*Original\i)+" "+FuncName)
		FreeMemory(*AnsiFuncName)
	EndIf
	CharLower_(@DllName)
	CharLower_(@FuncName)
	If *ImportDescr And (flags & #IATHOOK_STATICIMPORT)
		While *ImportDescr\Name
			ImportDllName = PeekS(ImageBase+*ImportDescr\Name,-1,#PB_Ascii)
			;DbgIatHook("  "+ImportDllName)
			CharLower_(@ImportDllName)
			If ImportDllName=DllName
				*ImportAddress = ImageBase + *ImportDescr\FirstThunk
				*ImportName = ImageBase + *ImportDescr\OriginalFirstThunk
				While *ImportName\i
					; Если старший бит установлен, то это импорт по номеру (ordinal)
					; Если нет - RVA импортируемого символа (структура IMAGE_IMPORT_BY_NAME)
					If *ImportName\i < 0
						;DbgIatHook("    "+Str(*ImportName\i|#ORDINAL_MASK))
					Else
						ImportFuncName = PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii)
						;DbgIatHook("      "+ImportFuncName)
						CharLower_(@ImportFuncName)
						If ImportFuncName=FuncName
							*OldRef = *ImportAddress\i
							If *OldRef <> *Detour
								DbgIatHook("  Set import: "+Str(*OldRef)+" "+PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii)+" "+Str(*Detour))
								VirtualProtect_(*ImportAddress,SizeOf(*ImportAddress),#PAGE_EXECUTE_READWRITE,@*OldProtect)
								;VirtualProtectEx_(GetCurrentProcess_(),@*ImportAddress\i,SizeOf(*Detour),#PAGE_EXECUTE_READWRITE,@*OldProtect)
								*ImportAddress\i = *Detour
								;Break ; можно закончить просмотр?
							Else
								DbgIatHook("  Skip import: "+Str(*OldRef)+" "+PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii))
							EndIf
						EndIf
					EndIf
					*ImportName + SizeOf(*ImportName)
					*ImportAddress + SizeOf(*ImportAddress)
					; а вот здесь заканчивать просмотр нельзя, так как могут быть ещё дескрипторы (???)
				Wend
			EndIf
			*ImportDescr + SizeOf(IMAGE_IMPORT_DESCRIPTOR)
		Wend
	EndIf
	
	; https://kaimi.io/2011/09/pe-format-import/
	;DbgIatHook("IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT: "+Str(*ImportDescr))
	If *DelayDescr And (flags & #IATHOOK_DELAYIMPORT)
		While *DelayDescr\DllNameRVA
			ImportDllName = PeekS(ImageBase+*DelayDescr\DllNameRVA,-1,#PB_Ascii)
			;DbgIatHook("  "+ImportDllName)
			CharLower_(@ImportDllName)
			If ImportDllName=DllName
				*ImportAddress = ImageBase + *DelayDescr\ImportAddressTableRVA
				*ImportName = ImageBase + *DelayDescr\ImportNameTableRVA
				While *ImportName\i
					If *ImportName\i < 0
						;DbgIatHook("    "+Str(*ImportName\i|#ORDINAL_MASK))
					Else
						ImportFuncName = PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii)
						;DbgIatHook("    "+ImportFuncName)
						CharLower_(@ImportFuncName)
						If ImportFuncName=FuncName
							*OldRef = *ImportAddress\i
							If *OldRef <> *Detour
								DbgIatHook("    Set delay: "+Str(*OldRef)+" "+PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii)+" "+Str(*Detour))
								VirtualProtect_(*ImportAddress\i,SizeOf(*ImportAddress),#PAGE_EXECUTE_READWRITE,@*OldProtect)
								*ImportAddress\i = *Detour
								;Break
							Else
								DbgIatHook("    Skip delay: "+Str(*OldRef)+" "+PeekS(ImageBase+*ImportName\i+OffsetOf(IMAGE_IMPORT_BY_NAME\Name),-1,#PB_Ascii))
							EndIf
						EndIf
					EndIf
					*ImportName + SizeOf(*ImportName)
					*ImportAddress + SizeOf(*ImportAddress)
				Wend
			EndIf
			*DelayDescr + SizeOf(IMAGE_DELAYLOAD_DESCRIPTOR)
		Wend
	EndIf
	ProcedureReturn *Original
EndProcedure

;;======================================================================================================================
Macro IAT_BeginInitHooks
	DbgIatHook("IAT: BeginInitHooks")
	IAT_Address(Program,GetModuleHandle_(#Null))
EndMacro
Macro IAT_EndInitHooks
	DbgIatHook("IAT: EndInitHooks")
EndMacro
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 147
; FirstLine = 144
; Folding = 8--
; EnableThread
; DisableDebugger
; EnableExeConstant