#!/bin/bash

## update the server
apt-get update
apt-get upgrade -y

## install nginx from the package manager
apt install nginx -y

## Install duckdns

userHome=$(eval echo ~${USER})
duckPath="$userHome/duckdns"
duckLog="$duckPath/duck.log"
duckScript="$duckPath/duck.sh"

# Remove Option
case "$1" in
	remove)
	    echo -ne "Un Install Duck DNS (Y/N) [Y] :"
      read confirmCont
      if [ "$confirmCont" != "Y" ] && [ "$confirmCont" != "Yes" ] && [ "$confirmCont" != "" ] && [ "$confirmCont" != "y" ]
        then 
          echo "Setup cancelled. Program will now quit."
          exit 0 
      fi
      # Remove Duck DNS files
      rm -R $duckPath
      # Remove Cron Job
      crontab -l >/tmp/crontab.tmp
      sed -e 's/\(^.*duck.sh$\)//g' /tmp/crontab.tmp  | crontab
      rm /tmp/crontab.tmp  
      echo "Duck DNS removed"
      exit 0        
	;;
	
esac

# Main Install ***
# Get sub domain 
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


