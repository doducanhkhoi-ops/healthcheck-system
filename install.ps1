Write-Host "Đang cài đặt Hệ Thống Báo Cáo Sức Khỏe Tự Động..." -ForegroundColor Cyan

$sourcePs1 = "$PSScriptRoot\AutoSystemCheck.ps1"
$docPs1 = "$env:USERPROFILE\Documents\AutoSystemCheck.ps1"
$vbsPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutoSystemCheck.vbs"

# Copy script chính vào Documents
Copy-Item -Path $sourcePs1 -Destination $docPs1 -Force

# Tạo file chạy ngầm (.vbs) trong thư mục Startup
$vbsContent = "Set objShell = CreateObject(""WScript.Shell"")
objShell.Run ""powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """$docPs1""""", 0, False"

Set-Content -Path $vbsPath -Value $vbsContent -Encoding UTF8

Write-Host "Cài đặt THÀNH CÔNG! ✅" -ForegroundColor Green
Write-Host "Máy tính của bạn sẽ tự động dọn rác và hiển thị báo cáo vào mỗi lần khởi động." -ForegroundColor Yellow
Start-Sleep -Seconds 3
