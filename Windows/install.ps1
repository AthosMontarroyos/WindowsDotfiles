[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot 'PowerShell/profile.ps1'
# Execute na edicao desejada: Windows PowerShell 5.1 ou PowerShell 7.
$targetPath = $PROFILE.CurrentUserAllHosts
$parentPath = Split-Path -Parent $targetPath
if (Test-Path -LiteralPath $targetPath -PathType Container) {
    throw "O destino e um diretorio: $targetPath"
}
if (Test-Path -LiteralPath $targetPath) {
    if ((Get-FileHash -LiteralPath $sourcePath).Hash -eq (Get-FileHash -LiteralPath $targetPath).Hash) {
        Write-Output "Perfil ja atualizado: $targetPath"
        return
    }
}
if ($PSCmdlet.ShouldProcess($targetPath, 'Aplicar perfil PowerShell com backup do existente')) {
    if (Test-Path -LiteralPath $targetPath) {
        $backupPath = '{0}.backup-{1}-{2}' -f $targetPath, (Get-Date -Format 'yyyyMMdd-HHmmss'), [guid]::NewGuid().ToString('N')
        Move-Item -LiteralPath $targetPath -Destination $backupPath
        Write-Output "Backup: $backupPath"
    }
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath
    Write-Output "Perfil aplicado: $targetPath. Reabra o PowerShell."
}
