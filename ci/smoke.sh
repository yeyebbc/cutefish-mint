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
calculator_pid=
cleanup() {
  if [[ -n "$calculator_pid" ]]; then
    kill "$calculator_pid" 2>/dev/null || true
    wait "$calculator_pid" 2>/dev/null || true
  fi
  kill "$compositor_pid" 2>/dev/null || true
  wait "$compositor_pid" 2>/dev/null || true
  cat /work/compositor-test.log
  [[ ! -f /work/calculator-test.log ]] || cat /work/calculator-test.log
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
cutefish-calculator > /work/calculator-test.log 2>&1 &
calculator_pid=$!
window_ready=false
for ((attempt=0; attempt<100; attempt++)); do
  kill -0 "$calculator_pid"
  if busctl --user --timeout=2 --json=short call org.cutefish.WindowDebug1 \
      /org/cutefish/WindowDebug1 org.cutefish.WindowDebug1 ListWindows \
      > /work/windows-test.json 2>/dev/null \
    && python3 -c 'import json; w=json.loads(json.load(open("/work/windows-test.json"))["data"][0]); assert any(x["appId"] == "cutefish-calculator" and x["visible"] for x in w)' 2>/dev/null; then
    window_ready=true
    break
  fi
  sleep 0.1
done
[[ "$window_ready" == true ]]
kill "$calculator_pid"
wait "$calculator_pid" 2>/dev/null || true
calculator_pid=
kill -TERM "$compositor_pid"
wait "$compositor_pid"
echo 'Headless compositor mapped the packaged calculator and shut down cleanly.'
