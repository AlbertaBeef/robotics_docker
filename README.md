## Overview

Docker container scripts for ROS2 development.

Contents of Docker image:
- Ubuntu 24.04 (Noble)
- ROS2 (Jazzy)
- Gazebo (Harmonic)

Additional content:
- Hand Controller
   - https://github.com/AlbertaBeef/hand_controller
- LeRobot SO-101 support
   - https://github.com/AlbertaBeef/Lerobot_ros2
- LeRobot LeKiwi support
   - https://github.com/AlbertaBeef/lekiwi_ros2
- MOGI-ROS simulation
   - https://github.com/MOGI-ROS/mogi_trajectory_server
   - https://github.com/MOGI-ROS/Week-3-4-Gazebo-basics
   - https://github.com/MOGI-ROS/Week-5-6-Gazebo-sensors
   - https://github.com/MOGI-ROS/Week-7-8-ROS2-Navigation
   - https://github.com/MOGI-ROS/Week-9-10-Simple-arm
- UR simulation

## Cloning the repo

The repo must be cloned with git:

   - git clone https://github.com/AlbertaBeef/robotics_docker
   - cd robotics_docker


## Building the Docker image

The pre-built Docker image can be accessed on Docker Hub:
   - https://hub.docker.com/repository/docker/albertabeef/robotics_docker

If you prefer to build the Docker image locally,

Start by downloading the following archive to the "robotics_docker" directory:
   - gazebo_models.zip [Google Drive](https://drive.google.com/uc?export=download&id=1tcfoLFReEW1XNHPUAeLpIz2iZXqQBvo_)
   - Depot_tria.zip (https://github.com/AlbertaBeef/robotics_docker/releases/download/robotics_demo_20260119/Depot_tria.zip)

Then launch the Docker build script as follows:
   - cd robotics_docker/docker
   - source ./build.sh


## Launching the Docker image

If not done so already, build Docker image, or download the image from Docker Hub:
   - docker pull albertabeef/robotics_docker:robotics_demo_20251119

Create a directory for shared content, and indicate its location in the following file:
   - robotics_docker/compose/docker-compose.yml 

Launch Docker image using compose functionnality:
   - cd robotics_docker/compose
   - docker compose up -d robotics_demo

Making the local host's GUI available to the Docker image:
   - xhost +
   - docker compose exec robotics_demo bash


## Running the ASL-controlled Turtlesim demo

Launch the asl_controller_twist node with usbcam_publisher and turtlesim nodes:

   - ros2 launch asl_mediapipe_pointnet demo01_turtlesim_asl_part1.launch.py | ros2 launch asl_mediapipe_pointnet demo01_turtlesim_asl_part2.launch.py

Launch the hand_controller_asl_twist node with usbcam_publisher and turtlesim nodes:

   - ros2 launch hand_controller demo01_turtlesim_part1_asl.launch.py | ros2 launch hand_controller demo01_turtlesim_part2.launch.py

Control Turtle with Hand Signs

   - A : Advance
   - B : Backup
   - L : Turn Left
   - R : Turn Right
   
![](https://github.com/AlbertaBeef/asl_mediapipe_pointnet/blob/main/images/asl_mediapipe_pointnet_demo01_ros2_turtlesim.gif)


## Running the ASL-controlled MOGI-ROS wheeled vehicle demo

Launch the asl_controller_twist node with the MOGI-ROS wheeled vehicle:

   - ros2 launch asl_mediapipe_pointnet demo11_mogiros_car_part1_asl.launch.py | ros2 launch asl_mediapipe_pointnet demo11_mogiros_car_part2.launch.py

Launch the hand_controller_asl_twist node with the MOGI-ROS wheeled vehicle:

   - ros2 launch hand_controller demo11_mogiros_car_part1_asl.launch.py | ros2 launch hand_controller demo11_mogiros_car_part2.launch.py

Control Vehicle with Hand Signs

   - A : Advance
   - B : Backup
   - L : Turn Left
   - R : Turn Right

![](https://github.com/AlbertaBeef/asl_mediapipe_pointnet/blob/main/images/asl_mediapipe_pointnet_demo01_ros2_gazebo.gif)


## Running the ASL-controlled MOGI-ROS robotic arm demo

Launch the asl_controller_pose node with MOGI-ROS simple robotic arm:

   - ros2 launch asl_mediapipe_pointnet demo21_mogiros_arm_part1_asl.launch.py | ros2 launch asl_mediapipe_pointnet demo21_mogiros_arm_part2.launch.py

Launch the hand_controller_asl_pose node with MOGI-ROS simple robotic arm:

   - ros2 launch hand_controller demo21_mogiros_arm_part1_asl.launch.py | ros2 launch hand_controller demo21_mogiros_arm_part2.launch.py

Control Robotic Arm with Left/Right Hands:

   - Left Hand
      - L : Turn Arm Left
      - R : Turn Arm Right
      - A : Advance Arm (shoulder joint)
      - B : Backup Arm (shoulder joint)
      - U : Lift Arm (elbow joint)
      - Y : Lower Arm (elbow joint)

   - Right Hand
      - A : Close Gripper
      - B : Open Gripper

![](https://github.com/AlbertaBeef/asl_mediapipe_pointnet/blob/main/images/asl_mediapipe_pointnet_demo04_ros2_gazebo_mogiros_arm.gif)




## References

The Complete Guide to Docker for ROS 2 Jazzy Projects
   - https://automaticaddison.com/the-complete-guide-to-docker-for-ros-2-jazzy-projects/

MOGI-ROS on-line Tutorials:
   - https://github.com/MOGI-ROS/Week-1-2-Introduction-to-ROS2
   - https://github.com/MOGI-ROS/Week-3-4-Gazebo-basics
   - https://github.com/MOGI-ROS/Week-5-6-Gazebo-sensors
   - https://github.com/MOGI-ROS/Week-7-8-ROS2-Navigation
   - https://github.com/MOGI-ROS/Week-9-10-Simple-arm

Accelerating MediaPipe:
   - Hackster Series Part 1 [Blazing Fast Models](https://avnet.me/mediapipe-01-models)
   - Hackster Series Part 2 [Insightful Datasets for ASL recognition](https://avnet.me/mediapipe-02-datasets)
   - Hackster Series Part 3 [Accelerating the MediaPipe models with Vitis-AI 3.5](https://avnet.me/mediapipe-03-vitis-ai-3.5)
   - Hackster Series Part 4 [Accelerating the MediaPipe models with Hailo-8](https://avnet.me/mediapipe-04-Hailo-8)
   - Hackster Series Part 5 [Accelerating the MediaPipe models on RPI5 AI Kit](https://avnet.me/mediapipe-05-rpi5aikit)
   - Hackster Series Part 6 [Accelerating the MediaPipe models with MemryX](https://avnet.me/mediapipe-06-memryx)
   - Blaze Utility (python version) : [blaze_app_python](https://github.com/albertabeef/blaze_app_python)
   - Blaze Utility (C++ version) : [blaze_app_cpp](https://github.com/albertabeef/blaze_app_cpp)

ASL Recognition using PointNet (by Edward Roe):
   - Medium Article [ASL Recognition using PointNet and MediaPipe](https://medium.com/@er_95882/asl-recognition-using-pointnet-and-mediapipe-f2efda78d089)
   - Kaggle Dataset [American Sign Language Dataset](https://www.kaggle.com/datasets/ayuraj/asl-dataset)
   - GitHub Source [pointnet_hands](https://github.com/e-roe/pointnet_hands/tree/main)
