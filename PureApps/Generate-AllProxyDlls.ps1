
$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $CurrentDir
[System.IO.Directory]::SetCurrentDirectory($CurrentDir)

$Dir32 = "x32"
$Dir64 = "x64"

@(
	"winmm", "version", "version+"
	"avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "glu32", "iphlpapi"
	"mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "secur32"
	"urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wintrust", "wtsapi32"
	"shfolder"
) | foreach { .\Compile-ProxyDll "Proxy" $_ -Dir32 $Dir32 -Dir64 $Dir64 }

@(
	"msimg32"
	#"comctl32"
	#"shell32"
	#"user32"
) | foreach {.\Compile-ProxyDll "Proxy" $_ -Dir32 $Dir32 -Dir64 $Dir64 -CorrectExport}

.\Compile-ProxyDll "Proxy" "winspool" -Dir32 $Dir32 -Dir64 $Dir64 -Out "winspool.drv"
