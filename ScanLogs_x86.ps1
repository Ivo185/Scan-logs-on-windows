# ScanLogs x86 (32-bit) Edition
# Използва 32-битов PowerShell за съвместимост с по-стари системи и среди.
# Ако скриптът се изпълнява в 64-битов PowerShell, той автоматично се рестартира в 32-битов.

if ($env:PROCESSOR_ARCHITECTURE -ne "x86" -and $env:PROCESSOR_ARCHITEW6432 -eq $null -and [IntPtr]::Size -ne 4) {
    $syswow = "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
    if (Test-Path $syswow) {
        Write-Host "[x86] Рестартиране в 32-битов PowerShell..." -ForegroundColor Magenta
        & $syswow -NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"
        exit
    } else {
        Write-Host "[ВНИМАНИЕ] 32-битов PowerShell не е намерен. Продължава в 64-битов режим." -ForegroundColor Yellow
    }
}

$start = Get-Date

Write-Host "ScanLogs x86 (32-bit)" -ForegroundColor Magenta
Write-Host "Архитектура: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor DarkGray
Write-Host "Сканирането започна... Моля, изчакайте, тъй като C: може да съдържа хиляди папки." -ForegroundColor Cyan

# Определяне на пътища за сканиране — x86 включва SysWOW64
$scanPaths = @("C:\")

$allLogs = foreach ($path in $scanPaths) {
    Get-ChildItem -Path $path -Filter "*.log" -Recurse -File -ErrorAction SilentlyContinue
}

$systemLogs = $allLogs | Where-Object { $_.FullName -like "C:\Windows\*" }
$appLogs    = $allLogs | Where-Object { $_.FullName -notlike "C:\Windows\*" }

# x86-специфично: Идентифициране на SysWOW64 лог файлове отделно
$wow64Logs  = $systemLogs | Where-Object { $_.FullName -like "*SysWOW64*" }

$totalSize  = ($allLogs     | Measure-Object -Property Length -Sum).Sum / 1MB
$systemSize = ($systemLogs  | Measure-Object -Property Length -Sum).Sum / 1MB
$appSize    = ($appLogs     | Measure-Object -Property Length -Sum).Sum / 1MB
$wow64Size  = ($wow64Logs   | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "`n--- РЕЗУЛТАТИ ОТ СКАНЕРА (x86) ---" -ForegroundColor Yellow
Write-Host "Общ брой .log файлове: $($allLogs.Count)"
Write-Host "-----------------------------------"

Write-Host "Системни лог файлове (C:\Windows):"
Write-Host "  - Брой: $($systemLogs.Count)"
Write-Host "  - Размер: $([Math]::Round($systemSize, 2)) MB"

Write-Host "`n  от които SysWOW64 (32-bit компоненти):"
Write-Host "  - Брой: $($wow64Logs.Count)"
Write-Host "  - Размер: $([Math]::Round($wow64Size, 2)) MB"

Write-Host "`nЛог файлове на приложения (Users/Program Files/и др.):"
Write-Host "  - Брой: $($appLogs.Count)"
Write-Host "  - Размер: $([Math]::Round($appSize, 2)) MB"

Write-Host "-----------------------------------"
Write-Host "ОБЩ РАЗМЕР: $([Math]::Round($totalSize, 2)) MB" -ForegroundColor Green

$end = Get-Date
Write-Host "`nВреме за изпълнение: $(($end - $start).Seconds) секунди."
Write-Host "Режим: 32-bit (x86)" -ForegroundColor Magenta
