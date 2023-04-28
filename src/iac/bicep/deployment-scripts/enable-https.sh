echo Logging into az cli for tenant $TenantId
az login --service-principal -u $ServicePrincipalClientId -p $ServicePrincipalClientSecret --tenant $TenantId
echo Enabling https certificate for custom domain $CustomDomainName
az cdn custom-domain enable-https --endpoint-name $CdnEndpointName \
                                  -n $CustomDomainName \
                                  --profile-name $CdnProfileName \
                                  --min-tls-version 1.2