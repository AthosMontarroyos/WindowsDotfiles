#!/usr/bin/env fish

# Limpa cache de imagens antigas
rm -rf ~/.cache/fastfetch/

# Caminho da pasta com imagens
set IMG_DIR "$HOME/.config/fastfetch/logo"

# Escolhe uma imagem aleatória
set RANDOM_IMG (find $IMG_DIR -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

# Caminho do config
set CONFIG_FILE "$HOME/.config/fastfetch/config.jsonc"

# Atualiza o campo "source" no config.jsonc
sed -i -E "s#(\"source\": \")[^\"]+#\1$RANDOM_IMG#" $CONFIG_FILE

# Executa o fastfetch
fastfetch