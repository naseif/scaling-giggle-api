#!/bin/bash
# I assume you are running in a vultr vm as root

# update the system so all is fresh
apt-get update
apt-get upgrade -y

# hosting the nodejs application using systemd

## install nodejs 14 lts
## from https://github.com/nodesource/distributions/blob/master/README.md
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

## install the service
cp scaling-giggle-env.service /lib/systemd/system/scaling-giggle-env.service

## we need to install the npm packages ... 
cd ..
npm i

## generate self signed ssl certificate
openssl genrsa -out key.pem
openssl req -new -key key.pem -out csr.pem
openssl x509 -req -days 9999 -in csr.pem -signkey key.pem -out cert.pem
rm csr.pem

## daemon stuff
systemctl daemon-reload
systemctl start scaling-giggle-env.service
systemctl enable scaling-giggle-env.service
