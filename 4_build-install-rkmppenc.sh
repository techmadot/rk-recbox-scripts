#!/bin/bash
set -e

# Install Prerequires.
sudo apt install -y build-essential libtool git cmake 

# Install Dependencies.
sudo apt install -y --no-install-recommends libvdpau1 libva-x11-2 libx11-dev ffmpeg \
  libavcodec-extra libavcodec-dev libavutil-dev libavformat-dev \
  libswresample-dev libavfilter-dev libavdevice-dev \
  libass9 libass-dev \
  opencl-headers clinfo

pushd .
DOWNLOAD_DEBDIR=/tmp/rkmppenc-debs
GITHUB_URL=https://github.com/tsukumijima
mkdir -p $DOWNLOAD_DEBDIR; cd $DOWNLOAD_DEBDIR
wget $GITHUB_URL/rockchip-multimedia-config/releases/download/v1.0.2-1/rockchip-multimedia-config_1.0.2-1_all.deb
wget $GITHUB_URL/mpp/releases/download/v1.5.0-1-54f7257/librockchip-mpp1_1.5.0-1_arm64.deb
wget $GITHUB_URL/mpp/releases/download/v1.5.0-1-54f7257/librockchip-mpp-dev_1.5.0-1_arm64.deb
wget $GITHUB_URL/librga/releases/download/v2.2.0-1-fb93eed/librga2_2.2.0-1_arm64.deb
wget $GITHUB_URL/librga/releases/download/v2.2.0-1-fb93eed/librga-dev_2.2.0-1_arm64.deb

sudo apt install -y ./librockchip-mpp1_1.5.0-1_arm64.deb ./librockchip-mpp-dev_1.5.0-1_arm64.deb
sudo apt install -y ./rockchip-multimedia-config_1.0.2-1_all.deb
sudo apt install -y ./librga2_2.2.0-1_arm64.deb ./librga-dev_2.2.0-1_arm64.deb

## libgm を置き換えないため、dummy 付きのものを選択.
LIBMALI_FILE=libmali-valhall-g610-g6p0-dummy_1.9-1_arm64.deb
wget $GITHUB_URL/libmali-rockchip/releases/download/v1.9-1-6f3d407/$LIBMALI_FILE
sudo apt install -y ./$LIBMALI_FILE

popd
rm $DOWNLOAD_DEBDIR/*.deb
rm -r $DOWNLOAD_DEBDIR

# Build rkmppenc
pushd .
RKMPPENC_CLONEDIR=/tmp/rkmppenc
git clone --recursive -b 0.03 https://github.com/rigaya/rkmppenc $RKMPPENC_CLONEDIR
cd $RKMPPENC_CLONEDIR
./configure
make -j4
sudo make install
popd
rm -rf $RKMPPENC_CLONEDIR

# Check result.
clinfo --list
rkmppenc --check-mppinfo
uname -r


