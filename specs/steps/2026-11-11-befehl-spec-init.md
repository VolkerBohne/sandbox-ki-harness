# R1.1 Befehl `spec-init`

Geplant am 2026-11-11. Branch für die Umsetzung: `step/2026-11-11-befehl-spec-init`.
Anforderungen: SDD-1, SDD-3, SDD-7, SDD-9 (Querschnitt: X-1).

## Ziel

Es gibt einen geteilten Befehl `/spec-init`, der in einem beliebigen Projekt
die Spec-Dateien `specs/mission.md`, `specs/requirements.md` und
`specs/roadmap.md` anlegt, soweit sie noch fehlen. Vorher stellt er je
anzulegender Datei genau eine Runde gruppierter Rückfragen. Die Dateien
entstehen in der Sprache des Zielprojekts. Der Befehl funktioniert gleich in opencode und Claude
Code und setzt keine bestimmte Sprache und kein bestimmtes Werkzeug voraus.

## Betroffene Dateien

| Datei | Änderung | Begründung |
|-------|----------|------------|
| `config/commands/spec-init.md` | neu | Die eigentliche Anleitung, gemeinsame Quelle für beide Agenten (SDD-1, X-1). |
| `config/skills/spec-init/SKILL.md` | neu | Skill-Hülle nach dem Muster von `config/skills/plan-item/SKILL.md`, verweist auf `/opt/agent-commands/spec-init.md` (SDD-1). |
| `README.md` | Tabelle unter *Geteilte Befehle* erweitern | Nur ein Hinweis, dass `/spec-init` existiert. Der ausführliche Abschnitt folgt in R1.4. |
| `specs/roadmap.md` | R1.1 abhaken | SDD-5, im selben PR. Die Anpassungen an *Anf.* und *Später / ungeplant* sind schon bei der Planung erfolgt. |

Nicht betroffen: `compose.yaml`, `Dockerfile`, `sandbox.sh`, `sandbox.ps1`.
Die Verzeichnisse `config/commands` und `config/skills` sind schon eingehängt,
die neuen Dateien sind nach einem Neustart der CLI sichtbar.

## Schritte

1. **Befehlsdatei anlegen** `config/commands/spec-init.md`:
   - Frontmatter nur mit `description` (README, *Was beim Schreiben eigener
     Befehle zu beachten ist*).
   - Umlaute in der Befehlsdatei und der Skill-Hülle als `ae`/`oe`/`ue`/`ss`,
     wie in den vorhandenen Befehlen.
   - `$ARGUMENTS` optional als Kurzbeschreibung des Projekts.
   - **Schritt 0: Kontext** per Kommandoblock: Verzeichnis, Git-Repository,
     Branch, vorhandene Dateien unter `specs/`.
   - **Vorhandene Specs:** Vorhandene Dateien bleiben unverändert. Der Befehl
     nennt sie, liest sie als Kontext und legt nur die fehlenden an. Fragerunden
     gibt es nur für die fehlenden Dateien. Liegen alle drei vor, meldet er das
     und endet ohne Änderung.
   - **Projekt erkunden** vor den Fragen: README, Build-Dateien (`Makefile`,
     `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml` o. Ä.) lesen,
     damit nur gefragt wird, was sich nicht nachlesen lässt (SDD-7).
   - **Sprache der Specs** (SDD-9) aus README und vorhandener Dokumentation
     ablesen. Ist sie nicht eindeutig, wird das in der ersten Fragerunde
     mitgefragt, nicht in einer eigenen Runde.
   - **Je fehlender Datei genau eine Fragerunde** (SDD-3), jeweils gesammelt in
     einer Nachricht mit nummerierten Fragen, danach auf Antwort warten:
     1. *mission.md:* Zweck, Zielgruppe, Leitprinzipien mit Rangfolge,
        Nicht-Ziele.
     2. *requirements.md:* Themenbereiche, Querschnittsregeln, bekannte
        Anforderungen mit Verbindlichkeit (MUSS/SOLL/KANN).
     3. *roadmap.md:* Phasen, Reihenfolge, erste Schritte und deren
        Akzeptanzkriterien.
   - Jede Datei wird direkt nach ihrer Fragerunde geschrieben, damit die
     Antworten der späteren Runde auf den schon geschriebenen Inhalt aufbauen.
   - **Struktur der Dateien** nach dem Vorbild dieses Repositories:
     - `mission.md`: Zweck, Zielgruppe, Leitprinzipien, Nicht-Ziele,
       Arbeitsweise.
     - `requirements.md`: Regeln zu IDs, Verbindlichkeit, Querschnittsregeln,
       je Bereich eine Tabelle `ID | Anforderung | Stufe`.
     - `roadmap.md`: Phasen mit Checkbox-Schritten `R<phase>.<n>`, je Schritt
       *Anf.*, *Fertig, wenn* und *Prüfen*, am Ende *Später / ungeplant*.
   - **Abschluss:** Liste der angelegten Dateien und Hinweis auf
     `/spec-plan` als nächsten Befehl.
   - **Regeln:** keine Änderungen außerhalb von `specs/`, keine Commits, keine
     Branches. Rückfragen und Zusammenfassung auf Deutsch, die Spec-Dateien
     in der Sprache des Zielprojekts.
