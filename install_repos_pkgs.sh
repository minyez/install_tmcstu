#!/usr/bin/env bash
source _common.sh
source extern_repos.sh
source remote_pkgs.sh

# location to install; usually no need to change
prefix="$HOME/local/programs"

function help() {
  echo "Install part of the external repos and software packages"
  echo "        into target directory: $prefix"
  echo ""
  echo "Usage:"
  echo "  $1 list : list packages that can be installed"
  echo "  $1 all  : install all basic packages"
  echo "  $1 [repo/pkg name]: install particular repo or package"
  echo ""
  echo "Update: 2021-04-29"
  echo ""
  echo "Contributors: MY Zhang"
  echo ""
}

function _install_all() {
  # install repos
  # only install the packages
  # that require no compiler setup
  all=("VESTA" "Zotero" "XCrySDen" "JabRef" "Chrome")
  echo "Will try to install: ${all[*]}"
  echo -n "Continue? [y/N] "
  read -r answer
  if [[ "$answer" != "y" ]] && [[ "$answer" != "Y" ]]; then
    echo "Goodbye :)"
    return
  fi
  for name in "${all[@]}"; do
    _install_one "$name"
  done
}

function _install_one() {
  #cwd=$(pwd)
  mkdir -p "$prefix"
  #cd "$prefix" || exit 1
  name="$1"
  if [[ -n "${repos_installers[$name]}" ]]; then
    ${repos_installers[$name]} "$prefix"
  elif [[ -n "${pkgs_installers[$name]}" ]]; then
    #echo "Installer for $name is not available"
    ${pkgs_installers[$name]} "$prefix"
  else
    return 1
  fi
  #cd "$cwd" || exit 0
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

function main() {
  opts=("$@")
  if (( $# == 0 )); then
    help "$0"
  else
    case ${opts[0]} in
      "help" | "h" | "-h" | "--help" ) help "$0" ;;
      "list" | "l" | "-l" | "--list" ) _list_all ;;
      "all"  ) _install_all ;;
      * ) if ( _install_one "$1" ); then \
        echo "Success to install ${opts[0]}"; else \
        echo "Fail to install ${opts[0]}"; exit 1 ; fi;;
    esac
  fi
}

main "$@"

