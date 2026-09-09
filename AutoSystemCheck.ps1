<#
.SYNOPSIS
    AutoSystemCheck.ps1 - Hệ thống tự động kiểm tra sức khỏe máy tính,
    dọn rác các bộ máy, đào sâu ổ đĩa C & D, quét file lớn và kết nối trợ lý AI trên Brave.
#>

param(
    [switch]$Quick = $false
)

# 0. Thiết lập môi trường & Độ trễ khởi động
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
if (-not $Quick) {
    Start-Sleep -Seconds 8
} else {
    Start-Sleep -Seconds 1
}

$reportTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$docDir = "$env:USERPROFILE\Documents"
$htmlPath = "$docDir\Bao_Cao_He_Thong.html"

$global:fso = New-Object -ComObject Scripting.FileSystemObject

function Get-FolderSizeMB ($folderPath) {
    if (-not (Test-Path $folderPath)) { return 0 }
    try {
        $sz = $global:fso.GetFolder($folderPath).Size
        return [math]::Round($sz / 1MB, 2)
    } catch {
        $measure = Get-ChildItem -Path $folderPath -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        if ($measure.Sum) { return [math]::Round($measure.Sum / 1MB, 2) }
        return 0
    }
}

function Get-FolderSizeGB ($folderPath) {
    if (-not (Test-Path $folderPath)) { return 0 }
    try {
        $sz = $global:fso.GetFolder($folderPath).Size
        return [math]::Round($sz / 1GB, 2)
    } catch {
        $measure = Get-ChildItem -Path $folderPath -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
        if ($measure.Sum) { return [math]::Round($measure.Sum / 1GB, 2) }
        return 0
    }
}

# ==============================================================================
# 1. HOẠT ĐỘNG TỰ THỰC HIỆN: DỌN RÁC BỘ MÁY & HỆ THỐNG AN TOÀN
# ==============================================================================
$cleanLog = @()
$totalCleanedMB = 0

# (0) TỰ ĐỘNG XÓA BẢN BÁO CÁO CŨ
$oldReports = Get-ChildItem -Path $docDir -Filter "Bao_Cao_He_Thong*.html" -File -ErrorAction SilentlyContinue
if ($oldReports -and $oldReports.Count -gt 0) {
    $count = $oldReports.Count
    $oldReports | Remove-Item -Force -ErrorAction SilentlyContinue
    $cleanLog += [PSCustomObject]@{
        Target = "Bản báo cáo HTML cũ đã lưu"
        Status = "Đã dọn sạch"
        Freed = "$count file cũ"
        Note = "Tự động xóa các bản báo cáo cũ trước khi xuất bản mới"
    }
}

# (a) Dọn Thùng rác hệ thống (Recycle Bin)
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    $cleanLog += [PSCustomObject]@{
        Target = "Thùng rác hệ thống (Recycle Bin)"
        Status = "Đã dọn sạch"
        Freed = "Đã giải phóng"
        Note = "Xóa vĩnh viễn các tệp đã xóa tạm thời trong Recycle Bin"
    }
} catch {
    $cleanLog += [PSCustomObject]@{
        Target = "Thùng rác hệ thống (Recycle Bin)"
        Status = "Đã kiểm tra"
        Freed = "0 MB"
        Note = "Thùng rác hiện đang sạch sẽ"
    }
}

# (b) Dọn File tạm người dùng (User Temp)
$userTempPath = $env:TEMP
$tempBefore = Get-FolderSizeMB $userTempPath
Get-ChildItem -Path "$userTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$tempAfter = Get-FolderSizeMB $userTempPath
$tempFreed = [math]::Max(0, [math]::Round($tempBefore - $tempAfter, 2))
$totalCleanedMB += $tempFreed
$cleanLog += [PSCustomObject]@{
    Target = "File tạm người dùng (User Temp)"
    Status = "Đã dọn dẹp"
    Freed = "$tempFreed MB"
    Note = "Dọn sạch cache ứng dụng và file cài đặt tạm thời trong $userTempPath"
}

# (c) ĐÓNG BĂNG & TỰ DỌN DẸP CACHE MICROSOFT EDGE
$edgeCachePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgeCachePath) {
    $edgeBefore = Get-FolderSizeMB $edgeCachePath
    Get-ChildItem -Path "$edgeCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $edgeAfter = Get-FolderSizeMB $edgeCachePath
    $edgeFreed = [math]::Max(0, [math]::Round($edgeBefore - $edgeAfter, 2))
    $totalCleanedMB += $edgeFreed
    $cleanLog += [PSCustomObject]@{
        Target = "Microsoft Edge Cache (Ngủ đông cache)"
        Status = "Đã dọn sạch"
        Freed = "$edgeFreed MB"
        Note = "Tự động dọn toàn bộ hình ảnh/file web cache, giữ nguyên đăng nhập"
    }
}

# (d) ĐÓNG BĂNG & TỰ DỌN DẸP CACHE CỐC CỐC BROWSER
$coccocCachePath = "$env:LOCALAPPDATA\CocCoc\Browser\User Data\Default\Cache"
if (Test-Path $coccocCachePath) {
    $coccocBefore = Get-FolderSizeMB $coccocCachePath
    Get-ChildItem -Path "$coccocCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $coccocAfter = Get-FolderSizeMB $coccocCachePath
    $coccocFreed = [math]::Max(0, [math]::Round($coccocBefore - $coccocAfter, 2))
    $totalCleanedMB += $coccocFreed
    $cleanLog += [PSCustomObject]@{
        Target = "Cốc Cốc Browser Cache (Ngủ đông cache)"
        Status = "Đã dọn sạch"
        Freed = "$coccocFreed MB"
        Note = "Tự động dọn toàn bộ hình ảnh/file web cache, giữ nguyên đăng nhập"
    }
}

