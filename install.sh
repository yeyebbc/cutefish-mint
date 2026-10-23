#!/usr/bin/env bash
# Install the CI-built bundle on Linux Mint 22.x / Ubuntu 24.04, amd64.
set -Eeuo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source /etc/os-release
if [[ "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}" != noble ]] \
   || [[ "$(dpkg --print-architecture)" != amd64 ]]; then
  echo 'This bundle requires Linux Mint 22.x or Ubuntu 24.04 on amd64.' >&2
  exit 1
fi
sha256sum --check SHA256SUMS
for library in libwayland-client0 libwayland-server0; do
  version=$(dpkg-query -W -f='${Version}' "$library" 2>/dev/null || true)
  if [[ -z "$version" ]] || ! dpkg --compare-versions "$version" ge 1.23; then
    echo "$library >= 1.23 is required. This build targets the Wayland 1.24 backport already installed on the intended Mint PC." >&2
    exit 1
  fi
done
mapfile -t packages < <(find debs -maxdepth 1 -type f -name '*.deb' -printf './%p\n' | sort)
(( ${#packages[@]} > 0 )) || { echo 'No packages found.' >&2; exit 1; }
sudo apt-get update
sudo apt-get --simulate --no-remove install "${packages[@]}"
sudo apt-get --no-remove install "${packages[@]}"
printf '\nCutefish is installed. Log out, select "Cutefish (Wayland)" on the login screen, and log in.\n'
printf 'Select Cinnamon on the same screen to return to your existing desktop.\n'
