# 🚀 Cross-Platform Auto Health Check & Cleaner

Một công cụ tự động siêu nhẹ dành cho **Windows** và **macOS**. Công cụ này sẽ tự động **dọn dẹp rác** và **hiển thị một bản Báo Cáo Sức Khỏe chi tiết (HTML)** mỗi khi bạn bật máy tính lên. 

## ✨ Tính Năng Nổi Bật
- 🗑️ **Dọn rác tự động ngầm:** Tự động xóa sạch thư mục rác (Temp/Trash) mà không hiện cửa sổ khó chịu.
- 📊 **Báo cáo HTML trực quan:** Hiển thị tự động trên trình duyệt Edge/Chrome/Safari ngay khi mở máy.
- 🧠 **Phân tích tài nguyên:** Báo cáo chi tiết về CPU, RAM, Ổ cứng.
- 🛡️ **Hỗ trợ đa nền tảng:** Có file cài đặt chuyên biệt cho Windows và macOS (Apple Silicon & Intel).

## 🪟 Hướng Dẫn Dành Cho Windows
1. Tải thư mục này về máy.
2. Click chuột phải vào file **install.ps1** và chọn **Run with PowerShell**.
3. (Nếu có thông báo đỏ hiện lên, hãy gõ Y và nhấn Enter để cấp quyền chạy Script).
4. **Xong!** 🎉 Mỗi lần bạn bật máy, bảng báo cáo sẽ tự động hiện lên sau 15 giây.

*(Gỡ cài đặt Windows: Nhấn Win + R -> gõ shell:startup -> xóa file AutoSystemCheck.vbs. Sau đó vào Documents xóa AutoSystemCheck.ps1)*

## 🍎 Hướng Dẫn Dành Cho macOS (MacBook, iMac, Mac mini)
1. Tải thư mục này về máy Mac của bạn.
2. Mở ứng dụng **Terminal** và điều hướng (cd) vào thư mục tải về.
3. Chạy lệnh cấp quyền: chmod +x install_mac.sh
4. Chạy file cài đặt: ./install_mac.sh
5. **Xong!** 🎉 Hệ thống sẽ thêm một LaunchAgent để tự chạy báo cáo mỗi khi bạn đăng nhập vào Mac.

*(Gỡ cài đặt Mac: Mở Terminal gõ launchctl unload ~/Library/LaunchAgents/com.user.autohealthcheck.plist, sau đó xóa file .plist đó và xóa ~/Documents/AutoSystemCheck_macOS.sh)*

## 📜 Giấy phép
Mã nguồn mở, chia sẻ miễn phí cho cộng đồng!
