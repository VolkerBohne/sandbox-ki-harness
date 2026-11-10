# Begruessung + Komfort in der Sandbox
# Prompt nur fuer bash - in zsh setzt Spaceship den Prompt
if [ -n "${BASH_VERSION:-}" ]; then
  export PS1='\[\e[32m\]sandbox\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi
alias ll='ls -alF --color=auto'
alias ls='ls --color=auto'

if [ -z "${GH_TOKEN:-}" ] && [ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  export GH_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN"
fi

if [ -z "${SANDBOX_MOTD_SHOWN:-}" ] && [ -t 1 ]; then
  export SANDBOX_MOTD_SHOWN=1
  _have() { command -v "$1" >/dev/null 2>&1; }
  echo
  echo "  Entwicklungs-Sandbox  --  Projekte liegen unter /work"
  echo
  _have opencode && echo "  opencode             opencode-TUI"
  _have claude   && echo "  claude               Claude Code"
  echo "  gh repo clone O/R    GitHub-Repository nach /work holen"
  _have glab     && echo "  glab repo clone G/P  GitLab-Projekt nach /work holen"
  echo
  echo "  Gemeinsame Befehle in beiden:"
  echo "    /plan-item <Nr>      Item vom Board planen"
  echo "    /implement-item <Nr> Item umsetzen und PR anlegen"
  echo
  if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "  Anthropic:  API-Key gesetzt"
  else
    echo "  Anthropic:  kein Key - opencode: /connect, claude: /login"
  fi
  if [ -n "${GH_TOKEN:-}" ]; then
    echo "  GitHub:     Token gesetzt (gh + MCP-Server einsatzbereit)"
  else
    echo "  GitHub:     kein Token -> GITHUB_PERSONAL_ACCESS_TOKEN in .env"
  fi
  if [ -n "${GITLAB_TOKEN:-}" ]; then
    echo "  GitLab:     Token gesetzt fuer ${GITLAB_HOST:-gitlab.com} (glab + MCP-Server)"
  else
    echo "  GitLab:     kein Token -> GITLAB_TOKEN in .env"
  fi
  echo
  unset -f _have
fi
