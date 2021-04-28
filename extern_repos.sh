#!/usr/bin/env bash
# This file included th names and URLs of external repositories
# to download

# some infrastructure
source _common.sh

# directory to store downloaded repositories. No need to change, basically
REPOS_DIR="repos"

repos_names=(
  "VESTA"
  "XCrySDen"
  "Zotero"
  "JabRef"
  "Chrome"
  # two lapack releases. The old 3.8.0 is hosted on netlib and should be easily accessible,
  # while the new 3.9.1 is hosted on GitHub and connection may fail.
  "lapack-3.8.0"
  "lapack-3.9.1"
  "scalapack-2.1.0"
  "fftw-3.3.9"
  "libxc-4.3.4"
  "libxc-5.1.3"
  "v_sim"
  "atat3-44"
  # placeholders for repos, without implemented URLs
  "hdf5"
  "netcdf"
  "cp2k-7.1"
)

declare -A repos_urls
repos_urls=(
  ["Chrome"]="https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
  ["VESTA"]="https://jp-minerals.org/vesta/archives/3.5.7/VESTA-gtk3.tar.bz2"
  ["XCrySDen"]="http://www.xcrysden.org/download/xcrysden-1.6.2-linux_x86_64-shared.tar.gz"
  ["Zotero"]="https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64"
  ["JabRef"]="https://github.com/JabRef/jabref/releases/download/v5.1/jabref-5.1-1.x86_64.rpm"
  ["lapack-3.8.0"]="http://www.netlib.org/lapack/lapack-3.8.0.tar.gz"
  ["lapack-3.9.1"]="https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.9.1.tar.gz"
  ["scalapack-2.1.0"]="http://www.netlib.org/scalapack/scalapack-2.1.0.tgz"
  ["v_sim"]="https://gitlab.com/l_sim/v_sim/-/archive/3.8.0/v_sim-3.8.0.tar.gz"
  ["fftw-3.3.9"]="http://www.fftw.org/fftw-3.3.9.tar.gz"
  ["libxc-4.3.4"]="http://www.tddft.org/programs/libxc/down.php?file=4.3.4/libxc-4.3.4.tar.gz"
  ["libxc-5.1.3"]="http://www.tddft.org/programs/libxc/down.php?file=5.1.3/libxc-5.1.3.tar.gz"
  ["atat3-44"]="http://alum.mit.edu/www/avdw/atat/atat3_44.tar.gz"
  ["cp2k-7.1.0"]="https://github.com/cp2k/cp2k/archive/refs/tags/v7.1.0.tar.gz"
)

# optional array to set the name of the downloaded file
# if not set, the basename of url will be used.
declare -A repos_outputs
repos_outputs=(
  ["Zotero"]="zotero.tar.bz2"
  ["lapack-3.9.1"]="lapack-3.9.1.tar.gz"
  ["cp2k-7.1.0"]="cp2k-7.1.0.tar.gz"
)

declare -A repos_installers
repos_installers=(
  ["VESTA"]="_vesta"
  ["Zotero"]="_zotero"
  ["XCrySDen"]="_xcrysden"
  ["JabRef"]="_install_repo_rpm JabRef"
  ["Chrome"]="_install_repo_rpm Chrome"
  ["cp2k-7.1.0"]="_cp2k_710_intel"
)

# write installers here
# each installer should have its first argument as the install target
# except for using _install_repo_rpm
#
function get_repo_output() {
  # get the name of wget output of repository
  name=$1
  output="${repos_outputs[$name]}"
  [[ -z "$output" ]] && output=$(basename "${repos_urls["$name"]}")
  echo "$output"
}

function check_repo_install() {
  # check if a repo can be installed under a target directory
  # $1: installation target (a directory)
  # $2: name of the directory to install under the target
  # $3: name of the repo
  #
  # returns:
  #   0: can be installed
  #   1: should not install. Cases are:
  #      a. target not exist
  #      b. source file not found
  #      c. the directory already found under target
  #
  [[ ! -d "$1" ]] && { echo "Target $1 does not exist"; return 1; }
  [[ -e "$1/$2" ]] && { echo "$2 already installed under $1. Remove to reinstall"; return 1; }
  name="$3"
  output=$(get_repo_output "$name")
  if [[ ! -e "$REPOS_DIR/$output" ]]; then
    echo -n "Source file of $output is not found under $REPOS_DIR."
    echo -n " Try to download it? [y/N] "
    read -r answer
    if [[ $answer == "y" ]] || [[ $answer == "Y" ]]; then
      url="${repos_urls[$name]}"
      output="${repos_outputs[$name]}"
      if [[ -z "$url" ]]; then
        echo "Warning: URL on external repo $name not set"
        return 1
      fi
      wget_repo "$REPOS_DIR" "$name" "$url" "$output"
    else
      return 1
    fi
  fi
}

