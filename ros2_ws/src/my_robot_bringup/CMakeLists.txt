cmake_minimum_required(VERSION 3.8)
project(my_robot_bringup)

# PATH 에 다른 venv(예: libcamera 빌드용 meson venv)가 앞서 있으면 CMake 가
# catkin_pkg 없는 파이썬을 잡는다. ROS 가 쓰는 시스템 파이썬으로 고정한다.
if(NOT DEFINED Python3_EXECUTABLE AND EXISTS /usr/bin/python3)
  set(Python3_EXECUTABLE /usr/bin/python3)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(rclpy REQUIRED)

# my_robot_bringup 파이썬 모듈 설치 (import my_robot_bringup 용)
ament_python_install_package(${PROJECT_NAME})

# 실행 노드 설치 (ros2 run / launch 에서 쓰는 이름은 setup.py 시절과 동일)
install(PROGRAMS
  ${PROJECT_NAME}/avoidance_node.py
  DESTINATION lib/${PROJECT_NAME}
  RENAME avoidance_node
)
install(PROGRAMS
  ${PROJECT_NAME}/camera_node.py
  DESTINATION lib/${PROJECT_NAME}
  RENAME camera_node
)
install(PROGRAMS
  ${PROJECT_NAME}/cmd_vel_bridge.py
  DESTINATION lib/${PROJECT_NAME}
  RENAME cmd_vel_bridge
)
install(PROGRAMS
  ${PROJECT_NAME}/cmd_vel_serial_bridge.py
  DESTINATION lib/${PROJECT_NAME}
  RENAME cmd_vel_serial_bridge
)

install(
  DIRECTORY launch
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # comment the line when a copyright and license is added to all source files
  set(ament_cmake_copyright_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
