$start = Get-Date

Write-Host "Сканирането започна... Моля, изчакайте, тъй като C: може да съдържа хиляди папки." -ForegroundColor Cyan

$allLogs = Get-ChildItem -Path "C:\" -Filter "*.log" -Recurse -File -ErrorAction SilentlyContinue

$systemLogs = $allLogs | Where-Object { $_.FullName -like "C:\Windows\*" }

$appLogs = $allLogs | Where-Object { $_.FullName -notlike "C:\Windows\*" }

$totalSize = ($allLogs | Measure-Object -Property Length -Sum).Sum / 1MB
$systemSize = ($systemLogs | Measure-Object -Property Length -Sum).Sum / 1MB
$appSize = ($appLogs | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "`n--- РЕЗУЛТАТИ ОТ СКАНЕРА ---" -ForegroundColor Yellow
Write-Host "Общ брой .log файлове: $($allLogs.Count)"
Write-Host "----------------------------"
Write-Host "Системни лог файлове (C:\Windows):"
Write-Host "  - Брой: $($systemLogs.Count)"
Write-Host "  - Размер: $([Math]::Round($systemSize, 2)) MB"

Write-Host "`nЛог файлове на приложения (Users/Program Files/и др.):"
Write-Host "  - Брой: $($appLogs.Count)"
Write-Host "  - Размер: $([Math]::Round($appSize, 2)) MB"

Write-Host "----------------------------"
Write-Host "ОБЩ РАЗМЕР: $([Math]::Round($totalSize, 2)) MB" -ForegroundColor Green

$end = Get-Date
Write-Host "`nВреме за изпълнение: $(($end - $start).Seconds) секунди."
