#!/bin/bash
# hkit5 컨테이너를 띄운다 (Raspberry Pi 4 에서 실행).
# 저장소의 ros2_ws 를 그대로 연결하므로 git pull 한 코드가 바로 컨테이너에 보인다.

IMAGE=hkit5:humble
REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)

# 로봇 프로파일(hkit4/hkit5)은 로봇마다 다르므로 저장소가 아닌 홈 디렉토리에 둔다
CONFIG=$HOME/config.ini
test -f "$CONFIG" || { echo "설정 파일이 없습니다: $CONFIG (README 참고)"; exit 1; }

# 호스트네임(HOSTNAME)으로 ROS_DOMAIN_ID 판별
HOST_NAME=$(hostname)

case "$HOST_NAME" in
  *hkit4*)
    DOMAIN_ID=40
    ;;
  *hkit5*)
    DOMAIN_ID=50
    ;;
  *)
    echo "경고: 알 수 없는 호스트네임($HOST_NAME)입니다. 기본값 90으로 설정합니다."
    DOMAIN_ID=90
    ;;
esac

echo "=========================================="
echo "호스트네임: $HOST_NAME -> ROS_DOMAIN_ID: $DOMAIN_ID"
echo "워크스페이스: $REPO_DIR/ros2_ws"
echo "=========================================="

# /run/udev: 컨테이너 안 libcamera 가 CSI 카메라를 찾는 데 필요
docker run -it --rm \
  --name hkit5 \
  --privileged \
  --net=host \
  -e ROS_DOMAIN_ID="$DOMAIN_ID" \
  --mount type=bind,src="$CONFIG",dst=/root/config.ini,readonly \
  -v /dev:/dev \
  -v /run/udev:/run/udev:ro \
  -v "$REPO_DIR/ros2_ws":/root/hkit5/ros2_ws \
  -w /root/hkit5/ros2_ws \
  "$IMAGE" \
  /bin/bash
