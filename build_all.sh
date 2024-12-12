cd follower/robot_setup/bota_ws && colcon build --symlink-install 
cd ../controller_ws && colcon build --packages-skip cartesian_controller_simulation cartesian_controller_tests --cmake-args -DCMAKE_BUILD_TYPE=Release
cd ../ur_ws && colcon build --symlink-install
cd ../../ros_ws_follower && colcon build --symlink-install
cd ../../leader/ros_ws_leader && colcon build --symlink-install
cd ../haption_ws && colcon build --symlink-install
cd ../../
