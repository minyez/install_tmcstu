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
  "libxc-5.1.3"
  "v_sim"
  "atat3-44"
  "cp2k-7.1-intel"
  # dependencies for CP2k 7.1
  "libxc-4.3.4-intel"
  "libint-v2.6.0-cp2k-lmax-6-intel"
  "elpa-2019.11.001-intel"
  "libxsmm-1.15-intel"
  # placeholders for repos, without implemented URLs
  "hdf5"
  "netcdf"
)

function is_repo() {
  printf '%s\n' "${repos_names[@]}" | grep -q "$1"
}

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
  ["libxc-5.1.3"]="http://www.tddft.org/programs/libxc/down.php?file=5.1.3/libxc-5.1.3.tar.gz"
  ["atat3-44"]="http://alum.mit.edu/www/avdw/atat/atat3_44.tar.gz"
  # do not use the tar.gz source code for CP2k
  # otherwise will have "No DBCSR submodule available "
  # according to https://www.gitmemory.com/issue/cp2k/cp2k/1302/759304465
  ["cp2k-7.1-intel"]="https://github.com/cp2k/cp2k/releases/download/v7.1.0/cp2k-7.1.tar.bz2"
  ["libxc-4.3.4-intel"]="http://www.tddft.org/programs/libxc/down.php?file=4.3.4/libxc-4.3.4.tar.gz"
  ["elpa-2019.11.001-intel"]="https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2019.11.001/elpa-2019.11.001.tar.gz"
  ["libint-v2.6.0-cp2k-lmax-6-intel"]="https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-6.tgz"
  ["libxsmm-1.15-intel"]="https://www.cp2k.org/static/downloads/libxsmm-1.15.tar.gz"
)

# optional array to set the name of the downloaded file
# if not set, the basename of url will be used.
declare -A repos_outputs
repos_outputs=(
  ["Zotero"]="zotero.tar.bz2"
  ["lapack-3.9.1"]="lapack-3.9.1.tar.gz"
)

declare -A repos_installers
repos_installers=(
  ["VESTA"]="_vesta"
  ["Zotero"]="_zotero"
  ["XCrySDen"]="_xcrysden"
  ["JabRef"]="_install_repo_rpm JabRef"
  ["Chrome"]="_install_repo_rpm Chrome"
  ["cp2k-7.1-intel"]="_cp2k_71_intel"
  ["libxc-4.3.4-intel"]="_libxc_434_intel"
  ["libint-v2.6.0-cp2k-lmax-6-intel"]="_libint_260_cp2k_lm6_intel"
  ["libxsmm-1.15-intel"]="_libxsmm_115_intel"
  ["elpa-2019.11.001-intel"]="_elpa_201911001_intel"
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
  # $3: name of the repository
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
    [[ -d "$target/$dir" ]] && return 0
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
# === $name added by $PROJNAME ===
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
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cd "$REPOS_DIR" || exit 1
  tar -jxf "$output"
  mv "$dir" "$target/"
  cd ..
  sudo dnf -y install gtk3 gtk3-devel
  # set bashrc
  cat >> ~/.bashrc << EOF
# === $name set by $PROJNAME ===
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
    [[ -d "$target/$dir" ]] && return 0
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
# === Xcrysden set by $PROJNAME ===
export PATH="$target/xcrysden-1.6.2:\$PATH"
# === end Xcrysden ===

EOF
}

function _libxsmm_115_intel() {
  target="$1"
  name="libxsmm-1.15-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cd "$REPOS_DIR" || exit 1
  tar -zxf libxsmm-1.15.tar.gz && cd libxsmm-1.15 || exit 1
  make CC=icc FC=ifort PREFIX="$target/$dir" install
  # make test
  # all tests passed, 210428
  cd ..
}

function _libint_260_cp2k_lm6_intel() {
  target="$1"
  name="libint-v2.6.0-cp2k-lmax-6-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cd "$REPOS_DIR" || exit 1
  tar -zxf "$output"
  cd "libint-v2.6.0-cp2k-lmax-6" || exit 1
  make clean && make distclean
  ./configure CC=icc CXX=icpc FC=ifort --prefix="$target/$dir" --enable-fortran
  # avoid install error by only compiling libint_f.F90 in fortran/
  cd fortran && \
    sed 's/default:: fortran_example check_test/default:: libint_f.o #fortran_example check_test/g' Makefile \
    -i_bak && cd ..
  make -j"${MAKE_NPROCS}"
  # correct the makefile to let Fortran module install work
  make install
  cd "$cwd" || exit 1
}

