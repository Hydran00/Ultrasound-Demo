# ICRA PAPER

## Requirements
- CUDA 12
- Zed SDK
- ROS2 Humble
- [SMPL model](https://smpl.is.tue.mpg.de/download.php)
- Docker image for SKEL reconstruction  
  ```docker pull hydran00/skel```

## Installation
### Body Modelling (Docker)
- Launch docker container
  ```
  docker run  --rm -dti --name "skel" -e DISPLAY=$DISPLAY --net=host --ipc=shareable --gpus all -v ~/Ultrasound_ws/body_modelling/:/home/ -v ~/Ultrasound_ws/body_modelling/memory_mapped_folder:/home/mmap/ hydran00/skel
  ```
- Install the local dependencies in the docker container 
  ```
  cd /home/
  pip install -U pip   
  python3.8 -m venv skel_venv
  source skel_venv/bin/activate
  pip install git+https://github.com/mattloper/chumpy
  cd SKEL
  pip install -e .
  pip install git+https://github.com/MPI-IS/mesh.git  
  ```
- Unzip the SMPL model using the script
    ```
    python scripts/setup_smpl.py /path/to/SMPL_python_v.1.1.0.zip  
    ```
### Body Modelling (local)
- Build the zed ros workspace that contains the body segmentation node and the zed wrapper (with the `.xacro` of the camera).
    ```
    sudo apt update
    cd ~/Ultrasound_ws/body_modelling/ros2_ws
    rosdep update
    rosdep install --from-paths src --ignore-src -r -y
    colcon build --symlink-install --cmake-args=-DCMAKE_BUILD_TYPE=Release
    ```

## Run the experiments
### Launch the robot controller 
Enter sudo mode
```
sudo su
```
Calibrate the haptic interface
```
source ros_source.sh
ros2 launch haptic_control auto_calibration.launch.py
```
Enter the guy
```
cd gui/
python3 main.py
```
And press the `Follower Launcher` button.
### Launch the body modelling

