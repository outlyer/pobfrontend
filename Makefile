DIR := ${CURDIR}
export PATH := $(brew --prefix qt@5)/bin:$(PATH)
export LDFLAGS := -L$(brew --prefix qt@5)/lib
export CPPFLAGS := -I$(brew --prefix qt@5)/include
export PKG_CONFIG_PATH := $(brew --prefix qt@5)/lib/pkgconfig
export VERSION := $(shell awk '/Version number/{print $$2}' FS='"' PathOfBuilding/manifest.xml)

all: frontend pob
	@cp -rf ${DIR}/PathOfBuildingBuild/* ${DIR}/PathOfBuilding.app/Contents/MacOS/
	mkdir -p "${DIR}/PathOfBuilding.app/Contents/Frameworks"
	macdeployqt ${DIR}/PathOfBuilding.app
	sed -e 's/VERSION/${VERSION}/' Info.plist.sh > ${DIR}/PathOfBuilding.app/Contents/Info.plist

sign:
	# Remove extraneous files from .app
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/spec
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/*.exe
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/*.dll
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/runtime/SimpleGraphic
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/docker-compose.yml
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/tests/
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/*.py
	rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/RELEASE.md
	# Sign with the first available identity
	#rm -rf ${DIR}/PathOfBuilding.app/Contents/MacOS/manifest.xml
	codesign --force --deep --sign $$(security find-identity -v -p codesigning | awk 'FNR == 1 {print $$2}') PathOfBuilding.app
	codesign -d -v PathOfBuilding.app

pob: luacurl frontend
	rm -rf PathOfBuildingBuild
	cp -rf PathOfBuilding PathOfBuildingBuild
	patch -p0 -E < devmode-patch.diff
	unzip -qjo PathOfBuildingBuild/runtime-win32.zip -d PathOfBuildingBuild lua/xml.lua lua/base64.lua lua/sha1.lua
	rm PathOfBuildingBuild/runtime-win32.zip
	cp Lua-cURLv3/lcurl.so PathOfBuildingBuild/
	mv PathOfBuildingBuild/src/* PathOfBuildingBuild/ 
	rmdir PathOfBuildingBuild/src

frontend:
	meson setup -Dbuildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build
	ninja -C build install

luacurl:
	$(MAKE) LUA_IMPL="luajit" MAKE_ENV="env MACOSX_DEPLOYMENT_TARGET='11.0'" -C Lua-cURLv3

tools:
	brew install qt@5 luajit meson create-dmg

localtest:
	cp -rf ${DIR}/PathOfBuildingBuild/* ${DIR}/build/

dmg:
	create-dmg ../PathOfBuilding-${VERSION}.dmg PathOfBuilding.app

clean:
	rm -rf PathOfBuildingBuild PathOfBuilding.app build
