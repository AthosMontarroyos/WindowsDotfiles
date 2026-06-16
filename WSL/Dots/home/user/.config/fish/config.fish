if status is-interactive
    set fish_greeting

    # ============================================================
    #  FASTFETCH — skipa dentro do editor do Terax e VSCode
    # ============================================================
    if test "$TERM_PROGRAM" != "vscode" && test "$TERAX_EDITOR" != "1"
        fastfetch
    end

    # ============================================================
    #  STARSHIP
    # ============================================================
    starship init fish | source

    # ============================================================
    #  PATH
    # ============================================================
    fish_add_path ~/.npm-global/bin
    fish_add_path ~/.local/bin

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
    #  ZOXIDE
    # ============================================================
    zoxide init fish | source

    # ============================================================
    #  DIRENV
    # ============================================================
    direnv hook fish | source

    # ============================================================
    #  FUNCOES — servicos
    # ============================================================
    function pg-start
        sudo systemctl start postgresql
        echo "PostgreSQL rodando."
    end

    function pg-stop
        sudo systemctl stop postgresql
        echo "PostgreSQL parado."
    end

    function dk-start
        sudo systemctl start docker
        echo "Docker rodando."
    end
end