#!/usr/bin/env bash
source _common.sh
source custom.sh

function help() {
  echo "$1: scripts to install a new TMC student PC workstation for research"
  echo ""
  echo "Subcommands:"
  echo "  help   : this help info"
  echo "  init   : minimal install from Fedora repository"
  echo "  cuda   : install necessary components to enable CUDA programming"
  echo "  vc     : verify cuda installation"
  echo "  docker : install Docker engine"
  echo ""
  echo "Notes: "
  echo "  1. it may require sudo when replacing repo source or installing by dnf"
  echo "  2. to retrieve packages from your TMC workstation account, you need a password-free connection"
  echo ""
  echo "TODOs:"
  echo "  1. obtain newest workable hosts and setup for Google and GitHub, etc"
  echo "  2. more tools: conda, pyenv, hdf5, netcdf"
  echo "  3. more science code: pyscf, Wannier90, QE, abinit, deepmd, lammps"
  echo "  4. config scripts, patches, makefile, modulefiles, etc"
  echo ""
  echo "Update: 2021-05-04"
  echo ""
  echo "Contributors: MY Zhang"
  echo ""
}
#  echo "  [ conda  ] : install miniconda"

FEDORA_VERSION=$(get_fedora_ver)
FEDORA_VERSION_MIN=29

function install_pyenv() {
  sudo dnf -y install xz xz-devel make gcc zlib-devel bzip2 bzip2-devel \
    readline-devel sqlite sqlite-devel tk-devel libffi-devel openssl-devel
  #curl https://pyenv.run | bash
}

function install_config_tools() {
  sudo dnf -y install make cmake autoconf automake git binutils binutils-devel\
                gcc gfortran gcc-c++ \
                bzip2 gzip p7zip \
                environment-modules \
                vim-enhanced neovim \
                jq \
                ripgrep fd-find \
                lshw htop
}

function install_network_tools() {
  sudo dnf -y install openssl-devel curl libcurl-devel wget
}

function install_sci_tools () {
  # units for unit conversion
  # (xm)grace, gnuplot, imagemagick, ghostscript, povray for visualization
  # texstudio and texlive for writing tex, texdoc for documentation
  # extra useful packages
  # code (VS code) as a popular IDE
  sudo dnf -y install units \
    grace gnuplot ImageMagick ghostscript povray \
    texstudio texlive texlive-{texdoc,texlive-en-doc,texlive-zh-cn-doc} \
    code
  sudo dnf -y install texlive-{ctex,xcjk2uni} \
    texlive-{physics,abstract,wordcount,xargs,worksheet,wordlike,zhnumber} \
    texlive-{cleveref,overpic,SIunits,a0poster,algorithmicx,algorithms,answers,annotate} \
    texlive-{tabulary,appendix,augie,autonum,autopdf,babel,babelbib} \
    texlive-{tikz-dependency,tikz-3dplot}
  sudo dnf -y install texlive-beamer{,audience}
  sudo dnf -y install texlive-{vancouver,achemso,tocbibind,pkuthss,pkuthss-doc} \
    texlive-biblatex-{chem,chicago,phys,publist}

  return
}

function install_docker() {
  # Docker engine
  sudo dnf -y install dnf-plugins-core
  # add the lateset repo
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf remove -y docker docker-client{,-latest} \
                  docker-{common,latest,logrotate,latest-logrotate} \
                  docker-{selinux,engine,engine-selinux}
  sudo dnf -y install docker-ce docker-ce-cli containerd.io
}

function init_fedora() {

  if (( FEDORA_VERSION < FEDORA_VERSION_MIN )); then
    echo "Error! Too low Fedora release version"
    echo "($FEDORA_VERSION < minimal version $FEDORA_VERSION_MIN)"
    exit 1
  fi

  sudo bash _renew_repo_sources.sh "$REPO_SOURCES"
  sudo dnf -y update
  sudo dnf -y upgrade

  install_network_tools
  install_config_tools
  install_sci_tools

  mkdir -p ~/local/programs
  if [[ ! -d ~/local/modulefiles ]]; then
    cp -r modulefiles ~/local/
  fi

}

function install_cuda() {
  ## Download and install necessary components to enable CUDA programming

  # install kernel headers
  sudo dnf install "kernel-devel-$(uname -r)" "kernel-headers-$(uname -r)"
  # disable the nvidia-driver if existing
  # https://ask.fedoraproject.org/t/dnf-update-nvidia-error/8864/5
  # https://rpmfusion.org/Howto/CUDA#Which_driver_Package
  sudo dnf clean expire-cache
  sudo dnf -y module disable nvidia-driver
  sudo dnf -y install cuda
  # post-installation
  # install samples-dependent libraries
  sudo dnf -y install freeglut-devel libX11-devel libXi-devel libXmu-devel \
    make mesa-libGLU-devel
}

function verify_cuda() {
  # verify the dnf CUDA
  CUDA_PREFIX="/usr/local/cuda"
  CUDA_VERSION="$(awk '/Release Notes/ {print $3}' "$CUDA_PREFIX"/CUDA_Toolkit_Release_Notes.txt | tail -1)"
  # verify installation
  PATH="$CUDA_PREFIX"/bin${PATH:+:${PATH}}
  LD_LIBRARY_PATH="$CUDA_PREFIX"/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
  if [[ ! -d NVIDIA_CUDA-"$CUDA_VERSION"_Samples ]]; then
    cuda-install-samples-"$CUDA_VERSION".sh .
  fi
  cwd="$(pwd)"
  cd NVIDIA_CUDA-"$CUDA_VERSION"_Samples || exit 0
  make
  cd bin/x86_64/linux/release || exit 0
  ./deviceQuery
  # this binary detects workable CUDA-GPU
  # If failed, the CUDA-GPU is not properly set up
  # see the following link and TMCSTU note for configuration.
  # https://forums.developer.nvidia.com/t/solved-run-cuda-on-dedicated-nvidia-gpu-while-connecting-monitors-to-intel-hd-graphics-is-this-possible/47690
  cd "$cwd" || exit 0
}

function main() {
  opts=("$@")
  if (( $# == 0 )); then
    help "$0"
  else
    case ${opts[0]} in
      "help" | "h" | "-h" | "--help" ) help "$0" ;;
      "init"   ) init_fedora ;;
      "cuda"   ) install_cuda;;
      "vc"     ) verify_cuda;;
      "docker" ) install_docker ;;
#      "-p" ) install_pyenv ;;
#      "conda" ) install_conda ;;
      * ) echo "Error: unknown command/option " "${opts[0]}"; \
        help "$0"; exit 1 ;;
    esac
  fi
}

main "$@"

