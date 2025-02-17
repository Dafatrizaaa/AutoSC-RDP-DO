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
ADMIN_USER="Administrator"
ADMIN_PASS="@NEXUS1S"

# Pastikan direktori /mnt/windows ada
if [ ! -d /mnt/windows ]; then
    echo "[!] Direktori /mnt/windows tidak ada, membuat direktori..."
    mkdir -p /mnt/windows
fi

# Pastikan /dev/vda1 ada (partisi yang sesuai)
if ! lsblk | grep -q "/dev/vda1"; then
    echo "[!] Tidak ada perangkat /dev/vda1, pastikan disk terpasang dengan benar!"
    exit 1
fi

# Instalasi Windows
echo "Mengunduh Windows dari $PILIHOS..."
wget -O /tmp/windows.gz "$PILIHOS"

# Cek apakah file berhasil diunduh
if [ ! -f /tmp/windows.gz ]; then
    echo "[!] Gagal mengunduh file Windows!"
    exit 1
fi

echo "Meng-ekstrak dan menulis Windows ke disk..."
gunzip /tmp/windows.gz
dd if=/tmp/windows of=/dev/vda bs=4M status=progress

# Cek jika proses dd berhasil
if [ $? -ne 0 ]; then
    echo "[!] Gagal menulis Windows ke disk!"
    exit 1
fi

# Mount volume Windows
echo "Mounting volume Windows ke /mnt/windows..."
mount /dev/vda1 /mnt/windows

# Cek apakah mount berhasil
if [ ! -d /mnt/windows ]; then
    echo "[!] Gagal mounting volume Windows!"
    exit 1
fi

# Mengaktifkan RDP dan membuka firewall
echo "Mengaktifkan Remote Desktop..."
cat <<EOF > /mnt/windows/System32/config/system.reg
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server]
"fDenyTSConnections"=dword:00000000
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
"PortNumber"=dword:0000270f
EOF

# Mengatur firewall untuk RDP
echo "Mengatur firewall untuk RDP..."
cat <<EOF > /mnt/windows/System32/config/firewall.reg
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List]
"9999:TCP"="9999:TCP:*:Enabled:RDP"
EOF

# Mengganti username dan password default menjadi Administrator
echo "Mengganti username dan password default menjadi Administrator dengan password @NEXUS1S"
cat <<EOF > /mnt/windows/System32/config/user.reg
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]
"DefaultUserName"="$ADMIN_USER"
"DefaultPassword"="$ADMIN_PASS"
EOF

# Konfigurasi selesai
echo "Konfigurasi selesai. Silakan reboot VM dan akses melalui Remote Desktop pada port 9999."
