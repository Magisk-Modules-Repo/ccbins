mv -f $MODPATH/common/busybox-$ARCH32 $MODPATH/busybox
[ -d /data/local/ccbinsbackup ] && { cp -af /data/local/ccbinsbackup/* $MODPATH; cp -af /data/local/ccbinsbackup/.installed $MODPATH; }
