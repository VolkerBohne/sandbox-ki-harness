# R1.5 OpenSpec für beide Agenten

Geplant am 2026-11-12. Branch für die Umsetzung: `step/2026-11-12-openspec-fuer-beide-agenten`.
Anforderungen: OSP-1, OSP-2, OSP-3, OSP-4, OSP-6 (Querschnitt: X-1, X-2, X-3).

## Ziel

Die OpenSpec-CLI ist in gepinnter Version (2.0.0) im Image installiert, sodass sich OpenSpec in jedem Projekt
unter `/work` für Claude Code und opencode einrichten lässt
(`openspec init --tools claude,opencode`). Zusätzlich stehen alle Skills von
OpenSpec beiden Agenten global zur Verfügung, als eingecheckte Kopie unter
`config/skills/openspec-*`. `./sandbox.sh update` erzeugt sie bei jedem Update
neu. Telemetrie und Update-Prüfung von OpenSpec sind abgeschaltet.

## Betroffene Dateien

| Datei | Änderung | Begründung |
|-------|----------|------------|
| `docker/Dockerfile` | `ARG INSTALL_OPENSPEC`, `ARG OPENSPEC_VERSION`, neuer Block nach Claude Code, `ENV` für OSP-4 | OSP-1, OSP-4 |
| `compose.yaml` | Build-Args `INSTALL_OPENSPEC`, `OPENSPEC_VERSION` | OSP-1 |
| `.env.example` | beide Schalter mit Kommentar | X-3 |
| `sandbox.sh` | `update`: Skills neu erzeugen. `doctor`: Zeile für OpenSpec | OSP-3, OSP-6 |
| `sandbox.ps1` | dasselbe wie in `sandbox.sh` | X-2 |
| `config/skills/openspec-*/SKILL.md` | neu, erzeugt mit der CLI, alle zwölf Skills | OSP-3 |
| `config/skills/.openspec-version` | neu, Version der CLI, aus der die Skills stammen | OSP-3, OSP-6 |
| `README.md` | Abschnitt „OpenSpec“: init je Projekt, globale Skills, Update, Telemetrie, Schalter | X-3, OSP-2, OSP-3 |
| `specs/tech-stack.md` | Stand der Zeile OpenSpec von *geplant* auf *eingesetzt*, Einträge in Abschnitt 3 und 9 | tech-stack-Regel |
| `specs/roadmap.md` | R1.5 abhaken | SDD-5 |

Nicht betroffen: `config/commands/`, die `spec-*`-Befehle (OSP-5: OpenSpec
ergänzt sie nur), `config/claude/`, `config/opencode/`.

## Schritte

1. **Dockerfile:**
   - `ARG INSTALL_OPENSPEC=true` und `ARG OPENSPEC_VERSION=2.0.0` neben den
     anderen Schaltern.
   - Direkt nach dem Block für Claude Code ein Block nach demselben Muster:
     Bei `INSTALL_OPENSPEC=true` ohne `INSTALL_NODE=true` bricht der Build mit
     einem Hinweis ab. Danach prüft er die Node-Mindestversion 22.12 mit
     `node -e`, ebenfalls mit Abbruch und Hinweis. Ist `OPENSPEC_VERSION`
     leer, bricht der Build ebenfalls ab, denn die Version muss gepinnt sein.
     Dann folgen `npm install -g "@fission-ai/openspec@${OPENSPEC_VERSION}"`
     und zuletzt `openspec --version`.
   - `ENV OPENSPEC_TELEMETRY=0 DO_NOT_TRACK=1 OPENSPEC_NO_UPDATE_CHECK=1` vor
     dem Installationsblock, damit es auch für Aufrufe beim Build gilt. Fest,
     ohne Schalter (OSP-4).
2. **compose.yaml und `.env.example`:** Die Build-Args `INSTALL_OPENSPEC` und
   `OPENSPEC_VERSION` mit Voreinstellungen `true` und `2.0.0`, in `compose.yaml`
   als `${OPENSPEC_VERSION:-2.0.0}`. Die Version anheben heißt: Wert in
   `.env.example`, `compose.yaml` und Dockerfile ändern, dann
   `./sandbox.sh update`, und die neu erzeugten Skills im selben PR einchecken. In `.env.example`
   stehen sie im Block der Agenten, mit Kommentar.
