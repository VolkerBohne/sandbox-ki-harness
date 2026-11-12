# Validierung

Diese Datei beschreibt, **wie** geprüft wird. `requirements.md` legt fest, was
gelten muss, und `roadmap.md` nennt je Schritt, was als fertig gilt. Hier
stehen die wiederverwendbaren Prüfschritte, auf die Schrittpläne und Pull
Requests verweisen.

Jeder Prüfschritt hat eine feste ID (`V-…`). Für die IDs gelten dieselben
Regeln wie in `requirements.md`: Sie bleiben erhalten, wenn sich ein Schritt
ändert. Fällt ein Schritt weg, wird er als *entfallen* markiert.

Spalte **Ort**: *Host* heißt auf dem Rechner mit Docker (`./sandbox.sh …`),
*Container* heißt in der Sandbox (`./sandbox.sh shell`), *beide* heißt, dass es
an beiden Orten geht.

---

## 1. Ablauf

1. **Planen** (`spec-plan`): Der Schrittplan wählt im Abschnitt *Tests* die
   passenden Prüfschritte aus dieser Datei aus. Die Zuordnung in Abschnitt 9
   liefert die Pflichtprüfungen, dazu kommen die Prüfungen aus *Fertig, wenn*
   und *Prüfen* des Roadmap-Schritts. Prüfungen, die nur für diesen Schritt
   gelten, stehen ausformuliert im Plan, ohne eigene ID.
2. **Umsetzen** (`spec-implement`): Alle im Plan genannten Prüfungen werden
   ausgeführt, bevor der PR geöffnet wird.
3. **Nachweisen:** Der PR-Text enthält ein Prüfprotokoll (Abschnitt 10).
4. **Reviewen:** Im Review werden die Prüfungen mit Ort *Host* stichprobenartig
   nachvollzogen, besonders Negativproben.

Grundregeln:

- Eine Prüfung, die nicht laufen konnte, wird als **nicht ausgeführt** mit
  Grund eingetragen und nie als bestanden. Typischer Fall: Windows ist nicht
  verfügbar, dann ist V-PAR-2 im Review nachzuholen.
- Schlägt eine Prüfung fehl, wird der Fehler behoben oder die Abweichung
  ausdrücklich im PR benannt (SDD-6). Stillschweigend übergangen wird nichts.
- Sicherheitsprüfungen brauchen immer auch eine **Negativprobe** (V-NEG). Ein
  `OK` gilt erst dann als belastbar, wenn der Fehlerfall nachweislich zu
  `WARN` oder `FAIL` führt.

## 2. Spec-Konsistenz (V-SPEC)

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-SPEC-1 | Jede in `roadmap.md` und im Schrittplan genannte Anforderungs-ID existiert in `requirements.md`. | `grep -ohE '\b(SDD\|HARD\|SEC\|PERM\|NET\|DOC\|OSP\|X)-[0-9]+\b' specs/roadmap.md specs/steps/*.md \| sort -u`, die Liste mit den in `requirements.md` definierten IDs abgleichen (`comm -23`) | Keine unbekannte ID | beide |
| V-SPEC-2 | Die erste Zeile des Schrittplans nennt die Roadmap-ID. | `head -1 specs/steps/<datei>.md` | Enthält z. B. `R1.1` | beide |
| V-SPEC-3 | Der Branch heißt wie die Datei des Schrittplans. | `git rev-parse --abbrev-ref HEAD` mit `step/<dateiname ohne .md>` vergleichen | Gleich (SDD-5) | beide |
| V-SPEC-4 | Der Schritt ist im selben PR in `roadmap.md` abgehakt, und sonst wurde dort nichts geändert. | `git diff main -- specs/roadmap.md` | Genau ein `[ ]` → `[x]` für diesen Schritt | beide |
| V-SPEC-5 | Commits nennen die Roadmap-ID. | `git log main..HEAD --format=%s` | Jede Betreffzeile enthält die ID | beide |
| V-SPEC-6 | Ändert sich eine Anforderung, ist zuerst die Spec angepasst (mission.md, *Arbeitsweise*). | Diff des PR durchsehen | Spec-Änderung liegt im selben oder einem früheren PR | beide |

## 3. Statische Prüfungen (V-STAT)

