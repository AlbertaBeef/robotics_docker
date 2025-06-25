#!/bin/bash

# Get the absolute path of the directory containing this script (docker directory)
SCRIPT_PATH=$(dirname $(realpath "$0"))

# Get the parent directory path (mycobot_ros2 directory)
# This is where our actual ROS 2 package code lives
PARENT_PATH=$(dirname "$SCRIPT_PATH")

# Function to build the Docker image
# This function handles the actual Docker build process
build_docker_image()
{
    # Set a log message for the build process
    LOG="Building Docker image albertabeef/robotics_docker:latest ..."

    # Print the log message using our debug function
    print_debug

    # Build the Docker image
    # -f $SCRIPT_PATH/Dockerfile: Specify the path to the Dockerfile in the docker directory
    # -t albertabeef/robotics_docker:latest: Tag the image as albertabeef/robotics_docker:latest
    # $PARENT_PATH: Use the parent directory as the build context, allowing access to all package files
    # --no-cache: Build the image without using the cache, ensuring fresh dependencies
    sudo docker image build -f $SCRIPT_PATH/Dockerfile -t albertabeef/robotics_docker:latest $PARENT_PATH --no-cache
}

# Function to print debug messages
# This provides consistent formatting for our log messages
print_debug()
{
    # Print an empty line for readability
    echo ""

    # Print the log message
    echo $LOG

    # Print another empty line for readability
    echo ""
}

# Main execution flow


# Build the Docker image
build_docker_image
