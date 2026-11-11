# Anforderungen

Jede Anforderung hat eine feste ID. Roadmap, Commits und Pull Requests
verweisen auf diese IDs. Wird eine Anforderung geändert, bleibt ihre ID
erhalten. Fällt sie weg, wird sie als *entfallen* markiert und nicht gelöscht.

Verbindlichkeit: **MUSS**, **SOLL**, **KANN**.

Für **alle** Anforderungen gelten drei Querschnittsregeln:

- **X-1 Gleichstand der Agenten:** Was für einen Agenten gilt, gilt auch für
  den anderen. Die Quelle liegt einmal unter `config/`.
- **X-2 Gleichstand der Plattformen:** Jede Änderung an `sandbox.sh` hat ihr
  Gegenstück in `sandbox.ps1`.
- **X-3 Dokumentation:** Jeder neue `.env`-Schalter steht in `.env.example`
  und im README, mit sicherer Voreinstellung.

---

## 1. Spec-Driven-Workflow (SDD)

Ausgangslage: `/plan-item` und `/implement-item` arbeiten auf GitHub-Issues.
Für die Weiterentwicklung dieses und anderer Projekte entsteht zusätzlich ein
Weg, der von Spec-Dateien im Repository ausgeht.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| SDD-1 | Die SDD-Befehle liegen als geteilte Befehle unter `config/commands/` und haben je eine Skill-Hülle unter `config/skills/`, nach demselben Muster wie `plan-item`. | MUSS |
| SDD-2 | Die Befehle setzen voraus, dass im Zielprojekt `specs/mission.md`, `specs/requirements.md` und `specs/roadmap.md` liegen. Fehlen sie, weisen die Befehle darauf hin und brechen ab. | MUSS |
| SDD-3 | Ein Befehl zum **Anlegen** erzeugt die drei Spec-Dateien für ein Projekt. Vorher stellt er gruppierte Rückfragen, eine Runde je Datei. | MUSS |
| SDD-4 | Ein Befehl zum **Planen** wählt den nächsten offenen Roadmap-Schritt oder einen per ID angegebenen und schreibt dazu einen Schrittplan nach `specs/steps/YYYY-MM-DD-<slug>.md`, mit dem Datum der Planung und einem Slug aus dem Titel des Schritts. Die erste Zeile des Plans nennt die Roadmap-ID, daran wird er wiedergefunden. Die Abschnitte entsprechen denen von `plan-item`: Ziel, Betroffene Dateien, Schritte, Tests, Offene Punkte, Definition of Done. Code wird dabei nicht geändert. | MUSS |
| SDD-5 | Ein Befehl zum **Umsetzen** arbeitet einen Schrittplan ab: Er legt einen Branch `step/YYYY-MM-DD-<slug>` an, der genauso heißt wie die Datei des Schrittplans (ohne `.md`). Er nennt die Roadmap-ID im Commit und öffnet einen Pull Request. Im selben PR hakt er den Schritt in `roadmap.md` ab. | MUSS |
| SDD-6 | Die Befehle prüfen, dass Plan und Umsetzung die referenzierten Anforderungs-IDs erfüllen, und nennen Abweichungen ausdrücklich. | SOLL |
| SDD-7 | Die Befehle sind sprachneutral gegenüber dem Zielprojekt. Sie lesen Build- und Testbefehle aus dem Projekt und setzen keine bestimmten Werkzeuge voraus. | MUSS |

## 2. Container-Härtung

