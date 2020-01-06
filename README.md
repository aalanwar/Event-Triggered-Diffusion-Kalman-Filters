# Event-Triggered-Diffusion-Kalman-Filters

Watch the video
[![Watch the video](https://img.youtube.com/vi/IcBoE3KHGwQ/0.jpg)](https://youtu.be/IcBoE3KHGwQ)

This video is for localizing a Quadrotor in 9x10m lab. The used algorithm is Event-Triggered Diffusion Kalman Filter. The rectangular is the Quadrotor real position using the Motion Capture system. The red plus is the estimated positions of the Quadrotor. The ellipses are based on the diffusion error covariance matrix.  
The used threshold is 1. To regenerate the video:
1- run "run_slatsCondMsg_Disekf_Thres_stopAll_ped01.m" which runs based on the real data on log ped01 in the logs folder
2- Choose the list of threshold in line 4. "for ii=1", currently it is 1 only.
3- set
SAVEMOVIE = true;
at line 72
to save the generated movie under the video folder.




If you use our code in academic work, please cite our [paper](https://arxiv.org/pdf/1609.00881.pdf):

```
@misc{eventtriggered,
    title={Event-Triggered Diffusion Kalman Filters},
    author={Amr Alanwar and Hazem Said and Ankur Mehta and Matthias Althoff},
    year={2020},
    booktitle={ICCPS'20: ACM/IEEE 11th International Conference on Cyber-Physical Systems (with CPS Week 2020),
    organization={IEEE Computer Society}
}



