#!/bin/bash

# Grant docker container access to x server
xhost +local:docker

# Run ROS2 container with X11 forwarding
docker run -it \
  --env DISPLAY=$DISPLAY \
  --env QT_X11_NO_MITSHM=1 \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  osrf/ros:lyrical-desktop-full bash

# After container end return previous access 
xhost -local:docker

