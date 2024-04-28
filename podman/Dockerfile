MAINTAINER roel@gloudemans.info

FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /

COPY startup.sh /startup.sh
COPY install_rms.sh /install_rms.sh

RUN chmod 755 /startup.sh && \
    chmod 755 /install_rms.sh && \
    apt update -y && \
    apt upgrade -y && \
    apt install --no-install-recommends -y python3-virtualenv \
    build-essential \ 
    cython3 \
    libcairo-gobject2 \ 
    libcairo-script-interpreter2 \
    libcairo2-dev \
    libcairo2 \
    ffmpeg \
    libgirepository-1.0-1 \
    libgirepository1.0-dev \
    libgstreamer-opencv1.0-0 \
    libgstreamer-plugins-bad1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    gstreamer1.0-python3-plugin-loader \
    gstreamer1.0-rtsp \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    cmake \
    gobject-introspection \
    libopencv-core* \
    libopencv-video* \
    libopencv-objdetect* \
    libopencv-ml* \
    python3-cython* \
    python3-opencv \
    python3-dev \
    python3-tk \
    openssh-client \
    git \
    libblas-dev \
    libatlas-base-dev \
    liblapack-dev \
    imagemagick \
    inetutils-ping \
    curl \
    zip \
    sudo && \
    apt clean && \
    mkdir /source && \
    cd /source && \
    git clone https://github.com/CroatianMeteorNetwork/RMS.git

RUN ./install_rms.sh

ENTRYPOINT ["/startup.sh"]