function _zotero() {
  # Zotero for bibliography
  target="$1"
  dir="Zotero_linux-x86_64"
  name="Zotero"
  if (check_repo_install "$target" "$dir" "$name") then
    output=$(get_repo_output "$name")
  else
    return 1
  fi
  cwd=$(pwd)
  cd "$REPOS_DIR" || exit 1
  tar -jxf "$output"
  mv "$dir" "$target/"
  cd "$target/$dir" || exit 1
  ./set_launcher_icon
  mkdir -p ~/.local/share/applications
  rm -f ~/.local/share/applications/zotero.desktop
  ln -s "$(realpath zotero.desktop)" ~/.local/share/applications/zotero.desktop
  cd "$cwd" || exit 0
  # set bashrc
  cat >> ~/.bashrc << EOF
# === $name added by install_tmcstu ===
export PATH="$target/$dir:\$PATH"
# === end $name ===

EOF
}

function _vesta() {
  # VESTA, require GTK3
  target="$1"
  name="VESTA"
  dir="VESTA-gtk3"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
  else
    return 1
  fi
  cd "$REPOS_DIR" || exit 1
  tar -jxf "$output"
  mv "$dir" "$target/"
  cd ..
  sudo dnf -y install gtk3 gtk3-devel
  # set bashrc
  cat >> ~/.bashrc << EOF
# === $name set by install_tmcstu ===
export PATH="$target/$dir:\$PATH"
# === end $name ===

EOF
}

function _xcrysden() {
  # Xcrysden
  target="$1"
  name="XCrySDen"
  dir="xcrysden-1.6.2"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
  else
    return 1
  fi
  cwd=$(pwd)
  cd "$REPOS_DIR" || exit 1
  tar -zxf "$output"
  mv xcrysden-1.6.2-bin-shared "$dir"
  mv "$dir" "$target/"
  cd "$target/" || exit 1
  # install requirements
  sudo dnf -y install tk tk-devel tcl tcl-devel tcl-togl tcl-togl-devel openbabel openbabel-devel \
    fftw-libs libXmu libXmu-devel libX11-devel mesa-libGLU mesa-libGLU-devel ImageMagick
  # one needs to download 64-bit Togl 2.0 to make it work on Fedora > 30
  FEDORA_VERSION=$(get_fedora_ver)
  if (( FEDORA_VERSION >= 30 )); then
    if (wget_link_source "libTogl2" \
        "https://sourceforge.net/projects/togl/files/Togl/2.0/Togl2.0-8.4-Linux64.tar.gz" \
        "Togl2.0-8.4-Linux.tar.gz"); then
      tar -zxf Togl2.0-8.4-Linux.tar.gz
      sudo cp -n Togl2.0-8.4-Linux/lib/Togl2.0/libTogl2.0.so /usr/lib64/libTogl.so.2
    fi
  fi
  cd "$cwd" || exit 1
  # set bashrc
  cat >> ~/.bashrc << EOF
# === Xcrysden set by install_tmcstu ===
export PATH="$target/xcrysden-1.6.2:\$PATH"
# === end Xcrysden ===

EOF
}

function _cp2k_710_intel() {
  echo "Not Implemented!" && return 1
  target="$1"
  name="cp2k-7.1.0"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
  else
    return 1
  fi
  cwd=$(pwd)
  cd "$REPOS_DIR" || exit 1
  tar -zxf "$output" && mv "$name" "$target/"
  cd "$target/$dir" || exit 1
  cd "$cwd" || exit 1
#  # set bashrc
#  cat >> ~/.bashrc << EOF
## === CP2k 7.1.0 set by install_tmcstu ===
#export PATH="$target/$name:\$PATH"
## === end CP2k 7.1.0 ===
#
#EOF
}

function _install_repo_rpm() {
  # install a RPM package for external repo
  # $1: the name of repo
  name="$1"
  output=$(get_repo_output "$name")
  [[ ! -f "$REPOS_DIR/$output" ]] && return 1
  sudo rpm -i "$REPOS_DIR/$output"
}

