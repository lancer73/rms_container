# Run Global Meteor Network RMS software in a container

## Run RMS on any system
*NOTE:* Container images must be kept small. The RMS container images is not there yet. The compressed image size is currently around 1GB and uncompressed around 2.7GB. Use this installation methon only when your RMS station has a good Internet connection and if your RMS station has at least the storage performance of a USB3 SSD connected to a Raspberry Pi 4.

*NOTE:* The current pre-built image is only for ARM64 (Raspberry Pi 4/5). You can rebuild the image yoursef by issuing a ``podman build . -t rms:latest`` and modify the docker-compose.yml file accordingly.

*NOTE:* While the container works fine on a Raspberry 5, there is something not right on the Raspberry 4. It looks like it is working, but the fram drop rate from the camera feed varies between 10 and 50%.

### Introduction

There are several good ways to get a Global Meteor Network RMS camera running. Those are documented at https://globalmeteornetwork.org/wiki/index.php?title=Advanced_RMS_installations_and_Multi-camera_support

If you are have never worked with a command prompt, that is probably the best option. But if you have some hardware bought, or lying arond that doesn't meet the prerequisistes named in those manuals, this might provide a solution.

A container resembles a virtual system. It run's its own copy of an operating system, where you can install the software. There are several container platforms out there. This method will be using Podman (https://podman-desktop.io). Most modern Linux distributions come with Podman and Podman can also be installed on Windows and MacOS systems. This means that alle these platforms can be used to run the RMS software.

The advantage of running RMS in a container is that you can create a safe and stable environment that is running and maintaining itself in the background. With the containers it is also very easy to connect multiple cameras to one system. The starting point for this manual is a running system. If you need to connect your RMS camera to you computer directly, please follow the chapter 'Configuring the Network" from this manual https://docs.google.com/document/d/19ImeNqBTD1ml2iisp5y7CjDrRV33wBeF9rtx3mIVjh4/edit#heading=h.cb2mnfqghp6u

If your computer has less than 4GB of internal memory (like on the low end Raspberries), it might be wise to make sure there is ample swap space to augment the internal memory. See the chapter "Increase swap memory to 1 GB" from the mentioned manual.

The remainder of the manual assumes a Debian Bookworm based system, like a Raspberry 5. The ``Dockerfile`` and ``startup.sh`` from the *podman* directory can also be used to run the container on other platforms. 


### Preparing your environment
Before we start installing camera software your system needs to be prepared To start with, the system needs the Podman software. If you are running Windows or MacOS, get the software at https://podman-desktop.io. If you are running debian based Linux, like on a Raspberry Pi you can install podman as follows:
```
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install podman podman-toolbox podman-compose podman-docker
```

Now download the files from this GitHub repository into your home directory. You can do this with the command:
```
git clone https://github.com/lancer73/rms_container
```

The next step is to create a user under which the container should run. This is not a prerequisite, but it is a wise thing to do. Running it under a separate user will provide more stability since there is less chance of running wrong commands by accident or removing critical configuration files. When you are using Linux add that user in the following way (we are using "podman" for the user name, but this could also be something else):
```
sudo useradd -m podman
sudo passwd -l podman
sudo loginctl enable-linger podman
sudo su - podman -c "echo export XDG_RUNTIME_DIR=/run/user/`id -u` >> ~podman/.bashrc"
sudo echo podman >> /etc/cron.allow
```

With the ``passwd -l`` command the podman account is locked, so there is no external access to it. The other commands are making sure that containers keep running when you logout and to enable timed jobs.

If you want to access the podman account, login with your regular user and do ``sudo su - podman`` to work under the *podman* account.

The last step is to copy the nescessary files into the user directory which will be running the containers. All the files that are needed are located in the RMS_data directory. This directory was downloadd from the Github repository earlier. You can move it to the proper account like this (replace "podman" with your user if nescessary):
```
cd rms_container
sudo cp -r RMS_data /home/podman
sudo chown -R podman:podman /home/podman/RMS_data
sudo chmod u+x /home/podman/RMS_data/*_rms
sudo chmod u+x /home/podman/RMS_data/startatboot
```

