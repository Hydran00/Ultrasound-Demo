git submodule update --init --recursive
cd follower/robot_setup && colcon build --symlink-install 
cd ../../ros_ws_follower && colcon build --symlink-install
cd ../../leader/ros_ws_leader && colcon build --symlink-install
cd ../haption_ws && colcon build --symlink-install
cd ../../
