#!/usr/bin/env bash
# shellcheck disable=SC2034

# mainland mirror to replace the official Fedora repo
# to make full use of EDU network
# possible chocies:
#  *empty*: do not replace the official source
#  THU:  mirror maintained by TUNA, Tsinghua University

REPO_SOURCES="THU"
MAKE_NPROCS=1

# location to install repos and pacakges; usually no need to change
PREFIX="$HOME/local/programs"

