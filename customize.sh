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

[ -f $NVBASE/modules/$MODID/system/bin/ccbins ] && branch="$(grep_prop branch $NVBASE/modules/$MODID/system/bin/ccbins)" || branch=master
wget -qO $MODPATH/install.sh https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/raw/$branch/ccbins_files/install.sh 2>/dev/null
. $MODPATH/install.sh
