# WindowsRice
My windows configs

# Execute Pre config WSL
sed -i 's/\r//' preconfig.sh && bash preconfig.sh

# Execute config WSL
sed -i 's/\r//' ~/WindowsRice/WSL/Config/main.sh && bash ~/WindowsRice/WSL/Config/main.sh