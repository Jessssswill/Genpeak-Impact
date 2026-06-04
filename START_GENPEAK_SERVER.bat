@echo off
title GenPeak Impact Server - Localtunnel
echo ===================================================
echo Memulai GenPeak Impact Server...
echo ===================================================
cd backend

echo [1/2] Menyalakan Backend Database...
start "GenPeak Backend" cmd /k "npm start dev"

echo Menunggu backend siap (5 detik)...
timeout /t 5 /nobreak >nul

echo [2/2] Membuka Jalur Internet (Localtunnel)...
echo.
echo ===================================================
echo JANGAN TUTUP JENDELA INI SELAMA BERMAIN
echo ===================================================
:loop
npx localtunnel --port 5000 --subdomain moody-bat-91
echo.
echo [!] Localtunnel terputus. Mencoba menyambung ulang dalam 2 detik...
timeout /t 2 /nobreak >nul
goto loop
