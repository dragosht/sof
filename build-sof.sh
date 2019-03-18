#!/bin/sh

mkdir -p build_apl && cd build_apl &&
  cmake -DTOOLCHAIN=xtensa-apl-elf -DROOT_DIR=`pwd`/../../xtensa-root/xtensa-apl-elf .. &&
  make apollolake_defconfig &&
  make bin -j4
