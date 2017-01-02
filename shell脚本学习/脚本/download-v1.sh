#!/bin/bash
#

M="www.178linux.com"

for j in {1..9}
do
  uri="http://$M/date/2016/0$j"
  curl ${uri}|grep  -o "$M/[0-9]\{1,\}"|sed  '/61385/,/62743/d'|uniq >$j.page
  for i in {2..30}
  do
     URI=${uri}/page/$i
     curl ${URI} > 178linux
     c=`sed -nr '/<title>/s/<title>(.*)<\/title>/\1/p' 178linux|sed -e 's@[[:punct:]]@@g' -e 's/[0-9]//g' -e 's/linux运维部 落//g' -e 's/^M//g'`
     c=`echo $c|grep -o "未找到页面"`
     [ $c = "未找到页面" ] && break
     echo 178linux|grep  -o "$M/[0-9]\{1,\}"|sed  '/61385/,/62743/d'|uniq>>$j.page 
     sleep $i
  done
done
#sed -nr '/<title>/s/<title>(.*)<\/title>/\1/p' a.html|sed -e 's@[[:punct:]]@@g' -e 's/[0-9]//g' -e 's/linux运维部落//g'
