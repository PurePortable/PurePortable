;;======================================================================================================================
; Чтение и запись файлов конфигурации
;;======================================================================================================================

Global ConfigFile.s
Global PermanentFile.s ; depricated
Global InitialFile.s

CompilerIf Not Defined(CONFIG_FILEEXT,#PB_Constant) : #CONFIG_FILEEXT = ".pport" : CompilerEndIf
CompilerIf Not Defined(CONFIG_INITIALEXT,#PB_Constant) : #CONFIG_INITIALEXT = #CONFIG_FILEEXT : CompilerEndIf
CompilerIf Defined(CONFIG_FILENAME,#PB_Constant)
	CompilerIf #CONFIG_FILENAME<>""
		ConfigFile = PrgDir+#CONFIG_FILENAME
		If GetExtensionPart(ConfigFile)=""
			ConfigFile + #CONFIG_FILEEXT
		EndIf
	CompilerElse
		ConfigFile = PrgDir+PrgName+#CONFIG_FILEEXT
	CompilerEndIf
CompilerEndIf
CompilerIf Defined(CONFIG_PERMANENT,#PB_Constant) ; depricated
	CompilerIf #CONFIG_PERMANENT<>""
		InitialFile = PrgDir+#CONFIG_PERMANENT
		If GetExtensionPart(InitialFile)=""
			InitialFile + #CONFIG_INITIALEXT
		EndIf
	CompilerElse
		InitialFile = PrgDir+PrgName+"-Init"+#CONFIG_INITIALEXT
	CompilerEndIf
CompilerElseIf Defined(CONFIG_INITIAL,#PB_Constant)
	CompilerIf #CONFIG_INITIAL<>""
		InitialFile = PrgDir+#CONFIG_INITIAL
		If GetExtensionPart(InitialFile)=""
			InitialFile + #CONFIG_INITIALEXT
		EndIf
	CompilerElse
		InitialFile = PrgDir+PrgName+"-Init"+#CONFIG_INITIALEXT
	CompilerEndIf
CompilerEndIf
CompilerIf Defined(CONFIG_OLDNAME,#PB_Constant)
	CompilerIf #CONFIG_OLDNAME<>""
		Global ConfigOldFile.s = PrgDir+#CONFIG_OLDNAME
		If FileSize(ConfigOldFile)>=0
			RenameFile(ConfigOldFile,ConfigFile)
		EndIf
	CompilerElse
		Global ConfigOldFile.s
	CompilerEndIf
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(CFG_SAVE_ON_CLOSE,#PB_Constant) : #CFG_SAVE_ON_CLOSE = 0 : CompilerEndIf

;;======================================================================================================================
; Процедуры для работы со значениями в виртуальном реестре
;;======================================================================================================================
CompilerIf Not Defined(PROC_CFG,#PB_Constant) : #PROC_CFG = 0 : CompilerEndIf
Procedure.i CfgExist(sKey.s,sName.s)
	CharLower_(@sKey)
	CharLower_(@sName)
	Protected i
	Protected hKey = FindKey(sKey)
	If hKey
		CharLower_(@sName)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				ProcedureReturn i
			EndIf
		Next
	EndIf
	ProcedureReturn 0
EndProcedure
Procedure.i _AddCfg(sKey.s,sName.s,dwType.l)
	CharLower_(@sKey)
	CharLower_(@sName)
	ConfigChanged = #True
	Protected i, iempty
	Protected hKey = AddKey(sKey)
	For i=1 To nCfg ; ищем уже существующее значение и перезаписываем
		If Cfg(i)\h = 0 ; удалённый параметр
			iempty = i
		ElseIf Cfg(i)\h=hKey And Cfg(i)\n=sName ; переписываем параметр
			DbgRegVirt("SetCfg: SET: "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType))
			Break
		EndIf
	Next
	; После завершения цикла for, i будет равен либо индексу найденного значения, либо на единицу больше nCfg
	If i > nCfg
		If iempty ; используем пустое
			DbgRegVirt("SetCfg: NEW: "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType))
			i = iempty
		Else ; или добавляем
			DbgRegVirt("SetCfg: ADD: "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType))
			nCfg = i
			ReDim Cfg(nCfg)
		EndIf
	EndIf
	Cfg(i)\h = hKey
	Cfg(i)\n = sName
	Cfg(i)\t = dwType
	ProcedureReturn i
EndProcedure
Procedure SetCfgS(sKey.s,sName.s,sData.s)
	Protected i = _AddCfg(sKey,sName,#REG_SZ)
	Cfg(i)\a = sData
	Cfg(i)\c = StringByteLength(sData)+2
	;Cfg(i)\m = Cfg(i)\c
EndProcedure
Procedure SetCfgD(sKey.s,sName.s,dwData.l)
	Protected i = _AddCfg(sKey,sName,#REG_DWORD)
	Cfg(i)\c = SizeOf(Long)
	Cfg(i)\l = dwData
EndProcedure
Procedure SetCfgB(sKey.s,sName.s,sHex.s)
	Protected i = _AddCfg(sKey,sName,#REG_BINARY)
	sHex = ReplaceString(ReplaceString(sHex,",","")," ","")+"0" ; плюс "0" для нейтрализации ошибки если было нечётное количество символов
	Protected Size = Len(sHex)/2
	Cfg(i)\c = Size
	;Cfg(i)\m = Size
	If Size<=4
		Hex2Bin(sHex,@Cfg(i)\l)
	Else
		Cfg(i)\a = SpaceB(Size)
		Hex2Bin(sHex,@Cfg(i)\a)
	EndIf
EndProcedure
Procedure.s GetCfgS(sKey.s,sName.s)
	;CharLower_(@sKey) ; преобразование будет в FindKey
	Protected hKey = FindKey(sKey)
	Protected i
	If hKey
		CharLower_(@sName)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				ProcedureReturn Cfg(i)\a
			EndIf
		Next
	EndIf
	ProcedureReturn ""
EndProcedure
Procedure.l GetCfgD(sKey.s,sName.s,DefVal=0)
	;CharLower_(@sKey) ; преобразование будет в FindKey
	Protected hKey = FindKey(sKey)
	Protected i
	If hKey
		CharLower_(@sName)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				ProcedureReturn Cfg(i)\l
			EndIf
		Next
	EndIf
	ProcedureReturn DefVal
EndProcedure
Procedure DelCfg(sKey.s,sName.s)
	Protected i
	Protected hKey = FindKey(sKey)
	If hKey
		CharLower_(@sName)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				Cfg(i)\h = 0
				Cfg(i)\l = 0
				Cfg(i)\c = 0
				;Cfg(i)\m = 0
				Cfg(i)\n = ""
				Cfg(i)\a = ""
				ConfigChanged = #True
			EndIf
		Next
	EndIf
EndProcedure
Procedure DelTree(sKey.s)
	Protected CmpKey.s = sKey + "\"
	Protected lenCmpKey = Len(CmpKey)
	Protected ik, ic, vKey
	For ik=1 To nKeys ; ищем все подключи и сам ключ
		If Keys(ik) = sKey Or Left(Keys(ik),lenCmpKey) = CmpKey
			;dbg("DelTree: "+Keys(ik))
			ConfigChanged = #True
			vKey = i2hkey(ik) ; виртуальный хэндл удаляемого подключа
			For ic=1 To nCfg  ; ищем и удаляем значения связанные с удаляемым ключом
				If Cfg(ic)\h = vKey
					;dbg("DelTree: Val: "+Cfg(ic)\n)
					Cfg(ic)\h = 0
					Cfg(ic)\c = 0
					;Cfg(ic)\m = 0
					Cfg(ic)\l = 0
					Cfg(ic)\n = ""
					Cfg(ic)\a = ""
				EndIf
			Next
			Keys(ik) = ""
		EndIf
	Next
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(PROC_ICFG,#PB_Constant) : #PROC_ICFG = 0 : CompilerEndIf
CompilerIf #PROC_ICFG
	Procedure SetIC(Index,dwType.l,sData.s,bData.l=0,cbData=1)
		Protected i
		ConfigChanged = #True
		Cfg(Index)\t = dwType
		If dwType=#REG_DWORD
			Cfg(Index)\l = bData
			Cfg(Index)\c = SizeOf(Long)
		ElseIf dwType=#REG_BINARY And cbData<=4
			Cfg(Index)\l = bData
			Cfg(Index)\c = cbData
		ElseIf dwType=#REG_SZ
			Cfg(Index)\a = sData
			Cfg(Index)\c = StringByteLength(sData)+2
		EndIf
	EndProcedure
	Procedure SetICS(Index,sData.s)
		SetIC(Index,#REG_SZ,sData)
	EndProcedure
	Procedure SetICD(Index,bData.l)
		SetIC(Index,#REG_DWORD,"",bData)
	EndProcedure
	Procedure SetICB(Index,bData.l,cbData=1)
		SetIC(Index,#REG_BINARY,"",bData,cbData)
	EndProcedure
	Procedure DelIC(Index)
		Cfg(Index)\h = 0
		Cfg(Index)\n = ""
		Cfg(Index)\c = 0
		Cfg(Index)\l = 0
		Cfg(Index)\a = ""
	EndProcedure
	Macro ICN(Index)
		Cfg(Index)\n
	EndMacro
	Macro ICS(Index)
		Cfg(Index)\a
	EndMacro
	Macro ICD(Index)
		Cfg(Index)\l
	EndMacro
CompilerEndIf
CompilerIf Not Defined(PROC_FINDCFG,#PB_Constant) : #PROC_FINDCFG = 0 : CompilerEndIf
CompilerIf #PROC_FINDCFG
	Procedure.s FindCfgS(ValueName.s)
		Protected i
		For i=1 To nCfg
			If Cfg(i)\n=ValueName And Cfg(i)\t=#REG_SZ
				ProcedureReturn Cfg(i)\a
			EndIf
		Next
	EndProcedure
	Procedure.l FindCfgD(ValueName.s)
		Protected i
		For i=1 To nCfg
			If Cfg(i)\n=ValueName And Cfg(i)\t=#REG_DWORD
				ProcedureReturn Cfg(i)\l
			EndIf
		Next
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(PROC_CORRECTCFGPATH,#PB_Constant) : #PROC_CORRECTCFGPATH = 0 : CompilerEndIf
CompilerIf #PROC_CORRECTCFGPATH
	Procedure CorrectCfgPath(Key.s,Value.s,Base.s,Flags=0)
		Protected Path.s = CorrectPath(GetCfgS(Key,Value),Base,Flags)
		If Flags & #CORRECTPATH_REAL_PATH
			If Path
				SetCfgS(Key,Value,Path)
			EndIf
		Else
			SetCfgS(Key,Value,Path)
		EndIf
	EndProcedure
CompilerEndIf

;;======================================================================================================================
; Процедуры для работы с файлами конфигурации
;;======================================================================================================================
; https://ru.wikipedia.org/wiki/Плоскость_(Юникод)
; https://ru.wikipedia.org/wiki/Области_для_частного_использования
; https://en.wikipedia.org/wiki/Unicode_control_character
; https://translated.turbopages.org/proxy_u/en-ru.ru.f9d70658-62a4a654-21fe0b42-74722d776562/https/en.wikipedia.org/wiki/Unicode_control_character
; TODO: другие управляющие символы

;#CONFIG_SEPARATOR = $A789 ; Модификатор письма двоеточие https://symbl.cc/ru/A789/
#CONFIG_SEPARATOR = $E800 ; Из набора символов для частного использования
#CONFIG_SEPARATOR$ = Chr(#CONFIG_SEPARATOR)
#CFG_CHR_NUL = $E000 ; 57344 - Из набора символов для частного использования
#CFG_CHR_SPACE = #CFG_CHR_NUL+$20
;;----------------------------------------------------------------------------------------------------------------------
; Поиск специальных символов-разделителей
Procedure FindCtrl(s.s,start=1)
	Protected i, c.c, l=Len(s)
	Protected istart = @s+start*2-2
	Protected iend = @s+l*2-2
	For i=istart To iend
		c = PeekC(i)
		If c=#CONFIG_SEPARATOR Or (c<32 And c>13) Or c=#TAB ;c<>10 And c<>13 And c<>0
			ProcedureReturn (i-@s)/2+1
		EndIf
	Next
	ProcedureReturn 0
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
; Чтение параметров из файла
Procedure ReadCfgFile(Config.s)
	Protected s.s, hKey, sKey.s, sData.s, cbData, sType.s, sName.s
	Protected x1, x2, x3, i
	Protected *pb.Byte, *pc.Character, *end
	Protected CodePage
	nCfg = ArraySize(Cfg())
	nKeys = ArraySize(Keys())
	ConfigChanged = #False
	Protected hCfg = ReadFile(#PB_Any,Config,#PB_File_SharedRead|#PB_File_SharedWrite)
	If hCfg
		CodePage = ReadStringFormat(hCfg)
		While Not Eof(hCfg)
			s = ReadString(hCfg,CodePage)
			x1 = FindCtrl(s)
			If x1 > 1
				x2 = FindCtrl(s,x1+1)
				x3 = FindCtrl(s,x2+1)
				If x2 And x3
					sKey = LCase(Left(s,x1-1))
					sName = LCase(Mid(s,x1+1,x2-x1-1))
					sType = Mid(s,x2+1,x3-x2-1)
					sData = Mid(s,x3+1)
					hKey = AddKey(sKey)
					For i=1 To nCfg
						If Cfg(i)\h=hKey And Cfg(i)\n=sName ; дубликат параметра, заменяем
							Break
						EndIf
					Next
					; После завершения цикла for, i будет равен либо индексу найденного значения, либо на единицу больше nCfg
					If i > nCfg
						nCfg = i
						ReDim Cfg(nCfg)
					EndIf
					Cfg(i)\h = hKey
					Cfg(i)\n = sName
					Select sType
						Case "s"
							Cfg(i)\t = #REG_SZ
						Case "m"
							Cfg(i)\t = #REG_MULTI_SZ
						Case "x"
							Cfg(i)\t = #REG_EXPAND_SZ
						Case "b"
							Cfg(i)\t = #REG_BINARY
						Case "d"
							Cfg(i)\t = #REG_DWORD
						Default
							Cfg(i)\t = Val("$"+sType)
					EndSelect
					Select sType
						Case "s","m","x"
							cbData = StringByteLength(sData)+2
						Case "d"
							cbData = SizeOf(Long)
						Default ; всё остальное хранится в виде hex-строки
							cbData = Len(sData)/2 ; два символа кодируют один байт
					EndSelect
					Cfg(i)\c = cbData
					; Тип проверяем в строковом виде, так как могут встретиться стандартные типы нестандартной длины.
					; Такие данные сохраняются с типом в hex виде и сами данные в виде hex-строки.
					If sType="s" Or sType="m" Or sType="x"
						Cfg(i)\a = sData
						DecodeCtrl(@Cfg(i)\a)
					ElseIf sType="d" ;And cbData=4
						Cfg(i)\l = Val("$"+sData)
					Else ; данные закодированны в бинарном виде, в том числе и для нестандартной длины REG_DWORD
						If (Cfg(i)\t=#REG_DWORD Or Cfg(i)\t=#REG_BINARY) And cbData<=4
							Hex2Bin(sData,@Cfg(i)\l)
						Else
							Cfg(i)\a = SpaceB(cbData+2)
							Hex2Bin(sData,@Cfg(i)\a)
						EndIf
					EndIf
				EndIf
			ElseIf x1 = 0 ; ключ без значения
				AddKey(sKey)
			;Else Иначе x1 = 1 строка начинается со спецсимвола, пропускаем как комментарий
			EndIf
		Wend
		CloseFile(hCfg)
	EndIf
EndProcedure
Procedure ReadCfg()
	If FileExist(ConfigFile)
		ReadCfgFile(ConfigFile)
	EndIf
	If FileExist(InitialFile)
		ReadCfgFile(InitialFile)
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Запись параметров в файл
Procedure WriteCfg()
	Protected i, sData.s, sType.s, sKey.s, sName.s, cbData, dwType.l
	Protected *ptr
	RegCriticalEnter
	If ConfigFile <> "" And ConfigChanged
		Protected hCfg = CreateFile(#PB_Any,ConfigFile,#PB_File_SharedRead|#PB_File_SharedWrite)
		If hCfg
			;dbg(Str(nKeys)+" "+Str(nCfg))
			WriteStringFormat(hCfg,#PB_Unicode)
			For i=1 To nKeys
				sKey = Keys(i)
				If sKey And Left(sKey,1)<>"?"
					WriteStringN(hCfg,sKey,#PB_Unicode)
				EndIf
			Next
			WriteStringN(hCfg,"",#PB_Unicode)
			For i=1 To nCfg
				sKey = GetKey(Cfg(i)\h)
				If sKey = "" : Continue : EndIf ; TODO: обработать через ErrorCfg()
				If Left(sKey,1) = "?" : Continue : EndIf
				sName = Cfg(i)\n
				cbData = Cfg(i)\c
				dwType = Cfg(i)\t
				If Cfg(i)\h
					Select dwType
						Case #REG_SZ
							sType = "s"
						Case #REG_MULTI_SZ
							sType = "m"
						Case #REG_EXPAND_SZ
							sType = "x"
						Case #REG_DWORD
							sType = "d"
						Case #REG_BINARY
							sType = "b"
						Default
							sType = Hex(dwType)
					EndSelect
					If dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ Or dwType=#REG_MULTI_SZ
						;sData = Cfg(i)\a ; MultiString так присваивать нельзя
						sData = SpaceB(cbData)
						CopyMemory(@Cfg(i)\a,@sData,cbData)
						EncodeCtrl(@sData,dwType)
					ElseIf dwType=#REG_DWORD And cbData=4 ; Иногда попадаются REG_DWORD нестандартной длины, например, 8 байт (REG_QWORD)
						sData = Hex(Cfg(i)\l,#PB_Long)
					Else ; всё остальное храним в HEX виде, в том числе REG_DWORD нестандартной длины
						If dwType=#REG_DWORD
							sType = Hex(dwType) ; REG_DWORD нестандартной длины
						EndIf
						If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4 ; ASK: Проверять только длину?
							sData = Bin2Hex(@Cfg(i)\l,cbData)
						Else
							*ptr = @Cfg(i)\a
							sData = Bin2Hex(*ptr,cbData)
						EndIf
					EndIf
					WriteStringN(hCfg,sKey+#CONFIG_SEPARATOR$+sName+#CONFIG_SEPARATOR$+sType+#CONFIG_SEPARATOR$+sData,#PB_Unicode)
					;dbg(sKey+#CONFIG_SEPARATOR$+sName+#CONFIG_SEPARATOR$+sType+#CONFIG_SEPARATOR$+sData)
					;FlushFileBuffers(hCfg)
				EndIf
			Next
		EndIf
		;FlushFileBuffers(hCfg) ; ???
		CloseFile(hCfg)
		ConfigChanged = #False
	EndIf
	RegCriticalLeave
EndProcedure

;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = AAAA-
; EnableThread
; DisableDebugger
; EnableExeConstant