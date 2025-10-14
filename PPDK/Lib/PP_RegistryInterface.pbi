CompilerIf Not Defined(PORTABLE_REGISTRY,#PB_Constant) : #PORTABLE_REGISTRY = 0 : CompilerEndIf
CompilerIf #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
	Procedure.i XCfgExist(*Key,*Name)
		ProcedureReturn CfgExist(PeekS(*Key),PeekS(*Name))
	EndProcedure
	Procedure XSetCfgS(*Key,*Name,*Data)
		ProcedureReturn SetCfgS(PeekS(*Key),PeekS(*Name),PeekS(*Data))
	EndProcedure
	Procedure XSetCfgD(*Key,*Name,dwData.l)
		ProcedureReturn SetCfgD(PeekS(*Key),PeekS(*Name),dwData)
	EndProcedure
	Procedure XSetCfgB(*Key,*Name,*Hex)
		ProcedureReturn SetCfgB(PeekS(*Key),PeekS(*Name),PeekS(*Hex))
	EndProcedure
	Procedure.s XGetCfgS(*Key,*Name)
		ProcedureReturn GetCfgS(PeekS(*Key),PeekS(*Name))
	EndProcedure
	Procedure.l XGetCfgD(*Key,*Name,DefVal=0)
		ProcedureReturn GetCfgD(PeekS(*Key),PeekS(*Name),DefVal)
	EndProcedure
	Procedure XDelCfg(*Key,*Name)
		ProcedureReturn DelCfg(PeekS(*Key),PeekS(*Name))
	EndProcedure
	Procedure XDelCfgTree(*Key)
		ProcedureReturn DelCfgTree(PeekS(*Key))
	EndProcedure
	Procedure XCorrectCfgPath(*Key,*Value,*Base,Flags=0)
		ProcedureReturn CorrectCfgPath(PeekS(*Key),PeekS(*Value),PeekS(*Base),Flags)	
	EndProcedure
CompilerEndIf

Prototype.i XCfgExist(*Key,*Name)
Prototype XSetCfgS(*Key,*Name,*Data)
Prototype XSetCfgD(*Key,*Name,dwData.l)
Prototype XSetCfgB(*Key,*Name,*Hex)
Prototype.s XGetCfgS(*Key,*Name)
Prototype.l XGetCfgD(*Key,*Name,DefVal=0)
Prototype XDelCfg(*Key,*Name)
Prototype XDelCfgTree(*Key)
Prototype XCorrectCfgPath(*Key,*Value,*Base,Flags=0)
;Prototype.s XFindCfgS(*ValueName) ; Только R1. Может не компилироваться по условию
;Prototype.l XFindCfgD(*ValueName) ; Только R1. Может не компилироваться по условию
; Некоторые другие для R1 типа SetIC

Structure IRegistryData
	*hAppKey.INTEGER
	*ConfigFile
	*InitialFile
	*Reserve ; для бывшего и возможно будущего дополнительного файла
	*Keys.String ; указатель на массив строк
	*Cfg.CFGDATA ; указатель на массив CFGDATA
	*nKeys.INTEGER
	*nCfg.INTEGER
	*ConfigChanged.INTEGER
EndStructure

Structure IRegistry
	StorageType.i ; 1 или 2
	*RD.IRegistryData
	CfgExist.XCfgExist
	SetCfgS.XSetCfgS
	SetCfgD.XSetCfgD
	SetCfgB.XSetCfgB
	GetCfgS.XGetCfgS
	GetCfgD.XGetCfgD
	DelCfg.XDelCfg
	DelCfgTree.XDelCfgTree
	CorrectCfgPath.XCorrectCfgPath
EndStructure

CompilerIf Not Defined(IREGISTRY_INIT,#PB_Constant) : #IREGISTRY_INIT = 0 : CompilerEndIf

CompilerIf #IREGISTRY_INIT
	
	Global IRegistry.IRegistry
	Global IRegistryData.IRegistryData
	CompilerSelect #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
		CompilerCase 1
			IRegistryData\Cfg = @Cfg()
			IRegistryData\Keys = @Keys()
			IRegistryData\nCfg = @nCfg
			IRegistryData\nKeys = @nKeys
			IRegistryData\ConfigChanged = @ConfigChanged
		CompilerCase 2
			IRegistryData\hAppKey = @hAppKey
	CompilerEndSelect
	CompilerIf #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
		IRegistryData\ConfigFile = @ConfigFile
		IRegistryData\InitialFile = @InitialFile
		IRegistry\StorageType = #PORTABLE_REGISTRY & #PORTABLE_REG_STORAGE_MASK
		IRegistry\RD = @IRegistryData
		IRegistry\CfgExist = @XCfgExist()
		IRegistry\SetCfgS = @XSetCfgS()
		IRegistry\SetCfgD = @XSetCfgD()
		IRegistry\SetCfgB = @XSetCfgB()
		IRegistry\GetCfgS = @XGetCfgS()
		IRegistry\GetCfgD = @XGetCfgD()
		IRegistry\DelCfg = @XDelCfg()
		IRegistry\DelCfgTree = @XDelCfgTree()		
		CompilerIf Defined(CorrectCfgPath,#PB_Procedure)
			IRegistry\CorrectCfgPath = @XCorrectCfgPath()
		CompilerEndIf
	CompilerEndIf
CompilerEndIf

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; Folding = --
; EnableThread
; DisableDebugger
; EnableExeConstant