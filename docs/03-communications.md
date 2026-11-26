# 3 – Communications

Rules I followed:
- **One channel, one voice:** updates only from the incident manager, published on status page + Teams channel *Alle* + e-mail (e-mail and Teams were unaffected)
- **Plain language:** what's affected, what to do, when the next update comes; no jargon like "NTDS" or "Kerberos"
- **Fixed rhythm:** every 30 minutes at the latest, even if nothing changed
- German first (company language), English below for international colleagues

---

### Update 1 – 07:25
**DE:** **[Störung] Netzlaufwerke und Drucker nicht verfügbar – Update 1 (07:25)**
Seit heute früh sind die Netzlaufwerke (S:, A:, W:, P:) und die Netzwerkdrucker nicht erreichbar. Teilweise ist auch keine Anmeldung am PC möglich. **E-Mail, Teams und OneDrive funktionieren normal.** Die IT arbeitet mit Hochdruck an der Lösung. Bitte **keine zusätzlichen Tickets** zu dieser Störung erstellen. Nächstes Update: spätestens 07:55 Uhr.

**EN:** **[Incident] Network drives and printers unavailable – update 1 (07:25)**
Since early this morning the network drives (S:, A:, W:, P:) and network printers are unavailable; some users can't sign in to their PC. **E-mail, Teams and OneDrive work normally.** IT is working on it. Please **don't open additional tickets** for this issue. Next update by 07:55 at the latest.

---

### Update 2 – 07:50
**DE:** **Update 2 (07:50): Ursache gefunden, Laufwerke wieder verfügbar.** Ein Server hatte keinen freien Speicherplatz mehr. Das ist behoben. Bitte **melden Sie sich einmal ab und wieder an**, dann sind Laufwerke und Drucker wieder da. Wir beobachten die Lage weiter. Nächstes Update: 08:20 Uhr.

**EN:** **Update 2 (07:50): cause found, drives available again.** A server had run out of disk space; this has been fixed. Please **sign out and back in once** to reconnect drives and printers. We're monitoring. Next update: 08:20.

---

### Update 3 – 08:05
**DE:** **Update 3 (08:05): Die meisten Arbeitsplätze funktionieren wieder.** Bei einigen **Laptops** ist die Anmeldung noch gestört. Wir haben eine zweite Ursache gefunden und beheben sie gerade. Bis dahin: Bitte nutzen Sie, wenn möglich, einen freien Desktop-PC oder arbeiten Sie im Browser mit **office.com**. Nächstes Update: spätestens 08:35 Uhr.

**EN:** **Update 3 (08:05): most workstations are working again.** Sign-in still fails on some **laptops**; we found a second cause and are fixing it. Until then, please use a free desktop PC if possible, or work in the browser at **office.com**. Next update by 08:35.

---

### Update 4 – 08:30
**DE:** **Update 4 (08:30): Alle Dienste sind wieder verfügbar.** Falls bei Ihnen noch etwas nicht funktioniert, **starten Sie Ihren PC bitte einmal neu**. Danach gerne ein Ticket, dann melden wir uns sofort.

**EN:** **Update 4 (08:30): all services restored.** If something still doesn't work for you, please **restart your PC once**. After that, open a ticket and we'll call you right away.

---

### Update 5 – 08:52 (all-clear)
**DE:** **[Behoben] Störung Netzlaufwerke und Anmeldung (07:05–08:52).** Die Störung ist vollständig behoben. Ursache war ein voller Datenträger auf einem zentralen Server und zusätzlich eine falsche Uhrzeit, die die Anmeldung an Laptops verhindert hat. Wir analysieren den Vorfall in dieser Woche und setzen Maßnahmen um, damit er sich nicht wiederholt. Vielen Dank für Ihre Geduld!

**EN:** **[Resolved] Network drives and sign-in (07:05–08:52).** The issue is fully resolved. It was caused by a full disk on a central server and, in addition, an incorrect clock that blocked laptop sign-ins. We'll review the incident this week and put measures in place so it doesn't happen again. Thank you for your patience!

---

## Management briefing (07:38, by phone, then summary by e-mail at 09:15)
> **Betreff: Zusammenfassung IT-Störung heute 07:05–08:52**
> - **Was:** Netzlaufwerke, Netzwerkdrucker und teilweise die PC-Anmeldung waren nicht verfügbar; E-Mail/Teams liefen normal.
> - **Auswirkung:** 19 von 25 Mitarbeitenden; Lager mit ca. 45 Min. Verzögerung beim Lieferscheindruck.
> - **Ursachen:** (1) Systemplatte des zentralen Servers voll, weil die Datensicherung vorübergehend auf das falsche Laufwerk umgestellt war; (2) falsche Serveruhrzeit wegen einer veralteten Zeitquelle.
> - **Status:** vollständig behoben, keine Daten verloren.
> - **Nächste Schritte:** Auswertung am Mittwoch, Maßnahmenplan bis Freitag (u. a. Speicherplatz-Überwachung, Alarm per Teams/SMS, Änderungen nur noch mit Ticket).
