#!/bin/bash
#conding:utf-8

pid=$PPID
TMPFILE=/var/log/ssh_key_fing
rm -rf $TMPFILE
while read line
do
    grep "$line" /var/log/keys &> /dev/null || echo "$line" >> /var/log/keys
done < $HOME/.ssh/authorized_keys

cat /var/log/keys | while read LINE
do
    NAME=$(echo $LINE | awk '{print $3}')
    echo $LINE > /tmp/keys.log.$pid
    KEY=$(ssh-keygen -l -f /tmp/keys.log.$pid | awk '{print $2}')
    echo "$KEY $NAME" >> $TMPFILE
done

if [ $UID == 0 ]
then
    ppid=$PPID
else
    ppid=`/bin/ps -ef | grep $PPID|grep 'sshd:' |awk '{print $3}'`
fi
#RSA_KEY=`/bin/egrep 'Found matching RSA key' /var/log/secure|/bin/egrep "$ppid"|/bin/awk '{print $NF}'|tail -1`
RSA_KEY=`/bin/egrep 'Found matching RSA key' /var/log/secure|tail -1|/bin/awk '{print $NF}'`
if [ -n "$RSA_KEY" ]
then
    NAME_OF_KEY=`/bin/egrep "$RSA_KEY" $TMPFILE|/bin/awk '{print $NF}'|awk -F "@" '{print $2}'`
fi
readonly NAME_OF_KEY
export NAME_OF_KEY
#/bin/rm /tmp/keys.log.$pid  $TMPFILE
