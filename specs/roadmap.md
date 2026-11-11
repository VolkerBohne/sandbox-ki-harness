# Roadmap

Reihenfolge der Umsetzung. **Ein Schritt entspricht einem kleinen Pull
Request.** Ein Schritt wird abgehakt, sobald sein PR gemergt ist. Die
Schritte bauen aufeinander auf und werden der Reihe nach abgearbeitet.

Jeder Schritt nennt:

- **Anf.:** die Anforderungs-IDs aus `requirements.md`, die er erfüllt
  (ganz oder teilweise)
- **Fertig, wenn:** die Akzeptanzkriterien
- **Prüfen:** wie man es nachvollzieht

Ab Phase 2 gilt DOC-6: Jede Sicherheitsänderung bringt im selben Schritt ihre
`doctor`-Prüfung mit.

---

## Phase 0: Grundlage

- [x] **R0.1 Specs anlegen**
  `specs/mission.md`, `specs/requirements.md` und `specs/roadmap.md` stehen im
  Repository.

## Phase 1: Spec-Driven-Befehle

Diese Phase kommt zuerst, damit alle folgenden Schritte schon über den neuen
Workflow laufen.

- [ ] **R1.1 Befehl `spec-init`**
  `config/commands/spec-init.md` mit Skill-Hülle. Der Befehl stellt
  gruppierte Rückfragen und legt die drei Spec-Dateien an.
  *Anf.:* SDD-1, SDD-3, SDD-7
  *Fertig, wenn:* In einem leeren Testprojekt unter `/work` erzeugt der Befehl
  in beiden Agenten die drei Dateien, mit genau einer Fragerunde je Datei.
  *Prüfen:* `doctor` zählt eine Datei mehr unter „Befehle“. Der Befehl wird je
  einmal in opencode und in Claude Code durchgespielt.

- [ ] **R1.2 Befehl `spec-plan`**
  Er liest die Specs, wählt den nächsten offenen Schritt oder eine
  angegebene ID und schreibt `specs/steps/YYYY-MM-DD-<slug>.md`.
  *Anf.:* SDD-1, SDD-2, SDD-4, SDD-6
  *Fertig, wenn:* `/spec-plan` ohne Argument plant R1.3 dieser Roadmap, ohne
  Code anzufassen. Fehlen die Specs, bricht der Befehl mit einem Hinweis ab.
  *Prüfen:* `git status` zeigt nur die neue Datei unter `specs/steps/`.

- [ ] **R1.3 Befehl `spec-implement`**
  Er arbeitet einen Schrittplan ab, mit Branch `step/YYYY-MM-DD-<slug>`,
  Commits mit der ID, einem PR und dem Haken in der Roadmap.
  *Anf.:* SDD-1, SDD-2, SDD-5, SDD-6, SDD-7
  *Fertig, wenn:* Ein Probelauf an R1.4 (`/spec-plan R1.4`, danach
  `/spec-implement R1.4`) öffnet einen PR, in dem R1.4 abgehakt ist.
  *Prüfen:* Branch-Name, Commit-Message, PR-Text und der Diff von `roadmap.md`
  im PR durchsehen.

- [ ] **R1.4 README-Abschnitt „Spec-Driven arbeiten“**
  Er beschreibt den Ablauf `spec-init` → `spec-plan` → `spec-implement` und
  grenzt ihn gegen `plan-item` und `implement-item` ab.
  *Anf.:* X-3
  *Fertig, wenn:* Der Abschnitt steht im README, mit einem Beispiel.

## Phase 2: Gerüst für `doctor`

- [ ] **R2.1 Prüfskript im Image**
  `docker/sandbox-doctor` wird nach `/usr/local/bin` kopiert und übernimmt
  die bisherigen Ausgaben 1:1.
  *Anf.:* DOC-4
  *Fertig, wenn:* `./sandbox.sh doctor` und `.\sandbox.ps1 doctor` liefern
  dieselbe Ausgabe wie vorher und rufen nur noch das Skript auf.
  *Prüfen:* Die Ausgaben vor und nach der Änderung vergleichen.

- [ ] **R2.2 Ergebniszeilen und Exit-Code**
  Jede Prüfung gibt `OK`, `WARN` oder `FAIL` aus, und bei einem `FAIL` endet
  das Skript mit Exit-Code 1.
  *Anf.:* DOC-1, DOC-2
  *Fertig, wenn:* Ein fehlendes Werkzeug (z. B. `INSTALL_CLAUDE=false`) führt
  zu `WARN`, ein absichtlich ausgelöstes `FAIL` zu Exit-Code 1.
  *Prüfen:* `./sandbox.sh doctor; echo $?`

- [ ] **R2.3 Gruppe „Sicherheit“ (leer) und `--security`**
  Abschnitt und Schalter sind angelegt. Erste Prüfungen sind Docker-Socket
  (HARD-6) und Ports an `127.0.0.1` (NET-7).
  *Anf.:* DOC-3 (Anfang), DOC-5, HARD-6, NET-7
  *Fertig, wenn:* Beide Prüfungen sind im Normalzustand `OK`. Ein auf
  `0.0.0.0` umgestellter Port ergibt `WARN`.
  *Prüfen:* `./sandbox.sh doctor --security`

