
$Build = 8
$Build++
Write-Host "Build: $Build"

function Get-Encoding($File) {
	if (Test-Path -LiteralPath $File -PathType Leaf) {
		$sig = Get-Content -LiteralPath $File -Encoding Byte # -TotalCount 3
		if ($sig[0] -eq 0xEF -and $sig[1] -eq 0xBB -and $sig[2] -eq 0xBF) { return "UTF8" }
		if ($sig[0] -eq 0xFF -and $sig[1] -eq 0xFE) { return "Unicode" }
		return ""
	}
}

<#
FILEVERSION 4,10,0,6
VALUE "FileVersion", "4.10.0.6\0"
;RES_VERSION 4.10.0.6
; VersionField0 = 4.10.0.6
; VersionField5 = 4.10.0.6
#>

function Set-Build($File,$Build) {
	$Enc = Get-Encoding($File)
	$Text = Get-Content $File -Enc $enc
	Write-Host "File: $File"
	for ($i=0;$i -lt $Text.Length;$i++) {
		if ($Text[$i] -match "^FILEVERSION \d+,\d+,\d+,\d+") {
			$Text[$i] = $Text[$i] -replace "^(FILEVERSION \d+,\d+,\d+,)\d+","`${1}$Build"
			Write-Host "  $($Text[$i])"
		}
		elseif ($Text[$i] -match "^\s*VALUE `"FileVersion`", `"\d+.\d+.\d+.\d+") {
			$Text[$i] = $Text[$i] -replace "^(\s*VALUE `"FileVersion`", `"\d+.\d+.\d+.)\d+","`${1}$Build"
			Write-Host "  $($Text[$i])"
		}
		elseif ($Text[$i] -match "^;RES_VERSION \d+.\d+.\d+.\d+") {
			$Text[$i] = $Text[$i] -replace "^(;RES_VERSION \d+.\d+.\d+.)\d+","`${1}$Build"
			Write-Host "  $($Text[$i])"
		}
		elseif ($Text[$i] -match "^; VersionField[05] = \d+.\d+.\d+.\d+") {
			$Text[$i] = $Text[$i] -replace "^(; VersionField[05] = \d+.\d+.\d+.)\d+","`${1}$Build"
			Write-Host "  $($Text[$i])"
		}
	}
	Set-Content $File $Text -Enc $Enc
}

@(
	"Proxy.rc"
	"PureApps1.rc"
	"PureApps2.rc"
	"Proxy.pb"
	"PureApps.pb"
) | foreach {Set-Build $_ $Build}

$Script = $PSCommandPath
$Script
[string[]]$ScriptText = Get-Content $Script
for ($i=0;$i -lt $ScriptText.Length;$i++) {
	#"$i : $($ScriptText[$i])"
	if ($ScriptText[$i] -match "^\`$Build\s*=\s*\d+") {
		$ScriptText[$i] = $ScriptText[$i] -replace "^(\`$Build\s*=\s*)\d+","`${1}$Build"
	}
}
Set-Content $Script $ScriptText -Enc UTF8
Write-Host "Done"
