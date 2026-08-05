# ros2-methodology

## how to start
### learning sources

- Main source is [official ros2 documentaiton](https://docs.ros.org/en/lyrical/index.html)
- This is link to [Robotogeddon youtube tutorial](https://www.youtube.com/watch?v=QfFnljTrRlQ&list=PLNw2RD-1J5YZbyWXCpas9zPJldfphPi4Q&index=1&pp=iAQB)
 - ros2 docker images [osrf/docker_images](https://github.com/osrf/docker_images)
### instalation and execution with docker

#### dockerfile with image configuration
```bash
# Dockerfile.lyrical-custom

FROM osrf/ros:lyrical-desktop-full

RUN apt-get update && \
    apt-get install -y tmux && \
    rm -rf /var/lib/apt/lists/*
```

#### runros.sh for automated image creation and container execution
```bash
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

# in instance init ros2 environment (you can access ros2 commands)
source /opt/ros/lyrical/setup.bash
```

#### usage
```bash
chmod +x ./scripts/runros.sh
./scripts/runros.sh
```

## Nodes
Nodes are objects of communication.

```bash
# run node
ros2 run examples_rclcpp_minimal_publisher publisher_lambda
ros2 run examples_rclcpp_minimal_subscriber subscriber_lambda

# check running nodes
ros2 node list

# check info about node (subscriber/publisher relate to topic)
ros2 node info /turtlesim

# changing node properties
ros2 run demo_nodes_cpp talker --ros-args -r __node:=abed -r __ns:=/abed -r chatter:=abed 

# run turtlesim
ros2 run turtlesim turtlesim_node
ros2 run turtlesim turtle_teleop_key

# show graph with communication
rqt_graph
rqt --standalone rqt_graph

# duplicate and mimic node
ros2 run turtlesim mimic
```

### Communication between nodes:
- topics
- services
- actions

## Topics 
Message bus/crossroad between nodes, run based on continues stream of data.

```bash
# basic commands
ros2 topic list
ros2 topic list -t
ros2 topic info /turtle1/cmd_vel

# listen to topic /turtle1/cmd_vel messages
ros2 topic echo /turtle1/cmd_vel

# show information about message type
ros2 interface show geometry_msgs/msg/Twist

# result example of message type:
Vector3  linear
        float64 x
        float64 y
        float64 z
Vector3  angular
        float64 x
        float64 y
        float64 z

# send command to topic /turtle1/cmd_vel in form of geometry_msgs/msg/Twist message with some values
ros2 topic pub /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 1, y: 1, z: 0}, angular: {x: 0, y: 0, z: 3.14}}"

# run command just once
ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 1, y: 1, z: 0}, angular: {x: 0, y: 0, z: 3.14}}"

#run command every second
ros2 topic pub --rate 1 /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 1, y: 1, z: 0}, angular: {x: 0, y: 0, z: 3.14}}"

# get information about rate of commands
ros2 topic hz /turtle1/cmd_vel
```

## services
One time request/response between client and server.

```bash
ros2 service list

#print types of services
ros2 service list -t

# find services of specific type
ros2 service find std_srvs/srv/Empty

# interface information
ros2 interface show turtlesim_msgs/srv/Spawn

# example of service use
ros2 service call spawn turtlesim_msgs/srv/Spawn "{x: 2, y: 2, theta: 3.14}"
```

## actions
Similar to services communication but it's stream of request/response.


```bash
# list actions
ros2 action list

# info about certain action (turtle rotation demo)
ros2 action info /turtle1/rotate_absolute

# information about interface (get type first then get interface information)
ros2 action list -t
ros2 interface show turtlesim_msgs/action/RotateAbsolute

# send goal and do some action (e.g. rotate by absolute 3.14)
ros2 action send_goal {action} {action type} {value} --feedback
ros2 action send_goal /turtle1/rotate_absolute turtlesim_msgs action/RotateAbsolute "{theta: 3.14}" --feedback
```

## Basic Commands

### packages
Package is a source code with node, topics, etc. logic definitions and configuration for build and installation.
Mostly is written in c++ or python. For minimal package creation it is necessary to define just CMakeList.txt and package.xml and soucer code.

#### basic architecture

- ROS2 Underlay - base framework packages
- ROS2 Overlay - custom packages

####  basic commands

```bash
# list available packages
ros2 pkg --help
ros2 pkg list
ros2 pkg executables
```

#### examples
```bash
# prepare workspace
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws

# download examples from github
git clone https://github.com/ros2/examples src/examples -b lyrical

# build all packages in worksapce
colcon build --symlink-install

# test
colcon test

# run some package node
ros2 run examples_rclcpp_minimal_publisher publisher_lambda
```

### params 
Configurable parameter for specific node.

```bash
# list available parameter list (like background color)
ros2 param list

# get parameter
ros2 param get /turtlesim background_b

# set value of parameter
ros2 param set /turtlesim background_b 200

# store parameter of node to file
ros2 param dump /turtlesim > turtlesim.yaml

# load parameters during startup
ros2 run turtlesim turtlesim_node --ros-args --params-file turtlesim.yaml
```

### bags
Used for recording of topic messages, services, actions, etc.

```bash
# run turtlesim and teleop
ros2 turtlesim turtlesim_node
ros2 run turtlesim turtle_teleop_key
ros2 topic list

# record topic messages
ros2 bag record -o dataset1 --topics /turtle1/cmd_vel /turtle/pose

# show metadata information about record
ros2 bag info dataset1

# replay stored record (check turtlesim during execution)
ros2 bag play dataset1
```