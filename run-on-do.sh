#!/bin/bash
if [ $# -eq 0 ]; then
	export makeparam="arm-29-micro"
else
	export makeparam="$1"
fi
echo "Building opengapps with $makeparam"
echo "Provisioning droplet..."
export SSHKEYS=`doctl compute ssh-key list --no-header --format ID | tr '\n' ',' | sed 's/,$/\n/'`
export IP=$( set -x; doctl compute droplet create $makeparam --ssh-keys $SSHKEYS --region sgp1 --size s-4vcpu-8gb --image ubuntu-20-04-x64 --user-data-file opengapps-build.sh --wait --no-header --format PublicIPv4 )
echo -n "Droplet at $IP, waiting for connection"
until (curl http://$IP/log 2>/dev/null >/dev/null); do
	echo -n "."
	sleep 1
done
echo
echo "Full log: http://$IP"
echo -n "Build running"
until (curl http://$IP 2>/dev/null | grep "BUILD COMPLETE" >/dev/null); do
	echo -n "."
	sleep 1
#	curl http://$IP/log 2>/dev/null | tail -n10
#	sleep 2
#	echo -en '\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K\e[1A\e[K' # set cursor ten lines before, clearing those lines
done
echo
export FN=`curl http://$IP 2>/dev/null | grep "BUILD COMPLETE" | awk '{print $3}'`
wget http://$IP/build.zip -O $FN
echo Build complete, deleting droplet
$(set -x; doctl compute droplet delete -f $makeparam)
