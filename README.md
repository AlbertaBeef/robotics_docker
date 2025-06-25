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
- Yahboom ROSMASTER-X3 simulation
   - https://github.com/automaticaddison/yahboom_rosmaster
- MOGI-ROS simulation


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

