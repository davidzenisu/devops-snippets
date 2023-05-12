#!/bin/bash -e
################################################################################
##  File:  docker.sh
##  Desc:  Installs Docker (Moby) and Docker Compose
################################################################################

# Install docker-compose v1 from releases
URL="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64"
curl -L $URL -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Check to see if docker is already installed
docker_package=moby
echo "Determing if Docker ($docker_package) is installed"
if ! dpkg -S $docker_package &> /dev/null; then
    echo "Docker ($docker_package) was not found. Installing..."
    apt-get remove -y moby-engine moby-cli
    apt-get update
    apt-get install -y moby-engine moby-cli
    apt-get install --no-install-recommends -y moby-buildx
    apt-get install -y moby-compose
else
    echo "Docker ($docker_package) is already installed"
fi