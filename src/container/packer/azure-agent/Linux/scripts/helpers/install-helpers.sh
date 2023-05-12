#!/bin/bash -e
################################################################################
##  File:  install-helpers.sh
##  Desc:  Helper functions for installing tools
################################################################################


get_toolset_path() {
    echo "$SCRIPT_PATH/toolset.json"
}

get_toolset_value() {
    local toolset_path=$(get_toolset_path)
    local query=$1
    echo "$(jq -r "$query" $toolset_path)"
}