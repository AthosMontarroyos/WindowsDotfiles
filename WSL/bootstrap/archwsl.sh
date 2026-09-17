#!/usr/bin/env bash
set -euo pipefail

WSL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$WSL_DIR/lib/common.sh"
DRY_RUN=0
username=''
for argument in "$@"; do
    case "$argument" in
        --dry-run) DRY_RUN=1 ;;
        --help|-h) printf 'Uso: bash WSL/bootstrap/archwsl.sh [--dry-run] nome-do-usuario\n'; exit 0 ;;
        --*) die "Opcao desconhecida: $argument" ;;
        *) [[ -z "$username" ]] || die 'Informe somente um usuario.'; username="$argument" ;;
    esac
done
[[ "$username" =~ ^[a-z_][a-z0-9_-]{0,31}$ && "$username" != root ]] || die 'Informe usuario comum valido (letras minusculas, numeros, _ ou -).'
if (( DRY_RUN )); then
    log "[dry-run] Preparar ArchWSL, criar $username se ausente, validar sudo e atualizar wsl.conf."
    log '[dry-run] Nenhuma senha sera modificada; systemd sera habilitado apenas na execucao real.'
    exit 0
fi
require_arch
(( EUID == 0 )) || die 'Execute o bootstrap como root.'
grep -qi microsoft /proc/sys/kernel/osrelease || die 'Este bootstrap e exclusivo para WSL.'
if id "$username" >/dev/null 2>&1; then
    (( $(id -u "$username") >= 1000 )) || die 'Nao use uma conta de sistema.'
fi
if [[ ! -f /etc/pacman.d/gnupg/pubring.gpg ]]; then
    pacman-key --init
    pacman-key --populate archlinux
fi
# Bootstrap separado: instala os requisitos necessarios para executar o instalador como usuario.
pacman -Syu --needed sudo git
if ! id "$username" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$username"
    log "Defina a senha de $username (necessaria para sudo)."
    passwd "$username"
fi

temporary_dir="$(mktemp -d)"
wsl_temp=''
trap 'rm -f -- "$temporary_dir/sudoers"; rmdir -- "$temporary_dir"; if [[ -n "$wsl_temp" ]]; then rm -f -- "$wsl_temp"; fi' EXIT
printf '%s ALL=(ALL:ALL) ALL\n' "$username" > "$temporary_dir/sudoers"
visudo -cf "$temporary_dir/sudoers"
sudo_target="/etc/sudoers.d/90-windows-dotfiles-$username"
[[ ! -L "$sudo_target" ]] || die "Destino sudoers e um link: $sudo_target"
if [[ -e "$sudo_target" ]] && ! cmp -s "$temporary_dir/sudoers" "$sudo_target"; then
    die "Regra sudoers existente diferente: $sudo_target. Revise manualmente."
fi
install -o root -g root -m 0440 "$temporary_dir/sudoers" "$sudo_target"
visudo -c

[[ ! -L /etc/wsl.conf ]] || die '/etc/wsl.conf e um link; revise manualmente.'
wsl_input=/dev/null
[[ ! -f /etc/wsl.conf ]] || wsl_input=/etc/wsl.conf
# Recusa secoes gerenciadas duplicadas para nao reescrever configuracoes ambiguas.
awk '
    /^[ \t]*\[/ {
        name=$0; sub(/^[ \t]*\[/,"",name); sub(/\].*$/,"",name)
        name=tolower(name)
        if ((name=="user" || name=="boot") && ++seen[name]>1) exit 1
    }
' "$wsl_input" || die 'wsl.conf contem secoes user/boot duplicadas; consolide-as antes.'
wsl_temp="$(mktemp /etc/wsl.conf.XXXXXX)"
awk -v username="$username" -f "$WSL_DIR/lib/wsl-conf.awk" "$wsl_input" > "$wsl_temp"
chmod 644 "$wsl_temp"
if [[ -f /etc/wsl.conf ]] && cmp -s "$wsl_temp" /etc/wsl.conf; then
    rm -f -- "$wsl_temp"
else
    if [[ -f /etc/wsl.conf ]]; then
        backup_path="$(mktemp /etc/wsl.conf.backup.XXXXXX)"
        cp -p -- /etc/wsl.conf "$backup_path"
        log "Backup: $backup_path"
    fi
    mv -- "$wsl_temp" /etc/wsl.conf
fi
wsl_temp=''
log 'Bootstrap concluido. No Windows, execute wsl --shutdown e reabra a distribuicao.'
log 'Systemd iniciara os servicos ja habilitados nessa distribuicao.'
