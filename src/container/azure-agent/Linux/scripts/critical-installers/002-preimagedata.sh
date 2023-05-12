#!/bin/bash -e

imagedata_file=$IMAGEDATA_FILE
image_version=$IMAGE_VERSION
os_name=$(lsb_release -ds | sed "s/ /\\\n/g")
os_version=$(lsb_release -rs)
image_label="ubuntu-${os_version}"
version_major=${os_version/.*/}
version_wo_dot=${os_version/./}

cat <<EOF > $imagedata_file
[
  {
    "group": "Operating System",
    "detail": "${os_name}"
  },
  {
    "group": "Runner Image",
    "detail": "Image: ${image_label}\nVersion: ${image_version}"
  }
]
EOF