When the containers are running all data will be stored in the "RMS_data" directory and can be read by your normal user, but not modified safeguarding the data. The only files that can be edited by the normal user are the base configuration files (we'll get to that later).

If you want to work under the "podman" account you can do so by issuing the following command:
```
sudo su - podman
```
and you can exit to your normal user by issuing the command ``exit``.

All the commands from this paragraph can also be executed by running the ``install`` script that was downloaded:
```
cd rms_container
sudo ./install podman
```

### Prepare camera configuration
Each camera needs it own configuration files. These are all created in the RMS_data directory of our podman user. The first step is to determine your location and the height of your camera above sea level. Note these details down somewhere. The next step is to generate a SSH key that will be used for uloading your results.

You can generate the SSH key with the following commands:
```
sudo su - podman
mkdir RMS_data/baseconfig/.ssh
chmod 700 RMS_data/baseconfig/.ssh
ssh-keygen -t rsa -m PEM -N "" -f RMS_data/baseconfig/.ssh/id_rsa
exit
```
If you have your camera's already running, copy your .ssh directory from the old installation into the ``RMS_data/baseconfig`` directory of the podman user.

If you just generated your SSH key, send the id_rsa.pub file from the ``RMS_data/baseconfig/.ssh`` directory to Denis Vida. Like the instructions on this page https://globalmeteornetwork.org/wiki/index.php?title=The_last_steps under the "Obtaining the station code" paragraph. Include the location in the mail and the number of camera's you will be running. You will receive your station codes in return.

When you have your station codes the camera configurations can be created. For each station do (replace STATIONID with your station id's):
```
sudo su - podman
cd RMS_data
mkdir STATIONID
mkdir STATIONID/config
cp -pr baseconfig/.ssh STATIONID/config
cp -pr baseconfig/.config STATIONID/config
chmod g+w baseconfig/docker-compose.yml
chmog g+w baseconfig/STATIONID/config/.config
exit
```

Now edit each config file to set the proper parameters. Set the location, the station id and your camera URL (you can determine your camera URL with the instructions on this page: https://globalmeteornetwork.org/wiki/index.php?title=Focusing_a_camera_and_the_first_tests). 

After the first night of operation you can determine your ``mask.bmp`` and ``platepar_cmn2010.cal`` files and copy them to the ``RMS_data/STATIONID/config`` directory and restart the container to activate the config (or wait for the automtic container reboot during the day). You can use your favourite graphical text editor to edit the configuration files if needed.

If you want to use your graphical editor add yourself to the "podman" group first by doing ``usermod -a -G podman [yourusername]``. Then logout and login again to activate this configuration.

The last step in the camera configuration is to prepare the configuration of the containers itself. To do this, modify the file ``RMS_data/baseconfig/docker-compose.yml``. If you have one camera with a station id of xx001d, then your docker-compose.yml should look like this (if you are using the user "podman"):
```
services:
  xx001d:
    image: docker.io/lancer73/rms
    container_name: xx001d
    hostname: xx001d
    restart: unless-stopped
    volumes:
      - type: bind
        source: /home/podman/RMS_data/xx001d
        target: /RMS_data
```

If you have two camera's xx001d and xx001e it should be:
```
services:
  xx001d:
    image: docker.io/lancer73/rms
    container_name: xx001d
    hostname: xx001d
    restart: unless-stopped
    volumes:
      - type: bind
        source: /home/podman/RMS_data/xx001d
        target: /RMS_data
  xx001e:
    image: docker.io/lancer73/rms
    container_name: xx001e
    hostname: xx001e
    restart: unless-stopped
    volumes:
      - type: bind
        source: /home/podman/RMS_data/xx001e
        target: /RMS_data
```

### Running the containers
The last step is running the containers. To do this:
```
sudo su - podman
cd RMS_data/baseconfig
podman-compose up -d
exit
```

If you want to stop the containers:
```
sudo su - podman
cd RMS_data/baseconfig
podman-compose down
exit
```

If you want to see if the containers are running:
```
sudo su - podman -c "podman ps"
```
You should see a line for each station (camera).

If you want to see the live output of the container for station xx001d, then do:
```
sudo su - podman -c "podman logs -f xx001d"
```
You can close the output with ctrl-c

### Start the containers at boot
To start the containers at boot, do:
```
sudo su - podman
cd ~/RMS_data
./startatboot
exit
```

This will create a systemctl script for each station (camera) and start it at boot. At 12:22 each day each container will be restarted to pull in the latest RMS updates. Individual containers can be started and stopped with ``sudo su - podman -c "systemctl --user start container-xx001d"`` and ``sudo su - podman -c "systemctl --user stop container-xx001d"``

You can also start stop and update all containers with the scripts ``start_rms``, ``stop_rms`` and ``update_rms`` in the ``RMS_data`` directory.

Use the scripts like:
```
sudo su - podman -c "./RMS_data/update_rms"
```

### Addon utilities
There are a couple of utilities which might be good to have. Those are:
1) cmn_binviewer, for viewing the captured files
2) Skyfit2, to create the platepar files and to use in orbit calculations
3) cameracontrol, to set camera settings from your Raspberry
4) showlivestream, to have a live view of the camera image

Scripts are provided to install those tools for all users.

#### Install cmn_binviewer
```
cd ~/rms_container
sudo ./install_cmn_binviewer
```

#### Install Skyfit2, cmaeracontrol and showlivestream
```
cd ~/rms_container
sudo ./install_skyfit2
```

After running the script the following commands are available for all users:
1) skyfit2_[stationid]
2) cameracontrol_[stationid]
3) showlivestream_[stationid]
