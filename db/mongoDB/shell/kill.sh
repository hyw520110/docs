ps -ef|grep mongo |grep -v grep |awk '{print $2}' |xargs kill -9 