## Phase 3: Container-Härtung

- [ ] **R3.1 sudo standardmäßig aus**
  `ENABLE_SUDO=false` in `.env.example` und `compose.yaml`, mit einer Prüfung
  in `doctor`.
  *Anf.:* HARD-1
  *Fertig, wenn:* Nach einem Rebuild schlägt `sudo -n true` fehl, und `doctor`
  meldet `OK`. Mit `ENABLE_SUDO=true` meldet er `WARN`.
  *Prüfen:* `./sandbox.sh run sudo -n true`

- [ ] **R3.2 `no-new-privileges`**
  *Anf.:* HARD-2
  *Fertig, wenn:* `security_opt` steht in `compose.yaml`, und `doctor` liest
  `NoNewPrivs: 1` aus `/proc/self/status`.
  *Prüfen:* `./sandbox.sh run grep NoNewPrivs /proc/self/status`

- [ ] **R3.3 Capabilities entziehen**
  `cap_drop: [ALL]` und nur die nötigen Capabilities wieder hinzufügen, jede
  mit einem Kommentar.
  *Anf.:* HARD-3
  *Fertig, wenn:* Entrypoint, Git, die Agenten, Builds und Tests laufen
  weiterhin. `doctor` prüft `CapEff` gegen die erwartete Menge.
  *Prüfen:* `./sandbox.sh run grep Cap /proc/self/status`, danach ein
  kompletter `/spec-plan`-Durchlauf.

- [ ] **R3.4 Agenten-Konfiguration schreibgeschützt**
  `config/opencode` wird geseedet oder schreibgeschützt eingehängt, nicht mehr
  beschreibbar.
  *Anf.:* HARD-5
  *Fertig, wenn:* Ein Schreibversuch auf `~/.config/opencode/opencode.json`
  im Container scheitert. Der Ablauf über `reseed` funktioniert und ist im
  README beschrieben.
  *Prüfen:* `./sandbox.sh run touch ~/.config/opencode/opencode.json`

- [ ] **R3.5 Root-Dateisystem schreibgeschützt**
  `read_only: true` mit `tmpfs` für `/tmp` und `/run`. Laufzeitpfade, die
  noch fehlen, werden als Volume oder `tmpfs` ergänzt.
  *Anf.:* HARD-4
  *Fertig, wenn:* `touch /usr/local/x` scheitert. Agenten, `npm i`,
  `go build` und `pip install --user` funktionieren.
  *Prüfen:* `./sandbox.sh doctor --security`

## Phase 4: Secrets

- [ ] **R4.1 `.dockerignore` und Prüfung des Build-Kontexts**
  *Anf.:* SEC-1
  *Fertig, wenn:* `docker/.dockerignore` schließt `.env*` aus, und `doctor`
  findet im Image keine `.env`.
  *Prüfen:* `docker run --rm <image> find / -name .env 2>/dev/null` liefert
  nichts.

- [ ] **R4.2 Werte von Tokens nie ausgeben**
  Alle Ausgaben in `sandbox.sh`, `sandbox.ps1`, `entrypoint.sh` und `doctor`
  werden durchgesehen.
  *Anf.:* SEC-4
  *Fertig, wenn:* Eine Suche nach Ausgaben mit `$*TOKEN`, `$*KEY` ohne
  Maskierung findet nichts.
  *Prüfen:* Die Suche per `grep` ist im PR dokumentiert.

- [ ] **R4.3 Compose-Secrets für GitHub**
  Das GitHub-Token liegt unter `/run/secrets/github_token`, und gh, der
  Credential-Helper und der MCP-Server lesen es dort.
  *Anf.:* SEC-2 (GitHub)
  *Fertig, wenn:* `GH_TOKEN` und `GITHUB_PERSONAL_ACCESS_TOKEN` fehlen in der
  Umgebung, und `gh auth status`, `git push` sowie die MCP-Werkzeuge
  funktionieren.
  *Prüfen:* `./sandbox.sh run env | grep -c TOKEN` ergibt 0, danach
  `./sandbox.sh gh auth status`.

- [ ] **R4.4 Compose-Secrets für GitLab**
  Wie R4.3, für `glab` und `glab mcp serve`.
  *Anf.:* SEC-2 (GitLab)
  *Fertig, wenn:* `GITLAB_TOKEN` fehlt in der Umgebung, und `glab auth status`
  sowie die MCP-Werkzeuge funktionieren.

- [ ] **R4.5 Compose-Secrets für Anthropic**
  Der API-Key kommt als Secret und wird nur an die Agenten-Prozesse gereicht,
  etwa über Wrapper unter `/usr/local/bin`.
  *Anf.:* SEC-2, SEC-3
  *Fertig, wenn:* Beide Agenten starten mit Key, und die Login-Shell enthält
  ihn nicht. Wo es technisch nicht anders geht, ist das dokumentiert.