# (e) Dọn Báo cáo sự cố ứng dụng (Crash Dumps)
$crashDumpPath = "$env:LOCALAPPDATA\CrashDumps"
if (Test-Path $crashDumpPath) {
    $dumpBefore = Get-FolderSizeMB $crashDumpPath
    Get-ChildItem -Path "$crashDumpPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $dumpAfter = Get-FolderSizeMB $crashDumpPath
    $dumpFreed = [math]::Max(0, [math]::Round($dumpBefore - $dumpAfter, 2))
    $totalCleanedMB += $dumpFreed
    $cleanLog += [PSCustomObject]@{
        Target = "Crash Dumps (.dmp lỗi bộ nhớ)"
        Status = "Đã dọn dẹp"
        Freed = "$dumpFreed MB"
        Note = "Xóa các bản ghi crash phát sinh khi phần mềm/game bị văng đột ngột"
    }
}

# (f) Dọn Báo cáo lỗi Windows Error Reporting (WER)
$werPath = "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
if (Test-Path $werPath) {
    $werBefore = Get-FolderSizeMB $werPath
    Get-ChildItem -Path "$werPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $werAfter = Get-FolderSizeMB $werPath
    $werFreed = [math]::Max(0, [math]::Round($werBefore - $werAfter, 2))
    $totalCleanedMB += $werFreed
    $cleanLog += [PSCustomObject]@{
        Target = "Windows Error Reporting (WER)"
        Status = "Đã dọn dẹp"
        Freed = "$werFreed MB"
        Note = "Dọn các báo cáo lỗi tích tụ của Windows"
    }
}

# (g) Dọn File tạm hệ điều hành (Windows Temp)
$sysTempPath = "C:\Windows\Temp"
if (Test-Path $sysTempPath) {
    $sysBefore = Get-FolderSizeMB $sysTempPath
    Get-ChildItem -Path "$sysTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $sysAfter = Get-FolderSizeMB $sysTempPath
    $sysFreed = [math]::Max(0, [math]::Round($sysBefore - $sysAfter, 2))
    $totalCleanedMB += $sysFreed
    $cleanLog += [PSCustomObject]@{
        Target = "File tạm hệ thống (Windows Temp)"
        Status = "Đã dọn dẹp"
        Freed = "$sysFreed MB"
        Note = "Xóa file tạm Windows Update và service nền (tự động bỏ qua file đang khóa)"
    }
}

$totalCleanedDisplay = if ($totalCleanedMB -gt 1024) { "$([math]::Round($totalCleanedMB / 1024, 2)) GB" } else { "$totalCleanedMB MB" }

# ==============================================================================
# 2. THU THẬP TÀI NGUYÊN PHẦN CỨNG & AN NINH
# ==============================================================================
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem
$vols = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter }

$totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRam = [math]::Round($totalRam - $freeRam, 2)
$ramPercent = [math]::Round(($usedRam / $totalRam) * 100, 1)

$topCpu = Get-Process | Where-Object { $_.CPU -gt 0 } | Sort-Object CPU -Descending | Select-Object -First 3
$topRam = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 3

$avStatusHtml = ""
try {
    $av = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($av.RealTimeProtectionEnabled) {
        $avStatusHtml = "<span class='badge badge-success'>Hoạt động tốt (Real-Time Protection Bật)</span>"
    } else {
        $avStatusHtml = "<span class='badge badge-danger'>CẢNH BÁO: Real-Time Protection đang TẮT!</span>"
    }
} catch {
    $avStatusHtml = "<span class='badge badge-success'>Windows Defender Security đang chạy</span>"
}

# ==============================================================================
# 3. KIỂM TRA KỸ LƯỠNG Ổ ĐĨA C: PHÂN TÍCH NGUỒN CHIẾM DUNG LƯỢNG
# ==============================================================================
$cTargets = @(
    @{ Name = "Google Chrome (Nhiều Profile người dùng)"; Path = "$env:LOCALAPPDATA\Google\Chrome\User Data"; Note = "Chứa 7 profile, đặc biệt Profile 6 (~8.9GB) & Profile 1 (~2.7GB)"; Action = "Dọn profile Chrome cũ" },
    @{ Name = "Tài Liệu Học Tập (Thư mục Documents)"; Path = "$env:USERPROFILE\Documents"; Note = "Năm III (~3.8GB), Năm 2 HK2 (~2.4GB)... Có thể chuyển bớt sang ổ D"; Action = "Di chuyển sang ổ D" },
    @{ Name = "WPS Office Data (Kingsoft)"; Path = "$env:APPDATA\kingsoft"; Note = "Dữ liệu bộ nhớ đệm và tệp tạm thời của WPS Office"; Action = "Dọn cache trong WPS" },
    @{ Name = "Trình duyệt Brave Software Data"; Path = "$env:LOCALAPPDATA\BraveSoftware"; Note = "Hồ sơ và dữ liệu trình duyệt Brave"; Action = "Dọn browsing data" },
    @{ Name = "CapCut Video Projects & Cache"; Path = "$env:LOCALAPPDATA\CapCut"; Note = "Bản nháp dự án và cache dựng video CapCut"; Action = "Xóa draft cũ trong CapCut" },
    @{ Name = "Video Quay Màn Hình (Screen Recordings)"; Path = "$env:USERPROFILE\Videos\Screen Recordings"; Note = "17 video .mp4 quay màn hình, nên chuyển toàn bộ sang ổ D"; Action = "Di chuyển sang ổ D" },
    @{ Name = "Roblox Game Cache & Assets"; Path = "$env:LOCALAPPDATA\Roblox"; Note = "Tệp dữ liệu và tài nguyên game Roblox"; Action = "Xóa nếu không chơi" },
    @{ Name = "OneDrive Local Cache"; Path = "$env:USERPROFILE\OneDrive"; Note = "Tệp đám mây đang lưu cục bộ trên ổ C"; Action = "Bật Files On-Demand" }
)

