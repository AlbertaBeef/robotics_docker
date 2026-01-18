#!/bin/bash

# Set the base directory where we'll clone/check for the repo
BASE_DIR="/home/$USER"
REPO_DIR="$BASE_DIR/robotics_docker"
SHARED_DIR="$BASE_DIR/shared"

DOCKER_TAG="robotics_demo_20260118"

# Install sshpass if not already installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y sshpass
    echo "✓ sshpass installed."
else
    echo "sshpass already installed."
fi

# Check if robotics_docker repo exists, if not clone it
echo "Checking for robotics_docker repository..."
if [ ! -d "$REPO_DIR" ]; then
    echo "Repository not found. Cloning robotics_docker..."
    cd "$BASE_DIR"
    git clone https://github.com/AlbertaBeef/robotics_docker.git
    echo "Repository cloned successfully!"    
else
    echo "Repository already exists at $REPO_DIR"
fi

# Create persistent storage directory
echo "Checking for shared directory..."
if [ ! -d "$SHARED_DIR" ]; then
    echo "Creating shared directory..."
    mkdir -p "$SHARED_DIR"
else
    echo "shared directory exists..."
fi
    
# Create ros_domain_id.txt (if not present)
if [ ! -f "$SHARED_DIR/ros_domain_id.txt" ]; then
    echo "Creating ros_domain_id.txt in shared directory..."
    echo "0" > $SHARED_DIR/ros_domain_id.txt
else
    echo "ros_domain_id.txt exists in shared directory..."
fi

# Pull the Docker image
echo "Pulling Docker image (tag=${DOCKER_TAG}) ..."
docker pull albertabeef/robotics_docker:$DOCKER_TAG

# Navigate to the compose directory
cd "$REPO_DIR/compose"

sed -i "s|image: albertabeef/robotics_docker:latest|image: albertabeef/robotics_docker:$DOCKER_TAG|g" "$REPO_DIR/compose/docker-compose.yml"

# Launch the docker container
echo "Starting Docker container..."
docker compose up -d robotics_demo

# Wait a moment for container to be ready
sleep 2

# Allow X-Windows on host
echo "Configuring X-Windows access..."
xhost +

echo "Launching the demo in new terminal..."

# Launch Part 2 demo in a new terminal window
gnome-terminal --title="ROS2 Demo Part 2" -- bash -c "
docker compose -f $REPO_DIR/compose/docker-compose.yml exec robotics_demo bash -ic '
ros2 launch hand_controller demo13_lekiwi_part2.launch.py use_imshow:=True model:=/root/Depot_tria/world.sdf
'; exec bash"


echo "Docker demo setup complete!"
