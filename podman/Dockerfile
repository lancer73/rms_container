MAINTAINER roel@gloudemans.info

FROM debian:bookworm
RUN apt-get update -y && apt-get upgrade -y
ENV DEBIAN_FRONTEND=noninteractive

# Put files into place
COPY startup.sh /startup.sh
RUN mkdir /source /RMS_data /Desktop
RUN echo 1 > /.rmsautorunflag

# Add the required packages
RUN apt install -y openssh-client git python3 python3-dev python3-tk python3-pip libblas-dev libatlas-base-dev liblapack-dev at-spi2-core libopencv-dev libffi-dev libssl-dev socat ntp libxml2-dev libxslt1-dev imagemagick ffmpeg gstreamer1.0* libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev build-essential libgtk-3-dev python3-virtualenv python3-pyasn python3-nacl python3-opencv python3-setuptools* python3-pypillowfight python3-pil python3-git* python3-scipy cython3* python3-cython* python3-astropy* python3-paramiko python3-matplotlib python3-fitsio inetutils-ping curl zip

# Create the python virtual environment with the required python modules
RUN virtualenv --system-site-packages /vRMS
ENV HOME /
RUN /bin/bash -c "source /vRMS/bin/activate && pip install asdf-unit-schemas && pip install numpy==1.23.5 && pip install pyephem && pip install imreg_dft && pip install configparser==4.0.2 && pip install imageio==2.6.1 && pip install pyqtgraph==0.12.4 && pip install python-dvr && pip install rawpy"

# Download the RMS sources
RUN cd /source && git clone https://github.com/CroatianMeteorNetwork/RMS.git

# Install RMS
RUN /bin/bash -c "source /vRMS/bin/activate && cd /source/RMS && python setup.py install && cd /source/RMS/Scripts && ./GenerateDesktopLinks.sh"

ENTRYPOINT ["/startup.sh"]
