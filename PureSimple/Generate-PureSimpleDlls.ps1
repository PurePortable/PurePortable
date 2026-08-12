$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$PSScriptRoot\bin\x32"
$Dir64 = "$PSScriptRoot\bin\x64"

Import-Module "..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start

$L1 = @(
  "pureport", "winmm", "version"
  "advapi32", "comdlg32"
)
$L2 = @( # Требующие коррекцию экспорта
  "kernel32"
)
$N = $L1.Length + $L2.Length
$I = 0
foreach ($name in $L1) {
  $I++
  Write-Host "$I / $N" -Bac DarkBlue
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-0" -C "PORTABLE_REGISTRY=0"
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-1" -C "PORTABLE_REGISTRY=1"
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-2" -C "PORTABLE_REGISTRY=2"
}
foreach ($name in $L2) { 
  $I++
  Write-Host "$I / $N" -Bac DarkBlue
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-0" -C "PORTABLE_REGISTRY=0" -CorrectExport
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-1" -C "PORTABLE_REGISTRY=1" -CorrectExport
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-2" -C "PORTABLE_REGISTRY=2" -CorrectExport
}

Compile-ProxyDll-Result
