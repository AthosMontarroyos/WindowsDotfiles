#!/bin/bash

sed -i 's/\r//' "$0"

set -e

# =========================================================
# WSL Arch Linux — Setup inicial
# =========================================================

# Root password
echo "==> Definindo senha do root..."
passwd

# Sudoers para grupo wheel
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Criacao do usuario
read -rp "==> Nome do novo usuario: " USERNAME

useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "==> Definindo senha para $USERNAME..."
passwd "$USERNAME"

# Pacman
setup_pacman() {
    echo "==> Inicializando keyring..."
    pacman-key --init
    pacman-key --populate archlinux

    echo "==> Atualizando sistema..."
    pacman -Sy --needed --noconfirm archlinux-keyring
    pacman -Syu --noconfirm
}

setup_pacman

echo ""
echo "==> Feito. Usuario '$USERNAME' criado com sudo via wheel."
echo "==> Reinicie o WSL para aplicar o usuario padrao."

# Definir usuario padrao via wsl.conf
echo "[user]" >> /etc/wsl.conf
echo "default=$USERNAME" >> /etc/wsl.conf