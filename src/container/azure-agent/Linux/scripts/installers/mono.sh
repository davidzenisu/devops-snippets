#!/bin/bash -e
################################################################################
##  File:  mono.sh
##  Desc:  Installs Mono
################################################################################

LSB_CODENAME="focal"

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-$LSB_CODENAME main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update
apt-get install -y --no-install-recommends apt-transport-https mono-complete nuget

rm /etc/apt/sources.list.d/mono-official-stable.list
rm -f /etc/apt/sources.list.d/mono-official-stable.list.save
echo "mono https://download.mono-project.com/repo/ubuntu stable-$LSB_CODENAME main" >> $HELPER_SCRIPTS/apt-sources.txt