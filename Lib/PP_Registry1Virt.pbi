;;======================================================================================================================
; Вывод диагностики работы внутренних функций
CompilerIf #DBG_REGISTRY_MODE
	Procedure DbgRegVirt(s.s)
		If DbgRegMode >= #DBG_REG_MODE_VIRT
			dbg(s)
			;CompilerIf #False ;#DBG_REGISTRY & #DBG_REGISTRY_FILE
			;	Protected hLog = OpenFile(#PB_Any,DbgLogFile,#PB_File_Append)
			;	If hLog
			;		WriteStringN(hLog,s,#PB_Unicode)
			;		CloseFile(hLog)
			;	EndIf
			;CompilerEndIf
		EndIf
	EndProcedure
CompilerElse
	Macro DbgRegVirt(s) : EndMacro
CompilerEndIf
;;======================================================================================================================
; Найти ключ.
; Ключ передаётся без завершающего "\".
; Возвращается виртуальный дескриптор найденного ключа или Null.
Procedure.l FindKey(Key.s)
	Protected i
	CharLower_(@Key)
	For i=1 To nKeys
		If Keys(i) = Key
			ProcedureReturn i2hkey(i)
		EndIf
	Next
	ProcedureReturn #Null
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Добавить весь путь, возвратить виртуальный хэндл ключа.
; Ключ передаётся без завершающего "\".
; Добавляются все промежуточные ключи для обеспечения enum.
; Возвращается виртуальный дескриптор найденного или созданного ключа или Null.
Procedure.l AddKey(Key.s)
	Protected i, iempty
	Protected p, SubKey.s
	CharLower_(@Key)
	If Key
		Key+"\"
		p = FindString(Key,"\")
		While p
			SubKey.s = Left(Key,p-1)
			; Ищем уже существующий ключ
			For i=1 To nKeys
				If Keys(i) = "" ; пустой элемент массива (удалённый ключ) можно использовать потом
					iempty = i
				ElseIf Keys(i) = SubKey
					Break ; i равен индексу найденного ключа!
				EndIf
			Next
			; После завершения цикла for, i будет равен либо индексу найденного ключа, либо на единицу больше nKeys
			If i > nKeys ; ключ не был найден, добавляем новый
				If iempty ; используем пустой
					Keys(iempty) = SubKey
					i = iempty
				Else ; или добавляем новый
					nKeys = i
					;!inc [v_nKeys]
					ReDim Keys(nKeys)
					Keys(nKeys) = SubKey
				EndIf
				ConfigChanged = #True
			EndIf
			p = FindString(Key,"\",p+1)
		Wend
		ProcedureReturn i2hkey(i)
	EndIf
	ProcedureReturn #Null
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Проверить, наш ли ключ. При необходимости создать. Результат в *phkResult.
; SubKey передаётся в нижнем регистре (через LPeekSZx) и т.п.
Procedure CreateKey(hKey.l,SubKey.s,*phkResult.Long,*Result.Long,*dwDisposition.Long=#Null)
	Protected Key.s
	DbgRegVirt("CreateKey: "+HKey2Str(hKey)+": "+Subkey)
	;DbgRegVirt("CreateKey (+): *phkResult: "+Hex(*phkResult)+" *dwDisposition: "+Hex(*dwDisposition))
	StrTrim_(@SubKey,"\")
	;SubKey = ReplaceString(Trim(SubKey,"\"),"\\","\")
	SubKey = ReplaceString(SubKey,"\\","\")
	If IsKey(hKey)
		Key = GetKey(hKey)
		If Key
			If SubKey
				Key + "\" +SubKey
			EndIf
			If *dwDisposition ; требуется проверка, существует ли ключ или создаётся новый
				hKey = FindKey(Key)
				If hKey
					*dwDisposition\l = #REG_OPENED_EXISTING_KEY
					DbgRegVirt("CreateKey (Disposition): REG_OPENED_EXISTING_KEY")
				Else
					hKey = AddKey(Key)
					*dwDisposition\l = #REG_CREATED_NEW_KEY
					DbgRegVirt("CreateKey (Disposition): REG_CREATED_NEW_KEY")
				EndIf
			Else
				hKey = AddKey(Key)
			EndIf
		EndIf
		*phkResult\l = hKey
		*Result\l = #NO_ERROR
		DbgRegVirt("CreateKey (OUR 1): "+HKey2Str(hKey)+" "+Key)
		ProcedureReturn #True
	EndIf
	Key = CheckKey(hKey,SubKey)
	If Key
		If *dwDisposition ; требуется проверка, существует ли ключ или создаётся новый
			hKey = FindKey(Key)
			If hKey
				*dwDisposition\l = #REG_OPENED_EXISTING_KEY
				DbgRegVirt("CreateKey (Disposition): REG_OPENED_EXISTING_KEY")
			Else
				hKey = AddKey(Key)
				*dwDisposition\l = #REG_CREATED_NEW_KEY
				DbgRegVirt("CreateKey (Disposition): REG_CREATED_NEW_KEY")
			EndIf
		Else
			hKey = AddKey(Key)
		EndIf
		*phkResult\l = hKey
		*Result\l = #NO_ERROR
		DbgRegVirt("CreateKey (OUR 2): "+HKey2Str(hKey)+" "+Key)
		ProcedureReturn #True
	EndIf
	DbgRegVirt("CreateKey (ALIEN): "+HKey2Str(hKey)+" "+SubKey)
	DbgRegAliens(SubKey)
	ProcedureReturn #False
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Проверить, наш ли ключ. Не создавать.
; SubKey передаётся в нижнем регистре (через LPeekSZx) и т.п.
; ASK: Надо ли что-то делать если IsKey(hKey), но в списке его нет? Такого быть не должно, но вдруг?
Procedure OpenKey(hKey.l,SubKey.s,*phkResult.Long,*Result.Long)
	Protected Key.s
	DbgRegVirt("OpenKey: "+HKey2Str(hKey)+" :: "+Subkey)
	;DbgRegVirt("OpenKey (+): *phkResult: "+Hex(*phkResult))
	StrTrim_(@SubKey,"\")
	;SubKey = ReplaceString(Trim(SubKey,"\"),"\\","\")
	SubKey = ReplaceString(SubKey,"\\","\")
	If IsKey(hKey)
		Key = GetKey(hKey)
		If SubKey
			Key + "\" +SubKey
			hKey = FindKey(Key)
		EndIf
		*phkResult\l = hKey
		If hKey = 0 : *Result\l = #ERROR_FILE_NOT_FOUND : EndIf
		DbgRegVirt("OpenKey (OUR 1): "+HKey2Str(hKey)+" "+Key)
		ProcedureReturn #True
	EndIf
	Key = CheckKey(hKey,SubKey)
	If Key
		hKey = FindKey(Key)
		*phkResult\l = hKey
		If hKey = 0 : *Result\l = #ERROR_FILE_NOT_FOUND : EndIf
		DbgRegVirt("OpenKey (OUR 2): "+HKey2Str(hKey)+" "+Key)
		ProcedureReturn #True
	EndIf
	DbgRegVirt("OpenKey (ALIEN): "+HKey2Str(hKey)+" "+SubKey)
	DbgRegAliens(SubKey)
	ProcedureReturn #False
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Записать данные в виртуальный реестр.
; Проверка существования ключа осуществляется из вызывающей функции вызовом IsKey или OpenKey или CreateKey.
; Имя передаётся в нижнем регистре.

; http://w32api.narod.ru/functions/RegSetValue.html
; http://w32api.narod.ru/functions/RegSetValueEx.html

CompilerIf #DETOUR_REG_UNICODE
	Procedure.l SetDataW(hKey.l,sName.s,dwType.l,*lpData.AnyType,cbData.l)
		Protected sData.s, sType.s, sBuf.s
		Protected i, iempty
		If hKey And *lpData
			ConfigChanged = #True
			;CharLower_(@sName) ; в нижний регистр преобразуется при чтении через LPeekSZ*
			For i=1 To nCfg ; ищем уже существующее значение и перезаписываем
				If Cfg(i)\h = 0 And iempty = 0 ; удалённый параметр
					iempty = i
				ElseIf Cfg(i)\h=hKey And Cfg(i)\n=sName ; переписываем параметр
					DbgRegVirt("SetDataW (SET): "+HKey2Str(hKey)+" "+sName+" "+type2str(dwType)+" cb:"+Str(cbData))
					Break
				EndIf
			Next
			; После завершения цикла for, i будет равен либо индексу найденного значения, либо на единицу больше nCfg
			If i > nCfg
				If iempty ; используем пустое
					DbgRegVirt("SetDataW (NEW): "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType)+" cb:"+Str(cbData))
					i = iempty
				Else ; или добавляем
					DbgRegVirt("SetDataW (ADD): "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType)+" cb:"+Str(cbData))
					nCfg = i
					ReDim Cfg(nCfg)
				EndIf
			EndIf
			Cfg(i)\h = hKey
			Cfg(i)\n = sName
			Cfg(i)\t = dwType
			Cfg(i)\c = cbData
			If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
				; Двоичные данные до 4-х байтов помещаем в поле DWORD
				Select cbData
					Case 0
						;Cfg(i)\l = 0
					Case 1
						Cfg(i)\b = *lpData\b
					Case 2
						Cfg(i)\w = *lpData\w
					Case 3
						Cfg(i)\bx\b0 = *lpData\bx\b0 ;Cfg(i)\x[0] = *lpData\x[0]
						Cfg(i)\bx\b1 = *lpData\bx\b1 ;Cfg(i)\x[1] = *lpData\x[1]
						Cfg(i)\bx\b2 = *lpData\bx\b2 ;Cfg(i)\x[2] = *lpData\x[2]
					Default ; 4
						Cfg(i)\l = *lpData\l
				EndSelect
				;DbgRegVirt("SetDataW (DW): cd:"+Str(cfg(i)\c)+" data:"+Str(cfg(i)\l)+" $"+Hex(cfg(i)\l))
				;DbgRegVirt("SetDataW (DW): cd:"+Str(cfg(i)\c)+" data:"+Str(PeekL(*lpData))+" $"+Hex(PeekL(*lpData)))
			ElseIf dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ
				; У строк может отсутствовать завершающий нулевой символ!
				cfg(i)\a = PeekS(*lpData,cbData/2)
				cfg(i)\c = Len(cfg(i)\a)*2+2
				cfg(i)\m = cfg(i)\c
				DbgRegVirt("SetDataW (SZ): "+Cfg(i)\a)
			Else
				; Все остальные данные пересылаем "как есть"
				If Cfg(i)\m <> cbData
					Cfg(i)\a = SpaceB(cbData)
					Cfg(i)\m = cbData
				EndIf
				CopyMemory(*lpData,@Cfg(i)\a,cbData)
			EndIf
		EndIf
		ProcedureReturn #NO_ERROR
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_REG_ANSI
	Procedure.l SetDataA(hKey.l,sName.s,dwType.l,*lpData.AnyType,cbData.l) ; Противоположная кодировка
		Protected sData.s, sType.s, sBuf.s
		Protected i, iempty
		Protected *pb.Byte, *pw.Word, *End
		If hKey And *lpData
			ConfigChanged = #True
			;CharLower_(@sName) ; в нижний регистр преобразуется при чтении через LPeekSZ*
			For i=1 To nCfg ; ищем уже существующее значение и перезаписываем
				If Cfg(i)\h = 0 And iempty = 0 ; удалённый параметр
					iempty = i
				ElseIf Cfg(i)\h=hKey And Cfg(i)\n=sName ; переписываем параметр
					DbgRegVirt("SetDataA (SET): "+HKey2Str(hKey)+" "+sName+" "+type2str(dwType)+" cb:"+Str(cbData))
					Break
				EndIf
			Next
			; После завершения цикла for, i будет равен либо индексу найденного значения, либо на единицу больше nCfg
			If i > nCfg
				If iempty ; используем пустое
					DbgRegVirt("SetDataA (NEW): "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType)+" cb:"+Str(cbData))
					i = iempty
				Else ; или добавляем
					DbgRegVirt("SetDataA (ADD): "+HKey2Str(hKey)+" "+sName+" type:"+type2str(dwType)+" cb:"+Str(cbData))
					nCfg = i
					ReDim Cfg(i)
				EndIf
			EndIf
			Cfg(i)\h = hKey
			Cfg(i)\n = sName
			Cfg(i)\t = dwType
			Cfg(i)\c = cbData
			If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
				; Двоичные данные до 4-х байтов помещаем в поле DWORD
				Select cbData
					Case 0
						;Cfg(i)\l = 0
					Case 1
						Cfg(i)\b = *lpData\b
					Case 2
						Cfg(i)\w = *lpData\w
					Case 3
						Cfg(i)\bx\b0 = *lpData\bx\b0 ;Cfg(i)\x[0] = *lpData\x[0]
						Cfg(i)\bx\b1 = *lpData\bx\b1 ;Cfg(i)\x[1] = *lpData\x[1]
						Cfg(i)\bx\b2 = *lpData\bx\b2 ;Cfg(i)\x[2] = *lpData\x[2]
					Default ; 4
						Cfg(i)\l = *lpData\l
				EndSelect
			ElseIf dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ
				; У строк может отсутствовать завершающий нулевой символ!
				Cfg(i)\a = PeekSZ(*lpData,cbData,#PB_Ascii)
				Cfg(i)\c = Len(Cfg(i)\a)*2+2
				Cfg(i)\m = Cfg(i)\c
				DbgRegVirt("SetDataA (SZ): "+Cfg(i)\a)
			ElseIf dwType=#REG_MULTI_SZ
				; Переносим в промежуточный буфер
				sBuf = SpaceB(cbData)
				CopyMemory(*lpData,@sBuf,cbData)
				; Заменяем нулевой разделитель на Chr(1)
				*pb = @sBuf
				*end = *pb+cbData-1 ; кроме последнего нулевого байта
				While *pb < *end
					If *pb\b = 0
						*pb\b = 1 ;*pb\b+1
					EndIf
					*pb + 1
				Wend
				; Записываем с конвертированием
				; Конечный нулевой символ добавится автоматически
				Cfg(i)\a = PeekS(@sBuf,-1,#PB_Ascii)
				Cfg(i)\c = Len(Cfg(i)\a)*2+2
				Cfg(i)\m = Cfg(i)\c
				; Заменяем Chr(1) на ноль
				*pw = @Cfg(i)\a
				*end = *pw+Cfg(i)\c
				While *pw < *end
					If *pw\w = 1
						*pw\w = 0 ;*pw\w-1
					EndIf
					*pw + 2
				Wend
			Else
				; Все остальные данные пересылаем "как есть"
				If Cfg(i)\m <> cbData
					Cfg(i)\a = SpaceB(cbData)
					Cfg(i)\m = cbData
				EndIf
				CopyMemory(*lpData,@Cfg(i)\a,cbData)
			EndIf
		EndIf
		ProcedureReturn #NO_ERROR
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Получить данные из виртуального реестра.
; Проверка существования ключа осуществляется из вызывающей функции вызовом IsKey или OpenKey или CreateKey.

; https://learn.microsoft.com/ru-ru/windows/win32/api/winreg/nf-winreg-reggetvaluea
; TODO: dwFlags, RRF_NOEXPAND, RRF_ZEROONFAILURE, RRF_RT_REG_EXPAND_S

; MSDN:
; lpcbData - Адрес переменной, указывающей размер в байтах буфера, на который ссылается параметр lpData.
; Когда функция возвращается, эта переменная содержит размер данных, скопированных в lpData.
; Если буфер, указанный в параметре lpData, слишком мал для данных,
; то функция возвращает ERROR_MORE_DATA, и помещает нужный размер в переменную, на которую ссылается lpcbData.
; Если lpData равен NULL, и lpcbData не равен NULL, функция возвращает NO_ERROR,
; и помещает размер данных, в байтах, в переменную, на которую указывает lpcbData.
; Это позволяет приложению выбрать лучший способ выделения памяти для данных значения ключа.
; Если данные имеют тип REG_SZ, REG_MULTI_SZ или REG_EXPAND_SZ, тогда cbData содержит размер с учетом нулевого завершающего символа.

CompilerIf #DETOUR_REG_UNICODE
	Procedure.l GetDataW(hKey.l,sName.s,*lpType.Long,*lpData.AnyType,*lpcbData.Long,rrfFlags=0)
		Protected i, cbData.l, dwType.l, cbDataReq.l
		If hKey
			;CharLower_(@sName) ; в нижний регистр преобразуется при чтении через LPeekSZ*
			For i=1 To nCfg
				If Cfg(i)\h=hKey And Cfg(i)\n=sName
					cbData = Cfg(i)\c
					dwType = Cfg(i)\t
					DbgRegVirt("GetDataW: "+sName+" type:"+type2str(dwType))
					DbgRegVirt("GetDataW: *lpType:"+Hex(*lpType)+" *lpData:"+Hex(*lpData)+" *lpcbData:"+Hex(*lpcbData))
					If *lpcbData : cbDataReq = *lpcbData\l : EndIf
					If *lpType : *lpType\l = dwType : EndIf
					If *lpData
						If cbDataReq < cbData ; не хватает места!
							DbgRegVirt("GetDataW (ERROR_MORE_DATA) len:"+Str(cbDataReq)+" need:"+Str(cbData))
							If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
								*lpcbData\l = cbData+2 ; +1 лишний символ (2 байта)
							Else
								*lpcbData\l = cbData
							EndIf
							ProcedureReturn #ERROR_MORE_DATA
						EndIf
						DbgRegVirt("GetDataW (data): "+sName+" cb:"+Str(cbData))
						*lpcbData\l = cbData
						If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
							; Двоичные данные до 4-х байтов
							Select cbData
								Case 0
									; Ничего не делаем
								Case 1
									*lpData\b = Cfg(i)\b
								Case 2
									*lpData\w = Cfg(i)\w
								Case 3
									*lpData\bx\b0 = Cfg(i)\bx\b0 ;*lpData\x[0] = Cfg(i)\x[0]
									*lpData\bx\b1 = Cfg(i)\bx\b1 ;*lpData\x[1] = Cfg(i)\x[1]
									*lpData\bx\b2 = Cfg(i)\bx\b2 ;*lpData\x[2] = Cfg(i)\x[2]
								Default ; 4
									*lpData\l = Cfg(i)\l
							EndSelect
						Else
							; Все остальные данные записываем "как есть"
							;DbgRegVirt("CopyMemory "+Str(@Cfg(i)\a)+" "+Str(*lpData))
							CopyMemory(@Cfg(i)\a,*lpData,cbData)
						EndIf
					ElseIf *lpcbData
						; Если *lpData имеет значение NULL, а *lpcbData — не NULL,
						; функция возвращает ERROR_SUCCESS и сохраняет размер данных в байтах в переменной, на которую указывает *lpcbData.
						DbgRegVirt("GetDataW (len): "+sName+" cb:"+Str(cbData))
						If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
							*lpcbData\l = cbData+2 ; +1 лишний символ (2 байта)
						Else
							*lpcbData\l = cbData
						EndIf
					EndIf
					ProcedureReturn #NO_ERROR
				EndIf
			Next
		EndIf
		ProcedureReturn #ERROR_FILE_NOT_FOUND
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_REG_ANSI
	Procedure.l GetDataA(hKey.l,sName.s,*lpType.Long,*lpData.AnyType,*lpcbData.Long,rrfFlags=0)
		Protected i, cbData.l, dwType.l, cbDataReq.l
		Protected sBuf.s
		Protected *pb.Byte, *pw.Word, *End
		If hKey
			;CharLower_(@sName) ; в нижний регистр преобразуется при чтении через LPeekSZ*
			For i=1 To nCfg
				If Cfg(i)\h=hKey And Cfg(i)\n=sName
					dwType = Cfg(i)\t
					DbgRegVirt("GetDataA: "+sName+" type:"+type2str(dwType))
					DbgRegVirt("GetDataA: *lpType:"+Hex(*lpType)+" *lpData:"+Hex(*lpData)+" *lpcbData:"+Hex(*lpcbData))
					If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
						; Так как юникод, строки реально занимают в два раза больше места, чем требуется. И наоборот.
						cbData = (Cfg(i)\c+1)/2 ; С округлением в большую сторону
					Else
						cbData = Cfg(i)\c
					EndIf
					If *lpcbData : cbDataReq = *lpcbData\l : EndIf
					If *lpType : *lpType\l = dwType : EndIf
					If *lpData
						If cbDataReq < cbData ; не хватает места!
							DbgRegVirt("GetDataA (ERROR_MORE_DATA) len:"+Str(cbDataReq)+" need:"+Str(cbData))
							If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
								*lpcbData\l = cbData+1 ; +1 лишний символ
							Else
								*lpcbData\l = cbData
							EndIf
							ProcedureReturn #ERROR_MORE_DATA
						EndIf
						DbgRegVirt("GetDataA (data): "+sName+" cb:"+Str(cbData))
						*lpcbData\l = cbData
						If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
							; Двоичные данные до 4-х байтов
							Select cbData
								Case 0
									; Ничего не делаем?
								Case 1
									*lpData\b = Cfg(i)\b
								Case 2
									*lpData\w = Cfg(i)\w
								Case 3
									*lpData\bx\b0 = Cfg(i)\bx\b0 ;*lpData\x[0] = Cfg(i)\x[0]
									*lpData\bx\b1 = Cfg(i)\bx\b1 ;*lpData\x[1] = Cfg(i)\x[1]
									*lpData\bx\b2 = Cfg(i)\bx\b2 ;*lpData\x[2] = Cfg(i)\x[2]
								Default ; 4
									*lpData\l = Cfg(i)\l
							EndSelect
						ElseIf dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ
							DbgRegVirt("GetDataA (sz): "+Cfg(i)\a)
							PokeS(*lpData,Cfg(i)\a,-1,#PB_Ascii)
							DbgRegVirt("GetDataA (sz): "+PeekS(*lpData,-1,#PB_Ascii))
						ElseIf dwType=#REG_MULTI_SZ
							; Переносим в промежуточный буфер
							; Не используем cbData!
							sBuf = SpaceB(Cfg(i)\c)
							CopyMemory(@Cfg(i)\a,@sBuf,Cfg(i)\c)
							; Заменяем нулевой разделитель на Chr(1)
							*pw = @sBuf
							*end = *pw+Cfg(i)\c-2 ; кроме последнего нулевого символа
							While *pw < *end
								If *pw\w = 0
									*pw\w = 1 ; *pw\w+1
								EndIf
								*pw + 2
							Wend
							; Записываем с конвертированием
							; Дополнительный нулевой символ добавится автоматически
							PokeS(*lpData,sBuf,-1,#PB_Ascii)
							; Заменяем Chr(1) на ноль
							*pb = *lpData
							*end = *pb+cbData
							While *pb < *end
								If *pb\b = 1
									*pb\b = 0 ;*pb\b-1
								EndIf
								*pb + 1
							Wend
						Else
							; Все остальные данные записываем "как есть"
							CopyMemory(@Cfg(i)\a,*lpData,cbData)
						EndIf
					ElseIf *lpcbData
						DbgRegVirt("GetDataA (len): "+sName+" cb:"+Str(cbData))
						If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
							*lpcbData\l = cbData+1 ; +1 лишний символ
						Else
							*lpcbData\l = cbData
						EndIf
					EndIf
					ProcedureReturn #NO_ERROR
				EndIf
			Next
		EndIf
		ProcedureReturn #ERROR_FILE_NOT_FOUND
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; Перечисление данных в ключе.
; Проверка существования ключа осуществляется из вызывающей функции вызовом IsKey или OpenKey или CreateKey.

; ASK: ERROR_MORE_DATA

; https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms724861(v=vs.85).aspx RegEnumKey
; RegEnumKeyA(hKey.l,dwIndex.l,*lpName,cbName.l)
; https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms724862(v=vs.85).aspx RegEnumKeyEx
; RegEnumKeyExA(hKey.l,dwIndex.l,*lpName,*lpcbName.Long,*lpReserved.Long,*lpClass,*lpcbClass.Long,*lpftLastWriteTime.FILETIME)

; http://w32api.narod.ru/functions/RegEnumKey.html
; http://w32api.narod.ru/functions/RegEnumKeyEx.html

; lpName - Адрес буфера, в который возвращается имя подключа, включая нулевой заканчивающий символ.
; Эта функция копирует в буфер только имя подключа, а не полную иерархию ключа.

; cbName - Указывает размер, в символах, буфера на который адресуется параметр lpName.
; Для определения требуемого размера буфера, используйте функцию RegQueryInfoKey,
; чтобы определить наибольший размер имени подключа, указанного в параметре hKey.
; Максимальный требуемый размер буфера это (MAX_PATH + 1) символов.

CompilerIf #DETOUR_REG_UNICODE
	Procedure.l EnumKeyW(hKey.l,dwIndex.l,*lpName,*lpcbName.Long)
		Protected i
		Protected Index.l = 0
		Protected NameLen.l, sName.s
		Protected sKey.s = GetKey(hKey)
		DbgRegVirt("EnumKeyW: "+sKey)
		; Ищем строки вида Key\SubKey
		For i=1 To nKeys
			Protected sIKey.s = Keys(i)
			Protected p = FindStringReverse(sIKey,"\")
			If p And Left(sIKey,p-1) = sKey
				If Index = dwIndex ; запись с нужным индексом
					sName = Mid(sIKey,p+1)
					NameLen = Len(sName)
					DbgRegVirt("EnumKeyW: index: "+Str(Index)+" name: "+sName)
					If *lpcbName\l < NameLen+1 ; нет места
						DbgRegVirt("EnumKeyW (ERROR_MORE_DATA): namelen: "+Str(NameLen))
						*lpcbName\l = NameLen+2 ; +2 лишних байта
						ProcedureReturn #ERROR_MORE_DATA
					EndIf
					PokeS(*lpName,sName)
					*lpcbName\l = NameLen
					ProcedureReturn #NO_ERROR
				EndIf
				Index + 1
			EndIf
		Next
		ProcedureReturn #ERROR_NO_MORE_ITEMS
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_REG_ANSI
	Procedure.l EnumKeyA(hKey.l,dwIndex.l,*lpName,*lpcbName.Long)
		Protected i
		Protected Index.l = 0
		Protected NameLen.l, sName.s
		Protected sKey.s = GetKey(hKey)
		DbgRegVirt("EnumKeyA: "+sKey)
		; Ищем строки вида Key\SubKey
		For i=1 To nKeys
			Protected sIKey.s = Keys(i)
			Protected p = FindStringReverse(sIKey,"\")
			If p And Left(sIKey,p-1) = sKey
				If Index = dwIndex ; запись с нужным индексом
					sName = Mid(sIKey,p+1)
					NameLen = Len(sName)
					DbgRegVirt("EnumKeyA: index: "+Str(Index)+" name: "+sName)
					If *lpcbName\l < NameLen+1 ; нет места
						DbgRegVirt("EnumKeyA (ERROR_MORE_DATA): namelen: "+Str(NameLen))
						*lpcbName\l = NameLen
						ProcedureReturn #ERROR_MORE_DATA
					EndIf
					PokeS(*lpName,sName,-1,#PB_Ascii)
					*lpcbName\l = NameLen
					ProcedureReturn #NO_ERROR
				EndIf
				Index + 1
			EndIf
		Next
		ProcedureReturn #ERROR_NO_MORE_ITEMS
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------

; https://learn.microsoft.com/ru-ru/windows/desktop/api/winreg/nf-winreg-regenumvaluea
; http://w32api.narod.ru/functions/RegEnumValue.html

; dwIndex - Указывает индекс затребованного значения. Его значение должно быть нулевым для первого вызова функции RegEnumValue
; и инкрементироваться для последующих вызовов.

; lpValueName - Адрес буфера, в который возвращается имя значения, включая и завершающий нулевой символ.

; lpcbValueName - Указывает размер, в символах, буфера на который адресуется параметр lpValueName.
; Этот размер должен учитывать и нулевой символ – признак завершения строки.
; Когда функция возвращается, переменная, на которую указывает lpcbValueName, содержит количество символов,
; записанных в буфер. Возвращенное число не учитывает нулевой символ завершения строки.

CompilerIf #DETOUR_REG_UNICODE
	Procedure.l EnumDataW(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpType.Long,*lpData.AnyType,*lpcbData.Long)
		Protected i, Index.l = 0
		Protected ValueNameLen.l, sValueName.s, cbData.l, dwType.l
		DbgRegVirt("EnumDataW: "+HKey2Str(hKey)+" "+GetKey(hKey))
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n
				If Index = dwIndex ; запись с нужным индексом
					sValueName = Cfg(i)\n
					cbData = Cfg(i)\c
					dwType = Cfg(i)\t
					ValueNameLen = Len(sValueName) ; количество символов в имени (не байт!)
					DbgRegVirt("EnumDataW: index: "+Str(dwIndex)+" name: "+sValueName)
					If *lpcbValueName\l < ValueNameLen+1 ; нет места для имени
						DbgRegVirt("EnumDataW (ERROR_MORE_DATA): namelen: "+Str(ValueNameLen))
						*lpcbValueName\l = ValueNameLen
						ProcedureReturn #ERROR_MORE_DATA
					EndIf
					*lpcbValueName\l = ValueNameLen
					PokeS(*lpValueName,sValueName)
					If *lpType : *lpType\l = dwType: EndIf
					If *lpData
						If *lpcbData\l < cbData ; не хватает места!
							DbgRegVirt("EnumDataW (ERROR_MORE_DATA): len:"+Str(*lpcbData\l)+" need:"+Str(cbData))
							*lpcbData\l = cbData+2 ; +2 лишних байта
							ProcedureReturn #ERROR_MORE_DATA
						EndIf
						DbgRegVirt("EnumDataW: "+Cfg(i)\n)
						*lpcbData\l = cbData
						If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
							; Двоичные данные до 4-х байтов
							Select cbData
								Case 0
									; Ничего не делаем
								Case 1
									*lpData\b = Cfg(i)\b
								Case 2
									*lpData\w = Cfg(i)\w
								Case 3
									*lpData\bx\b0 = Cfg(i)\bx\b0 ;*lpData\x[0] = Cfg(i)\x[0]
									*lpData\bx\b1 = Cfg(i)\bx\b1 ;*lpData\x[1] = Cfg(i)\x[1]
									*lpData\bx\b2 = Cfg(i)\bx\b2 ;*lpData\x[2] = Cfg(i)\x[2]
								Default ; 4
									*lpData\l = Cfg(i)\l
							EndSelect
						Else
							; Все остальные данные записываем "как есть"
							CopyMemory(@Cfg(i)\a,*lpData,cbData)
						EndIf
					ElseIf *lpcbData
						DbgRegVirt("EnumDataW (len): "+Cfg(i)\n+" cb:"+Str(cbData))
						*lpcbData\l = cbData
					EndIf
					ProcedureReturn #NO_ERROR
				EndIf
				Index + 1
			EndIf
		Next
		ProcedureReturn #ERROR_NO_MORE_ITEMS
	EndProcedure
CompilerEndIf
CompilerIf #DETOUR_REG_ANSI
	Procedure.l EnumDataA(hKey.l,dwIndex.l,*lpValueName,*lpcbValueName.Long,*lpType.Long,*lpData.AnyType,*lpcbData.Long)
		Protected i, Index.l = 0
		Protected ValueNameLen.l, sValueName.s, cbData.l, dwType.l
		Protected *pb.Byte, *pw.Word, *End
		Protected sBuf.s
		DbgRegVirt("EnumDataA: "+HKey2Str(hKey)+" "+GetKey(hKey))
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n
				If Index = dwIndex ; запись с нужным индексом
					sValueName = Cfg(i)\n
					dwType = Cfg(i)\t
					ValueNameLen = Len(sValueName) ; количество символов в имени (не байт!)
					DbgRegVirt("EnumDataA: index: "+Str(dwIndex)+" name: "+sValueName)
					If *lpcbValueName\l < ValueNameLen+1 ; нет места для имени
						DbgRegVirt("EnumDataA (ERROR_MORE_DATA): namelen: "+Str(ValueNameLen))
						*lpcbValueName\l = ValueNameLen
						ProcedureReturn #ERROR_MORE_DATA
					EndIf
					*lpcbValueName\l = ValueNameLen
					PokeS(*lpValueName,sValueName,-1,#PB_Ascii)
					If dwType=#REG_SZ Or dwType=#REG_MULTI_SZ Or dwType=#REG_EXPAND_SZ
						; Компилится в юникод, поэтому строки реально занимают в два раза больше места, чем требуется.
						cbData = (Cfg(i)\c+1)/2+1 ; +1 лишний байт
					Else
						cbData = Cfg(i)\c
					EndIf
					If *lpType : *lpType\l = dwType : EndIf
					If *lpData
						If *lpcbData\l < cbData ; не хватает места!
							DbgRegVirt("EnumDataA (ERROR_MORE_DATA): len:"+Str(*lpcbData\l)+" need:"+Str(cbData))
							*lpcbData\l = cbData
							ProcedureReturn #ERROR_MORE_DATA
						EndIf
						DbgRegVirt("EnumDataA: "+Cfg(i)\n)
						*lpcbData\l = cbData
						If (dwType=#REG_DWORD Or dwType=#REG_BINARY) And cbData<=4
							; Двоичные данные до 4-х байтов
							Select Cfg(i)\c
								Case 0
									; Ничего не делаем?
								Case 1
									*lpData\b = Cfg(i)\b
								Case 2
									*lpData\w = Cfg(i)\w
								Case 3
									*lpData\bx\b0 = Cfg(i)\bx\b0 ;*lpData\x[0] = Cfg(i)\x[0]
									*lpData\bx\b1 = Cfg(i)\bx\b1 ;*lpData\x[1] = Cfg(i)\x[1]
									*lpData\bx\b2 = Cfg(i)\bx\b2 ;*lpData\x[2] = Cfg(i)\x[2]
								Default ; 4
									*lpData\l = Cfg(i)\l
							EndSelect
						ElseIf dwType=#REG_SZ Or dwType=#REG_EXPAND_SZ
							PokeS(*lpData,Cfg(i)\a,-1,#PB_Ascii)
						ElseIf dwType=#REG_MULTI_SZ
							; Переносим в промежуточный буфер
							; Не используем cbData!
							sBuf = SpaceB(Cfg(i)\c)
							CopyMemory(@Cfg(i)\a,@sBuf,Cfg(i)\c)
							; Заменяем нулевой разделитель на Chr(1)
							*pw = @sBuf
							*end = *pw+Cfg(i)\c-2 ; кроме последнего нулевого символа
							While *pw < *end
								If *pw\w = 0
									*pw\w = 1 ; *pw\w+1
								EndIf
								*pw + 2
							Wend
							; Записываем с конвертированием
							; Дополнительный нулевой символ добавится автоматически
							PokeS(*lpData,sBuf,-1,#PB_Ascii)
							; Заменяем Chr(1) на ноль
							*pb = *lpData
							*end = *pb+cbData
							While *pb < *end
								If *pb\b = 1
									*pb\b = 0 ;*pb\b-1
								EndIf
								*pb + 1
							Wend
						Else
							; Все остальные данные записываем "как есть"
							CopyMemory(@Cfg(i)\a,*lpData,cbData)
						EndIf
					ElseIf *lpcbData
						DbgRegVirt("EnumDataA (len):"+Cfg(i)\n+" cb:"+Str(cbData))
						*lpcbData\l = cbData
					EndIf
					ProcedureReturn #NO_ERROR
				EndIf
				Index + 1
			EndIf
		Next
		ProcedureReturn #ERROR_NO_MORE_ITEMS
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------

; TODO: Для ansi функций из-под unicode *lpcMaxValueLen будет завышаться (?)

; https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms724902(v=vs.85).aspx
; http://w32api.narod.ru/functions/RegQueryInfoKey.html

; pcbMaxSubKeyLen - Адрес переменной, в которую возвращается длина, в символах, наибольшего имени подключа. Этот параметр может быть NULL.
; lpcbMaxClassLen - Адрес переменной, в которую возвращается длина, в символах, наибольшего имени класса ключа. Этот параметр может быть NULL.
; lpcValues - Адрес переменной, в которую возвращается количество значений, ассоциирующихся с ключом. Этот параметр может быть NULL.
; lpcbMaxValueNameLen - Адрес переменной, в которую возвращается длина, в символах, наибольшего имени значения. Этот параметр может быть NULL.
; lpcbMaxValueLen - Адрес переменной, в которую возвращается длина, в байтах, наибольшего компонента среди значениий ключа. Этот параметр может быть NULL.

Procedure.l KeyInfo(hKey.l,*lpClass,*lpcbClass,*lpcSubKeys.Long,*lpcMaxSubKeyLen.Long,*lpcMaxClassLen.Long,*lpcValues.Long,*lpcMaxValueNameLen.Long,*lpcMaxValueLen.Long)
	Protected i, p, sIKey.s, lenSubKey
	Protected cSubKeys.l, cMaxSubKeyLen.l, cValues.l, cMaxValueNameLen.l, cMaxValueLen.l
	Protected sKey.s = GetKey(hKey)
	DbgRegVirt("KeyInfo: "+sKey)
	If *lpcSubKeys Or *lpcMaxSubKeyLen
		; Подсчёт количества подключей и их максимальную длину
		; Ищем строки вида Key\SubKey, где Key это обрабатываемый ключ и SubKey не содержит "\"
		For i=1 To nKeys
			sIKey = Keys(i)
			p = FindStringReverse(sIKey,"\")
			If p And Left(sIKey,p-1) = sKey
				cSubKeys+1
				lenSubKey = Len(Mid(sIKey,p+1))
				If lenSubKey > cMaxSubKeyLen
					cMaxSubKeyLen = lenSubKey
				EndIf
			EndIf
		Next
		If *lpcSubKeys
			DbgRegVirt("KeyInfo: cSubKeys: "+Str(cSubKeys))
			*lpcSubKeys\l = cSubKeys
		EndIf
		If *lpcMaxSubKeyLen
			DbgRegVirt("KeyInfo: cMaxSubKeyLen: "+Str(cMaxSubKeyLen))
			*lpcMaxSubKeyLen\l = cMaxSubKeyLen
		EndIf
	EndIf
	If *lpcMaxClassLen : *lpcMaxClassLen\l = 0 : EndIf
	If *lpcValues Or *lpcMaxValueNameLen Or *lpcMaxValueLen ; подсчёт количества значений, макс. длину имени и данных
		For i=1 To nCfg
			If Cfg(i)\h=hKey
				cValues+1
				If Len(Cfg(i)\n) > cMaxValueNameLen
					cMaxValueNameLen = Len(Cfg(i)\n)
				EndIf
				If Cfg(i)\c > cMaxValueLen
					cMaxValueLen = Cfg(i)\c
				EndIf
			EndIf
		Next
		If *lpcValues
			DbgRegVirt("KeyInfo: cValues: "+Str(cValues))
			*lpcValues\l = cValues
		EndIf
		If *lpcMaxValueNameLen
			DbgRegVirt("KeyInfo: cMaxValueNameLen: "+Str(cMaxValueNameLen))
			*lpcMaxValueNameLen\l = cMaxValueNameLen
		EndIf
		If *lpcMaxValueLen
			DbgRegVirt("KeyInfo: cMaxValueLen: "+Str(cMaxValueLen))
			*lpcMaxValueLen\l = cMaxValueLen
		EndIf
	EndIf
	ProcedureReturn #NO_ERROR
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
; Возвращаемый результат: наш или не наш ключ, для удобства проверки.
Procedure.l DelKey(hKey.l,SubKey.s,*Result.Long)
	Protected ik, ic, vKey.l
	Protected Key.s, CmpKey.s, lenCmpKey
	StrTrim_(@SubKey,"\")
	;SubKey = Trim(ReplaceString(SubKey,"\\","\"),"\")
	SubKey = ReplaceString(SubKey,"\\","\")
	If IsKey(hKey) ; для виртуального дискриптора формируем полный путь
		Key = GetKey(hKey)
		If SubKey : Key+"\"+SubKey : EndIf
	Else ; либо проверяем ключ наш/не наш
		Key = CheckKey(hKey,SubKey)
	EndIf
	DbgRegVirt("DelKey: "+HKey2Str(hKey)+" "+Key+" :: "+SubKey)
	If Key
		If FindKey(Key)
			CmpKey.s = Key + "\"
			lenCmpKey = Len(CmpKey)
			For ik=1 To nKeys ; ищем все подключи и сам ключ
				If Keys(ik) = Key Or Left(Keys(ik),lenCmpKey) = CmpKey
					DbgRegVirt("DelKey: Sub: "+Keys(ik))
					ConfigChanged = #True
					vKey = i2hkey(ik) ; виртуальный хэндл удаляемого подключа
					For ic=1 To nCfg ; ищем и удаляем значения связанные с удаляемым ключом
						If Cfg(ic)\h = vKey
							DbgRegVirt("DelKey: Val: "+Cfg(ic)\n)
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
			*Result\l = #NO_ERROR
		Else
			*Result\l = #ERROR_FILE_NOT_FOUND
		EndIf
		ProcedureReturn #True
	EndIf
	DbgRegAliens(SubKey)
	ProcedureReturn #False
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
Procedure.l DelData(hKey.l,sName.s,*Result.Long)
	Protected i
	If IsKey(hKey)
		For i=1 To nCfg
			If Cfg(i)\h=hKey And Cfg(i)\n=sName
				ConfigChanged = #True
				Cfg(i)\h = 0
				Cfg(i)\c = 0
				Cfg(i)\m = 0
				Cfg(i)\l = 0
				Cfg(i)\n = ""
				Cfg(i)\a = ""
				*Result\l = #NO_ERROR
				ProcedureReturn #True
			EndIf
		Next
		*Result\l = #ERROR_FILE_NOT_FOUND
	EndIf
	ProcedureReturn #False
EndProcedure
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_SHDELETEEMPTYKEYA Or #DETOUR_SHDELETEEMPTYKEYW
	Procedure IsEmptyKey(sKey.s)
		Protected i
		sKey + "\"
		Protected l = Len(sKey)
		For i=1 To nKeys
			If Left(Keys(i),l) = sKey
				ProcedureReturn #False
			EndIf
		Next
		Protected hKey = FindKey(sKey)
		For i=1 To nCfg
			If Cfg(i)\h = hKey
				ProcedureReturn #False
			EndIf
		Next
		ProcedureReturn #True
	EndProcedure
CompilerEndIf
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; Folding = CAA-
; EnableThread
; DisableDebugger
; EnableExeConstant