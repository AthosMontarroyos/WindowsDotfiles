# WindowsRice

My personal Windows and WSL configuration repository.

This repository includes an `autounattend.xml` file for unattended Windows installations, along with custom configurations for Windows, PowerShell, and WSL.

---

# Oh My Posh

Copy the PowerShell profile to:

```text
Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

Paste the profile contents into this file.

---

# Install WSL

## Install ArchWSL

1. Download the latest release of ArchWSL.
2. Credits: https://github.com/yuk7/ArchWSL
3. Extract the downloaded archive.
4. Run `Arch.exe`.
5. Open the WSL instance and follow the initial setup steps.

---

## Run the Pre-Configuration Script

Copy `WSL/Install/Script/preconfig.sh` to your WSL environment and execute:

```bash
sed -i 's/\r//' preconfig.sh && bash preconfig.sh
```

---

## Run the Main Configuration

Copy the `WSL` directory to your home folder and execute:

```bash
sed -i 's/\r//' ~/WindowsRice/WSL/Config/main.sh && bash ~/WindowsRice/WSL/Config/main.sh
```

This script will apply the complete WSL configuration.
