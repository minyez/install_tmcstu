#!/usr/bin/env bash

source _common.sh
source extern_repos.sh

function help() {
  echo "Download repositories from external online sources by using wget"
  echo ""
  echo "To add a new target, you only have to add the following to arrays in extern_repos.sh"
  echo ""
  echo "  1. repo name as an identifier to \`repos_names\`"
  echo "  2. repo URL to \`repos_urls\`"
  echo "  3. (optional) output path to \`repos_outputs\`"
  echo ""
  echo "Check existing examples before you want to write one."
  echo ""
  echo "Note that GitHub extracting may fail due to network problem"
}

#function _clash() {
#  # clash appimage for get over GFW
#  clash_ver=$(get_gh_latest_release Dreamacro/clash)
#  echo "Getting clash, version: $clash_ver"
#  if (wget_link_source "clash" \
#      "https://github.com/Dreamacro/clash/releases/$clash_ver/clash-linux-amd64-$clash_ver.gz" \
#      clash.gz); then
#    gunzip clash.gz
#    chmod +x clash
#  fi
#}

function download_extern_repos() {
  for name in "${repos_names[@]}"; do
    unset url
    unset output
    url="${repos_urls[$name]}"
    output="${repos_outputs[$name]}"
    if [[ -z "$url" ]]; then
      echo "Warning: URL on external repo $name not set, skip"
      continue
    fi
    wget_repo "$REPOS_DIR" "$name" "$url" "$output"
  done
  #_zotero
  #_vesta
  #_xcrysden
}

if (( $# == 0 )); then
  help
  exit 0
fi

download_extern_repos "$@"

