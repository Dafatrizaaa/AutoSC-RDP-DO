#!/bin/bash
set -e

echo "=== AUTO INSTALL WINDOWS RDP ==="

# Pilih OS secara otomatis (default: Windows 2019)
OS_URL="https://download1589.mediafire.com/om29odxbrj5g38gUMD7RWK7ZL1IsI9J8Z5o2Ql9VbYIwq_zdf6YFgHJC6NCcQeWRIgW0YtHu3NhXPbBzbcYeOtKMHW2MmujTqFdnoV95L0rwtw0BKdv-PWJhhor4Wxu8K7CiQIKJEwobcL8REtIskfXJW6PjUjJYSQi1XCyxiGsQWw/2fclsa87a89ro29/ws12%2853058%29.gz"
PASSWORD="SecureRDP2025!"
PORT=3389

# Unduh dan ekstrak image Windows
echo "[*] Mengunduh Windows Image..."
wget -O windows.gz "$OS_URL"
echo "[*] Ekstrak image..."
gunzip -c windows.gz > /dev/sda

# Konfigurasi password Administrator
echo "[*] Mengatur password Administrator..."
echo -e "$PASSWORD\n$PASSWORD" | passwd Administrator

# Konfigurasi firewall dan port
echo "[*] Mengatur firewall dan membuka port RDP..."
ufw allow $PORT/tcp
ufw enable

# Aktifkan layanan RDP
echo "[*] Mengaktifkan layanan RDP..."
systemctl enable xrdp
echo "[*] Memulai ulang layanan RDP..."
systemctl restart xrdp

echo "=== Instalasi Selesai! ==="
echo "Gunakan RDP dengan IP VPS dan port $PORT"
echo "Username: Administrator"
echo "Password: $PASSWORD"
