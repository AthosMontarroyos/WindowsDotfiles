function ff-random --description 'Fastfetch com imagem aleatoria, sem modificar o config'
    type -q fastfetch; or return 127
    set -l logo_dir ~/.config/fastfetch/logo
    set -l images
    if test -d "$logo_dir"
        set images (find "$logo_dir" -type f \( -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' \))
    end
    if test (count $images) -gt 0
        set -l image (printf '%s\n' $images | shuf -n 1)
        fastfetch --logo "$image" --logo-type auto $argv
    else
        fastfetch $argv
    end
end
