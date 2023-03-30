registryCredentials=$(az acr credential show -n XXX -g XXX | jq)
registryUsername=$(echo "$registryCredentials" | jq -r '.username')
registryPassword=$(echo "$registryCredentials" | jq -r '.passwords[0].value')

echo Logging in with $registryUsername

#packer should be installed
packer build \
    -var "repositoryName=XXX" \
    -var "repositoryTag=1.0" \
    -var "registryName=kedatest" \
    -var "registryUsername=$registryUsername" \
    -var "registryPassword=$registryPassword" \
    ./agent.pkr.hcl