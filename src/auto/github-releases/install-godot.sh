godot_alias="godot-engine"
repo="godotengine/godot"
release_type="linux.x86_64"

readonly RELEASE_INFO="release.json"

sh ./download-latest-release.sh "$repo" "$release_type"
installer_file=$(jq -r '.name' $RELEASE_INFO)
extracted_binary="${installer_file%.*}"
echo $extracted_binary
echo "Extracting zip..."
unzip $installer_file -d .
echo "Deleting zip..."
rm $installer_file
echo "Moving installer to local programs..."
sudo mv $extracted_binary "/usr/local/bin/${godot_alias}"
rm $RELEASE_INFO