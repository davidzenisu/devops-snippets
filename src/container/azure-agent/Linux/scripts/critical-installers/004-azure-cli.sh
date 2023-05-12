#!/bin/bash -e
# This script does three fundamental things:
#   1. Add Microsoft's GPG Key has a trusted source of apt packages.
#   2. Add Microsoft's repositories as a source for apt packages.
#   3. Installs the Azure CLI from those repositories. 

curl -sL https://aka.ms/InstallAzureCLIDeb | bash