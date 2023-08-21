#!/usr/bin/env bash

cp -rf "${MESON_SOURCE_ROOT}"/PathOfBuildingBuild/* "${MESON_INSTALL_PREFIX}"/Contents/MacOS/
#cp -f "${MESON_SOURCE_ROOT}"/fonts/*.ttf "${MESON_INSTALL_PREFIX}"/Contents/MacOS/

mkdir -p "${MESON_INSTALL_PREFIX}/Contents/Frameworks"
