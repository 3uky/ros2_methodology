# ros2_methodology

## how to start
### learning sources

- Main source is [official ros2 documentaiton](https://docs.ros.org/en/lyrical/index.html)
- This is link to [Robotogeddon youtube tutorial](https://www.youtube.com/watch?v=QfFnljTrRlQ&list=PLNw2RD-1J5YZbyWXCpas9zPJldfphPi4Q&index=1&pp=iAQB)
 - ros2 docker images [osrf/docker_images](https://github.com/osrf/docker_images)
### instalation and ros2 execution with docker
```bash
#!/bin/bash
# Grant docker container access to x server
xhost +local:docker

# Run ROS2 container with X11 forwarding, docker image is created from open-source robotic foundation source if it's first run
docker run -it \
  --env DISPLAY=$DISPLAY \
  --env QT_X11_NO_MITSHM=1 \
  --volume /tmp/.X11-unix:/tmp/.X11-unix \
  osrf/ros:lyrical-desktop-full bash

# After container end return previous access 
xhost -local:docker

# in instance init ros2 environment (you can access ros2 commands)
source /opt/ros/lyrical/setup.bash
```

### package commands

```bash
# list available packages
ros2 pkg --help
ros2 pkg list
ros2 pkg executables
```

## Nodes
Nodes are objects of communication.

```bash
# run node
ros2 run examples_rclcpp_minimal_publisher publisher_lambda
ros2 run examples_rclcpp_minimal_subscriber subscriber_lambda

# check running nodes
ros2 node list

# changing node properties
ros2 run demo_nodes_cpp talker --ros-args -r __node:=abed -r __ns:=/abed -r chatter:=abed 

# run turtlesim
ros2 run turtlesim turtlesim_node
ros2 run turtlesim turtle_teleop_key
rqt_graph
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

## params 
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