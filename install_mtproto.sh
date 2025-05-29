#!/bin/bash

echo "[+] Cài đặt MTProto Proxy với nhiều người dùng và TLS Fake Domain..."

# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cài đặt các gói cần thiết
sudo apt install -y python3 python3-pip git

# Tải mã nguồn MTProto proxy
git clone https://github.com/alexbers/mtprotoproxy.git /opt/mtprotoproxy
cd /opt/mtprotoproxy

# Cài đặt thư viện Python cần thiết
pip3 install -r requirements.txt

# Tạo file cấu hình
cat <<EOF > config.py
PORT = 443
TLS_DOMAIN = "cdn.cloudflare.com"

USERS = {
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d1": "User01",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d2": "User02",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d3": "User03",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d4": "User04",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d5": "User05",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6": "User06",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d7": "User07",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d8": "User08",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d9": "User09",
    "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5da": "User10"
}

MODES = {
    "secure": True,
    "tls": True
}

EOF

# Tạo systemd service để chạy ngầm
sudo bash -c 'cat <<EOF > /etc/systemd/system/mtproto.service
[Unit]
Description=MTProto Proxy for Telegram
After=network.target

[Service]
WorkingDirectory=/opt/mtprotoproxy
ExecStart=/usr/bin/python3 /opt/mtprotoproxy/mtprotoproxy.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Khởi động dịch vụ
sudo systemctl daemon-reload
sudo systemctl enable mtproto
sudo systemctl start mtproto

# Hiển thị thông tin kết nối cho từng người dùng
echo
echo "✅ MTProto Proxy đang chạy!"
echo "🌐 Tên miền: proxy.namdm.io.vn"
echo "🔗 Link truy cập cho từng người dùng:"
for SECRET in "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6" "abcdefabcdefabcdefabcdefabcdefab" "1234567890abcdef1234567890abcdef"; do
    HEX_DOMAIN=$(echo -n "cdn.cloudflare.com" | xxd -ps)
    echo "tg://proxy?server=proxy.namdm.io.vn&port=443&secret=ee${SECRET}${HEX_DOMAIN}"
done
