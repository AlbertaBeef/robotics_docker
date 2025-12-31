#!/bin/bash
set -e

# Set ROS 2 distribution as a variable
ROS_DISTRO="jazzy"

# Source ROS 2 setup
source /opt/ros/$ROS_DISTRO/setup.bash

#
# Edge Impulse
#

# Install Edge Impulse
#    reference : https://docs.edgeimpulse.com/tools/clis/edge-impulse-cli/installation
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
#
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> /root/.bashrc
#
npm install -g edge-impulse-cli
npm install -g edge-impulse-linux
#
sed -i 's/^from edge_impulse_linux import audio/#from edge_impulse_linux import audio/' /usr/local/lib/python3.12/dist-packages/edge_impulse_linux/__init__.py

#
# MongoDB
#

# Install system dependencies for MongoDB and PCL
apt-get update && apt-get install -y \
    gnupg \
    curl \
    libpcap-dev

# Install MongoDB (following official MongoDB installation for Ubuntu)
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
    --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-8.0.list
apt-get update && apt-get install -y mongodb-org

# Start and enable MongoDB service
# Note: systemctl might not work in all Docker environments, so we'll add error handling
systemctl start mongod || echo "Warning: Could not start MongoDB service. This is expected in some Docker environments."
systemctl enable mongod || echo "Warning: Could not enable MongoDB service. This is expected in some Docker environments."

# Update ROS2
echo "Update ROS2 ..."
rosdep update


#
# ASL Controller
#

# Install asl_mediapipe_pointnet
echo "Installing asl_mediapipe_pointnet ..."
cd /root
if [ ! -d "asl_mediapipe_pointnet" ]; then
    git clone https://github.com/AlbertaBeef/asl_mediapipe_pointnet.git
    cd asl_mediapipe_pointnet/model
    source ./get_model.sh
    cd ../..
fi

# Copy asl_mediapipe_pointnet to ros2_ws/src and Build
cd /root/ros2_ws/src
echo "Copying asl_mediapipe_pointnet to ros2_ws directory ..."
cp -r /root/asl_mediapipe_pointnet/ros2_ws/asl_mediapipe_pointnet .
echo "Installing ROS 2 dependencies for asl_mediapipe_pointnet ..."
rosdep install -i --from-path asl_mediapipe_pointnet --rosdistro $ROS_DISTRO -y
echo "Building asl_mediapipe_pointnet ..."
cd /root/ros2_ws/src/asl_mediapipe_pointnet
colcon build
source install/setup.bash

# Copy asl_moveit_demos to ros2_ws/src and Build
cd /root/ros2_ws/src
echo "Copying asl_moveit_demos to ros2_ws directory ..."
cp -r /root/asl_mediapipe_pointnet/ros2_ws/asl_moveit_demos .
echo "Installing ROS 2 dependencies for asl_moveit_demos ..."
rosdep install -i --from-path asl_moveit_demos --rosdistro $ROS_DISTRO -y
echo "Building asl_moveit_demos ..."
cd /root/ros2_ws/src/asl_moveit_demos
colcon build
source install/setup.bash

#
# LeRobot ROS2 packages
#

# Install extra dependencies
pip3 install deepdiff serial feetech-servo-sdk

# Create common directory for so101 and lekiwi packages
mkdir /root/ros2_ws/src/lerobot

echo "Cloning SO-101 ROS2 package ..."
cd /root
git clone https://github.com/AlbertaBeef/Lerobot_ros2
cp -r /root/Lerobot_ros2/src/so101_* /root/ros2_ws/src/lerobot/.

