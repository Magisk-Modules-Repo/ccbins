unset curl
alias curl="$curlalias$dns"

test_connection() {
  ui_print "- Testing internet connection"
  for i in google,8.8.8.8 baidu,223.5.5.5; do # Google or Ali DNS
    local domain=$(echo $i | cut -d , -f1) ip=$(echo $i | cut -d , -f2)
    if curl --connect-timeout 3 -I https://www.$domain.com --dns-servers $ip | grep -q 'HTTP/.* 200' || ping -q -c 1 -W 1 $i.com >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

download_file() {
  rm -f $MODPATH/dlerror
  local file="$1" url="$2"
  rm -f "$file"
  curl -o "$file" "$url"
  if [ "$file" == "$MODPATH/.checksums" ]; then
    [ "$(head -n1 "$file" 2>/dev/null)" == "checksums.txt" ] && return 0 || return 1
  else
    grep -Fwq "`md5sum "$file" | awk '{print $1}'`" $MODPATH/.checksums || { rm -f "$file"; touch $MODPATH/dlerror; ui_print "Download error for $file!"; }
  fi
}
