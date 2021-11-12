# Debug
set -x

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

# Setup curl and wg - alias must be specified before defining functions that call them
for i in curl wg wg-quick; do
  mv -f $MODPATH/$i-$ARCH32 $MODPATH/$i
  set_perm $MODPATH/$i 0 0 0755
done
[ -f $NVBASE/modules/$MODID/doh ] && cp -f $NVBASE/modules/$MODID/doh $MODPATH/doh
alias wg="$MODPATH/wg"
alias wg-quick="$MODPATH/wg-quick"
dns=""
if [ $API -lt 23 ]; then
  curlalias="$MODPATH/curl -kLs"
else
  curlalias="$MODPATH/curl -Ls"
  [ $API -ge 31 ] && dns=" --dns-servers 8.8.8.8"
fi
[ -f $MODPATH/doh ] && { curlalias="$curlalias --doh-url $(tail -n1 $MODPATH/doh)"; ui_print "  Using $(head -n1 $MODPATH/doh) DOH!"; }

# Wireguard fix - use wireguard dns servers if specified
if [ "$(pm list packages com.wireguard.android)" ] && [ "$(wg show)" ]; then
  wgint="$(wg show | grep 'interface' | sed 's/interface: //')"
  # Initial log/output from starting a tunnel is only surefire way to get the dns addresses to my knowledge
  for i in $wgint; do
    wg-quick down $i >/dev/null; wg-quick up $i | tee $MODPATH/tmp >/dev/null
    j="$(grep setResolverConfiguration $MODPATH/tmp | awk -F '[()]' '{print $2}' | cut -d '[' -f2 | cut -d ']' -f1 | sed 's/ //g')"
    [ "$j" ] && dnsrvs="$dnsrvs,$j"
    j="$(grep setResolverConfiguration $MODPATH/tmp | awk -F '[()]' '{print $2}' | cut -d '[' -f3 | cut -d ']' -f1 | sed 's/ //g')"
    [ "$j" ] && dnsrvs="$dnsrvs,$j"
  done
  dnsrvs="$(echo "$dnsrvs" | sed 's/^,//')"
  rm -f $MODPATH/tmp
  [ "$dnsrvs" ] && dns=" --dns-servers $dnsrvs"
fi

. $MODPATH/functions.sh

test_connection || abort "This mod requires internet for install!"
[ -f $NVBASE/modules/$MODID/system/bin/ccbins ] && branch="$(grep_prop branch $NVBASE/modules/$MODID/system/bin/ccbins)" || branch=testing

if ! download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt; then
  [ -z "$flag" ] || abort "Unable to download files!"
  echo -e "Alibaba\nhttps://dns.alidns.com/dns-query" > $MODPATH/doh
  curlalias="$curlalias --doh-url $(tail -n1 $MODPATH/doh)"
  [ $API -ge 31 ] && [ -z $dnsrvs ] && dns=" --dns-servers 223.5.5.5"
  [ -d $NVBASE/modules/$MODID ] && cp -f $MODPATH/doh $NVBASE/modules/$MODID/doh
  . $MODPATH/functions.sh
  download_file $MODPATH/.checksums https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/checksums.txt || abort "Unable to download files!"
fi

download_file $MODPATH/install.sh https://raw.githubusercontent.com/Zackptg5/Cross-Compiled-Binaries-Android/$branch/ccbins_files/install.sh
. $MODPATH/install.sh
ui_print "- Installation complete!"
exit 0
