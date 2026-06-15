# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    # Skip fastfetch inside VS Code terminal
    if test "$TERM_PROGRAM" != "vscode"
        random_fastfetch
    end
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end

    # npm global sem root
    set -x PATH ~/.npm-global/bin $PATH

    # OpenCode — agente de coding local
    alias oc 'opencode'

end
