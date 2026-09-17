#!/usr/bin/env bash

load_packages() {
    PACKAGES=()
    local group line file
    local -A seen=()
    for group in "${GROUPS_SELECTED[@]}"; do
        file="$WSL_DIR/packages/$group.txt"
        [[ -f "$file" ]] || die "Manifesto ausente: $file"
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%$'\r'}"
            line="${line%%#*}"
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue
            [[ "$line" =~ ^[a-z0-9@_+.-]+$ ]] || die "Pacote invalido em $file: $line"
            if [[ -z "${seen[$line]+present}" ]]; then
                PACKAGES+=("$line")
                seen[$line]=1
            fi
        done < "$file"
    done
    ((${#PACKAGES[@]})) || die 'Nenhum pacote selecionado.'
}

install_packages() {
    log "Perfis: ${GROUPS_SELECTED[*]} (${#PACKAGES[@]} pacotes explicitos)."
    # Uma transacao completa evita atualizar apenas parte do sistema.
    run sudo pacman -Syu --needed "${PACKAGES[@]}"
    if (( ! DRY_RUN )); then
        command -v opencode >/dev/null || die 'OpenCode nao encontrado apos a instalacao.'
        opencode --version
    fi
}
