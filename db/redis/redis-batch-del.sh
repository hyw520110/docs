#!/bin/bash

REDIS_HOME=/usr/local/redis-cluster
REDIS_PORT=7000

TMP_FILE=/home/keys.tmp

function findKey(){
  $REDIS_HOME/bin/redis-cli -c -p $REDIS_PORT keys "*"${1}"*" >> $TMP_FILE
}

function delKeys(){
  for key in `cat $TMP_FILE`
  do
		echo del key: $key
		$REDIS_HOME/bin/redis-cli -c -p $REDIS_PORT  del $key
  done
  rm -rf $TMP_FILE
}

if [ -f "$1" ];then
  for i in `cat $1`
  do
		#$REDIS_HOME/bin/redis-cli -c -p $REDIS_PORT keys ${1}"*" |awk '{print $1}' | xargs $REDIS_HOME/bin/redis-cli -c -p $REDIS_PORT  del
		findKey $i 
  done  
else
 [ ! -n "$1" ] && echo "useage $0 keyword or keyFile" 
 findKey $1 
fi

delKeys 	
	
	
	
