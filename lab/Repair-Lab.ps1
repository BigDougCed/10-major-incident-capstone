#Requires -RunAsAdministrator
<#
.SYNOPSIS
    LAB ONLY: repairs MI-2026-001 on DC01 (removes filler, starts AD DS/DNS, fixes NTP).

.EXAMPLE
    .\Repair-Lab.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$NtpServers = @('0.de.pool.ntp.org', '1.de.pool.ntp.org'),
    [string]$LabDomain = 'corp.nordlicht.internal'
)

$ErrorActionPreference = 'Stop'
if ((Get-CimInstance Win32_ComputerSystem).Domain -ne $LabDomain) { throw "Not in lab domain $LabDomain." }

# --- Cause 1 ----------------------------------------------------------------
if ((Test-Path 'C:\Backup\filler.bin') -and $PSCmdlet.ShouldProcess('C:\Backup\filler.bin', 'Delete')) {
    Remove-Item 'C:\Backup\filler.bin' -Force
    Write-Host "[+] Filler removed, C: free: $([math]::Round((Get-PSDrive C).Free / 1GB, 1)) GB" -ForegroundColor Green
}

if ($PSCmdlet.ShouldProcess('NTDS, DNS, KDC, Netlogon', 'Start services')) {
    foreach ($svc in 'NTDS', 'DNS', 'KDC', 'Netlogon') {
        if ((Get-Service $svc).Status -ne 'Running') { Start-Service $svc }
    }
    Write-Host '[+] AD DS, DNS, KDC, Netlogon running' -ForegroundColor Green
}

# --- Cause 2 ----------------------------------------------------------------
if ($PSCmdlet.ShouldProcess('Windows Time', "Use $($NtpServers -join ', ') as reliable source and resync")) {
    $peers = ($NtpServers | ForEach-Object { "$_,0x8" }) -join ' '
    & w32tm.exe /config /manualpeerlist:"$peers" /syncfromflags:manual /reliable:yes /update | Out-Null
    Restart-Service w32time
    Start-Sleep -Seconds 3
    & w32tm.exe /resync /rediscover | Out-Null
    Write-Host '[+] Time service reconfigured' -ForegroundColor Green
    & w32tm.exe /query /status
}

# --- Verify -----------------------------------------------------------------
Write-Host "`n--- Verification ---" -ForegroundColor Cyan
Write-Host 'dcdiag (no output below = no errors):'
& dcdiag.exe /test:services /test:advertising /q
Resolve-DnsName "_ldap._tcp.dc._msdcs.$LabDomain" -Type SRV | Select-Object -First 1 Name, NameTarget
Write-Host 'Clients: restart or run "w32tm /resync" if they picked up the wrong time.' -ForegroundColor Yellow
