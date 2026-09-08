#!/bin/bash
# Đợi 15 giây sau khi Mac khởi động
sleep 15

# 1. Dọn rác
rm -rf ~/.Trash/* 2>/dev/null

# 2. Lấy thông tin tài nguyên
CPU_LOAD=$(top -l 1 | awk '/CPU usage/ {print $3}' | tr -d '%')
RAM_TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.2f GB", $0/1073741824}')

DISK_INFO=$(df -h / | tail -1)
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')
DISK_FREE=$(echo $DISK_INFO | awk '{print $4}')

# 3. Tạo HTML
HTML_PATH="$HOME/Documents/Bao_Cao_Mac.html"
DATE=$(date "+%d/%m/%Y %H:%M")

cat <<EOF > "$HTML_PATH"
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>Báo Cáo Sức Khỏe Mac</title>
<style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #f0f2f5; color: #1c1e21; padding: 20px; }
    .container { max-width: 800px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    h1 { color: #0071e3; border-bottom: 2px solid #e4e6eb; padding-bottom: 15px; text-align: center; }
    h2 { color: #0071e3; margin-top: 25px; font-size: 1.2em; }
    .card { background: #f7f8fa; padding: 15px; border-radius: 8px; margin-bottom: 10px; border: 1px solid #e4e6eb; }
    .good { color: #31a24c; font-weight: bold; }
</style>
</head>
<body>
<div class='container'>
    <h1>🍎 BÁO CÁO TÌNH TRẠNG MAC HÀNG NGÀY</h1>
    <p style='text-align: center; color: #606770;'>Cập nhật lúc: $DATE</p>
    <h2>1. Trạng Thái Tổng Quan</h2>
    <div class='card'>
        <p><b>CPU Usage:</b> $CPU_LOAD%</p>
        <p><b>RAM Tổng:</b> $RAM_TOTAL</p>
    </div>
    <h2>2. Dung Lượng Ổ Cứng (Macintosh HD)</h2>
    <div class='card'>
        <p><b>Tổng dung lượng:</b> $DISK_TOTAL | <b>Đang trống:</b> $DISK_FREE</p>
    </div>
    <h2>3. Hoạt Động Tự Động Đã Làm</h2>
    <div class='card'>
        <p><span class='good'>[Đã làm]</span> Tự động làm sạch Thùng rác (Trash).</p>
    </div>
</div>
</body>
</html>
EOF

# 4. Tự động mở báo cáo
open "$HTML_PATH"
