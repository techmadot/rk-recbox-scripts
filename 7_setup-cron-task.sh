#!/bin/bash
set -e

SCRIPT_DIR=$(cd $(dirname $0); pwd)

prepareEncodeTask()
{
  sudo cat << EOS > /tmp/task-encode
## エンコードタスクの投入.
15 3 * * * root node /usr/local/bin/enqueue_enc.js
EOS
  chmod 600 /tmp/task-encode
  sudo chown root:root /tmp/task-encode
  sudo mv /tmp/task-encode /etc/cron.d/task-encode

  sudo cp $SCRIPT_DIR/cron-tasks/enqueue_enc.js /usr/local/bin/enqueue_enc.js
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

  chmod +x $SCRIPT_DIR/cron-tasks/system_reboot.sh
  sudo cp $SCRIPT_DIR/cron-tasks/system_reboot.sh /usr/local/sbin/system_reboot.sh
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