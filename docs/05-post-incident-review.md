# 5 – Post-incident review (blameless)

**Incident:** MI-2026-001 · **Review date:** 2026-11-25 · **Participants:** IT lead, service desk (2), system admin, managing director (first 15 min)
**Principle:** we look for gaps in **processes and systems**, not for people to blame. The colleague who changed the backup target acted in good faith to keep backups running.

## Root cause analysis: 5 whys

### Cause 1: DC01 system drive full
1. **Why did shares and logons fail?** AD DS and DNS on DC01 stopped working correctly.
2. **Why?** The C: drive had no free space left.
3. **Why?** Windows Server Backup wrote 41 GB to `C:\Backup`.
4. **Why?** On Thursday the backup target was changed from E: (full) to C: as a temporary workaround.
5. **Why wasn't that caught?** The change had no ticket/change record and no review, and **free disk space wasn't monitored**. Nobody owned "backup disk is getting full" either.

**Root cause:** no change process for "small" infrastructure changes + no capacity monitoring.

### Cause 2: Kerberos clock skew
1. **Why couldn't laptops sign in after the fix?** Kerberos rejected them (KRB_AP_ERR_SKEW).
2. **Why?** DC01's clock was 7 min ahead; the limit is 5 min.
3. **Why?** DC01 had no working time source and ran on its own clock.
4. **Why?** Its NTP server was the old router, decommissioned in October.
5. **Why wasn't that caught?** The router replacement checklist didn't include "services provided by the old device", and time offset wasn't monitored.

**Root cause:** incomplete decommissioning process + no time monitoring.

### Contributing factor: slow detection
Alerts went out at 06:10 by **e-mail only** to a shared mailbox nobody reads before 07:00. Users found the problem before IT did.

## What went well
- Pattern recognised and P1 declared **17 minutes** after the first ticket
- Clear roles: incident manager vs. technical lead; the TL could work without interruptions
- Regular updates, and updating the phone message reduced calls noticeably
- The backup data was **kept** (copied to NAS) instead of deleted under pressure
- M365 being independent of DC01 meant e-mail and Teams worked: communication was possible

## What went badly
- 68 minutes from first alert to a human noticing
- Second cause found only by users reporting; the "fixed" message at 07:50 was premature for laptop users
- Print server and file server on the DC = single point of failure for the warehouse

## Action plan (CAPA)
| # | Action | Type | Owner | Due | Status |
|---|---|---|---|---|---|
| 1 | Disk space monitor on DC01 (warn < 15 %, critical < 5 %), e.g. Uptime Kuma push from a scheduled PowerShell check / Checkmk agent | Detect | Sysadmin | 2026-11-27 | ☐ |
| 2 | Critical alerts to Teams channel + SMS/push to on-call phone, not e-mail only | Detect | IT lead | 2026-11-30 | ☐ |
| 3 | Time offset monitor (`w32tm /stripchart` against pool.ntp.org, alert > 60 s) | Detect | Sysadmin | 2026-11-27 | ☐ |
| 4 | Lightweight change process: every infrastructure change needs a Zammad change ticket (what, why, rollback, until when) | Prevent | IT lead | 2026-12-04 | ☐ |
| 5 | Backup disk E: extended + capacity check in the weekly report; backup target change is now a change ticket | Prevent | Sysadmin | ✅ 2026-11-23 | ✅ |
| 6 | PDC emulator syncs from external NTP (done), documented in the AD runbook | Prevent | Sysadmin | ✅ 2026-11-23 | ✅ |
| 7 | Decommissioning checklist: "Which services does this device provide? (DHCP, DNS, NTP, SNMP, syslog…)" | Prevent | IT lead | 2026-12-04 | ☐ |
| 8 | Second DC (DC02) for AD/DNS redundancy; move print server off the DC | Resilience | IT lead (budget) | Q1 2027 | ☐ |
| 9 | Service desk: major incident checklist + status update templates in Zammad (done) | Respond | Service desk | ✅ 2026-11-25 | ✅ |

## Lessons for my own practice
- Monitoring is only as good as the alert path: an alert nobody reads = no alert
- After fixing a major incident, **actively test with different user groups** (desktop, laptop, remote) before announcing "fixed"
- Write updates you'd want to receive: what does it mean for me, what should I do, when will I hear more
