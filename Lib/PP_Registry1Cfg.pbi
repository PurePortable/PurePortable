;;======================================================================================================================
; Чтение и запись файлов конфигурации
;;======================================================================================================================

Global ConfigFile.s
Global PermanentFile.s
Global InitialFile.s

CompilerIf Not Defined(CONFIG_FILEEXT,#PB_Constant) : #CONFIG_FILEEXT = ".pport" : CompilerEndIf
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
CompilerIf Defined(CONFIG_PERMANENT,#PB_Constant)
	CompilerIf #CONFIG_PERMANENT<>""
		PermanentFile = PrgDir+#CONFIG_PERMANENT
		If GetExtensionPart(PermanentFile)=""
			PermanentFile + #CONFIG_FILEEXT
		EndIf
	CompilerElse
		PermanentFile = PrgDir+PrgName+"-Data"+#CONFIG_FILEEXT
	CompilerEndIf
CompilerEndIf
CompilerIf Defined(CONFIG_INITIAL,#PB_Constant)
	CompilerIf #CONFIG_INITIAL<>""
		InitialFile = PrgDir+#CONFIG_INITIAL
		If GetExtensionPart(InitialFile)=""
			InitialFile + #CONFIG_FILEEXT
		EndIf
	CompilerElse
		InitialFile = PrgDir+PrgName+"-Init"+#CONFIG_FILEEXT
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

;;----------------------------------------------------------------------------------------------------------------------
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
Procedure ReadCfg(AltConfig.s="")
	Protected s.s, hKey, sKey.s, sData.s, cbData, sType.s, sName.s, Config.s
	Protected x1, x2, x3, i
	Protected *pb.Byte, *pc.Character, *end
	Protected CodePage
	If AltConfig
		Config = AltConfig
	ElseIf FileExist(ConfigFile)
		Config = ConfigFile
	ElseIf FileExist(InitialFile)
		Config = InitialFile
	EndIf
	If Config <> ""
		nCfg = ArraySize(Cfg())
		nKeys = ArraySize(Keys())
		ConfigChanged = #False
		Protected hCfg = ReadFile(#PB_Any,Config,#PB_File_SharedRead|#PB_File_SharedWrite)
		If hCfg
			CodePage = ReadStringFormat(hCfg)
			While Not Eof(hCfg)
				s = ReadString(hCfg,CodePage)
				x1 = FindCtrl(s)
				If x1
					x2 = FindCtrl(s,x1+1)
					x3 = FindCtrl(s,x2+1)
					If x2 And x3
						sKey = LCase(Left(s,x1-1))
						sName = LCase(Mid(s,x1+1,x2-x1-1))
						sType = Mid(s,x2+1,x3-x2-1)
						sData = Mid(s,x3+1)
						hKey = AddKey(sKey)
						;dbg("READ CFG: "+HKey2Str(hKey)+" "+sKey+" :: "+sType+" :: "+sName+" :: "+sData)
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
						;dbg("ADD: "+Str(ArraySize(Cfg()))+" "+Str(i)+" "+sName+" = "+sData)
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
							Default
								cbData = Len(sData)/2 ; два символа кодируют один байт
						EndSelect
						; Тип проверяем в строковом виде, так как могут встретиться стандартные типы нестандартной длины.
						; Такие данные сохраняются с типом в HEX виде.
						If sType="s" Or sType="m" Or sType="x"
							Cfg(i)\c = cbData
							Cfg(i)\m = cbData
							Cfg(i)\a = sData
							*pc = @Cfg(i)\a
							*end = *pc + cbData
							While *pc < *end ; декодирование управляющих символов 0-31
								If *pc\c>=#CFG_CHR_NUL And *pc\c<#CFG_CHR_SPACE
									*pc\c - #CFG_CHR_NUL
								EndIf
								*pc + 2
							Wend
						ElseIf sType="d" ;And cbData=4
							Cfg(i)\c = cbData
							Cfg(i)\l = Val("$"+sData)
						Else ; данные закодированны в бинарном виде, в том числе и для нестандартной длины REG_DWORD
							;cbData = Len(sData)/2 ; два символа кодируют один байт
							Cfg(i)\c = cbData
							*pc = @sData
							If (Cfg(i)\t=#REG_DWORD Or Cfg(i)\t=#REG_BINARY) And cbData<=4
								*pb = @Cfg(i)\l
							Else
								Cfg(i)\a = SpaceB(cbData)
								Cfg(i)\m = cbData
								*pb = @Cfg(i)\a
							EndIf
							*end = *pb+cbData
							While *pb < *end
								*pb\b = Val("$"+PeekS(*pc,2))
								*pb + 1
								*pc + 4 ; hex представление байта - два символа в юникоде
							Wend
						EndIf
					EndIf
				Else ; ключ без значения
					AddKey(sKey)
				EndIf
			Wend
		EndIf
		CloseFile(hCfg)
	EndIf
	;For i=1 To nKeys ;ArraySize(Keys())
	;	dbg("CFG: "+Keys(i))
	;Next
	;dbgclear()
	;For i=1 To ArraySize(Cfg())
	;	If Cfg(i)\t=#REG_DWORD
	;		dbg("CFG: "+Cfg(i)\n+" : dw : "+HexLA(Cfg(i)\l))
	;	ElseIf Cfg(i)\t=#REG_BINARY And Cfg(i)\c<=4
	;		dbg("CFG: "+Cfg(i)\n+" : bd "+Str(Cfg(i)\c)+" : "+HexLA(Cfg(i)\l))
	;	ElseIf Cfg(i)\t=#REG_BINARY
	;		dbg("CFG: "+Cfg(i)\n+" : bx "+Str(Cfg(i)\c)+" : "+HexLA(PeekL(@Cfg(i)\a))+"...")
	;	ElseIf Cfg(i)\t=#REG_SZ
	;		dbg("CFG: "+Cfg(i)\n+" : sz "+Str(Cfg(i)\c)+" : "+Left(Cfg(i)\a,60))
	;	Else
	;		dbg("CFG: "+Cfg(i)\n+" : "+Cfg(i)\t)
	;	EndIf
	;Next
	;dbg("END READ CFG")
	If AltConfig="" And PermanentFile And FileExist(PermanentFile)
		ReadCfg(PermanentFile)
	EndIf
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Запись параметров в файл
Procedure WriteCfg()
	Protected i, sData.s, sType.s, sKey.s, sName.s, cbData
	Protected *pb.Byte, *pc.Character, *end
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
				;dbg(Cfg(i)\n)
				sKey = GetKey(Cfg(i)\h)
				If sKey = "" : Continue : EndIf ; TODO: обработать через ErrorCfg()
				If Left(sKey,1) = "?" : Continue : EndIf
				sName = Cfg(i)\n
				cbData = Cfg(i)\c
				If Cfg(i)\h
					Select Cfg(i)\t
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
							sType = Hex(Cfg(i)\t)
					EndSelect
					If Cfg(i)\t=#REG_SZ Or Cfg(i)\t=#REG_EXPAND_SZ Or Cfg(i)\t=#REG_MULTI_SZ
						sData = SpaceB(cbData)
						CopyMemory(@Cfg(i)\a,@sData,cbData)
						*pc = @sData
						*end = *pc + cbData - 2 ; кроме завершающего 0
						While *pc < *end ; кодирование служебных символов 0-31
							If *pc\c>=0 And *pc\c<$20
								*pc\c + #CFG_CHR_NUL
							EndIf
							*pc + 2
						Wend
					ElseIf Cfg(i)\t=#REG_DWORD And Cfg(i)\c=4
						sData = Hex(Cfg(i)\l,#PB_Long)
					Else ; всё остальное храним в HEX виде, в том числе REG_DWORD с нестандартной длиной
						sData = Space(cbData*2) ; по два символа на каждый байт
						*pc = @sData
						If Cfg(i)\t=#REG_DWORD
							sType = Hex(Cfg(i)\t)
						EndIf
						If (Cfg(i)\t=#REG_DWORD Or Cfg(i)\t=#REG_BINARY) And cbData<=4
							*pb = @Cfg(i)\l
						Else
							*pb = @Cfg(i)\a
						EndIf
						*end = *pb + cbData
						While *pb < *end ; кодирование управляющих символов 0-31
							PokeS(*pc,RSet(Hex(*pb\b,#PB_Byte),2,"0")) ; пишем по два символа + 0; последний 0 ляжет на 0 в конце строки
							*pb + 1
							*pc + 4 ; hex представление байта - два символа в юникоде
						Wend
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
; Процедуры для работы со значениями в виртуальном реестре
;;======================================================================================================================
CompilerIf Not Defined(PROC_CFG,#PB_Constant) : #PROC_CFG = 0 : CompilerEndIf
Procedure SetCfg(sKey.s,sName.s,dwType.l,sData.s,bData.l=0,cbData=1)
	Protected i, iempty
	Protected hKey = AddKey(sKey)
	CharLower_(@sName)
	ConfigChanged = #True
	For i=1 To nCfg ; ищем уже существующее значение и перезаписываем
		If Cfg(i)\h = 0 And iempty ; удалённый параметр
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
	If dwType=#REG_DWORD
		Cfg(i)\l = bData
		Cfg(i)\c = SizeOf(Long)
	ElseIf dwType=#REG_BINARY And cbData<=4
		Cfg(i)\l = bData
		Cfg(i)\c = cbData
	ElseIf dwType=#REG_SZ
		Cfg(i)\a = sData
		Cfg(i)\c = StringByteLength(sData)+2
		Cfg(i)\m = Cfg(i)\c
	EndIf
EndProcedure
Procedure SetCfgS(sKey.s,sName.s,sData.s)
	SetCfg(sKey,sName,#REG_SZ,sData)
EndProcedure
Procedure SetCfgD(sKey.s,sName.s,bData.l)
	SetCfg(sKey,sName,#REG_DWORD,"",bData)
EndProcedure
Procedure SetCfgB(sKey.s,sName.s,bData.l,cbData=1)
	SetCfg(sKey,sName,#REG_BINARY,"",bData,cbData)
EndProcedure
Procedure.s GetCfgS(sKey.s,sName.s)
	Protected i
	Protected hKey = FindKey(sKey)
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
	Protected i
	Protected hKey = FindKey(sKey)
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
				Cfg(i)\m = 0
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
					Cfg(ic)\m = 0
					Cfg(ic)\l = 0
					Cfg(ic)\n = ""
					Cfg(ic)\a = ""
				EndIf
			Next
			Keys(ik) = ""
		EndIf
	Next
EndProcedure
Procedure CfgExist(sKey.s,sName.s)
	Protected i
	Protected hKey = FindKey(sKey)
	If hKey
		CharLower_(@sName)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				ProcedureReturn Cfg(i)\t
			EndIf
		Next
	EndIf
	ProcedureReturn 0
EndProcedure

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(PROC_ICFG,#PB_Constant) : #PROC_ICFG = 0 : CompilerEndIf
CompilerIf #PROC_ICFG
	Procedure SetIC(Index,dwType.l,sData.s,bData.l=0,cbData=1)
		Protected i, iempty
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
			Cfg(Index)\m = Cfg(Index)\c
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

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = AAAg
; EnableThread
; DisableDebugger
; EnableExeConstant