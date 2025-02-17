#!/bin/bash
set -e

echo "=== AUTO INSTALL WINDOWS RDP ==="

# Pilih OS secara otomatis (default: Windows 2019)
OS_URL="http://143.198.203.169/Windows10.gz"
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
