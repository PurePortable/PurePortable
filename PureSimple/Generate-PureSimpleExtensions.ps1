$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit "$ScriptDir\extensions"
[System.IO.Directory]::SetCurrentDirectory("$ScriptDir\extensions")

$Dir32 = "$PSScriptRoot\bin\x32\extensions"
$Dir64 = "$PSScriptRoot\bin\x64\extensions"
$RcFile = "$PSScriptRoot\PureSimpleExtension.rc"

Import-Module "$PSScriptRoot\..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start

Compile-ProxyDll "PureExtensionIni" "PurePort" -RC $RcFile -IN "PurePortIni" -OF "PurePortIni" -FD "PurePortableSimpleExtension: Modify configs (ini, xml, json)" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePortIni"
Compile-ProxyDll "PureExtensionMFO" "PurePort" -RC $RcFile -IN "PurePortMFO" -OF "PurePortMFO" -FD "PurePortableSimpleExtension: Monitoring File Operations" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePortMFO"

Compile-ProxyDll-Result