3. **Skills erzeugen**, als gemeinsame Logik für Ersterzeugung und `update`:
   - Im Container in einem temporären Verzeichnis:
     zuerst die Auswahl auf alle Skills stellen (siehe *Offene Punkte*, Nr. 4),
     dann `openspec init --tools agents --profile custom --no-animation`. Das
     legt nur `.agents/skills/openspec-*` an, erwartet sind zwölf Verzeichnisse. Dazu kommt `openspec --version`.
   - Auf dem Host: Die vorhandenen `config/skills/openspec-*` löschen, die
     neuen Verzeichnisse per `docker compose cp` nach `config/skills/`
     kopieren, Hilfsdateien wie `.openspec-target` auslassen und die Version
     nach `config/skills/.openspec-version` schreiben. Danach das temporäre
     Verzeichnis im Container entfernen.
   - Andere Skills unter `config/skills/` (`plan-item`, `spec-init`, ...)
     bleiben unberührt. Gelöscht wird nur, was mit `openspec-` beginnt.
4. **`update` in beiden Skripten:** Nach `up -d --force-recreate` läuft Schritt 3,
   aber nur, wenn `openspec` im Container vorhanden ist. Sonst erscheint ein
   Hinweis, und die Skills bleiben unverändert. Am Ende zeigt `update`, ob sich
   die Skills geändert haben (`git status --short config/skills`), damit die
   Änderung bewusst committet wird.
5. **Erstbefüllung:** Schritt 3 einmal ausführen, die erzeugten Skills und
   `.openspec-version` einchecken.
6. **`doctor` in beiden Skripten:** Eine Zeile
   `openspec: <CLI-Version> (Skills: <Version aus .openspec-version>)`, als
   `FEHLT`, wenn die CLI fehlt. Weichen die Versionen ab, steht ein Hinweis
   „Skills veraltet, ./sandbox.sh update“ dabei (OSP-6). Die Bewertung mit
   `OK`/`WARN` kommt erst mit R2.2.
7. **README:** Ein Abschnitt „OpenSpec“ beschreibt:
   - die globalen Skills, die ohne `init` bereitstehen,
   - `openspec init --tools claude,opencode` und `openspec update` je Projekt,
   - das Neuerzeugen der Skills über `./sandbox.sh update`,
   - die abgeschaltete Telemetrie,
   - die beiden Schalter.

   Die ausführliche Abgrenzung zu `spec-*` folgt in R1.4 (OSP-5). Hier genügt
   ein Satz.
8. **tech-stack.md** auf den neuen Stand bringen.
9. **Roadmap:** R1.5 abhaken.

## Tests

Prüfschritte aus `specs/validation.md`:

| Prüfung | Was hier konkret geprüft wird |
|---------|-------------------------------|
| V-SPEC-1 bis V-SPEC-5 | IDs, Plan-Kopf, Branch-Name, Haken bei R1.5, Commit-Betreff mit `R1.5` |
| V-SECRET-1, V-SECRET-2 | Keine `.env` und keine Tokens im Diff, keine neuen Ausgaben von Token-Werten |
| V-STAT-1, V-STAT-2 | `bash -n` und shellcheck für `sandbox.sh` |
| V-STAT-3 | `sandbox.ps1` ist parsebar |
| V-STAT-4 | `docker compose config -q` |
| V-STAT-5 | hadolint für das Dockerfile, keine neuen Befunde |
| V-STAT-7 | Frontmatter der erzeugten `SKILL.md` (`name`, `description`) |
| V-PAR-2 | `update` und `doctor` verhalten sich in `sandbox.sh` und `sandbox.ps1` gleich |
| V-PAR-3 | `INSTALL_OPENSPEC` und `OPENSPEC_VERSION` stehen in `.env.example` und im README |
| V-RUN-1 | `./sandbox.sh rebuild` gelingt, `openspec --version` meldet die Version |
| V-RUN-2 | `./sandbox.sh doctor` zeigt die OpenSpec-Zeile mit gleicher CLI- und Skill-Version |
| V-RUN-4 | Die Zeile *Skills* zählt die globalen `openspec-*`-Skills mit (3 + 12) |
| V-RUN-5 | Git, Build und Test in einem Beispielprojekt laufen wie vorher |
| V-AGENT-1, V-AGENT-2 | In einem Projekt **ohne** `openspec init` ist `openspec-explore` in Claude Code und in opencode aufrufbar |

Schrittspezifisch (aus *Fertig, wenn*):

- `./sandbox.sh run env | grep -E 'OPENSPEC_TELEMETRY=0|DO_NOT_TRACK=1|OPENSPEC_NO_UPDATE_CHECK=1'`
  findet alle drei Variablen.
- In `/work/_test-r1.5` legt `openspec init --tools claude,opencode` die Dateien
  `openspec/config.yaml`, `.agents/skills/openspec-*` und `.claude/skills/openspec-*`
  an. `git status` zeigt nur diese Pfade.
- In demselben Projekt nach `init` testen, welche Variante der Skills der Agent
  nimmt, wenn globale und projekteigene `openspec-*`-Skills gleich heißen. Das
  Ergebnis kommt ins README.