Werkzeuge, die fehlen, werden als *nicht ausgeführt* eingetragen (Abschnitt 1).

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-STAT-1 | Shell-Skripte sind syntaktisch korrekt. | `bash -n sandbox.sh docker/entrypoint.sh` und weitere geänderte `.sh` | Keine Ausgabe, Exit 0 | beide |
| V-STAT-2 | Shell-Skripte bestehen shellcheck. | `shellcheck sandbox.sh docker/*.sh docker/sandbox-doctor` | Keine neuen Befunde gegenüber `main` | beide |
| V-STAT-3 | PowerShell-Skript ist parsebar. | `pwsh -NoProfile -Command "[System.Management.Automation.Language.Parser]::ParseFile('sandbox.ps1',[ref]\$null,[ref]\$e); \$e"` | Keine Fehler | Host |
| V-STAT-4 | Compose-Datei ist gültig. | `docker compose config -q` | Exit 0 | Host |
| V-STAT-5 | Dockerfile besteht hadolint. | `hadolint docker/Dockerfile` | Keine neuen Befunde gegenüber `main` | Host |
| V-STAT-6 | JSON-Konfiguration ist gültig. | `jq empty config/claude/settings.json config/opencode/*.json` | Exit 0 | beide |
| V-STAT-7 | Befehls- und Skill-Dateien haben gültigen Frontmatter. | Kopf jeder geänderten Datei unter `config/commands/` und `config/skills/` ansehen | `---`-Block mit `description` bzw. `name` und `description` | beide |

## 4. Gleichstand (V-PAR)

Prüft die Querschnittsregeln X-1 bis X-3.

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-PAR-1 | **Agenten (X-1):** Jeder Befehl unter `config/commands/` hat eine Skill-Hülle, und jede Hülle verweist auf `/opt/agent-commands/<name>.md`. | `for f in config/commands/*.md; do n=$(basename "$f" .md); grep -q "/opt/agent-commands/$n.md" "config/skills/$n/SKILL.md" \|\| echo "fehlt: $n"; done` | Keine Ausgabe | beide |
| V-PAR-2 | **Plattformen (X-2):** Jeder geänderte oder neue Unterbefehl von `sandbox.sh` existiert in `sandbox.ps1` und verhält sich gleich. | `./sandbox.sh help` und `.\sandbox.ps1 help` vergleichen, den geänderten Unterbefehl auf beiden Wegen ausführen | Gleiche Befehlsliste, gleiche Wirkung | Host |
| V-PAR-3 | **Dokumentation (X-3):** Jeder neue `.env`-Schalter steht in `.env.example` und im README, mit sicherer Voreinstellung. | `git diff main` nach neuen Variablen durchsuchen, dann `grep -n <VAR> .env.example README.md` | Je ein Treffer, Voreinstellung ist die strengere Variante | beide |
| V-PAR-4 | Regeln, die beide Agenten betreffen (z. B. Berechtigungen), sind in beiden Konfigurationen inhaltlich gleich. | `config/claude/settings.json` und `config/opencode/opencode.json` gegen die Quelle (z. B. `config/permissions.md`) abgleichen | Keine Abweichung | beide |

## 5. Laufzeit (V-RUN)

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-RUN-1 | Image baut, Container startet. | `./sandbox.sh rebuild` | Exit 0, `./sandbox.sh status` zeigt den Container als laufend | Host |
| V-RUN-2 | `doctor` läuft durch. | `./sandbox.sh doctor; echo $?` | Ab R2.2: kein `FAIL`, Exit 0. Vorher: keine Zeile mit `FEHLT` für aktivierte Werkzeuge | Host |
| V-RUN-3 | Sicherheitsgruppe läuft durch. | `./sandbox.sh doctor --security; echo $?` (ab R2.3) | Alle Zeilen `OK`, Exit 0 | Host |
| V-RUN-4 | Geteilte Befehle sind in beiden Agenten sichtbar. | `doctor`, Zeilen *Befehle (Quelle)*, *→ opencode*, *→ claude*, *Skills* | Alle drei Befehlszahlen gleich, Skills ≥ Befehle | Host |
| V-RUN-5 | Grundfunktionen gehen weiterhin: Git, Build und Test in einem Projekt unter `/work`. | In einem Beispielprojekt `git status`, Build- und Testbefehl des Projekts | Wie vor der Änderung | Container |
| V-RUN-6 | Neustart ohne Rebuild übernimmt Konfigurationsänderungen, wo das zugesagt ist (z. B. NET-6). | Datei ändern, `./sandbox.sh restart`, Wirkung prüfen | Änderung wirkt | Host |

## 6. Agenten-Durchlauf (V-AGENT)

Gilt für jede Änderung an Befehlen, Skills oder Agenten-Konfiguration.

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-AGENT-1 | Der Befehl läuft in **Claude Code**. | `./sandbox.sh claude`, in einem Testprojekt unter `/work` den Befehl aufrufen | Verhalten wie im Befehl beschrieben | Container |
| V-AGENT-2 | Der Befehl läuft in **opencode**. | `./sandbox.sh opencode`, gleicher Aufruf im gleichen Ausgangszustand | Gleiches Verhalten wie in V-AGENT-1 | Container |
| V-AGENT-3 | Der Befehl ist sprachneutral (SDD-7). | Durchlauf in einem Testprojekt mit anderer Sprache bzw. anderem Build-Werkzeug als dieses Repository, z. B. ein Go- und ein Node-Projekt | Build- und Testbefehle werden aus dem Projekt gelesen, nicht angenommen | Container |
| V-AGENT-4 | Fehlende Voraussetzungen führen zum Abbruch mit Hinweis (z. B. SDD-2). | Durchlauf in einem Projekt ohne `specs/` | Klarer Hinweis, keine Dateien angelegt | Container |
| V-AGENT-5 | Ein reiner Planungsbefehl ändert keinen Code. | Nach dem Durchlauf `git status --porcelain` | Nur die erwartete neue Datei | Container |

