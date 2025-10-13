
Prototype.i CfgExist(sKey.s,sName.s)
Prototype SetCfgS(sKey.s,sName.s,sData.s)
Prototype SetCfgD(sKey.s,sName.s,dwData.l)
Prototype SetCfgB(sKey.s,sName.s,sHex.s)
Prototype.s GetCfgS(sKey.s,sName.s)
Prototype.l GetCfgD(sKey.s,sName.s,DefVal=0)
Prototype DelCfg(sKey.s,sName.s)
Prototype DelCfgTree(sKey.s)
Prototype CorrectCfgPath(Key.s,Value.s,Base.s,Flags=0) ; Может не компилироваться по условию
Prototype.s FindCfgS(ValueName.s) ; Только R1. Может не компилироваться по условию
Prototype.l FindCfgD(ValueName.s) ; Только R1. Может не компилироваться по условию
; Некоторые другие для R1 типа SetIC

;{ Структуры R1 для работы с записываемыми/считываемыми в реестр данными
Structure AnyBytes
	b0.b
	b1.b
	b2.b
	b3.b
EndStructure
Structure AnyWords
	w0.w
	w1.w
EndStructure
Structure AnyType
	StructureUnion
		l.l
		w.w
		b.b
		x.b[3]
		bx.AnyBytes
		wx.AnyWords
	EndStructureUnion
EndStructure
;}

Structure IRegistryData
	hAppKey.l
	*ConfigFile
	*InitialFile
	*Keys.String ; указатель на массив строк
	*Cfg.CFGDATA ; указатель на массив CFGDATA
	*nkeys.INTEGER
	*nCfg.INTEGER
	*ConfigChanged.INTEGER
EndStructure

Structure IRegistry
	Version.i ; 1 или 2
	*D.IRegistryData
	CfgExist.CfgExist
	SetCfgS.SetCfgS
	SetCfgD.SetCfgD
	SetCfgB.SetCfgB
	GetCfgS.GetCfgS
	GetCfgD.GetCfgD
	DelCfg.DelCfg
	DelCfgTree.DelCfgTree
	CorrectCfgPath.CorrectCfgPath
EndStructure

CompilerIf Not Defined(IREGISTRY_INIT,#PB_Constant) : #IREGISTRY_INIT = 0 : CompilerEndIf

CompilerIf #IREGISTRY_INIT
	
	Global IRegistry.IRegistry
	
	DataSection
		IRegistry:
		Data.i @CfgExist()
		Data.i @SetCfgS()
		Data.i @SetCfgD()
		Data.i @SetCfgB()
		Data.i @GetCfgS()
		Data.i @GetCfgD()
		Data.i @DelCfg()
		Data.i @DelCfgTree()
		CompilerIf Defined(CorrectCfgPath,#PB_Procedure)
			Data.i @CorrectCfgPath()
		CompilerElse
			Data.i 0
		CompilerEndIf
	EndDataSection
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 67
; FirstLine = 28
; Folding = +
; EnableThread
; DisableDebugger
; EnableExeConstant