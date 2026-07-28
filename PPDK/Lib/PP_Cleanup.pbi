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

Global CleanupFileList.s, CleanupEveryProcess
Global Dim CleanupList.s(0), nCleanupList, fCleanupList

;;----------------------------------------------------------------------------------------------------------------------
; Добавление цели в список очистки.
; При необходимости создаётся временный файл для списка.
; https://learn.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-gettempfilenamea
Procedure AddCleanItem(Item.s,Incr=1)
	fCleanupList + Incr
	DbgCln("AddCleanItem: "+Item)
	AddArrayS(CleanupList(),Item)
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Ручное добавление цели в список очистки для использования в PureExpert из DetachProcedure.
Procedure Clean(Item.s,Incr=1)
	If PrgIsValid And LastProcess
		AddCleanItem(Item,Incr)
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Команды для добавления в DetachProcedure
; Если это последний процесс и список очистки создан (вызывались Clean или AddCleanItem), будет создан отдельный процесс для очистки.
Procedure DetachCleanup()
	If PrgIsValid And fCleanupList
		CleanupFileList = Space(#MAX_PATH)
		Protected RetCode = GetTempFileName_(TempDir,"~PP",0,@CleanupFileList)
		Protected i
		Protected n = ArraySize(CleanupList())
		Protected CleanupItem.s, CleanupItemType.s
		Protected hCleanupFileList = OpenFile(#PB_Any,CleanupFileList,#PB_UTF8)
		WriteStringFormat(hCleanupFileList,#PB_UTF8)
		For i=1 To n
			CleanupItem = CleanupList(i)
			CleanupItemType = Left(CleanupItem,1)
			If CleanupItemType<>";" And CleanupItemType<>"|" And CleanupItemType<>">" And CleanupItemType<>"<"
				CleanupItem = NormalizePath(CleanupItem)
			EndIf
			WriteStringN(hCleanupFileList,CleanupItem,#PB_UTF8)
		Next
		CloseFile(hCleanupFileList)
		;Protected CleanupCmdLine.s = Chr(34)+DllPath+Chr(34)+",PurePortableCleanup "+StrU(DbgClnMode)+" "+StrU(ProcessId)+" "+Chr(34)+CleanupFileList+Chr(34)
		Protected CleanupCmdLine.s = Chr(34)+DllPath+Chr(34)+",PurePortableCleanup "+StrU(DbgClnMode)+" "+Chr(34)+CleanupFileList+Chr(34)
		DbgCln("PurePortableCleanup: "+"rundll32 "+CleanupCmdLine)
		Execute(SysDir+"\rundll32.exe",CleanupCmdLine)
	EndIf
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
#FOF_NO_CONNECTED_ELEMENTS = $2000 ; https://learn.microsoft.com/ru-ru/windows/win32/api/shobjidl_core/nf-shobjidl_core-ifileoperation-setoperationflags
ProcedureDLL.l PurePortableCleanup(hWnd,hInst,*lpszCmdLine,nCmdShow)
	; *lpszCmdLine в кодировке ASCII ! Не используем!
	; Командная строка: rundll32 путь_к_dll,PurePortableCleanup dbg_mode "путь_к_списку"
	
	Protected RetCode
	Protected CleanupItem.s, CleanupItemType.s
	DbgClnMode = Val(ProgramParameter(2))
	CleanupFileList = ProgramParameter(3)
	
	;DbgCln("PurePortableCleanup: ProcessId: "+ProgramParameter(2))
	;DbgCln("PurePortableCleanup: FileList: "+ProgramParameter(3))
	
	Protected ProcessPipeName.s, hProcessPipe
	Protected ProcessPipeCnt, ProcessWaitCnt
	Protected SHFileOp.SHFILEOPSTRUCT
	Protected hCleanupFileList = ReadFile(#PB_Any,CleanupFileList,#PB_UTF8)
	If hCleanupFileList
		ReadStringFormat(hCleanupFileList) ; не важен, всегда должен быть UTF8
		While Not Eof(hCleanupFileList)
			CleanupItem = ReadString(hCleanupFileList,#PB_UTF8)
			CleanupItemType = Left(CleanupItem,1)
			Select CleanupItemType
				Case "|"
					DbgCln("PurePortableCleanup: Pipe: "+Mid(CleanupItem,2))
					ProcessPipeName = Mid(CleanupItem,2)
					If ProcessPipeName ; Если ProcessPipeName не пустое, дожидаемся завершения процесса, создавшего этот канал
						hProcessPipe = CreateNamedPipe_(@ProcessPipeName,#PIPE_ACCESS_DUPLEX,0,#PIPE_UNLIMITED_INSTANCES,16,16,0,#Null)
						GetNamedPipeHandleState_(hProcessPipe,#Null,@ProcessPipeCnt,#Null,#Null,#Null,0)
						DbgCln("PurePortableCleanup: Pipe counter: "+Str(ProcessPipeCnt))
						While ProcessPipeCnt > 1 ; Должен остаться только 1 процесс - текущий RunDll32
							ProcessWaitCnt+1
							DbgCln("PurePortableCleanup: Wait end process: "+Str(ProcessWaitCnt))
							Delay(10)
							GetNamedPipeHandleState_(hProcessPipe,#Null,@ProcessPipeCnt,#Null,#Null,#Null,0)
						Wend
						;CloseHandle_(hProcessPipe) ; В принципе, лучше не закрывать. Закроется автоматически. (???)
					EndIf
				Case ">"
					DbgCln("PurePortableCleanup: Delay: "+Mid(CleanupItem,2))
					Delay(Val(Mid(CleanupItem,2)))
				Case "<"
				Default
					DbgCln("PurePortableCleanup: "+CleanupItem)
					CleanupItem = ReplaceString(CleanupItem,"|",#XNUL$)+#XNUL$ ; Эта строка должна быть завершена двойным значением NULL
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
			EndSelect
		Wend
		CloseFile(hCleanupFileList)
		DeleteFile(CleanupFileList)
	EndIf
EndProcedure
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = C-
; EnableThread
; DisableDebugger
; EnableExeConstant