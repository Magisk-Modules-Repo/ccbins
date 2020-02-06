test_connection() {
  echo "- Testing internet connection"
  (ping -q -c 1 -W 1 google.com >/dev/null 2>&1) && return 0 || return 1
}

if ! $BOOTMODE; then
  ui_print "- Only uninstall is supported in recovery"
  rm -rf $MODPATH $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  abort "Uninstalling!"
fi

# Setup needed applets
set_perm $MODPATH/busybox-$ARCH32 0 0 0755
alias ping="$MODPATH/busybox-$ARCH32 ping"
alias wget="$MODPATH/busybox-$ARCH32 wget"

test_connection || { ui_print " "; abort "!This mod requires internet for install!"; }

if [ -f $NVBASE/modules/$MODID/system/bin/ccbins ]; then
  ui_print "- Using current ccbin files/settings"
  cp -af $NVBASE/modules/$MODID/system $MODPATH
  cp -pf $NVBASE/modules/$MODID/.* $MODPATH 2>/dev/null
else
  mkdir -p $MODPATH/system/bin
fi
ui_print "- Downloading needed files"
wget -O $MODPATH/mod-util.sh https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/master/mod-util.sh 2>/dev/null
wget -O $MODPATH/system/bin/ccbins https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/master/ccbins 2>/dev/null
wget -O $MODPATH/busybox https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/master/busybox/busybox-$ARCH 2>/dev/null
rm -f $MODPATH/busybox-*
set_perm $MODPATH/busybox 0 0 0755
locs="$(grep '^locs=' $MODPATH/system/bin/ccbins)"
eval $locs
for i in $locs; do
  [ -d $MODPATH$i ] && chmod -R 0755 $MODPATH$i
done
