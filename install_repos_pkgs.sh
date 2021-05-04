#!/usr/bin/env bash
source _common.sh
source extern_repos.sh
source remote_pkgs.sh

# location to install; usually no need to change
prefix="$HOME/local/programs"

function help() {
  echo "$1: Install part of the external repos and software packages into target directory: $prefix"
  echo ""
  echo "Subcommands:"
  echo "  help   : print this message"
  echo "  list   : list packages that can be installed"
  echo "  min    : minimal install"
  echo "  [name] : install repo or package 'name'"
  echo ""
  echo "  dl [all/repos/pkgs/name] : download only"
  echo ""
  echo "Update: 2021-05-04"
  echo ""
  echo "Contributors: MY Zhang"
  echo ""
}

function _install_min() {
  # install repos
  # only install the packages
  # that require no compiler setup
  mins=("VESTA" "Zotero" "XCrySDen" "JabRef")
  echo "Will try to install: ${mins[*]}"
  echo -n "Continue? [y/N] "
  read -r answer
  if [[ "$answer" != "y" ]] && [[ "$answer" != "Y" ]]; then
    echo "Goodbye :)"
    return
  fi
  for name in "${mins[@]}"; do
    _install_one "$name"
  done
}

function _list_all() {
  echo "Repos:"
  for name in "${repos_names[@]}"; do
    installer="${repos_installers[$name]}"
    if [[ -n "$installer" ]]; then
      echo " - $name"
    fi
  done
  echo ""
  echo "Packages:"
  for name in "${pkgs_names[@]}"; do
    installer="${pkgs_installers[$name]}"
    if [[ -n "$installer" ]]; then
      echo " - $name"
    fi
  done
  echo ""
}

function _download_repo() {
  name=$1
  url="${repos_urls[$name]}"
  output="${repos_outputs[$name]}"
  if [[ -z "$url" ]]; then
    echo "Warning: URL on external repo $name not set, skip"
    return
  fi
  wget_repo "$REPOS_DIR" "$name" "$url" "$output"
}

function _download_all_repos() {
  for name in "${repos_names[@]}"; do
    _download_repo "$name"
  done
}

function _retrieve_pkg() {
  # $1: package name
  # $2: if check SSH connection, 0 for do not check
  name=$1
  check_ssh_connection=$2
  url="${pkgs_urls[$name]}"
  output=$(get_pkg_output "$name")
  if [[ -z "$url" ]]; then
    echo "Warning: URL of $name not set, skip"
    return
  fi
  rsync_pkg "$check_ssh_connection" "$rsync_opts" "$SSH_CONNECTION" \
    "$name" "$url" "$PKGS_DIR/$output"
}

function _retrieve_all_pkgs() {
  if (ssh_connection_check "${SSH_CONNECTION}"); then
    for name in "${pkgs_names[@]}"; do
      _retrieve_pkg "$name" 0
    done
  else
    echo "Error: fail to connect to remote under ${SSH_CONNECTION}. Please check IP and SSH setup."
  fi
}

function _download_one() {
  name="$1"
  if (is_repo "$name"); then
    _download_repo "$name"
  elif (is_pkg "$name"); then
    _retrieve_pkg "$name" 1
  else
    echo "$name is not either a repo or pacakge name"
    return 1
  fi
}

function _download_only() {
  function help() {
    echo "require arguments for dowload, e.g."
    echo ""
    echo "  dl all"
    echo "  dl repos"
    echo "  dl pkgs"
    echo "  dl [name of repo/package]"
    echo ""
  }
  opts=("$@")
  if (( $# == 0 )); then
    help
    return 1
  fi
  case ${opts[0]} in
    "all" ) _download_all_repos; _retrieve_all_pkgs;;
    "repos" ) _download_all_repos ;;
    "pkgs" ) _retrieve_all_pkgs;;
    * ) _download_one "${opts[@]}";;
  esac
}

function _install_one() {
  mkdir -p "$prefix"
  name="$1"
  if [[ -n "${repos_installers[$name]}" ]]; then
    ${repos_installers[$name]} "$prefix"
  elif [[ -n "${pkgs_installers[$name]}" ]]; then
    #echo "Installer for $name is not available"
    ${pkgs_installers[$name]} "$prefix"
  else
    return 1
  fi
}

function main() {
  opts=("$@")
  if (( $# == 0 )); then
    help "$0"
  else
    case ${opts[0]} in
      "help" | "h" | "-h" | "--help" ) help "$0" ;;
      "list" | "l" | "-l" | "--list" ) _list_all ;;
      "dl" ) _download_only "${opts[@]:1}";;
      "min"  ) _install_min ;;
      * ) if ( _install_one "$1" ); then \
        echo "Success to install ${opts[0]}"; else \
        echo "Fail to install ${opts[0]}"; exit 1 ; fi;;
    esac
  fi
}

main "$@"

