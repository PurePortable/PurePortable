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
  [Alias('CO','Comments','Comment')] [string] $FileComment
  ,
  [Parameter(Mandatory=$false)]
  [switch] $x32
  ,
  [Parameter(Mandatory=$false)]
  [switch] $x64
  ,
  [Parameter(Mandatory=$false)]
  [Alias('Dir32')] [string] $OutDir32
  ,
  [Parameter(Mandatory=$false)]
  [Alias('Dir64')] [string] $OutDir64
  ,
  [Parameter(Mandatory=$false)]
  [Alias('CE')] [switch] $CorrectExport
)
#$ScriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$RetCode = 0

. "$PSScriptRoot\Compile-ProxyDll-Settings.ps1"
$Compiler32list = @($Compiler32)
$Compiler64list = @($Compiler64)
$Compiler32 = ""
$Compiler64 = ""
foreach ($exe in $Compiler32list) {
  if ($Compiler32 -eq "") {
    if ($exe.Substring(0,2) -eq "..") { # Относительный путь
      $exe = "$PSScriptRoot\$exe"
    }
    if (Test-Path $exe) {
      $Compiler32 = $exe
    }
  }
}
foreach ($exe in $Compiler64list) {
  if ($Compiler64 -eq "") {
    if ($exe.Substring(0,2) -eq "..") { # Относительный путь
      $exe = "$PSScriptRoot\$exe"
    }
    if (Test-Path $exe) {
      $Compiler64 = $exe
    }
  }
}
if ($x32 -and $Compiler32 -eq "") {
  Write-Error "Compiler x32 was not found"
  exit
}
Write-Host "Compiler x32: $Compiler32"
if ($x64 -and $Compiler64 -eq "") {
  Write-Error "Compiler x64 was not found"
  exit
}
Write-Host "Compiler x64: $Compiler64"

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
  #elseif ($s -match '^#(?<Const>[a-zA-Z_0-9]+)(?<Space>\s*=\s*)(?<Value>\$?[0-9a-f]+)(?<Tail>.*)') { # Остальные числовые константы
  elseif ($s -match '^#(?<Const>[a-zA-Z_0-9]+)(?<Space>\s*=\s*)(?<Value>\[$#]?[_0-9a-z]+)(?<Tail>.*)') { # Остальные числовые константы
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
  $RcFile = "$RC"
}
else {
  $RcFile = "$Src"
}
if ([System.IO.Path]::GetExtension($RC) -eq "") {
  $RcFile = "$RcFile.rc"
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
    $s = $s -replace ',(?<Space>\s*).*',",`"$($Matches.Space)$OriginalFilename\0`""
  }
  elseif ($s -match '^\s*VALUE "FileDescription"' -and $FileDescription -ne "") {
    $s = $s -replace ',(?<Space>\s*).*',",`"$($Matches.Space)$FileDescription\0`""
  }
  elseif ($s -match '^\s*VALUE "Comments"' -and $FileComments -ne "") {
    $s = $s -replace ',(?<Space>\s*).*',",`"$($Matches.Space)$FileComment\0`""
  }
  Add-Content -Lit $RcTmp -Value $s -Enc Unicode
}

# Компиляция x32
if ($x32 -or ((-not $x32) -and (-not $x64))) {
  Write-Host ""
  if ($OutDir32) {
    $SubDir = $OutDir32
    if (-not (Test-Path $SubDir -Type Container)) {
      New-Item $SubDir -Type Directory | Out-Null
    }
  }
  if ((& $Compiler32 /dll /optimizer /thread /output "$SubDir\$OutFile" /resource "$RcTmp" "$SrcTmp") -ne 0) {
    $RetCode += 1
  }
  if ($CorrectExport) {
    & $CorrectExportC "$SubDir\$OutFile"
  }
  Remove-Item -Lit "$SubDir\$OutName.exp" -Force -ErrorAction Ignore
  Remove-Item -Lit "$SubDir\$OutName.lib" -Force -ErrorAction Ignore
}

# Компиляция x64
if ($x64 -or ((-not $x32) -and (-not $x64))) {
  Write-Host ""
  if ($OutDir64) {
    $SubDir = $OutDir64
    if (-not (Test-Path $SubDir -Type Container)) {
      New-Item $SubDir -Type Directory | Out-Null
    }
  }
  if ((& $Compiler64 /dll /optimizer /thread /output "$SubDir\$OutFile" /resource "$RcTmp" "$SrcTmp") -ne 0) {
    $RetCode += 2
  }
  if ($CorrectExport) {
    & $CorrectExportC "$SubDir\$OutFile"
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

#return $RetCode
