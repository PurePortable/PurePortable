$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$PSScriptRoot\bin\x32\loaders"
$Dir64 = "$PSScriptRoot\bin\x64\loaders"

Import-Module "..\PPDK\Compile-ProxyDll.psm1" -Force -DisableNameChecking #-ErrorAction SilentlyContinue
Compile-ProxyDll-Start

# Proxy-dlls - загрузчики PureSimple
@(
  "winmm", "version", "version+"
  "avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "dwrite", "glu32", "iphlpapi", "ktmw32"
  "mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "propsys", "secur32"
  "shfolder", "urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wtsapi32", "vcruntime140", "vcruntime140_0"
  "comdlg32", "wintrust"
) | foreach { Compile-ProxyDll "PureSimpleLoader" $_ -Dir32 $Dir32 -Dir64 $Dir64 }

# Загрузчики, требующие коррекцию экспорта
@(
  "msimg32"
  "shell32", "user32", "advapi32", "kernel32"
  #"comctl32"
) | foreach { Compile-ProxyDll "PureSimpleLoader" $_ -Dir32 $Dir32 -Dir64 $Dir64 -CorrectExport}

# Загрузчики с нестандартным расширением
Compile-ProxyDll "PureSimpleLoader" "winspool" -Dir32 $Dir32 -Dir64 $Dir64 -Out "winspool.drv"

# Вывод информации об ошибках
Compile-ProxyDll-Result
