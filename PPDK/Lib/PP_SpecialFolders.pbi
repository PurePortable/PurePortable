;;======================================================================================================================
; Портабелизация папок
;;======================================================================================================================
; TODO:
; - GetAllUsersProfileDirectoryA(lpProfileDir,lpcchSize)
; - GetAllUsersProfileDirectoryW(lpProfileDir,lpcchSize)
;;======================================================================================================================

Global ProfileRedir.s
Global AppDataRedir.s
Global LocalAppDataRedir.s
Global LocalLowAppDataRedir.s
Global DocumentsRedir.s
Global PublicRedir.s
Global CommonAppDataRedir.s
Global CommonDocumentsRedir.s
Global TempRedir.s

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf Not Defined(DETOUR_SHFOLDER,#PB_Constant) : #DETOUR_SHFOLDER = 0 : CompilerEndIf
CompilerIf Not Defined(DETOUR_USERENV,#PB_Constant) : #DETOUR_USERENV = 0 : CompilerEndIf
CompilerIf Defined(PORTABLE_USERENV,#PB_Constant) : #DETOUR_USERENV = #PORTABLE_USERENV : CompilerEndIf

CompilerIf #PROXY_DLL_COMPATIBILITY<>0 And #PROXY_DLL_COMPATIBILITY<6 ; Vista, 2008
	#DETOUR_SHGETKNOWNFOLDERPATH = 0
	#DETOUR_SHGETFOLDERPATHEX = 0
	#DETOUR_SHGETKNOWNFOLDERIDLIST = 0
CompilerEndIf

CompilerIf Not Defined(DETOUR_SHGETKNOWNFOLDERPATH,#PB_Constant) : #DETOUR_SHGETKNOWNFOLDERPATH = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETFOLDERPATHEX,#PB_Constant) : #DETOUR_SHGETFOLDERPATHEX = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETKNOWNFOLDERIDLIST,#PB_Constant) : #DETOUR_SHGETKNOWNFOLDERIDLIST = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETFOLDERPATH,#PB_Constant) : #DETOUR_SHGETFOLDERPATH = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETFOLDERPATHANDSUBDIR,#PB_Constant) : #DETOUR_SHGETFOLDERPATHANDSUBDIR = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETSPECIALFOLDERPATH,#PB_Constant) : #DETOUR_SHGETSPECIALFOLDERPATH = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETFOLDERLOCATION,#PB_Constant) : #DETOUR_SHGETFOLDERLOCATION = 1 : CompilerEndIf
CompilerIf Not Defined(DETOUR_SHGETSPECIALFOLDERLOCATION,#PB_Constant) : #DETOUR_SHGETSPECIALFOLDERLOCATION = 1 : CompilerEndIf

CompilerIf #DETOUR_SHGETFOLDERPATH Or #DETOUR_SHGETFOLDERPATHANDSUBDIR Or #DETOUR_SHGETSPECIALFOLDERPATH
	#CSIDL2PATH = 1
CompilerElse
	#CSIDL2PATH = 0
CompilerEndIf
CompilerIf #DETOUR_SHGETFOLDERLOCATION Or #DETOUR_SHGETSPECIALFOLDERLOCATION
	#CSIDL2PIDL = 1
CompilerElse
	#CSIDL2PIDL = 0
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DBG_SPECIAL_FOLDERS And Not Defined(DBG_ALWAYS,#PB_Constant)
	#DBG_ALWAYS = 1
CompilerEndIf
CompilerIf #DBG_SPECIAL_FOLDERS
	;UndefineMacro DbgAny : DbgAnyDef
	Global DbgSpecMode = #DBG_SPECIAL_FOLDERS
	Procedure DbgSpec(txt.s)
		If DbgSpecMode
			dbg(txt)
		EndIf
	EndProcedure
CompilerElse
	Macro DbgSpec(txt) : EndMacro
CompilerEndIf
CompilerIf #DBG_SPECIAL_FOLDERS And (#PROXY_DLL_COMPATIBILITY=0 Or #PROXY_DLL_COMPATIBILITY>5)
	XIncludeFile "Proc\guid2s.pbi"
	Procedure DbgKfid(func.s,kfid,path.s="")
		If DbgSpecMode
			If path : path = ": «"+path+"»" : EndIf
			If CompareMemory(kfid,?FOLDERID_Profile,16)
				DbgSpec(func+": "+guid2s(kfid)+" (Profile)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_RoamingAppData,16)
				DbgSpec(func+": "+guid2s(kfid)+" (AppData)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_LocalAppData,16)
				DbgSpec(func+": "+guid2s(kfid)+" (LocalAppData)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_LocalLowAppData,16)
				DbgSpec(func+": "+guid2s(kfid)+" (LocalLowAppData)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_Documents,16)
				DbgSpec(func+": "+guid2s(kfid)+" (Documents)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_ProgramData,16)
				DbgSpec(func+": "+guid2s(kfid)+" (CommonAppData)"+path)
			ElseIf CompareMemory(kfid,?FOLDERID_PublicDocuments,16)
				DbgSpec(func+": "+guid2s(kfid)+" (CommonDocuments)"+path)
			Else
				DbgSpec(func+": "+guid2s(kfid)+path)
			EndIf
		EndIf
	EndProcedure
CompilerElse
	Macro DbgKfid(func,kfid,path="") : EndMacro
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
#CSIDL_ID_MASK = ~#CSIDL_FLAG_MASK
; https://learn.microsoft.com/en-us/windows/win32/shell/csidl
CompilerIf #DBG_SPECIAL_FOLDERS
	Procedure.s csidl2s(csidl)
		Protected Result.s
		Select csidl & #CSIDL_ID_MASK
			Case #CSIDL_PROFILE
				Result = "CSIDL_PROFILE"
			Case #CSIDL_APPDATA
				Result = "CSIDL_APPDATA"
			Case #CSIDL_LOCAL_APPDATA
				Result = "CSIDL_LOCAL_APPDATA"
			Case #CSIDL_PERSONAL
				Result = "CSIDL_PERSONAL"
			Case #CSIDL_MYDOCUMENTS
				Result = "CSIDL_MYDOCUMENTS"
			Case #CSIDL_COMMON_APPDATA
				Result = "CSIDL_COMMON_APPDATA"
			Case #CSIDL_COMMON_DOCUMENTS
				Result = "CSIDL_COMMON_DOCUMENTS"
			Default
				Result = "CSIDL_0x"+HexL(csidl)
		EndSelect
		ProcedureReturn Result
	EndProcedure
CompilerElse
	Macro csidl2s(csidl) : EndMacro
CompilerEndIf

;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_SHGETKNOWNFOLDERPATH Or #DETOUR_SHGETFOLDERPATHEX Or #DETOUR_SHGETKNOWNFOLDERIDLIST
	Declare.s CheckKFID(kfid)
	Macro CheckRFID : CheckKFID : EndMacro ; для совместимости
	Procedure.s kfid2path(kfid)
		If CompareMemory(kfid,?FOLDERID_Profile,16) And ProfileRedir
			DbgSpec("kfid2path: "+ProfileRedir)
			ProcedureReturn ProfileRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_RoamingAppData,16) And AppDataRedir
			DbgSpec("kfid2path: "+AppDataRedir)
			ProcedureReturn AppDataRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_LocalAppData,16) And LocalAppDataRedir
			DbgSpec("kfid2path: "+LocalAppDataRedir)
			ProcedureReturn LocalAppDataRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_LocalLowAppData,16) And LocalLowAppDataRedir
			DbgSpec("kfid2path: "+LocalLowAppDataRedir)
			ProcedureReturn LocalLowAppDataRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_Documents,16) And DocumentsRedir
			DbgSpec("kfid2path: "+DocumentsRedir)
			ProcedureReturn DocumentsRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_ProgramData,16) And CommonAppDataRedir
			DbgSpec("kfid2path: "+CommonAppDataRedir)
			ProcedureReturn CommonAppDataRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_Public,16) And PublicRedir
			DbgSpec("kfid2path: "+PublicRedir)
			ProcedureReturn PublicRedir
		EndIf
		If CompareMemory(kfid,?FOLDERID_PublicDocuments,16) And CommonDocumentsRedir
			DbgSpec("kfid2path: "+CommonDocumentsRedir)
			ProcedureReturn CommonDocumentsRedir
		EndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			Protected path.s = CheckKFID(kfid)
			DbgSpec("CheckKFID: "+path)
			ProcedureReturn path
		CompilerElse
			ProcedureReturn CheckKFID(kfid)
		CompilerEndIf
	EndProcedure
	;{ Folder Id Guids
	DataSection ; https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid
		FOLDERID_ProgramData: ; {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
		Data.l $62AB5D82
		Data.w $FDC1,$4DC3
		Data.b $A9,$DD,$07,$0D,$1D,$49,$5D,$97

		FOLDERID_Public: ; {DFDF76A2-C82A-4D63-906A-5644AC457385}
		Data.l $DFDF76A2
		Data.w $C82A,$4D63
		Data.b $90,$6A,$56,$44,$AC,$45,$73,$85

		FOLDERID_PublicDocuments: ; {ED4824AF-DCE4-45A8-81E2-FC7965083634}
		Data.l $ED4824AF
		Data.w $DCE4,$45A8
		Data.b $81,$E2,$FC,$79,$65,$08,$36,$34

		FOLDERID_Documents: ; {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
		Data.l $FDD39AD0
		Data.w $238F,$46AF
		Data.b $AD,$B4,$6C,$85,$48,$03,$69,$C7

		FOLDERID_RoamingAppData: ; {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
		Data.l $3EB685DB
		Data.w $65F9,$4CF6
		Data.b $A0,$3A,$E3,$EF,$65,$72,$9F,$3D

		FOLDERID_LocalAppData: ; {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
		Data.l $F1B32785
		Data.w $6FBA,$4FCF
		Data.b $9D,$55,$7B,$8E,$7F,$15,$70,$91

		FOLDERID_LocalLowAppData: ; {A520A1A4-1780-4FF6-BD18-167343C5AF16}
		Data.l $A520A1A4
		Data.w $1780,$4FF6
		Data.b $BD,$18,$16,$73,$43,$C5,$AF,$16

		FOLDERID_Profile: ; {5E6C858F-0E22-4760-9AFE-EA3317B67173}
		Data.l $5E6C858F
		Data.w $0E22,$4760
		Data.b $9A,$FE,$EA,$33,$17,$B6,$71,$73
	EndDataSection
	;}
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_SHGETKNOWNFOLDERPATH
	; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath
	; https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cotaskmemalloc
	; https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cotaskmemfree
	; https://www.purebasic.fr/english/viewtopic.php?f=5&t=5517
	Prototype.l SHGetKnownFolderPath(kfid,dwFlags.l,hToken,*ppszPath.Integer)
	Global Original_SHGetKnownFolderPath.SHGetKnownFolderPath
	Procedure.l Detour_SHGetKnownFolderPath(kfid,dwFlags,hToken,*ppszPath.Integer)
		Protected Result
		CompilerIf Not #PORTABLE
			DbgKfid("SHGetKnownFolderPath",kfid)
			Result = Original_SHGetKnownFolderPath(kfid,dwFlags,hToken,*ppszPath)
		CompilerElse
			DbgKfid("SHGetKnownFolderPath",kfid)
			Protected FolderPath.s = kfid2path(kfid)
			If FolderPath
				;DbgKfid("SHGetKnownFolderPath",kfid,FolderPath)
				*ppszPath\i = CoTaskMemAlloc_(Len(FolderPath)*2+2)
				;*ppszPath\i = CoTaskMemAlloc_(StringByteLength(FolderPath)+2,#PB_Unicode)
				PokeS(*ppszPath\i,FolderPath)
				Result = #S_OK
			Else
				Result = Original_SHGetKnownFolderPath(kfid,dwFlags,hToken,*ppszPath)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_SHGETFOLDERPATHEX
	; https://learn.microsoft.com/en-us/windows/win32/shell/shgetfolderpathex
	; cchPath в символах (+ нулевой?)
	; Returns S_OK if successful, or an error value otherwise.
	Prototype.l SHGetFolderPathEx(hwnd,csidl,hToken,dwFlags.l,*pszPath)
	Global Original_SHGetFolderPathEx.SHGetFolderPathEx
	Procedure.l Detour_SHGetFolderPathEx(kfid,dwFlags,hToken,*pszPath,cchPath)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderPathEx(kfid,dwFlags,hToken,*pszPath,cchPath)
			DbgKfid("SHGetFolderPathEx",kfid,PeekSZ(*pszPath))
		CompilerElse
			DbgKfid("SHGetFolderPathEx",kfid)
			Protected FolderPath.s = kfid2path(kfid)
			If FolderPath
				;DbgKfid("SHGetFolderPathEx",kfid,FolderPath)
				If Len(FolderPath)>(cchPath-1)
					DbgSpec("pathlen="+Str(Len(FolderPath))+" cchPath="+Str(cchPath))
					Result = $8007007A
					DbgKfid("SHGetFolderPathEx",kfid,"ERROR")
				Else
					Result = #S_OK
				EndIf
				If cchPath>0
					PokeS(*pszPath,FolderPath,cchPath-1,#PB_Unicode)
				EndIf
			Else
				Result = Original_SHGetFolderPathEx(kfid,dwFlags,hToken,*pszPath,cchPath)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #DETOUR_SHGETKNOWNFOLDERIDLIST
	; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderidlist
	; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shilcreatefrompath
	; ASK: Как правильно действовать в режиме ansi?
	Prototype.l SHGetKnownFolderIDList(kfid,dwFlags,hToken,*ppidl)
	Global Original_SHGetKnownFolderIDList.SHGetKnownFolderIDList
	Procedure.l Detour_SHGetKnownFolderIDList(kfid,dwFlags,hToken,*ppidl)
		Protected Result
		DbgKfid("SHGetKnownFolderIDList ("+Hex(*ppidl)+")",kfid)
		CompilerIf Not #PORTABLE
			Result = Original_SHGetKnownFolderIDList(kfid,dwFlags,hToken,*ppidl)
		CompilerElse
			Protected rgfInOut
			Protected FolderPath.s = kfid2path(kfid)
			If FolderPath
				;DbgKfid("SHGetKnownFolderIDList ("+Hex(*ppidl)+")",kfid,FolderPath)
				Result = SHILCreateFromPath_(@FolderPath,*ppidl,@rgfInOut)
				DbgSpec("SHILCreateFromPath: Result: $"+Hex(Result)+" ("+Str(Result)+")")
			Else
				Result = Original_SHGetKnownFolderIDList(kfid,dwFlags,hToken,*ppidl)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
CompilerIf #CSIDL2PATH Or #CSIDL2PIDL
	Declare.s CheckCSIDL(csidl)
	Procedure.s csidl2path(csidl)
		Select csidl & #CSIDL_ID_MASK
			Case #CSIDL_PROFILE
				If ProfileRedir
					DbgSpec("csidl2path: "+ProfileRedir)
					ProcedureReturn ProfileRedir
				EndIf
			Case #CSIDL_APPDATA
				If AppDataRedir
					DbgSpec("csidl2path: "+AppDataRedir)
					ProcedureReturn AppDataRedir
				EndIf
			Case #CSIDL_LOCAL_APPDATA
				If LocalAppDataRedir
					DbgSpec("csidl2path: "+LocalAppDataRedir)
					ProcedureReturn LocalAppDataRedir
				EndIf
			Case #CSIDL_MYDOCUMENTS,#CSIDL_PERSONAL
				If DocumentsRedir
					DbgSpec("csidl2path: "+DocumentsRedir)
					ProcedureReturn DocumentsRedir
				EndIf
			Case #CSIDL_COMMON_APPDATA
				If CommonAppDataRedir
					DbgSpec("csidl2path: "+CommonAppDataRedir)
					ProcedureReturn CommonAppDataRedir
				EndIf
			Case #CSIDL_COMMON_DOCUMENTS
				If CommonDocumentsRedir
					DbgSpec("csidl2path: "+CommonDocumentsRedir)
					ProcedureReturn CommonDocumentsRedir
				EndIf
			Default
				CompilerIf #DBG_SPECIAL_FOLDERS
					Protected path.s = CheckCSIDL(csidl & #CSIDL_ID_MASK)
					DbgSpec("CheckCSIDL: "+path)
					ProcedureReturn path
				CompilerElse
					ProcedureReturn CheckCSIDL(csidl & #CSIDL_ID_MASK)
				CompilerEndIf
		EndSelect
		ProcedureReturn ""
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
Prototype.l SHGetFolderPath(hwnd,csidl,hToken,dwFlags.l,*pszPath)
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetfolderpathw
; DEPRICATED: As of Windows Vista, this function is merely a wrapper for SHGetKnownFolderPath.
; Возвращает имя специальной папки в системе.
; Данная функция работает только со специальными папками, которые физически присутствуют на диске, но не работает с виртуальными папками
; Функция возвращает один из следующих флажков:
; S_OK = 0 : Функция завершилась успешно
; S_FALSE = 1 : CSIDL специальной папки существует. Папка является виртуальной
; E_INVALIDARG = $80070057 : CSIDL не доступен
; TODO: CSIDL_FLAG_CREATE
CompilerIf #DETOUR_SHGETFOLDERPATH
	Global Original_SHGetFolderPathA.SHGetFolderPath
	Procedure.l Detour_SHGetFolderPathA(hwnd,csidl,hToken,dwFlags.l,*pszPath)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderPathA(hwnd,csidl,hToken,dwFlags,*pszPath)
			DbgSpec("SHGetFolderPathA: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath,-1,#PB_Ascii))
		CompilerElse
			DbgSpec("SHGetFolderPathA: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				PokeS(*pszPath,FolderPath,-1,#PB_Ascii)
				Result = #S_OK
			Else
				Result = Original_SHGetFolderPathA(hwnd,csidl,hToken,dwFlags,*pszPath)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And (csidl & #CSIDL_FLAG_CREATE)
				DbgSpec("SHGetFolderPathA: CSIDL_FLAG_CREATE")
			EndIf
			;DbgSpec("SHGetFolderPathA: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	Global Original_SHGetFolderPathW.SHGetFolderPath
	Procedure.l Detour_SHGetFolderPathW(hwnd,csidl,hToken,dwFlags.l,*pszPath)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderPathW(hwnd,csidl,hToken,dwFlags,*pszPath)
			DbgSpec("SHGetFolderPathW: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath))
		CompilerElse
			DbgSpec("SHGetFolderPathW: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				PokeS(*pszPath,FolderPath)
				Result = #S_OK
			Else
				Result = Original_SHGetFolderPathW(hwnd,csidl,hToken,dwFlags,*pszPath)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And (csidl & #CSIDL_FLAG_CREATE)
				DbgSpec("SHGetFolderPathW: CSIDL_FLAG_CREATE")
			EndIf
			;DbgSpec("SHGetFolderPathW: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetfolderpathandsubdira
Prototype.l SHGetFolderPathAndSubDir(hwnd,csidl,hToken,dwFlags.l,pszSubDir,*pszPath)
CompilerIf #DETOUR_SHGETFOLDERPATHANDSUBDIR
	Global Original_SHGetFolderPathAndSubDirA.SHGetFolderPathAndSubDir
	Procedure.l Detour_SHGetFolderPathAndSubDirA(hwnd,csidl,hToken,dwFlags.l,pszSubDir,*pszPath)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderPathAndSubDirA(hwnd,csidl,hToken,dwFlags,pszSubDir,*pszPath)
			DbgSpec("SHGetFolderPathAndSubDirA: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath,-1,#PB_Ascii))
		CompilerElse
			DbgSpec("SHGetFolderPathAndSubDirA: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				If pszSubDir
					FolderPath + "\" + PeekS(pszSubDir,-1,#PB_Ascii)
				EndIf
				If csidl & #CSIDL_FLAG_CREATE
					CreateDirectory(FolderPath)
				EndIf
				PokeS(*pszPath,FolderPath,-1,#PB_Ascii)
				Result = #S_OK
			Else
				Result = Original_SHGetFolderPathAndSubDirA(hwnd,csidl,hToken,dwFlags,pszSubDir,*pszPath)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And (csidl & #CSIDL_FLAG_CREATE)
				DbgSpec("SHGetFolderPathAndSubDirA: CSIDL_FLAG_CREATE")
			EndIf
			;DbgSpec("SHGetFolderPathAndSubDirA: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	Global Original_SHGetFolderPathAndSubDirW.SHGetFolderPathAndSubDir
	Procedure.l Detour_SHGetFolderPathAndSubDirW(hwnd,csidl,hToken,dwFlags.l,pszSubDir,*pszPath)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderPathAndSubDirW(hwnd,csidl,hToken,dwFlags,pszSubDir,*pszPath)
			DbgSpec("SHGetFolderPathAndSubDirW: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath))
		CompilerElse
			DbgSpec("SHGetFolderPathAndSubDirW: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				If pszSubDir
					FolderPath + "\" + PeekS(pszSubDir,-1,#PB_Unicode)
				EndIf
				If csidl & #CSIDL_FLAG_CREATE
					CreateDirectory(FolderPath)
				EndIf
				PokeS(*pszPath,FolderPath,-1,#PB_Unicode)
				Result = #S_OK
			Else
				Result = Original_SHGetFolderPathAndSubDirW(hwnd,csidl,hToken,dwFlags,pszSubDir,*pszPath)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And (csidl & #CSIDL_FLAG_CREATE)
				DbgSpec("SHGetFolderPathAndSubDirW: CSIDL_FLAG_CREATE")
			EndIf
			;DbgSpec("SHGetFolderPathAndSubDirW: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetspecialfolderpathw
; NOT SUPPORTED
; Получает имя специальных папок системы (только физических, но не виртуальных)
; fCreate : Если 0, то не создавать специальной папки, если она не существует. В других случаях создавать ее, если она еще не существует
; ASK: SHGetSpecialFolderPath - определять через SHGetSpecialFolderPathW ? Иначе, какие-то ошибки и вызовы через ordinal
; Эта функция эквивалентна SHGetSpecialFolderPathW ?
; Procedure.l Detour_SHGetSpecialFolderPath(hwnd,*pszPath,csidl,fCreate)
; EndProcedure
Prototype.l SHGetSpecialFolderPath(hwnd,*pszPath,csidl,fCreate)
CompilerIf #DETOUR_SHGETSPECIALFOLDERPATH
	Global Original_SHGetSpecialFolderPathA.SHGetSpecialFolderPath
	Procedure.l Detour_SHGetSpecialFolderPathA(hwnd,*pszPath,csidl,fCreate)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetSpecialFolderPathA(hwnd,*pszPath,csidl,fCreate)
			DbgSpec("SHGetSpecialFolderPathA: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath,-1,#PB_Ascii))
		CompilerElse
			DbgSpec("SHGetSpecialFolderPathA: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				PokeS(*pszPath,FolderPath,-1,#PB_Ascii)
				Result = #True
			Else
				Result = Original_SHGetSpecialFolderPathA(hwnd,*pszPath,csidl,fCreate)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And fCreate
				DbgSpec("SHGetSpecialFolderPathA: fCreate")
			EndIf
			;DbgSpec("SHGetSpecialFolderPathA: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	Global Original_SHGetSpecialFolderPathW.SHGetSpecialFolderPath
	Procedure.l Detour_SHGetSpecialFolderPathW(hwnd,*pszPath,csidl,fCreate)
		Protected Result
		CompilerIf Not #PORTABLE
			Result = Original_SHGetSpecialFolderPathW(hwnd,*pszPath,csidl,fCreate)
			DbgSpec("SHGetSpecialFolderPathW: csid:"+csidl2s(csidl)+" path:"+PeekS(*pszPath,-1,#PB_Unicode))
		CompilerElse
			DbgSpec("SHGetSpecialFolderPathW: "+csidl2s(csidl))
			Protected FolderPath.s = csidl2path(csidl)
			If FolderPath
				PokeS(*pszPath,FolderPath,-1,#PB_Unicode)
				Result = #True
			Else
				Result = Original_SHGetSpecialFolderPathW(hwnd,*pszPath,csidl,fCreate)
			EndIf
		CompilerEndIf
		CompilerIf #DBG_SPECIAL_FOLDERS
			If DbgSpecMode And fCreate
				DbgSpec("SHGetSpecialFolderPathW: fCreate")
			EndIf
			;DbgSpec("SHGetSpecialFolderPathW: Result: "+Str(Result))
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; ASK: Использовать SHParseDisplayName вместо SHILCreateFromPath ???
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shilcreatefrompath
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shparsedisplayname
CompilerIf #CSIDL2PIDL
	Procedure csidl2pidl(csidl,*ppidl)
		Protected Result = #E_FAIL
		Protected FolderPath.s = csidl2path(csidl)
		If FolderPath
			;DbgSpec("csidl2pidl ("+csidl2s(csidl)+"): "+FolderPath)
			DbgSpec("csidl2pidl: "+FolderPath)
			Result = SHILCreateFromPath_(@FolderPath,*ppidl,0)
		EndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetfolderlocation
; DEPRICATED
; Создает указатель к структуре ITEMIDLIST (известную как PIDL)), ссылающую к специальной папке на компьютере.
; PIDL может относиться к специальным папкам, которые существуют на диске или являются виртуальными папками.
; После завершения вашей программы, использующей PIDL, используйте CoTaskMemFree для освобождения памяти.
; Функция возвращает один из следующих флажков:
; S_OK = 0 : Функция завершилась успешно
; S_FALSE = 1 : CSIDL специальной папки существует. Папка является виртуальной
; E_INVALIDARG = $80070057 : CSIDL не доступен
Prototype.l SHGetFolderLocation(hwnd,csidl,hToken,dwFlags.l,*ppidl)
CompilerIf #DETOUR_SHGETFOLDERLOCATION
	Global Original_SHGetFolderLocation.SHGetFolderLocation
	Procedure.l Detour_SHGetFolderLocation(hwnd,csidl,hToken,dwFlags.l,*ppidl.Integer)
		Protected Result = #S_OK
		DbgSpec("SHGetFolderLocation: "+csidl2s(csidl))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetFolderLocation(hwnd,csidl,hToken,dwFlags,*ppidl)
		CompilerElse
			If csidl2pidl(csidl,*ppidl) <> #S_OK
				Result = Original_SHGetFolderLocation(hwnd,csidl,hToken,dwFlags,*ppidl)
			EndIf
		CompilerEndIf
		;DbgSpec("SHGetFolderLocation ("+csidl2s(csidl)+")("+Hex(*ppidl)+")("+Hex(*ppidl\i)+") ")
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetspecialfolderlocation
; NOT SUPPORTED
; S_OK = 0 : Функция завершилась успешно
Prototype.l SHGetSpecialFolderLocation(hwnd,csidl,*ppidl)
CompilerIf #DETOUR_SHGETSPECIALFOLDERLOCATION
	Global Original_SHGetSpecialFolderLocation.SHGetSpecialFolderLocation
	Procedure.l Detour_SHGetSpecialFolderLocation(hwnd,csidl,*ppidl.Integer)
		Protected Result = #S_OK
		DbgSpec("SHGetSpecialFolderLocation: "+csidl2s(csidl))
		CompilerIf Not #PORTABLE
			Result = Original_SHGetSpecialFolderLocation(hwnd,csidl,*ppidl)
		CompilerElse
			If csidl2pidl(csidl,*ppidl) <> #S_OK
				Result = Original_SHGetSpecialFolderLocation(hwnd,csidl,*ppidl)
			EndIf
		CompilerEndIf
		;DbgSpec("SHGetSpecialFolderLocation ("+csidl2s(csidl)+")("+Hex(*ppidl)+")("+Hex(*ppidl\i)+") ")
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;----------------------------------------------------------------------------------------------------------------------
; https://learn.microsoft.com/en-us/windows/win32/api/userenv/nf-userenv-getuserprofiledirectoryw
CompilerIf #DETOUR_USERENV
	Global GetUserProfileDirectoryMode = 1 ; управление GetUserProfileDirectory
	Prototype.l GetUserProfileDirectory(hToken,lpProfileDir,lpcchSize)
	Global Original_GetUserProfileDirectoryA.GetUserProfileDirectory
	Procedure.l Detour_GetUserProfileDirectoryA(hToken,*lpProfileDir,*lpcchSize.Long)
		Protected Result
		Protected ProfileDirSize = Len(ProfileRedir)+1
		CompilerIf Not #PORTABLE
			Result = Original_GetUserProfileDirectoryA(hToken,*lpProfileDir,*lpcchSize)
			DbgSpec("GetUserProfileDirectoryA: ("+Str(*lpcchSize\l)+") "+PeekSZ(*lpProfileDir,-1,#PB_Ascii))
			DbgSpec("GetUserProfileDirectoryA: RESULT: "+Str(Result)+" ERROR: "+Str(GetLastError_()))
		CompilerElse
			If GetUserProfileDirectoryMode
				If *lpcchSize
					*lpcchSize\l = ProfileDirSize
				EndIf
				If *lpProfileDir=#Null Or *lpcchSize=#Null Or *lpcchSize\l<ProfileDirSize
					Result = #False
					SetLastError_(122)
					DbgSpec("GetUserProfileDirectoryA: ("+Str(*lpcchSize\l)+")")
				Else
					Result = #True
					PokeS(*lpProfileDir,ProfileRedir,-1,#PB_Ascii)
					SetLastError_(0)
					DbgSpec("GetUserProfileDirectoryA: ("+Str(*lpcchSize\l)+") "+PeekSZ(*lpProfileDir,-1,#PB_Ascii))
				EndIf
			Else
				Result = Original_GetUserProfileDirectoryA(hToken,*lpProfileDir,*lpcchSize)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
	Global Original_GetUserProfileDirectoryW.GetUserProfileDirectory
	Procedure.l Detour_GetUserProfileDirectoryW(hToken,*lpProfileDir,*lpcchSize.Long)
		Protected Result
		Protected ProfileDirSize = Len(ProfileRedir)+1
		CompilerIf Not #PORTABLE
			Result = Original_GetUserProfileDirectoryW(hToken,*lpProfileDir,*lpcchSize)
			DbgSpec("GetUserProfileDirectoryW: ("+Str(*lpcchSize\l)+") "+PeekSZ(*lpProfileDir,-1,#PB_Unicode))
			DbgSpec("GetUserProfileDirectoryW: RESULT: "+Str(Result)+" ERROR: "+Str(GetLastError_()))
		CompilerElse
			If GetUserProfileDirectoryMode
				If *lpcchSize
					*lpcchSize\l = ProfileDirSize
				EndIf
				If *lpProfileDir=#Null Or *lpcchSize=#Null Or *lpcchSize\l<ProfileDirSize
					Result = #False
					SetLastError_(122)
					DbgSpec("GetUserProfileDirectoryW: ("+Str(*lpcchSize\l)+")")
				Else
					Result = #True
					PokeS(*lpProfileDir,ProfileRedir,-1,#PB_Unicode)
					SetLastError_(0)
					DbgSpec("GetUserProfileDirectoryW: ("+Str(*lpcchSize\l)+") "+PeekSZ(*lpProfileDir,-1,#PB_Unicode))
				EndIf
			Else
				Result = Original_GetUserProfileDirectoryW(hToken,*lpProfileDir,*lpcchSize)
			EndIf
		CompilerEndIf
		ProcedureReturn Result
	EndProcedure
CompilerEndIf
;;======================================================================================================================
XIncludeFile "PP_MinHook.pbi"
;;======================================================================================================================
; Принудительная статическая линковка dll
; https://learn.microsoft.com/en-us/cpp/build/reference/include-force-symbol-references
CompilerIf #PORTABLE_SPECIAL_FOLDERS
	Import "shell32.lib" : EndImport
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import "/INCLUDE:_SHGetFolderLocation@20" : EndImport
	CompilerElse
		Import "/INCLUDE:SHGetFolderLocation" : EndImport
	CompilerEndIf
CompilerEndIf
CompilerIf #DETOUR_USERENV
	Import "userenv.lib" : EndImport
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
		Import "/INCLUDE:_GetUserProfileDirectoryW@12" : EndImport
	CompilerElse
		Import "/INCLUDE:GetUserProfileDirectoryW" : EndImport
	CompilerEndIf
CompilerEndIf

Global SpecialFoldersPermit = 1
Procedure _InitSpecialFoldersHooks()
	If SpecialFoldersPermit
		CompilerIf (#DETOUR_SHFOLDER Or (#PORTABLE_SPECIAL_FOLDERS & #PORTABLE_SF_SHFOLDER))
			LoadDll("shfolder.dll")
			MH_HookApiV(shfolder,SHGetFolderPathA,SHGetFolderPathA,SHGetFolderPathA2)
			MH_HookApiV(shfolder,SHGetFolderPathW,SHGetFolderPathW,SHGetFolderPathW2)
		CompilerEndIf
		CompilerIf #DETOUR_USERENV Or (#PORTABLE_SPECIAL_FOLDERS & #PORTABLE_SF_USERENV)
			MH_HookApi(userenv,GetUserProfileDirectoryA)
			MH_HookApi(userenv,GetUserProfileDirectoryW)
		CompilerEndIf
		CompilerIf #DETOUR_SHGETKNOWNFOLDERPATH : MH_HookApi(shell32,SHGetKnownFolderPath,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERPATHEX : MH_HookApi(shell32,SHGetFolderPathEx,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_SHGETKNOWNFOLDERIDLIST : MH_HookApi(shell32,SHGetKnownFolderIDList,#MH_HOOKAPI_NOCHECKRESULT) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERPATH : MH_HookApi(shell32,SHGetFolderPathA) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERPATH : MH_HookApi(shell32,SHGetFolderPathW) : CompilerEndIf
		CompilerIf #DETOUR_SHGETSPECIALFOLDERPATH : MH_HookApi(shell32,SHGetSpecialFolderPathA) : CompilerEndIf
		CompilerIf #DETOUR_SHGETSPECIALFOLDERPATH : MH_HookApi(shell32,SHGetSpecialFolderPathW) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERPATHANDSUBDIR : MH_HookApi(shell32,SHGetFolderPathAndSubDirA) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERPATHANDSUBDIR : MH_HookApi(shell32,SHGetFolderPathAndSubDirW) : CompilerEndIf
		CompilerIf #DETOUR_SHGETFOLDERLOCATION : MH_HookApi(shell32,SHGetFolderLocation) : CompilerEndIf
		CompilerIf #DETOUR_SHGETSPECIALFOLDERLOCATION : MH_HookApi(shell32,SHGetSpecialFolderLocation) : CompilerEndIf
	EndIf
EndProcedure
AddInitProcedure(_InitSpecialFoldersHooks)
;;======================================================================================================================

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = uDAC+
; EnableAsm
; DisableDebugger
; EnableExeConstant