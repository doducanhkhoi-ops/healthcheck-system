# Đợi máy tính khởi động ổn định
Start-Sleep -Seconds 15

# 1. Dọn rác
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\ASUS\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Thu thập dữ liệu
$cpu = Get-CimInstance Win32_Processor
$os = Get-CimInstance Win32_OperatingSystem
$vols = Get-Volume | Where-Object DriveType -eq 'Fixed'

$totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$ramPercent = [math]::Round((($totalRam - $freeRam) / $totalRam) * 100, 2)

# 3. Top tiến trình ngốn tài nguyên
$topCpu = Get-Process | Sort-Object CPU -Descending | Select-Object -First 3
$topRam = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 3

# 4. Kiểm tra An ninh & Virus
$avStatus = "Chưa xác định"
try {
    $av = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($av.RealTimeProtectionEnabled) { $avStatus = "<span class='good'>Đang được bảo vệ (Real-time Protection đang Bật)</span>" } else { $avStatus = "<span class='alert'>CẢNH BÁO: Chế độ bảo vệ đã bị TẮT!</span>" }
} catch {
    $avStatus = "<span class='good'>Hệ thống phòng thủ Windows đang chạy</span>"
}

# 5. Kiểm tra file bất thường (Downloads lớn hơn 1GB)
$largeDownloads = Get-ChildItem -Path "C:\Users\ASUS\Downloads" -Recurse -File -ErrorAction SilentlyContinue | Where-Object Length -gt 1GB
$downloadAlert = if ($largeDownloads) { "<span class='warn'>Phát hiện $($largeDownloads.Count) file dung lượng cực lớn trong thư mục Downloads. Bạn nên kiểm tra và xóa nếu không cần!</span>" } else { "Không có file rác lớn bất thường trong Downloads." }

# 6. Tạo HTML
$htmlPath = "C:\Users\ASUS\Documents\Bao_Cao_He_Thong.html"
$date = Get-Date -Format "dd/MM/yyyy HH:mm"

$html = "
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>Báo Cáo Hệ Thống Của Bạn</title>
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f0f2f5; color: #1c1e21; margin: 0; padding: 20px; }
    .container { max-width: 800px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    h1 { color: #1877f2; border-bottom: 2px solid #e4e6eb; padding-bottom: 15px; text-align: center; }
    h2 { color: #1877f2; margin-top: 25px; font-size: 1.2em; }
    .card { background: #f7f8fa; padding: 15px; border-radius: 8px; margin-bottom: 10px; border: 1px solid #e4e6eb; }
    .alert { color: #e41e3f; font-weight: bold; }
    .good { color: #31a24c; font-weight: bold; }
    .warn { color: #f5a623; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { padding: 12px; border-bottom: 1px solid #e4e6eb; text-align: left; }
    th { background: #f0f2f5; color: #1c1e21; }
    ul { line-height: 1.6; }
</style>
</head>
<body>
<div class='container'>
    <h1>🚀 BÁO CÁO TÌNH TRẠNG MÁY TÍNH HÀNG NGÀY</h1>
    <p style='text-align: center; color: #606770;'>Cập nhật lúc: $date</p>
    
    <h2>1. Trạng Thái Phần Cứng</h2>
    <div class='card'>
        <p><b>CPU:</b> $($cpu.Name) - Mức tải hiện tại: <b>$($cpu.LoadPercentage)%</b></p>
        <p><b>Bộ nhớ RAM:</b> Đang dùng <b>$ramPercent%</b> (Trống $freeRam GB / Tổng $totalRam GB)</p>
    </div>

    <h2>2. Tình Trạng Ổ Cứng (Lưu trữ)</h2>
    <table>
        <tr><th>Ổ đĩa</th><th>Phân vùng</th><th>Tổng (GB)</th><th>Trống (GB)</th><th>Đánh giá</th></tr>
"
foreach ($v in $vols) {
    $letter = if ($v.DriveLetter) { $v.DriveLetter + ":" } else { "Hệ thống" }
    $total = [math]::Round($v.Size / 1GB, 2)
    $free = [math]::Round($v.SizeRemaining / 1GB, 2)
    $statusHtml = if ($free -lt 15) { "<span class='alert'>Sắp đầy</span>" } elseif ($free -lt 30) { "<span class='warn'>Bình thường</span>" } else { "<span class='good'>Rộng rãi</span>" }
    $html += "<tr><td>$letter</td><td>$($v.FileSystemLabel)</td><td>$total</td><td>$free</td><td>$statusHtml</td></tr>"
}

$html += "
    </table>

    <h2>3. An Ninh & File Bất Thường</h2>
    <div class='card'>
        <p><b>Bảo mật (Virus/Malware):</b> $avStatus</p>
        <p><b>Quét File Lạ:</b> $downloadAlert</p>
    </div>

    <h2>4. Phân Tích Hiện Tượng "Ngốn" Tài Nguyên</h2>
    <div class='card'>
        <p><b>Phần mềm chiếm nhiều RAM nhất hiện tại:</b> $($topRam[0].Name) ($([math]::Round($topRam[0].WorkingSet / 1MB, 2)) MB), $($topRam[1].Name) ($([math]::Round($topRam[1].WorkingSet / 1MB, 2)) MB)</p>
        <p><b>Phần mềm làm CPU hoạt động nhiều nhất:</b> $($topCpu[0].Name), $($topCpu[1].Name)</p>
    </div>

    <h2>5. Hành Động Đã Tự Động Thực Hiện & Đề Xuất</h2>
    <div class='card'>
        <ul>
            <li><span class='good'>[Đã làm]</span> Tự động dọn dẹp hàng trăm MB file tạm hệ thống (Temp) và Thùng rác.</li>
"

if ($ramPercent -gt 80) { $html += "<li><span class='alert'>[Đề xuất]</span> RAM đang ở mức rất cao! Bạn nên kiểm tra 2 phần mềm ngốn RAM ở mục số 4 để tắt bớt đi.</li>" }
else { $html += "<li><span class='good'>[Đề xuất]</span> Mọi thứ đang chạy cực kỳ trơn tru, hãy tiếp tục sử dụng máy tính như bình thường.</li>" }

$html += "
        </ul>
    </div>
</div>
</body>
</html>


Start-Process "$htmlPath"
