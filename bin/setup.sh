#!/bin/bash
#
# DO-AutoVPN Droplet Setup Script
# By: Chris Blake (chrisrblake@gmail.com)
#

# Are we root?
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 1>&2
  exit 1
fi

# Set our env settings (these are randomly sent to us vi the meta info)
HTTPS_PORT=$1
AUTH_PW=$2
DO_APIKEY=$3

# Save our key to a file for later usage (to remove self)
echo $DO_APIKEY > /root/.do_apikey

# Install required packages for python
apt-get install -qy python python-openssl 

SERVER_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

# Setup key for Python Client
openssl req -new -x509 -keyout py-server.pem -out py-server.pem -days 365 -subj /CN=$SERVER_IP/ -nodes

# Setup OpenVPN
chmod +x ./openvpn.sh && ./openvpn.sh

# Copy over the client config
cp /etc/openvpn/client.ovpn ./client.ovpn

# Startup the self destruct script
cp ./remove-instance.sh /usr/bin/remove-instance.sh && chmod +x /usr/bin/remove-instance.sh
/usr/bin/remove-instance.sh &

# Serve up the HTTPS server so the config can be pulled
./handoff-server.py $HTTPS_PORT admin:$AUTH_PW

# Finish
echo "setup.sh Complete!"