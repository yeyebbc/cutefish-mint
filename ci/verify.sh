#!/usr/bin/env bash
# Verify the full package set on a clean Noble system with Mint's login manager.
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
/work/packaging/ci/wayland.sh
apt-get install -y --no-install-recommends lightdm cinnamon-session dbus-x11 wayland-utils
manager_before=$(readlink -f /etc/systemd/system/display-manager.service || true)
session_before=$(readlink -f /etc/alternatives/x-session-manager || true)
cd /work/bundle
sha256sum --check SHA256SUMS
mapfile -t packages < <(find debs -maxdepth 1 -name '*.deb' -printf './%p\n' | sort)
apt-get --simulate --no-remove install "${packages[@]}"
apt-get --yes --no-remove install "${packages[@]}"
test -z "$(dpkg --audit)"
test -x /usr/bin/cutefish-wayland-session
test -x /usr/bin/cutefish-compositor
test -f /usr/share/wayland-sessions/cutefish-wayland.desktop
test "$manager_before" = "$(readlink -f /etc/systemd/system/display-manager.service || true)"
test "$session_before" = "$(readlink -f /etc/alternatives/x-session-manager || true)"
! dpkg-query -W -f='${Status}' cutefish-dm 2>/dev/null | grep -q 'install ok installed'
! dpkg-query -W -f='${Status}' cutefish-installer 2>/dev/null | grep -q 'install ok installed'
for binary in /usr/bin/cutefish-* /usr/lib/x86_64-linux-gnu/libcutefish*.so*; do
  [[ -f "$binary" ]] || continue
  if ldd "$binary" 2>/dev/null | grep -F 'not found'; then
    echo "Unresolved runtime library: $binary" >&2
    exit 1
  fi
done
dpkg-query -W -f='${Package} ${Version}\n' 'cutefish-*' 'xdg-desktop-portal-cutefish'
dbus-run-session -- bash /work/packaging/ci/smoke.sh
echo 'Clean Ubuntu 24.04 installation, runtime linking, headless compositor, and existing login/session preservation passed.'
