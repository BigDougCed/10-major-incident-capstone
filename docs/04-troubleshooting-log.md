# 4 – Technical troubleshooting log

## Phase 1: "Drives and logons fail": scope it
| Check | Command / tool | Result | Conclusion |
|---|---|---|---|
| Is it everyone? | Ticket list | 3 departments, desktops + laptops | Central cause, not a client issue |
| What does monitoring say? | Uptime Kuma | DC01 ping ✅, LDAP ❌, DNS ❌ since 06:10 | Server is up but its services aren't. Look at DC01 itself |
| M365? | outlook.office.com | ✅ | Internet and cloud fine, so it's local infrastructure |

## Phase 2: DC01
```powershell
Get-PSDrive C | Select-Object Used, Free          # Free: ~0.2 GB
Get-WinEvent -LogName System -MaxEvents 30 | Where-Object LevelDisplayName -in 'Error','Warning' |
  Select-Object TimeCreated, ProviderName, Id, Message
Get-WinEvent -LogName 'Directory Service' -MaxEvents 20 | Select-Object TimeCreated, Id, LevelDisplayName, Message
Get-Service NTDS, DNS, Netlogon, KDC | Format-Table Name, Status
```
Findings: *Srv 2013* (disk near capacity) from 03:41, NTDS errors about lack of disk space, DNS server errors writing to disk.

Largest folders:
```powershell
Get-ChildItem C:\ -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
  [pscustomobject]@{ Folder = $_.FullName
    GB = [math]::Round((Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1GB, 1) }
} | Sort-Object GB -Descending | Select-Object -First 5
```
→ `C:\Backup` 41 GB. Task Scheduler › *Microsoft › Windows › Backup*, history: target changed on Thursday.

**Decision:** don't just delete the backup (it's the only recent one) → start copying it to the NAS, and in parallel delete only the oldest version to free space quickly:
```cmd
wbadmin get versions -backupTarget:C:
wbadmin delete backup -backupTarget:C: -keepVersions:1 -quiet
```
Then:
```powershell
Restart-Service NTDS -Force        # also restarts DNS, KDC, DFSR, Netlogon (dependent services)
dcdiag /test:services /test:advertising /test:sysvolcheck
Resolve-DnsName _ldap._tcp.dc._msdcs.corp.nordlicht.internal -Type SRV
```
✅ Services running, DC advertising, Uptime Kuma green at 07:48.

## Phase 3: "Still some laptops can't sign in"
Not every user, only laptops, after the disk fix → **different cause**. Don't assume the first fix was incomplete.

On an affected laptop (local admin / cached logon):
```cmd
klist                       REM no tickets
nltest /sc_query:corp.nordlicht.internal
w32tm /stripchart /computer:dc01.corp.nordlicht.internal /samples:3 /dataonly
```
Event Viewer › System: **Kerberos Event 4 / KRB_AP_ERR_SKEW**. `w32tm /stripchart` → offset **-432 s** (laptop is 7 min 12 s *behind* the DC).

Why only laptops? Desktops ran all weekend and synchronised their time **from DC01**, so they drifted along with it and matched. Laptops were at home over the weekend with the correct hardware clock. Kerberos allows max. **5 minutes** difference → rejected.

On DC01:
```cmd
w32tm /query /status          REM Source: Local CMOS Clock  -> no real time source!
w32tm /query /configuration   REM NtpServer: 10.10.10.254,0x8  -> old router, gone since October
netdom query fsmo             REM DC01 holds PDC emulator = time master of the domain
```

**Fix (emergency change, documented in the ticket):**
```cmd
w32tm /config /manualpeerlist:"0.de.pool.ntp.org,0x8 1.de.pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
net stop w32time && net start w32time
w32tm /resync /rediscover
w32tm /query /status          REM Source: 0.de.pool.ntp.org, offset < 1 s
```
Hyper-V: *Time Synchronization* integration service stays **off** for DC01 (a DC must get time from NTP, not from the host), documented.

Desktops (now 7 min fast) resynced from DC01: `w32tm /resync` via a quick Intune/GPO script, or simply a restart. Laptops: sign-in works immediately.

## Verification
| Test | Result |
|---|---|
| `dcdiag` (all tests) | Passed |
| `w32tm /monitor` | All machines within ±1 s of DC01 |
| Uptime Kuma | All monitors green |
| 3 users from different departments: sign in, open S:/A:/W:, print | ✅ |
