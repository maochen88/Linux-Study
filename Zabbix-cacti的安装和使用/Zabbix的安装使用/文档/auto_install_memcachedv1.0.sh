#!/bin/bash
#author itnihao
#version 1.0
#date 2012-08-04
#mail itnihao@qq.com
#source http://code.google.com/p/auto-task-pe/


green='\e[0;32m'
red='\e[0;31m'
blue='\e[0;36m'
blue1='\e[5;31m'
NC='\e[0m'
soft_PATH=$(pwd)
libevent_version=libevent-2.0.19-stable.tar.gz
memcached_version=memcached-1.4.13.tar.gz
libevent_url=https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
memcached_url=http://memcached.googlecode.com/files/memcached-1.4.13.tar.gz


function install_libevent {
cd ${soft_PATH}
[ ! -e ${libevent_version} ]; stats=$?
[ "$stats" == 0 ] && echo -e "${red} there is not ${libevent_version} file${NC}" && wget --no-check-certificate ${libevent_url}
tar zxvf ${libevent_version}
cd $(echo $libevent_version|sed "s/.tar.gz//g")
./configure
[ "$?" != 0 ] && echo -e "${red}configure libevent error,please check${NC}" && exit 1
make
[ "$?" != 0 ] && echo -e "${red}  make    libevent error,please check${NC}" && exit 1
make install;stats=$?
[ "$stats" != 0 ] && echo -e "${red}make install libevent error,please check${NC}" && exit 1
[ "$stats" == 0 ] && echo -e "${green}install ${libevent_version} is OK........${NC}"
}

function install_memcached {
cd ${soft_PATH}
echo ${soft_PATH}
[ ! -e ${memcached_version} ];stats=$?
[ "$stats" == 0 ]  && echo -e "${red} there is not ${memcached_version} file${NC}" && wget ${memcached_url}
tar xvf ${memcached_version} 
cd $(echo $memcached_version|sed "s/.tar.gz//g")
./configure
[ "$?" != 0 ] && echo -e "${red}configure memcached error,please check${NC}" && exit 1
make
[ "$?" != 0 ] && echo -e "${red}  make    memcached error,please check${NC}" && exit 1
make install;stats=$?
[ "$stats" != 0 ] && echo -e "${red}make install memcached error,please check${NC}" && exit 1
[ "$stats" == 0 ] && echo -e "${green}install ${memcached_version} is OK........${NC}"
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig
/usr/local/bin/memcached  -m 32m -p 11211 -d -u root -P /var/run/memcached.pid -c 1024
echo -e "${blue}now,memcached is running and used this command \"/usr/local/bin/memcached  -m 32m -p 11211 -d -u root -P /var/run/memcached.pid -c 1024\"${NC}"
}

install_libevent
install_memcached