- [ ] **R4.6 Prüfungen für Secrets in `doctor`, Doku der Mindestrechte**
  *Anf.:* SEC-2, SEC-3, SEC-5, SEC-6, DOC-3
  *Fertig, wenn:* `doctor` prüft die Dateirechte unter `/run/secrets`, die
  Umgebung ohne Tokens und schreibgeschützte SSH-Mounts. Das README nennt je
  Token die Mindestrechte.

## Phase 5: Berechtigungen der Agenten

- [ ] **R5.1 Profil festschreiben**
  `config/permissions.md` mit den Tabellen *erlaubt*, *nachfragen* und
  *verboten*.
  *Anf.:* PERM-1, PERM-2
  *Fertig, wenn:* Die Tabelle deckt PERM-3 bis PERM-5 vollständig ab und ist
  reviewt.

- [ ] **R5.2 Profil für Claude Code**
  `permissions` (`allow`, `ask`, `deny`) in `config/claude/settings.json`.
  *Anf.:* PERM-2 bis PERM-5
  *Fertig, wenn:* Nach `reseed` lehnt Claude Code `cat /work/x/.env` ab, fragt
  bei `git push` nach und führt `go test` ohne Rückfrage aus.

- [ ] **R5.3 Profil für opencode**
  `permission` in `config/opencode/opencode.json`, inhaltlich gleich wie R5.2.
  *Anf.:* PERM-2 bis PERM-5, X-1
  *Fertig, wenn:* opencode verhält sich bei denselben drei Proben wie in R5.2
  gleich.

- [ ] **R5.4 Abgleich in `doctor`**
  `doctor` prüft, ob beide Profile vorhanden sind und die verbotenen Muster in
  beiden stehen.
  *Anf.:* DOC-3 (PERM)
  *Fertig, wenn:* Wird ein `deny`-Eintrag in einer der beiden Dateien
  entfernt, ergibt das `FAIL`.

- [ ] **R5.5 Strenges Profil (optional)**
  *Anf.:* PERM-6
  *Fertig, wenn:* Mit `AGENT_PERMISSION_PROFILE=strict` fragt jeder
  Shell-Befehl nach, in beiden Agenten.

## Phase 6: Netzwerk-Egress

- [ ] **R6.1 Proxy-Dienst im Modus `open`**
  Ein zweiter Compose-Dienst `egress` (z. B. tinyproxy oder squid) wird
  angelegt. Die Sandbox setzt `HTTP(S)_PROXY`, alles bleibt erlaubt.
  *Anf.:* NET-1 (Vorbereitung), NET-4
  *Fertig, wenn:* Agenten, `gh`, `glab`, npm, pip und go funktionieren über
  den Proxy. `EGRESS_MODE=open` ergibt in `doctor` ein `WARN`.

- [ ] **R6.2 Allowlist-Datei und Standardliste**
  `config/egress-allowlist.txt` mit den Einträgen aus NET-3. Sie wird in den
  Proxy eingehängt, ist aber noch nicht aktiv.
  *Anf.:* NET-2, NET-3, NET-6
  *Fertig, wenn:* Jeder Eintrag hat einen Kommentar, wofür er da ist. Der Proxy
  übernimmt die Datei nach `restart`.

- [ ] **R6.3 Allowlist erzwingen**
  `EGRESS_MODE=allowlist` wird Voreinstellung, und der Proxy lehnt alles
  andere ab.
  *Anf.:* NET-2, NET-4
  *Fertig, wenn:* `curl https://example.com` scheitert, `gh api user`
  funktioniert, und ein Durchlauf von `/spec-plan` klappt.

- [ ] **R6.4 Internes Netz**
  Die Sandbox hängt nur am `internal`-Netz, der Proxy an `internal` und am
  Standardnetz. Direkte Verbindungen ohne Proxy sind unmöglich.
  *Anf.:* NET-1
  *Fertig, wenn:* `curl --noproxy '*' https://api.github.com` scheitert. Die
  Port-Weiterleitungen funktionieren weiterhin.

- [ ] **R6.5 `egress-log`**
  Ein Unterbefehl in `sandbox.sh` und `sandbox.ps1` zeigt abgelehnte Ziele an.
  *Anf.:* NET-5, X-2
  *Fertig, wenn:* Nach einem blockierten `curl` erscheint der Host in
  `./sandbox.sh egress-log`.

- [ ] **R6.6 Egress-Prüfungen in `doctor`, Doku**
  *Anf.:* DOC-3 (NET), X-3
  *Fertig, wenn:* `doctor` prüft, dass ein erlaubtes Ziel `OK` ergibt und ein
  nicht erlaubtes blockiert wird. Das README beschreibt die Allowlist und den
  Modus `open`.

---

## Später / ungeplant

Ideen, die noch nicht eingeplant sind. Sie werden erst nach einer Anpassung
von `requirements.md` aufgenommen.

- GitLab-Issues und Merge Requests für `plan-item` und `implement-item`
- Project-Board-Anbindung (`GITHUB_PROJECT_*`)
- CI mit GitHub Actions (Image-Build, shellcheck, hadolint, `doctor` als
  Smoke-Test)
- Reproduzierbare Builds (gepinnte Digests und Versionen)
