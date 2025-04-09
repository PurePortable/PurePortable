$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit "$ScriptDir\extensions"
[System.IO.Directory]::SetCurrentDirectory("$ScriptDir\extensions")

$Dir32 = "$PSScriptRoot\bin\x32\extensions"
$Dir64 = "$PSScriptRoot\bin\x64\extensions"
$RcFile = "$PSScriptRoot\PureSimpleExtension.rc"

Import-Module "$PSScriptRoot\..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start
@(
  @{ Name="PurePortIni";   Descr="PurePortableSimpleExtension: Correction config files (ini, xml, json)" }
  @{ Name="PurePortMFO";   Descr="PurePortableSimpleExtension: Monitoring File Operations" }
  @{ Name="PurePortFonts"; Descr="PurePortableSimpleExtension: Load additional fonts" }
  @{ Name="PurePortPS";    Descr="PurePortableSimpleExtension: Detour WinApi for ini-files" }

) | foreach { Compile-ProxyDll $_.Name "PurePort" -RC $RcFile -IN $_.Name -OF $_.Name -FD $_.Descr -Dir32 $Dir32 -Dir64 $Dir64 -O $_.Name }

Compile-ProxyDll-Result
