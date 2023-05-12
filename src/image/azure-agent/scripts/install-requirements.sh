# Requirements as mentioned on: https://github.com/actions/runner-images/blob/main/docs/create-image-and-azure-resources.md#build-agent-requirements
echo Generic ubuntu startup script version 1.0.3

# Adding strict mode:
set -e

#OS - Windows/Linux
echo Agent running on $OSTYPE

#packer 1.8.2 or higher - Can be downloaded from https://www.packer.io/downloads
echo Installing packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
sudo apt-get update && sudo apt-get install packer
packer version

#Azure CLI  - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
echo Installing Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#PowerShell 5.0 or higher or PSCore for linux distributes.
echo Installing PowerShell
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
pwsh -Version
rm packages-microsoft-prod.deb -f

#Azure Az Powershell module - https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
echo Installing PowerShell Az module
pwsh -Command "Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force"

#Git for Windows - https://gitforwindows.org/
echo Git for Windows not required on Linux machine