- `./sandbox.sh update` erzeugt die Skills neu. Ohne Versionswechsel bleibt
  `git status config/skills` leer. Mit `OPENSPEC_VERSION` auf einer anderen
  Version ändern sich Skills und `.openspec-version`.
- `ls -d config/skills/openspec-*/ | wc -l` ergibt 12, darunter
  `openspec-verify-change` und `openspec-onboard`.
- `INSTALL_OPENSPEC=false`: Build gelingt, `doctor` zeigt `FEHLT`, `update`
  meldet den Hinweis und lässt `config/skills` unverändert.
- `INSTALL_NODE=false` mit `INSTALL_OPENSPEC=true`: Der Build bricht mit
  Hinweis ab.
- Derselbe `update`-Ablauf mit `.\sandbox.ps1 update` unter Windows.

Die Testprojekte werden danach gelöscht. Das Ergebnis kommt als
`## Prüfprotokoll` in den PR.

## Entscheidungen

Beim Replanning am 2026-11-12 geklärt:

1. **Bereitstellung:** CLI im Image **und** globale Kopie der Skills (OSP-2, OSP-3).
2. **Verhältnis zu `spec-*`:** OpenSpec wird parallel angeboten, R1.2 bis R1.4
   bleiben (OSP-5).
3. **Installation:** per npm mit `INSTALL_OPENSPEC` und `OPENSPEC_VERSION` (OSP-1).
4. **Telemetrie:** fest abgeschaltet, dazu die Update-Prüfung (OSP-4).
5. **Aktualisierung der globalen Skills:** über `./sandbox.sh update` bzw.
   `.\sandbox.ps1 update`.

6. **Version:** gepinnt auf `2.0.0`. Angehoben wird bewusst, zusammen mit
   den neu erzeugten Skills im selben PR.
7. **Skills:** Global liegen alle zwölf Skills, die sechs Kern-Skills
   (`explore`, `propose`, `apply-change`, `update-change`, `sync-specs`,
   `archive-change`) und die sechs optionalen (`new-change`, `continue-change`,
   `ff-change`, `verify-change`, `bulk-archive-change`, `onboard`).

## Offene Punkte

1. **Gleichnamige Skills:** Nach `openspec init` gibt es `openspec-*` doppelt,
   global unter `~/.claude/skills` und im Projekt. Welche Variante Claude Code
   und opencode nehmen, ist nicht dokumentiert. Das wird beim Test ermittelt.
   Nimmt ein Agent die globale Variante, obwohl das Projekt eine andere
   OpenSpec-Version nutzt, ist das im README zu beschreiben.
2. **Tool-ID `agents`:** Laut Dokumentation von OpenSpec schreibt
   `--tools agents` nur nach `.agents/skills/`. Das ist bei der Umsetzung als
   Erstes zu prüfen. Klappt es nicht, wird mit `--tools claude` erzeugt und aus
   `.agents/skills/` kopiert.
3. **Egress:** Mit der Allowlist (R6.3) braucht `openspec` keinen eigenen
   Eintrag, solange Telemetrie und Update-Prüfung aus sind. Die Installation
   läuft über npm, das in NET-3 schon enthalten ist. Das ist in R6.2 zu
   bestätigen.
4. **Alle Skills ohne Rückfrage auswählen:** Laut Dokumentation wird die
   Auswahl über `openspec config profile` getroffen und in
   `~/.config/openspec/config.json` gespeichert. Für `custom` ist nicht
   dokumentiert, wie man nicht-interaktiv alle Skills wählt. Bei der Umsetzung
   zuerst klären, z. B. über `openspec config set` oder eine vorbereitete
   `config.json` in einem temporären `XDG_CONFIG_HOME`. Die globale
   Konfiguration von `dev` bleibt dabei unberührt.

## Definition of Done

- Das Image enthält die OpenSpec-CLI in der gepinnten Version 2.0.0. Die Schalter wirken wie beschrieben, und
  bei fehlendem oder zu altem Node bricht der Build mit Hinweis ab.
- `config/skills/openspec-*` mit allen zwölf Skills und
  `config/skills/.openspec-version` sind eingecheckt.
- In einem Projekt ohne `init` sind die globalen Skills in beiden Agenten
  nutzbar. Nach `openspec init --tools claude,opencode` ist OpenSpec im
  Projekt eingerichtet.
- `update` und `doctor` verhalten sich in `sandbox.sh` und `sandbox.ps1` gleich.
- Telemetrie und Update-Prüfung sind im Container aus.
- README und `tech-stack.md` sind aktualisiert, R1.5 ist abgehakt.
- Alle Prüfungen aus *Tests* stehen im Prüfprotokoll des PR.
