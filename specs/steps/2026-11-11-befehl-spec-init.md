# R1.1 Befehl `spec-init`

Geplant am 2026-11-11. Branch für die Umsetzung: `step/2026-11-11-befehl-spec-init`.
Anforderungen: SDD-1, SDD-3, SDD-7 (Querschnitt: X-1).

## Ziel

Es gibt einen geteilten Befehl `/spec-init`, der in einem beliebigen Projekt
die Spec-Dateien `specs/mission.md`, `specs/requirements.md` und
`specs/roadmap.md` anlegt. Vorher stellt er je Datei genau eine Runde
gruppierter Rückfragen. Der Befehl funktioniert gleich in opencode und Claude
Code und setzt keine bestimmte Sprache und kein bestimmtes Werkzeug voraus.

## Betroffene Dateien

| Datei | Änderung | Begründung |
|-------|----------|------------|
| `config/commands/spec-init.md` | neu | Die eigentliche Anleitung, gemeinsame Quelle für beide Agenten (SDD-1, X-1). |
| `config/skills/spec-init/SKILL.md` | neu | Skill-Hülle nach dem Muster von `config/skills/plan-item/SKILL.md`, verweist auf `/opt/agent-commands/spec-init.md` (SDD-1). |
| `README.md` | Tabelle unter *Geteilte Befehle* erweitern | Nur ein Hinweis, dass `/spec-init` existiert. Der ausführliche Abschnitt folgt in R1.4. |
| `specs/roadmap.md` | R1.1 abhaken | SDD-5, im selben PR. |

Nicht betroffen: `compose.yaml`, `Dockerfile`, `sandbox.sh`, `sandbox.ps1`.
Die Verzeichnisse `config/commands` und `config/skills` sind schon eingehängt,
die neuen Dateien sind nach einem Neustart der CLI sichtbar.

## Schritte

1. **Befehlsdatei anlegen** `config/commands/spec-init.md`:
   - Frontmatter nur mit `description` (README, *Was beim Schreiben eigener
     Befehle zu beachten ist*).
   - `$ARGUMENTS` optional als Kurzbeschreibung des Projekts.
   - **Schritt 0: Kontext** per Kommandoblock: Verzeichnis, Git-Repository,
     Branch, vorhandene Dateien unter `specs/`.
   - **Vorhandene Specs:** Liegt schon eine der drei Dateien vor, nennt der
     Befehl sie und bricht ab, ohne etwas zu überschreiben (siehe *Offene
     Punkte*).
   - **Projekt erkunden** vor den Fragen: README, Build-Dateien (`Makefile`,
     `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml` o. Ä.) lesen,
     damit nur gefragt wird, was sich nicht nachlesen lässt (SDD-7).
   - **Drei Fragerunden, je Datei genau eine** (SDD-3), jeweils gesammelt in
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
     Branches, Antwortsprache Deutsch.
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

- In jedem Durchlauf gibt es **genau drei** Fragerunden, eine je Datei. Mehr
  Rückfragen gelten als fehlgeschlagen.
- Ein zweiter Aufruf in einem Projekt, in dem `specs/` schon gefüllt ist,
  überschreibt nichts und nennt die vorhandenen Dateien.
- Die erzeugte `roadmap.md` enthält mindestens einen Schritt im Format
  `- [ ] **R1.1 …**` mit *Anf.*, *Fertig, wenn* und *Prüfen*, sodass
  `/spec-plan` (R1.2) daran ansetzen kann.

Die Testprojekte werden danach gelöscht. Das Ergebnis kommt als
`## Prüfprotokoll` in den PR (validation.md, Abschnitt 10).

## Offene Punkte

1. **Vorhandene Specs:** Geplant ist Abbruch ohne Überschreiben. Alternative
   wäre, nur fehlende Dateien anzulegen. Das ist im Review zu entscheiden.
2. **`validation.md` im Zielprojekt:** SDD-8 macht die Datei optional.
   Soll `spec-init` eine vierte Fragerunde für `validation.md` anbieten? Das
   würde SDD-3 (*eine Runde je Datei*, drei Dateien) erweitern und bräuchte
   zuerst eine Anpassung von SDD-3. Vorschlag: in R1.1 nicht, als Idee unter
   *Später / ungeplant* aufnehmen.
3. **Umlaute:** Die vorhandenen Befehlsdateien schreiben `ae`/`oe`/`ue`, die
   Specs echte Umlaute. Beide Agenten verarbeiten UTF-8. Vorschlag: neue
   Befehle mit Umlauten schreiben, die alten bleiben unverändert.
4. **Sprache der erzeugten Specs:** Der Befehl antwortet auf Deutsch. Ob die
   erzeugten Dateien in der Sprache des Zielprojekts geschrieben werden
   sollen, regeln die Anforderungen bisher nicht.

## Definition of Done

- `config/commands/spec-init.md` und `config/skills/spec-init/SKILL.md` liegen
  vor und folgen dem Muster von `plan-item`.
- In beiden Agenten legt `/spec-init` in einem leeren Testprojekt die drei
  Spec-Dateien an, mit genau einer Fragerunde je Datei.
- `doctor` zählt einen Befehl und einen Skill mehr.
- Alle Prüfungen aus *Tests* sind im Prüfprotokoll des PR als *bestanden*
  oder begründet als *nicht ausgeführt* eingetragen.
- R1.1 ist in `specs/roadmap.md` abgehakt, der PR nennt R1.1 und die
  Anforderungen SDD-1, SDD-3 und SDD-7.
