FROM ubuntu:22.04

# set build environment

ARG DEBIAN_FRONTEND=noninteractive
ARG SCRIPT_PATH=/scripts
ARG CRITICAL_PATH=$SCRIPT_PATH/critical-installers
ARG INSTALLERS_PATH=$SCRIPT_PATH/installers
ARG HELPER_SCRIPTS=$SCRIPT_PATH/helpers
ARG IMAGEDATA_FILE=$SCRIPT_PATH/imagedata.json
ARG IMAGE_VERSION=0.1

# copy scripts directory

WORKDIR $SCRIPT_PATH
COPY ./scripts .
RUN chmod -R +x .

# run critical installers

WORKDIR /

RUN $CRITICAL_PATH/001-install-base-packages.sh
RUN $CRITICAL_PATH/002-preimagedata.sh
RUN $CRITICAL_PATH/003-configure-environment.sh
RUN $CRITICAL_PATH/004-azure-cli.sh
RUN $CRITICAL_PATH/005-powershellcore.sh
RUN pwsh -f $CRITICAL_PATH/006-Install-PowerShellModules.ps1
RUN pwsh -f $CRITICAL_PATH/007-Install-AzureModules.ps1
RUN $CRITICAL_PATH/008-docker.sh

# run additional installers

RUN $INSTALLERS_PATH/azcopy.sh
RUN $INSTALLERS_PATH/azure-devops-cli.sh
RUN $INSTALLERS_PATH/bicep.sh
RUN $INSTALLERS_PATH/dotnetcore-sdk.sh
RUN $INSTALLERS_PATH/mono.sh
RUN $INSTALLERS_PATH/nodejs.sh

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./files/start.sh .
RUN chmod +x start.sh

ENTRYPOINT ./start.sh ${AZP_STARTUP:-""}