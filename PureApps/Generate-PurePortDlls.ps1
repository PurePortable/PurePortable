$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $CurrentDir
[System.IO.Directory]::SetCurrentDirectory($CurrentDir)

$Dir32 = "x32"
$Dir64 = "x64"

.\Compile-ProxyDll "PureApps" "PurePort" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort0" -C "PORTABLE_REGISTRY=0" -RC "PureApps0"
.\Compile-ProxyDll "PureApps" "PurePort" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort1" -C "PORTABLE_REGISTRY=1" -RC "PureApps1"
.\Compile-ProxyDll "PureApps" "PurePort" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort1xp" -C "PORTABLE_REGISTRY=1","PROXY_DLL_COMPATIBILITY=5" -x32 -RC "PureApps1"
.\Compile-ProxyDll "PureApps" "PurePort" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort2" -C "PORTABLE_REGISTRY=2" -RC "PureApps2"
