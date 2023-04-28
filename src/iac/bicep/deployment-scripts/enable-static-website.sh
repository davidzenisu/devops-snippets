echo Logging into az cli for tenant $TenantId
az login --service-principal -u $ServicePrincipalClientId -p $ServicePrincipalClientSecret --tenant $TenantId
echo Activating static website access for storage acocunt $StorageAccountName
az storage blob service-properties update \
     --account-name $StorageAccountName \
     --static-website \
     --index-document $IndexDocument \
     --404-document $ErrorDocument
echo Fetching url for static website
staticWebsiteEndpoint=$(az storage account show --name $StorageAccountName --query 'primaryEndpoints.web' | tr -d '"/' | sed s/"https:"//)
echo Found url $staticWebsiteEndpoint
outputJson=$(jq -n -c --arg originHost $staticWebsiteEndpoint  '$ARGS.named')
echo Setting output as $outputJson
echo $outputJson > $AZ_SCRIPTS_OUTPUT_PATH