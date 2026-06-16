#!/usr/bin/env bash

# corrigir CRLF
sed -i 's/\r//' "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/../lib/utils.sh
find "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" -name "*.sh" -exec sed -i 's/\r//' {} +

# ============================================================
#  APLICAR CONFIGURACOES — WSL (wsl.conf, git, gh, dots)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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
# GIT + GITHUB + SSH
# ----------------------------------------------------------
apply_git_config() {
    local current_name current_email
    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"

    current_name="$(git config --global user.name 2>/dev/null)"
    current_email="$(git config --global user.email 2>/dev/null)"

    if [[ -z "$current_name" || -z "$current_email" ]]; then
        log "Configurando Git..."

        read -rp "Nome para git config: " GIT_NAME
        read -rp "Email para git config: " GIT_EMAIL

        git config --global user.name "$GIT_NAME"
        git config --global user.email "$GIT_EMAIL"
        git config --global init.defaultBranch main
        git config --global core.autocrlf false

        current_email="$GIT_EMAIL"

        log "Git configurado."
    else
        log "Git ja configurado ($current_name / $current_email)."
    fi

    if ! command -v gh >/dev/null 2>&1; then
        warn "gh nao encontrado."
        return
    fi

    if ! gh auth status >/dev/null 2>&1; then
        log "Autenticando GitHub CLI..."
        gh auth login
    else
        warn "gh ja autenticado."
    fi

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    if [[ ! -f "$key_file" ]]; then
        log "Gerando chave SSH..."

        ssh-keygen \
            -t ed25519 \
            -a 100 \
            -f "$key_file" \
            -N "" \
            -C "$current_email"

        chmod 600 "$key_file"
        chmod 644 "${key_file}.pub"

        log "Chave SSH criada."
    else
        warn "Chave SSH ja existe."
    fi

    cat > "$ssh_dir/config" <<EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $key_file
    IdentitiesOnly yes
EOF

    chmod 600 "$ssh_dir/config"

    if gh auth status >/dev/null 2>&1; then
        if gh ssh-key list >/dev/null 2>&1; then
            if ! gh ssh-key list 2>/dev/null | \
                grep -q "$(cut -d' ' -f2 "${key_file}.pub")"; then

                log "Adicionando chave SSH ao GitHub..."

                gh ssh-key add \
                    "${key_file}.pub" \
                    --title "$USER@$(uname -n)"

                log "Chave SSH adicionada."
            else
                warn "Chave SSH ja cadastrada."
            fi
        else
            warn "Token GitHub nao possui permissao admin:public_key. Pulando cadastro automatico."
        fi
    fi

    ssh \
        -o StrictHostKeyChecking=accept-new \
        -T git@github.com || true

    log "Git + GitHub + SSH configurados."
}

# ----------------------------------------------------------
# DOTS PESSOAIS
# ----------------------------------------------------------
apply_personal_dots() {
    local src_base="$DOTFILES_DIR/Dots/home/user"

    log "Procurando dots em: $src_base"

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

    if [[ -f "$src_base/.bashrc" ]]; then
        log "Copiando .bashrc..."
        cp -f "$src_base/.bashrc" "$HOME/.bashrc"
    fi

    log "Configs pessoais aplicadas."
}

# ----------------------------------------------------------
# NPM
# ----------------------------------------------------------
apply_npmrc() {
    if [[ -f "$HOME/.npmrc" ]]; then
        warn ".npmrc ja existe — pulando."
        return
    fi

    log "Configurando .npmrc..."

    echo "prefix=$HOME/.npm-global" > "$HOME/.npmrc"
    mkdir -p "$HOME/.npm-global/bin"

    log ".npmrc configurado."
}

# ----------------------------------------------------------
# ORQUESTRADOR
# ----------------------------------------------------------
apply_dots() {
    apply_wsl_conf
    apply_git_config
    apply_personal_dots
    apply_npmrc
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_dots
fi