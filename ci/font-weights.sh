#!/usr/bin/env bash
# Runs inside CI's private session bus/compositor, with throwaway settings.
set -Eeuo pipefail
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME
font_test_home=$(mktemp -d)
XDG_CONFIG_HOME="$font_test_home/config"
XDG_DATA_HOME="$font_test_home/data"
XDG_CACHE_HOME="$font_test_home/cache"
services_pid=
cleanup() {
  if [[ -n "$services_pid" ]]; then
    kill "$services_pid" 2>/dev/null || true
    wait "$services_pid" 2>/dev/null || true
  fi
  rm -rf "$font_test_home"
}
trap cleanup EXIT
start_services() {
  cutefish-services >> /work/font-service-test.log 2>&1 &
  services_pid=$!
  for ((attempt=0; attempt<100; attempt++)); do
    if busctl --user --timeout=1 get-property org.cutefish.Services /org/cutefish/Services/Appearance \
        org.cutefish.Services.Appearance systemFontWeight >/dev/null 2>&1; then
      return
    fi
    kill -0 "$services_pid"
    sleep 0.1
  done
  cat /work/font-service-test.log
  return 1
}
get_weight() {
  busctl --user --timeout=2 get-property org.cutefish.Services /org/cutefish/Services/Appearance \
    org.cutefish.Services.Appearance "$1"
}
set_weight() {
  busctl --user --timeout=2 call org.cutefish.Services /org/cutefish/Services/Appearance \
    org.cutefish.Services.Appearance "$1" i "$2"
}
start_services
test "$(get_weight systemFontWeight)" = "i 400"
test "$(get_weight systemFixedFontWeight)" = "i 400"
set_weight setSystemFontWeight 700
set_weight setSystemFixedFontWeight 500
test "$(get_weight systemFontWeight)" = "i 700"
test "$(get_weight systemFixedFontWeight)" = "i 500"
set_weight setSystemFontWeight 0
set_weight setSystemFixedFontWeight 1000
test "$(get_weight systemFontWeight)" = "i 700"
test "$(get_weight systemFixedFontWeight)" = "i 500"
python3 - <<'PY'
import configparser, os, pathlib
root=pathlib.Path(os.environ["XDG_CONFIG_HOME"])
config=configparser.ConfigParser()
config.read(root/"cutefish/services.conf")
assert config["Appearance"]["FontWeight"] == "700"
assert config["Appearance"]["FixedFontWeight"] == "500"
gtk=configparser.ConfigParser()
gtk.read(root/"gtk-3.0/settings.ini")
assert " Bold " in gtk["Settings"]["gtk-font-name"]
gsettings=configparser.ConfigParser()
gsettings.read(root/"glib-2.0/settings/keyfile")
assert " Medium " in gsettings["org/gnome/desktop/interface"]["monospace-font-name"]
print("Font weights reached services.conf, GTK settings.ini, and the GSettings keyfile.")
PY
kill "$services_pid"
wait "$services_pid" 2>/dev/null || true
services_pid=
for ((attempt=0; attempt<100; attempt++)); do
  if ! get_weight systemFontWeight >/dev/null 2>&1; then break; fi
  sleep 0.1
done
start_services
test "$(get_weight systemFontWeight)" = "i 700"
test "$(get_weight systemFixedFontWeight)" = "i 500"
set_weight setSystemFontWeight 400
set_weight setSystemFixedFontWeight 400
echo "Font-weight validation, independent settings, and service-restart persistence passed."