echo "Cloning LeKiwi ROS2 package ..."
cd /root
git clone https://github.com/AlbertaBeef/lekiwi_ros2
cp -r /root/lekiwi_ros2/src/* /root/ros2_ws/src/lerobot/.

#
# Hand Controller
#

# Install extra dependencies
pip3 install flask==3.0.0 edge_impulse_linux

# Install hand_controller
echo "Installing hand_controller ..."
cd /root
if [ ! -d "hand_controller" ]; then
    git clone --recursive https://github.com/AlbertaBeef/hand_controller.git
    cd hand_controller
    # Download the ASL model
    cd asl_pointnet
    source ./get_model.sh
    cd ..
    # Download the TFLite mediapipe models
    cd blaze_app_python/blaze_tflite/models
    source ./get_tflite_models.sh
    cd ../../..
    # Download the PyTorch mediapipe models
    cd blaze_app_python/blaze_pytorch/models
    source ./get_pytorch_models.sh
    cd ../../..
    # Remove Edge Impulse models for qcs6490 host
    rm hands-v2-*-qnn-*.eim
    # Download Edge Impulse models for x86 host
    cd /root/hand_controller
    wget -O hands-v2-yolov5-linux-x86.eim "https://github.com/zebular13/hand_controller/releases/download/Flask_QIRP1.4/hands-v2-linux-x86.eim"
    chmod +x hands-v2-yolov5-linux-x86.eim
fi

# Copy hand_controller to ros2_ws/src and Build
cd /root/ros2_ws/src
echo "Copying hand_controller to ros2_ws directory ..."
cp -r /root/hand_controller/ros2_ws/hand_controller .
echo "Installing ROS 2 dependencies for hand_controller ..."
rosdep install -i --from-path hand_controller --rosdistro $ROS_DISTRO -y
echo "Building hand_controller ..."
cd /root/ros2_ws/src/hand_controller
colcon build
source install/setup.bash

#
# MongoDB
#

# Navigate to the workspace
cd /root/ros2_ws/src

# Install warehouse_ros_mongo if not already present
if [ ! -d "warehouse_ros_mongo" ]; then
    git clone https://github.com/moveit/warehouse_ros_mongo.git -b ros2
    cd warehouse_ros_mongo/
    git reset --hard 32f8fc5dd245077b9c09e93efc8625b9f599f271
    cd ..
fi

# Navigate back to the workspace root
cd /root/ros2_ws

# Install ROS2 dependencies for all packages
echo "Installing ROS 2 dependencies..."
rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

# Final build of everything
colcon build
source install/setup.bash


#
# MOGI-ROS
#

# Install mogiros if not already present
cd /root/ros2_ws/src
if [ ! -d "mogiros" ]; then
    mkdir mogiros
    cd mogiros
    git clone https://github.com/MOGI-ROS/mogi_trajectory_server
    git clone https://github.com/MOGI-ROS/Week-3-4-Gazebo-basics
    git clone https://github.com/MOGI-ROS/Week-5-6-Gazebo-sensors
    git clone https://github.com/MOGI-ROS/Week-7-8-ROS2-Navigation
    git clone https://github.com/MOGI-ROS/Week-9-10-Simple-arm
fi

# Build mogiros
cd /root/ros2_ws/src
echo "Installing ROS 2 dependencies for mogiros ..."
rosdep install -i --from-path mogiros --rosdistro $ROS_DISTRO -y
echo "Building yahboom_rosmaster ..."
cd /root/ros2_ws/src/mogiros
colcon build
source install/setup.bash

# Unzip gazebo models
cd /root
unzip gazebo_models.zip

#
# LLM-based content
#

# llm-robot-control
cd /root
git clone https://github.com/AlbertaBeef/llm-robot-control
cd /root/llm-robot-control
pip3 install -r requirements.txt
#rosdep install -r --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y
   #/usr/bin/rosdep:6: DeprecationWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html
   #  from pkg_resources import load_entry_point
   #ERROR: the following packages/stacks could not have their rosdep keys resolved
   #to system dependencies:
   #ros2_ai_interfaces: Cannot locate rosdep definition for [transforms3d]
   #ros2_ai_agent: Cannot locate rosdep definition for [moveit-py]
   #ros2_ai_eval: Cannot locate rosdep definition for [moveit-py]
   #Continuing to install resolvable dependencies...
   #All required rosdeps installed successfully
colcon build
source install/setup.bash
echo 'source /root/llm-robot-control/install/setup.bash' >> /root/.bashrc

# Universal Robotics (UR)
apt install -y ros-$ROS_DISTRO-ur
apt install -y ros-$ROS_DISTRO-ur-simulation-gz

# Install RAI
#   reference : https://robotecai.github.io/rai/setup/install/
curl -sSL https://install.python-poetry.org | python3 -
echo 'export PATH=~/.local/bin:$PATH' >> /root/.bashrc
#
cd /root
git clone https://github.com/RobotecAI/rai.git
#
cd /root/rai
vcs import < ros_deps.repos
#
cd /root/rai
/root/.local/bin/poetry install
/root/.local/bin/poetry install --all-groups
#
cd /root/rai
rosdep install --from-paths src --ignore-src -r -y
#
cd /root/rai
pip3 install empy
pip3 install catkin_pkg
colcon build --symlink-install
source ~/rai/install/setup.bash 
echo 'source ~/rai/install/setup.bash' >> /root/.bashrc
#
cd /root/rai
apt-get install -y zip
./scripts/download_demo.sh manipulation
./scripts/download_demo.sh rosbot
./scripts/download_demo.sh agriculture


 
#
# Final Build
#

# Final build of everything
cd /root/ros2_ws
colcon build
source install/setup.bash


echo "Workspace setup completed!"
