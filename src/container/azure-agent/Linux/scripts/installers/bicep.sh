#!/bin/bash -e
################################################################################
##  File:  bicep.sh
##  Desc:  Installs bicep cli
################################################################################

# Install Bicep CLI
curl "https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64" -4 -sL -o "./bicep.bin"
# Mark it as executable
chmod +x ./bicep.bin
# Add bicep to PATH (requires admin)
sudo mv ./bicep.bin /usr/local/bin/bicep