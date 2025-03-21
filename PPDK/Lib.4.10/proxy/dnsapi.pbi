﻿
DeclareProxyDll(dnsapi)

DeclareProxyFunc(dnsapi,AdaptiveTimeout_ClearInterfaceSpecificConfiguration)
DeclareProxyFunc(dnsapi,AdaptiveTimeout_ResetAdaptiveTimeout)
DeclareProxyFunc(dnsapi,AddRefQueryBlobEx)
DeclareProxyFunc(dnsapi,BreakRecordsIntoBlob)
DeclareProxyFunc(dnsapi,Coalesce_UpdateNetVersion)
DeclareProxyFunc(dnsapi,CombineRecordsInBlob)
DeclareProxyFunc(dnsapi,DelaySortDAServerlist)
DeclareProxyFunc(dnsapi,DeRefQueryBlobEx)
DeclareProxyFunc(dnsapi,Dns_AddRecordsToMessage)
DeclareProxyFunc(dnsapi,Dns_AllocateMsgBuf)
DeclareProxyFunc(dnsapi,Dns_BuildPacket)
DeclareProxyFunc(dnsapi,Dns_CacheServiceCleanup)
DeclareProxyFunc(dnsapi,Dns_CacheServiceInit)
DeclareProxyFunc(dnsapi,Dns_CacheServiceStopIssued)
DeclareProxyFunc(dnsapi,Dns_CleanupWinsock)
DeclareProxyFunc(dnsapi,Dns_CloseConnection)
DeclareProxyFunc(dnsapi,Dns_CloseSocket)
DeclareProxyFunc(dnsapi,Dns_CreateMulticastSocket)
DeclareProxyFunc(dnsapi,Dns_CreateSocket)
DeclareProxyFunc(dnsapi,Dns_CreateSocketEx)
DeclareProxyFunc(dnsapi,Dns_ExtractRecordsFromMessage)
DeclareProxyFunc(dnsapi,Dns_FindAuthoritativeZoneLib)
DeclareProxyFunc(dnsapi,Dns_FreeMsgBuf)
DeclareProxyFunc(dnsapi,Dns_GetRandomXid)
DeclareProxyFunc(dnsapi,Dns_InitializeMsgBuf)
DeclareProxyFunc(dnsapi,Dns_InitializeMsgRemoteSockaddr)
DeclareProxyFunc(dnsapi,Dns_InitializeWinsock)
DeclareProxyFunc(dnsapi,Dns_OpenTcpConnectionAndSend)
DeclareProxyFunc(dnsapi,Dns_ParseMessage)
DeclareProxyFunc(dnsapi,Dns_ParsePacketRecord)
DeclareProxyFunc(dnsapi,Dns_PingAdapterServers)
DeclareProxyFunc(dnsapi,Dns_ReadRecordStructureFromPacket)
DeclareProxyFunc(dnsapi,Dns_RecvTcp)
DeclareProxyFunc(dnsapi,Dns_ResetNetworkInfo)
DeclareProxyFunc(dnsapi,Dns_SendAndRecvUdp)
DeclareProxyFunc(dnsapi,Dns_SendEx)
DeclareProxyFunc(dnsapi,Dns_SetRecordDatalength)
DeclareProxyFunc(dnsapi,Dns_SetRecordsSection)
DeclareProxyFunc(dnsapi,Dns_SetRecordsTtl)
DeclareProxyFunc(dnsapi,Dns_SkipToRecord)
DeclareProxyFunc(dnsapi,Dns_UpdateLib)
DeclareProxyFunc(dnsapi,Dns_UpdateLibEx)
DeclareProxyFunc(dnsapi,Dns_WriteQuestionToMessage)
DeclareProxyFunc(dnsapi,Dns_WriteRecordStructureToPacketEx)
DeclareProxyFunc(dnsapi,DnsAcquireContextHandle_A)
DeclareProxyFunc(dnsapi,DnsAcquireContextHandle_W)
DeclareProxyFunc(dnsapi,DnsAllocateRecord)
DeclareProxyFunc(dnsapi,DnsApiAlloc)
DeclareProxyFunc(dnsapi,DnsApiAllocZero)
DeclareProxyFunc(dnsapi,DnsApiFree)
DeclareProxyFunc(dnsapi,DnsApiHeapReset)
DeclareProxyFunc(dnsapi,DnsApiRealloc)
DeclareProxyFunc(dnsapi,DnsApiSetDebugGlobals)
DeclareProxyFunc(dnsapi,DnsAsyncRegisterHostAddrs)
DeclareProxyFunc(dnsapi,DnsAsyncRegisterInit)
DeclareProxyFunc(dnsapi,DnsAsyncRegisterTerm)
DeclareProxyFunc(dnsapi,DnsCancelQuery)
DeclareProxyFunc(dnsapi,DnsCheckNrptRuleIntegrity)
DeclareProxyFunc(dnsapi,DnsCheckNrptRules)
DeclareProxyFunc(dnsapi,DnsConnectionDeletePolicyEntries)
DeclareProxyFunc(dnsapi,DnsConnectionDeletePolicyEntriesPrivate)
DeclareProxyFunc(dnsapi,DnsConnectionDeleteProxyInfo)
DeclareProxyFunc(dnsapi,DnsConnectionFreeNameList)
DeclareProxyFunc(dnsapi,DnsConnectionFreeProxyInfo)
DeclareProxyFunc(dnsapi,DnsConnectionFreeProxyInfoEx)
DeclareProxyFunc(dnsapi,DnsConnectionFreeProxyList)
DeclareProxyFunc(dnsapi,DnsConnectionGetHandleForHostUrlPrivate)
DeclareProxyFunc(dnsapi,DnsConnectionGetNameList)
DeclareProxyFunc(dnsapi,DnsConnectionGetProxyInfo)
DeclareProxyFunc(dnsapi,DnsConnectionGetProxyInfoForHostUrl)
DeclareProxyFunc(dnsapi,DnsConnectionGetProxyList)
DeclareProxyFunc(dnsapi,DnsConnectionSetPolicyEntries)
DeclareProxyFunc(dnsapi,DnsConnectionSetPolicyEntriesPrivate)
DeclareProxyFunc(dnsapi,DnsConnectionSetProxyInfo)
DeclareProxyFunc(dnsapi,DnsConnectionUpdateIfIndexTable)
DeclareProxyFunc(dnsapi,DnsCopyStringEx)
DeclareProxyFunc(dnsapi,DnsCreateReverseNameStringForIpAddress)
DeclareProxyFunc(dnsapi,DnsCreateStandardDnsNameCopy)
DeclareProxyFunc(dnsapi,DnsCreateStringCopy)
DeclareProxyFunc(dnsapi,DnsDeRegisterLocal)
DeclareProxyFunc(dnsapi,DnsDhcpRegisterAddrs)
DeclareProxyFunc(dnsapi,DnsDhcpRegisterHostAddrs)
DeclareProxyFunc(dnsapi,DnsDhcpRegisterInit)
DeclareProxyFunc(dnsapi,DnsDhcpRegisterTerm)
DeclareProxyFunc(dnsapi,DnsDhcpRemoveRegistrations)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterHostAddr)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterHostAddrEx)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterHostName)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterHostNameEx)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterInit)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterInitEx)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterInitialize)
DeclareProxyFunc(dnsapi,DnsDhcpSrvRegisterTerm)
DeclareProxyFunc(dnsapi,DnsDisableIdnEncoding)
DeclareProxyFunc(dnsapi,DnsDowncaseDnsNameLabel)
DeclareProxyFunc(dnsapi,DnsExtractRecordsFromMessage_UTF8)
DeclareProxyFunc(dnsapi,DnsExtractRecordsFromMessage_W)
DeclareProxyFunc(dnsapi,DnsFindAuthoritativeZone)
DeclareProxyFunc(dnsapi,DnsFlushResolverCache)
DeclareProxyFunc(dnsapi,DnsFlushResolverCacheEntry_A)
DeclareProxyFunc(dnsapi,DnsFlushResolverCacheEntry_UTF8)
DeclareProxyFunc(dnsapi,DnsFlushResolverCacheEntry_W)
DeclareProxyFunc(dnsapi,DnsFree)
DeclareProxyFunc(dnsapi,DnsFreeAdaptersInfo)
DeclareProxyFunc(dnsapi,DnsFreeConfigStructure)
DeclareProxyFunc(dnsapi,DnsFreeNrptRule)
DeclareProxyFunc(dnsapi,DnsFreeNrptRuleNamesList)
DeclareProxyFunc(dnsapi,DnsFreePolicyConfig)
DeclareProxyFunc(dnsapi,DnsFreeProxyName)
DeclareProxyFunc(dnsapi,DnsGetAdaptersInfo)
DeclareProxyFunc(dnsapi,DnsGetApplicationIdentifier)
DeclareProxyFunc(dnsapi,DnsGetBufferLengthForStringCopy)
DeclareProxyFunc(dnsapi,DnsGetCacheDataTable)
DeclareProxyFunc(dnsapi,DnsGetCacheDataTableEx)
DeclareProxyFunc(dnsapi,DnsGetDnsServerList)
DeclareProxyFunc(dnsapi,DnsGetInterfaceSettings)
DeclareProxyFunc(dnsapi,DnsGetLastFailedUpdateInfo)
DeclareProxyFunc(dnsapi,DnsGetNrptRuleNamesList)
DeclareProxyFunc(dnsapi,DnsGetPolicyTableInfo)
DeclareProxyFunc(dnsapi,DnsGetPolicyTableInfoPrivate)
DeclareProxyFunc(dnsapi,DnsGetPrimaryDomainName_A)
DeclareProxyFunc(dnsapi,DnsGetProxyInfoPrivate)
DeclareProxyFunc(dnsapi,DnsGetProxyInformation)
DeclareProxyFunc(dnsapi,DnsGetQueryRetryTimeouts)
DeclareProxyFunc(dnsapi,DnsGetSettings)
DeclareProxyFunc(dnsapi,DnsGlobals)
DeclareProxyFunc(dnsapi,DnsIpv6AddressToString)
DeclareProxyFunc(dnsapi,DnsIpv6StringToAddress)
DeclareProxyFunc(dnsapi,DnsIsStringCountValidForTextType)
DeclareProxyFunc(dnsapi,DnsLogEvent)
DeclareProxyFunc(dnsapi,DnsModifyRecordsInSet_A)
DeclareProxyFunc(dnsapi,DnsModifyRecordsInSet_UTF8)
DeclareProxyFunc(dnsapi,DnsModifyRecordsInSet_W)
DeclareProxyFunc(dnsapi,DnsNameCompare_A)
DeclareProxyFunc(dnsapi,DnsNameCompare_UTF8)
DeclareProxyFunc(dnsapi,DnsNameCompare_W)
DeclareProxyFunc(dnsapi,DnsNameCompareEx_A)
DeclareProxyFunc(dnsapi,DnsNameCompareEx_UTF8)
DeclareProxyFunc(dnsapi,DnsNameCompareEx_W)
DeclareProxyFunc(dnsapi,DnsNameCopy)
DeclareProxyFunc(dnsapi,DnsNameCopyAllocate)
DeclareProxyFunc(dnsapi,DnsNetworkInfo_CreateFromFAZ)
DeclareProxyFunc(dnsapi,DnsNetworkInformation_CreateFromFAZ)
DeclareProxyFunc(dnsapi,DnsNotifyResolver)
DeclareProxyFunc(dnsapi,DnsNotifyResolverClusterIp)
DeclareProxyFunc(dnsapi,DnsNotifyResolverEx)
DeclareProxyFunc(dnsapi,DnsQuery_A)
DeclareProxyFunc(dnsapi,DnsQuery_UTF8)
DeclareProxyFunc(dnsapi,DnsQuery_W)
DeclareProxyFunc(dnsapi,DnsQueryConfig)
DeclareProxyFunc(dnsapi,DnsQueryConfigAllocEx)
DeclareProxyFunc(dnsapi,DnsQueryConfigDword)
DeclareProxyFunc(dnsapi,DnsQueryEx)
DeclareProxyFunc(dnsapi,DnsQueryExA)
DeclareProxyFunc(dnsapi,DnsQueryExUTF8)
DeclareProxyFunc(dnsapi,DnsQueryExW)
DeclareProxyFunc(dnsapi,DnsRecordBuild_UTF8)
DeclareProxyFunc(dnsapi,DnsRecordBuild_W)
DeclareProxyFunc(dnsapi,DnsRecordCompare)
DeclareProxyFunc(dnsapi,DnsRecordCopyEx)
DeclareProxyFunc(dnsapi,DnsRecordListFree)
DeclareProxyFunc(dnsapi,DnsRecordListUnmapV4MappedAAAAInPlace)
DeclareProxyFunc(dnsapi,DnsRecordSetCompare)
DeclareProxyFunc(dnsapi,DnsRecordSetCopyEx)
DeclareProxyFunc(dnsapi,DnsRecordSetDetach)
DeclareProxyFunc(dnsapi,DnsRecordStringForType)
DeclareProxyFunc(dnsapi,DnsRecordStringForWritableType)
DeclareProxyFunc(dnsapi,DnsRecordTypeForName)
DeclareProxyFunc(dnsapi,DnsRegisterLocal)
DeclareProxyFunc(dnsapi,DnsReleaseContextHandle)
DeclareProxyFunc(dnsapi,DnsRemoveNrptRule)
DeclareProxyFunc(dnsapi,DnsRemoveRegistrations)
DeclareProxyFunc(dnsapi,DnsReplaceRecordSetA)
DeclareProxyFunc(dnsapi,DnsReplaceRecordSetUTF8)
DeclareProxyFunc(dnsapi,DnsReplaceRecordSetW)
DeclareProxyFunc(dnsapi,DnsResetQueryRetryTimeouts)
DeclareProxyFunc(dnsapi,DnsResolverOp)
DeclareProxyFunc(dnsapi,DnsResolverQueryHvsi)
DeclareProxyFunc(dnsapi,DnsScreenLocalAddrsForRegistration)
DeclareProxyFunc(dnsapi,DnsServiceBrowse)
DeclareProxyFunc(dnsapi,DnsServiceBrowseCancel)
DeclareProxyFunc(dnsapi,DnsServiceConstructInstance)
DeclareProxyFunc(dnsapi,DnsServiceCopyInstance)
DeclareProxyFunc(dnsapi,DnsServiceDeRegister)
DeclareProxyFunc(dnsapi,DnsServiceFreeInstance)
DeclareProxyFunc(dnsapi,DnsServiceRegister)
DeclareProxyFunc(dnsapi,DnsServiceRegisterCancel)
DeclareProxyFunc(dnsapi,DnsServiceResolve)
DeclareProxyFunc(dnsapi,DnsServiceResolveCancel)
DeclareProxyFunc(dnsapi,DnsSetConfigDword)
DeclareProxyFunc(dnsapi,DnsSetConfigValue)
DeclareProxyFunc(dnsapi,DnsSetInterfaceSettings)
DeclareProxyFunc(dnsapi,DnsSetNrptRule)
DeclareProxyFunc(dnsapi,DnsSetNrptRules)
DeclareProxyFunc(dnsapi,DnsSetQueryRetryTimeouts)
DeclareProxyFunc(dnsapi,DnsSetSettings)
DeclareProxyFunc(dnsapi,DnsStartMulticastQuery)
DeclareProxyFunc(dnsapi,DnsStopMulticastQuery)
DeclareProxyFunc(dnsapi,DnsStringCopyAllocateEx)
DeclareProxyFunc(dnsapi,DnsTraceServerConfig)
DeclareProxyFunc(dnsapi,DnsUpdate)
DeclareProxyFunc(dnsapi,DnsUpdateMachinePresence)
DeclareProxyFunc(dnsapi,DnsUpdateTest_A)
DeclareProxyFunc(dnsapi,DnsUpdateTest_UTF8)
DeclareProxyFunc(dnsapi,DnsUpdateTest_W)
DeclareProxyFunc(dnsapi,DnsValidateName_A)
DeclareProxyFunc(dnsapi,DnsValidateName_UTF8)
DeclareProxyFunc(dnsapi,DnsValidateName_W)
DeclareProxyFunc(dnsapi,DnsValidateNameOrIp_TempW)
DeclareProxyFunc(dnsapi,DnsValidateServer_A)
DeclareProxyFunc(dnsapi,DnsValidateServer_W)
DeclareProxyFunc(dnsapi,DnsValidateServerArray_A)
DeclareProxyFunc(dnsapi,DnsValidateServerArray_W)
DeclareProxyFunc(dnsapi,DnsValidateServerStatus)
DeclareProxyFunc(dnsapi,DnsValidateUtf8Byte)
DeclareProxyFunc(dnsapi,DnsWriteQuestionToBuffer_UTF8)
DeclareProxyFunc(dnsapi,DnsWriteQuestionToBuffer_W)
DeclareProxyFunc(dnsapi,DnsWriteReverseNameStringForIpAddress)
DeclareProxyFunc(dnsapi,ExtraInfo_Init)
DeclareProxyFunc(dnsapi,Faz_AreServerListsInSameNameSpace)
DeclareProxyFunc(dnsapi,FlushDnsPolicyUnreachableStatus)
DeclareProxyFunc(dnsapi,GetCurrentTimeInSeconds)
DeclareProxyFunc(dnsapi,HostsFile_Close)
DeclareProxyFunc(dnsapi,HostsFile_Open)
DeclareProxyFunc(dnsapi,HostsFile_ReadLine)
DeclareProxyFunc(dnsapi,IpHelp_IsAddrOnLink)
DeclareProxyFunc(dnsapi,Local_GetRecordsForLocalName)
DeclareProxyFunc(dnsapi,Local_GetRecordsForLocalNameEx)
DeclareProxyFunc(dnsapi,NetInfo_Build)
DeclareProxyFunc(dnsapi,NetInfo_Clean)
DeclareProxyFunc(dnsapi,NetInfo_Copy)
DeclareProxyFunc(dnsapi,NetInfo_CopyNetworkIndex)
DeclareProxyFunc(dnsapi,NetInfo_CreatePerNetworkNetinfo)
DeclareProxyFunc(dnsapi,NetInfo_Free)
DeclareProxyFunc(dnsapi,NetInfo_GetAdapterByAddress)
DeclareProxyFunc(dnsapi,NetInfo_GetAdapterByInterfaceIndex)
DeclareProxyFunc(dnsapi,NetInfo_GetAdapterByName)
DeclareProxyFunc(dnsapi,NetInfo_IsAddrConfig)
DeclareProxyFunc(dnsapi,NetInfo_IsForUpdate)
DeclareProxyFunc(dnsapi,NetInfo_IsTcpipConfigChange)
DeclareProxyFunc(dnsapi,NetInfo_ResetServerPriorities)
DeclareProxyFunc(dnsapi,NetInfo_UpdateDnsInterfaceConfigChange)
DeclareProxyFunc(dnsapi,NetInfo_UpdateNetworkProperties)
DeclareProxyFunc(dnsapi,NetInfo_UpdateServerReachability)
DeclareProxyFunc(dnsapi,Query_Cancel)
DeclareProxyFunc(dnsapi,Query_Main)
DeclareProxyFunc(dnsapi,QueryDirectEx)
DeclareProxyFunc(dnsapi,Reg_FreeUpdateInfo)
DeclareProxyFunc(dnsapi,Reg_GetValueEx)
DeclareProxyFunc(dnsapi,Reg_ReadGlobalsEx)
DeclareProxyFunc(dnsapi,Reg_ReadUpdateInfo)
DeclareProxyFunc(dnsapi,Security_ContextListTimeout)
DeclareProxyFunc(dnsapi,Send_AndRecvUdpWithParam)
DeclareProxyFunc(dnsapi,Send_MessagePrivate)
DeclareProxyFunc(dnsapi,Send_MessagePrivateEx)
DeclareProxyFunc(dnsapi,Send_OpenTcpConnectionAndSend)
DeclareProxyFunc(dnsapi,Socket_CacheCleanup)
DeclareProxyFunc(dnsapi,Socket_CacheInit)
DeclareProxyFunc(dnsapi,Socket_CleanupWinsock)
DeclareProxyFunc(dnsapi,Socket_ClearMessageSockets)
DeclareProxyFunc(dnsapi,Socket_CloseEx)
DeclareProxyFunc(dnsapi,Socket_CloseMessageSockets)
DeclareProxyFunc(dnsapi,Socket_Create)
DeclareProxyFunc(dnsapi,Socket_CreateMulticast)
DeclareProxyFunc(dnsapi,Socket_InitWinsock)
DeclareProxyFunc(dnsapi,Socket_JoinMulticast)
DeclareProxyFunc(dnsapi,Socket_RecvFrom)
DeclareProxyFunc(dnsapi,Socket_SetMulticastInterface)
DeclareProxyFunc(dnsapi,Socket_SetMulticastLoopBack)
DeclareProxyFunc(dnsapi,Socket_SetTtl)
DeclareProxyFunc(dnsapi,Socket_TcpListen)
DeclareProxyFunc(dnsapi,Trace_Reset)
DeclareProxyFunc(dnsapi,Update_ReplaceAddressRecordsW)
DeclareProxyFunc(dnsapi,Util_IsIp6Running)
DeclareProxyFunc(dnsapi,Util_IsRunningOnXboxOne)
DeclareProxyFunc(dnsapi,WriteDnsNrptRulesToRegistry)

; x64 only ???
DeclareProxyFunc(dnsapi,Dns_ReadPacketName)
DeclareProxyFunc(dnsapi,Dns_ReadPacketNameAllocate)
DeclareProxyFunc(dnsapi,Dns_SkipPacketName)
DeclareProxyFunc(dnsapi,Dns_WriteDottedNameToPacket)
DeclareProxyFunc(dnsapi,DnsGetDomainName)
DeclareProxyFunc(dnsapi,DnsIsAMailboxType)
DeclareProxyFunc(dnsapi,DnsIsNSECType)
DeclareProxyFunc(dnsapi,DnsIsStatusRcode)
DeclareProxyFunc(dnsapi,DnsMapRcodeToStatus)
DeclareProxyFunc(dnsapi,DnsStatusString)
DeclareProxyFunc(dnsapi,DnsUnicodeToUtf8)
DeclareProxyFunc(dnsapi,DnsUtf8ToUnicode)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; EnableAsm
; DisableDebugger
; EnableExeConstant