#!/usr/bin/env bash
# Exercise the real compositor and its Wayland protocol on CI without a GPU.
set -Eeuo pipefail
export XDG_RUNTIME_DIR
XDG_RUNTIME_DIR=$(mktemp -d)
chmod 700 "$XDG_RUNTIME_DIR"
export WAYLAND_DISPLAY=ci-cutefish
cutefish-compositor --no-drm --no-xwayland --socket "$WAYLAND_DISPLAY" \
  > /work/compositor-test.log 2>&1 &
compositor_pid=$!
cleanup() {
  kill "$compositor_pid" 2>/dev/null || true
  wait "$compositor_pid" 2>/dev/null || true
  cat /work/compositor-test.log
  rm -rf "$XDG_RUNTIME_DIR"
}
trap cleanup EXIT
for ((attempt=0; attempt<100; attempt++)); do
  [[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] && break
  kill -0 "$compositor_pid"
  sleep 0.1
done
test -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
timeout 20s wayland-info > /work/wayland-info.log
grep -q 'xdg_wm_base' /work/wayland-info.log
grep -q 'wl_output' /work/wayland-info.log
kill -TERM "$compositor_pid"
wait "$compositor_pid"
echo 'Headless compositor accepted a Wayland client and shut down cleanly.'
