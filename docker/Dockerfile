# hkit5 EP 파트 도커 이미지 (Raspberry Pi 4 전용, arm64)
#
# 빌드: docker/build_image.sh  (Pi 4 에서 libcamera 컴파일 때문에 40분 이상 걸린다)
FROM ros:humble

ARG DEBIAN_FRONTEND=noninteractive
ARG MESON_VERSION=1.11.2
# 호스트(Raspberry Pi OS)의 libcamera 와 같은 버전을 쓴다 (dpkg -l | grep libcamera)
ARG LIBCAMERA_VERSION=v0.7.2+rpt20260817
ARG RPICAM_APPS_VERSION=v1.12.0

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ROS 패키지, 노드가 쓰는 Python 모듈, 카메라 빌드 의존성
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    ros-humble-rplidar-ros \
    ros-humble-vision-msgs \
    ros-humble-dynamixel-sdk \
    python3-serial \
    python3-opencv \
    python3-numpy \
    python3-venv \
    git \
    g++ \
    cmake \
    pkg-config \
    ninja-build \
    libyaml-dev \
    libgnutls28-dev \
    openssl \
    libtiff5-dev \
    libjpeg-dev \
    libpng-dev \
    libboost-program-options-dev \
    libexif-dev \
    libudev-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Meson 과 libcamera 빌드용 Python 모듈은 별도 venv 에만 둔다.
# ENV PATH 에 넣지 않는다: 넣으면 colcon/CMake 와 노드가 이 venv 의 python3 를 잡아
# catkin_pkg, numpy 등을 못 찾는다. 카메라 빌드 RUN 단계 안에서만 export 한다
# (ninja 가 실행하는 코드 생성 스크립트도 jinja2 가 있는 이 python3 를 써야 한다).
RUN python3 -m venv /opt/meson-venv \
    && /opt/meson-venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/meson-venv/bin/pip install --no-cache-dir \
       "meson==${MESON_VERSION}" \
       Jinja2 PyYAML ply \
    && /opt/meson-venv/bin/meson --version

# Raspberry Pi 4 용 libcamera (VC4 파이프라인만)
RUN export PATH="/opt/meson-venv/bin:${PATH}" \
    && mkdir -p /tmp/camera-build \
    && cd /tmp/camera-build \
    && git clone --depth=1 --branch "${LIBCAMERA_VERSION}" \
       https://github.com/raspberrypi/libcamera.git \
    && cd libcamera \
    && meson setup build \
       --buildtype=release \
       -Dpipelines=rpi/vc4 \
       -Dipas=rpi/vc4 \
       -Dv4l2=true \
       -Dgstreamer=disabled \
       -Dtest=false \
       -Dlc-compliance=disabled \
       -Dcam=disabled \
       -Dqcam=disabled \
       -Ddocumentation=disabled \
       -Dpycamera=disabled \
    && ninja -C build -j2 \
    && ninja -C build install \
    && ldconfig

# rpicam-vid (camera_node 가 MJPEG 스트림을 받는 데 사용)
RUN export PATH="/opt/meson-venv/bin:${PATH}" \
    && cd /tmp/camera-build \
    && git clone --depth=1 --branch "${RPICAM_APPS_VERSION}" \
       https://github.com/raspberrypi/rpicam-apps.git \
    && cd rpicam-apps \
    && meson setup build \
       -Denable_libav=disabled \
       -Denable_drm=disabled \
       -Denable_egl=disabled \
       -Denable_qt=disabled \
       -Denable_opencv=disabled \
       -Denable_tflite=disabled \
       -Denable_hailo=disabled \
    && ninja -C build -j2 \
    && ninja -C build install \
    && ldconfig \
    && rpicam-vid --version \
    && rm -rf /tmp/camera-build

# ROS 2 언더레이와 워크스페이스 자동 소싱 (워크스페이스는 첫 colcon build 이후에 생긴다)
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc && \
    echo "[ -f /root/hkit5/ros2_ws/install/setup.bash ] && source /root/hkit5/ros2_ws/install/setup.bash" >> /root/.bashrc

WORKDIR /root/hkit5/ros2_ws
CMD ["/bin/bash"]
