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
  # CP2k 7.1
  "cp2k-7.1-intel"
  # dependencies for CP2k 7.1
  "spglib-1.16.1-intel"
  "libxc-4.3.4-intel"
  "libint-v2.6.0-cp2k-lmax-6-intel"
  "elpa-2019.11.001-intel"
  "libxsmm-1.15-intel"
  # QE 6.6
  "qe-6.6-intel"
  # dependencies for qe
  "hdf5-1.12.0-intel"
  # BerkeleyGW (BGW) 3.0.1 with parallel HDF5
  "BerkeleyGW-3.0.1-intel"
  # dependencies for BGW
  # BGW 3.0.1 seems to break with MPI support of HDF5 1.12.0, use 1.8.21 is okay
  "hdf5-1.8.21-intel"
  # placeholders for repos, without implemented URLs
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
  # otherwise will have "No DBCSR submodule available"
  # according to https://www.gitmemory.com/issue/cp2k/cp2k/1302/759304465
  ["cp2k-7.1-intel"]="https://github.com/cp2k/cp2k/releases/download/v7.1.0/cp2k-7.1.tar.bz2"
  ["spglib-1.16.1-intel"]="https://github.com/spglib/spglib/archive/refs/tags/v1.16.1.tar.gz"
  ["libxc-4.3.4-intel"]="http://www.tddft.org/programs/libxc/down.php?file=4.3.4/libxc-4.3.4.tar.gz"
  ["elpa-2019.11.001-intel"]="https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2019.11.001/elpa-2019.11.001.tar.gz"
  ["libint-v2.6.0-cp2k-lmax-6-intel"]="https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-6.tgz"
  ["libxsmm-1.15-intel"]="https://www.cp2k.org/static/downloads/libxsmm-1.15.tar.gz"
  # QE 6.6
  ["qe-6.6-intel"]="https://gitlab.com/QEF/q-e/-/archive/qe-6.6/q-e-qe-6.6.tar.gz"
  ["hdf5-1.12.0-intel"]="https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582&refresh=60c992f7c4d191623823095"
  # BGW 3.0.1
  # they use a cloud service with encrypted link, might fail in the future.
  ["BerkeleyGW-3.0.1-intel"]="https://public.boxcloud.com/d/1/b1!J__Pv-LIztAxB9g0xpEDl1WfV0BkIa6A4peDj00tT7Actfb3W_vhlqrwdIrVbNQcpM-fuEg3wIYDa8o23d1fg1xdWVARBgNXY8LHUZhS6ExRkdEplhQkzHSwoLTqcSqmjkw3H74cXRsiClSxfZ0MoUN7CyL9yZ4JAajIs_tSnRoAQPRl5wRhDKRiKYDbt_S-lyeMVoowsL9v9FQUThAFGo2hVWZ6r-OKoukGn8obVtjLtowOmLAb0dNKrfpXNzGsZTgIAbR5BYLH1o1z2EqqQyqyYjG6rPTjKanREDyIXhSzc-gD9l7TQ_Qwh6dMqVCcSyfdnJYyr6vT56GsvfkXsCQ4cXbCb_UC-UJ5n7ca745AQNIlngSQ1jVy9RRzbaggtjegpG2Md01a2f8h19ShBtyx1oh0KKyv7hOUPGLtnDH8AsQ0ZDENseRX2YI2ow8PSI02SKU2KQUUR0b5ecyYxr6yVoKFhF_DdcgQHU7j4aR0QTCmFJ6abLbqo16dMVxzx6J1OgpQQMYVRUymLnagn8eGQqZL8jxgGeZIGvZFB0rtOYfJAeAmuyFsH0ux9D3NoVvbNcHYjs7kew77CkmM-ckqp7oblgFA3TH-NVZpiz4IR0NtE7SKDwfldvwWg47F6rUXTS3MNxUmghZR_TmjTuubSm5IZgKumVTKCgGB2tdRixAVxEp0ZTgXw75Rjt5qg-_Imt59yjoPP6f_3_cLJoQRm8S19AUA5qayyMZVr8_m-OY6ktf-QFblPURV-AeH-0y0TD3gut20OVriZI0ULFPie5rpYBYyHpxrz6FIeYUEEnJCicE_awTVglQMVGr4x-ETN5EOxAzPRm7BRnpZHQULDl9voVyWWdBdmBpwhs3m_O5OFvi8OOp9sQLPhdvjHW-9mv98YRpeXEGCqXvqTDyr-pKqqlHOEkAVjIdYkyu7sTlcuYGO9G976JidYLcp3gxCM-hGmCaucJrqWfVC7vDRdjI1tLlv8D5sWwSwOT7d1Fk9qymnn0VTOZDnYznpAh9WPD4pIRyk8JsluqDjuArQfguoWMualcdvIcGlAQl5PNyQ5Tfo02K8ZHRH8uRzEZH2FHWH-8ALnUWzThex39mJEwkWzrPX1_79mfDshPtTzViezx71SVgM1_fiur7uWTWAXlU7G993dTXKU11fzWj-J1iP3Le5SN58K-akSqr_Oq_FV64x2-UZaWfQX0BniB-pB555ChzwGlo3hKvhI07UJd-bf9MRftqueXJPKziP75rksZJtTJAEj4NsM9Ok6AEBZjK_XIfTecFROSobYgGf8UCSvFkfmFIMGK0btlh60Oy-0zQzvwGUgsI./download"
  ["hdf5-1.8.21-intel"]="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.gz"
)