Testprojekte entstehen frisch unter `/work/_test-<schritt>` und werden nach der
Prüfung wieder gelöscht. Sie gelangen nie ins Repository.

## 7. Negativproben (V-NEG)

Für jede Sicherheitszusage wird gezeigt, dass ihr Bruch auffällt. Die Probe
wird anschließend zurückgenommen, und V-RUN-3 muss wieder `OK` ergeben.

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-NEG-1 | Ein gezielt herbeigeführter Fehlzustand wird von `doctor` erkannt. | Den im Schrittplan genannten Zustand herstellen, z. B. Port auf `0.0.0.0`, `ENABLE_SUDO=true`, `deny`-Eintrag entfernen | `WARN` bzw. `FAIL` laut Anforderung, bei `FAIL` Exit ≠ 0 | Host |
| V-NEG-2 | Verbotene Aktionen scheitern im Container. | Die im Schritt genannte Aktion ausführen, z. B. `touch /usr/local/x`, Schreiben auf Agenten-Konfiguration, `curl https://example.com` | Fehler, keine Wirkung | Container |
| V-NEG-3 | Verbotene Aktionen werden von **beiden** Agenten abgelehnt bzw. erfragt. | Dieselbe Probe in Claude Code und in opencode | Gleiches Verhalten (ablehnen bzw. nachfragen) | Container |

## 8. Secrets (V-SECRET)

Gilt für jede Änderung an Skripten, Ausgaben oder Compose-Konfiguration.

| ID | Prüfung | Wie | Erwartung | Ort |
|----|---------|-----|-----------|-----|
| V-SECRET-1 | Keine `.env` und keine Tokens im Commit. | `git diff main --name-only \| grep -E '(^\|/)\.env$'` und `git diff main \| grep -nEi '(ghp_\|glpat-\|sk-ant-)'` | Keine Treffer | beide |
| V-SECRET-2 | Kein Skript gibt Token-Werte aus (SEC-4). | `grep -nE 'echo.*\$\{?[A-Z_]*(TOKEN\|KEY)' sandbox.sh sandbox.ps1 docker/*` und Treffer prüfen | Nur Ausgaben wie *gesetzt*/*fehlt* | beide |
| V-SECRET-3 | Ausgaben von `doctor` und `status` enthalten keine Token-Werte. | Ausgabe mit gesetzten Test-Tokens nach deren Wert durchsuchen | Kein Treffer | Host |

## 9. Pflichtprüfungen je Art der Änderung

| Art der Änderung | Pflichtprüfungen |
|------------------|------------------|
| Jeder Schritt | V-SPEC-1 bis V-SPEC-5, V-SECRET-1 |
| Nur Specs oder README | V-SPEC-6 |
| Befehl oder Skill unter `config/commands/`, `config/skills/` | V-STAT-7, V-PAR-1, V-RUN-4, V-AGENT-1, V-AGENT-2, dazu V-AGENT-3 bis -5 je nach Befehl |
| `sandbox.sh` / `sandbox.ps1` | V-STAT-1 bis V-STAT-3, V-PAR-2, V-SECRET-2, V-SECRET-3 |
| `docker/Dockerfile`, `docker/entrypoint.sh`, `compose.yaml` | V-STAT-1, V-STAT-2, V-STAT-4, V-STAT-5, V-RUN-1, V-RUN-2, V-RUN-5 |
| Agenten-Konfiguration (`config/claude`, `config/opencode`) | V-STAT-6, V-PAR-4, V-AGENT-1, V-AGENT-2 |
| Neuer `.env`-Schalter | V-PAR-3 |
| Sicherheitsanforderung (HARD, SEC, PERM, NET) | V-RUN-3, V-NEG-1, V-NEG-2, bei Agenten-Regeln V-NEG-3 (DOC-6) |
| `doctor` | V-RUN-2, V-RUN-3, V-NEG-1 |

## 10. Prüfprotokoll im PR

Der PR-Text enthält einen Abschnitt `## Prüfprotokoll` mit einer Zeile je
Prüfung aus dem Schrittplan:

```markdown
## Prüfprotokoll

| Prüfung | Ergebnis | Hinweis |
|---------|----------|---------|
| V-SPEC-1 | bestanden | |
| V-PAR-2 | nicht ausgeführt | kein Windows verfügbar, im Review nachholen |
| V-NEG-1 | bestanden | Port auf 0.0.0.0 → WARN |
| Schrittspezifisch: `git status` zeigt nur `specs/steps/…` | bestanden | |
```

Mögliche Ergebnisse: **bestanden**, **fehlgeschlagen** (mit Begründung, warum
der PR trotzdem geöffnet wird), **nicht ausgeführt** (mit Grund).
