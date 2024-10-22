# Debug
set -x

# Detect magisk vs kernelsu
[ -z $KSU ] && { KSU=false; [ $MAGISK_VER_CODE -ge 27000 ] && require_old_magisk; }
$KSU && { [ $KSU_VER_CODE -lt 11184 ] && require_new_ksu; }

if ! $BOOTMODE; then
  ui_print "- Only uninstall is supported in recovery"
  rm -rf $MODPATH $NVBASE/modules_update/$MODID $TMPDIR 2>/dev/null
  abort "Uninstalling!"
fi

# Setup needed busybox applets
if [ -z $ARCH32 ]; then
  case $ARCH in
    arm|arm64) ARCH32=arm;;
    x86|x64) ARCH32=x86;;
  esac
fi
set_perm $MODPATH/busybox-$ARCH32 0 0 0755
alias awk="$MODPATH/busybox-$ARCH32 awk"
alias grep="$MODPATH/busybox-$ARCH32 grep"
alias md5sum="$MODPATH/busybox-$ARCH32 md5sum"
alias ping="$MODPATH/busybox-$ARCH32 ping"

# Setup curl alias - must be specified before defining functions that call them
set_perm $MODPATH/curl-$ARCH32 0 0 0755
[ $API -lt 23 ] && flags="-kLs" || flags="-Ls"
curlalias="$MODPATH/curl-$ARCH32 $flags"
[ -f $NVBASE/modules/$MODID/doh ] && mv -f $NVBASE/modules/$MODID/doh $NVBASE/modules/$MODID/.doh
if [ -f $NVBASE/modules/$MODID/.doh ]; then
  cp -f $NVBASE/modules/$MODID/.doh $MODPATH/.doh
  grep -q 'Cloudflare' $MODPATH/.doh && dns="1.1.1.1,1.0.0.1" || dns="223.5.5.5,223.6.6.6"
  curlalias="$curlalias --doh-url $(tail -n1 $MODPATH/.doh)"
  ui_print "  Using $(head -n1 $MODPATH/.doh) DOH!"
fi

. $MODPATH/functions.sh

test_connection || abort "This mod requires internet for install!"
curlalias="$curlalias --dns-servers $dns"
. $MODPATH/functions.sh

[ -f $NVBASE/modules/$MODID/.branch ] && branch="$(cat $NVBASE/modules/$MODID/.branch)" || branch=master

if ! download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt; then
  [ -f $MODPATH/.doh ] && abort "Unable to download files!"
  echo -e "Alibaba\nhttps://dns.alidns.com/dns-query" > $MODPATH/.doh
  curlalias="$MODPATH/curl-$ARCH32 $flags --doh-url $(tail -n1 $MODPATH/.doh) --dns-servers 223.5.5.5,223.6.6.6"
  . $MODPATH/functions.sh
  download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt || abort "Unable to download files!"
fi

# Keep current mod settings
if [ -f $NVBASE/modules/$MODID/system/bin/ccbins ]; then
  ui_print "- Using current ccbins files/settings"
  rm -f $NVBASE/modules/$MODID/.checksums
  cp -af $NVBASE/modules/$MODID/system $MODPATH
  cp -pf $NVBASE/modules/$MODID/.* $MODPATH 2>/dev/null
else
  mkdir -p $MODPATH/system/bin
fi

# Create folders for tmpfs mounts needed later
$IS64BIT && libfol="system/lib64" || libfol="system/lib"
mktouch $MODPATH/system/etc/placeholder_ccbins
mktouch $MODPATH/$libfol/placeholder_ccbins
$KSU && parts="/system/vendor/bin /system/vendor/xbin" || parts="/vendor/bin /vendor/xbin"
for i in /system/xbin $parts; do
  [ -d "$i" ] || continue
  mktouch $MODPATH$i/placeholder_ccbins
done

# Get mod files
ui_print "- Downloading and installing needed files"
download_file $MODPATH/curl https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/curl/curl-$ARCH
[ -f $MODPATH/dlerror ] && { rm -f $MODPATH/dlerror; cp -f $MODPATH/curl-$ARCH32 $MODPATH/curl; } # This shouldn't happen but just in case
set_perm $MODPATH/curl 0 0 0755

for i in post-fs-data.sh mod-util.sh "system/bin/ccbins"; do
  download_file $MODPATH/$i https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/$(basename $i)
  [ -f $MODPATH/dlerror ] && abort "Unable to download files!"
done
set_perm $MODPATH/system/bin/ccbins 0 0 0755

if curl -I --connect-timeout 3 https://raw.githubusercontent.com/Magisk-Modules-Repo/busybox-ndk/master/busybox-$ARCH-selinux | grep -q 'HTTP/.* 200' || ping -q -c 1 -W 1 $i.com >/dev/null 2>&1; then
  curl -o $MODPATH/busybox https://raw.githubusercontent.com/Magisk-Modules-Repo/busybox-ndk/master/busybox-$ARCH-selinux
else
  cp -f $MODPATH/busybox-$ARCH32 $MODPATH/busybox
fi
set_perm $MODPATH/busybox 0 0 0755

locs="$(grep '^locs=' $MODPATH/system/bin/ccbins)"
eval $locs
for i in $locs; do
  [ -d $MODPATH$i ] && chmod -R 0755 $MODPATH$i
done

install_ncursesw

# Detect TerminalMods module
if [ -d $NVBASE/modules/terminalmods ]; then
  ui_print "- Terminal Modifications"
  ui_print "   Terminal Modifications module detected"
  ui_print "   Now conflicts with ccbins"
  ui_print "   Uninstalling"
  touch $NVBASE/modules/terminalmods/.remove
fi

# Cleanup
rm -f $MODPATH/busybox-* $MODPATH/curl-* $MODPATH/functions.sh $MODPATH/customize.sh $MODPATH/README.md
ui_print "- Installation complete!"
exit 0
