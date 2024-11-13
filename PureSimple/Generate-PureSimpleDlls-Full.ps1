$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$PSScriptRoot\bin\x32f"
$Dir64 = "$PSScriptRoot\bin\x64f"

Import-Module "..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start

@(
  "winmm", "version", "version+"
  "avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "glu32", "iphlpapi", "ktmw32"
  "mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "secur32"
  "shfolder", "urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wtsapi32", "vcruntime140"
  "comdlg32", "wintrust"
) | foreach {
  $name = $_
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-0" -C "PORTABLE_REGISTRY=0"
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-1" -C "PORTABLE_REGISTRY=1"
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-2" -C "PORTABLE_REGISTRY=2"
}
# Требующие коррекцию экспорта
@(
  "msimg32"
  "shell32", "user32", "advapi32", "kernel32"
  #"comctl32"
) | foreach { 
  $name = $_
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-0" -C "PORTABLE_REGISTRY=0" -CorrectExport
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-1" -C "PORTABLE_REGISTRY=1" -CorrectExport
  Compile-ProxyDll "PureSimple" "$name" -InternalName "$name-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "$name-2" -C "PORTABLE_REGISTRY=2" -CorrectExport
}
# С нестандартным расширением
Compile-ProxyDll "PureSimple" "winspool" -InternalName "winspool-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "winspool-0.drv" -C "PORTABLE_REGISTRY=0"
Compile-ProxyDll "PureSimple" "winspool" -InternalName "winspool-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "winspool-1.drv" -C "PORTABLE_REGISTRY=1"
Compile-ProxyDll "PureSimple" "winspool" -InternalName "winspool-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "winspool-2.drv" -C "PORTABLE_REGISTRY=2"

Compile-ProxyDll-Result
