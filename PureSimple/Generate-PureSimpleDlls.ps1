$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$ScriptDir\bin\x32"
$Dir64 = "$ScriptDir\bin\x64"

.\Compile-ProxyDll "PureSimple" "PurePort" -InternalName "pureport-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-0" -C "PORTABLE_REGISTRY=0"
.\Compile-ProxyDll "PureSimple" "PurePort" -InternalName "pureport-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1" -C "PORTABLE_REGISTRY=1"
.\Compile-ProxyDll "PureSimple" "PurePort" -InternalName "pureport-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1xp" -C "PORTABLE_REGISTRY=1","PROXY_DLL_COMPATIBILITY=5" -x32
.\Compile-ProxyDll "PureSimple" "PurePort" -InternalName "pureport-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-2" -C "PORTABLE_REGISTRY=2"

.\Compile-ProxyDll "PureSimple" "AdvApi32" -InternalName "advapi32-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "AdvApi32-1" -C "PORTABLE_REGISTRY=1"
.\Compile-ProxyDll "PureSimple" "AdvApi32" -InternalName "advapi32-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "AdvApi32-2" -C "PORTABLE_REGISTRY=2"
