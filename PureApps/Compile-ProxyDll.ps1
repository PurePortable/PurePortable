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
	[Alias('IN')] [string] $InternalName
	,
	[Parameter(Mandatory=$false)]
	[Alias('OF')] [string] $OriginalFilename
	,
	[Parameter(Mandatory=$false)]
	[Alias('FD')] [string] $FileDescription
	,
	[Parameter(Mandatory=$false)]
	[Alias('CO','Comments','Comment')] [string] $FileComments
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
	[Alias('CE')] [switch] $CorrectExport
)
$CurrentDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$Compiler32 = "P:\PureBasic\6.04.x86\Compilers\pbcompiler.exe"
$Compiler64 = "P:\PureBasic\6.04.x64\Compilers\pbcompiler.exe"

$SrcTmp = "~tmp.pb"
$RcTmp = "~tmp.rc"
$SubDir = "."
$SrcFile = "$Src.pb"

# Имя результирующего файла
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

# Список констант, заменяемых в исходном файле
$Constants = @{}
if ($PSBoundParameters.ContainsKey('ConstList')) {
	foreach ($Const in $ConstList) {
		$c,$v = $Const -split "="
		$Constants += @{ $c = $v }
	}
}

# Формирование временного исходного файла
Set-Content -Lit $SrcTmp -Force -Value "" -Enc UTF8 -NoNewLine
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
	Add-Content -Lit $SrcTmp -Value $s -Enc UTF8
}

# Имя файла ресурсов. По умолчанию имя исходного файла с расширением .rc
if ($RC) {
	$RcFile = "$RC.rc"
}
else {
	$RcFile = "$Src.rc"
}
# Параметры для файла ресурсов
if (-not $PSBoundParameters.ContainsKey('InternalName')) {
	$InternalName = $Proxy
}
if (-not $PSBoundParameters.ContainsKey('OriginalFilename')) {
	$OriginalFilename = $Proxy
}

# Формирование временного файла ресурсов
# https://learn.microsoft.com/en-us/windows/win32/menurc/stringfileinfo-block
Set-Content -Lit $RcTmp -Force -Value "" -Enc Unicode
Get-Content -Lit $RcFile -Enc Unicode | foreach {
	$s = $_
	if ($s -match '^\s*VALUE "InternalName"' -and $InternalName -ne "") {
		$s = $s -replace ',(?<Space>\s*).*',",`"$($Matches.Space)$InternalName\0`""
	}
	elseif ($s -match '^\s*VALUE "OriginalFilename"' -and $OriginalFilename -ne "") {

	}
	elseif ($s -match '^\s*VALUE "FileDescription"' -and $FileDescription -ne "") {

	}
	elseif ($s -match '^\s*VALUE "Comments"' -and $FileComments -ne "") {

	}
	Add-Content -Lit $RcTmp -Value $s -Enc Unicode
}

# Компиляция x32
if ($x32 -or ((-not $x32) -and (-not $x64))) {
	if ($Dir32) {
		$SubDir = $Dir32
		if (-not (Test-Path $SubDir -Type Container)) {
			New-Item $SubDir -Type Directory
		}
	}
	& $Compiler32 /dll /optimizer /thread /output "$SubDir\$OutFile" /resource "$RcTmp" "$SrcTmp"
	if ($CorrectExport) {
		.\PPCorrectExportC "$SubDir\$OutFile"
	}
	Remove-Item -Lit "$SubDir\$OutName.exp" -Force -ErrorAction Ignore
	Remove-Item -Lit "$SubDir\$OutName.lib" -Force -ErrorAction Ignore
}

# Компиляция x64
if ($x64 -or ((-not $x32) -and (-not $x64))) {
	if ($Dir64) {
		$SubDir = $Dir64
		if (-not (Test-Path $SubDir -Type Container)) {
			New-Item $SubDir -Type Directory
		}
	}
	& $Compiler64 /dll /optimizer /thread /output "$SubDir\$OutFile" /resource "$RcTmp" "$SrcTmp"
	if ($CorrectExport) {
		.\PPCorrectExportC "$SubDir\$OutFile"
	}
	Remove-Item -Lit "$SubDir\$OutName.exp" -Force -ErrorAction Ignore
	Remove-Item -Lit "$SubDir\$OutName.lib" -Force -ErrorAction Ignore
}

# Завершение
Remove-Item -Lit $SrcTmp -Force -ErrorAction Ignore
Remove-Item -Lit $RcTmp -Force -ErrorAction Ignore
Write-Host ""
Write-Host "Done"
Write-Host ""
