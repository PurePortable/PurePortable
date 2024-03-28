#function Compile-ProxyDll

param (
	[Parameter(Mandatory=$true,Position=0)]
	[Alias('S')] [string] $Src
	,
	[Parameter(Mandatory=$true,Position=1)]
	[Alias('P')] [string] $Proxy
	,
	[Parameter(Mandatory=$false,Position=2)]
	[Alias('R')] [string] $RC
	,
	[Parameter(Mandatory=$false)]
	[Alias('O')] [string] $Out
	,
	[Parameter(Mandatory=$false)]
	[Alias('C')] [string[]] $ConstList
	,
	[Parameter(Mandatory=$false)]
	[switch] $x32
	,
	[Parameter(Mandatory=$false)]
	[switch] $x64
	,
	[Parameter(Mandatory=$false)]
	[string] $Dir32
	,
	[Parameter(Mandatory=$false)]
	[string] $Dir64
	,
	[Parameter(Mandatory=$false)]
	[switch] $CorrectExport
)
$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$Tmp = "~tmp.pb"
$SubDir = "."
$SrcFile = "$Src.pb"
if ($PSBoundParameters.ContainsKey('Out')) {
	$OutFile = $Out
}
else {
	$OutFile = $Proxy
}
if ([System.IO.Path]::GetExtension($OutFile) -eq "") {
	$OutFile += ".dll"
}
$OutName = [System.IO.Path]::GetFileNameWithoutExtension($OutFile)
Write-Host "Compile $OutName" -bac DarkBlue
if ($RC) {
	$RCFile = "$RC.rc"
}
else {
	$RCFile = "$Src.rc"
}
$Constants = @{}
if ($PSBoundParameters.ContainsKey('ConstList')) { # Список констант, которые заменяем в исходном файле
	foreach ($Const in $ConstList) {
		$c,$v = $Const -split "="
		$Constants += @{ $c = $v }
	}
}
Set-Content -Lit $Tmp -Force -Value "" -Enc UTF8 -NoNewLine
Get-Content -Lit $SrcFile -Enc UTF8 | foreach {
	$s = $_
	if ($s -match '^#PROXY_DLL\s+=\s+"[^"]+"') { # Константа PROXY_DLL на особом счету
		$s = $s -replace '^(#PROXY_DLL\s+=\s+)"[^"]+"',"`$1`"$Proxy`""
	}
	elseif ($s -match '^#(?<Const>[a-zA-Z_0-9]+)(?<Space>\s*=\s*")(?<Value>[^"]+)(?<Tail>".*)') { # Остальные строковые константы
		if ($Constants.ContainsKey($Matches.Const)) {
			$ConstName = $Matches.Const
			$ConstValue = $Constants[$ConstName]
			#echo "$ConstName :: $ConstValue"
			$s = "#$($Matches.Const)$($Matches.Space)$ConstValue$($Matches.Tail)"
			#echo "S: $s"
		}
	}
	elseif ($s -match '^#(?<Const>[a-zA-Z_0-9]+)(?<Space>\s*=\s*)(?<Value>\$?[0-9a-f]+)(?<Tail>.*)') { # Остальные числовые константы
		if ($Constants.ContainsKey($Matches.Const)) {
			$ConstName = $Matches.Const
			$ConstValue = $Constants[$ConstName]
			#echo "$ConstName :: $ConstValue"
			$s = "#$($Matches.Const)$($Matches.Space)$ConstValue$($Matches.Tail)"
			#echo "S: $s"
		}
		#echo ($Matches.Const)
	}
	Add-Content -Lit $Tmp -Value $s -Enc UTF8
}
if ($x32 -or ((-not $x32) -and (-not $x64))) { # Компиляция x32
	if ($Dir32) {
		$SubDir = $Dir32
		if (-not (Test-Path $SubDir -Type Container)) {
			New-Item $SubDir -Type Directory
		}
	}
	& "P:\PureBasic\6.04.x86\Compilers\pbcompiler.exe" /dll /optimizer /output "$SubDir\$OutFile" /resource "$RCFile" "$Tmp"
	if ($CorrectExport) {
		.\PPCorrectExportC "$SubDir\$OutFile"
	}
	Remove-Item -Lit "$SubDir\$OutName.exp" -Force -ErrorAction Ignore
	Remove-Item -Lit "$SubDir\$OutName.lib" -Force -ErrorAction Ignore
}
if ($x64 -or ((-not $x32) -and (-not $x64))) { # Компиляция x64
	if ($Dir64) {
		$SubDir = $Dir64
		if (-not (Test-Path $SubDir -Type Container)) {
			New-Item $SubDir -Type Directory
		}
	}
	& "P:\PureBasic\6.04.x64\Compilers\pbcompiler.exe" /dll /optimizer /output "$SubDir\$OutFile" /resource "$RCFile" "$Tmp"
	if ($CorrectExport) {
		.\PPCorrectExportC "$SubDir\$OutFile"
	}
	Remove-Item -Lit "$SubDir\$OutName.exp" -Force -ErrorAction Ignore
	Remove-Item -Lit "$SubDir\$OutName.lib" -Force -ErrorAction Ignore
}
Remove-Item -Lit $Tmp -Force -ErrorAction Ignore
Write-Host ""
Write-Host "Done"
Write-Host ""
