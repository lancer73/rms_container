# Run Global Meteor Network RMS software in a container

## Run RMS on any system

### Introduction

There are several good ways to get a Global Meteor Network RMS camera running. Those are documented at https://globalmeteornetwork.org/wiki/index.php?title=Advanced_RMS_installations_and_Multi-camera_support

If you are have never worked with a command prompt, that is probably the best option. But if you have some hardware bought, or lying arond that doesn't meet the prerequisistes named in those manuals, this might provide a solution.

A container resembles a virtual system. It run's its own copy of an operating system, where you can install the software. There are several container platforms out there. This method will be using Podman (https://podman-desktop.io). Most modern Linux distributions come with Podman and Podman can also be installed on Windows and MacOS systems. This means that alle these platforms can be used to run the RMS software.

The advantage of running RMS in a container is that you can create a safe and stable environment that is running and maintaining itself in the background. With the containers it is also very easy to connect multiple cameras to one system. The starting point for this manual is a running system. If you need to connect your RMS camera to you computer directly, please follow the chapter 'Configuring the Network" from this manual https://docs.google.com/document/d/19ImeNqBTD1ml2iisp5y7CjDrRV33wBeF9rtx3mIVjh4/edit#heading=h.cb2mnfqghp6u

If your computer has less than 4GB of internal memory (like on the low end Raspberries), it might be wise to make sure there is ample swap space to augment the internal memory. See the chapter "Increase swap memory to 1 GB" from the mentioned manual.

The remainder of the manual assumes a Debian Bookworm based system, like a Raspberry 5. The ``Dockerfile`` and ``startup.sh`` from the *podman* directory can also be used to run the container on other platforms. 


### Install Podman
Most Linux distributions have packages for podman. You can install it on Debian Bookworm like this:
```
sudo apt-get update
sudo apt-get upgrade -y
apt-get install podman podman-toolbox podman-compose podman-docker
```

Packages on other Linux platforms will be named similarly, or you canget the podman software here: https://podman-desktop.io

You might want to consider running the pods as a different user from your normal user account. This prevents accidents and make sure the containers keep running and that the data will not be compromised. If you want to run the container under a different user, on Linux do:
```
useradd -m podman
passwd -l podman
loginctl enable-linger podman
echo export XDG_RUNTIME_DIR=/run/user/`id -u podman` >> ~podman/.bashrc
```
The last command locks the *podman* account, so there is no remote access to it. If yoo want to access the podman account, login with your regular user and do ``sudo su - podman`` to work under the *podman* account.

### Install the container
To run the container, we first need to build the container image. Then we can create as many containers from the image as we like. 

Create a separate directory under the account you will be using to run the containers and download the Dockerfile and startup.sh from this repository.
```
sudo su - podman
git clone https://github.com/lancer73/rms_container
cd rms_container/podman
podman build . -t rms:latest
```

This will take a while. You can confirm your image exists with ``podman images``. For this to work you need to be in the *podman* account.

To be able to access RMS data and configuration, we keep those outside of the container. For instance in the directory ~/RMS_data. Each camera needs its own container. In the following example our fictitios RMS camera has id *xx000a*. You can substitute whis with your own camera id. If you have more than one camera, repeat these instructions for each. Note, as we didn't exit the podman account after the previous instructions ``sodu su - podman`` is omitted from the codeblock below.

```
mkdir -p /RMS_data/xx000a/config
```
This *config* directory needs to hold:
1) .config
2) .ssh
3) platepar_cmn2010.cal
4) mask.bmp

When the *config* directory has been created we can finally create and run the container:
```
podman create --mount=type=bind,source=/home/podman/RMS_data/xx000a,destination=/RMS_data --name=xx000a rms:latest
```

Now verify the container has been created with ``podman ps -a``

You can start and stop the container with ``podman start xx000a`` and ``podman stop xx000a`` (under the podman account). You can access the camera data under */home/podman/RMS_data/xx000a* from any account. 

### Run the container at boot
It is possible to start the container automatically at system boot and restart it when it stops for some reason.

If you are not working under the *podman* account, become *podman* first by ``sudo su - podman``. Execute the following commands to start the container at boot, again with our fictitious *xx000a* camera. Replace this with your own camera ID's.

```
mkdir -p ~/.config/systemd/user
podman generate systemd --new --name xx000a -f
systemctl --user daemon-reload
systemctl --user enable container-xx000a.service
```

It might be wise to restart the container daily to automatically apply updates of the RMS software. In the *podman* account do ``crontab -e`` and add the following line:
```
22 12 * * * podman stop xx000a
```
Which stops the container daily at 12:22. Systemd will then detect the container as crashed and will automatically restart.

And make sure *podman* is allowed to have cron jobs by adding *podman* to ``/etc/cron.allow``. You can do this as your regular user by executing:
```
sudo sh -c "echo podman > /etc/cron.allow"
```

## Give me an easier way
Fine, 

```
sudo su -
apt update && apt upgrade -y && apt install git
git clone https://github.com/lancer73/rms_container
cd rms_container
chmod 755 install
./install podman
```
And follow the instructions.
Afterwards communicate ``/home/podman/RMS_data/baseconfig/.ssh/id_rsa.pub`` to the said mail address and edit your configurations in ``/home/podman/RMS_data/[stationname]/config``.
If you need to edit the configuration, or start and/or stop the containers become user *podman* first (``sudo su - podman``)

The scripts will also create the following commands:
1) cmn_binviewer
2) skyfit2_[cameraname]
3) cameracontrol_[cameraname]
4) showlivestream_[cameraname]
For all users in the system. You can start these commands from the command prompt.

When your camera configurations are correct, start the container with:
```
podman start [cameraname]
```

You can view the start output by issuing (and exit with the ctrl-p ctrl-q keycombos):
```
podman attach [cameraname]
```

If the container is running properly, you can start the container at boot by running the script  ``~/startatboot [cameraname]``

Now reboot the system.

After the system has booted you can verify everything is running properly by executing:
```
sudo su - podman
systemctl --user status container-[cameraname].service
```




 



