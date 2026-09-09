# HealthCheck System (Windows & macOS)

Bộ công cụ tự động dọn dẹp hệ thống, phân tích dung lượng ổ đĩa C/D và tạo báo cáo kiểm tra sức khỏe phần cứng định kỳ. Hỗ trợ kích hoạt chạy ngầm khi khởi động máy, tích hợp trực tiếp với trình duyệt Brave và chuẩn bị sẵn dữ liệu phân tích cho AI (ChatGPT, Gemini).

---

## Tính năng chính

### 1. Dọn dẹp rác hệ thống tự động
- Làm sạch Thùng rác (Recycle Bin).
- Dọn dẹp file tạm người dùng (%TEMP%) và file tạm hệ thống (C:\Windows\Temp).
- Xóa các bản ghi crash ứng dụng (.dmp) và báo cáo lỗi Windows Error Reporting (WER).
- Tự động dọn báo cáo cũ trước khi xuất bản mới, tránh chiếm dung lượng Documents.
- Giữ bộ nhớ đệm (cache) của Microsoft Edge và Cốc Cốc ở mức tối thiểu khi không sử dụng.

### 2. Quét sâu ổ đĩa C và D
- Sử dụng đối tượng Windows Scripting FileSystemObject (FSO) để duyệt cây thư mục nhanh chóng mà không làm chậm máy.
- Liệt kê các thư mục chiếm nhiều dung lượng nhất theo phân vùng.
- Tự động phát hiện các file dung lượng lớn (> 250 MB hoặc > 1 GB) như file cài đặt, file nén (.zip, .rar), bản ghi màn hình để người dùng dễ kiểm soát.

### 3. Tích hợp Brave và Trợ lý AI
- **Kích hoạt qua CDP:** Mở hoặc chuyển tab báo cáo trực tiếp trên trình duyệt Brave đang hoạt động thông qua cổng Chrome DevTools Protocol (CDP 9222).
- **AI Connect Hub:** Giao diện báo cáo tích hợp nút copy nhanh prompt tóm tắt thông số máy tính, sẵn sàng để dán (Ctrl + V) vào ChatGPT hoặc Gemini để nhận tư vấn kỹ thuật.

### 4. Chạy ngầm khi khởi động
- Script cài đặt install.ps1 tạo tiến trình VBScript ẩn trong Windows Startup (shell:startup).
- Chạy hoàn toàn dưới nền sau khi người dùng đăng nhập Windows, không hiện cửa sổ console gây gián đoạn.

---

## Cấu trúc thư mục

`	ext
healthcheck-system/
├── AutoSystemCheck.ps1        # Script chính trên Windows (quét ổ đĩa, dọn rác, xuất HTML)
├── install.ps1               # Cài đặt tự động chạy ngầm vào Windows Startup
├── uninstall.ps1             # Gỡ bỏ khỏi Windows Startup
├── AutoSystemCheck_macOS.sh   # Bản kiểm tra tương thích cho macOS
├── install_mac.sh            # Cài đặt dịch vụ nền trên macOS (LaunchAgent)
├── .gitignore                # Bỏ qua báo cáo HTML sinh ra và file tạm
└── README.md                 # Tài liệu hướng dẫn sử dụng
`

---

## Hướng dẫn sử dụng

### Trên Windows

#### 1. Chạy thử nghiệm ngay
Mở PowerShell tại thư mục dự án:
`powershell
powershell -ExecutionPolicy Bypass -File .\AutoSystemCheck.ps1 -Quick
`
*Script sẽ dọn rác, quét phân vùng và mở báo cáo Bao_Cao_He_Thong.html trên trình duyệt Brave.*

#### 2. Cài đặt vào Startup (Tự chạy mỗi khi bật máy)
`powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
`
*Script sẽ sao chép AutoSystemCheck.ps1 vào thư mục Documents và tạo file kích hoạt ẩn AutoSystemCheck.vbs trong thư mục Startup.*

#### 3. Gỡ cài đặt khỏi Startup
`powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
`

---

### Trên macOS

#### 1. Cài đặt LaunchAgent
Mở Terminal tại thư mục dự án:
`ash
chmod +x install_mac.sh
./install_mac.sh
`

#### 2. Gỡ cài đặt
`ash
launchctl unload ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Documents/AutoSystemCheck_macOS.sh
`
