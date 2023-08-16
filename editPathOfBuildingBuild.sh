#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# We remove the `launch.devMode or` to ensure the user's builds are stored not in
# the binary, but within their user directory
sed -i '' 's/if launch.devMode or .*then/if false then/' src/Modules/Main.lua
# Remove the dev-mode notice
sed -i '' 's/if launch.devMode and GetTime.*then/if false then/' src/Modules/Main.lua

# Run remaining setup
unzip -jo runtime-win32.zip lua/xml.lua lua/base64.lua lua/sha1.lua
cp ../lcurl.so .
mv src/* .
rmdir src