# optional array to set the name of the downloaded file
# if not set, the basename of url will be used.
declare -A repos_outputs
repos_outputs=(
  ["Zotero"]="zotero.tar.bz2"
  ["lapack-3.9.1"]="lapack-3.9.1.tar.gz"
  ["spglib-1.16.1-intel"]="spglib-1.16.1.tar.gz"
  ["hdf5-1.12.0-intel"]="hdf5-1.12.0.tar.gz"
  ["qe-6.6-intel"]="qe-6.6.tar.gz"
  ["BerkeleyGW-3.0.1-intel"]="BerkeleyGW-3.0.1.tar.gz"
)

declare -A repos_installers
repos_installers=(
  ["VESTA"]="_vesta"
  ["Zotero"]="_zotero"
  ["XCrySDen"]="_xcrysden"
  ["JabRef"]="_install_repo_rpm JabRef"
  ["Chrome"]="_install_repo_rpm Chrome"
  ["cp2k-7.1-intel"]="_cp2k_71_intel"
  ["spglib-1.16.1-intel"]="_spglib_1161_intel"
  ["libxc-4.3.4-intel"]="_libxc_434_intel"
  ["libint-v2.6.0-cp2k-lmax-6-intel"]="_libint_260_cp2k_lm6_intel"
  ["libxsmm-1.15-intel"]="_libxsmm_115_intel"
  ["elpa-2019.11.001-intel"]="_elpa_201911001_intel"
  ["qe-6.6-intel"]="_qe_66_intel"
  ["hdf5-1.12.0-intel"]="_hdf5_1120_intel"
  ["BerkeleyGW-3.0.1-intel"]="_berkeleygw_301_intel"
  ["hdf5-1.8.21-intel"]="_hdf5_1821_intel"
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
  make clean && make CC=icc FC=ifort PREFIX="$target/$dir" install
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
  make distclean
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
  cd "$REPOS_DIR" || return 1
  tar -zxf "$output"
  cd elpa-2019.11.001 || return 1
  [[ -z "$MKLROOT" ]] && { echo "Error: You must set MKLROOT before installing $name"; return 1; }
  ### TODO issue: ifort: specifying -lm before files may supersede the Intel(R) math library and affect performance
  libs=$(echo -L"$MKLROOT/lib/intel64" -lmkl_{scalapack_lp64,intel_lp64,sequential,core,blacs_intelmpi_lp64} -lpthread -lm -ldl)
  # rpath to let mkl automatically loaded when running elpa
  ./configure FC=mpiifort CC=mpiicc --prefix="$target/$dir" \
    SCALAPACK_LDFLAGS="$libs -Wl,-rpath,$MKLROOT/lib/intel64" \
    SCALAPACK_FCFLAGS="$libs -I$MKLROOT/include"
  make clean && make -j"${MAKE_NPROCS}" && make install
  ### NOTE make check: 2-stage almost all failed, but cp2k test looks okay
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
  ./configure FC=ifort CC=icc F77=ifort --prefix="$target/$dir" || return 1
  make || return 1
  make install || return 1
  cd "$cwd" || return 1
}