Ausgangslage: Der Container läuft als `dev` mit optionalem sudo
(`ENABLE_SUDO=true`) und mit den Standard-Capabilities von Docker. Das
Root-Dateisystem ist beschreibbar.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| HARD-1 | `ENABLE_SUDO` steht standardmäßig auf `false`. Wer sudo braucht, schaltet es bewusst ein, und `doctor` warnt dann. | MUSS |
| HARD-2 | Der Container läuft mit `security_opt: no-new-privileges:true`. | MUSS |
| HARD-3 | Der Container läuft mit `cap_drop: [ALL]`. Benötigte Capabilities werden einzeln und begründet wieder hinzugefügt. | MUSS |
| HARD-4 | Das Root-Dateisystem ist schreibgeschützt (`read_only: true`). Beschreibbar sind nur `/work`, die benannten Volumes und `tmpfs` für `/tmp` und `/run`. | SOLL |
| HARD-5 | Konfiguration, die das Verhalten der Agenten steuert, ist im Container nicht beschreibbar. Das betrifft auch `config/opencode`, das heute beschreibbar eingehängt ist. Sie wird wie `config/claude` geseedet oder schreibgeschützt eingehängt. | MUSS |
| HARD-6 | Der Docker-Socket des Hosts wird nie in den Container gereicht. `doctor` prüft das. | MUSS |
| HARD-7 | Die Grenzen für Ressourcen (`cpus`, `mem_limit`, `pids_limit`) bleiben erhalten und sind über `.env` steuerbar. | MUSS |

## 3. Secrets

Ausgangslage: `ANTHROPIC_API_KEY`, `GITHUB_PERSONAL_ACCESS_TOKEN`/`GH_TOKEN` und
`GITLAB_TOKEN` liegen als Umgebungsvariablen für alle Prozesse im Container.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| SEC-1 | `.env` gelangt weder ins Git noch in den Build-Kontext des Images. Das sichern `.gitignore` und `docker/.dockerignore` ab. | MUSS |
| SEC-2 | Tokens werden nicht mehr pauschal über `environment:` gesetzt. Sie liegen als Dateien unter `/run/secrets/` (Compose-Secrets) und werden nur den Werkzeugen gereicht, die sie brauchen, etwa über Wrapper oder Credential-Helper. | MUSS |
| SEC-3 | Die Agenten-Prozesse sehen Tokens nicht in ihrer Umgebung (`env`), sofern das Werkzeug das zulässt. Wo ein Token unvermeidbar in der Umgebung steht, ist das dokumentiert. | SOLL |
| SEC-4 | Kein Skript gibt den Wert eines Tokens aus, auch nicht `doctor` oder `status`. Angezeigt wird nur *gesetzt* oder *fehlt*. | MUSS |
| SEC-5 | Für jedes Token sind die Mindestrechte dokumentiert. Read-only-Varianten (z. B. `GITHUB_READ_ONLY`) bleiben erhalten. | MUSS |
| SEC-6 | Die Mounts für SSH-Keys bleiben auskommentiert. Werden sie aktiviert, sind sie schreibgeschützt, und `doctor` warnt. | MUSS |

## 4. Berechtigungen der Agenten

Ausgangslage: `config/claude/settings.json` enthält keine
Berechtigungsregeln, und `config/opencode/opencode.json` ebenso wenig.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| PERM-1 | Es gibt ein gemeinsames, dokumentiertes Berechtigungsprofil, das für beide Agenten gleich wirkt: was ohne Rückfrage erlaubt ist, was nachfragt und was verboten ist. | MUSS |
| PERM-2 | Das Profil steht als Tabelle in `config/permissions.md`. Daraus werden `config/claude/settings.json` (`permissions`) und `config/opencode/opencode.json` (`permission`) abgeleitet und von Hand synchron gehalten. | MUSS |
| PERM-3 | **Verboten:** Lesen von `/run/secrets/**` und `**/.env` durch die Agenten-Werkzeuge sowie Schreiben unter `/opt/**`. | MUSS |
| PERM-4 | **Nachfragen:** `git push`, das Anlegen oder Mergen von PRs und MRs, Paketinstallation mit sudo und destruktive Git-Befehle (`reset --hard`, `push --force`, `clean -fd`). | MUSS |
| PERM-5 | **Ohne Rückfrage:** Lesen und Schreiben unter `/work`, Build-, Test- und Lint-Befehle, Git-Befehle, die nur lesen. | SOLL |
| PERM-6 | Über einen `.env`-Schalter (`AGENT_PERMISSION_PROFILE=strict|default`) lässt sich ein strengeres Profil wählen, bei dem jeder Shell-Befehl nachfragt. | KANN |

