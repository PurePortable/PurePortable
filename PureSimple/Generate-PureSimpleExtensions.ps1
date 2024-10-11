$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$ScriptDir\bin\x32\extensions"
$Dir64 = "$ScriptDir\bin\x64\extensions"

..\PPDK\Compile-ProxyDll "PureExtensionIni" "PurePort" -RC "PureSimpleExtension" -IN "PurePortIni" -OF "PurePortIni" -FD "PurePortableSimpleExtension" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePortIni"
