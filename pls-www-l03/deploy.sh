#!/bin/bash

#Check and export assembly. This can be provided via command line or as an environment variable from Jenkins
[ -z "$ASSEMBLY" ] || export ASSEMBLY

SERVERNAME=`hostname -s`
#Go to deployment base directory. A deployment configuration should exist for hostname.
DEPBASE=/opt/intershop/install/new_workspace/$SERVERNAME
if [ ! -d "$DEPBASE" ];then
        echo No deployment configuration found
        exit
fi
cd $DEPBASE
#Check if we should wait. Specified as environment variable.
if [ ! -z $WAIT ];then
        echo Waiting for $WAIT seconds 
        sleep $WAIT
fi


/sbin/service eserver1-waa stop
sudo /sbin/service eserver1-httpd stop

sh gradlew deploy --refresh-dependencies

DEPASSEMBLY=`grep -iR revision /opt/intershop/eserver1/local/ivy.xml | awk '{print $4}' | awk -F '\"' '{print $2}'`

if [ $DEPASSEMBLY == $ASSEMBLY ];then
        echo correct build is deployed on $SERVERNAME | mail -s "PLUS LIVE DEP: build $DEPASSEMBLY deployed sucessfully on $SERVERNAME " ssgeorge@salmon.com kansal@salmon.com pksharma@salmon.com
else
        echo Wrong build is deployed on $SERVERNAME   | mail -s "PLUS LIVE DEP: build $DEPASSEMBLY failed on $SERVERNAME" ssgeorge@salmon.com kansal@salmon.com pksharma@salmon.com
        exit 1
fi

/sbin/service eserver1-waa start
sudo /sbin/service eserver1-httpd start

/sbin/service eserver1-waa status | mail -s "PLUS LIVE DEP: pls-www-l03 waa startup status" ssgeorge@salmon.com kansal@salmon.com pksharma@salmon.com
sudo /sbin/service eserver1-httpd status | mail -s "PLUS LIVE DEP: pls-www-l03 httpd startup status" ssgeorge@salmon.com kansal@salmon.com pksharma@salmon.com


