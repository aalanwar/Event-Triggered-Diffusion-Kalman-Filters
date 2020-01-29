# Event-Triggered-Diffusion-Kalman-Filters

Watch the video <br />
[![Watch the video](https://img.youtube.com/vi/IcBoE3KHGwQ/0.jpg)](https://youtu.be/IcBoE3KHGwQ)


This video is for localizing a Quadrotor in 9x10m lab. The used algorithm is Event-Triggered Diffusion Kalman Filter. The blue rectangular is the Quadrotor real position using the Motion Capture system. The red plus is the estimated positions of the Quadrotor. The ellipses are based on the diffusion error covariance matrix. The data and the code structure can be used in for testing other estimation and localization algorithms.<br /><br />

The used threshold is one for event-triggerred algorithm. 

To regenerate the video, follow these steps:<br />
1- run the main file "run_slatsCondMsg_Disekf_Thres_stopAll_ped01.m" which runs based on the real data at log ped01 in the logs folder <br /> 
2- Choose the list of threshold in line 4.<br />
"for ii=1", currently it is 1 only.<br />
3- set<br />
SAVEMOVIE = true;
at line 72 to save the generated movie under the video folder.<br />


The class folder has the main classes<br />
1- DataParserROS.m: parses the log files<br />
2- Measurement.m: each measurement in the log file would make a object of this class<br />
3- Node.m: every node would make an object of this class <br />
3- NetworkManager.m: distributes the measurements and the estimates between nodes <br />


If you use our code in academic work, please cite our [paper](https://arxiv.org/pdf/1609.00881.pdf):

```
@misc{eventtriggered,
    title={Event-Triggered Diffusion Kalman Filters},
    author={Amr Alanwar and Hazem Said and Ankur Mehta and Matthias Althoff},
    year={2020},
    booktitle={ICCPS'20: ACM/IEEE 11th International Conference on Cyber-Physical Systems (with CPS Week 2020),
    organization={IEEE Computer Society}
}
```
The early version of this code was in the following work in collaboration with Dr. Paul Martin.

```
@inproceedings{alanwar2017d,
  title={D-slats: Distributed simultaneous localization and time synchronization},
  author={Alanwar, Amr and Ferraz, Henrique and Hsieh, Kevin and Thazhath, Rohit and Martin, Paul and Hespanha, Joao and Srivastava, Mani},
  booktitle={Proceedings of the 18th ACM International Symposium on Mobile Ad Hoc Networking and Computing},
  pages={14},
  year={2017},
  organization={ACM}
}
```
