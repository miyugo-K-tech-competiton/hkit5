# hkit5

> K-Tech Competition EP 파트 (hkit5 로봇, Raspberry Pi 4)

---

## ✅ 구성

| 경로 | 내용 |
|------|------|
| `docker/Dockerfile` | ROS 2 Humble + libcamera/rpicam-vid (Pi 4 전용) 이미지 |
| `docker/build_image.sh` | 이미지 빌드 (`hkit5:humble`) |
| `docker/run_container.sh` | 컨테이너 실행 (저장소의 `ros2_ws` 를 그대로 연결) |
| `ros2_ws/src/my_robot_bringup` | 로봇 노드 (ament_cmake, Python) |

---

## 📌 작업 흐름

코드는 **맥에서 작성**하고, 라즈베리파이에서는 **git pull 후 도커에서 빌드/실행**만 한다.
라즈베리파이에서 직접 코드를 고치지 않는다 (다음 pull 때 충돌난다).

```bash
# 맥
git add -A
git commit -m "[feature] ..."
git push

# 라즈베리파이
cd ~/hkit5
git pull
docker/run_container.sh

# 컨테이너 안
colcon build
source install/setup.bash
ros2 launch my_robot_bringup ep.launch.py
```

- 파이썬 노드도 수정 후에는 꼭 `colcon build` 를 다시 해야 반영된다
- 컨테이너는 `--rm` 이라 나가면 사라진다. 빌드 결과(`ros2_ws/build`, `install`)는 저장소 폴더에 남는다

---

## 🛠 라즈베리파이 최초 설정

- 도커 설치, 사용자 docker 그룹 추가는 ktech_ws 의 `docker_config/README.md` 참고

```bash
git clone https://github.com/miyugo-K-tech-competiton/hkit5.git ~/hkit5
```

- 로봇 프로파일 파일을 홈 디렉토리에 만든다 (`ep.launch.py` 가 읽음)

```bash
cat > ~/config.ini <<'EOF'
[robot]
profile = hkit5
EOF
```

- 이미지 빌드 (Pi 4 에서 libcamera 컴파일 때문에 40분 이상 걸린다)

```bash
cd ~/hkit5
docker/build_image.sh
```

- `Dockerfile` 이 바뀌었을 때만 다시 빌드하면 된다. 코드 변경은 이미지 재빌드 불필요

---

## 📌 Git Commit Convention

| Prefix | Description |
|--------|-------------|
| **[feature]** | 새로운 기능 추가 또는 알고리즘 수정 |
| **[bugfix]** | 버그 수정 |
| **[ignore]** | 주석 추가, 코드 정리 등 알고리즘에 영향을 주지 않는 변경 |

---

## 📖 하드웨어 메모 (hkit5)

| 장치 | 포트 | 비고 |
|------|------|------|
| ROBOTIS OpenCR | `/dev/ttyACM0` | USB→Dynamixel 통과 모드, 1Mbps, Protocol 2.0 |
| 바퀴 모터 XL430-W250 ×4 | ID 1~4 | 속도 제어 모드. ID 2·4 왼쪽(Drive Mode 반전), ID 1·3 오른쪽 |
| 라이다 | `/dev/ttyUSB0` | CP2102 |
| 카메라 ov5647 (CSI) | libcamera | `rpicam-vid` 로 MJPEG 수신 |

- Goal Velocity 양수 = 로봇 **후진**. 전진은 4개 모두 음수
- 제자리 회전 시 바퀴 미끄러짐이 커서 엔코더 기준 회전각의 약 0.48 배만 실제로 돈다 (육안 측정)
- Goal Velocity 레지스터에 이전 값(1023)이 남아 있을 수 있다. 토크를 켜기 전에 반드시 0 으로 쓸 것

## ⚠️ 알려진 문제

- `cmd_vel_bridge` 는 115200bps 텍스트 `V,좌,우` 프로토콜을 가정하고 있어 현재 OpenCR(통과 모드)과 맞지 않는다. 바퀴가 움직이지 않는다 → Dynamixel 직접 제어로 재작성 예정
- 토픽 명세상 EP 는 `/sp/cmd_vel`, `/ap/cmd_vel` 을 구독해야 하지만 현재는 `cmd_vel` 만 구독한다
