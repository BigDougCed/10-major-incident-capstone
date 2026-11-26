# 1 – Scenario & impact

## Background (what happened before Monday)
| When | What | Nobody noticed because… |
|---|---|---|
| Mid-October | The old router (10.10.10.254), which also served as **NTP time source** for DC01, was replaced. DC01 kept pointing to the old IP. | `w32tm` only logs warnings in the System log; nothing monitored time |
| October–November | Without a time source, the DC01 VM clock drifted ~1–2 minutes per week | Clients sync their time **from** the DC, so they drifted along. No errors |
| Thursday 2026-11-19 | Backup disk E: on DC01 was full. A colleague changed the Windows Server Backup target to `C:\Backup` "for a few days" to keep backups running | Change was done without a ticket or a change record |
| Weekend | DC01 clock passed **+5 minutes** compared to real time | Nobody worked |

## Monday 2026-11-23
| Time | What users saw |
|---|---|
| ~02:07 | Nightly backup starts writing ~40 GB to `C:\Backup` |
| ~03:40 | C: is full. AD DS can't write to its database log, DNS stops answering reliably |
| 06:10 | Uptime Kuma e-mails "LDAP 10.10.10.10:389 DOWN" and "AD DNS DOWN" to `it-alerts@`. No one is on duty yet |
| 07:00 | Warehouse starts. PCs that ran over the weekend log on with **cached credentials**, but drives S:/W: don't connect |
| 07:05 | First ticket: „Laufwerk W: geht nicht" |
| 07:10–07:20 | Office staff arrive with laptops: some see *"There are currently no logon servers available"*, others log on but have no drives or printers |
| Unaffected | Outlook, Teams, OneDrive: they're in Microsoft 365 and don't depend on DC01 |

## Business impact
- Warehouse couldn't print delivery notes (print server on DC01) → first trucks left ~45 minutes late
- Accounting couldn't open the month-end files on A:
- 23 tickets and many phone calls in 40 minutes. The service desk itself was overloaded

## Why it's a P1
Majority of users (19/25), several business-critical processes, no workaround for shares and printing → **impact: company, urgency: high** → P1 ([priority matrix](https://github.com/BigDougCed/06-helpdesk-ticketing-zammad/blob/main/docs/03-sla-escalation.md)).
