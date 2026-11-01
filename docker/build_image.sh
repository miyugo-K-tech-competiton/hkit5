#!/bin/bash
# hkit5 도커 이미지를 빌드한다 (Raspberry Pi 4 에서 실행).
set -e

IMAGE=hkit5:humble
DOCKER_DIR=$(cd "$(dirname "$0")" && pwd)

docker build -t "$IMAGE" "$DOCKER_DIR"
echo "빌드 완료: $IMAGE"