function _spglib_1161_intel() {
  target="$1"
  name="spglib-1.16.1-intel"
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
  cd spglib-1.16.1 || return 1
  mkdir -p _build && cd _build || return 1
  CC=icc cmake -DCMAKE_INSTALL_PREFIX="" ..
  CC="icc -openmp" make
  make DESTDIR="$target/$dir" install
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
  depends=(
    "libxc-4.3.4-intel"
    "libint-v2.6.0-cp2k-lmax-6-intel"
    "elpa-2019.11.001-intel"
    "libxsmm-1.15-intel"
    # TODO add spglib support, redo the testings
    #"spglib-1.16.1-intel"
  )
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
  # set bashrc
  cat >> ~/.bashrc << EOF
# === $name set by $PROJNAME ===
# dependencies: ${depends[*]}
export PATH="$target/$dir/exe/$arch:\$PATH"
# === end $name ===

EOF
}

function _qe_66_intel() {
  target="$1"
  name="qe-6.6-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  depends=(
    "libxc-4.3.4-intel"
    "hdf5-1.12.0-intel"
  )
  echo "Will install dependencies: ${depends[*]}"
  if ( { for d in "${depends[@]}"; do ${repos_installers[$d]} "$target"; done } ); then
    cd "$REPOS_DIR" || exit 1
    tar -zxf "$output"
    cd "$cwd" || exit 1
  else
    echo "Fail to install all dependencies of QE 6.6 (intel)"
    return 1
  fi
  mv "$REPOS_DIR/q-e-qe-6.6" "$target/$dir"
  cd "$target/$dir" || exit 1
  ./configure prefix="$target/$dir/build" \
    FC=ifort F90=ifort MPIF90=mpiifort CC=icc F77=ifort \
    FCFLAGS="-O2 -I$MKLROOT/include/fftw -I$MKLROOT/include" \
    CFLAGS="-O2 -I$MKLROOT/include/fftw -I$MKLROOT/include" \
    --with-libxc=yes --with-libxc-prefix="$target/libxc-4.3.4-intel" \
    --with-libxc-include="$target/libxc-4.3.4-intel"/include \
    --with-scalapack="intel" \
    --with-hdf5="$target/hdf5-1.12.0-intel"
  make all || return 1
  cd "$cwd" || return 1
  # set bashrc
  cat >> ~/.bashrc << EOF
# === $name set by $PROJNAME ===
# dependencies: ${depends[*]}
export PATH="$target/$dir/bin:\$PATH"
# === end $name ===

EOF
}

function _hdf5_1120_intel() {
  #function_body
  target="$1"
  name="hdf5-1.12.0-intel"
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
  cd hdf5-1.12.0 || return 1
  # NOTE: parallel test fails with t_2Gio. Check results in QE
  ./configure --prefix="$target/$dir" \
    CC=mpiicc CPP="mpiicc -E" FC=mpiifort --enable-parallel \
    --enable-fortran --enable-tools --enable-optimization="high" \
  make && make install
  cd "$cwd" || return 1
  # TODO set bashrc
}

function _hdf5_1821_intel() {
  #function_body
  target="$1"
  name="hdf5-1.8.21-intel"
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
  cd hdf5-1.8.21 || return 1
  ./configure --prefix="$target/$dir" \
    CC=mpiicc CPP="mpiicc -E" FC=mpiifort --enable-parallel \
    --enable-fortran --enable-tools --enable-optimization="high" \
  make && make install
  cd "$cwd" || return 1
}

