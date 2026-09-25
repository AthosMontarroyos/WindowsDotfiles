function ocimg --description 'Salva a imagem do clipboard para uso no OpenCode'
    for dependency in powershell.exe wslpath clip.exe
        if not type -q $dependency
            echo "ocimg: comando necessario nao encontrado: $dependency" >&2
            return 127
        end
    end

    set -l image_dir .opencode-temp
    set -l image_path "$image_dir/clipboard.png"
    command mkdir -p "$image_dir"; or return 1

    set -l windows_path (wslpath -w "$PWD/$image_path"); or return 1
    powershell.exe -NoLogo -NoProfile -NonInteractive -Sta -Command '& {
        param([string]$OutputPath)
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $image = [System.Windows.Forms.Clipboard]::GetImage()
        if ($null -eq $image) {
            [Console]::Error.WriteLine("ocimg: o clipboard nao contem uma imagem.")
            exit 1
        }
        try {
            $image.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $image.Dispose()
        }
    }' "$windows_path"
    or return $status

    set -l reference "@$image_path"
    printf '%s' "$reference" | clip.exe; or return 1
    echo "Imagem salva em $image_path; referencia copiada: $reference"
end
