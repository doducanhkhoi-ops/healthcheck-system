Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  GỠ BỎ HỆ THỐNG KIỂM TRA SỨC KHỎE KHỎI STARTUP      " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$vbsPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutoSystemCheck.vbs"
$docPs1 = "$env:USERPROFILE\Documents\AutoSystemCheck.ps1"

$removed = $false

if (Test-Path $vbsPath) {
    Remove-Item -Path $vbsPath -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Đã xóa file tự khởi động trong Startup: AutoSystemCheck.vbs" -ForegroundColor Green
    $removed = $true
} else {
    Write-Host "- Không tìm thấy file trong thư mục Startup." -ForegroundColor Gray
}

if (Test-Path $docPs1) {
    Remove-Item -Path $docPs1 -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Đã xóa script chính tại: Documents\AutoSystemCheck.ps1" -ForegroundColor Green
    $removed = $true
}

if ($removed) {
    Write-Host "`nĐÃ GỠ CÀI ĐẶT THÀNH CÔNG! ✅" -ForegroundColor Green
    Write-Host "Hệ thống sẽ không còn tự động chạy kiểm tra khi khởi động máy." -ForegroundColor Yellow
} else {
    Write-Host "`nHệ thống chưa từng được cài đặt vào Startup." -ForegroundColor Yellow
}

Start-Sleep -Seconds 2
