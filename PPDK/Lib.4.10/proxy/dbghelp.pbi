﻿
DeclareProxyDll(dbghelp)

DeclareProxyFunc(dbghelp,MapDebugInformation) ; x32 only
DeclareProxyFunc(dbghelp,UnmapDebugInformation) ; x32 only

DeclareProxyFunc(dbghelp,block)
DeclareProxyFunc(dbghelp,chksym)
DeclareProxyFunc(dbghelp,dbghelp)
DeclareProxyFunc(dbghelp,DbgHelpCreateUserDump)
DeclareProxyFunc(dbghelp,DbgHelpCreateUserDumpW)
DeclareProxyFunc(dbghelp,dh)
DeclareProxyFunc(dbghelp,EnumDirTree)
DeclareProxyFunc(dbghelp,EnumDirTreeW)
DeclareProxyFunc(dbghelp,EnumerateLoadedModules)
DeclareProxyFunc(dbghelp,EnumerateLoadedModules64)
DeclareProxyFunc(dbghelp,EnumerateLoadedModulesEx)
DeclareProxyFunc(dbghelp,EnumerateLoadedModulesExW)
DeclareProxyFunc(dbghelp,EnumerateLoadedModulesW64)
DeclareProxyFunc(dbghelp,ExtensionApiVersion)
DeclareProxyFunc(dbghelp,FindDebugInfoFile)
DeclareProxyFunc(dbghelp,FindDebugInfoFileEx)
DeclareProxyFunc(dbghelp,FindDebugInfoFileExW)
DeclareProxyFunc(dbghelp,FindExecutableImage)
DeclareProxyFunc(dbghelp,FindExecutableImageEx)
DeclareProxyFunc(dbghelp,FindExecutableImageExW)
DeclareProxyFunc(dbghelp,FindFileInPath)
DeclareProxyFunc(dbghelp,FindFileInSearchPath)
DeclareProxyFunc(dbghelp,fptr)
DeclareProxyFunc(dbghelp,GetSymLoadError)
DeclareProxyFunc(dbghelp,GetTimestampForLoadedLibrary)
DeclareProxyFunc(dbghelp,homedir)
DeclareProxyFunc(dbghelp,ImageDirectoryEntryToData)
DeclareProxyFunc(dbghelp,ImageDirectoryEntryToDataEx)
DeclareProxyFunc(dbghelp,ImagehlpApiVersion)
DeclareProxyFunc(dbghelp,ImagehlpApiVersionEx)
DeclareProxyFunc(dbghelp,ImageNtHeader)
DeclareProxyFunc(dbghelp,ImageRvaToSection)
DeclareProxyFunc(dbghelp,ImageRvaToVa)
DeclareProxyFunc(dbghelp,inlinedbg)
DeclareProxyFunc(dbghelp,itoldyouso)
DeclareProxyFunc(dbghelp,lmi)
DeclareProxyFunc(dbghelp,lminfo)
DeclareProxyFunc(dbghelp,MakeSureDirectoryPathExists)
DeclareProxyFunc(dbghelp,MiniDumpReadDumpStream)
DeclareProxyFunc(dbghelp,MiniDumpWriteDump)
DeclareProxyFunc(dbghelp,omap)
DeclareProxyFunc(dbghelp,optdbgdump)
DeclareProxyFunc(dbghelp,optdbgdumpaddr)
DeclareProxyFunc(dbghelp,RangeMapAddPeImageSections)
DeclareProxyFunc(dbghelp,RangeMapCreate)
DeclareProxyFunc(dbghelp,RangeMapFree)
DeclareProxyFunc(dbghelp,RangeMapRead)
DeclareProxyFunc(dbghelp,RangeMapRemove)
DeclareProxyFunc(dbghelp,RangeMapWrite)
DeclareProxyFunc(dbghelp,RemoveInvalidModuleList)
DeclareProxyFunc(dbghelp,ReportSymbolLoadSummary)
DeclareProxyFunc(dbghelp,SearchTreeForFile)
DeclareProxyFunc(dbghelp,SearchTreeForFileW)
DeclareProxyFunc(dbghelp,SetCheckUserInterruptShared)
DeclareProxyFunc(dbghelp,SetSymLoadError)
DeclareProxyFunc(dbghelp,srcfiles)
DeclareProxyFunc(dbghelp,stack_force_ebp)
DeclareProxyFunc(dbghelp,stackdbg)
DeclareProxyFunc(dbghelp,StackWalk)
DeclareProxyFunc(dbghelp,StackWalk64)
DeclareProxyFunc(dbghelp,StackWalkEx)
DeclareProxyFunc(dbghelp,sym)
DeclareProxyFunc(dbghelp,SymAddrIncludeInlineTrace)
DeclareProxyFunc(dbghelp,SymAddSourceStream)
DeclareProxyFunc(dbghelp,SymAddSourceStreamA)
DeclareProxyFunc(dbghelp,SymAddSourceStreamW)
DeclareProxyFunc(dbghelp,SymAddSymbol)
DeclareProxyFunc(dbghelp,SymAddSymbolW)
DeclareProxyFunc(dbghelp,SymCleanup)
DeclareProxyFunc(dbghelp,SymCompareInlineTrace)
DeclareProxyFunc(dbghelp,SymDeleteSymbol)
DeclareProxyFunc(dbghelp,SymDeleteSymbolW)
DeclareProxyFunc(dbghelp,SymEnumerateModules)
DeclareProxyFunc(dbghelp,SymEnumerateModules64)
DeclareProxyFunc(dbghelp,SymEnumerateModulesW64)
DeclareProxyFunc(dbghelp,SymEnumerateSymbols)
DeclareProxyFunc(dbghelp,SymEnumerateSymbols64)
DeclareProxyFunc(dbghelp,SymEnumerateSymbolsW)
DeclareProxyFunc(dbghelp,SymEnumerateSymbolsW64)
DeclareProxyFunc(dbghelp,SymEnumLines)
DeclareProxyFunc(dbghelp,SymEnumLinesW)
DeclareProxyFunc(dbghelp,SymEnumProcesses)
DeclareProxyFunc(dbghelp,SymEnumSourceFiles)
DeclareProxyFunc(dbghelp,SymEnumSourceFilesW)
DeclareProxyFunc(dbghelp,SymEnumSourceFileTokens)
DeclareProxyFunc(dbghelp,SymEnumSourceLines)
DeclareProxyFunc(dbghelp,SymEnumSourceLinesW)
DeclareProxyFunc(dbghelp,SymEnumSym)
DeclareProxyFunc(dbghelp,SymEnumSymbols)
DeclareProxyFunc(dbghelp,SymEnumSymbolsEx)
DeclareProxyFunc(dbghelp,SymEnumSymbolsExW)
DeclareProxyFunc(dbghelp,SymEnumSymbolsForAddr)
DeclareProxyFunc(dbghelp,SymEnumSymbolsForAddrW)
DeclareProxyFunc(dbghelp,SymEnumSymbolsW)
DeclareProxyFunc(dbghelp,SymEnumTypes)
DeclareProxyFunc(dbghelp,SymEnumTypesByName)
DeclareProxyFunc(dbghelp,SymEnumTypesByNameW)
DeclareProxyFunc(dbghelp,SymEnumTypesW)
DeclareProxyFunc(dbghelp,SymFindDebugInfoFile)
DeclareProxyFunc(dbghelp,SymFindDebugInfoFileW)
DeclareProxyFunc(dbghelp,SymFindExecutableImage)
DeclareProxyFunc(dbghelp,SymFindExecutableImageW)
DeclareProxyFunc(dbghelp,SymFindFileInPath)
DeclareProxyFunc(dbghelp,SymFindFileInPathW)
DeclareProxyFunc(dbghelp,SymFromAddr)
DeclareProxyFunc(dbghelp,SymFromAddrW)
DeclareProxyFunc(dbghelp,SymFromIndex)
DeclareProxyFunc(dbghelp,SymFromIndexW)
DeclareProxyFunc(dbghelp,SymFromInlineContext)
DeclareProxyFunc(dbghelp,SymFromInlineContextW)
DeclareProxyFunc(dbghelp,SymFromName)
DeclareProxyFunc(dbghelp,SymFromNameW)
DeclareProxyFunc(dbghelp,SymFromToken)
DeclareProxyFunc(dbghelp,SymFromTokenW)
DeclareProxyFunc(dbghelp,SymFunctionTableAccess)
DeclareProxyFunc(dbghelp,SymFunctionTableAccess64)
DeclareProxyFunc(dbghelp,SymFunctionTableAccess64AccessRoutines)
DeclareProxyFunc(dbghelp,SymGetExtendedOption)
DeclareProxyFunc(dbghelp,SymGetFileLineOffsets64)
DeclareProxyFunc(dbghelp,SymGetHomeDirectory)
DeclareProxyFunc(dbghelp,SymGetHomeDirectoryW)
DeclareProxyFunc(dbghelp,SymGetLineFromAddr)
DeclareProxyFunc(dbghelp,SymGetLineFromAddr64)
DeclareProxyFunc(dbghelp,SymGetLineFromAddrW64)
DeclareProxyFunc(dbghelp,SymGetLineFromInlineContext)
DeclareProxyFunc(dbghelp,SymGetLineFromInlineContextW)
DeclareProxyFunc(dbghelp,SymGetLineFromName)
DeclareProxyFunc(dbghelp,SymGetLineFromName64)
DeclareProxyFunc(dbghelp,SymGetLineFromNameW64)
DeclareProxyFunc(dbghelp,SymGetLineNext)
DeclareProxyFunc(dbghelp,SymGetLineNext64)
DeclareProxyFunc(dbghelp,SymGetLineNextW64)
DeclareProxyFunc(dbghelp,SymGetLinePrev)
DeclareProxyFunc(dbghelp,SymGetLinePrev64)
DeclareProxyFunc(dbghelp,SymGetLinePrevW64)
DeclareProxyFunc(dbghelp,SymGetModuleBase)
DeclareProxyFunc(dbghelp,SymGetModuleBase64)
DeclareProxyFunc(dbghelp,SymGetModuleInfo)
DeclareProxyFunc(dbghelp,SymGetModuleInfo64)
DeclareProxyFunc(dbghelp,SymGetModuleInfoW)
DeclareProxyFunc(dbghelp,SymGetModuleInfoW64)
DeclareProxyFunc(dbghelp,SymGetOmaps)
DeclareProxyFunc(dbghelp,SymGetOptions)
DeclareProxyFunc(dbghelp,SymGetScope)
DeclareProxyFunc(dbghelp,SymGetScopeW)
DeclareProxyFunc(dbghelp,SymGetSearchPath)
DeclareProxyFunc(dbghelp,SymGetSearchPathW)
DeclareProxyFunc(dbghelp,SymGetSourceFile)
DeclareProxyFunc(dbghelp,SymGetSourceFileChecksum)
DeclareProxyFunc(dbghelp,SymGetSourceFileChecksumW)
DeclareProxyFunc(dbghelp,SymGetSourceFileFromToken)
DeclareProxyFunc(dbghelp,SymGetSourceFileFromTokenW)
DeclareProxyFunc(dbghelp,SymGetSourceFileToken)
DeclareProxyFunc(dbghelp,SymGetSourceFileTokenW)
DeclareProxyFunc(dbghelp,SymGetSourceFileW)
DeclareProxyFunc(dbghelp,SymGetSourceVarFromToken)
DeclareProxyFunc(dbghelp,SymGetSourceVarFromTokenW)
DeclareProxyFunc(dbghelp,SymGetSymbolFile)
DeclareProxyFunc(dbghelp,SymGetSymbolFileW)
DeclareProxyFunc(dbghelp,SymGetSymFromAddr)
DeclareProxyFunc(dbghelp,SymGetSymFromAddr64)
DeclareProxyFunc(dbghelp,SymGetSymFromName)
DeclareProxyFunc(dbghelp,SymGetSymFromName64)
DeclareProxyFunc(dbghelp,SymGetSymNext)
DeclareProxyFunc(dbghelp,SymGetSymNext64)
DeclareProxyFunc(dbghelp,SymGetSymPrev)
DeclareProxyFunc(dbghelp,SymGetSymPrev64)
DeclareProxyFunc(dbghelp,SymGetTypeFromName)
DeclareProxyFunc(dbghelp,SymGetTypeFromNameW)
DeclareProxyFunc(dbghelp,SymGetTypeInfo)
DeclareProxyFunc(dbghelp,SymGetTypeInfoEx)
DeclareProxyFunc(dbghelp,SymGetUnwindInfo)
DeclareProxyFunc(dbghelp,SymInitialize)
DeclareProxyFunc(dbghelp,SymInitializeW)
DeclareProxyFunc(dbghelp,SymLoadModule)
DeclareProxyFunc(dbghelp,SymLoadModule64)
DeclareProxyFunc(dbghelp,SymLoadModuleEx)
DeclareProxyFunc(dbghelp,SymLoadModuleExW)
DeclareProxyFunc(dbghelp,SymMatchFileName)
DeclareProxyFunc(dbghelp,SymMatchFileNameW)
DeclareProxyFunc(dbghelp,SymMatchString)
DeclareProxyFunc(dbghelp,SymMatchStringA)
DeclareProxyFunc(dbghelp,SymMatchStringW)
DeclareProxyFunc(dbghelp,SymNext)
DeclareProxyFunc(dbghelp,SymNextW)
DeclareProxyFunc(dbghelp,SymPrev)
DeclareProxyFunc(dbghelp,SymPrevW)
DeclareProxyFunc(dbghelp,SymQueryInlineTrace)
DeclareProxyFunc(dbghelp,SymRefreshModuleList)
DeclareProxyFunc(dbghelp,SymRegisterCallback)
DeclareProxyFunc(dbghelp,SymRegisterCallback64)
DeclareProxyFunc(dbghelp,SymRegisterCallbackW64)
DeclareProxyFunc(dbghelp,SymRegisterFunctionEntryCallback)
DeclareProxyFunc(dbghelp,SymRegisterFunctionEntryCallback64)
DeclareProxyFunc(dbghelp,SymSearch)
DeclareProxyFunc(dbghelp,SymSearchW)
DeclareProxyFunc(dbghelp,SymSetContext)
DeclareProxyFunc(dbghelp,SymSetExtendedOption)
DeclareProxyFunc(dbghelp,SymSetHomeDirectory)
DeclareProxyFunc(dbghelp,SymSetHomeDirectoryW)
DeclareProxyFunc(dbghelp,SymSetOptions)
DeclareProxyFunc(dbghelp,SymSetParentWindow)
DeclareProxyFunc(dbghelp,SymSetScopeFromAddr)
DeclareProxyFunc(dbghelp,SymSetScopeFromIndex)
DeclareProxyFunc(dbghelp,SymSetScopeFromInlineContext)
DeclareProxyFunc(dbghelp,SymSetSearchPath)
DeclareProxyFunc(dbghelp,SymSetSearchPathW)
DeclareProxyFunc(dbghelp,symsrv)
DeclareProxyFunc(dbghelp,SymSrvDeltaName)
DeclareProxyFunc(dbghelp,SymSrvDeltaNameW)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexes)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexesW)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexInfo)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexInfoW)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexString)
DeclareProxyFunc(dbghelp,SymSrvGetFileIndexStringW)
DeclareProxyFunc(dbghelp,SymSrvGetSupplement)
DeclareProxyFunc(dbghelp,SymSrvGetSupplementW)
DeclareProxyFunc(dbghelp,SymSrvIsStore)
DeclareProxyFunc(dbghelp,SymSrvIsStoreW)
DeclareProxyFunc(dbghelp,SymSrvStoreFile)
DeclareProxyFunc(dbghelp,SymSrvStoreFileW)
DeclareProxyFunc(dbghelp,SymSrvStoreSupplement)
DeclareProxyFunc(dbghelp,SymSrvStoreSupplementW)
DeclareProxyFunc(dbghelp,SymUnDName)
DeclareProxyFunc(dbghelp,SymUnDName64)
DeclareProxyFunc(dbghelp,SymUnloadModule)
DeclareProxyFunc(dbghelp,SymUnloadModule64)
DeclareProxyFunc(dbghelp,UnDecorateSymbolName)
DeclareProxyFunc(dbghelp,UnDecorateSymbolNameW)
DeclareProxyFunc(dbghelp,vc7fpo)
DeclareProxyFunc(dbghelp,WinDbgExtensionDllInit)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; EnableAsm
; DisableDebugger
; EnableExeConstant