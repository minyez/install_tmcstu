#!/usr/bin/env bash
# This file included th names and URLs of packages/files
# on remote server for retrieving and installation

# directory to store retrieved packages. No need to change, basically
PKGS_DIR="pkgs"

# SSH connection, for retriving packages from TMC workstation
# adapt to your own case before ./install_tmcstu.sh pkg
SSH_CONNECTION="username@xxx.xx.xxx.xx"
SSH_CONNECTION="ws"
#
# Note!!!
#   1. You should first make the SSH password-free
#   2. To add port, you can adjust as below
#      SSH_CONNECTION="-p 2022 username@xxx.xx.xxx.xx"

# options for rsync command
# note:
#  1. you must first ensure that connecting to remote server is password-free. This will be checked by ssh_connection_check
#  2. info=progress2 to give a summary of current speed and progress. For old version rsync, one should use --progress instead
#  3. Caveat: may break if the remote server is behind some route such that a port number may be required
#     A workaround: add `-p port ` option in rsync or before the account
rsync_opts="--exclude=*.o --exclude=*.mod --exclude=*.out --exclude=*.pyc --exclude=vasp --exclude=vasp_* -azru --info=progress2 "
#

pkgs_names=(
  # VASP
  "vasp-5.4.4"
  "vasppot-5.4"
  # WIEN2k
  "wien2k-v19.2"
  #"wien2k-v16.1"
  # Intel
  #"intel_xe_2019_update3"
  "intel_xe_2020_update4"
  # Intel licenses (registered under the author, you may need to refresh with your own one)
  "intel_licenses"
  # Gaussian09 e1, may fail due to permission problem
  "g09e1"
  # VMD
  "vmd-1.9.4a51"
  # direct download from VMD website is tricky due to a request of filling a form
  # we retrieve it from the remote server
  # placeholders
)

function is_pkg() {
  printf '%s\n' "${pkgs_names[@]}" | grep -q "$1"
}

# URL can either be the path to the root directory of the pacakge (!!!must end with a backslash!!!)
#         or a path to single file.
# using -a may raise syntax error: invalid arithmetic operator for names having dots
declare -A pkgs_urls
pkgs_urls=(
  ["vasp-5.4.4"]="/opt/software/vasp/5.4.4-16052018-patched/intel/2019.3/"
  ["vasppot-5.4"]="/opt/software/vasp/vasppot-5.4/"
  ["wien2k-v19.2"]="/home/jiangh/WIEN2k_19.2.tar"
  #["wien2k-v16.1"]="/opt/software/wien2k/16.1/intel-2019.3/"
  #["intel_xe_2019_update3"]="/opt/compiler/intel/2019.3/"
  ["intel_xe_2020_update4"]="/opt/compiler/intel/parallel_studio_xe_2020_update4_cluster_edition.tgz"
  ["intel_licenses"]="/opt/intel/licenses/"
  ["g09e1"]="/opt/software/g09e01/"
  ["vmd-1.9.4a51"]="/opt/tool/vmd-1.9.4a51.LINUXAMD64.tar.gz"
)

# name of the output, i.e. destination of rsync
declare -A pkgs_outputs
pkgs_outputs=(
  ["wien2k-v19.2"]="WIEN2K_19.2.tar"
  ["intel_xe_2020_update4"]="intel_xe_2020_update4.tar.gz"
  ["vmd-1.9.4a51"]="vmd-1.9.4a51.tar.gz"
)

declare -A pkgs_installers
pkgs_installers=(
  ["g09e1"]="_g09"
  ["vasp-5.4.4"]="_vasp_544_intel"
  ["intel_xe_2020_update4"]="_intel_xe_20_u4"
  ["intel_licenses"]="_intel_licenses"
)

function get_pkg_output() {
  name=$1
  output="${pkgs_outputs[$name]}"
  [[ -z "$output" ]] && output="$name"
  echo "$output"
}

