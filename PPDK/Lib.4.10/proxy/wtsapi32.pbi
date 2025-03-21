﻿
DeclareProxyDll(wtsapi32)

DeclareProxyFunc(wtsapi32,WTSCloseServer)
DeclareProxyFunc(wtsapi32,WTSConnectSessionA)
DeclareProxyFunc(wtsapi32,WTSConnectSessionW)
DeclareProxyFunc(wtsapi32,WTSCreateListenerA)
DeclareProxyFunc(wtsapi32,WTSCreateListenerW)
DeclareProxyFunc(wtsapi32,WTSDisconnectSession)
DeclareProxyFunc(wtsapi32,WTSEnableChildSessions)
DeclareProxyFunc(wtsapi32,WTSEnumerateListenersA)
DeclareProxyFunc(wtsapi32,WTSEnumerateListenersW)
DeclareProxyFunc(wtsapi32,WTSEnumerateProcessesA)
DeclareProxyFunc(wtsapi32,WTSEnumerateProcessesExA)
DeclareProxyFunc(wtsapi32,WTSEnumerateProcessesExW)
DeclareProxyFunc(wtsapi32,WTSEnumerateProcessesW)
DeclareProxyFunc(wtsapi32,WTSEnumerateServersA)
DeclareProxyFunc(wtsapi32,WTSEnumerateServersW)
DeclareProxyFunc(wtsapi32,WTSEnumerateSessionsA)
DeclareProxyFunc(wtsapi32,WTSEnumerateSessionsExA)
DeclareProxyFunc(wtsapi32,WTSEnumerateSessionsExW)
DeclareProxyFunc(wtsapi32,WTSEnumerateSessionsW)
DeclareProxyFunc(wtsapi32,WTSFreeMemory)
DeclareProxyFunc(wtsapi32,WTSFreeMemoryExA)
DeclareProxyFunc(wtsapi32,WTSFreeMemoryExW)
DeclareProxyFunc(wtsapi32,WTSGetChildSessionId)
DeclareProxyFunc(wtsapi32,WTSGetListenerSecurityA)
DeclareProxyFunc(wtsapi32,WTSGetListenerSecurityW)
DeclareProxyFunc(wtsapi32,WTSIsChildSessionsEnabled)
DeclareProxyFunc(wtsapi32,WTSLogoffSession)
DeclareProxyFunc(wtsapi32,WTSOpenServerA)
DeclareProxyFunc(wtsapi32,WTSOpenServerExA)
DeclareProxyFunc(wtsapi32,WTSOpenServerExW)
DeclareProxyFunc(wtsapi32,WTSOpenServerW)
DeclareProxyFunc(wtsapi32,WTSQueryListenerConfigA)
DeclareProxyFunc(wtsapi32,WTSQueryListenerConfigW)
DeclareProxyFunc(wtsapi32,WTSQuerySessionInformationA)
DeclareProxyFunc(wtsapi32,WTSQuerySessionInformationW)
DeclareProxyFunc(wtsapi32,WTSQueryUserConfigA)
DeclareProxyFunc(wtsapi32,WTSQueryUserConfigW)
DeclareProxyFunc(wtsapi32,WTSQueryUserToken)
DeclareProxyFunc(wtsapi32,WTSRegisterSessionNotification)
DeclareProxyFunc(wtsapi32,WTSRegisterSessionNotificationEx)
DeclareProxyFunc(wtsapi32,WTSSendMessageA)
DeclareProxyFunc(wtsapi32,WTSSendMessageW)
DeclareProxyFunc(wtsapi32,WTSSetListenerSecurityA)
DeclareProxyFunc(wtsapi32,WTSSetListenerSecurityW)
DeclareProxyFunc(wtsapi32,WTSSetRenderHint)
DeclareProxyFunc(wtsapi32,WTSSetSessionInformationA)
DeclareProxyFunc(wtsapi32,WTSSetSessionInformationW)
DeclareProxyFunc(wtsapi32,WTSSetUserConfigA)
DeclareProxyFunc(wtsapi32,WTSSetUserConfigW)
DeclareProxyFunc(wtsapi32,WTSShutdownSystem)
DeclareProxyFunc(wtsapi32,WTSStartRemoteControlSessionA)
DeclareProxyFunc(wtsapi32,WTSStartRemoteControlSessionW)
DeclareProxyFunc(wtsapi32,WTSStopRemoteControlSession)
DeclareProxyFunc(wtsapi32,WTSTerminateProcess)
DeclareProxyFunc(wtsapi32,WTSUnRegisterSessionNotification)
DeclareProxyFunc(wtsapi32,WTSUnRegisterSessionNotificationEx)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelClose)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelOpen)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelOpenEx)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelPurgeInput)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelPurgeOutput)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelQuery)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelRead)
DeclareProxyFunc(wtsapi32,WTSVirtualChannelWrite)
DeclareProxyFunc(wtsapi32,WTSWaitSystemEvent)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 1
; EnableThread
; DisableDebugger
; EnableExeConstant