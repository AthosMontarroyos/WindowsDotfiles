function random_fastfetch
    rm -rf ~/.cache/fastfetch/
    set IMG_DIR "$HOME/.config/fastfetch/logo"

    set RANDOM_IMG (find $IMG_DIR -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

    if test -z "$RANDOM_IMG"
        fastfetch
        return
    end

    fastfetch --logo "$RANDOM_IMG"
end