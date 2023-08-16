DIR := ${CURDIR}
export PATH := $(brew --prefix qt@5)/bin:$(PATH)
export LDFLAGS := -L$(brew --prefix qt@5)/lib
export CPPFLAGS := -I$(brew --prefix qt@5)/include
export PKG_CONFIG_PATH := $(brew --prefix qt@5)/lib/pkgconfig

all: frontend pob
	pushd build; \
	ninja install; \
	popd; \
	macdeployqt ${DIR}/PathOfBuilding.app; \
	cp ${DIR}/Info.plist.sh ${DIR}/PathOfBuilding.app/Contents/Info.plist; \

# Sign with the first available identity
sign:
	echo 'Signing with the first available identity'; \
	rm -rf PathOfBuilding.app/Contents/MacOS/spec/TestBuilds/3.13; \
	codesign --force --deep --sign $$(security find-identity -v -p codesigning | awk 'FNR == 1 {print $$2}') PathOfBuilding.app; \
	codesign -d -v PathOfBuilding.app

pob: luacurl frontend
	rm -rf PathOfBuildingBuild; \
	cp -rf PathOfBuilding PathOfBuildingBuild; \
	pushd PathOfBuildingBuild; \
	patch -p1 -E < ../devmode-patch.diff; \
	unzip -jo runtime-win32.zip lua/xml.lua lua/base64.lua lua/sha1.lua ;\
	cp ../lcurl.so . ;\
	mv src/* . ;\
	rmdir src ;\
	popd

frontend:
	meson setup -Dbuildtype=release --prefix=${DIR}/PathOfBuilding.app --bindir=Contents/MacOS build

luacurl:
	pushd Lua-cURLv3; \
	make LUA_IMPL="luajit" MAKE_ENV="env MACOSX_DEPLOYMENT_TARGET='11.0'"; \
	mv lcurl.so ../lcurl.so; \
	popd

tools:
	brew install qt@5 luajit zlib meson

clean:
	rm -rf PathOfBuildingBuild PathOfBuilding.app lcurl.so build
