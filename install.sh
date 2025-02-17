#!/bin/bash

echo "SCRIPT AUTO INSTALL WINDOWS by HIDESSH"
echo
echo "Pilih OS yang ingin anda install"
echo "[1] Windows 2019(Default)"
echo "[2] Windows 2016"
echo "[3] Windows 2012"
echo "[4] Windows 10"
echo "[5] Chat Ryan Untuk Add OS lain"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
    1|"") PILIHOS="http://143.198.203.169/Windows10.gz";;
    2) PILIHOS="https://file.nixpoin.com/windows2016.gz";;
    3) PILIHOS="https://download1589.mediafire.com/ws12.gz";;
    4) PILIHOS="http://143.198.203.169/Windows10.gz";;
    5) read -p "[?] Masukkan Link GZ mu : " PILIHOS;;
    *) echo "[!] Pilihan salah"; exit;;
esac

# Konfigurasi password Administrator
read -p "Masukkan password untuk akun Administrator RDP anda: " ADMIN_PASS

# Instalasi Windows
echo "Menginstal Windows dari $PILIHOS"
wget -O /tmp/windows.gz "$PILIHOS"
echo "Ekstrak dan pasang Windows..."
# Perintah ekstraksi dan pemasangan spesifik sesuai metode DigitalOcean

# Mengaktifkan RDP dan membuka firewall
echo "Mengaktifkan Remote Desktop..."
cat <<EOF >> /mnt/windows/System32/config/system.reg
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server]
"fDenyTSConnections"=dword:00000000
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
"PortNumber"=dword:0000270f
EOF

# Mengatur firewall untuk RDP
echo "Mengatur firewall untuk RDP..."
cat <<EOF >> /mnt/windows/System32/config/firewall.reg
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List]
"9999:TCP"="9999:TCP:*:Enabled:RDP"
EOF

# Konfigurasi selesai
echo "Konfigurasi selesai. Silakan reboot VM dan akses melalui Remote Desktop pada port 9999."
