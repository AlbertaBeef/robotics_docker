#!/bin/bash
set -e

# Set ROS 2 distribution as a variable
ROS_DISTRO="jazzy"

# Source ROS 2 setup
source /opt/ros/$ROS_DISTRO/setup.bash

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

#
# MyCobot 280
#

# Navigate to the workspace
cd /root/ros2_ws/src

# Install mycobot_ros2 if not already present
if [ ! -d "mycobot_ros2" ]; then
    git clone https://github.com/automaticaddison/mycobot_ros2.git -b jazzy
fi

# Install warehouse_ros_mongo if not already present
if [ ! -d "warehouse_ros_mongo" ]; then
    git clone https://github.com/moveit/warehouse_ros_mongo.git -b ros2
    cd warehouse_ros_mongo/
    git reset --hard 32f8fc5dd245077b9c09e93efc8625b9f599f271
    cd ..
fi

# Install MoveIt Task Constructor if not already present
if [ ! -d "moveit_task_constructor" ]; then
    git clone https://github.com/moveit/moveit_task_constructor.git -b jazzy
    #cd moveit_task_constructor
    #git reset --hard 9ced9fc10a15388224f0741e5a930a33f4ed6255
    #cd ..
fi

# Navigate back to the workspace root
cd /root/ros2_ws

# Install ROS2 dependencies for all packages
echo "Installing ROS 2 dependencies..."
rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

# Now apply all the fixes after dependencies are installed

# Fix storage.cpp
echo "Fixing storage.cpp..."
cd /root/ros2_ws/src/moveit_task_constructor
if [ -f core/src/storage.cpp ]; then
    # Create backup
    cp core/src/storage.cpp core/src/storage.cpp.backup

    # Replace the four lines with the new line using sed
    sed -i '/if (this->end()->scene()->getParent() == this->start()->scene())/,+3c\    this->end()->scene()->getPlanningSceneDiffMsg(t.scene_diff);' core/src/storage.cpp || echo "Warning: Could not modify storage.cpp"
fi

# Fix cartesian_path.cpp
echo "Fixing cartesian_path.cpp..."
if [ -f core/src/solvers/cartesian_path.cpp ]; then
    # Create backup
    cp core/src/solvers/cartesian_path.cpp core/src/solvers/cartesian_path.cpp.backup

    # Make the replacement
    sed -i 's/moveit::core::JumpThreshold(props.get<double>("jump_threshold")), is_valid,/moveit::core::JumpThreshold::relative(props.get<double>("jump_threshold")), is_valid,/' core/src/solvers/cartesian_path.cpp || echo "Warning: Could not modify cartesian_path.cpp"
fi

cd /root/ros2_ws

# Fix PCL warning - this needs to come after rosdep install
echo "Fixing PCL warnings..."
find /usr/include/pcl* -path "*/sample_consensus/impl/sac_model_plane.hpp" -exec sed -i 's/^\(\s*\)PCL_ERROR ("\[pcl::SampleConsensusModelPlane::isSampleGood\] Sample points too similar or collinear!\\n");/\1\/\/ PCL_ERROR ("[pcl::SampleConsensusModelPlane::isSampleGood] Sample points too similar or collinear!\\n");/' {} \;

# Build the packages
echo "Building packages..."
# First build without the problematic package
colcon build --packages-skip mycobot_mtc_pick_place_demo
source install/setup.bash

# Then build the problematic package with warning suppression
colcon build --packages-select mycobot_mtc_pick_place_demo --cmake-args -Wno-dev
source install/setup.bash

# Final build of everything
colcon build
source install/setup.bash


#
# Yahboom ROSMASTER-X3
#

# Install yahboom_rosmaster if not already present
cd /root/ros2_ws/src
if [ ! -d "yahboom_rosmaster" ]; then
    git clone https://github.com/automaticaddison/yahboom_rosmaster.git
fi

# Build yahboom_rosmaster
cd /root/ros2_ws/src
echo "Installing ROS 2 dependencies for yahboom_rosmaster ..."
rosdep install -i --from-path yahboom_rosmaster --rosdistro $ROS_DISTRO -y
echo "Building yahboom_rosmaster ..."
cd /root/ros2_ws/src/yahboom_rosmaster
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
# Final Build
#

# Final build of everything
cd /root/ros2_ws
colcon build
source install/setup.bash


echo "Workspace setup completed!"
