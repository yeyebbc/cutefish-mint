#!/usr/bin/env bash
# Runs inside an Ubuntu 24.04 container on GitHub Actions, never on the user's PC.
set -Eeuo pipefail
cd /work
export DEBIAN_FRONTEND=noninteractive
export DEB_BUILD_OPTIONS="parallel=4"
export CCACHE_DIR=/work/.ccache
export CCACHE_BASEDIR=/work
export CCACHE_COMPILERCHECK=content
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
packaging/ci/wayland.sh build
apt-get install -y --no-install-recommends build-essential devscripts equivs git xz-utils ccache
ccache --max-size=2G
git config --global --add safe.directory '*'

if [[ "$1" == foundation ]]; then
  packaging/debian/build.sh --install --snapshot cutefish-toolkit cutefish-framework
else
  project="$1"
  mapfile -t foundations < <(find foundation -maxdepth 1 -name '*.deb' ! -name '*-dbgsym_*' -print)
  apt-get install -y --no-install-recommends "${foundations[@]/#/./}"
  mkdir -p packaging/out/debian
  (
    cd packaging/out/debian
    mk-build-deps --install --remove \
      --tool 'apt-get --yes --no-install-recommends' \
      "/work/packaging/debian/$project/debian/control"
  )
  packaging/debian/build.sh --snapshot "$project"
fi
ccache --show-stats
