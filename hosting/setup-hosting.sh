#!/bin/bash

## update the server
apt-get update
apt-get upgrade -y

## install nginx from the package manager
apt install nginx -y
snap install powershell --classic

## Install duckdns (Thanks for whoever wrote this script!)

userHome=$(eval echo ~${USER})
duckPath="$userHome/duckdns"
duckLog="$duckPath/duck.log"
duckScript="$duckPath/duck.sh"

# Main Install ***
echo -ne "Enter your Duck DNS sub-domain name (e.g mydomain.duckdns.org) : "
read domainName
mySubDomain="${domainName%%.*}"
duckDomain="${domainName#*.}"
if [ "$duckDomain" != "duckdns.org" ] && [ "$duckDomain" != "$mySubDomain" ] || [ "$mySubDomain" = "" ]
then 
  echo "[Error] Invalid domain name. Program will now quit."
  exit 0
fi
# Get Token value
echo 
echo -ne "Enter your Duck DNS Token value : "
read duckToken
echo
# Display Confirmation
echo "Your fully qualified domain name will be : $mySubDomain.duckdns.org"
echo "Your token value is : $duckToken"
echo
echo -ne "Enter Y or Yes to continue [Y] :"
read confirmCont
if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
then 
  echo "Setup cancelled. Program will now quit."
  exit 0 
fi
# Create duck dir
if [ ! -d "$duckPath" ] 
then
  mkdir "$duckPath"
fi
# Create duck script file
echo "echo url=\"https://www.duckdns.org/update?domains=$mySubDomain&token=$duckToken&ip=\" | curl -k -o $duckLog -K -" > $duckScript
chmod 700 $duckScript
echo "Duck Script file created"
# Create Conjob
# Check if job already exists
checkCron=$( crontab -l | grep -c $duckScript )
if [ "$checkCron" -eq 0 ] 
then
  # Add cronjob
  echo "Adding Cron job for Duck DNS"
  crontab -l | { cat; echo "*/5 * * * * $duckScript"; } | crontab -
fi
# Test Setup
echo 
echo -ne "Update and Test your Duck DNS now ? Y/N [Y]: "
read confirmCont
if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
then 
  echo "Setup cancelled. Program will now quit."
  exit 0 
fi
# Run now
$duckScript
# Response
duckResponse=$( cat $duckLog )
echo "Duck DNS server response : $duckResponse"
if [ "$duckResponse" != "OK" ]
then
  echo "[Error] Duck DNS did not update correctly. Please check your settings or run the setup again."
else
  echo "Duck DNS setup complete."
fi


## Install LetsEncrypt

apt install socat ## socat for standalone server if you use standalone mode
echo -n "Provide your Email:  " 
read letsEncryptEmail
curl https://get.acme.sh | sh -s email=$letsEncryptEmail

mkdir -p /etc/nginx/ssl/$domainName
chmod 700 /etc/nginx/ssl

/root/.acme.sh/acme.sh --upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
# /root/.acme.sh/acme.sh --force --issue --nginx -d $domainName
systemctl stop nginx
/root/.acme.sh/acme.sh --force --issue --standalone -d $domainName --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
sleep 1
systemctl start nginx
/root/.acme.sh/acme.sh --force --install-cert -d $domainName --key-file /etc/nginx/ssl/$domainName/key.pem --fullchain-file /etc/nginx/ssl/$domainName/fullchain.pem --ca-file /etc/nginx/ssl/$domainName/chain.pem --reloadcmd "systemctl reload nginx"

## Set new nginx configuration
pwsh set-nginx.configuration.ps1 -domainName $domainName
