echo "Downloading release."
echo "Repository: $1"
echo "Release name: $2"

repo=$1
release_name=$2

readonly GITHUB_RELEASES_URL="https://api.github.com/repos/${repo}/releases/latest"
readonly OUTPUT_FILE="installer"

release_info=$(curl -s $GITHUB_RELEASES_URL | jq --arg release $release_name '.assets[] | select(.name | contains($release)) | {file_name: .name, download_url: .browser_download_url}')
file_name=$(echo $release_info | jq -r .file_name)
download_url=$(echo $release_info | jq -r .download_url)
echo "Release found: $file_name"
echo "Downloading release from $download_url..."
wget $download_url -O $file_name -o /dev/null
echo "Writing result to file 'result.json'"
jq -n --arg file_name $file_name '{"name": $file_name}' > release.json