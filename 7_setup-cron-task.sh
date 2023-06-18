#!/bin/bash
set -e

GITHUB_REPO_URL=https://github.com/techmadot/rk3588-env

prepareEncodeTask()
{
  sudo cat << EOS > /tmp/task-encode
## エンコードタスクの投入.
15 3 * * * root node /usr/local/bin/enqueue_enc.js
EOS
  chmod 600 /tmp/task-encode
  sudo chown root:root /tmp/task-encode
  sudo mv /tmp/task-encode /etc/cron.d/task-encode

  sudo wget -O /usr/local/bin/enqueue_enc.js $GITHUB_REPO_URL/raw/main/scripts/enqueue_enc.js
}

prepareRebootTask()
{
  cat << EOS > /tmp/task-reboot
## 再起動処理
5 3 * * sat root /usr/local/sbin/system_reboot.sh
EOS

  chmod 600 /tmp/task-reboot
  sudo chown root:root /tmp/task-reboot
  sudo mv /tmp/task-reboot /etc/cron.d/task-reboot

  sudo wget -O /usr/local/sbin/system_reboot.sh $GITHUB_REPO_URL/raw/main/scripts/reboot_sys.sh
  sudo chmod +x /usr/local/sbin/system_reboot.sh
}

while [ $# -gt 0 ]; do
  case "$1" in
    --encode-task)
      prepareEncodeTask
      echo "add entry Encode Task"
      ;;
    --reboot-task)
      prepareRebootTask
      echo "add entry Reboot Task"
      ;;
  esac
  shift $(( $# > 0 ? 1 : 0 ))
done

echo "Cron Task Preparation Finished"