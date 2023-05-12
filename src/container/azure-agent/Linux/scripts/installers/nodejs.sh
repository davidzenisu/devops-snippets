#!/bin/bash -e
################################################################################
##  File:  nodejs.sh
##  Desc:  Installs nvm, Node.js LTS and related tooling (Gulp, Grunt, etc.)
################################################################################

# Source the helpers for use with the script
. $HELPER_SCRIPTS/install-helpers.sh

export NVM_DIR="/etc/skel/.nvm"
mkdir $NVM_DIR
VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$VERSION/install.sh | bash
echo 'NVM_DIR=$HOME/.nvm' | tee -a /etc/environment
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' | tee -a /etc/skel/.bash_profile
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# set system node.js as default one
nvm alias default system 

# Install Node.js
defaultVersion=$(get_toolset_value '.node.version')
nvm install $defaultVersion
nvm use $defaultVersion

# Install node modules
node_modules=$(get_toolset_value '.node.modules[]')
npm install -g $node_modules

# fix global modules installation as regular user
# sudo chmod -R 777 /usr/local/lib/node_modules 
# sudo chmod -R 777 /usr/local/bin