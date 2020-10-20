# Debug
set -x

if ! $BOOTMODE; then
  ui_print "- Only uninstall is supported in recovery"
  rm -rf $MODPATH $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  abort "Uninstalling!"
fi

# Setup needed busybox applets
set_perm $MODPATH/busybox-$ARCH32 0 0 0755
alias awk="$MODPATH/busybox-$ARCH32 awk"
alias grep="$MODPATH/busybox-$ARCH32 grep"
alias md5sum="$MODPATH/busybox-$ARCH32 md5sum"
alias ping="$MODPATH/busybox-$ARCH32 ping"

# Setup curl - alias must be specified before defining functions that call it
mv -f $MODPATH/curl-$ARCH32 $MODPATH/curl
set_perm $MODPATH/curl 0 0 0755
[ -f $NVBASE/modules/$MODID/doh ] && cp -f $NVBASE/modules/$MODID/doh $MODPATH/doh

. $MODPATH/functions.sh

test_connection || abort "This mod requires internet for install!"
[ -f $NVBASE/modules/$MODID/system/bin/ccbins ] && branch="$(grep_prop branch $NVBASE/modules/$MODID/system/bin/ccbins)" || branch=master

if ! download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt; then
  [ -z "$flag" ] || abort "Unable to download files!"
  echo -e "Alibaba\nhttps://dns.alidns.com/dns-query" > $MODPATH/doh
  flag=" --doh-url $(tail -n1 $MODPATH/doh)"
  [ -d $NVBASE/modules/$MODID ] && cp -f $MODPATH/doh $NVBASE/modules/$MODID/doh
  . $MODPATH/functions.sh
  download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt || abort "Unable to download files!"
fi

download_file $MODPATH/install.sh https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/install.sh
. $MODPATH/install.sh
ui_print "- Installation complete!"
exit 0
