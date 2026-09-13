# HealthCheck System

Công cụ dọn dẹp và báo cáo tình trạng hệ thống tự động.

## Chức năng
- Dọn rác: File tạm (Temp, Windows Temp), cache trình duyệt (Edge, Cốc Cốc), thùng rác, crash dumps.
- Giải phóng RAM: Tự động chạy [Mem Reduct](https://github.com/henrypp/memreduct/releases) (nếu đã cài) trước khi xuất báo cáo.
- Quét ổ đĩa: Tìm file/thư mục lớn, tổng hợp dung lượng trống.
- Báo cáo: Tự xuất file HTML trực quan, gợi ý chuyển file sang ổ khác, hỗ trợ prompt copy nhanh cho AI.

## Sử dụng (Windows)

**Chạy ngay (không cài đặt):**
```powershell
powershell -ExecutionPolicy Bypass -File .\AutoSystemCheck.ps1 -Quick
```

**Cài đặt tự chạy lúc khởi động:**
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**Gỡ cài đặt:**
```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## Sử dụng (macOS)

**Cài đặt LaunchAgent:**
```bash
chmod +x install_mac.sh
./install_mac.sh
```

**Gỡ cài đặt:**
```bash
launchctl unload ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Documents/AutoSystemCheck_macOS.sh
```
