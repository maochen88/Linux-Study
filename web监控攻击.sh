#!/bin/bash
#


while true;do
   echo  """`grep -v "^\:\:" /var/log/httpd/access_log|awk -v dateTime="$datetimes" '{if($1==dateTime){i=1}if(i=1){dateArry[$1]++}}END{for(j in dateArry){printf "%s %s\n",j,dateArry[j]}}'`"""|awk '{if($2>=200){system("iptables -A INPUT -j REJECT -p tcp --dport 80 -s "$1)}}' 
   #awk '{if($2>=20){system("echo " $1)}}'
   #awk '{if($2>=20){system("iptables -A INPUT -j REJECT -p tcp --dport 80 -s "$1)}}'
   datetimes=`date +%y-%m-%d-%H-%M-%s`
   echo "$datetimes" >> /var/log/httpd/access_log
   sleep 30
done
