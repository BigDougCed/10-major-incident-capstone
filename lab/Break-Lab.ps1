#Requires -RunAsAdministrator
<#
.SYNOPSIS
    LAB ONLY: reproduces major incident MI-2026-001 on DC01 (disk full + clock skew).

.DESCRIPTION
    Cause 1: fills C: with C:\Backup\filler.bin (leaves -LeaveFreeMB) and stops NTDS + DNS
             (simulates what a full disk does to AD DS, but predictably).
    Cause 2: sets the NTP source to a dead IP and moves the clock forward by -SkewMinutes.

    Safety: only runs in the domain corp.nordlicht.internal, asks for confirmation (ConfirmImpact High),
    supports -WhatIf. Take a Hyper-V checkpoint first. Undo with Repair-Lab.ps1.

.EXAMPLE
    .\Break-Lab.ps1 -WhatIf
    .\Break-Lab.ps1
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [ValidateRange(100, 2048)][int]$LeaveFreeMB = 300,
    [ValidateRange(6, 30)][int]$SkewMinutes = 7,
    [string]$DeadNtpServer = '10.10.10.254',
    [string]$LabDomain = 'corp.nordlicht.internal'
)

$ErrorActionPreference = 'Stop'

# --- Safety guard -----------------------------------------------------------
$domain = (Get-CimInstance Win32_ComputerSystem).Domain
if ($domain -ne $LabDomain) {
    throw "Refusing to run: this computer is in '$domain', not the lab domain '$LabDomain'."
}
if (-not (Get-Service NTDS -ErrorAction SilentlyContinue)) {
    throw 'Refusing to run: this is not a domain controller.'
}
Write-Warning "This will break AD on $env:COMPUTERNAME for the exercise. Did you take a checkpoint?"

# --- Cause 1: disk full -----------------------------------------------------
$freeBytes = (Get-PSDrive C).Free
$fillBytes = [int64]($freeBytes - ($LeaveFreeMB * 1MB))
if ($fillBytes -le 0) {
    Write-Warning "C: already has less than $LeaveFreeMB MB free - no filler needed."
} elseif ($PSCmdlet.ShouldProcess('C:\Backup\filler.bin', "Create $([math]::Round($fillBytes / 1GB, 1)) GB filler file")) {
    New-Item -Path 'C:\Backup' -ItemType Directory -Force | Out-Null
    & fsutil.exe file createnew 'C:\Backup\filler.bin' $fillBytes | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'fsutil failed to create the filler file.' }
    Write-Host "[x] C: filled, $([math]::Round((Get-PSDrive C).Free / 1MB)) MB left" -ForegroundColor Red
}

if ($PSCmdlet.ShouldProcess('NTDS, DNS', 'Stop services (simulated low-disk failure)')) {
    Stop-Service NTDS -Force      # also stops dependent services (KDC, DFSR, ...)
    Stop-Service DNS -Force
    Write-Host '[x] AD DS and DNS stopped' -ForegroundColor Red
}

# --- Cause 2: clock skew ----------------------------------------------------
if ($PSCmdlet.ShouldProcess('Windows Time', "Point NTP to dead $DeadNtpServer and skew clock +$SkewMinutes min")) {
    & w32tm.exe /config /manualpeerlist:"$DeadNtpServer,0x8" /syncfromflags:manual /update | Out-Null
    Restart-Service w32time
    Set-Date -Date (Get-Date).AddMinutes($SkewMinutes) | Out-Null
    Write-Host "[x] NTP -> $DeadNtpServer, clock now $(Get-Date -Format 'HH:mm:ss') (+$SkewMinutes min)" -ForegroundColor Red
}

Write-Host "`nIncident is live. Start working it from the user's side (tickets, Uptime Kuma)." -ForegroundColor Yellow
