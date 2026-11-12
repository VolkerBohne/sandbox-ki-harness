# Tech-Stack

Diese Datei beschreibt, **womit** die Sandbox gebaut ist: die eingesetzten
Komponenten und die, die laut Roadmap hinzukommen. Was gelten muss, steht in
`requirements.md`, die Reihenfolge in `roadmap.md`.

Kommt eine Komponente hinzu oder fällt eine weg, wird zuerst diese Datei
angepasst, im selben PR wie die Änderung an Anforderungen oder Roadmap.

Spalte **Steuerung**: der `.env`-Schalter bzw. das Build-Argument, über das die
Komponente gewählt oder versioniert wird. *fest* heißt: immer enthalten.

---

## 1. Host

| Komponente | Zweck | Steuerung |
|------------|-------|-----------|
| Docker Engine bzw. Docker Desktop | Container-Laufzeit | – |
| Docker Compose v2 | Definition des Dienstes `sandbox`, Volumes, Ports, Grenzen (`compose.yaml`) | – |
| `sandbox.sh` | Bedienung unter macOS und Linux (bash) | – |
| `sandbox.ps1`, `sandbox.bat` | Bedienung unter Windows (PowerShell, `.bat` als Starter) | – |
| `.env` / `.env.example` | Alle Schalter, Tokens und Grenzen | – |

Der Quellcode der Projekte liegt auf dem Host unter `WORKSPACE_DIR` und wird
nach `/work` eingehängt.

## 2. Image und Container

| Komponente | Zweck | Steuerung |
|------------|-------|-----------|
| `debian:bookworm-slim` | Basis-Image | fest |
| `golang:1-bookworm` (Build-Stufe) | Übersetzt den GitHub-MCP-Server, landet nicht im Image | fest |
| `tini` über `init: true` | PID 1, sauberes Signal-Handling | fest |
| `docker/entrypoint.sh` | Seeding von `config/claude`, Git-Identität | `SEED_OVERWRITE` |
| Benutzer `dev` (UID/GID vom Host) | Arbeitsbenutzer ohne root | `SANDBOX_UID`, `SANDBOX_GID` |
| sudo für `dev` | Optional, laut HARD-1 künftig aus | `ENABLE_SUDO` (heute `true`) |
| Basiswerkzeuge per apt | git, git-lfs, openssh-client, ripgrep, fd, jq, tree, tmux, build-essential, cmake u. a. | `EXTRA_APT_PACKAGES` für Ergänzungen |
| Ressourcengrenzen | `cpus`, `mem_limit`, `pids_limit` | `SANDBOX_CPUS`, `SANDBOX_MEMORY` |
| Port-Weiterleitungen | 3000, 5173, 8000, nur an `127.0.0.1` | `PORT_A` bis `PORT_C` |

## 3. Agenten

| Komponente | Zweck | Installation | Steuerung |
|------------|-------|--------------|-----------|
| Claude Code | KI-Coding-Agent | `npm install -g @anthropic-ai/claude-code` (braucht Node) | `INSTALL_CLAUDE`, `CLAUDE_CODE_VERSION` |
| opencode | KI-Coding-Agent | Installer von opencode.ai, Rückfall auf `npm install -g opencode-ai` | `INSTALL_OPENCODE`, `OPENCODE_VERSION` |

Selbst-Updates der Agenten sind abgeschaltet (`DISABLE_AUTOUPDATER=1`,
`autoupdate: false`). Aktualisiert wird per `./sandbox.sh update`.

**Geteilte Befehle und Skills** (eine Quelle für beide Agenten, X-1):

| Quelle | Eingehängt nach | Nur lesend |
|--------|-----------------|-----------|
| `config/commands/*.md` | `/opt/agent-commands`, `~/.claude/commands`, `~/.config/opencode/commands` | ja |
| `config/skills/<name>/SKILL.md` | `~/.claude/skills` (liest auch opencode) | ja |
| `config/claude/` | per Seed nach `~/.claude` | Vorlage `ro` |
| `config/opencode/` | `~/.config/opencode` | **nein**, siehe HARD-5 / R3.4 |

Vorhandene Befehle: `plan-item`, `implement-item` (GitHub-Issues), `spec-init`
(Spec-Driven Development). Mit R1.5 kommen die OpenSpec-Skills dazu, siehe
Abschnitt 9.

## 4. Anbindung an GitHub und GitLab

