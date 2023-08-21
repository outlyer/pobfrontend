DIR := ${CURDIR}
export PATH := $(brew --prefix qt@5)/bin:$(PATH)
export LDFLAGS := -L$(brew --prefix qt@5)/lib
export CPPFLAGS := -I$(brew --prefix qt@5)/include
export PKG_CONFIG_PATH := $(brew --prefix qt@5)/lib/pkgconfig
export VERSION := $(shell awk '/Version number/{print $$2}' FS='"' PathOfBuilding/manifest.xml)


all: frontend pob
	ninja -C build install; 
	macdeployqt ${DIR}/PathOfBuilding.app
	sed -e 's/VERSION/${VERSION}/' Info.plist.sh > ${DIR}/PathOfBuilding.app/Contents/Info.plist

# Sign with the first available identity
sign:
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/spec/TestBuilds/3.13
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/*.exe
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/*.dll
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/SimpleGraphic
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/docker-compose.yml
	codesign --force --deep --sign $$(security find-identity -v -p codesigning | awk 'FNR == 1 {print $$2}') PathOfBuilding.app;
	codesign -d -v PathOfBuilding.app

pob: luacurl frontend
	rm -rf PathOfBuildingBuild;
	cp -rf PathOfBuilding PathOfBuildingBuild;
	patch -p0 -E < devmode-patch.diff
	unzip -qjo PathOfBuildingBuild/runtime-win32.zip -d PathOfBuildingBuild lua/xml.lua lua/base64.lua lua/sha1.lua
	rm PathOfBuildingBuild/runtime-win32.zip
	cp lcurl.so PathOfBuildingBuild
	mv PathOfBuildingBuild/src/* PathOfBuildingBuild/ 
	rmdir PathOfBuildingBuild/src

frontend:
	meson setup -Dbuildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build

luacurl:
	$(MAKE) LUA_IMPL="luajit" MAKE_ENV="env MACOSX_DEPLOYMENT_TARGET='11.0'" -C Lua-cURLv3
	mv Lua-cURLv3/lcurl.so lcurl.so

tools:
	brew install qt@5 luajit zlib meson create-dmg

dmg:
	create-dmg ../PathOfBuilding-2.31.2.dmg PathOfBuilding.app

clean:
	rm -rf PathOfBuildingBuild PathOfBuilding.app lcurl.so build
