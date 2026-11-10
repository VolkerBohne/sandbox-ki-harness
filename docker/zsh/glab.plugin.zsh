# oh-my-zsh-Plugin fuer die GitLab CLI (glab)
# oh-my-zsh bringt keines mit; aufgebaut wie das mitgelieferte gh-Plugin:
# die Completion wird einmalig erzeugt und im Cache abgelegt.

(( $+commands[glab] )) || return

if [[ ! -f "$ZSH_CACHE_DIR/completions/_glab" ]]; then
  mkdir -p "$ZSH_CACHE_DIR/completions"
  glab completion -s zsh >| "$ZSH_CACHE_DIR/completions/_glab" 2>/dev/null
  typeset -g -A _comps
  autoload -Uz _glab
  _comps[glab]=_glab
fi

(( ${fpath[(Ie)$ZSH_CACHE_DIR/completions]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)
