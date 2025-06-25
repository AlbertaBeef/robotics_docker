## Overview

Docker container scripts for ROS2 development.

Contents of docker image:
- Ubuntu 24.04 (Noble)
- ROS2 (Jazzy)
- Gazebo (Harmonic)

Additional content:
- ASL Controller
   - https://github.com/AlbertaBeef/asl_mediapipe_pointnet
- MyCobot-280 simulation
   - https://github.com/automaticaddison/mycobot_ros2 (branch=jazzy)
   - https://github.com/moveit/moveit_task_constructor (branch=jazzy)
   - https://github.com/moveit/warehouse_ros_mongo (branch=ros2)
- Yahboom ROSMASTER-X3 simulation
   - https://github.com/automaticaddison/yahboom_rosmaster
- MOGI-ROS simulation
   - https://github.com/MOGI-ROS/mogi_trajectory_server
   - https://github.com/MOGI-ROS/Week-3-4-Gazebo-basics
   - https://github.com/MOGI-ROS/Week-5-6-Gazebo-sensors
   - https://github.com/MOGI-ROS/Week-7-8-ROS2-Navigation
   - https://github.com/MOGI-ROS/Week-9-10-Simple-arm

## Cloning the repo

- git clone https://github.com/AlbertaBeef/robotics_docker


## Building the docker image

To build the docker image locally:
- cd robotics_docker/docker
- source ./build.sh

Pre-built docker images located here:
- https://hub.docker.com/repository/docker/albertabeef/robotics_docker


## Launching the docker image

If not done so already, build docker image, or download:
- docker pull albertabeef/robotics_docker:latest

Launch docker image using compose functionnality:
- cd robotics_docker/compose
- docker compose up -d robotics_demo

Making the local host's GUI available to the docker image:
- xhost +
- docker compose exec robotics_demo bash


## Running the ASL-controlled Turtlesim demo

- ros2 launch asl_mediapipe_pointnet asl_mediapipe_pointnet_turtlesim.launch.py

![](images/asl_mediapipe_pointnet_demo01_ros2_turtlesim.gif)

## Running the ASL-controlled Yahboom ROSMASTER-X3 demo

- ros2 launch asl_mediapipe_pointnet asl_mediapipe_pointnet_rosmaster.launch.py


## Running the ASL-controlled MOGI-ROS wheeled vehicle demo

- ros2 launch asl_mediapipe_pointnet asl_mediapipe_pointnet_mogiros.launch.py

![](images/asl_mediapipe_pointnet_demo01_ros2_gazebo.gif)


## References

The Complete Guide to Docker for ROS 2 Jazzy Projects
   - https://automaticaddison.com/the-complete-guide-to-docker-for-ros-2-jazzy-projects/

Automatic Addison on-line Tutorials:
   - https://automaticaddison.com/tutorials
   - https://github.com/automaticaddison/mycobot_ros2 (branch=jazzy)
   - https://github.com/automaticaddison/yahboom_rosmaster   

MOGI-ROS on-line Tutorials:
   - https://github.com/MOGI-ROS/Week-1-2-ROS2-basics
   - https://github.com/MOGI-ROS/Week-3-4-Gazebo-basics
   - https://github.com/MOGI-ROS/Week-5-6-Gazebo-sensors
   - https://github.com/MOGI-ROS/Week-7-8-ROS2-Navigation
   - https://github.com/MOGI-ROS/Week-9-10-Simple-arm

ASL Recognition using PointNet
   - Article [Medium](https://medium.com/@er_95882/asl-recognition-using-pointnet-and-mediapipe-f2efda78d089)
   - Dataset [Kaggle](https://www.kaggle.com/datasets/ayuraj/asl-dataset)
   - Source [Github](https://github.com/e-roe/pointnet_hands/tree/main)

