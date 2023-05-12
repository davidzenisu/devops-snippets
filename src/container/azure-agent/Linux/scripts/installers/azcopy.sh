#!/bin/bash -e
################################################################################
##  File:  azcopy.sh
##  Desc:  Installs AzCopy
################################################################################

# Install AzCopy10
curl "https://aka.ms/downloadazcopy-v10-linux" -4 -sL -o "/tmp/azcopy.tar.gz"
tar xzf /tmp/azcopy.tar.gz --strip-components=1 -C /tmp
mv /tmp/azcopy /usr/local/bin/azcopy
chmod +x /usr/local/bin/azcopy
# Create azcopy 10 alias for backward compatibility
ln -sf /usr/local/bin/azcopy /usr/local/bin/azcopy10