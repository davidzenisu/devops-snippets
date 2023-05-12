#!/bin/bash -e
################################################################################
##  File:  dotnetcore-sdk.sh
##  Desc:  Installs .NET Core SDK
################################################################################

. $HELPER_SCRIPTS/install-helpers.sh

LATEST_DOTNET_PACKAGES=$(get_toolset_value '.dotnet.aptPackages[]')

# Disable telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# There is a versions conflict, that leads to
# Microsoft <-> Canonical repos dependencies mix up.
# Give Microsoft's repo higher priority to avoid collisions.
# See: https://github.com/dotnet/core/issues/7699

cat << EOF > /etc/apt/preferences.d/dotnet
Package: *net*
Pin: origin packages.microsoft.com
Pin-Priority: 1001
EOF

apt-get update

for latest_package in ${LATEST_DOTNET_PACKAGES[@]}; do
    echo "Determing if .NET Core ($latest_package) is installed"
    if ! IsPackageInstalled $latest_package; then
        echo "Could not find .NET Core ($latest_package), installing..."
        apt-get install $latest_package -y
    else
        echo ".NET Core ($latest_package) is already installed"
    fi
done

rm /etc/apt/preferences.d/dotnet

echo "DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1" | sudo tee -a /etc/environment 
echo "DOTNET_NOLOGO=1" | sudo tee -a /etc/environment 
echo "DOTNET_MULTILEVEL_LOOKUP=0" | sudo tee -a /etc/environment 