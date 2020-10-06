# Cross Compiled Binaries
Term script to install a collection of ever growing binaries cross compiled for android. Successor and combination of Curl and GNU mods and more. [See here for a list of what's currently included](https://github.com/Zackptg5/Cross-Compiled-Binaries-Android)

## Usage
```
su
ccbins
```

## Change Log
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
