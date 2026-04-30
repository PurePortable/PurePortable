;;======================================================================================================================

;XIncludeFile "proc\NormalizePath.pbi"
XIncludeFile "proc\Execute.pbi"

;;----------------------------------------------------------------------------------------------------------------------

CompilerIf Not Defined(DBG_CLEANUP,#PB_Constant) : #DBG_CLEANUP = 0 : CompilerEndIf

CompilerIf #DBG_CLEANUP And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf

Global DbgClnMode = #DBG_CLEANUP
CompilerIf #DBG_CLEANUP
	Procedure DbgCln(Txt.s)
		If DbgClnMode
			dbg(Txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgCln(Txt) : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------

Global CleanupList.s, hCleanupList

;;----------------------------------------------------------------------------------------------------------------------
; Добавление цели в список очистки.
; При необходимости создаётся временный файл для списка.
; https://learn.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-gettempfilenamea
Procedure AddCleanItem(Item.s)
	Protected RetCode
	DbgCln("AddCleanItem: "+Item)
	If hCleanupList = 0
		CleanupList = Space(#MAX_PATH)
		RetCode = GetTempFileName_(TempDir,"~PP",0,@CleanupList)
		;CleanupList = CleanupList ; убрать лишние символы
		hCleanupList = OpenFile(#PB_Any,CleanupList,#PB_UTF8)
		;hCleanupList = CreateFile(#PB_Any,CleanupList)
		WriteStringFormat(hCleanupList,#PB_UTF8)
	EndIf
	WriteStringN(hCleanupList,NormalizePath(Item),#PB_UTF8)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Ручное добавление цели в список очистки для использования в PureExpert из DetachProcedure.
Procedure Clean(Item.s)
	If PrgIsValid And LastProcess
		AddCleanItem(Item)
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Команды для добавления в DetachProcedure
; Если это последний процесс и список очистки создан (вызывались Clean или AddCleanItem), будет создан отдельный процесс для очистки.
Macro DetachCleanup
	If PrgIsValid And LastProcess And hCleanupList
		CloseFile(hCleanupList)
		Protected CleanupCmdLine.s = Chr(34)+DllPath+Chr(34)+",PurePortableCleanup "+StrU(DbgClnMode)+" "+StrU(ProcessId)+" "+Chr(34)+CleanupList+Chr(34)
		DbgCln("PurePortableCleanup: "+SysDir+"\rundll32.exe "+CleanupCmdLine)
		Execute(SysDir+"\rundll32.exe",CleanupCmdLine)
	EndIf
EndMacro

;;----------------------------------------------------------------------------------------------------------------------
#FOF_NO_CONNECTED_ELEMENTS = $2000 ; https://learn.microsoft.com/ru-ru/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags
ProcedureDLL.l PurePortableCleanup(hWnd,hInst,*lpszCmdLine,nCmdShow)
	; *lpszCmdLine в кодировке ASCII ! Не используем!
	; Командная строка: rundll32 путь_к_dll,PurePortableCleanup dbg_mode process_id "путь_к_списку"
	
	Protected CleanupItem.s
	DbgClnMode = Val(ProgramParameter(2))
	Protected LastProcessId = Val(ProgramParameter(3))
	CleanupList.s = ProgramParameter(4)
	
	;DbgCln("PurePortableCleanup: ProcessId: "+ProgramParameter(2))
	;DbgCln("PurePortableCleanup: FileList: "+ProgramParameter(3))
	
	Protected SHFileOp.SHFILEOPSTRUCT
	Protected RetCode
	hCleanupList = ReadFile(#PB_Any,CleanupList,#PB_UTF8)
	If hCleanupList
		ReadStringFormat(hCleanupList) ; не важен, всегда должен быть UTF8
		While Not Eof(hCleanupList)
			CleanupItem = ReadString(hCleanupList,#PB_UTF8)
			DbgCln("PurePortableCleanup: "+CleanupItem)
			CleanupItem+#XNUL$ ; Эта строка должна быть завершена двойным значением NULL
			DecodeCtrl(@CleanupItem)
			;SetCurrentDirectory(CleanupDirectory)
			; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shfileoperationa
			;SHFileOp\hwnd = 0 ; Окно не нужно
			SHFileOp\wFunc = #FO_DELETE
			; #FOF_FILESONLY Если в поле pFrom установлено *.*, то операция будет производиться только с файлами.
			; #FOF_SILENT Не показывать диалог с индикатором прогресса.
			; #FOF_NOCONFIRMATION Отвечать "yes to all" на все запросы в ходе операции.
			; #FOF_NO_CONNECTED_ELEMENTS
			SHFileOp\fFlags = #FOF_SILENT|#FOF_NOCONFIRMATION|#FOF_NOERRORUI ;|#FOF_FILESONLY
			SHFileOp\pFrom = @CleanupItem ; Эта строка должна быть завершена двойным значением NULL
			;SHFileOp\fAnyOperationsAborted = 0
			RetCode = SHFileOperation_(SHFileOp)
			; 124 == 0x7C == The path in the source or destination or both was invalid.
			; Путь в источнике или пункте назначения или в обоих случаях недействителен.
			DbgCln("PurePortableCleanup: RetCode: "+Str(RetCode))
		Wend
		CloseFile(hCleanupList)
		DeleteFile(CleanupList)
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = C-
; EnableThread
; DisableDebugger
; EnableExeConstant