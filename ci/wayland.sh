#!/usr/bin/env bash
# CI only. Match the Wayland backport already installed on the target Mint PC.
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates software-properties-common
add-apt-repository --yes --no-update ppa:3v1n0/gamescope
cat > /etc/apt/preferences.d/cutefish-build-wayland <<'EOF'
Package: libwayland-client0 libwayland-server0 libwayland-cursor0 libwayland-egl1 libwayland-bin libwayland-dev
Pin: release o=LP-PPA-3v1n0-gamescope
Pin-Priority: 500

Package: *
Pin: release o=LP-PPA-3v1n0-gamescope
Pin-Priority: -1
EOF
apt-get update
wayland_version=1.24.0-2~24.04.1
apt-get install -y --no-install-recommends \
  "libwayland-client0=$wayland_version" "libwayland-server0=$wayland_version" \
  "libwayland-cursor0=$wayland_version" "libwayland-egl1=$wayland_version"
if [[ "${1:-}" == build ]]; then
  apt-get install -y --no-install-recommends \
    "libwayland-bin=$wayland_version" "libwayland-dev=$wayland_version"
fi
