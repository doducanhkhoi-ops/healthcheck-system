#!/bin/bash
echo "Đang cài đặt Hệ Thống Báo Cáo Sức Khỏe Tự Động cho Mac..."

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
DEST_SCRIPT="$HOME/Documents/AutoSystemCheck_macOS.sh"

# Copy và cấp quyền thực thi
cp "$SCRIPT_DIR/AutoSystemCheck_macOS.sh" "$DEST_SCRIPT"
chmod +x "$DEST_SCRIPT"

# Tạo LaunchAgent để tự chạy lúc mở máy
PLIST_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$PLIST_DIR"
PLIST_PATH="$PLIST_DIR/com.user.autohealthcheck.plist"

cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.autohealthcheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>$DEST_SCRIPT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

launchctl load "$PLIST_PATH" 2>/dev/null

echo "Cài đặt THÀNH CÔNG! ✅ Máy Mac sẽ tự báo cáo khi khởi động."
