# Shared Control Virtual Fixtures 
Official code repository of "An Anatomy-Aware Shared Control Approach for Assisted
Teleoperation of Lung Ultrasound Examinations".

<b>Abstract</b>  
<i>The introduction of artificial intelligence and robotics in telehealth is enabling personalised treatment and supporting teleoperated procedures such as lung ultrasound, which has gained attention during the COVID-19 pandemic. Although fully autonomous systems face challenges due to anatomical variability, teleoperated systems appear to be more practical in current healthcare settings. This paper presents an anatomy-aware control framework for teleoperated lung ultrasound. Using biomechanically accurate 3D models such as SMPL and SKEL, the system provides a real-time visual feedback and applies virtual constraints to assist in precise probe placement tasks. Evaluations on five subjects show the accuracy of the biomechanical models and the efficiency of the system in improving probe placement and reducing procedure time compared to traditional teleoperation. The results demonstrate that the proposed framework enhances the physician's capabilities in executing remote lung ultrasound examinations, towards more objective and repeatable acquisitions.</i>
## Requirements
- CUDA 12
- Zed SDK
- ROS2 Humble
- [SMPL model](https://smpl.is.tue.mpg.de/download.php) and [SKEL model](https://skel.is.tue.mpg.de/download.php)
- [Open3d from source](https://www.open3d.org/docs/release/compilation.html)
- Docker image for SKEL reconstruction  
  ```docker pull hydran00/skel```


## Installation

<b>Note, this repository NEEDS to be cloned in the HOME directory and not renamed!</b>
```
git clone -b icra2024 git@github.com:Hydran00/Ultrasound-Demo.git
```
### Body Modelling (Docker)
- Launch docker container
  ```
  docker run  --rm -dti --name "skel" -e DISPLAY=$DISPLAY --net=host --ipc=shareable --gpus all -v ~/Ultrasound-Demo/body_modelling/:/home/ -v ~/Ultrasound-Demo/body_modelling/memory_mapped_folder:/home/mmap/ hydran00/skel
  ```
- Install the local dependencies in the docker container 
  ```
  docker exec -ti skel /bin/bash
  cd /home/
  apt-get update
  apt-get install pip
  pip install -U pip   
  python3.8 -m venv skel_venv
  source skel_venv/bin/activate
  pip install git+https://github.com/mattloper/chumpy
  cd SKEL
  pip install -e .
  pip install git+https://github.com/MPI-IS/mesh.git
  pip install matplotlib omegaconf
  ```
  These installed packages will be stored in the `skel_venv` folder therefore you don't need to commit the docker.
- Download and setup the SKEL model as explained [here](https://github.com/Hydran00/SKEL?tab=readme-ov-file#downloading-skel)
- Unzip the SMPL model using the script
    ```
    python scripts/setup_smpl.py /path/to/SMPL_python_v.1.1.0.zip  
    ```
  You should have this structure:
  ```
  -SKEL  
  |--models  
     |--skel_models_v1.1  
     |--smpl  
  ```
### Body Modelling (local)
- Build the zed ros workspace that contains the body segmentation node and the zed wrapper (with the `.xacro` of the camera).
    ```
    sudo apt update
    ```
    Init zed interfaces submodule
    ```
    cd ~/Ultrasound-Demo/body_modelling/ros2_ws/src/zed-ros2-wrapper
    ```
    ```
    git submodule init
    git submodule update
    ```
    ```
    cd ~/Ultrasound-Demo/body_modelling/ros2_ws/
    ```
    ```
    rosdep update
    rosdep install --from-paths src --ignore-src -r -y
    colcon build --symlink-install --cmake-args=-DCMAKE_BUILD_TYPE=Release
    ```

## Run the experiments
- Compile every ros workspace you find under any `leader` and `follower` folder. 
### Launch the robot controller 
- Enter sudo mode
```
sudo su
```
- Calibrate the haptic interface
```
source ros_source.sh
ros2 launch haptic_control auto_calibration.launch.py
```
- Run the robot controller (avoid loading the camera node since we will use a customized version)
```
source ros_source.zsh # or source ros_source.sh
ros2 launch follower_launcher follower_launcher.launch.py camera_type:=none
```

### Launch the body modelling pipeline
- Launch the docker container
```  
xhost +
docker run  --rm -dti --name "skel" -e DISPLAY=$DISPLAY --net=host --ipc=shareable --gpus all -v ~/Ultrasound-Demo/body_modelling/:/home/ -v ~/Ultrasound-Demo/body_modelling/memory_mapped_folder:/home/mmap/ hydran00/skel
docker exec -ti skel /bin/bash
# inside the docker terminal
cd /home
source skel_venv/bin/activate
cd SKEL
```
- Run the zed camera node in another terminal
```
source ros_source.zsh # or source ros_source.sh
ros2 launch yolo_seg body_publisher.launch.py
```
- Run the smpl fitting node in another terminal
```
source ros_source.zsh # or source ros_source.sh
ros2 launch yolo_seg body_publisher.launch.py
```
This should compute the SMPL model, when you see `waiting for skel mesh` proceed
- Fit the skel skeleton (in the docker terminal)
```
# inside the docker terminal
python examples/my_skel_fit.py
```
This should generate the SKEL object file that can be used to generate the virtual fixture mesh
```
ros2 run virtual_fixture virtual_fixture.py
```
### Launch the teleoperation with VFs
- Change the path of the meshes under `~/Ultrasound-Demo/leader/haption_ws/src/vf_control/config/parameters.yaml`
```
input_mesh_path: "/home/<username>/Ultrasound-Demo/body_modelling/ros2_ws/final_vf.obj"
skin_mesh_path: "/home/<username>/Ultrasound-Demo/body_modelling/ros2_ws/skin_mesh.obj"
output_mesh_path : "/home/<username>/Ultrasound-Demo/body_modelling/ros2_ws/final_vf2.obj"
```
Finally launch the teleoperation
```
ros2 launch vf_control vf.launch.py use_fixtures:=true
```

## Cite us
```
@misc{nardi2024anatomyawaresharedcontrolapproach,
      title={An Anatomy-Aware Shared Control Approach for Assisted Teleoperation of Lung Ultrasound Examinations}, 
      author={Davide Nardi and Edoardo Lamon and Luca Beber and Daniele Fontanelli and Matteo Saveriano and Luigi Palopoli},
      year={2024},
      eprint={2409.17395},
      archivePrefix={arXiv},
      primaryClass={cs.RO},
      url={https://arxiv.org/abs/2409.17395}, 
}
```
