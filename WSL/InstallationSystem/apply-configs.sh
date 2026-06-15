#!/usr/bin/env bash

# ============================================================
#  APLICAR CONFIGURACOES — WSL (wsl.conf, git, gh, dots)
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

# ----------------------------------------------------------
# WSL.CONF
# ----------------------------------------------------------
apply_wsl_conf() {
    log "Configurando wsl.conf..."

    local wsl_conf="/etc/wsl.conf"

    if [[ -f "$wsl_conf" ]]; then
        warn "wsl.conf ja existe — pulando. Edite manualmente se necessario."
        return
    fi

    sudo tee "$wsl_conf" > /dev/null <<EOF
[boot]
systemd=true

[user]
default=$USER

[interop]
appendWindowsPath=false
EOF

    log "wsl.conf criado. Reinicie o WSL para aplicar: wsl --shutdown"
}

# ----------------------------------------------------------
# GIT CONFIG
# ----------------------------------------------------------
apply_git_config() {
    log "Configurando Git..."

    read -rp "  Nome para git config (ex: Athos Montarroyos): " GIT_NAME
    read -rp "  Email para git config: " GIT_EMAIL

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main
    git config --global core.autocrlf false

    log "Git configurado."
}

# ----------------------------------------------------------
# GITHUB CLI AUTH
# ----------------------------------------------------------
apply_gh_auth() {
    if ! command -v gh &>/dev/null; then
        warn "gh nao encontrado — pulando autenticacao GitHub."
        return
    fi

    if gh auth status &>/dev/null; then
        warn "gh ja autenticado — pulando."
        return
    fi

    log "Autenticando GitHub CLI..."
    gh auth login
}

# ----------------------------------------------------------
# DOTS PESSOAIS
# ----------------------------------------------------------
apply_personal_dots() {
    local src_base="$DOTFILES_DIR/Dots/home/user"

    if [[ ! -d "$src_base" ]]; then
        warn "Dots/home/user nao encontrado — pulando configs pessoais."
        return
    fi

    log "Aplicando configs pessoais..."

    for dir in .config .local; do
        if [[ -d "$src_base/$dir" ]]; then
            log "Copiando $dir..."
            mkdir -p "$HOME/$dir"
            cp -rf "$src_base/$dir/." "$HOME/$dir/"
        fi
    done

    log "Configs pessoais aplicadas."
}

# ----------------------------------------------------------
# ORQUESTRADOR
# ----------------------------------------------------------
apply_dots() {
    apply_wsl_conf
    apply_git_config
    apply_gh_auth
    apply_personal_dots
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_dots
fi