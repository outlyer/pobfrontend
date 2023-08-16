PoBFrontend
===========

A cross-platform [Path of Building](https://github.com/PathOfBuildingCommunity/PathOfBuilding) driver.

Building
--------

```sh
# Run this only once after installing Homebrew to install dependencies
make tools

# Build the entire app
make

# Optionally sign it for distribution
make sign
```

### Dependencies:

- [Homebrew](https://brew.sh)
- Qt5
- luajit
- zlib

### Build dependencies:

- meson
- git
- pkg-config
- ninja (optional, can tell meson to generate makefiles if you prefer)

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

