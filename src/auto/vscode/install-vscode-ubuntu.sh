echo Installing dependencies wget and gpg
sudo apt-get install -y wget gpg

echo Downloading, installing, and registering Microsoft key lists
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

echo Installing depenencies from key list
sudo apt install -y apt-transport-https
sudo apt -y update

echo Installing VS Code
sudo apt install -y code # or code-insiders