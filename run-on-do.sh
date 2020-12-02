#!/bin/bash
if [ $# -eq 0 ]; then
	export makeparam="arm-29-micro"
else
	export makeparam="$1"
fi
echo "Building opengapps with $makeparam"
echo "Provisioning droplet..."
export IP=`doctl compute droplet create $makeparam --region sgp1 --size s-4vcpu-8gb --image ubuntu-20-04-x64 --user-data-file opengapps-build.sh --wait | tail -n1 | awk '{print $3}'`
echo Droplet at $IP, waiting for connection
until (curl http://$IP/log 2>/dev/null >/dev/null); do
	sleep 1
done
until (curl http://$IP 2>/dev/null | grep "BUILD COMPLETE" >/dev/null); do
	echo "Full log: http://$IP"
	echo $NEXTLOG
	sleep 2
	export NEXTLOG="`curl http://$IP/log 2>/dev/null | tail`"
	clear
done
export FN=`curl http://$IP 2>/dev/null | grep "BUILD COMPLETE" | awk '{print $3}'`
wget http://$IP/build.zip -O $FN
echo Build complete, deleting droplet
doctl compute droplet delete -f $makeparam
