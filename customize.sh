# Debug
set -x

if ! $BOOTMODE; then
  ui_print "- Only uninstall is supported in recovery"
  rm -rf $MODPATH $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  abort "Uninstalling!"
fi

# Setup curl - alias must be specified before defining functions that call it
API=`getprop ro.build.version.sdk`
mv -f $MODPATH/curl-$ARCH32 $MODPATH/curl
set_perm $MODPATH/curl 0 0 0755
[ $API -lt 23 ] && alias curl="$MODPATH/curl -kLs" || alias curl="$MODPATH/curl -Ls"
# Setup needed busybox applets
set_perm $MODPATH/busybox-$ARCH32 0 0 0755
alias grep="$MODPATH/busybox-$ARCH32 grep"
alias ping="$MODPATH/busybox-$ARCH32 ping"

test_connection() {
  echo "- Testing internet connection"
  for i in github google baidu; do
    if curl --connect-timeout 3 -I https://www.$i.com | grep -q 'HTTP/.* 200' || ping -q -c 1 -W 1 $i.com >/dev/null; then
      return 0
    elif curl --connect-timeout 3 -I https://www.$i.com | grep -q 'HTTP/.* 200' || ping -q -c 1 -W 1 $i.com >/dev/null; then
      return 0
    fi
  done
  return 1
}

test_connection || { ui_print " "; abort "!This mod requires internet for install!"; }

[ -f $NVBASE/modules/$MODID/system/bin/ccbins ] && branch="$(grep_prop branch $NVBASE/modules/$MODID/system/bin/ccbins)" || branch=master
curl -o $MODPATH/install.sh https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/$branch/ccbins_files/install.sh
. $MODPATH/install.sh
