# Lab exercise: reproduce MI-2026-001

⚠️ **Lab only.** These scripts deliberately break a domain controller. They refuse to run unless the domain is `corp.nordlicht.internal`, and they ask for confirmation. **Take a Hyper-V checkpoint first:**
```powershell
Checkpoint-VM -Name DC01 -SnapshotName 'before MI-2026-001 exercise'
```

## Setup (on the Hyper-V host)
DC01 must not get its time from the host, otherwise Hyper-V would correct the clock:
```powershell
Disable-VMIntegrationService -VMName DC01 -Name 'Time Synchronization'
```

## 1. Break (on DC01, elevated PowerShell)
```powershell
.\Break-Lab.ps1 -WhatIf     # preview
.\Break-Lab.ps1
```
- **Cause 1:** fills C: with a filler file in `C:\Backup` until ~300 MB are left, then stops AD DS and DNS. Stopping them simulates the failure a full disk causes, so the lab result is predictable
- **Cause 2:** points the Windows time service to a non-existent NTP server (`10.10.10.254`) and sets the clock **7 minutes ahead**

## 2. Work the incident
Ideally ask a friend to run the break script so you don't know the details, then:
1. Watch Uptime Kuma alerts, create tickets in Zammad as "users"
2. Declare the major incident, send status updates (templates in [docs/03-communications.md](../docs/03-communications.md))
3. Troubleshoot with the [log](../docs/04-troubleshooting-log.md) as a guide, but try first without it
4. To see cause 2, you need a client whose clock is **correct** (like the laptops in the scenario). Before breaking the lab, set one client to take its time from the internet instead of the domain: `w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:manual /update` and `w32tm /resync`. Undo afterwards with `w32tm /config /syncfromflags:domhier /update`

## 3. Repair
```powershell
.\Repair-Lab.ps1
```
Removes the filler file, starts AD DS/DNS, configures external NTP and resyncs. Or revert the checkpoint.

## 4. Write your own review
Copy [docs/05-post-incident-review.md](../docs/05-post-incident-review.md) and fill it in with your real times and findings. That's the most valuable part.
