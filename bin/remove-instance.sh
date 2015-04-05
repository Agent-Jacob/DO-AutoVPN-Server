#!/bin/bash
#
# By Chris Blake (chrisrblake@gmail.com)
# Digital Ocean instance remove script
#
exec > >(tee /root/terminate.log)
exec 2>&1

DO_TOKEN=$(cat /root/.do_apikey)
INSTANCE_ID=$(curl -s http://169.254.169.254/metadata/v1/id)

# Always run as we want to self-destroy when we are empty for 15 minutes
echo "Starting Termination Daemon"
while true; do
	connectcount=0
	echo 'Connect count is $connectcount'
	# Is anyone connected?
	if [$(netstat -n | grep -e ESTABLISHED | grep 443 | wc -l) -lt 1]
	then
		echo 'No user connected, ticking...'
		connectcount=$connectcount+1
		sleep 60
		return
	else
		echo 'User is connected, sleeping'
		sleep 60
	fi
	if [$connnectcount -gt 15]
	then
		echo 'Threshold met, terminating self...'
		curl -X DELETE -H 'Content-Type: application/json' -H 'Authorization: Bearer $DO_TOKEN' "https://api.digitalocean.com/v2/droplets/$INSTANCE_ID"
		sleep 600
	fi
done
