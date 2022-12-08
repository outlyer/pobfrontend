PoBFrontend
===========

A cross-platform [Path of Building](https://github.com/Openarl/PathOfBuilding) driver.

Building
--------

### Steps to build

```sh
# Run this only once after installing Homebrew to install dependencies
make tools

# Build the entire app
make
```

### Dependencies:

- Qt5
- luajit
- zlib
- opengl
- lua-curl (see below)
- Bitstream-Vera and Liberation TTF fonts. Will work without these but most likely look terrible.

### Build dependencies:

- meson
- pkg-config
- ninja (optional, can tell meson to generate makefiles if you prefer)

### Ensuring old versions of Mac:

By default, the built lcurl.so links to the local version of cURL. Old
versions of cURL on old Macs may be too old to include the relevant functions and run into this error:

```
Error loading main script: error loading module 'lcurl.safe' from file './lcurl.so':
  dlopen(./lcurl.so, 6): Symbol not found: _curl_easy_option_by_id
    Referenced from: ./lcurl.so (which was built for Mac OS X 13.0)
    Expected in: /usr/lib/libcurl.4.dylib
```

To try to fix this issue, we include the libcurl.4.dylib in our app.

We change it in mesonInstaller.sh based on https://stackoverflow.com/a/38709580/319066

- `otool -L lcurl.so` can be used to debug the paths
- `install_name_tool ...` is used to change the paths

## Old manual steps to build:

### Build Lua-Curl:

You need to build [Lua-Curl](https://github.com/Lua-cURL/Lua-cURLv3) for luajit.

Edit the Lua-Curl Makefile:

```diff
@@ -7,7 +7,7 @@ DESTDIR          ?= /
 PKG_CONFIG       ?= pkg-config
 INSTALL          ?= install
 RM               ?= rm
-LUA_IMPL         ?= lua
+LUA_IMPL         ?= luajit
 CC               ?= $(MAC_ENV) gcc
 
 LUA_VERSION       = $(shell $(PKG_CONFIG) --print-provides --silence-errors $(LUA_IMPL))
```
 
Run make. You should get `lcurl.so`.

### Get the PoBFrontend sources:

`git clone https://github.com/philroberts/pobfrontend.git`

### Build:

```bash
meson -Dbuildtype=release pobfrontend build
cd build
ninja
```

Run the thing:

```bash
cd /path/to/PathOfBuilding # <- a pathofbuilding git clone
for f in tree*.zip; do unzip $f;done # <- use the provided tree data because reasons
unzip runtime-win32.zip lua/xml.lua lua/base64.lua lua/sha1.lua
mv lua/*.lua .
rmdir lua
cp /path/to/lcurl.so . # our lcurl.so from earlier
/path/to/build/pobfrontend
```

You can adjust the font size up or down with a command line argument:

```bash
pobfrontend -2
```

### Notes:

I have the following edit in my PathOfBuilding clone, stops it from saving builds even when I tell it not to:

```diff
--- a/Modules/Build.lua
+++ b/Modules/Build.lua
@@ -599,7 +599,7 @@ function buildMode:CanExit(mode)
 end
 
 function buildMode:Shutdown()
-       if launch.devMode and self.targetVersion and not self.abortSave then
+       if false then --launch.devMode and self.targetVersion and not self.abortSave then
                if self.dbFileName then
                        self:SaveDBFile()
                        elseif self.unsaved then
```

###### OS X

On mac you need to invoke meson with some extra flags, per the luajit documentation:

```bash
LDFLAGS="-pagezero_size 10000 -image_base 100000000" meson pobfrontend build
```