function _elpa_201911001_intel() {
  target="$1"
  name="elpa-2019.11.001-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cd "$REPOS_DIR" || exit 1
  tar -zxf "$output"
  cd elpa-2019.11.001 || exit 1
  ### TODO issue: ifort: specifying -lm before files may supersede the Intel(R) math library and affect performance
  libs=$(echo -L$MKLROOT/lib/intel64 -lmkl_{scalapack_lp64,intel_lp64,sequential,core,blacs_intelmpi_lp64} -lpthread -lm -ldl)
  ./configure FC=mpiifort CC=mpiicc --prefix="$target/$dir" \
    SCALAPACK_LDFLAGS="$libs -Wl,-rpath,$MKLROOT/lib/intel64" \
    SCALAPACK_FCFLAGS="$libs -I$MKLROOT/include"
  make -j"${MAKE_NPROCS}" && make install
  ### TODO make check: 2-stage almost all failed
  ### # TOTAL: 104
  ### # PASS:  28
  ### # SKIP:  56
  ### # XFAIL: 0
  ### # FAIL:  20
  ### # XPASS: 0
  ### # ERROR: 0
  ### 210429, stevezhang, intel 2018.1
  cd "$cwd" || exit 1
}

function _libxc_434_intel() {
  target="$1"
  name="libxc-4.3.4-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  cd "$REPOS_DIR" || return 1
  tar -zxf "$output"
  cd libxc-4.3.4 || return 1
  make clean && ./configure FC=ifort CC=icc F77=ifort --prefix="$target/$dir"
  make && make install
  cd "$cwd" || return 1
}

function _cp2k_71_intel() {
  target="$1"
  name="cp2k-7.1-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  ### check and install dependencies that maybe useful for programs other than cp2k
  ### it would be better to install before hand
  depends=("libxc-4.3.4-intel"
           "libint-v2.6.0-cp2k-lmax-6-intel"
           "elpa-2019.11.001-intel"
           "libxsmm-1.15-intel")
  echo "Will install dependencies: ${depends[*]}"
  if ( { for d in "${depends[@]}"; do ${repos_installers[$d]} "$target"; done } ); then
    cd "$REPOS_DIR" || exit 1
    tar -jxf "$output"
    cd "$cwd" || exit 1
  else
    echo "Fail to install all dependencies of CP2k (intel)"
    return 1
  fi
  mv "$REPOS_DIR/cp2k-7.1" "$target/$dir"
  cd "$target/$dir" || exit 1
  arch=Linux-x86-64-intel
  version=popt
  # shellcheck disable=SC2016
  [[ ! -f arch/$arch.${version}_orig ]] && sed -e\
"s#LIBXC    = /home/users/p02464/libs/libxc/intel/4.0.3#LIBXC    = $target/libxc-4.3.4-intel#g" -e \
"s#LIBINT   = /home/users/p02464/libs/libint/intel/1.1.6#LIBINT   = $target/libint-v2.6.0-cp2k-lmax-6-intel#g" -e \
"s#LIBELPA  = /home/users/p02464/libs/libelpa/intel/2017.05.002#LIBELPA  = $target/elpa-2019.11.001-intel#g" -e \
"s#LIBXSMM  = /home/users/p02464/libxsmm/1.8.3_skl_intel#LIBXSMM  = $target/libxsmm-1.15-intel#g" -e \
's#CC       = cc#CC       = icc#g' -e \
's/-D__ELPA=201705/-D__ELPA=201901/g' -e \
'/$(LIBELPA)/a FCFLAGS += -I$(LIBINT)\/include' -e \
'/LIBS     = -L$(LIBELPA)/a LIBS    += -Wl,-rpath,$(LIBELPA)/lib' -e \
's/elpa-2017.05.002/elpa-2019.11.001/g' -e \
's/-D__LIBINT_MAX_AM=7 -D__LIBDERIV_MAX_AM1=6//g' -e \
's/-lderiv -lint/-lint2/g' \
  -i_orig arch/$arch.$version
  if (make -j"$MAKE_NPROCS" ARCH=$arch VERSION=$version); then
    echo -e "Done make. You may want to test:\n  cd $target/$dir && make ARCH=$arch VERSION=$version numprocs=4 test"
    # regtest by MYZ, 210429, intel 2018.1
    # Number of FAILED  tests 0
    # Number of WRONG   tests 0
    # Number of CORRECT tests 3207
    # Number of NEW     tests 3
    # Total number of   tests 3210
    # GREPME 0 0 3207 3 3210 X
  else
    cd "$cwd" && return 1
  fi
  cd "$cwd" || return 1
#  # set bashrc
#  cat >> ~/.bashrc << EOF
## === $name set by $PROJNAME ===
#export PATH="$target/$dir/exe/$arch:\$PATH"
## === end $name ===
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

