#!/bin/bash
export IMAGE="ubuntu-20-04-x64"
export USERDATA="opengapps-build.sh"
export REGION="sgp1"
export SIZE="s-4vcpu-8gb"
export HOSTNAME="arm-29-micro"

echo "Running $USERDATA on $REGION:$IMAGE:$SIZE with hostname $HOSTNAME"
echo "Started at `date`"
export STARTTIME=`date +%s`
echo "Provisioning droplet..."
export SSHKEYS=`doctl compute ssh-key list --no-header --format ID | tr '\n' ',' | sed 's/,$/\n/'`
export IP=$( set -x; doctl compute droplet create $HOSTNAME --ssh-keys $SSHKEYS --region $REGION --size $SIZE --image $IMAGE --user-data-file $USERDATA --wait --no-header --format PublicIPv4 )
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
	sleep 10
done
echo
export FN=`curl http://$IP 2>/dev/null | grep "BUILD COMPLETE" | awk '{print $3}'`
wget http://$IP/build.zip -O $FN
echo Build complete, deleting droplet
$(set -x; doctl compute droplet delete -f $HOSTNAME)
echo "Finished at `date`"
export ENDTIME=`date +%s`
echo "Total run time: $(($ENDTIME-$STARTTIME))"
echo -n "Total (estimated) cost: USD $"
doctl compute size list | grep $SIZE | awk '{print $5}' | while read p; do python3 -c "print(($p/2592000)*($ENDTIME-$STARTTIME))"; done
