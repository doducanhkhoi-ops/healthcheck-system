Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  CÀI ĐẶT / CẬP NHẬT HỆ THỐNG KIỂM TRA SỨC KHỎE OS   " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

$sourcePs1 = "$PSScriptRoot\AutoSystemCheck.ps1"
$docPs1 = "$env:USERPROFILE\Documents\AutoSystemCheck.ps1"
$startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$vbsPath = "$startupDir\AutoSystemCheck.vbs"

if (-not (Test-Path $sourcePs1)) {
    Write-Host "LỖI: Không tìm thấy file nguồn AutoSystemCheck.ps1!" -ForegroundColor Red
    exit 1
}

# 1. Sao chép script chính mới nhất vào Documents
Copy-Item -Path $sourcePs1 -Destination $docPs1 -Force
Write-Host "✓ Đã sao chép phiên bản mới nhất vào:" -ForegroundColor Green
Write-Host "  -> $docPs1" -ForegroundColor Gray

# 2. Tạo hoặc cập nhật file chạy ngầm trong thư mục Startup
if (-not (Test-Path $startupDir)) {
    New-Item -Path $startupDir -ItemType Directory -Force | Out-Null
}

$vbsContent = @'
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{0}""", 0, False
'@ -f $docPs1

Set-Content -Path $vbsPath -Value $vbsContent -Encoding Ascii
Write-Host "✓ Đã thiết lập kích hoạt tự động tại Startup:" -ForegroundColor Green
Write-Host "  -> $vbsPath" -ForegroundColor Gray

Write-Host "`nĐẨY CODE MỚI LÊN STARTUP THÀNH CÔNG! ✅" -ForegroundColor Green
Write-Host "Hệ thống sẽ tự động dọn rác bộ máy và bật báo cáo mỗi khi bật máy." -ForegroundColor Yellow
Write-Host "Muốn chạy thử ngay lập tức? Chạy: powershell -ExecutionPolicy Bypass -File .\AutoSystemCheck.ps1 -Quick" -ForegroundColor Cyan
Start-Sleep -Seconds 2
