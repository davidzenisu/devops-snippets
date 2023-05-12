# Install latest PHP in chocolatey
$installDir = "c:\tools\php"

choco install php -y --params /InstallDir:$installDir --no-progress
choco install composer -y --params "--ia /DEV=$installDir /PHP=$installDir" --no-progress

# update path to extensions and enable curl and mbstring extensions, and enable php openssl extensions.
((Get-Content -path $installDir\php.ini -Raw) -replace ';extension=curl','extension=curl' -replace ';extension=mbstring','extension=mbstring' -replace ';extension_dir = "ext"','extension_dir = "ext"' -replace ';extension=openssl','extension=openssl') | Set-Content -Path $installDir\php.ini
# Set the PHPROOT environment variable.
setx PHPROOT $installDir /M