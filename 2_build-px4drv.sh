#!/bin/bash
set -e

## Orange Pi 5
##   Orangepi5 1.1.6ubuntu jammy server 5.10.110
##   -> rockchip,rk3588s-orangepi-5rockchip,rk3588
##   Armbian_23.5.1 (download)
##   -> kernel-headers インストール無し
##   -> rockchip,rk3588s-orangepi-5rockchip,rk3588
# armbian-config
## Software -> Headers_install
## --> linux-headers-legacy-rockchip-rk3588 インストールする.
# orangepi-config
## ※ 同じように headers_install が可能か？

## OS のリスト
## OrangePi5: Armbian_23.02.2_Orangepi5_jammy_legacy_5.10.110 (使用)



KERNEL_HEADER_DIR=linux-headers-$(uname -r)
GITHUB_CONTENT_BASE_URL=https://raw.githubusercontent.com/torvalds/linux/v5.10


SOC_NAME=$(cat /proc/device-tree/compatible)
echo $SOC_NAME

sudo apt update
sudo apt install -y --no-install-recommends python2
sudo apt install --allow-change-held-packages -y linux-headers-legacy-rockchip-rk3588

OS_TYPE=default
if [ -f /etc/armbian-release ]; then
  OS_TYPE=armbian
  if [ ! -d /usr/src/$KERNEL_HEADER_DIR ]; then
    ## 合っているものが存在していないので自動処理は無理.
    echo "mismatch Kernel header version."
    echo "current: $(uname -r)"
    echo "src headers: $(ls /usr/src)"
    exit
  fi
fi

## module.lds がないなら生成処理
pushd .
if [ ! -f /usr/src/$KERNEL_HEADER_DIR/scripts/module.lds ]; then
  cd /usr/src/$KERNEL_HEADER_DIR/arch/arm64/kernel/vdso
  sudo wget $GITHUB_CONTENT_BASE_URL/arch/arm64/kernel/vdso/vdso.lds.S 
  sudo wget $GITHUB_CONTENT_BASE_URL/arch/arm64/kernel/vdso/vgettimeofday.c
  sudo wget $GITHUB_CONTENT_BASE_URL/arch/arm64/kernel/vdso/note.S
  sudo wget $GITHUB_CONTENT_BASE_URL/arch/arm64/kernel/vdso/sigreturn.S
  sudo wget $GITHUB_CONTENT_BASE_URL/arch/arm64/kernel/vdso/gen_vdso_offsets.sh
  sudo chmod +x gen_vdso_offsets.sh
  cd /usr/src/$KERNEL_HEADER_DIR/lib/vdso
  sudo wget $GITHUB_CONTENT_BASE_URL/lib/vdso/gettimeofday.c
  cd /usr/src/$KERNEL_HEADER_DIR
  sudo make olddefconfig && sudo make modules_prepare
fi
popd

## Build px4drv
sudo apt install -y build-essential libtool git cmake 
git clone -b develop --depth 1 https://github.com/techmadot/px4_drv.git /tmp/px4_drv
cd /tmp/px4_drv
sudo cp -a ./ /usr/src/px4_drv-0.2.1
sudo dkms add px4_drv/0.2.1
sudo dkms install px4_drv/0.2.1

## Firmware
cd fwtool
make
wget http://plex-net.co.jp/plex/pxw3u4/pxw3u4_BDA_ver1x64.zip -O pxw3u4_BDA_ver1x64.zip
unzip -oj pxw3u4_BDA_ver1x64.zip pxw3u4_BDA_ver1x64/PXW3U4.sys
./fwtool PXW3U4.sys it930x-firmware.bin
sudo cp it930x-firmware.bin /lib/firmware/

wget http://www.plex-net.co.jp/plex/px-s1ud/PX-S1UD_driver_Ver.1.0.1.zip
unzip -oj PX-S1UD_driver_Ver.1.0.1.zip PX-S1UD_driver_Ver.1.0.1/x64/amd64/isdbt_rio.inp
sudo cp isdbt_rio.inp /lib/firmware/

echo "================"
echo "  Finished."
echo "================"
