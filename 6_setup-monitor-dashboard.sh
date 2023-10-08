#!/bin/bash
set -e 

## Grafana のユーザー名&パスワード.
GRAFANA_ACCOUNT=admin:admin

cd $HOME
git clone -b v2.0 --depth 1 https://github.com/techmadot/docker-recbox-monitor.git
cd docker-recbox-monitor

## InfluxDB および Grafana の開始
docker compose up -d

## 状態チェックスクリプトを開始.
cd host_app
./setup.sh

## Grafana 起動完了までの待機.
echo "Wait for grafana startup"
sleep 15

## Grafana の DataSource 設定
echo "Register DataSource"
DATASOURCE_CONFIG=$(cat <<EOS
{
  "name":"InfluxDB",
  "type":"influxdb",
  "access":"proxy",
  "url":"http://influxdb:8086",
  "isDefault":true,
  "jsonData":{
    "defaultBucket":"mybucket",
    "httpMode":"POST",
    "organization":"myorgs",
    "version":"Flux"
  },
  "secureJsonData" : {
    "token": "my-recmachine-token"
  },
  "readOnly":false
}
EOS
)

GRAFANA_URL=http://localhost:8090
MIME="Content-Type: application/json"

curl -X POST -H "$MIME" \
  --user $GRAFANA_ACCOUNT \
  -d "$DATASOURCE_CONFIG" $GRAFANA_URL/api/datasources/

## Grafana のダッシュボード設定
cd ../misc
echo 
echo "Register Dashboard"
jq '{ "dashboard": . }' dashboard_auto.json | curl -X POST -H "$MIME" \
  --user $GRAFANA_ACCOUNT $GRAFANA_URL/api/dashboards/db -d @-

echo "Monitoring Dashboard Setup Finished."
