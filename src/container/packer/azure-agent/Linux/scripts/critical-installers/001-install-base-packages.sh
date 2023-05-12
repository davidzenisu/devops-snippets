apt-get update
apt-get upgrade -y

apt-get install -y -qq --no-install-recommends jq
. $HELPER_SCRIPTS/install-helpers.sh
packages=$(get_toolset_value .apt[])
for package in $packages; do
    echo "Install $package"
    apt-get install -y --no-install-recommends $package
done