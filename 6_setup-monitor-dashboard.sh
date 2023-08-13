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
./setup.sh $USER

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
curl -X POST -H "Content-Type: application/json" \
  --user $GRAFANA_ACCOUNT \
  -d $DATASOURCE_CONFIG http://localhost:8090/api/datasources/

## Grafana のダッシュボード設定
cd ../misc
echo 
echo "Register Dashboard"
jq '{ "dashboard": . }' dashboard.json | curl -X POST -H "Content-Type: application/json" \
  --user $GRAFANA_ACCOUNT http://localhost:8090/api/dashboards/db -d @-

echo "Monitoring Dashboard Setup Finished."
