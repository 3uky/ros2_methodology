from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='turtlesim',
            namespace='turtlesim1',
            executable='turtlesim_node',
            name='first',
        ),
        Node(
            package='turtlesim',
            namespace='turtlesim2',
            executable='turtlesim_node',
            name='second'
        ),
        Node(
            package='turtlesim',
            executable='mimic',
            name='mimic',
            remappings=[
                ('/input/pose', '/turtlesim1/turtle1/pose'),
                ('/output/cmd_vel', '/turtlesim2/turtle1/cmd_vel')
            ]

        )
    ])

# ros2 launch launch_file.py

# connect turtle teleop output for created /turtlesim1/turtle1 node
# ros2 run turtlesim turtle_teleop_key --ros-args -r /turtle1/cmd_vel:=turtlesim1/turtle1/cmd_vel