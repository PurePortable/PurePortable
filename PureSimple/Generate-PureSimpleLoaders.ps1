
$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
#Set-Location -Lit $ScriptDir
#[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$ScriptDir\bin\x32\loaders"
$Dir64 = "$ScriptDir\bin\x64\loaders"

Import-Module "..\PPDK\Compile-ProxyDll-Module.ps1"

$SrcErr = [System.Collections.Generic.List[string]]::new()

# Proxy-dlls - загрузчики PureSimple
@(
	"winmm", "version", "version+"
	"avifil32", "dbghelp", "ddraw", "dinput", "dnsapi", "dwmapi", "glu32", "iphlpapi", "ktmw32"
	"mpr", "msacm32", "mscms", "msi", "msvbvm60", "msvfw32", "netapi32", "opengl32", "secur32"
	"urlmon", "userenv", "uxtheme", "wer", "winhttp", "wininet", "wintrust", "wtsapi32"
	"shfolder", "vcruntime140"
) | foreach { Compile-ProxyDll "PureSimpleLoader" $_ -EL $SrcErr -Dir32 $Dir32 -Dir64 $Dir64 }

# Загрузчики, требующие коррекцию экспорта
@(
	"msimg32"
	"shell32"
	"user32"
	"advapi32"
	#"comctl32"
) | foreach { Compile-ProxyDll "PureSimpleLoader" $_ -EL $SrcErr -Dir32 $Dir32 -Dir64 $Dir64 -CorrectExport}

# Загрузчики с нестандартным расширением
Compile-ProxyDll "PureSimpleLoader" "winspool" -EL $SrcErr -Dir32 $Dir32 -Dir64 $Dir64 -Out "winspool.drv"

# Вывод информации об ошибках
if ($SrcErr.Count -gt 0) {
    Write-Host "Errors: $($SrcErr.Count)" -For White -Bac DarkRed
    foreach ($Err in $SrcErr) {
        Write-Host $Err
    }
}
else {
    Write-Host "Errors: $($SrcErr.Count)" -For White -Bac DarkGreen
}
Write-Host "Press any key to continue . . . " -For White -NoNewLine
while ($KeyInfo.VirtualKeyCode -eq $Null) { $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
Write-Host ""
