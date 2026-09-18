#!/usr/bin/env bash

apply_dotfiles() {
    local source relative target parent
    local backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/windows-dotfiles/backups"
    local backup_dir=''
    [[ "$backup_root" = /* ]] || die 'XDG_STATE_HOME deve ser absoluto.'
    # Copias independem de onde o repo for guardado depois da formatacao.
    while IFS= read -r -d '' source; do
        relative="${source#"$WSL_DIR/dots/"}"
        target="$HOME/$relative"
        parent="$(dirname "$target")"
        [[ ! -d "$target" ]] || die "Destino e um diretorio: $target"
        if [[ -f "$target" && ! -L "$target" ]] && cmp -s "$source" "$target"; then
            continue
        fi
        if (( DRY_RUN )); then
            log "[dry-run] Copiar $relative; salvar destino existente em $backup_root."
            continue
        fi
        if [[ -e "$target" || -L "$target" ]]; then
            if [[ -z "$backup_dir" ]]; then
                mkdir -p "$backup_root"
                backup_dir="$(mktemp -d "$backup_root/$(date +%Y%m%d-%H%M%S).XXXXXX")"
            fi
            mkdir -p "$backup_dir/$(dirname "$relative")"
            mv -- "$target" "$backup_dir/$relative"
        fi
        mkdir -p "$parent"
        cp -- "$source" "$target"
    done < <(find "$WSL_DIR/dots" -type f -print0)
    [[ -z "$backup_dir" ]] || log "Backup das configuracoes anteriores: $backup_dir"
    log 'Dotfiles conferidos.'
}

setup_fish() {
    local fish_path current_shell

    if (( DRY_RUN )); then
        log '[dry-run] Definir Fish como shell de login, se necessario.'
        return
    fi

    fish_path="$(command -v fish)" || die 'Fish nao encontrado.'
    fish_path="$(readlink -f "$fish_path")"

    current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"

    if [[ "$current_shell" != "$fish_path" ]]; then
        grep -Fxq "$fish_path" /etc/shells \
            || die "Fish ($fish_path) ausente de /etc/shells."

        chsh -s "$fish_path"
        log 'Reabra a sessao para usar Fish.'
    fi
}