function check_pkg_install() {
  # check if a package can be installed under a target directory
  # $1: installation target (a directory)
  # $2: name of the directory to install under the target
  # $3: name of the package
  #
  # returns:
  #   0: can be installed
  #   1: should not install. Cases are:
  #      a. target not exist
  #      b. source file not found
  #      c. the directory already found under target
  #
  [[ ! -d "$1" ]] && { echo "Target $1 does not exist"; return 1; }
  [[ -e "$1/$2" ]] && { echo "$2 already moved to $1. Remove to reinstall"; return 1; }
  name="$3"
  output=$(get_pkg_output "$name")
  if [[ ! -e "$PKGS_DIR/$output" ]]; then
    echo -n "Source file of $output is not found under $PKGS_DIR."
    echo -n " Try to retrieve it? [y/N] "
    read -r answer
    if [[ $answer == "y" ]] || [[ $answer == "Y" ]]; then
      url="${pkgs_urls[$name]}"
      if [[ -z "$url" ]]; then
        echo "Warning: URL on remote pkg $name not set"
        return 1
      fi
      rsync_pkg 1 "$rsync_opts" "$SSH_CONNECTION" \
        "$name" "$url" "$PKGS_DIR/$output"
    else
      return 1
    fi
  fi
}

function _g09() {
  #Gaussian09 installer
  target="$1"
  name="g09e1"
  dir="$name"
  if (check_pkg_install "$target" "$dir" "$name"); then
    output=$(get_pkg_output "$name")
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  # change other user permission to make G09 work
  chmod -R o-xr "$PKGS_DIR/$output"
  cp -r "$PKGS_DIR/$output" "$target/$dir"
  # write to bashrc
  # Note!!!: GV not included at present
  cat >> ~/.bashrc << EOF
# === $name set by $PROJNAME ===
export G09ROOT="$target/$output"
export G09BASIS="\$G09ROOT/basis"
export GAUSS_EXEDIR="\$G09ROOT/bsd:\$G09ROOT/local:\$G09ROOT/extras:\$G09ROOT"
export GAUSS_SCRDIR="."
export PATH="\$GAUSS_EXEDIR:\$PATH"
export LD_LIBRARY_PATH="\$GAUSS_EXEDIR:\$LD_LIBRARY_PATH"
# === end $name ===

EOF
}

function _vasp_544_intel() {
  target=$1
  name="vasp-5.4.4"
  dir="$name"
  if (check_pkg_install "$target" "$dir" "$name"); then
    output=$(get_pkg_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cp -r "$PKGS_DIR/$output" "$target/$dir" && cd "$target/$dir" || exit 1
  if ({ make veryclean; make all; }); then
  # bash equivalent to pass in Python
    :
  else
    echo "Something wrong in compiling VASP. Check error log above."
    echo "When break at linking, it is very possible that "
    echo "libfftw3xf_intel.a is missing under MKLROOT/interfaces/fftw3xf. To resolve, try "
    echo ""
    echo "  cd $MKLROOT/interfaces/fftw3xf"
    echo "  make libintel64"
    echo "  cd $target/$dir && make all "
    cd "$cwd" && return 1
  fi
  cat >> ~/.bashrc << EOF
# === $name set by $PROJNAME ===
export PATH="$target/$dir/bin:\$PATH"
# === end $name ===

EOF
  cd "$cwd" || return 1
}

function _intel_licenses() {
  #function_body
  target=$1
  name="intel_licenses"
  dir="$name"
  if (check_pkg_install "$target" "$dir" "$name"); then
    output=$(get_pkg_output "$name")
    cp -a "$PKGS_DIR/$output" "$target/$dir"
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
}

function _intel_xe_20_u4() {
  target=$1
  name="intel_xe_2020_update4"
  dir="$name"
  if (check_pkg_install "$target" "$dir" "$name"); then
    output=$(get_pkg_output "$name")
    cwd=$(pwd)
    if [[ ! -d "$PKGS_DIR/$name" ]]; then
      tar -C "$PKGS_DIR" -zxf "$PKGS_DIR/$output" && mv "$PKGS_DIR/parallel_studio_xe_2020_update4_cluster_edition" "$PKGS_DIR/$name"
    fi
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  echo "You now have all you need to install Intel 2020u4 in $cwd/$PKGS_DIR/$name"
  echo ""
  echo "Unfortunately, you have to install by yourself, by"
  echo "  cd $cwd/$PKGS_DIR/$name && chmod +x install.sh && ./install.sh"
  echo ""
  echo "Note:"
  echo "    1. it would be consistent to install under $target/$dir"
  echo "    2. you may need License to proceed. You can get your own from Intel site, or"
  echo "       obtain from server by ./install_repos_pkgs.sh intel_licenses and find them at $target/intel_licenses"
  echo "    3. after installation, you may find the modulefile 'modulefiles/compilers/intel/2020.4' useful"
  echo ""
  cd "$cwd" || return 1
}
