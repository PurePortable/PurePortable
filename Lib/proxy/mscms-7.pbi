﻿; SDK 7.1a

DeclareProxyDll(mscms)

DeclareProxyFunc(mscms,AssociateColorProfileWithDeviceA)
DeclareProxyFunc(mscms,AssociateColorProfileWithDeviceW)
DeclareProxyFunc(mscms,CheckBitmapBits)
DeclareProxyFunc(mscms,CheckColors)
DeclareProxyFunc(mscms,CloseColorProfile)
DeclareProxyFunc(mscms,CloseDisplay)
;DeclareProxyFunc(mscms,ColorAdapterGetCurrentProfileCalibration)
;DeclareProxyFunc(mscms,ColorAdapterGetDisplayCurrentStateID)
;DeclareProxyFunc(mscms,ColorAdapterGetDisplayProfile)
;DeclareProxyFunc(mscms,ColorAdapterGetDisplayTargetWhitePoint)
;DeclareProxyFunc(mscms,ColorAdapterGetDisplayTransformData)
;DeclareProxyFunc(mscms,ColorAdapterGetSystemModifyWhitePointCaps)
;DeclareProxyFunc(mscms,ColorAdapterRegisterOEMColorService)
;DeclareProxyFunc(mscms,ColorAdapterUnregisterOEMColorService)
;DeclareProxyFunc(mscms,ColorAdapterUpdateDeviceProfile)
;DeclareProxyFunc(mscms,ColorAdapterUpdateDisplayGamma)
DeclareProxyFunc(mscms,ColorCplGetDefaultProfileScope)
DeclareProxyFunc(mscms,ColorCplGetDefaultRenderingIntentScope)
DeclareProxyFunc(mscms,ColorCplGetProfileProperties)
DeclareProxyFunc(mscms,ColorCplHasSystemWideAssociationListChanged)
DeclareProxyFunc(mscms,ColorCplInitialize)
DeclareProxyFunc(mscms,ColorCplLoadAssociationList)
DeclareProxyFunc(mscms,ColorCplMergeAssociationLists)
DeclareProxyFunc(mscms,ColorCplOverwritePerUserAssociationList)
DeclareProxyFunc(mscms,ColorCplReleaseProfileProperties)
DeclareProxyFunc(mscms,ColorCplResetSystemWideAssociationListChangedWarning)
DeclareProxyFunc(mscms,ColorCplSaveAssociationList)
DeclareProxyFunc(mscms,ColorCplSetUsePerUserProfiles)
DeclareProxyFunc(mscms,ColorCplUninitialize)
;DeclareProxyFunc(mscms,ColorProfileAddDisplayAssociation)
;DeclareProxyFunc(mscms,ColorProfileGetDisplayDefault)
;DeclareProxyFunc(mscms,ColorProfileGetDisplayList)
;DeclareProxyFunc(mscms,ColorProfileGetDisplayUserScope)
;DeclareProxyFunc(mscms,ColorProfileRemoveDisplayAssociation)
;DeclareProxyFunc(mscms,ColorProfileSetDisplayDefaultAssociation)
DeclareProxyFunc(mscms,ConvertColorNameToIndex)
DeclareProxyFunc(mscms,ConvertIndexToColorName)
DeclareProxyFunc(mscms,CreateColorTransformA)
DeclareProxyFunc(mscms,CreateColorTransformW)
DeclareProxyFunc(mscms,CreateDeviceLinkProfile)
DeclareProxyFunc(mscms,CreateMultiProfileTransform)
DeclareProxyFunc(mscms,CreateProfileFromLogColorSpaceA)
DeclareProxyFunc(mscms,CreateProfileFromLogColorSpaceW)
DeclareProxyFunc(mscms,DccwCreateDisplayProfileAssociationList)
DeclareProxyFunc(mscms,DccwGetDisplayProfileAssociationList)
DeclareProxyFunc(mscms,DccwGetGamutSize)
DeclareProxyFunc(mscms,DccwReleaseDisplayProfileAssociationList)
DeclareProxyFunc(mscms,DccwSetDisplayProfileAssociationList)
DeclareProxyFunc(mscms,DeleteColorTransform)
DeclareProxyFunc(mscms,DeviceRenameEvent)
DeclareProxyFunc(mscms,DisassociateColorProfileFromDeviceA)
DeclareProxyFunc(mscms,DisassociateColorProfileFromDeviceW)
DeclareProxyFunc(mscms,EnumColorProfilesA)
DeclareProxyFunc(mscms,EnumColorProfilesW)
DeclareProxyFunc(mscms,GenerateCopyFilePaths)
DeclareProxyFunc(mscms,GetCMMInfo)
DeclareProxyFunc(mscms,GetColorDirectoryA)
DeclareProxyFunc(mscms,GetColorDirectoryW)
DeclareProxyFunc(mscms,GetColorProfileElement)
DeclareProxyFunc(mscms,GetColorProfileElementTag)
DeclareProxyFunc(mscms,GetColorProfileFromHandle)
DeclareProxyFunc(mscms,GetColorProfileHeader)
DeclareProxyFunc(mscms,GetCountColorProfileElements)
DeclareProxyFunc(mscms,GetNamedProfileInfo)
DeclareProxyFunc(mscms,GetPS2ColorRenderingDictionary)
DeclareProxyFunc(mscms,GetPS2ColorRenderingIntent)
DeclareProxyFunc(mscms,GetPS2ColorSpaceArray)
DeclareProxyFunc(mscms,GetStandardColorSpaceProfileA)
DeclareProxyFunc(mscms,GetStandardColorSpaceProfileW)
DeclareProxyFunc(mscms,InstallColorProfileA)
DeclareProxyFunc(mscms,InstallColorProfileW)
;DeclareProxyFunc(mscms,InternalGetAppliedGammaRamp)
;DeclareProxyFunc(mscms,InternalGetAppliedGDIGammaRamp)
DeclareProxyFunc(mscms,InternalGetDeviceConfig)
;DeclareProxyFunc(mscms,InternalGetDeviceGammaCapability)
DeclareProxyFunc(mscms,InternalGetPS2ColorRenderingDictionary)
;DeclareProxyFunc(mscms,InternalGetPS2ColorRenderingDictionary2)
DeclareProxyFunc(mscms,InternalGetPS2ColorSpaceArray)
;DeclareProxyFunc(mscms,InternalGetPS2ColorSpaceArray2)
DeclareProxyFunc(mscms,InternalGetPS2CSAFromLCS)
DeclareProxyFunc(mscms,InternalGetPS2PreviewCRD)
;DeclareProxyFunc(mscms,InternalGetPS2PreviewCRD2)
DeclareProxyFunc(mscms,InternalRefreshCalibration)
DeclareProxyFunc(mscms,InternalSetDeviceConfig)
;DeclareProxyFunc(mscms,InternalSetDeviceGammaRamp)
;DeclareProxyFunc(mscms,InternalSetDeviceGDIGammaRamp)
;DeclareProxyFunc(mscms,InternalSetDeviceTemperature)
DeclareProxyFunc(mscms,InternalWcsAssociateColorProfileWithDevice)
;DeclareProxyFunc(mscms,InternalWcsDisassociateColorProfileWithDevice)
DeclareProxyFunc(mscms,IsColorProfileTagPresent)
DeclareProxyFunc(mscms,IsColorProfileValid)
DeclareProxyFunc(mscms,OpenColorProfileA)
DeclareProxyFunc(mscms,OpenColorProfileW)
DeclareProxyFunc(mscms,OpenDisplay)
DeclareProxyFunc(mscms,RegisterCMMA)
DeclareProxyFunc(mscms,RegisterCMMW)
DeclareProxyFunc(mscms,SelectCMM)
DeclareProxyFunc(mscms,SetColorProfileElement)
DeclareProxyFunc(mscms,SetColorProfileElementReference)
DeclareProxyFunc(mscms,SetColorProfileElementSize)
DeclareProxyFunc(mscms,SetColorProfileHeader)
DeclareProxyFunc(mscms,SetStandardColorSpaceProfileA)
DeclareProxyFunc(mscms,SetStandardColorSpaceProfileW)
DeclareProxyFunc(mscms,SpoolerCopyFileEvent)
DeclareProxyFunc(mscms,TranslateBitmapBits)
DeclareProxyFunc(mscms,TranslateColors)
DeclareProxyFunc(mscms,UninstallColorProfileA)
DeclareProxyFunc(mscms,UninstallColorProfileW)
DeclareProxyFunc(mscms,UnregisterCMMA)
DeclareProxyFunc(mscms,UnregisterCMMW)
DeclareProxyFunc(mscms,WcsAssociateColorProfileWithDevice)
DeclareProxyFunc(mscms,WcsCheckColors)
DeclareProxyFunc(mscms,WcsCreateIccProfile)
DeclareProxyFunc(mscms,WcsDisassociateColorProfileFromDevice)
DeclareProxyFunc(mscms,WcsEnumColorProfiles)
DeclareProxyFunc(mscms,WcsEnumColorProfilesSize)
DeclareProxyFunc(mscms,WcsGetCalibrationManagementState)
DeclareProxyFunc(mscms,WcsGetDefaultColorProfile)
DeclareProxyFunc(mscms,WcsGetDefaultColorProfileSize)
DeclareProxyFunc(mscms,WcsGetDefaultRenderingIntent)
DeclareProxyFunc(mscms,WcsGetUsePerUserProfiles)
DeclareProxyFunc(mscms,WcsGpCanInstallOrUninstallProfiles)
DeclareProxyFunc(mscms,WcsOpenColorProfileA)
DeclareProxyFunc(mscms,WcsOpenColorProfileW)
DeclareProxyFunc(mscms,WcsSetCalibrationManagementState)
DeclareProxyFunc(mscms,WcsSetDefaultColorProfile)
DeclareProxyFunc(mscms,WcsSetDefaultRenderingIntent)
DeclareProxyFunc(mscms,WcsSetUsePerUserProfiles)
DeclareProxyFunc(mscms,WcsTranslateColors)

; IDE Options = PureBasic 6.04 LTS (Windows - x86)
; CursorPosition = 2
; EnableAsm
; DisableDebugger
; EnableExeConstant