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

apt install -y v4l-utils ffmpeg apache2 apache2-utils mariadb-server php8.2 php8.2-curl php8.2-cli php8.2-xml php8.2-mysql libxml2-dev composer npm git ufw

# Program pull then split frontend into necessary folder
git clone https://git.cool-home.duckdns.org/alzy/pypi-camera.git /opt/pypi-camera
git clone https://git.cool-home.duckdns.org/alzy/pypi-web.git /var/www/html/pypi-web

## Backend

# Pull correct script version
if [[ "$target" == "rpi" ]]; then
   cp /opt/pypi-camera/src/pi-sw-max.py /opt/pypi-camera/main.py
elif [[ "$target" == "generic" ]]; then
   cp /opt/pypi-camera/src/gen-sw-max.py /opt/pypi-camera/main.py
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

# Folder creation for backend
mkdir /camera
chmod -R 777 /camera

## Frontend

# Web server module set up
a2enmod proxy proxy_http proxy_wstunnel rewrite ssl

# Web server config set up
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
cp /opt/pypi-camera/configs/000-default.conf /etc/apache2/sites-available/000-default.conf

# MariaDB User Password generation
password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 15)

# Database and user creation
mariadb -u root -e "CREATE DATABASE pypi; CREATE USER 'pypi'@'localhost' IDENTIFIED BY '$password'; GRANT ALL PRIVILEGES ON pypi.* TO 'pypi'@'localhost';"

# Laravel set up
COMPOSER_ALLOW_SUPERUSER=1 composer install -d /var/www/html/pypi-web
npm install --prefix /var/www/html/pypi-web

# Make .env file and insert password
sed "s/REPLACEME/${password}/g" /opt/pypi-camera/configs/.env > /var/www/html/pypi-web/.env

# API Key and Database propagation
php /var/www/html/pypi-web/artisan key:generate
php /var/www/html/pypi-web/artisan migrate:fresh --seed

# NPM build
npm run build --prefix /var/www/html/pypi-web

# Symlink camera clips folder into server root
ln -s /camera/ /var/www/html/pypi-web/public/camera

## Security

# Firewall install and set up

ufw allow 22 comment SSH
ufw allow 80 comment HTTP
ufw allow 443 comment HTTPS
ufw allow 8554 comment RTSP

ufw default deny incoming
ufw default allow outgoing
ufw enable

# HTTPS set up
openssl req -x509 -nodes -days 3652 -newkey rsa:4096 -keyout /etc/apache2/ssl/local.key -out /etc/apache2/ssl/local.crt -subj "/C=GB/ST=West Yorkshire/L=Leeds/O=Pypi/OU=Pypi-Camera/CN=localhost"

## Finalization

# Change perms for web directory
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# Component start and enable
systemctl enable apache2.service
systemctl enable mediamtx.service
systemctl enable pypi-camera.service
systemctl restart apache2.service
systemctl start mediamtx.service
systemctl start pypi-camera.service

# Finishing messages
echo "#############################################"
echo "Installation complete"
echo "It is recommended that you restart the system"
echo "KEEP THIS PASSWORD SAFE"
echo "PyPi MySQL Password is: ${password}"
echo "#############################################"