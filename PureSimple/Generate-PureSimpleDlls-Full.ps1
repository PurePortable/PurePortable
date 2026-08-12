$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$PSScriptRoot\bin\x32f"
$Dir64 = "$PSScriptRoot\bin\x64f"

Import-Module "..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start

$L1 = @(
  "winmm", "version", "version+"
  "avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "dwrite", "glu32", "iphlpapi", "ktmw32"
  "mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "propsys", "secur32"
  "shfolder", "urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wtsapi32", "vcruntime140"
  "comdlg32", "wintrust", "shell32", "advapi32"
)
$L2 = @( # Требующие коррекцию экспорта
  "msimg32", "kernel32", "user32"
)
$L3 = @( # С нестандартным расширением
  @{name="winspool";ext="drv"}
)
$N = $L1.Length + $L2.Length + $L3.Length
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
foreach ($src in $L3) {
  $name = $src.name
  $ext = $src.ext
  $I++
  Write-Host "$I / $N" -Bac DarkBlue
  Compile-ProxyDll "PureSimple" "winspool" -InternalName "$name-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-0.$ext" -C "PORTABLE_REGISTRY=0"
  Compile-ProxyDll "PureSimple" "winspool" -InternalName "$name-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-1.$ext" -C "PORTABLE_REGISTRY=1"
  Compile-ProxyDll "PureSimple" "winspool" -InternalName "$name-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-2.$ext" -C "PORTABLE_REGISTRY=2"
}

Compile-ProxyDll-Result
