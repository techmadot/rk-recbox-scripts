#!/bin/bash
set -e

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y ffmpeg nodejs
sudo npm install -g pm2
sudo pm2 startup

sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp $HOME


## EPGStationに必要なMySQLの準備
cd $HOME
mkdir -p docker-mysql
cd docker-mysql
cat << EOS > docker-compose.yml
version: "3.7"
services:
  mysql:
    image: mariadb:10.4
    volumes:
      - epg-mysql-db:/var/lib/mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_USER: epgstation
      MYSQL_PASSWORD: epgstation
      MYSQL_ROOT_PASSWORD: epgstation
      MYSQL_DATABASE: epgstation
      TZ: "Asia/Tokyo"
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci --performance-schema=false --expire_logs_days=1
    logging:
      options:
        max-size: "10m"
        max-file: "3"
    restart: always
volumes:
  epg-mysql-db:
    driver: local
EOS
### 起動開始
docker compose up -d

## EPGStationのインストールと初期設定
cd $HOME
git clone -b develop --depth 1 https://github.com/techmadot/EPGStation.git
cd EPGStation
npm run all-install
npm run build

### 設定ファイルの準備
cp config/config.yml.template config/config.yml
cp config/operatorLogConfig.sample.yml config/operatorLogConfig.yml
cp config/epgUpdaterLogConfig.sample.yml config/epgUpdaterLogConfig.yml
cp config/serviceLogConfig.sample.yml config/serviceLogConfig.yml
cp config/enc.js.template config/enc.js
### ドロップチェック有効にしておく.
cat << EOS >> config/config.yml
isEnabledDropCheck: true
dropLog: '/home/$USER/EPGStation/drop'
EOS
mkdir -p /home/$USER/EPGStation/drop

### 録画ファイルの格納先
sudo mkdir -p /record-data
sudo chown $USER:$USER /record-data

## EPGStationをPM2の自動起動へ登録
pm2 start dist/index.js --name "EPGStation"
pm2 save

echo "EPGStation Setup Finished."

