; HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID ???
;Procedure RegOpenKeyS(hKey,key.s,*hk)
;	ProcedureReturn Bool(RegOpenKey_(hKey,@key,*hk)=#ERROR_SUCCESS)
;EndProcedure
Procedure.s GuidInfo(*id)
	;Protected guid.s = guid2s(*id)
	Protected guid.s = Space(40)
	StringFromGUID2_(*id,@guid,40)
	;guid = Trim(guid)
	Protected hk, size
	Protected info.s ;= Space(256)
	If guid
		If RegOpenKey_(#HKEY_CLASSES_ROOT,"CLSID\"+guid,@hk)=#ERROR_SUCCESS
			info = Space(256)
			size = 512
			If RegQueryValueEx_(hk,#Null,#Null,#Null,@info,@size)=#ERROR_SUCCESS
				info = "HKCR\CLSID\"+guid+" «"+info+"»"
			Else
				info = guid
			EndIf
		ElseIf RegOpenKey_(#HKEY_CLASSES_ROOT,"Interface\"+guid,@hk)=#ERROR_SUCCESS
			info = Space(256)
			size = 512
			If RegQueryValueEx_(hk,#Null,#Null,#Null,@info,@size)=#ERROR_SUCCESS
				info = "HKCR\Interface\"+guid+" «"+info+"»"
			Else
				info = guid
			EndIf
		ElseIf RegOpenKey_(#HKEY_CLASSES_ROOT,"TypeLib\"+guid,@hk)=#ERROR_SUCCESS
			info = Space(256)
			size = 512
			If RegQueryValueEx_(hk,#Null,#Null,#Null,@info,@size)=#ERROR_SUCCESS
				info = "HKCR\TypeLib\"+guid+" «"+info+"»"
			Else
				info = guid
			EndIf
		Else
			info = guid
		EndIf
		RegCloseKey_(hk)
	EndIf
	ProcedureReturn info
EndProcedure
