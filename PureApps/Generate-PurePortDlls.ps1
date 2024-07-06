$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $CurrentDir
[System.IO.Directory]::SetCurrentDirectory($CurrentDir)

$Dir32 = "bin\x32"
$Dir64 = "bin\x64"

.\Compile-ProxyDll "PurePort" "PurePort" -RC "PurePort" -InternalName "pureport-0" -FileDescription "Without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-0" -C "PORTABLE_REGISTRY=0"
.\Compile-ProxyDll "PurePort" "PurePort" -RC "PurePort" -InternalName "pureport-1" -FileDescription "With Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1" -C "PORTABLE_REGISTRY=1"
.\Compile-ProxyDll "PurePort" "PurePort" -RC "PurePort" -InternalName "pureport-1" -FileDescription "With Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1xp" -C "PORTABLE_REGISTRY=1","PROXY_DLL_COMPATIBILITY=5" -x32
.\Compile-ProxyDll "PurePort" "PurePort" -RC "PurePort" -InternalName "pureport-2" -FileDescription "With Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-2" -C "PORTABLE_REGISTRY=2"

.\Compile-ProxyDll "PurePort" "AdvApi32" -RC "PurePort" -InternalName "advapi32-1" -FileDescription "With Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "AdvApi32-1" -C "PORTABLE_REGISTRY=1"
.\Compile-ProxyDll "PurePort" "AdvApi32" -RC "PurePort" -InternalName "advapi32-2" -FileDescription "With Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "AdvApi32-2" -C "PORTABLE_REGISTRY=2"