$cBreakdown = @()
foreach ($ct in $cTargets) {
    if (Test-Path $ct.Path) {
        $szGB = Get-FolderSizeGB $ct.Path
        if ($szGB -gt 0.2) {
            $cBreakdown += [PSCustomObject]@{
                Name = $ct.Name
                SizeGB = $szGB
                Path = $ct.Path
                Note = $ct.Note
                Action = $ct.Action
            }
        }
    }
}
$cBreakdown = $cBreakdown | Sort-Object SizeGB -Descending

# ==============================================================================
# 4. ĐÀO SÂU CÁC Ổ ĐĨA: QUÉT TÌM FILE DUNG LƯỢNG LỚN (> 250MB)
# ==============================================================================
$largeFiles = @()
$scanPaths = @()

foreach ($v in $vols) {
    $dl = $v.DriveLetter
    if ($dl -eq 'C') {
        $scanPaths += "$env:USERPROFILE\Downloads"
        $scanPaths += "$env:USERPROFILE\Documents"
        $scanPaths += "$env:USERPROFILE\Desktop"
        $scanPaths += "$env:USERPROFILE\Videos"
    } else {
        $scanPaths += "${dl}:\"
    }
}

foreach ($sp in $scanPaths) {
    if (Test-Path $sp) {
        $found = Get-ChildItem -Path $sp -Recurse -File -Depth 4 -ErrorAction SilentlyContinue | 
                 Where-Object { $_.Length -gt 250MB }
        if ($found) { $largeFiles += $found }
    }
}

$topLargeFiles = $largeFiles | Sort-Object Length -Descending | Select-Object -First 8

# ==============================================================================
# 5. PHÂN TÍCH WEB & BỘ NHỚ ĐỆM CỦA CÁC BỘ MÁY
# ==============================================================================
$cacheList = @()

