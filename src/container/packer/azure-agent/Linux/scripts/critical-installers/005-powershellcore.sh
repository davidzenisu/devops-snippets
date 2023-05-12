#!/bin/bash -e
# This script does two fundamental things:
#   1. Add Microsoft's complete repositories as a source for apt packages.
#   3. Installs the Powershell from those repositories. 

LSB_RELEASE=$(lsb_release -rs)

# Install Microsoft repository
wget https://packages.microsoft.com/config/ubuntu/$LSB_RELEASE/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get -yq update
apt-get -yq dist-upgrade

source $HELPER_SCRIPTS/install-helpers.sh

pwshversion=$(get_toolset_value .pwsh.version)

# Install Powershell
apt-get install -y powershell=$pwshversion*
