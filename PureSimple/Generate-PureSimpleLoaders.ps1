
$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
#Set-Location -Lit $ScriptDir
#[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$ScriptDir\bin\x32\loaders"
$Dir64 = "$ScriptDir\bin\x64\loaders"

#New-Item $Dir32 -Type Dir
#New-Item $Dir64 -Type Dir

# Proxy-dlls - загрузчики PureSimple
@(
	"winmm", "version", "version+"
	"avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "glu32", "iphlpapi", "ktmw32.pbi"
	"mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "secur32"
	"urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wintrust", "wtsapi32"
	"shfolder", "vcruntime140"
) | foreach { ..\PPDK\Compile-ProxyDll "PureSimpleLoader" $_ -Dir32 $Dir32 -Dir64 $Dir64 }

# Загрузчики, требующие коррекцию экспорта
@(
	"msimg32"
	"shell32"
	"user32"
	"advapi32"
	#"comctl32"
) | foreach {..\PPDK\Compile-ProxyDll "PureSimpleLoader" $_ -Dir32 $Dir32 -Dir64 $Dir64 -CorrectExport}

# Загрузчики с нестандартным расширением
..\PPDK\Compile-ProxyDll "PureSimpleLoader" "winspool" -Dir32 $Dir32 -Dir64 $Dir64 -Out "winspool.drv"