2. **Skill-Hülle anlegen** `config/skills/spec-init/SKILL.md`: Frontmatter mit
   `name` und `description`, die erklärt, wann der Skill passt (*neues Projekt
   spec-driven aufsetzen, Specs anlegen*). Der Text verweist auf
   `/opt/agent-commands/spec-init.md` und reicht `$ARGUMENTS` durch.
3. **README** ergänzen: in der Tabelle unter *Geteilte Befehle* bzw. in einem
   Satz darunter `/spec-init` erwähnen.
4. **Prüfungen** laut Abschnitt *Tests* durchführen.
5. **Roadmap**: R1.1 in `specs/roadmap.md` abhaken.

## Tests

Prüfschritte aus `specs/validation.md`:

| Prüfung | Was hier konkret geprüft wird |
|---------|-------------------------------|
| V-SPEC-1 bis V-SPEC-5 | IDs, Plan-Kopf, Branch-Name, Haken in der Roadmap, Commit-Betreff mit `R1.1` |
| V-SECRET-1 | Keine `.env`, keine Tokens im Diff |
| V-STAT-7 | Frontmatter von `spec-init.md` (nur `description`) und `SKILL.md` (`name`, `description`) |
| V-PAR-1 | `spec-init` hat eine Hülle, die auf `/opt/agent-commands/spec-init.md` verweist |
| V-RUN-4 | `./sandbox.sh doctor`: *Befehle (Quelle)*, *→ opencode* und *→ claude* zeigen je eine Datei mehr als vorher (3 statt 2), *Skills* ebenso |
| V-AGENT-1 | `/spec-init` in Claude Code in `/work/_test-r1.1-go` (leeres Go-Projekt mit `go.mod`) |
| V-AGENT-2 | Derselbe Durchlauf in opencode in einem frischen `/work/_test-r1.1-go` |
| V-AGENT-3 | Zusätzlich ein Durchlauf in `/work/_test-r1.1-node` (nur `package.json`): Der Befehl fragt nicht nach Dingen, die in `package.json` stehen, und erwähnt keine Go-Werkzeuge |
| V-AGENT-5 | Nach jedem Durchlauf zeigt `git status --porcelain` nur `specs/mission.md`, `specs/requirements.md` und `specs/roadmap.md` |

Schrittspezifisch (aus *Fertig, wenn*):

- In jedem Durchlauf ohne Specs gibt es **genau drei** Fragerunden, eine je
  Datei. Mehr Rückfragen gelten als fehlgeschlagen.
- Teilweise vorhandene Specs: In einem Testprojekt mit nur `specs/mission.md`
  legt der Befehl die beiden anderen Dateien mit genau zwei Fragerunden an.
  `git diff specs/mission.md` ist danach leer.
- Ein Aufruf, wenn alle drei Dateien vorliegen, ändert nichts und meldet das.
- Sprache: In `/work/_test-r1.1-node` mit englischem README entstehen die Specs
  auf Englisch, in `/work/_test-r1.1-go` mit deutschem README auf Deutsch.
- `grep -nP '[äöüÄÖÜß]' config/commands/spec-init.md config/skills/spec-init/SKILL.md`
  findet nichts.
- Die erzeugte `roadmap.md` enthält mindestens einen Schritt im Format
  `- [ ] **R1.1 …**` mit *Anf.*, *Fertig, wenn* und *Prüfen*, sodass
  `/spec-plan` (R1.2) daran ansetzen kann.

Die Testprojekte werden danach gelöscht. Das Ergebnis kommt als
`## Prüfprotokoll` in den PR (validation.md, Abschnitt 10).

## Entscheidungen

Bei der Planung geklärt:

1. **Vorhandene Specs:** Nur fehlende Dateien werden angelegt, vorhandene
   bleiben unverändert.
2. **`validation.md` im Zielprojekt:** nicht in R1.1. Steht in `roadmap.md`
   unter *Später / ungeplant*.
3. **Umlaute:** Befehlsdateien und Skill-Hüllen bleiben bei `ae`/`oe`/`ue`.
4. **Sprache der erzeugten Specs:** die des Zielprojekts, festgehalten als
   SDD-9 in `requirements.md`.

## Offene Punkte

Keine.

## Definition of Done

- `config/commands/spec-init.md` und `config/skills/spec-init/SKILL.md` liegen
  vor und folgen dem Muster von `plan-item`.
- In beiden Agenten legt `/spec-init` in einem leeren Testprojekt die drei
  Spec-Dateien an, mit genau einer Fragerunde je Datei und in der Sprache des
  Projekts. Vorhandene Spec-Dateien bleiben unverändert.
- `doctor` zählt einen Befehl und einen Skill mehr.
- Alle Prüfungen aus *Tests* sind im Prüfprotokoll des PR als *bestanden*
  oder begründet als *nicht ausgeführt* eingetragen.
- R1.1 ist in `specs/roadmap.md` abgehakt, der PR nennt R1.1 und die
  Anforderungen SDD-1, SDD-3, SDD-7 und SDD-9.
