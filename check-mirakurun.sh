#!/bin/bash
set -e

CONTAINER_ID=$(docker ps --filter "name=mirakurun" --format "{{.ID}}")
echo "ContainerID=${CONTAINER_ID}"

## Check B-CAS Card
#docker logs $CONTAINER_ID | grep "Chijou Digital"


while [ $# -gt 0 ]; do
  case "$1" in 
    --scan)
      SCAN_TYPE_LIST="$2"
      shift
      ;;
    --rec-test)
      REC_TEST=1
      ;;
    --channel)
      CHANNEL="$2"
      shift
      ;;
    --duration)
      DURATION="$2"
      shift
      ;;
    --device)
      DEVICE="$2"
      shift
      ;;
    --file)
      REC_FILE="$2"
      shift
      ;;
    --recdvb)
      USE_RECDVB=1
      ;;
  esac
  shift $(( $# > 0 ? 1 : 0 ))
done

channelScan()
{
  IFS=',' read -ra typeList <<< "${SCAN_TYPE_LIST}"
  for type in "${typeList[@]}"; do
    curl -X PUT "http://localhost:40772/api/config/channels/scan?type=${type}&refresh=true&setDisabledOnAdd=false"
  done
}

testRecording() 
{
  COMMAND="recpt1 --device ${DEVICE} -b"
  if [ -n "$USE_RECDVB" ]; then
    COMMAND="recdvb --dev ${DEVICE} -b"
  fi

  COMMAND="$COMMAND ${CHANNEL} ${DURATION} /tmp/${REC_FILE}"

  docker container exec -t $CONTAINER_ID bash -c "$COMMAND"
  docker cp $CONTAINER_ID:/tmp/$REC_FILE ./$REC_FILE
}

if [ -n "$REC_TEST" ]; then
  echo "======== Start test recording ========"
  testRecording
  echo "======== End test recording ========"
fi
if [ -n "$SCAN_TYPE_LIST" ]; then
  echo "======== Start channel scan ========"
  channelScan
  echo "======== End channel scan ========"
fi
