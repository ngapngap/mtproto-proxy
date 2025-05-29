#!/bin/bash

echo "[+] Cài đặt MTProto Proxy với 10 user + TLS Fake Domain..."

# Cập nhật hệ thống và cài gói cần thiết
sudo apt update && sudo apt install -y python3 python3-pip git

# Clone mã nguồn MTProto proxy
git clone https://github.com/alexbers/mtprotoproxy.git /opt/mtprotoproxy
cd /opt/mtprotoproxy

# Cài thư viện Python
pip3 install -r requirements.txt

# Ghi file cấu hình
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

# Tạo systemd service
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

# Khởi động proxy
sudo systemctl daemon-reload
sudo systemctl enable mtproto
sudo systemctl start mtproto

# In link truy cập Telegram cho từng user
DOMAIN="cdn.cloudflare.com"
HEX_DOMAIN=$(echo -n "$DOMAIN" | xxd -ps -c 256)
echo
echo "✅ MTProto Proxy đang chạy!"
echo "🌐 Tên miền: proxy.namdm.io.vn"
echo "🔗 Link truy cập:"
for SECRET in \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d1 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d2 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d3 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d4 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d5 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d7 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d8 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d9 \
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5da
do
  echo "tg://proxy?server=proxy.namdm.io.vn&port=443&secret=ee${SECRET}${HEX_DOMAIN}"
done
