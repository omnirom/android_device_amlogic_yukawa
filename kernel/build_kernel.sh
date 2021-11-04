#!/bin/sh

export AOSP_TOPDIR=`pwd`/../../../..
export PATH=${AOSP_TOPDIR}/prebuilts/clang/host/linux-x86/clang-r416183b1/bin:$PATH
export PATH=${AOSP_TOPDIR}/prebuilts/gas/linux-x86:$PATH
export PATH=${AOSP_TOPDIR}/prebuilts/misc/linux-x86/lz4:$PATH
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export LLVM=1
cd ${AOSP_TOPDIR}/kernel/amlogic/yukawa/

make mrproper
make meson_defconfig
make DTC_FLAGS="-@" -j24
lz4 -f arch/arm64/boot/Image arch/arm64/boot/Image.lz4

export KERN_VER="5.4-mod"
for f in arch/arm64/boot/dts/amlogic/*{g12b,sm1,g12a}*.dtb; do
    cp -v -p $f ${AOSP_TOPDIR}/device/amlogic/yukawa-kernel/${KERN_VER}/
done
cp -v -p arch/arm64/boot/Image.lz4 ${AOSP_TOPDIR}/device/amlogic/yukawa-kernel/${KERN_VER}/
