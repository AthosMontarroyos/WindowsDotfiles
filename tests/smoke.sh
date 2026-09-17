#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
WSL_DIR="$REPO_DIR/WSL"
source "$WSL_DIR/lib/common.sh"
source "$WSL_DIR/modules/packages.sh"
source "$WSL_DIR/modules/dotfiles.sh"
source "$WSL_DIR/modules/services.sh"
test_dir="$(mktemp -d)"
# Temporarios permanecem identificados no fim, sem limpeza recursiva de caminhos calculados.
trap 'printf "Arquivos temporarios de teste: %s\n" "$test_dir"' EXIT

while IFS= read -r -d '' script; do bash -n "$script"; done < <(find "$WSL_DIR" "$REPO_DIR/tests" -name '*.sh' -print0)
bash -n "$WSL_DIR/dots/.bashrc"
if command -v shellcheck >/dev/null; then
    shellcheck -x "$WSL_DIR/install.sh" "$WSL_DIR/bootstrap/archwsl.sh" "$WSL_DIR"/lib/*.sh "$WSL_DIR"/modules/*.sh
else
    warn 'ShellCheck indisponivel; checagem adicional nao executada.'
fi
if command -v fish >/dev/null; then
    fish --no-execute "$WSL_DIR/dots/.config/fish/config.fish"
    fish --no-execute "$WSL_DIR/dots/.config/fish/functions/ff-random.fish"
else
    warn 'Fish indisponivel; sintaxe Fish nao executada.'
fi
bash "$WSL_DIR/install.sh" --dry-run > "$test_dir/core.log"
bash "$WSL_DIR/install.sh" --dry-run --profile dev --with-gpu --with-postgres --with-fonts --with-toolchains > "$test_dir/all.log"
bash "$WSL_DIR/bootstrap/archwsl.sh" --dry-run athos > "$test_dir/bootstrap.log"
if bash "$WSL_DIR/install.sh" --profile unknown > /dev/null 2>&1; then die 'Aceitou perfil invalido.'; fi
if bash "$WSL_DIR/install.sh" --profile > /dev/null 2>&1; then die 'Aceitou perfil ausente.'; fi
if bash "$WSL_DIR/install.sh" --invalid > /dev/null 2>&1; then die 'Aceitou opcao invalida.'; fi
if bash "$WSL_DIR/bootstrap/archwsl.sh" --dry-run root > /dev/null 2>&1; then die 'Aceitou root.'; fi
if bash "$WSL_DIR/bootstrap/archwsl.sh" --dry-run '../bad' > /dev/null 2>&1; then die 'Aceitou usuario invalido.'; fi
! grep -q 'systemctl\|initdb\|postgresql' "$test_dir/core.log" || die 'Core acionou servicos.'
[[ $(grep -c '^\[dry-run\] sudo pacman ' "$test_dir/all.log") == 1 ]] || die 'Transacoes Pacman duplicadas.'
grep -q 'opencode' "$test_dir/core.log"

GROUPS_SELECTED=(core dev containers database gpu fonts toolchains)
load_packages
[[ $(printf '%s\n' "${PACKAGES[@]}" | sort -u | wc -l) -eq ${#PACKAGES[@]} ]] || die 'Pacotes duplicados.'
DRY_RUN=0
sudo() { die 'Modo seco chamou sudo.'; }
export -f sudo die
bash "$WSL_DIR/install.sh" --dry-run --with-containers > /dev/null
unset -f sudo

# Reexecucao do INI deve produzir o mesmo resultado e preservar chaves nao gerenciadas.
printf '[network]\nhostname=custom\n[boot]\ncommand=echo hello\nsystemd=false\n[user]\ndefault=old\n[automount]\nenabled=false\n' > "$test_dir/wsl.conf"
awk -v username=athos -f "$WSL_DIR/lib/wsl-conf.awk" "$test_dir/wsl.conf" > "$test_dir/first.conf"
awk -v username=athos -f "$WSL_DIR/lib/wsl-conf.awk" "$test_dir/first.conf" > "$test_dir/second.conf"
cmp "$test_dir/first.conf" "$test_dir/second.conf"
grep -Fxq 'command=echo hello' "$test_dir/first.conf"
grep -Fxq 'enabled=false' "$test_dir/first.conf"
grep -Fxq 'default=athos' "$test_dir/first.conf"
grep -Fxq 'systemd=true' "$test_dir/first.conf"
awk -v username=athos -f "$WSL_DIR/lib/wsl-conf.awk" /dev/null > "$test_dir/empty.conf"
grep -Fxq '[user]' "$test_dir/empty.conf"
grep -Fxq '[boot]' "$test_dir/empty.conf"

# Executa o aplicador em processo isolado com home temporario.
mkdir -p "$test_dir/home"
printf 'original\n' > "$test_dir/home/.bashrc"
export WSL_DIR
export -f apply_dotfiles log die
env HOME="$test_dir/home" XDG_STATE_HOME="$test_dir/state" bash -c 'set -euo pipefail; DRY_RUN=1; apply_dotfiles' > /dev/null
[[ ! -e "$test_dir/state" ]] || die 'Dry-run criou estado.'
grep -Fxq original "$test_dir/home/.bashrc"
env HOME="$test_dir/home" XDG_STATE_HOME="$test_dir/state" bash -c 'set -euo pipefail; DRY_RUN=0; apply_dotfiles; apply_dotfiles' > /dev/null
cmp "$WSL_DIR/dots/.bashrc" "$test_dir/home/.bashrc"
backup_count=0
while IFS= read -r -d '' backup; do
    grep -Fxq original "$backup"
    backup_count=$((backup_count + 1))
done < <(find "$test_dir/state" -name .bashrc -print0)
[[ "$backup_count" == 1 ]] || die 'Backup nao foi unico ou nao preservou o original.'

# PostgreSQL nunca executa comandos; Docker somente com flag explicita.
run() { printf '%s\n' "$*" >> "$test_dir/commands.log"; }
CONTAINERS=0 POSTGRES=1 GPU=0
configure_services > /dev/null
[[ ! -e "$test_dir/commands.log" ]] || die 'PostgreSQL executou comando.'
CONTAINERS=1
configure_services > /dev/null
grep -Fxq 'sudo systemctl enable --now docker.service' "$test_dir/commands.log"
log 'Smoke tests aprovados.'
