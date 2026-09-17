#!/usr/bin/env bash

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }
die() { printf '[erro] %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY_RUN )); then
        printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
    else
        "$@"
    fi
}

require_arch() {
    [[ -f /etc/arch-release ]] || die 'Execute dentro do Arch Linux/ArchWSL.'
    command -v pacman >/dev/null || die 'Pacman nao encontrado.'
}
