@echo off
setlocal
title ONE-CLICK DESKTOP SETUP
color 0A

:: ==========================================
:: 1. AUTO ELEVATE (Minta Izin Admin)
:: ==========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] BUTUH ADMIN. RELAUNCHING...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ==================================================
echo   ONE-CLICK DESKTOP SETUP
echo   Unlocking Policy, Icons, Taskbar & Wallpaper
echo ==================================================
echo.
timeout /t 2 >nul

:: ==========================================
:: 2. HANCURKAN BLOKIR POLICY (GROUP POLICY)
:: ==========================================
echo [1/4] Menghancurkan Policy & Group Policy...
powershell -ExecutionPolicy Bypass -Command ^
  "Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies' -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "Remove-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies' -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "Remove-Item -Path 'HKCU:\Software\Policies\Microsoft\Windows' -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "Remove-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows' -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "Remove-Item -Path ($env:WinDir + '\System32\GroupPolicy') -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "Remove-Item -Path ($env:WinDir + '\System32\GroupPolicyUsers') -Recurse -Force -ErrorAction SilentlyContinue"

:: ==========================================
:: 3. MUNCULIN ICON DESKTOP
:: ==========================================
echo [2/4] Menampilkan semua Icon Desktop...
:: Matiin "Hide Desktop Icons"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 0 /f >nul

:: Nampilin This PC, User Folder, Network, Recycle Bin
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f >nul

:: ==========================================
:: 4. RAPIIN TASKBAR (Munculin Search & Icon)
:: ==========================================
echo [3/4] Mengatur Taskbar...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAutoHide /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarLocked /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v AlwaysShowAllIcons /t REG_DWORD /d 1 /f >nul

:: ==========================================
:: 5. GANTI WALLPAPER & RESTART EXPLORER
:: ==========================================
echo [4/4] Mengatur Wallpaper & Restart Explorer...
:: (Opsional) Ganti wallpaper ke default Windows
set "WALL=C:\Windows\Web\Wallpaper\Windows\img0.jpg"
if exist "%WALL%" (
    powershell -Command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class W { [DllImport(\"user32.dll\")] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [W]::SystemParametersInfo(20, 0, '%WALL%', 3)"
)

:: Restart Explorer biar semua settingan langsung kebaca
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe
ie4uinit.exe -show >nul 2>&1

echo.
echo ==================================================
echo   [X] DESKTOP BERHASIL DISETUP! [X]
echo ==================================================
echo.
echo  - Blokir Policy : DIHAPUS
echo  - Icon Desktop  : MUNCUL
echo  - Taskbar       : RAPI
echo  - Wallpaper     : DEFAULT
echo.
echo Tekan tombol apa saja untuk keluar...
pause >nul