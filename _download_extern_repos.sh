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
}

if (( $# == 0 )); then
  help
  exit 0
fi

download_extern_repos "$@"

