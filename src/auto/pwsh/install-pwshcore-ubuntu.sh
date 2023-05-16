#!/bin/bash
echo Update the list of packages
sudo apt-get update
echo Install pre-requisite packages.
sudo apt-get install -y wget apt-transport-https software-properties-common
echo Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
echo Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
echo Delete the the Microsoft repository GPG keys file
rm packages-microsoft-prod.deb
echo Update the list of packages after we added packages.microsoft.com
sudo apt-get update
echo Install PowerShell
sudo apt-get install -y powershell

echo To start PowerShell run 'pwsh'
#pwsh