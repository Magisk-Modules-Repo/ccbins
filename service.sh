# This script will be executed in late_start service mode
# More info in the main Magisk thread
(
until [ "$(getprop sys.boot_completed)" == "1" ]; do
  sleep 5
done
[ "$(grep 'cu()' /storage/emulated/0/.aliases 2>/dev/null)" ] || echo -e 'cu() {\n  coreutils --coreutils-prog=${@}\n}' >> /storage/emulated/0/.aliases
)&
