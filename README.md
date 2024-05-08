# Run Global Meteor Network RMS software in a container

## Run RMS on any system
*NOTE:* For Raspberry, it is advisable to use an (USB3 connected) SSD as storage.

*NOTE:* The current pre-built image is only for ARM64 (Raspberry Pi 4/5). For other architectures the container image will be built locally by the ``install`` script.


### Introduction

There are several good ways to get a Global Meteor Network RMS camera running. Those are documented at https://globalmeteornetwork.org/wiki/index.php?title=Advanced_RMS_installations_and_Multi-camera_support

If you are have never worked with a command prompt, that is probably the best option. But if you have some hardware bought, or lying arond that doesn't meet the prerequisistes named in those manuals, this might provide a solution.

A container resembles a virtual system. It run's its own copy of an operating system, where you can install the software. There are several container platforms out there. This method will be using Podman (https://podman-desktop.io). Most modern Linux distributions come with Podman and Podman can also be installed on Windows and MacOS systems. This means that alle these platforms can be used to run the RMS software.

The advantage of running RMS in a container is that you can create a safe and stable environment that is running and maintaining itself in the background. With the containers it is also very easy to connect multiple cameras to one system. The starting point for this manual is a running system. If you need to connect your RMS camera to you computer directly, please follow the chapter 'Configuring the Network" from this manual https://docs.google.com/document/d/19ImeNqBTD1ml2iisp5y7CjDrRV33wBeF9rtx3mIVjh4/edit#heading=h.cb2mnfqghp6u

If your computer has less than 4GB of internal memory (like on the low end Raspberries), it might be wise to make sure there is ample swap space to augment the internal memory. See the chapter "Increase swap memory to 1 GB" from the mentioned manual.

The remainder of the manual assumes a Debian Bookworm based system, like a Raspberry 5. The ``Dockerfile`` and ``startup.sh`` from the *podman* directory can also be used to run the container on other platforms. 


### Preparing your environment
The first thing to do is to download this repository and use its install script to prepare the environment.
```
sudo apt-get update && sudo apt-get install git && cd ~ && git clone https://github.com/lancer73/rms_container && bash rms_container/install_scripts/install
```

Now prepare to run the container for the first time. Go into the ``rms_container`` folder and edit the ``docker-compose.yml`` file with your favorite editor.
The file initially looks like this:
```
# This file is used to start the containers for all your cameras
# Make sure all the nescessary camera config directories extist under
# RMS_data.
#
# Add an instance for each camera and then do: podman-compose up -d
# from the directory where this file is.
#
# REPLACE CAMERANAME with the names you received for your cameras
#
services:
  [CAMERANAME1]:
    image: docker.io/lancer73/rms
    container_name: [CAMERANAME1]
    hostname: [CAMERANAME1]
    restart: on-failure:2
    volumes:
      - /home/[MYUSER]/rms_container/[CAMERANAME1]:/root
    tmpfs:
      - /tmp:size=512m

#
#  CAMERANAME2:
#    image: docker.io/lancer73/rms
#    container_name: [CAMERANAME2]
#    hostname: [CAMERANAME2]
#    restart: on-failure:2
#    volumes:
#      - /home/[MYUSER]/rms_container/[CAMERANAME2]:/root
#      - proc/diskstats:/proc/diskstats:ro
#    tmpfs:
#      - /tmp:size=512m
```

Replace *[CAMERANAME1]* with your camera name and *[MYUSER]* with your user name. If you have multiple camera's repeat the same saction for each camera. For instance:
```
services:
  xx001d:
    image: docker.io/lancer73/rms
    container_name: xx001d
    hostname: xx001d
    restart: on-failure:2
    volumes:
      - /home/lancer73/rms_container/xx001d:/root
    tmpfs:
      - /tmp:size=512m
```

### Prepare camera configuration
Each camera needs it own configuration files. These are all created in the ``~/rms_container`` directory. To get the basic configuration files you need to run the container once. This will setup the RMS software and create the basic configurations:
```
cd ~/rms_container && podman-compose up
```

The image will download and setup RMS. After first setup the image will quit so you can edit your configuration files. 

The file you will need to edit is ``~/rms_container/[CAMERANAME1]/source/RMS/.config`` and you will need to send ``~/rms_container/[CAMERANAME1]/.ssh/id_rsa`` to Denis Vida or put your existing ssh key in that place. 

If you have an existing ``platepar_cmn2010.cal`` file and mask, you can put it in ``~/rms_container/[CAMERANAME1]/source/RMS``, or you can observe the first night and then create them (see Global Meteor Network wiki; https://globalmeteornetwork.org//wiki/index.php?title=Main_Page#Using_SkyFit2_to_perform_astrometric_and_photometric_calibration_+_Manually_reducing_observations_of_fireballs_and_computing_their_trajectories:)

When reading the Global Meteor Network wiki (https://globalmeteornetwork.org/wiki) you can follow all instructions there, but note that our directory paths are slightly different. Insert ``/rms_container/[CAMERANAME1]`` after the home directory of all paths. For instance ``~/source/RMS`` and ``/home/rms/vRMS/bin`` will become ``~/rms_container/[CAMERANAME1]/source/RMS`` and ``/home/rms/rms_container/[CAMERANAME1]/vRMS/bin``. For additional cameras substitute the proper cameraname in the path.


### Running the containers
The last step is running the containers. To do this:
```
cd ~/rms_container && podman-compose up -d
```

If you want to stop the containers:
```
cd ~/rms_container && podman-compose down
```

If you want to see if the containers are running:
```
podman ps
```
You should see a line for each station (camera).

If you want to see the live output of the container for station xx001d, then do:
```
podman logs -f xx001d
```
You can close the output with ctrl-c

### Start the containers at boot
To start the containers at boot, do:
```
bash ~/rms_container/install_scripts/startatboot
```

This will create a systemctl script for each station (camera) and start it at boot. At 12:22 each day each container will be restarted to pull in the latest RMS updates. Individual containers can be started and stopped with ``systemctl --user start container-xx001d`` and ``systemctl --user stop container-xx001d``

You can also start stop and update all containers with the scripts ``start_rms``, ``stop_rms`` and ``update_rms`` in the ``rms_container`` directory.

Use the scripts like:
```
bash ~/rms_container/update_rms
```

Reboot the computer and check that the RMS container starts after boot.

### Addon utilities (optional)
There are a couple of utilities which might be good to have. Those are:
1) cmn_binviewer, for viewing the captured files
2) Skyfit2, to create the platepar files and to use in orbit calculations
3) cameracontrol, to set camera settings from your Raspberry
4) showlivestream, to have a live view of the camera image

Scripts are provided to install those tools for all users.

#### Install cmn_binviewer
```
cd ~/rms_container/install_scripts
sudo bash install_cmn_binviewer
```

#### Install Skyfit2, cameracontrol and showlivestream
```
cd ~/rms_container/install_scripts
sudo bash install_skyfit2 [MYUSER]
```

After running the script the following commands are available:
1) skyfit2_[CAMERANAME1]
2) cameracontrol_[CAMERANAME1]
3) showlivestream_[CAMERANAME1]
