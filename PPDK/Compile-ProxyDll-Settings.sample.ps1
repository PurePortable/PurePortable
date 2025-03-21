# Переименовать данный скрипт в Compile-ProxyDll-Settings.ps1
# Исправить пути.
# Можно задать относительные пути относительно модуля

$Compiler32 = "..\..\PureBasic\6.04.x86\Compilers\pbcompiler.exe"
$Compiler64 = "..\..\PureBasic\6.04.x64\Compilers\pbcompiler.exe"
$CorrectExportC = "$PSScriptRoot\PPCorrectExportC.exe"

# Можно использовать списки путей.
# Будет использован первый существующий.
<#
$Compiler32 = @(
  "..\..\6.04.x86\Compilers\pbcompiler.exe"
)
$Compiler64 = @(
  "..\..\6.04.x64\Compilers\pbcompiler.exe"
)
#>
