#/bin/bash
#
cat >> /etc/profile.d/java << EOF
export JAVA_HOME=/usr/java/latest
export CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=$PATH:$JAVA_HOME/bin
EOF

for i in {1..3}
do
	scp /root/jdk-8u112-linux-x64.rpm node0$:/usr/src
	ssh node0$i "rpm -ivh jdk-8u112-linux-x64.rpm"
	scp /etc/profile.d/java.sh node0$:/etc/profile.d/
done
