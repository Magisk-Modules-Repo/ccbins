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

test_connection() {
  echo "- Testing internet connection"
  if curl --connect-timeout 3 -I https://www.google.com | grep -q 'HTTP/.* 200'; then
    return 0
  elif curl --connect-timeout 3 -I https://www.baidu.com | grep -q 'HTTP/.* 200'; then
    return 0
  else
    return 1
  fi
}

test_connection || { ui_print " "; abort "!This mod requires internet for install!"; }

[ -f $NVBASE/modules/$MODID/system/bin/ccbins ] && branch="$(grep_prop branch $NVBASE/modules/$MODID/system/bin/ccbins)" || branch=testing
curl -o $MODPATH/install.sh https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/$branch/ccbins_files/install.sh
. $MODPATH/install.sh
