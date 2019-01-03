#!/bin/bash

echo "Libreoffice is starting"
/opt/libreoffice/libreoffice.sh restart
sleep 3600

ok=1
while [ $ok -le 2]
do
 echo "Restarting libreoffice instance"
 /opt/libreoffice/libreoffice.sh restart
 sleep 3600
done

