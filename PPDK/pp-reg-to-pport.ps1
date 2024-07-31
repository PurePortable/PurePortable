<#
TODO:
	- многострочные значения с символами перевода строки
	- REG_EXPAND_SZ
	- @
#>

param(
	[Parameter(Mandatory,Position=0)] [string] [ValidateNotNullOrEmpty()] $File
)

#$del = "" # старый разделитель полей (служебный символ U+0016=22)
$del = "" # разделитель полей (символ U+E800=59392 из области для частного использования)
$ctl = 57344 # начало таблицы (U+E000) из области для частного использования для кодирования служебных символов

$cfgfile = ($File -replace "\.[^.\\:]+$","") + ".pport"

Set-Content -Lit $cfgfile "" -Enc Unicode -NoNewline
$key = ""
$reg = Get-Content -Lit $File
$i = 0
$m = $reg.Length
while ( $i -le $m ) {
	$s = $reg[$i]
	if ($s -match "^\s+" -or $s -match "^;") {
		# комментарий
	}
	elseif ( $s -match "^\[HKEY_[^\\]+\\(.+)\]$") {
		$key = $Matches[1].ToLower()
	}
	elseif ($key) {
		if ($s -match '^"(?<val>[^"]+)"=(?<data>.+)') {
			$val = $Matches.val.ToLower()
			$data = $Matches.data
			if ($data -match '^dword:(?<dword>[a-f0-9]+)') {
				$dword = $Matches.dword
				Add-Content -Lit $cfgfile ("$key$del$val$del"+"d$del$dword") -Enc Unicode
			}
			elseif ($data -match '^hex:(?<hex>.*)') { # REG_BINARY
				$hex = $Matches.hex -replace ",",""
				while ($hex.EndsWith('\')) {
					$i++
					$s = $reg[$i]
					$hex = ($hex -replace "\\$","") + ($s -replace "[\s,]","")
				}
				Add-Content -Lit $cfgfile ("$key$del$val$del"+"b"+"$del$hex") -Enc Unicode
			}
			elseif ($data -match '^hex\((?<type>.+)\):(?<hex>.*)') { # Другие типы в бинарном виде
				$hex = $Matches.hex -replace ",",""
				$type = $Matches.type.ToUpper()
				while ($hex.EndsWith('\')) {
					$i++
					$s = $reg[$i]
					$hex = ($hex -replace "\\$","") + ($s -replace "[\s,]","")
				}
				Add-Content -Lit $cfgfile ("$key$del$val$del"+$type+"$del$hex") -Enc Unicode
			}
			elseif ($data -match '^"(?<str>.*)"$') {
				$str = $Matches.str -replace '\\([\\"])','$1'
				Add-Content -Lit $cfgfile ("$key$del$val$del"+"s"+"$del$str") -Enc Unicode
			}
			else {
				Write-Host "Unknown data: $s"
			}
		}
	}
	$i++
}
