#!/bin/bash

set -e

IMAGE="ros:lyrical-custom"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKERFILE="$SCRIPT_DIR/Dockerfile.lyrical-custom"

# Build image if it doesn't exist
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "Docker image '$IMAGE' not found. Building..."
    docker build -f "$DOCKERFILE" -t "$IMAGE" "$SCRIPT_DIR"
fi

# Grant docker container access to x server
xhost +local:docker

# Run ROS2 container with X11 forwarding
docker run --rm -it \
  --env DISPLAY=$DISPLAY \
  --env QT_X11_NO_MITSHM=1 \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  "$IMAGE" bash

# After container end return previous access 
xhost -local:docker