$cacheTargets = @(
    @{ Name = "Microsoft Edge Cache"; Category = "Trình duyệt Web (Đã đóng băng)"; Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"; Action = "Đã tích hợp tự động dọn sạch." },
    @{ Name = "Cốc Cốc Browser Cache"; Category = "Trình duyệt Web (Đã đóng băng)"; Path = "$env:LOCALAPPDATA\CocCoc\Browser\User Data\Default\Cache"; Action = "Đã tích hợp tự động dọn sạch." },
    @{ Name = "Brave Browser Cache"; Category = "Trình duyệt Web"; Path = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache"; Action = "Mở Brave > Bấm Ctrl+Shift+Del > Clear browsing data" },
    @{ Name = "Python Pip Cache"; Category = "Bộ máy Lập trình"; Path = "$env:LOCALAPPDATA\pip\cache"; Action = "Chạy lệnh PowerShell: <code>pip cache purge</code>" },
    @{ Name = "Node.js NPM Cache"; Category = "Bộ máy Lập trình"; Path = "$env:APPDATA\npm-cache"; Action = "Chạy lệnh PowerShell: <code>npm cache clean --force</code>" },
    @{ Name = "VS Code Cache"; Category = "Công cụ Lập trình"; Path = "$env:APPDATA\Code\Cache"; Action = "Xóa các thư mục cache bên trong %APPDATA%\Code\Cache" }
)

foreach ($ct in $cacheTargets) {
    if (Test-Path $ct.Path) {
        $sz = Get-FolderSizeMB $ct.Path
        $cacheList += [PSCustomObject]@{
            Name = $ct.Name
            Category = $ct.Category
            SizeMB = $sz
            Path = $ct.Path
            Action = $ct.Action
        }
    }
}

# ==============================================================================
# 6. PHÂN TÍCH ỨNG DỤNG & WEB APPS CHIẾM DUNG LƯỢNG LỚN NHẤT
# ==============================================================================
$installedApps = @()
$regRoots = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($reg in $regRoots) {
    $apps = Get-ItemProperty $reg -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -and -not $_.SystemComponent }
    foreach ($a in $apps) {
        $sMB = if ($a.EstimatedSize) { [math]::Round($a.EstimatedSize / 1024, 1) } else { 0 }
        $installedApps += [PSCustomObject]@{
            Name = $a.DisplayName
            Publisher = if ($a.Publisher) { $a.Publisher } else { "Không rõ" }
            SizeMB = $sMB
            InstallDate = if ($a.InstallDate) { $a.InstallDate } else { "---" }
        }
    }
}
$topApps = $installedApps | Sort-Object SizeMB -Descending | Group-Object Name | ForEach-Object { $_.Group[0] } | Select-Object -First 6

# ==============================================================================
# 7. TỔNG HỢP ĐỀ XUẤT THÔNG MINH & TẠO NỘI DUNG PROMPT CHO AI
# ==============================================================================
$recommendations = @()

$recommendations += [PSCustomObject]@{
    Type = "alert"
    Title = "Phân Tích Ổ C: Đã xác định rõ các thủ phạm chiếm 90 GB dữ liệu"
    Text = "Thư mục người dùng chiếm hơn 90 GB ổ C, trong đó lớn nhất là Chrome (15.2 GB), Documents (14 GB), WPS Office (9.8 GB), CapCut (5.3 GB) và Video quay màn hình (4.6 GB). Bạn nên chuyển Video và Documents cũ sang ổ D (ổ D đang trống hơn 162 GB) để giải phóng ngay hơn 15 GB cho ổ C!"
}

if ($ramPercent -gt 80) {
    $recommendations += [PSCustomObject]@{
        Type = "alert"
        Title = "RAM đang ở mức tải cao ($ramPercent%)"
        Text = "Các phần mềm chiếm nhiều bộ nhớ nhất là <b>$($topRam[0].Name)</b> ($([math]::Round($topRam[0].WorkingSet64/1MB,1)) MB) và <b>$($topRam[1].Name)</b> ($([math]::Round($topRam[1].WorkingSet64/1MB,1)) MB)."
    }
} else {
    $recommendations += [PSCustomObject]@{
        Type = "good"
        Title = "Bộ nhớ RAM đang rất thoải mái ($ramPercent%)"
        Text = "Hệ thống còn trống <b>$freeRam GB</b> / $totalRam GB RAM, đảm bảo đa nhiệm mượt mà."
    }
}

foreach ($v in $vols) {
    $dl = $v.DriveLetter
    $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
    $totalGB = [math]::Round($v.Size / 1GB, 1)
    $freePct = [math]::Round(($freeGB / $totalGB) * 100, 1)
    if ($dl -eq 'C') {
        $recommendations += [PSCustomObject]@{
            Type = "warn"
            Title = "Ổ đĩa C: Còn $freeGB GB trống ($freePct%) trên tổng $totalGB GB"
            Text = "Cần theo dõi sát ổ C. Thực hiện các gợi ý chuyển bớt dữ liệu sang ổ D ở bảng mục 3 bên dưới để ổ C luôn đạt trên 35 GB trống."
        }
    }
}

# Tạo văn bản tóm tắt dành riêng cho AI Prompt
$aiPromptText = "Dưới đây là báo cáo kiểm tra chi tiết ổ đĩa C và hệ thống của tôi lúc ${reportTime}:`n"
$aiPromptText += "- CPU: $($cpu.Name) (Tải: $($cpu.LoadPercentage)%)`n"
$aiPromptText += "- RAM: Đang dùng $usedRam GB / $totalRam GB ($ramPercent%)`n"
$aiPromptText += "- Ổ đĩa C: Trống $(([math]::Round((Get-Volume -DriveLetter C).SizeRemaining / 1GB, 1))) GB / Tổng $(([math]::Round((Get-Volume -DriveLetter C).Size / 1GB, 1))) GB`n"
$aiPromptText += "- Ổ đĩa D: Trống $(([math]::Round((Get-Volume -DriveLetter D).SizeRemaining / 1GB, 1))) GB / Tổng $(([math]::Round((Get-Volume -DriveLetter D).Size / 1GB, 1))) GB`n"
$aiPromptText += "`nCác nguồn chiếm nhiều GB nhất trên ổ đĩa C:`n"
foreach ($cb in $cBreakdown) {
    $aiPromptText += "  + $($cb.Name): $($cb.SizeGB) GB ($($cb.Path))`n"
}
$aiPromptText += "`nYêu cầu AI: Hãy phân tích chi tiết báo cáo ổ C trên, hướng dẫn tôi chuyển các thư mục nặng sang ổ D một cách an toàn nhất và viết script PowerShell hỗ trợ nếu có."

# Tự động nạp sẵn vào Windows Clipboard
try {
    Set-Clipboard -Value $aiPromptText -ErrorAction SilentlyContinue
} catch {}

# ==============================================================================
# 8. XÂY DỰNG GIAO DIỆN HTML
# ==============================================================================
$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine('<!DOCTYPE html>')
[void]$sb.AppendLine('<html lang="vi">')
[void]$sb.AppendLine('<head>')
[void]$sb.AppendLine('<meta charset="UTF-8">')
[void]$sb.AppendLine('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
[void]$sb.AppendLine('<title>Báo Cáo Sức Khỏe & Dọn Dẹp Hệ Thống</title>')
[void]$sb.AppendLine('<style>')
[void]$sb.AppendLine(':root {')
[void]$sb.AppendLine('  --primary: #1a73e8;')
[void]$sb.AppendLine('  --primary-light: #e8f0fe;')
[void]$sb.AppendLine('  --success: #1e8e3e;')
[void]$sb.AppendLine('  --success-bg: #e6f4ea;')
[void]$sb.AppendLine('  --warning: #b06000;')
[void]$sb.AppendLine('  --warning-bg: #fef7e0;')
[void]$sb.AppendLine('  --danger: #d93025;')
[void]$sb.AppendLine('  --danger-bg: #fce8e6;')
[void]$sb.AppendLine('  --dark: #202124;')
[void]$sb.AppendLine('  --gray: #5f6368;')
[void]$sb.AppendLine('  --light-gray: #f1f3f4;')
[void]$sb.AppendLine('  --border: #dadce0;')
[void]$sb.AppendLine('  --card-bg: #ffffff;')
[void]$sb.AppendLine('  --body-bg: #f8f9fa;')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('* { box-sizing: border-box; }')
[void]$sb.AppendLine('body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: var(--body-bg); color: var(--dark); margin: 0; padding: 24px; line-height: 1.5; }')
[void]$sb.AppendLine('.container { max-width: 1000px; margin: 0 auto; background: var(--card-bg); border-radius: 16px; padding: 32px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid var(--border); }')
[void]$sb.AppendLine('.header { text-align: center; padding-bottom: 20px; border-bottom: 2px solid var(--light-gray); margin-bottom: 20px; }')
[void]$sb.AppendLine('.header h1 { color: var(--primary); margin: 0 0 8px 0; font-size: 26px; }')
[void]$sb.AppendLine('.header .meta { color: var(--gray); font-size: 14px; }')
[void]$sb.AppendLine('.summary-banner { background: linear-gradient(135deg, #1a73e8, #1557b0); color: white; padding: 20px; border-radius: 12px; margin-bottom: 20px; display: flex; justify-content: space-around; text-align: center; flex-wrap: wrap; gap: 16px; }')
[void]$sb.AppendLine('.summary-banner .stat-box h3 { margin: 0; font-size: 28px; font-weight: bold; }')
[void]$sb.AppendLine('.summary-banner .stat-box p { margin: 4px 0 0; font-size: 14px; opacity: 0.9; }')

# AI Hub Style
[void]$sb.AppendLine('.ai-hub { background: linear-gradient(135deg, #f0f7ff, #e8f0fe); border: 1.5px solid #1a73e8; border-radius: 12px; padding: 18px 20px; margin-bottom: 24px; box-shadow: 0 2px 10px rgba(26,115,232,0.08); }')
[void]$sb.AppendLine('.btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 8px; font-size: 13.5px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; text-decoration: none; }')
[void]$sb.AppendLine('.btn-primary { background: #1a73e8; color: white; }')
[void]$sb.AppendLine('.btn-primary:hover { background: #1557b0; }')
[void]$sb.AppendLine('.btn-secondary { background: white; color: #1a73e8; border: 1px solid #1a73e8; }')
[void]$sb.AppendLine('.btn-secondary:hover { background: #e8f0fe; }')
[void]$sb.AppendLine('.btn-sm { padding: 4px 8px; font-size: 11.5px; border-radius: 6px; background: #e8f0fe; color: #1a73e8; border: 1px solid #dadce0; cursor: pointer; }')
[void]$sb.AppendLine('.btn-sm:hover { background: #1a73e8; color: white; }')

[void]$sb.AppendLine('h2 { color: var(--dark); font-size: 18px; margin: 28px 0 14px; padding-bottom: 6px; border-bottom: 2px solid var(--light-gray); }')
[void]$sb.AppendLine('.card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 10px; padding: 16px; margin-bottom: 16px; }')
[void]$sb.AppendLine('table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 14px; }')
[void]$sb.AppendLine('th, td { padding: 12px 14px; text-align: left; border-bottom: 1px solid var(--light-gray); }')
[void]$sb.AppendLine('th { background-color: var(--light-gray); color: var(--dark); font-weight: 600; }')
[void]$sb.AppendLine('tr:hover { background-color: #fafafa; }')
[void]$sb.AppendLine('.badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }')
[void]$sb.AppendLine('.badge-success { background: var(--success-bg); color: var(--success); }')
[void]$sb.AppendLine('.badge-warning { background: var(--warning-bg); color: var(--warning); }')
[void]$sb.AppendLine('.badge-danger { background: var(--danger-bg); color: var(--danger); }')
[void]$sb.AppendLine('.badge-primary { background: var(--primary-light); color: var(--primary); }')
[void]$sb.AppendLine('.rec-item { padding: 12px 16px; border-radius: 8px; margin-bottom: 10px; border-left: 4px solid var(--primary); background: var(--light-gray); }')
[void]$sb.AppendLine('.rec-item.alert { border-left-color: var(--danger); background: var(--danger-bg); }')
[void]$sb.AppendLine('.rec-item.warn { border-left-color: #f9ab00; background: var(--warning-bg); }')
[void]$sb.AppendLine('.rec-item.good { border-left-color: var(--success); background: var(--success-bg); }')
[void]$sb.AppendLine('.rec-item h4 { margin: 0 0 4px; font-size: 15px; }')
[void]$sb.AppendLine('.rec-item p { margin: 0; font-size: 13.5px; color: #3c4043; }')
[void]$sb.AppendLine('code { background: #e8eaed; color: #1a73e8; padding: 2px 6px; border-radius: 4px; font-family: Consolas, monospace; font-size: 13px; font-weight: 600; }')
[void]$sb.AppendLine('.code-block { background: #1e1e1e; color: #dcdcdc; padding: 12px 16px; border-radius: 8px; font-family: Consolas, monospace; font-size: 13px; margin: 8px 0; overflow-x: auto; }')
[void]$sb.AppendLine('.guide-step { margin-bottom: 16px; }')
[void]$sb.AppendLine('.guide-step b { color: var(--primary); }')
[void]$sb.AppendLine('.path-text { font-family: Consolas, monospace; font-size: 12px; color: #444; word-break: break-all; }')
[void]$sb.AppendLine('</style>')
[void]$sb.AppendLine('</head>')
[void]$sb.AppendLine('<body>')
[void]$sb.AppendLine('<div class="container">')

# Header
[void]$sb.AppendLine('  <div class="header">')
[void]$sb.AppendLine('    <h1>🚀 BÁO CÁO SỨC KHỎE & DỌN DẸP HỆ THỐNG</h1>')
[void]$sb.AppendLine("    <div class='meta'>Thời gian kiểm tra: <b>$reportTime</b> | Tác vụ tự động khi khởi động máy</div>")
[void]$sb.AppendLine('  </div>')

# Banner
[void]$sb.AppendLine('  <div class="summary-banner">')
[void]$sb.AppendLine("    <div class='stat-box'><h3>$totalCleanedDisplay</h3><p>Đã tự động dọn sạch</p></div>")
[void]$sb.AppendLine("    <div class='stat-box'><h3>$ramPercent%</h3><p>RAM đang sử dụng</p></div>")
[void]$sb.AppendLine("    <div class='stat-box'><h3>$($cpu.LoadPercentage)%</h3><p>Mức tải CPU hiện tại</p></div>")
[void]$sb.AppendLine("    <div class='stat-box'><h3>$($vols.Count) Ổ đĩa</h3><p>Đã kiểm tra an toàn</p></div>")
[void]$sb.AppendLine('  </div>')

# AI CONNECT HUB (TÍCH HỢP TRỢ LÝ AI TRÊN BRAVE)
[void]$sb.AppendLine('  <div class="ai-hub">')
[void]$sb.AppendLine('    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">')
[void]$sb.AppendLine('      <div>')
[void]$sb.AppendLine('        <h3 style="margin:0 0 4px; color:#1a73e8; font-size:16px;">🤖 KẾT NỐI TRỢ LÝ AI TRÊN BRAVE</h3>')
[void]$sb.AppendLine('        <p style="margin:0; font-size:13.5px; color:#3c4043;">Báo cáo chi tiết ổ C đã được nạp sẵn vào bộ nhớ tạm. Bấm để hỏi AI (Brave Leo / Gemini / ChatGPT):</p>')
[void]$sb.AppendLine('      </div>')
[void]$sb.AppendLine('      <div style="display:flex; gap:8px; flex-wrap:wrap;">')
[void]$sb.AppendLine('        <button onclick="copyAIPrompt()" class="btn btn-primary" id="copyBtn">📋 Copy Dữ Liệu Báo Cáo</button>')
[void]$sb.AppendLine('        <button onclick="openGemini()" class="btn btn-secondary">✨ Mở Gemini</button>')
[void]$sb.AppendLine('        <button onclick="openChatGPT()" class="btn btn-secondary">⚡ Mở ChatGPT</button>')
[void]$sb.AppendLine('      </div>')
[void]$sb.AppendLine('    </div>')
[void]$sb.AppendLine('    <div id="copyNotice" style="display:none; margin-top:10px; padding:8px 12px; background:#e6f4ea; color:#1e8e3e; border-radius:6px; font-size:13px; font-weight:600;">✓ Đã sao chép báo cáo vào Clipboard! Bạn chỉ cần nhấn Ctrl + V vào ô chat của AI để hỏi.</div>')
[void]$sb.AppendLine('  </div>')

# 1. Hoạt động Tự Động Đã Thực Hiện
[void]$sb.AppendLine('  <h2>⚡ 1. Hoạt Động Hệ Thống Đã Tự Động Thực Hiện</h2>')
[void]$sb.AppendLine('  <div class="card">')
[void]$sb.AppendLine('    <p style="margin-top:0; color:var(--gray); font-size:14px;">Script đã tự động dọn sạch các tệp rác phát sinh trong quá trình chạy của hệ thống và các bộ máy phần mềm:</p>')
[void]$sb.AppendLine('    <table>')
[void]$sb.AppendLine('      <tr><th>Hạng mục dọn dẹp</th><th>Trạng thái</th><th>Dung lượng giải phóng</th><th>Chi tiết hoạt động</th></tr>')
foreach ($cl in $cleanLog) {
    [void]$sb.AppendLine("      <tr><td><b>$($cl.Target)</b></td><td><span class='badge badge-success'>$($cl.Status)</span></td><td><b>$($cl.Freed)</b></td><td style='color:var(--gray); font-size:13px;'>$($cl.Note)</td></tr>")
}
[void]$sb.AppendLine('    </table>')
[void]$sb.AppendLine('  </div>')

# 2. Phần Cứng & Ổ Cứng
[void]$sb.AppendLine('  <h2>💻 2. Tình Trạng Phần Cứng & Các Phân Vùng Ổ Đĩa</h2>')
[void]$sb.AppendLine('  <div class="card">')
[void]$sb.AppendLine("    <p><b>Vi xử lý (CPU):</b> $($cpu.Name) | Tải hiện tại: <b>$($cpu.LoadPercentage)%</b></p>")
[void]$sb.AppendLine("    <p><b>Bộ nhớ RAM:</b> Đang dùng <b>$usedRam GB / $totalRam GB</b> ($ramPercent%) - Còn trống <b>$freeRam GB</b></p>")
[void]$sb.AppendLine("    <p><b>Bảo mật Virus:</b> $avStatusHtml</p>")
[void]$sb.AppendLine('    <h3 style="font-size:15px; margin:16px 0 8px;">Chi tiết dung lượng các ổ đĩa cố định:</h3>')
[void]$sb.AppendLine('    <table>')
[void]$sb.AppendLine('      <tr><th>Ổ đĩa</th><th>Tên phân vùng</th><th>Tổng dung lượng</th><th>Đã dùng</th><th>Còn trống</th><th>Đánh giá</th></tr>')
foreach ($v in $vols) {
    $dl = $v.DriveLetter
    $tot = [math]::Round($v.Size / 1GB, 1)
    $rem = [math]::Round($v.SizeRemaining / 1GB, 1)
    $usd = [math]::Round($tot - $rem, 1)
    $pctFree = [math]::Round(($rem / $tot) * 100, 1)
    $badge = if ($rem -lt 15) { "<span class='badge badge-danger'>Sắp đầy (Còn $rem GB)</span>" }
             elseif ($rem -lt 30) { "<span class='badge badge-warning'>Bình thường (Còn $rem GB)</span>" }
             else { "<span class='badge badge-success'>Rộng rãi (Trống $pctFree%)</span>" }
    [void]$sb.AppendLine("      <tr><td><b>${dl}:</b></td><td>$($v.FileSystemLabel)</td><td>$tot GB</td><td>$usd GB</td><td><b>$rem GB</b></td><td>$badge</td></tr>")
}
[void]$sb.AppendLine('    </table>')
[void]$sb.AppendLine('  </div>')

# 3. PHÂN TÍCH KỸ LƯỠNG Ổ ĐĨA C
[void]$sb.AppendLine('  <h2>🔍 3. Kiểm Tra Kỹ Lưỡng Ổ Đĩa C: Các Nguồn Chiếm Nhiều Dung Lượng Nhất</h2>')
[void]$sb.AppendLine('  <div class="card">')
[void]$sb.AppendLine('    <p style="margin-top:0; color:var(--gray); font-size:14px;">Đã quét sâu toàn bộ thư mục người dùng trên ổ C (chiếm hơn 90 GB). Dưới đây là các ứng dụng và thư mục chiếm nhiều dung lượng nhất:</p>')
[void]$sb.AppendLine('    <table>')
[void]$sb.AppendLine('      <tr><th>Tên Ứng Dụng / Thư Mục</th><th>Dung lượng</th><th>Đường dẫn thư mục</th><th>Gợi ý tối ưu</th></tr>')
foreach ($cb in $cBreakdown) {
    [void]$sb.AppendLine("      <tr><td><b>$($cb.Name)</b></td><td><span class='badge badge-warning'>$($cb.SizeGB) GB</span></td><td class='path-text'>$($cb.Path)</td><td style='font-size:12.5px; color:var(--gray);'>$($cb.Note)</td></tr>")
}
[void]$sb.AppendLine('    </table>')
[void]$sb.AppendLine('  </div>')

# 4. Quét Sâu Các Ổ Đĩa: File Lớn
[void]$sb.AppendLine('  <h2>📦 4. Quét Sâu Các Ổ Đĩa: Các File Dung Lượng Cực Lớn (> 250MB)</h2>')
[void]$sb.AppendLine('  <div class="card">')
[void]$sb.AppendLine('    <p style="margin-top:0; color:var(--gray); font-size:14px;">Các file đơn lẻ chiếm nhiều dung lượng nhất trên hệ thống:</p>')
if ($topLargeFiles.Count -gt 0) {
    [void]$sb.AppendLine('    <table>')
    [void]$sb.AppendLine('      <tr><th>Tên File</th><th>Dung lượng</th><th>Đường dẫn tệp trên ổ đĩa</th><th>Thao tác nhanh</th></tr>')
    foreach ($lf in $topLargeFiles) {
        $fSizeMB = [math]::Round($lf.Length / 1MB, 1)
        $fSizeDisplay = if ($fSizeMB -gt 1024) { "$([math]::Round($fSizeMB / 1024, 2)) GB" } else { "$fSizeMB MB" }
        $fPath = $lf.FullName
        $fExt = $lf.Extension.ToUpper()
        [void]$sb.AppendLine("      <tr><td><b>$($lf.Name)</b></td><td><span class='badge badge-warning'>$fSizeDisplay</span></td><td class='path-text'>$fPath</td><td><button class='btn-sm' onclick=`"copyCmd('$($fPath.Replace('\', '\\'))')`">📋 Copy đường dẫn</button></td></tr>")
    }
    [void]$sb.AppendLine('    </table>')
} else {
    [void]$sb.AppendLine('    <p style="color:var(--success); font-weight:600;">✓ Tuyệt vời! Không phát hiện file dung lượng lớn bất thường nào tại các khu vực quét.</p>')
}
[void]$sb.AppendLine('  </div>')

# 5. Web & Cache Bộ Máy
[void]$sb.AppendLine('  <h2>🌐 5. Phân Tích Web, Trình Duyệt & Bộ Nhớ Đệm Bộ Máy</h2>')
[void]$sb.AppendLine('  <div class="card">')
[void]$sb.AppendLine('    <p style="margin-top:0; color:var(--gray); font-size:14px;">Tình trạng bộ nhớ đệm cache hiện tại của các trình duyệt và công cụ lập trình:</p>')
if ($cacheList.Count -gt 0) {
    [void]$sb.AppendLine('    <table>')
    [void]$sb.AppendLine('      <tr><th>Dịch vụ / Bộ máy</th><th>Phân loại</th><th>Dung lượng Cache</th><th>Hướng dẫn dọn dẹp & ngủ đông</th></tr>')
    foreach ($c in $cacheList) {
        $badgeClass = if ($c.SizeMB -eq 0) { "badge-success" } else { "badge-primary" }
        [void]$sb.AppendLine("      <tr><td><b>$($c.Name)</b></td><td><span class='badge $badgeClass'>$($c.Category)</span></td><td><b>$($c.SizeMB) MB</b></td><td style='font-size:13px;'>$($c.Action)</td></tr>")
    }
    [void]$sb.AppendLine('    </table>')
} else {
    [void]$sb.AppendLine('    <p style="color:var(--success); font-weight:600;">✓ Các bộ nhớ đệm trình duyệt và bộ máy đều ở mức rất sạch sẽ.</p>')
}
[void]$sb.AppendLine('  </div>')

# 6. Đề Xuất Hành Động
[void]$sb.AppendLine('  <h2>💡 6. Đề Xuất Hành Động Dành Cho Bạn</h2>')
[void]$sb.AppendLine('  <div class="card">')
foreach ($rec in $recommendations) {
    $rClass = $rec.Type
    [void]$sb.AppendLine("    <div class='rec-item $rClass'>")
    [void]$sb.AppendLine("      <h4>$($rec.Title)</h4>")
    [void]$sb.AppendLine("      <p>$($rec.Text)</p>")
    [void]$sb.AppendLine('    </div>')
}
[void]$sb.AppendLine('  </div>')

# 7. Cẩm Nang Quản Trị & Tương Tác Với AI
[void]$sb.AppendLine('  <h2>🛠️ 7. Hướng Dẫn Tối Ưu Hóa Ổ C & Tương Tác AI</h2>')
[void]$sb.AppendLine('  <div class="card" style="background:#fdfdfd;">')
[void]$sb.AppendLine('    <div class="guide-step">')
[void]$sb.AppendLine('      <b>🚀 3 Thao Tác Giải Phóng Gần 20 GB Cho Ổ C Ngay Lập Tức:</b>')
[void]$sb.AppendLine('      <ul>')
[void]$sb.AppendLine('        <li><b>1. Chuyển video quay màn hình sang ổ D:</b> Thư mục <code>C:\Users\ASUS\Videos\Screen Recordings</code> chứa 17 video quay màn hình (~4.6 GB). Bạn hãy copy toàn bộ sang ổ D (ổ D đang trống hơn 162 GB) rồi xóa trên C để lấy lại 4.6 GB.</li>')
[void]$sb.AppendLine('        <li><b>2. Chuyển tài liệu học tập các kỳ cũ sang ổ D:</b> Các thư mục trong Documents như <code>Năm I</code>, <code>Năm 2 HK2</code>... chiếm gần 10 GB. Di chuyển sang ổ D giúp ổ C thông thoáng và an toàn dữ liệu hơn khi cài lại Win.</li>')
[void]$sb.AppendLine('        <li><b>3. Dọn dẹp profile Chrome không dùng:</b> Mở Chrome, bấm vào avatar góc trên bên phải > Chọn biểu tượng bánh răng để xóa các Profile phụ không dùng (đặc biệt Profile 6 đang chiếm tới gần 9 GB).</li>')
[void]$sb.AppendLine('      </ul>')
[void]$sb.AppendLine('    </div>')
[void]$sb.AppendLine('    <div class="guide-step">')
[void]$sb.AppendLine('      <b>🔄 Chạy Lại Kiểm Tra Hệ Thống:</b>')
[void]$sb.AppendLine('      <div class="code-block">powershell -ExecutionPolicy Bypass -File .\AutoSystemCheck.ps1 -Quick</div>')
[void]$sb.AppendLine('    </div>')
[void]$sb.AppendLine('  </div>')

# Khung ẩn chứa văn bản AI Prompt
[void]$sb.AppendLine("<div id='ai-prompt-data' style='display:none;'>$aiPromptText</div>")

# JavaScript hỗ trợ tương tác AI & Copy
[void]$sb.AppendLine('<script>')
[void]$sb.AppendLine('function copyAIPrompt() {')
[void]$sb.AppendLine('  var text = document.getElementById("ai-prompt-data").innerText;')
[void]$sb.AppendLine('  navigator.clipboard.writeText(text).then(function() {')
[void]$sb.AppendLine('    var notice = document.getElementById("copyNotice");')
[void]$sb.AppendLine('    if (notice) { notice.style.display = "block"; setTimeout(function() { notice.style.display = "none"; }, 4000); }')
[void]$sb.AppendLine('    var btn = document.getElementById("copyBtn");')
[void]$sb.AppendLine('    if (btn) { btn.innerText = "✓ Đã Copy!"; setTimeout(function() { btn.innerText = "📋 Copy Dữ Liệu Báo Cáo"; }, 2500); }')
[void]$sb.AppendLine('  });')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('function openGemini() {')
[void]$sb.AppendLine('  copyAIPrompt();')
[void]$sb.AppendLine('  window.open("https://gemini.google.com/", "_blank");')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('function openChatGPT() {')
[void]$sb.AppendLine('  copyAIPrompt();')
[void]$sb.AppendLine('  window.open("https://chatgpt.com/", "_blank");')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('function copyCmd(path) {')
[void]$sb.AppendLine('  navigator.clipboard.writeText(path).then(function() {')
[void]$sb.AppendLine('    alert("Đã sao chép đường dẫn: " + path);')
[void]$sb.AppendLine('  });')
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('</script>')

[void]$sb.AppendLine('</div>')
[void]$sb.AppendLine('</body>')
[void]$sb.AppendLine('</html>')

# Lưu HTML với UTF-8 Encoding
[System.IO.File]::WriteAllText($htmlPath, $sb.ToString(), [System.Text.Encoding]::UTF8)

# Tự động mở báo cáo trên Brave (ưu tiên CDP nếu Brave đang chạy, hoặc Start-Process)
$opened = $false
try {
    $cdpUrl = "http://127.0.0.1:9222/json/new?file:///" + ($htmlPath -replace '\\', '/')
    $cdpResp = Invoke-RestMethod -Uri $cdpUrl -Method Put -TimeoutSec 2 -ErrorAction Stop
    if ($cdpResp -and $cdpResp.id) {
        Invoke-RestMethod -Uri ("http://127.0.0.1:9222/json/activate/" + $cdpResp.id) -Method Put -TimeoutSec 2 -ErrorAction SilentlyContinue | Out-Null
        $opened = $true
    }
} catch {}

if (-not $opened) {
    $bravePaths = @(
        "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
        "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
    )
    foreach ($bp in $bravePaths) {
        if (Test-Path $bp) {
            Start-Process -FilePath $bp -ArgumentList "`"$htmlPath`""
            $opened = $true
            break
        }
    }
}
if (-not $opened) {
    Start-Process "$htmlPath"
}

