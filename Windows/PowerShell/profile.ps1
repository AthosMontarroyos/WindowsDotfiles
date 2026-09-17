if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config 'catppuccin_mocha' | Invoke-Expression
}
