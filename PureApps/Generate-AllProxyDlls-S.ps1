
$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $CurrentDir
[System.IO.Directory]::SetCurrentDirectory($CurrentDir)

@(
	"winmm", "version", "version+"
	#"avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "glu32", "iphlpapi"
	#"mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "secur32"
	#"urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wintrust", "wtsapi32"
	#"shfolder"
) | foreach { .\Compile-ProxyDll "PureApps" $_ -Dir32 "x32s" -Dir64 "x64s" -RC "Proxy"}

#@(
#	"msimg32"
#	#"shell32", "user32"
#) | foreach {.\Compile-ProxyDll "PureApps" $_ -Dir32 "x32s" -Dir64 "x64s" -CorrectExport -RC "Proxy"}

#.\Compile-ProxyDll "PureApps" "winspool" -Dir32 "x32s" -Dir64 "x64s" -Out "winspool.drv -RC "Proxy""
