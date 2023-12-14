# MagPerch

Files and scripts used for the RoboSys 2023 Final Project to achieve magnetic perching on the CrazyFlie drone using the TinyMPC library.

`controller_tinympc.cpp` is the main firmware file that is running the TinyMPC controller. 

`perch.h` contains the generated perching trajectory which is flashed onto the drone.

`perch.py` is a script that uses the python Crazyflie API to command the drone to takeoff and switch control modes.

`quadrotor_traj.ipynb` is a Julia Jupyter notebook used to run the trajectory optimization and generate the `perch.h` file
