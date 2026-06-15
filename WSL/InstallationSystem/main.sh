#!/usr/bin/env bash

# ============================================================
#  INSTALL MODULE — orquestrador principal
#  Pode ser sourced ou executado diretamente
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

# Source sub-modules
source "$SCRIPT_DIR/setup-initial.sh"
source "$SCRIPT_DIR/install-packages.sh"
source "$SCRIPT_DIR/apply-configs.sh"
source "$SCRIPT_DIR/setup-shell.sh"

run_install_module() {
    log "Iniciando modulo de instalacao — $(date)"

    # 1. yay (necessario antes de qualquer AUR)
    install_yay

    # 2. Pacotes base (pacman + AUR pessoal)
    install_official_packages
    install_aur_packages

    # 3. END4 — clona + roda sdata (deps/setups/files) + dots-extra
    #    Os illogical-impulse-* sao instalados internamente pelo ./setup
    setup_end4

    # 4. Configs de sistema e dots pessoais (por cima do END4)
    apply_system_files
    setup_sddm
    apply_personal_dots

    # 5. Cursor
    setup_cursors

    # 6. Apps extras
    setup_flatpak
    setup_spicetify

    # 6. Servicos e shell
    enable_services
    set_default_shell

    # 7. System tuning (Swap 8GB + NVIDIA VRAM 8GB)
    run_system_tuning

    log "Modulo de instalacao concluido."
}

# Standalone execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_install_module
fi
