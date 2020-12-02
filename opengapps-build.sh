#!/bin/bash

mkdir -p /var/www/html
ln -s /var/log/cloud-init-output.log /var/www/html/log
apt-get -y update
apt-get -y install nginx
git clone https://github.com/ukhas/js-logtail /var/www/logtail
mv /var/www/logtail/* /var/www/html/

apt-get -y install software-properties-common
apt-add-repository ppa:maarten-fonville/android-build-tools
apt-get -y install openjdk-8-jdk build-essential lzip git zip git-lfs bc android-build-tools-installer
export HOSTNAME=$(curl -s http://169.254.169.254/metadata/v1/hostname)
git clone https://github.com/opengapps/opengapps /var/www/html/opengapps
cd /var/www/html/opengapps
curl https://github.com/opengapps/opengapps/commit/f45c00cd0433583257c26947a8e6809e1b2a8ba0.diff | git apply
./download_sources.sh --shallow ${HOSTNAME%%-*}
make $HOSTNAME
export fn=$(cd /var/www/html/opengapps/out; ls *-UNOFFICIAL.zip)
echo "BUILD COMPLETE $fn" > /var/www/html/index.html
ln -s /var/www/html/opengapps/out/$fn /var/www/html/build.zip
