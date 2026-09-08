# Auto Health Check & Cleaner (OS)

Script tự động dọn file tạm và tạo báo cáo tình trạng hệ thống (CPU, RAM, ổ cứng) bằng file HTML khi khởi động máy. Hỗ trợ Windows và macOS.

## Cài đặt

### Windows
1. Chuột phải vào `install.ps1` chọn **Run with PowerShell** (hoặc chạy trong PowerShell: `.\install.ps1`).
2. Script tự động tạo tác vụ chạy ngầm trong thư mục Startup.

*Gỡ cài đặt:* Xóa `AutoSystemCheck.vbs` trong Startup (`Win + R` -> gõ `shell:startup`) và xóa `AutoSystemCheck.ps1` trong thư mục `Documents`.

### macOS
Mở Terminal tại thư mục dự án và chạy:
```bash
chmod +x install_mac.sh
./install_mac.sh
```

*Gỡ cài đặt:*
```bash
launchctl unload ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Documents/AutoSystemCheck_macOS.sh
```
