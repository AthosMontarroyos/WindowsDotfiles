#!/bin/bash
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
echo "==> Reinicie o WSL e defina o usuario padrao com:"
echo "    wsl.exe -d <sua-distro> --set-default-user $USERNAME"