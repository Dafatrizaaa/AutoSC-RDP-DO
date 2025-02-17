#!/bin/bash
echo "SCRIPT AUTO INSTALL WINDOWS by HIDESSH"
echo
echo "Pilih OS yang ingin Anda install"
echo "[1] Windows 2019 (Default)"
echo "[2] Windows 2016"
echo "[3] Windows 2012"
echo "[4] Windows 10"
echo "[5] Chat Ryan Untuk Add OS lain"

read -p "Pilih [1]: " PILIHOS

# Default ke Windows 10 jika tidak ada pilihan
case "$PILIHOS" in
    1|"") PILIHOS="http://143.198.203.169/Windows10.gz";;
    2) PILIHOS="https://file.nixpoin.com/windows2016.gz";;
    3) PILIHOS="https://download1589.mediafire.com/om29odxbrj5g38gUMD7RWK7ZL1IsI9J8Z5o2Ql9VbYIwq_zdf6YFgHJC6NCcQeWRIgW0YtHu3NhXPbBzbcYeOtKMHW2MmujTqFdnoV95L0rwtw0BKdv-PWJhhor4Wxu8K7CiQIKJEwobcL8REtIskfXJW6PjUjJYSQi1XCyxiGsQWw/2fclsa87a89ro29/ws12%2853058%29.gz";;
    4) PILIHOS="http://143.198.203.169/Windows10.gz";;
    5) read -p "[?] Masukkan Link GZ mu : " PILIHOS;;
    *) echo "[!] Pilihan salah"; exit 1;;
esac

# Mendapatkan alamat IP publik dan gateway default
IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Membuat skrip net.bat untuk mengatur akun Administrator dan jaringan
cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
    echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
    "%temp%\Admin.vbs"
    del /f /q "%temp%\Admin.vbs"
    exit /b 2
)

# Mengubah username dan password Administrator
net user Administrator @NEXUS1S
net localgroup administrators Administrator /add

# Aktifkan Remote Desktop
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes

# Mengatur IP dan DNS
for /f "tokens=3*" %%i in ('netsh interface show interface ^|findstr /I /R "Local.* Ethernet Ins*"') do (set InterfaceName=%%j)
netsh -c interface ip set address name="Ethernet Instance 0" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet Instance 0" address=8.8.8.8 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet Instance 0" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF

# Membuat skrip dpart.bat untuk mengubah port RDP dan mengonfigurasi firewall
cat >/tmp/dpart.bat<<EOF
@ECHO OFF
echo WaRNiNG HaZaRD 
echo JENDELA INI JANGAN DITUTUP
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 6969, UNTUK MENYAMBUNG KE RDP GUNAKAN ALAMAT $IP4:6969
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
    echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
    "%temp%\Admin.vbs"
    del /f /q "%temp%\Admin.vbs"
    exit /b 2
)

# Ubah port RDP menjadi 6969
set PORT=6969
set RULE_NAME="Open Port %PORT%"

# Membuka port firewall untuk RDP
netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    echo Rule %RULE_NAME% sudah ada.
) else (
    echo Rule %RULE_NAME% tidak ada. Membuat rule...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

# Ubah port RDP
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 6969

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q dpart.bat
timeout 50 >nul
del /f /q ChromeSetup.exe
echo JENDELA INI JANGAN DITUTUP
exit
EOF

# Mengunduh dan menginstal gambar Windows yang dipilih
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

# Memasang volume sistem dan menyalin file yang diperlukan
mount /dev/vda1 /mnt
if [ -d "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/" ]; then
    cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
    wget https://nixpoin.com/ChromeSetup.exe
    cp -f /tmp/net.bat net.bat
    cp -f /tmp/dpart.bat dpart.bat
else
    echo "[!] Direktori tidak ditemukan atau tidak dapat diakses."
fi

echo "Reboot RDP terlebih dahulu, baru bisa digunakan"
