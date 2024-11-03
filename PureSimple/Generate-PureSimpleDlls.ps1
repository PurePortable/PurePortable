$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location -Lit $ScriptDir
[System.IO.Directory]::SetCurrentDirectory($ScriptDir)

$Dir32 = "$ScriptDir\bin\x32"
$Dir64 = "$ScriptDir\bin\x64"

Import-Module "..\PPDK\Compile-ProxyDll-Module.ps1"

$SrcErr = [System.Collections.Generic.List[string]]::new()

Compile-ProxyDll "PureSimple" "pureport" -ErrorList $SrcErr -InternalName "pureport-0" -FileDescription "PureSimple without Registry module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-0" -C "PORTABLE_REGISTRY=0"
Compile-ProxyDll "PureSimple" "pureport" -ErrorList $SrcErr -InternalName "pureport-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1" -C "PORTABLE_REGISTRY=1"
Compile-ProxyDll "PureSimple" "pureport" -ErrorList $SrcErr -InternalName "pureport-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-1xp" -C "PORTABLE_REGISTRY=1","PROXY_DLL_COMPATIBILITY=5" -x32
Compile-ProxyDll "PureSimple" "pureport" -ErrorList $SrcErr -InternalName "pureport-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "PurePort-2" -C "PORTABLE_REGISTRY=2"

Compile-ProxyDll "PureSimple" "advapi32" -ErrorList $SrcErr -InternalName "advapi32-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "advapi32-1" -C "PORTABLE_REGISTRY=1"
Compile-ProxyDll "PureSimple" "advapi32" -ErrorList $SrcErr -InternalName "advapi32-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "advapi32-2" -C "PORTABLE_REGISTRY=2"

Compile-ProxyDll "PureSimple" "comdlg32" -ErrorList $SrcErr -InternalName "comdlg32-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "comdlg32-1" -C "PORTABLE_REGISTRY=1"
Compile-ProxyDll "PureSimple" "comdlg32" -ErrorList $SrcErr -InternalName "comdlg32-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "comdlg32-2" -C "PORTABLE_REGISTRY=2"

Compile-ProxyDll "PureSimple" "kernel32" -ErrorList $SrcErr -InternalName "kernel32-1" -FileDescription "PureSimple with Registry 1 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "kernel32-1" -C "PORTABLE_REGISTRY=1" -CorrectExport
Compile-ProxyDll "PureSimple" "kernel32" -ErrorList $SrcErr -InternalName "kernel32-2" -FileDescription "PureSimple with Registry 2 module" -Dir32 $Dir32 -Dir64 $Dir64 -O "kernel32-2" -C "PORTABLE_REGISTRY=2" -CorrectExport

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
