zookeeper有dataDir和dataLogDir两个目录，分别用于snapshot和事务日志的输出（默认情况下只有dataDir目录，snapshot和事务日志都保存在这个目录中)


 正常运行过程中，ZK会不断地把快照数据和事务日志输出到这两个目录，并且如果没有人为操作的话，ZK自己是不会清理这些文件的，需要管理员来清理，这里介绍4种清理日志的方法。在这4种方法中，推荐使用第一种方法，对于运维人员来说，将日志清理工作独立出来，便于统一管理也更可控。毕竟zk自带的一些工具并不怎么给力，这里是社区反映的两个问题：

	https://issues.apache.org/jira/browse/ZOOKEEPER-957
	http://zookeeper-user.578899.n2.nabble.com/PurgeTxnLog-td6304244.html
第一种，也是运维人员最常用的，写一个删除日志脚本，每天定时执行即可：

	#!/bin/bash
    
	zk_home=/usr/local/zookeeper       
	#Leave 60 files
	count=60

	#snapshot file dir
	dataDir=$zk_home/data/version-2
	#tran log dir
	dataLogDir=$zk_home/logs/version-2
	#zk log dir
	logDir=$zk_home/logs
	
	count=$[$count+1]
	ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f
	ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f
	ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f

	#find /home/yinshi.nc/taokeeper/zk_data/version-2 -name “snap*” -mtime +1 | xargs rm -f 
	#find /home/yinshi.nc/taokeeper/zk_logs/version-2 -name “log*” -mtime +1 | xargs rm -f 
	#find /home/yinshi.nc/taokeeper/logs/ -name “zookeeper.log.*” -mtime +1 | xargs rm –f


以上这个脚本定义了删除对应两个目录中的文件，保留最新的60个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。


第二种，使用ZK的工具类PurgeTxnLog，它的实现了一种简单的历史文件清理策略，可以在这里看一下他的使用方法：
	
	http://zookeeper.apache.org/doc/r3.4.6/api/index.html
可以指定要清理的目录和需要保留的文件数目，简单使用如下：
	
	java -cp zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf org.apache.zookeeper.server.PurgeTxnLog <dataDir><snapDir> -n <count>
最后一个参数表示希望保留的历史文件个数，注意，count必须是大于3的整数。可以把这句命令写成一个定时任务，以便每天定时执行清理。

第三种，对于上面这个Java类的执行，ZK自己已经写好了脚本，在bin/zkCleanup.sh中，所以直接使用这个脚本也是可以执行清理工作的。

第四种，从3.4.0开始，zookeeper提供了自动清理snapshot和事务日志的功能，通过配置autopurge.snapRetainCount和 autopurge.purgeInterval 这两个参数能够实现定时清理了。这两个参数都是在zoo.cfg中配置的：
autopurge.purgeInterval  这个参数指定了清理频率，单位是小时，需要填写一个1或更大的整数，默认是0，表示不开启自己清理功能。
autopurge.snapRetainCount 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。