| Komponente | Zweck | Steuerung |
|------------|-------|-----------|
| `gh` (GitHub CLI, apt-Repository von GitHub) | Issues, PRs, API | `GH_HOST`, Token |
| `github-mcp-server` (aus dem Quelltext gebaut) | MCP-Server für beide Agenten, lokal per stdio | `GITHUB_MCP_VERSION`, `GITHUB_TOOLSETS`, `GITHUB_READ_ONLY` |
| GitHub-Remote-MCP (`api.githubcopilot.com`) | Alternative zum lokalen Server, standardmäßig aus | in `config/opencode/opencode.json` |
| `glab` (GitLab CLI, `.deb` aus den GitLab-Releases) | Issues, MRs, API | `GLAB_VERSION`, `GITLAB_HOST`, Token |
| `glab mcp serve` | MCP-Server für GitLab | Token |

Tokens: `ANTHROPIC_API_KEY`, `GITHUB_PERSONAL_ACCESS_TOKEN` (auch als
`GH_TOKEN`), `GITLAB_TOKEN`. Heute als Umgebungsvariablen, laut SEC-2 künftig
als Compose-Secrets.

## 5. Sprachen und Toolchains

| Komponente | Quelle | Steuerung |
|------------|--------|-----------|
| Node.js | NodeSource-Repository | `INSTALL_NODE`, `NODE_MAJOR` (22) |
| Python 3 mit venv, pip, pipx | Debian | `INSTALL_PYTHON` |
| Go | go.dev, neueste oder gepinnte Version | `INSTALL_GO`, `GO_VERSION` |
| Rust | rustup, Profil `minimal` | `INSTALL_RUST` (Standard `false`) |

Globale npm-Pakete liegen unter `~/.npm-global` (Volume), Go-Module unter
`~/go/pkg` (Volume).

## 6. Shell

| Komponente | Zweck | Steuerung |
|------------|-------|-----------|
| zsh mit oh-my-zsh, zsh-completions, Spaceship-Prompt | Login-Shell | `INSTALL_ZSH`, `OMZ_REF`, `SPACESHIP_REF` |
| bash | Rückfall-Shell, Skripte | fest |

## 7. Persistenz (benannte Volumes)

| Volume | Inhalt |
|--------|--------|
| `claude-data` | Anmeldung und Sitzungen von Claude Code |
| `opencode-data` | Anmeldung und Sitzungen von opencode |
| `gh-config`, `glab-config` | Zustand von `gh` und `glab` |
| `sandbox-cache`, `sandbox-go`, `sandbox-npm` | Caches |

## 8. Versionierung

Die meisten Komponenten werden ohne feste Version gebaut (neueste Version
bzw. `latest`). Über die `*_VERSION`-Schalter lässt sich pinnen.
Reproduzierbare Builds mit gepinnten Digests stehen in der Roadmap unter
*Später / ungeplant*.

---

## 9. Geplante Komponenten

| Komponente | Zweck | Roadmap | Anf. | Stand |
|------------|-------|---------|------|-------|
| OpenSpec-CLI (`@fission-ai/openspec`, npm, gepinnt auf 2.0.0, Node ≥ 22.12) mit globaler Kopie aller Skills unter `config/skills/openspec-*`, Telemetrie und Update-Prüfung aus | Zusätzlicher Spec-Driven-Workflow für Zielprojekte, Skills für beide Agenten | R1.5 | OSP-1 bis OSP-6 | geplant |
| `sandbox-doctor` unter `/usr/local/bin` | Gemeinsame Prüflogik für `doctor` beider Plattformen | R2.1 bis R2.3 | DOC-1 bis DOC-6 | geplant |
| Compose-Härtung (`no-new-privileges`, `cap_drop`, `read_only`, `tmpfs`) | Container-Isolation | R3.1 bis R3.5 | HARD-1 bis HARD-5 | geplant |
| Compose-Secrets unter `/run/secrets` mit Wrappern bzw. Credential-Helper | Tokens nicht mehr in der Umgebung | R4.1 bis R4.6 | SEC-1 bis SEC-6 | geplant |
| `config/permissions.md` und Berechtigungen in beiden Agenten | Gemeinsames Berechtigungsprofil | R5.1 bis R5.5 | PERM-1 bis PERM-6 | geplant |
| Egress-Proxy als zweiter Compose-Dienst (tinyproxy oder squid, noch offen) mit `config/egress-allowlist.txt` und `internal`-Netz | Ausgehender Verkehr nur über Allowlist | R6.1 bis R6.6 | NET-1 bis NET-7 | geplant, Proxy-Wahl offen |
| CI mit GitHub Actions (Image-Build, shellcheck, hadolint, `doctor` als Smoke-Test) | Automatische Prüfung | – | – | ungeplant |
