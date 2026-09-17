fish_add_path ~/.local/bin
set -gx EDITOR nvim

if status is-interactive
    set fish_greeting

    # ============================================================
    #  HISTORICO
    # ============================================================

    set -g fish_history main
    
    # ============================================================
    #  STARSHIP
    # ============================================================
    if type -q starship
        starship init fish | source
    end

    # ============================================================
    #  ALIASES — system
    # ============================================================

    alias update='sudo pacman -Syu'

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
    alias ff='fastfetch'

    alias g='git'
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'

    # ============================================================
    #  ZOXIDE
    # ============================================================
    if type -q zoxide
        zoxide init fish | source
    end

    # ============================================================
    #  DIRENV
    # ============================================================
    if type -q direnv
        direnv hook fish | source
    end

    # ============================================================
    #  FUNCOES — servicos
    # ============================================================
    function pg-start
        sudo systemctl start postgresql; and echo "PostgreSQL rodando."
    end

    function pg-stop
        sudo systemctl stop postgresql; and echo "PostgreSQL parado."
    end

    function dk-start
        sudo systemctl start docker; and echo "Docker rodando."
    end
end
