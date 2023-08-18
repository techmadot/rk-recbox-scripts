#!/bin/bash
set -e

cd $HOME
git clone --depth 1 https://github.com/techmadot/docker-mirakurun.git
cd docker-mirakurun

enableDevice()
{
  DEVFILE=$1
  if [ -e "$DEVFILE" ]; then
    echo "${DEVFILE} が存在しました。 docker-compose.yml を更新します"
    escaped=`echo $DEVFILE | sed  -e "s/\//\\\\\\\\\//g"`
    sed  -i -e "s/^#\(.*$escaped\)/\1/g" docker-compose.yml
  fi
}


## 現在接続されているデバイスから docker-compose.yml のデバイス行を編集する.
enableDevice /dev/px4video0
enableDevice /dev/px4video1
enableDevice /dev/px4video2
enableDevice /dev/px4video3
enableDevice /dev/isdb2056video0
enableDevice /dev/pxm1urvideo0
enableDevice /dev/pxs1urvideo0
enableDevice /dev/dvb

echo "Finished"
