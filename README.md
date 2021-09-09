# Cross Compiled Binaries
Term script to install a collection of ever growing binaries cross compiled for android. Successor and combination of Curl and GNU mods and more. [See here for a list of what's currently included](https://github.com/Zackptg5/Cross-Compiled-Binaries-Android)

## Usage
```
su
ccbins
```

## Change Log
### v8.0 - 9.9.2021
* Fix bug with doh workaround
* Fix for magisk canary
* Update curl and wireguard binaries

### v7.2 - 5.10.2021
* Update wireguard binaries

### v7.1 - 2.13.2021
* Added workaround for curl dns server issues - will work without root now
* Updated module copy of curl

### v7.0 - 10.20.2020
* More connection test fixes
* Added doh workaround for dns poisoning (such as China)

### v6.0 - 10.12.2020
* Further tweaks to connection test

### v5.0 - 10.5.2020
* Switch everything to curl, no need for ping or wget anymore
* Verify proper download of mod files with md5sum

### v4.0 - 9.25.2020
* Go back to using google for ping check - github wasn't working for some people. Fallback to baidu if google fails (for chinese users)
* Use curl rather than wget - some users were having issues with busybox wget

### v3.0 - 9.12.2020
* Updated busybox

### v2.0 - 3.9.2020
* Update boot scripts for recently added binaries
* Add mkshrc stuff
* Add rest of mod to repo - everything should be self-updating now

### v1.0 - 02.05.2020
* Initial Release
