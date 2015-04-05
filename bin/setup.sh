#!/bin/bash
#
# DO-AutoVPN Droplet Setup Script
# By: Chris Blake (chrisrblake@gmail.com)
#
set -e

# Are we root?
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 1>&2
  exit 1
fi

# Set our auth PW (used later)
AUTH_PW = $1

# Install required packages for python
apt-get install -qy python python-openssl 

# Setup key for Python Client
openssl req -new -x509 -keyout py-server.pem -out py-server.pem -days 365 -subj /CN=Python-Server/ -nodes

# Setup OpenVPN
chmod +x ./openvpn.sh && ./openvpn.sh

# Copy over the client config
cp /etc/openvpn/client.ovpn ./client.ovpn

# Serve up the HTTPS server
./handoff-server.py 1221 admin:$AUTH_PW

# Config is downloaded, we are good to go!