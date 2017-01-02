#!/bin/bash
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 说明： 此脚本用于装有RHEL6服务器的SSH远程登录安全及系统优化的
# 运行此脚本前请给与脚本执行权限： chmod +x 1-ssh_safe.sh
# 运行此脚本后SSH端口号会由默认端口号22改为12345
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#1. 删除系统特殊的的用户帐号和组帐号：
userdel adm
userdel lp
userdel sync
userdel shutdown
userdel halt
userdel news
userdel uucp
userdel operator
userdel games
userdel gopher
groupdel adm
groupdel lp
groupdel news
groupdel uucp
groupdel games
groupdel dip
sleep 1

#2.用户密码长度和时效设置：最小密码长度设为8，最短有效期为360天
# PASS_MAX_DAYS 99999 ##密码设置最长有效期（默认值）
# PASS_MIN_DAYS 0 ##密码设置最短有效期
# PASS_MIN_LEN 5 ##设置密码最小长度
# PASS_WARN_AGE 7 ##提前多少天警告用户密码即将过期。
cd /etc/
cp login.defs login.defs_bak
sed -i "s/PASS_MIN_LEN    5/PASS_MIN_LEN    8/g" login.defs
sed -i "s/PASS_MIN_DAYS   0/PASS_MIN_DAYS   360/g" login.defs
sleep 1

#3.自动注销帐号时间设置：10分钟无任何操作则自动注销
cd /etc/
cp profile profile_bak
sed '48a\TMOUT=600' profile
sleep 1

#4.修改ssh端口和禁止root远程登录：修改端口为12345
cd /etc/ssh
cp sshd_config sshd_config_bak
echo "Backup $p/ssh_config.conf successful"
sleep 1
sed -i "s/#Port 22/Port 12345/g" sshd_config
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" sshd_config
sleep 1

#5.关闭不使用的服务：
cd /etc/init.d/
mv apmd apmd.old				 	##笔记本需要
mv netfs netfs.old 					## nfs客户端
mv yppasswdd yppasswdd.old 			## NIS服务器，此服务漏洞很多
mv ypserv ypserv.old 				## NIS服务器，此服务漏洞很多
mv dhcpd dhcpd.old 					## dhcp服务
mv portmap portmap.old 				##运行rpc(111端口)服务必需
mv lpd lpd.old 						##打印服务
mv nfs nfs.old 						## NFS服务器，漏洞极多
mv sendmail sendmail.old 			##邮件服务, 漏洞极多
mv snmpd snmpd.old 					## SNMP，远程用户能从中获得许多系统信息
mv rstatd rstatd.old 				##避免运行r服务，远程用户可以从中获取很多信息
mv atd atd.old 						##和cron很相似的定时运行程序的服务
chkconfig --level 35 bluetooth off  #蓝牙无线通讯
chkconfig --level 35 cpuspeed  off  #cpu速度调节，常用于laptop
chkconfig --level 35 cups  off  	#通用unix打印服务
chkconfig --level 35 ip6tables  off #ipv6防火墙

#6.给系统服务端口列表加锁：主要是防止未经许可的删除或添加服务
cd /etc/
cp services services_bak
sleep 1
chattr +i services

#7.修改init目录文件执行权限：
chmod -R 700 /etc/init.d/*

#8.修改部分系统文件的SUID和SGID的权限：
#cd ~
chattr +a .bash_history #避免删除.bash_history或者重定向到/dev/null
chattr +i .bash_history
#chmod 700 /usr/bin       ## 恢复 chmod 555 /usr/bin
#chmod 700 /bin/ping      ## 恢复 chmod 4755 /bin/ping
#chmod 700 /usr/bin/vim   ## 恢复 chmod 755 /usr/bin/vim
#chmod 700 /bin/netstat   ## 恢复 chmod 755 /bin/netstat
#chmod 700 /usr/bin/tail  ## 恢复 chmod 755 /usr/bin/tail
#chmod 700 /usr/bin/less  ## 恢复 chmod 755 /usr/bin/less
#chmod 700 /usr/bin/head  ## 恢复 chmod 755 /usr/bin/head
#chmod 700 /bin/cat       ## 恢复 chmod 755 /bin/cat
#chmod a-s /usr/bin/chage
#chmod a-s /usr/bin/gpasswd
#chmod a-s /usr/bin/wall
#chmod a-s /usr/bin/chfn
#chmod a-s /usr/bin/chsh
#chmod a-s /usr/bin/newgrp
#chmod a-s /usr/bin/write
#chmod a-s /usr/sbin/usernetctl
#chmod a-s /usr/sbin/traceroute
#chmod a-s /bin/mount
#chmod a-s /bin/umount
#chmod a-s /bin/ping
#chmod a-s /sbin/netreport

#9.修改系统引导文件：
cd /etc
cp grub.conf grub.conf_bak 
chmod 600 /etc/grub.conf
chattr +i /etc/grub.conf
sleep 1

#10.防止IP欺骗
cd /etc
cp host.conf host.conf_bak
echo "order bind, hosts" >> /etc/host.conf #order指定选择服务的顺序
echo "multi off" >> /etc/host.conf         #multi指定主机能不能有多个IP地址
echo "nospoof on" >> /etc/host.conf        #nospoof指定不允许IP伪装

#11.隐藏服务器系统信息
mv /etc/issue /etc/issue_bak
mv /etc/issue.net /etc/issue.net_bak
sleep 1

#12.防止ping:
cd /etc/rc.d/
cp rc.local rc.local_bak
echo "echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all" >>rc.local
sleep 1

#13.禁止Ctrl+Alt+Del重启：
cd /etc/init/
cp -p control-alt-delete.conf control-alt-delete.conf_bak
echo "file  bakeup success"
sed -i "s/start/#start/g" control-alt-delete.conf
sed -i "s/exec/#exec/g" control-alt-delete.conf
echo "Modify $p/control-alt-delete.conf   successful"
sleep 1

#14.禁止IP源路径路由
echo "for f in /proc/sys/net/ipv4/conf/*/accept_source_route; do
      echo 0>$f
      done" >>/etc/rc.d/rc.local

#15.资源限制
#为了避免服务攻击，需要对系统资源的使用做一些限制。
#编辑/etc/security/limits.conf,加入如下改变
#cd /etc/security/
# echo "* hard core 0" >>limits.conf    #禁止创建core文件
# echo "* hard rss  5000" >>limits.conf #除root外，其他用户最多使用5M内存
# echo "* hard nproc 20" >>limits.conf  #最多进程限制为20
#编辑/etc/pam.d/login,在文件尾部加上：
#echo "session required /lib/security/pam_limits.so" >>/etc/pam.d/login

#16.保护TCP SYN Cookie：防止SYN Flood攻击
# echo 1 >/proc/sys/net/ipv4/tcp_syncookies


