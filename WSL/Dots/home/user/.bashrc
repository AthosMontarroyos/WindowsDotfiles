# ============================================================
#  .bashrc — WSL + Warp
# ============================================================

# Nao rodar em sessoes nao-interativas
[[ $- != *i* ]] && return

# ============================================================
#  PATH
# ============================================================

export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ============================================================
#  ALIASES — navegacao
# ============================================================

alias ls='eza --icons'
alias ll='eza --icons -la'
alias lt='eza --icons --tree'

# Typos
alias celar="printf '\033[2J\033[3J\033[1;1H'"
alias claer="printf '\033[2J\033[3J\033[1;1H'"
alias pamcan='sudo pacman'

# ============================================================
#  ALIASES — dev
# ============================================================

alias dc='docker compose'
alias lzd='lazydocker'
alias oc='opencode'

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# ============================================================
#  FUNCOES — servicos
# ============================================================

pg-start() {
    sudo systemctl start postgresql
    echo "PostgreSQL rodando."
}

pg-stop() {
    sudo systemctl stop postgresql
    echo "PostgreSQL parado."
}

dk-start() {
    sudo systemctl start docker
    echo "Docker rodando."
}

# ============================================================
#  ZOXIDE
# ============================================================

eval "$(zoxide init bash)"

# ============================================================
#  DIRENV
# ============================================================

eval "$(direnv hook bash)"
