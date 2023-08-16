#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# We remove the `launch.devMode or` to ensure the user's builds are stored not in
# the binary, but within their user directory
sed -i '' 's/if launch.devMode or .*then/if false then/' src/Modules/Main.lua
# Remove the dev-mode notice
sed -i '' 's/if launch.devMode and GetTime.*then/if false then/' src/Modules/Main.lua

# Remove SSL checks. This fixes a weird problem where cURL doesn't find the
# certificates on M1 Macs. The risk is really low, since the information this
# transfers isn't really sensitive
#SED_COMMAND='s/(easy:setopt_url\(.*\))$/\1; easy:setopt(curl.OPT_SSL_VERIFYPEER, false)/'
#sed -E -i '' "$SED_COMMAND" src/Launch.lua
#sed -E -i '' "$SED_COMMAND" src/Classes/PassiveTree.lua
#sed -E -i '' "$SED_COMMAND" src/Classes/TradeQueryGenerator.lua
#sed -E -i '' "$SED_COMMAND" src/Classes/TreeTab.lua
#sed -E -i '' "$SED_COMMAND" src/Modules/BuildSiteTools.lua
# Do not remove SSL for LaunchInstall and Update as that's more sensitive, but
# also unused.

# Run remaining setup
unzip -jo runtime-win32.zip lua/xml.lua lua/base64.lua lua/sha1.lua
cp ../lcurl.so .
mv src/* .
rmdir src