## 5. Netzwerk-Egress

Ausgangslage: Der Container hat unbeschränkten Internetzugang. Ports sind nur
an `127.0.0.1` gebunden.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| NET-1 | Ausgehender Verkehr läuft über einen Egress-Proxy als zweiten Compose-Dienst. Der Sandbox-Container hängt nur an einem `internal`-Netz und erreicht das Internet ausschließlich über den Proxy. | MUSS |
| NET-2 | Der Proxy lässt nur Ziele aus einer Allowlist zu: `config/egress-allowlist.txt` mit einem Hostnamen oder einer Wildcard-Domain pro Zeile und Kommentaren. | MUSS |
| NET-3 | Die Standard-Allowlist deckt den Normalbetrieb ab: Anthropic-API und -Login, `GH_HOST` und die zugehörigen API- und Raw-Hosts, `GITLAB_HOST`, npm, PyPI, Go-Proxy und -Sum sowie crates.io, falls Rust aktiv ist. | MUSS |
| NET-4 | `EGRESS_MODE=allowlist|open` in der `.env`. Voreinstellung ist `allowlist`. `open` ist ein bewusster Ausstieg, und `doctor` warnt dann. | MUSS |
| NET-5 | Abgelehnte Verbindungen werden protokolliert. `./sandbox.sh egress-log` zeigt die letzten Einträge, damit fehlende Einträge in der Allowlist schnell auffallen. | SOLL |
| NET-6 | Änderungen an der Allowlist wirken ohne Rebuild, nach `./sandbox.sh restart`. | SOLL |
| NET-7 | Die Port-Weiterleitungen bleiben an `127.0.0.1` gebunden. `doctor` warnt bei `0.0.0.0`. | MUSS |

## 6. Selbsttest (`doctor`)

Ausgangslage: `doctor` listet Versionen und Zählwerte, bewertet aber nichts
und endet immer mit Exit-Code 0.

| ID | Anforderung | Stufe |
|----|-------------|-------|
| DOC-1 | `doctor` gibt je Prüfung eine Zeile mit `OK`, `WARN` oder `FAIL` aus. | MUSS |
| DOC-2 | `doctor` endet mit Exit-Code ≠ 0, sobald mindestens ein `FAIL` auftritt. Damit ist es skriptbar. | MUSS |
| DOC-3 | Eine eigene Gruppe **Sicherheit** prüft die zugesagten Eigenschaften im laufenden Container: sudo (HARD-1), no-new-privileges und Capabilities (HARD-2/3), schreibgeschütztes Root-FS (HARD-4), schreibgeschützte Agenten-Konfiguration (HARD-5), kein Docker-Socket (HARD-6), keine Tokens in der Agenten-Umgebung (SEC-3), Rechte auf `/run/secrets` (SEC-2), Berechtigungsprofil beider Agenten vorhanden und gleich (PERM-1/2) sowie Egress (NET-1/4: erlaubtes Ziel erreichbar, nicht erlaubtes blockiert). | MUSS |
| DOC-4 | Die Prüflogik liegt einmal im Image (`/usr/local/bin/sandbox-doctor`). `sandbox.sh` und `sandbox.ps1` rufen sie nur auf, sodass der Gleichstand der Plattformen ohne doppelten Code entsteht. | MUSS |
| DOC-5 | `doctor --security` führt nur die Sicherheitsgruppe aus. | KANN |
| DOC-6 | Jede neue Sicherheitsanforderung bringt im selben PR ihre `doctor`-Prüfung mit. | MUSS |
