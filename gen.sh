#!/usr/bin/env bash

set -e

ROOT=$(pwd)
DCIMGUI_COMMIT=581c2e909c899c21923c779d4c41ea56ab93bbb4
SOKOL_COMMIT=74bd1cc77022586de08e72b597dfccff4a6465f4
ODIN_C_BINDGEN_COMMIT=f431ebf335c47fb87ae92a3a5f70be2f06221f47
SOKOL_ODIN_COMMIT=2fbaae3c245b2f65c961ef4a38482c81f6bbae6c

git clone https://github.com/floooh/dcimgui
cd dcimgui && git checkout $DCIMGUI_COMMIT && cd $ROOT

git clone https://github.com/floooh/sokol
cd sokol && git checkout $SOKOL_COMMIT && cd $ROOT

git clone https://github.com/karl-zylinski/odin-c-bindgen
cd odin-c-bindgen && git checkout $ODIN_C_BINDGEN_COMMIT && cd $ROOT

git clone https://github.com/floooh/sokol-odin sokol/bindgen/sokol-odin
cd sokol/bindgen/sokol-odin && git checkout $SOKOL_ODIN_COMMIT && cd $ROOT

rm -rf dcimgui/build
cmake -B dcimgui/build -G Ninja dcimgui
cmake --build dcimgui/build

odin build odin-c-bindgen/src -out:bindgen

### cimgui

mkdir -p cimgui
cp dcimgui/src/cimgui.h ./cimgui
cp dcimgui/src/imconfig.h ./cimgui
cp cimgui-bindgen.sjson cimgui
cp foreign.odin cimgui


./bindgen ./cimgui/cimgui-bindgen.sjson
cp dcimgui/build/libimgui.a cimgui/cimgui


# fix #by_ptr stuff
gsed -i -E 's/#by_ptr ([a-zA-Z_][a-zA-Z0-9_]*): \[([0-9]+)\]([a-zA-Z0-9_]+)/\1: ^[\2]\3/g' cimgui/cimgui/cimgui.odin

### sokol

cp gen_odin_imgui.py ./sokol/bindgen
cp sokol/util/sokol_imgui.h sokol/bindgen/sokol-odin/sokol/c
cp sokol_imgui.c sokol/bindgen/sokol-odin/sokol/c
cp build_clibs_macos_with_imgui.sh sokol/bindgen/sokol-odin/sokol/
cd ./sokol/bindgen

python3 gen_odin_imgui.py
cd sokol-odin/sokol
sh build_clibs_macos_with_imgui.sh
cd $ROOT

# copy ./libs/cimgui and ./libs/sokol to odin shared dir
mkdir -p libs
cp -r cimgui/cimgui ./libs/
cp -r sokol/bindgen/sokol-odin/sokol ./libs/

rm -rf cimgui dcimgui odin-c-bindgen sokol bindgen
