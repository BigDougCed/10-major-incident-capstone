# 2 – Timeline (Monday 2026-11-23)

IM = incident manager (coordination & communication) · TL = technical lead · SD = service desk

| Time | Who | Event / action |
|---|---|---|
| 02:07 | system | Windows Server Backup starts, target `C:\Backup` |
| 03:41 | system | DC01 System log: *Srv 2013 – The C: disk is at or near capacity*; Directory Service log: NTDS errors about insufficient disk space |
| 06:10 | Uptime Kuma | Alerts by e-mail: LDAP down, AD DNS down. DC01 **ping still up** |
| 07:05 | SD | INC-1030 "Laufwerk W: nicht verbunden" (Warehouse) |
| 07:12 | SD | INC-1031..1034: drives missing, "no logon servers available", printer offline |
| 07:18 | SD (Cedric) | Notices the pattern (5 tickets, 3 departments, same symptoms). Checks Uptime Kuma: LDAP + DNS red since 06:10 |
| **07:22** | SD → IT lead | **Major incident declared (P1)**. Cedric = IM, Thomas Becker = TL. INC-1030 becomes the parent ticket; new tickets linked to it |
| 07:25 | IM | Status page + Teams post + e-mail: **Update 1** (problem known, working on it) |
| 07:27 | IM | Phone message on the service desk line updated: "Bekannte Störung Netzlaufwerke, wir arbeiten daran" → fewer calls |
| 07:30 | TL | RDP to DC01 very slow. `Get-PSDrive C` → **0.2 GB free** |
| 07:34 | TL | `Get-ChildItem C:\ -Recurse` sizes → `C:\Backup\WindowsImageBackup` 41 GB. Backup target was changed on Thursday (found in task history) |
| 07:38 | IM | Briefs managing director by phone: cause found, ETA ~20 min for shares |
| 07:41 | TL | Decision: move backup data to the NAS (keep it, don't just delete) → started copy; meanwhile deleted the oldest backup version with `wbadmin delete backup -keepVersions:1` → 28 GB free |
| 07:46 | TL | `Restart-Service NTDS -Force` (restarts DNS, DFSR, KDC with it); `dcdiag /test:services /test:advertising` OK |
| 07:48 | Uptime Kuma | LDAP + DNS **up** |
| 07:50 | IM | **Update 2**: drives should work again, please sign out and in |
| 07:55 | SD | Desktop PCs OK. **But: 6 laptop users still can't sign in or access drives** |
| 08:02 | TL | On an affected laptop: System log **Event 4, Kerberos, KRB_AP_ERR_SKEW**. `w32tm /stripchart /computer:dc01 /samples:3` → DC01 is **+7 min 12 s** ahead |
| 08:05 | IM | **Update 3**: most users OK, laptop sign-in issue being fixed, workaround: use desktop PCs / M365 in the browser |
| 08:10 | TL | DC01: `w32tm /query /configuration` → NtpServer `10.10.10.254` (old router, gone). `w32tm /query /status` → *Source: Local CMOS Clock* |
| 08:14 | TL | Change (emergency): DC01 (PDC emulator) → external NTP `0.de.pool.ntp.org,1.de.pool.ntp.org` (`w32tm /config ... /reliable:yes`), `w32tm /resync /rediscover` |
| 08:16 | TL | DC01 time correct. Desktop PCs had followed DC01's wrong time and are now 7 min ahead, so they need to resync from DC01 too (restart, or `w32tm /resync` pushed as a quick Intune/GPO script) |
| 08:25 | SD | Laptop users sign in OK; asked all users to restart once |
| 08:30 | IM | **Update 4**: all services restored, please restart once if anything still doesn't work |
| 08:30–08:50 | SD | Callbacks to all 23 ticket owners, linked tickets resolved |
| 08:52 | IM | **All-clear (Update 5)**, monitoring phase until 12:00, PIR scheduled for Wednesday |
| 10:15 | TL | NAS copy of backup data finished; backup target set back to E: after extending E: by 100 GB; manual backup run OK |
| Wed 11-25 | IM + team | Post-incident review → [05-post-incident-review.md](05-post-incident-review.md) |

**Metrics:** time to detect (first alert → human aware) **68 min** · time to declare P1 after first ticket **17 min** · time to restore (declaration → all-clear) **90 min**
