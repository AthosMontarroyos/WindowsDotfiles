#!/usr/bin/env bash

if grep -rlP '\r' "$(dirname "$0")"/.. --include="*.sh" | grep -q .; then
    grep -rlP '\r' "$(dirname "$0")"/.. --include="*.sh" | xargs sed -i 's/\r//'
    exec bash "$0" "$@"
fi

# ============================================================
#  INSTALL MODULE
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
    source "$SCRIPT_DIR/../lib/utils.sh"
fi

source "$SCRIPT_DIR/setup-initial.sh"
source "$SCRIPT_DIR/install-packages.sh"
source "$SCRIPT_DIR/apply-configs.sh"
source "$SCRIPT_DIR/setup-fish.sh"
source "$SCRIPT_DIR/services.sh"

run_install_module() {
    log "Iniciando modulo de instalacao — $(date)"

    install_yay

    install_official_packages
    install_aur_packages

    apply_dots

    setup_fish

    enable_services

    log "Modulo de instalacao concluido."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_install_module
fi