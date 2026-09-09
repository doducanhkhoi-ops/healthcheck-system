# 🚀 Auto Health Check & System Cleaner (Windows & macOS)

Hệ thống tự động kiểm tra sức khỏe máy tính toàn diện, dọn rác bộ máy, đào sâu các ổ đĩa (C & D) để phát hiện file lớn, đóng băng & dọn dẹp cache trình duyệt, tích hợp trực tiếp với trình duyệt **Brave** qua cổng DevTools (CDP) và kết nối với **Trợ lý AI (ChatGPT / Gemini)**.

---

## ✨ Tính Năng Nổi Bật

### 1. 🧹 Tự Động Dọn Rác & Bộ Nhớ Đệm (Auto Cleaner)
- **Thùng rác hệ thống (Recycle Bin):** Tự động dọn sạch mọi file rác.
- **File tạm thời:** Quét và làm sạch User Temp (%TEMP%) và Windows Temp.
- **Lỗi & Crash:** Tự động loại bỏ các tệp Windows Error Reporting (WER) và tệp Crash Dump (.dmp) chiếm bộ nhớ.
- **Bản báo cáo cũ:** Tự động phát hiện và xóa các file báo cáo HTML cũ trước khi tạo bản mới, tránh rác thư mục Documents.
- **Đóng băng cache trình duyệt:** Tự động làm sạch và duy trì cache của Microsoft Edge và Cốc Cốc ở mức tối thiểu (0 MB) khi không sử dụng.

### 2. 🔍 Đào Sâu Đa Ổ Đĩa (Deep Multi-Drive Scan: C: & D:)
- Sử dụng đối tượng siêu tốc **Windows Scripting FileSystemObject (FSO)** giúp duyệt toàn bộ cây thư mục chỉ trong vài giây.
- Phân tích chi tiết tỷ lệ chiếm dụng theo thư mục gốc của từng ổ đĩa.
- Tự động liệt kê danh sách các file dung lượng khổng lồ (> 250 MB / > 1 GB) như video quay màn hình, file cài đặt, file nén (.zip, .rar, .iso) kèm đường dẫn chi tiết để người dùng cân nhắc giải phóng.

### 3. 🌐 Tích Hợp Trực Tiếp Trình Duyệt Brave & AI Connect Hub
- **Kết nối Brave qua CDP:** Tự động gửi và kích hoạt tab báo cáo trực tiếp trên trình duyệt Brave đang mở qua Chrome DevTools Protocol (CDP port 9222), tránh bị ẩn cửa sổ hay mở trùng lặp.
- **AI Connect Hub:**
  - Tích hợp sẵn khung dữ liệu tổng hợp hiện trạng hệ thống dạng cấu trúc chuẩn cho AI.
  - Nút bấm 1 chạm: **Copy Dữ Liệu Báo Cáo** (tự động nạp prompt vào Clipboard).
  - Nút bấm mở nhanh **ChatGPT** và **Google Gemini** để người dùng chỉ cần nhấn Ctrl + V là có ngay phân tích chuyên sâu.

### 4. 🗂️ Hỗ Trợ Kỹ Thuật NTFS Directory Junctions (mklink /J)
- Hướng dẫn và cung cấp giải pháp di dời các thư mục học tập/dữ liệu lớn sang ổ **D:** nhưng vẫn giữ nguyên đường dẫn ảo tại C:\Users\<User>\Documents\ để phần mềm (Office, Photoshop...) mở bình thường mà ổ C không tốn dung lượng.

### 5. ⚡ Khởi Động Cùng Windows Cực Êm (Silent Startup)
- Tích hợp trình cài đặt install.ps1 và gỡ bỏ uninstall.ps1.
- Kích hoạt qua tệp VBScript ẩn, chạy ngầm hoàn toàn sau khi bật máy mà không làm gián đoạn công việc hay hiện cửa sổ đen PowerShell.

---

## 📁 Cấu Trúc Dự Án

`	ext
lively-nobel/
├── AutoSystemCheck.ps1        # Script chính kiểm tra sức khỏe & tạo báo cáo trên Windows
├── install.ps1               # Tự động đồng bộ và cài đặt vào Windows Startup (chạy ngầm)
├── uninstall.ps1             # Gỡ cài đặt hoàn toàn khỏi Windows Startup
├── AutoSystemCheck_macOS.sh   # Bản kiểm tra tương thích cho hệ điều hành macOS
├── install_mac.sh            # Cài đặt tự động chạy nền trên macOS (LaunchAgent)
├── .gitignore                # Bỏ qua các file sinh tự động, file log và báo cáo HTML
└── README.md                 # Tài liệu hướng dẫn sử dụng chi tiết
`

---

## 💻 Hướng Dẫn Sử Dụng Trên Windows

### 1. Chạy Thử Nghiệm Nhanh (Không Chờ Trễ)
Mở PowerShell tại thư mục dự án và thực hiện:
`powershell
powershell -ExecutionPolicy Bypass -File .\AutoSystemCheck.ps1 -Quick
`
*Script sẽ dọn rác, quét ổ C & D, tạo báo cáo Bao_Cao_He_Thong.html và tự động hiển thị ngay trong tab của trình duyệt Brave.*

---

### 2. Cài Đặt Vào Startup (Tự Chạy Khi Khởi Động Máy)
Để cài đặt hoặc cập nhật phiên bản mới nhất:
`powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
`
> **Cơ chế:** Script sẽ sao chép AutoSystemCheck.ps1 vào thư mục Documents và tạo lối tắt ẩn AutoSystemCheck.vbs trong thư mục shell:startup.

---

### 3. Gỡ Cài Đặt Khỏi Startup
Nếu không muốn script tự chạy mỗi khi khởi động:
`powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
`

---

## 🍎 Hướng Dẫn Sử Dụng Trên macOS

### Cài đặt LaunchAgent:
`ash
chmod +x install_mac.sh
./install_mac.sh
`

### Gỡ cài đặt:
`ash
launchctl unload ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Library/LaunchAgents/com.user.autohealthcheck.plist
rm ~/Documents/AutoSystemCheck_macOS.sh
`