function _berkeleygw_301_intel() {
  target="$1"
  name="BerkeleyGW-3.0.1-intel"
  dir="$name"
  if (check_repo_install "$target" "$dir" "$name"); then
    output=$(get_repo_output "$name")
    cwd=$(pwd)
  else
    [[ -d "$target/$dir" ]] && return 0
    return 1
  fi
  depends=(
    "hdf5-1.8.21-intel"
  )
  echo "Will install dependencies: ${depends[*]}"
  if ( { for d in "${depends[@]}"; do ${repos_installers[$d]} "$target"; done } ); then
    cd "$REPOS_DIR" || exit 1
    tar -zxf "$output"
    cd "$cwd" || exit 1
  else
    echo "Fail to install all dependencies of $name"
    return 1
  fi
  cd "$REPOS_DIR/BerkeleyGW-3.0.1" || return 1
  echo "Start compiling $name at $REPOS_DIR/BerkeleyGW-3.0.1"
  # write the arch.mk, make sure that cpp preprocessor, intel MPI and MKL are available
  echo "Writing arch.mk"
  cat > arch.mk << EOF
COMPFLAG  = -DINTEL
PARAFLAG  = -DMPI -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5

FCPP    = cpp -C -nostdinc
F90free = mpiifort -free -qopenmp
LINK    = mpiifort -free -qopenmp
FOPTS   = -O3 -g -no-prec-div
#FNOOPTS = -O2 -no-prec-div
FNOOPTS = \$(FOPTS)
MOD_OPT = -module 
INCFLAG = -I

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP  = mpiicc
C_COMP  = mpiicc
C_LINK  = mpiicc
C_OPTS  = -O3 -xAVX -qopenmp
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
HDF5_DIR     = $target/hdf5-1.8.21-intel
HDF5_LDIR    =  \$(HDF5_DIR)/lib
## static link leading to large executable (~1.9G)
#FFTWLIB      = \$(MKLROOT)/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group \$(MKLROOT)/lib/intel64/libmkl_intel_lp64.a \$(MKLROOT)/lib/intel64/libmkl_core.a \\
#               \$(MKLROOT)/lib/intel64/libmkl_intel_thread.a \$(MKLROOT)/lib/intel64/libmkl_blacs_intelmpi_lp64.a -Wl,--end-group -lpthread -lm -ldl -z muldefs
#HDF5LIB      =  \$(HDF5_LDIR)/libhdf5hl_fortran.a \\
#                \$(HDF5_LDIR)/libhdf5_hl.a \\
#                \$(HDF5_LDIR)/libhdf5_fortran.a \\
#                \$(HDF5_LDIR)/libhdf5.a -lz -ldl
# dynamic link (~230M). Remember to add HDF5 and MKL libs to LD_LIBRARY_PATH when use
FFTWLIB      = -L\$(MKLROOT)/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_core \\
               -lmkl_intel_thread -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl -z muldefs
HDF5LIB      = -L\$(HDF5_LDIR) -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz -ldl

FFTWINCLUDE  = \$(MKLROOT)/include/fftw/
HDF5INCLUDE  = \$(HDF5_DIR)/include
LAPACKLIB    = \$(FFTWLIB)
EOF
  make all-flavors || return 1
  make install INSTDIR="$target/$dir" || return 1
  cd "$cwd" || return 1
  echo "Check BGW installation by entering $REPOS_DIR/BerkeleyGW-3.0.1 and run"
  echo "  make check"
}

function _install_repo_rpm() {
  # install a RPM package for external repo
  # $1: the name of repo
  name="$1"
  output=$(get_repo_output "$name")
  [[ ! -f "$REPOS_DIR/$output" ]] && return 1
  sudo rpm -i "$REPOS_DIR/$output"
}

