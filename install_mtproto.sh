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
    "User01": "c87ebc6c55fd2387187aca574e6ed809",
    "User02": "7ff756f2a5ae7696ba9f2bca8eb89838",
    "User03": "cd2e3a6cd67101797b470a289f9221f9",
    "User04": "f88e5cdac5ba9c5f5c829a0ad70d2194",
    "User05": "389b20dc2b3d122026d67b75aa828c5c",
    "User06": "b3c13c6fc82699f17ab75879da689dfc",
    "User07": "baac3bab9c3330e13f3b97eec73968f8",
    "User08": "b8d610a2d6316db9be49a7b26243d7b8",
    "User09": "f53be43c08e2e70a3cc93d45c4531aa7",
    "User10": "16ca288722d4352123a6edad90888ad9"
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
  c87ebc6c55fd2387187aca574e6ed809 \
  7ff756f2a5ae7696ba9f2bca8eb89838 \
  cd2e3a6cd67101797b470a289f9221f9 \
  f88e5cdac5ba9c5f5c829a0ad70d2194 \
  389b20dc2b3d122026d67b75aa828c5c \
  b3c13c6fc82699f17ab75879da689dfc \
  baac3bab9c3330e13f3b97eec73968f8 \
  b8d610a2d6316db9be49a7b26243d7b8 \
  f53be43c08e2e70a3cc93d45c4531aa7 \
  16ca288722d4352123a6edad90888ad9
do
  echo "tg://proxy?server=proxy.namdm.io.vn&port=443&secret=ee${SECRET}${HEX_DOMAIN}"
done
