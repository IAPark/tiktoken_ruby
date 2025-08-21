#! /usr/bin/env bash

set -o errexit
set -o pipefail
set -x

# check if target is provided as the first argument, and exit if not
if [ -z "$1" ]; then
    echo "No target provided"
    exit 1
fi
TARGET=$1

git clone --depth 1 https://github.com/richfelker/musl-cross-make.git
pushd musl-cross-make

cat > config.mak <<EOF
TARGET = $TARGET

DL_CMD = wget -c --no-verbose -O

# to match the location of the apt-installed cross-compiler packages
OUTPUT = /usr

# Recommended options for faster/simpler build:
COMMON_CONFIG += --disable-nls
GCC_CONFIG += --enable-languages=c,c++
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-multilib
EOF

make -j$(nproc) install

popd

# cleanup
rm -rf musl-cross-make
