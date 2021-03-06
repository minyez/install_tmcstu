#!/usr/bin/env bash

# shellcheck disable=SC2034
PROJNAME="install_tmcstu"

function get_fedora_ver() {
  if [[ ! -f /etc/os-release ]]; then
    echo "Error! Not a Fedora release"
    exit 1
  fi
  awk -F = '/VERSION_ID/ {print $2}' /etc/os-release
}

function ssh_connection_check() {
  ssh -q -o BatchMode=yes  -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$1" 'exit 0'
  return "$?"
}

function get_gh_latest_release() {
  curl -sL "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | cut -d'"' -f4
}

function wget_link_source() {
  # $1: name of source
  # $2: URL link
  # $3: (optional) output file name of the downloaded source
  # returncode 0 if success, otherwise 1
  case $# in
    0|1 ) echo "Error! specify name and url"; exit 1;;
    2 ) name="$1"; url="$2"; output="";;
    * ) name="$1"; url="$2"; output="$3";;
  esac
  if [[ -n "$output" ]]; then
    wget_cmd="wget -nv --show-progress --progress=bar:force $url -O $output"
  else
    wget_cmd="wget -nv --show-progress --progress=bar:force $url"
  fi
  logname=tmcstu_pcws_wget.log
  echo "==wget==: try downloading $name with"
  echo "  $wget_cmd"
  if [[ -f "$output" ]]; then
    echo "Warning: $output found, will skip."
    return 0
  fi
  if ($wget_cmd 2>&1 | tee "$logname"); then
    if [[ -n "$output" ]]; then
      echo "Success: $name downloaded as $output"
    else
      echo "Success: $name downloaded"
    fi
    return 0
  else
    echo "Error: $name not downloaded. See $logname for wget log."
    return 1
  fi
}

function wget_repo() {
  # $1: path to repo directory
  # $2: name
  # $3: url
  # $4: (optional) output. If not specified, use url trimed before last /
  case $# in
    0|1|2 ) echo "Error! must specify repo directory, name and url"; exit 2;;
    3 ) repos_dir="$1"; name="$2"; url="$3"; output="";;
    * ) repos_dir="$1"; name="$2"; url="$3"; output="$4";;
  esac
  cwd="$(pwd)"
  mkdir -p "$repos_dir"
  cd "$repos_dir" || exit 0
  if [[ -z "$output" ]]; then
    output=$(basename "$url")
  fi
  wget_link_source "$name" "$url" "$output"
  cd "$cwd" || exit 0
}

function rsync_pkg() {
  # $1: whether to check conncetion, 0 for not check, otherwise check
  # $2: sync command
  # $3: connection
  # $4: name
  # $5: source
  # $6: output/destination
  case $# in
    6 ) if_check_ssh=$1;
        rsync_opts=$2; connection=$3;
        name=$4; src=$5; dest=$6 ;;
    * ) echo "Error! must specify repo directory, name and url"; exit 2;;
  esac

  if [[ "$if_check_ssh" != 0 ]]; then
    ssh_connection_check "$connection" || { \
      echo "Error: fail to connect to remote under ${connection}."; \
      echo "Please check IP and SSH setup"; \
      return 1; }
  fi

  mkdir -p "$(dirname "$dest")"
  echo "==rsync==: try syncing $name with:"
  echo "    rsync $rsync_opts ${connection}:${src} ${dest}"
  if [[ -e "$dest" ]]; then
    echo "Warning: file/directory $name already synced, will skip"
    return 0
  fi
  # shellcheck disable=SC2086
  if (rsync $rsync_opts "$connection:$src" "$dest"); then
    echo "Success: $name synced"
  else
    echo "Error: $name not synced completely"
    return 1
  fi
}

