# Path of Building (macOS)

[Path of Building](https://github.com/PathOfBuildingCommunity/PathOfBuilding) front end for modern macOS machines. 

## Changes in this version:

- Native arm64 support
- Uses native fonts rather than embedded ones (YMMV)
- Larger initial window
- Some QOL fixes like native help, changelog, etc. 
- Builds saved to Documents instead of homedir

_Caveats_
- Tested on latest stable macOS (13.x Ventura)

## Building

```sh
# Run this only once after installing Homebrew to install dependencies
make tools

# Build the entire app
make

# Optionally sign it for distribution
make sign

# Build a release dmg (requires create-dmg)
make dmg

```

### Build dependencies:

- [Homebrew](https://brew.sh)
- meson
- git
- pkg-config
- ninja
- qt5
- luajit
