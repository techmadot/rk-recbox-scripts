#!/bin/bash
set -e
sudo apt update

## 古いものを除外
sudo apt remove docker docker.io

## Compiler & Build Tools
sudo apt install -y --no-install-recommends \
    build-essential libtool git cmake pkg-config automake dkms

## Other Tools
sudo apt install -y --no-install-recommends \
    apt-transport-https ca-certificates \
    software-properties-common curl wget jq python-is-python3 cron rsyslog lm-sensors python3-pip

## Docker-CE のインストール
curl -fsSL https://get.docker.com -o /tmp/install-docker.sh
bash /tmp/install-docker.sh --version 23.0

sudo systemctl enable docker
sudo usermod -aG docker $USER

echo "Relogin is required. Please re-login to apply the new settings."
