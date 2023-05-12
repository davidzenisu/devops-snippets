# $1 ACR registry
# $2 ACR repository
# $3 ACR version tag

echo Building container using packer $(packer --version) and pushing to registry $1
registryCredentials=$(az acr credential show -n $1 -g rg-cq-bicep-sandbox-we | jq)
registryUsername=$(echo "$registryCredentials" | jq -r '.username')
registryPassword=$(echo "$registryCredentials" | jq -r '.passwords[0].value')

echo Logging in with $registryUsername

#packer should be installed
packer build \
    -var "repositoryName=$2" \
    -var "repositoryTag=$3" \
    -var "registryName=kedatest" \
    -var "registryUsername=$registryUsername" \
    -var "registryPassword=$registryPassword" \
    ./agent.pkr.hcl