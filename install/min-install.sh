#!/bin/bash

## Preparation

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
   echo "$0 must be run as root" 1>&2
   exit 1
fi

# System Update and Dependency install
apt update -y
apt upgrade -y

# Get Architecture
arch=$(uname -m)

# Check if target device is Raspberry Pi or Generic Computer
if [[ -f /sys/devices/virtual/dmi/id/product_name ]]; then
   # Generic
   target="generic"
elif [[ -f /sys/firmware/devicetree/base/model ]]; then
   # Raspberry Pi  (Installs Picamera2 for camera module)
   target="rpi"
   apt install -y python3-picamera2 --no-install-recommends
else
   echo "Error: Unable to determine system model."
   exit 1
fi

apt install -y v4l-utils ffmpeg git ufw

# Program pull then split frontend into necessary folder
git clone https://git.cool-home.duckdns.org/alzy/pypi-camera.git /opt/pypi-camera

## Backend

# Pull correct script version
if [[ "$target" == "rpi" ]]; then
   cp /opt/pypi-camera/src/pi-sw-min.py /opt/pypi-camera/main.py
elif [[ "$target" == "generic" ]]; then
   cp /opt/pypi-camera/src/gen-sw-min.py /opt/pypi-camera/main.py
else
   echo "Error: Unable to determine system model."
   exit 1
fi

# Make virtual environment and move backend files in
python -m venv /opt/pypi-camera --system-site-packages

# Python package installation and upgrade
/opt/pypi-camera/bin/pip install --upgrade pip opencv-python ai-edge-litert
# This is needed to use system level numpy because it's what Picamera2 expects. Otherwise, this does not need to be uninstalled
/opt/pypi-camera/bin/pip uninstall -y numpy

# Check which MediaMTX binary to pull
if [[ "$arch" == "x86_64" ]]; then
   wget https://github.com/bluenviron/mediamtx/releases/download/v1.11.3/mediamtx_v1.11.3_linux_amd64.tar.gz -O /tmp/mediamtx.tar.gz
elif [[ "$arch" == "aarch64" ]]; then
   wget https://github.com/bluenviron/mediamtx/releases/download/v1.11.3/mediamtx_v1.11.3_linux_arm64v8.tar.gz -O /tmp/mediamtx.tar.gz
else
   echo "Error: Unable to determine system model."
   exit 1
fi

# MediaMTX download and installation into /opt/mediamtx
tar -xvzf /tmp/mediamtx.tar.gz -C /tmp
mkdir /opt/mediamtx
mv /tmp/mediamtx /opt/mediamtx/
cp /opt/pypi-camera/configs/mediamtx.yml /opt/mediamtx/

# Move service files into systemd
cp /opt/pypi-camera/systemd/mediamtx.service /etc/systemd/system/
cp /opt/pypi-camera/systemd/pypi-camera.service /etc/systemd/system/

## Security

# Firewall install and set up

ufw allow 22 comment SSH
ufw allow 8554 comment RTSP

ufw default deny incoming
ufw default allow outgoing
ufw enable

## Finalization

# Component start and enable
systemctl enable mediamtx.service
systemctl enable pypi-camera.service
systemctl start mediamtx.service
systemctl start pypi-camera.service

# Finishing messages
echo "#############################################"
echo "Installation complete"
echo "It is recommended that you restart the system"
echo "#############################################"