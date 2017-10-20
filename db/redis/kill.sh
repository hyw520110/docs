#!/bin/bash

#./redis.cli -p 7001 shutdown

PIDS=`ps -ef|grep redis |grep -v grep |grep -v 6379| awk '{print $2}'` && [ -n "$PIDS" ] && kill re
dis cluster process:$PIDS  && kill -9 $PIDS
                                       