#!/bin/bash

python3 --version

PY_VERSION="38"
OUTPUT_FILE="AKU.cpython-${PY_VERSION}-darwin.so"
OUTPUT="./lib/candy_editor/AKU/dev/AKU.cpython-${PY_VERSION}-darwin.so"

# clean
if [ -f "./lib/candy_editor/AKU/dev/AKU.cpp" ]; then
  echo "clean AKU.cpp."
  rm -rf ./lib/candy_editor/AKU/dev/AKU.cpp
fi

if [ -f "./lib/candy_editor/AKU/dev/${OUTPUT_FILE}" ]; then
  echo "clean ${OUTPUT_FILE}"
  rm -rf $OUTPUT
fi

if [ -d "./lib/candy_editor/AKU/dev/build" ]; then
  echo "clean build."
  rm -rf ./lib/candy_editor/AKU/dev/build
fi

cd lib/candy_editor/AKU/dev
python3 setup.py build_ext --inplace
cd ../../../..

if [ -f "./lib/candy_editor/AKU/dev/${OUTPUT_FILE}" ]; then
  echo "================"
  echo "AKU.so OK!"
  echo "================"
#  cp -f $OUTPUT ./lib/candy_editor/AKU/AKU.so
  cp -f $OUTPUT ./lib/3rdparty/osx/AKU.so
  rm -rf $OUTPUT
fi
