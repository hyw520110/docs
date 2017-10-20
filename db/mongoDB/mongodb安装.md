#简介
MongoDB有32bit和64bit：

	根据业界规则，偶数为“稳定版”（如：1.6.X，1.8.X），奇数为“开发版”（如：1.7.X，1.9.X)
	32bit的mongodb最大只能存放2G的数据，64bit就没有限制。

#安装配置

##windows安装配置

下载安装或解压(解压版)到指定目录完成安装

###创建数据目录

	mkdir data && cd data && mkdir db
###启动服务

	mongod --dbpath=d:\data\db
	或在安装目录下新建conf/mongod.conf
	dbpath=d:\data\db
	
	mongod -f ../conf/mongod.conf
根据启动提示，服务默认端口为27017，更多启动命令参数查看帮助：

	mongod -h


###安装服务

管理权限执行:
		
	mongod --bind_ip yourIPadress --logpath "xxx\logs\mongodb.log" --logappend --dbpath "xxx\db" --port 27017 --serviceName "mongodb" --serviceDisplayName "mongodb database" --install
参数说明：

	--bind_ip			绑定服务IP，若绑定127.0.0.1，则只能本机访问，不指定默认本地所有IP
	--logpath			定MongoDB日志文件，注意是指定文件不是目录
	--logappend			使用追加的方式写日志
	--dbpath				指定数据库路径
	--port				指定服务端口号，默认端口27017
	--serviceName		指定服务名称
	--serviceDisplayNam	指定服务名称，有多个mongodb服务时执行。
	--install			指定作为一个Windows服务安装。
或在配置文件中设置
	
	processManagement:
	    windowsService:
	        serviceName: mongodb
	      	displayName: mongo database
	      	description: mongo database service
	      	#serviceUser: root
	      	#servicePassword: admin


###MongoDB后台管理 Shell

cmd进入bin目录，执行：
	
	mongo
进入mongoDB后台后，它默认会链接到 test 文档（数据库）.MongoDB Shell是MongoDB自带的交互式Javascript shell,用来对MongoDB进行操作和管理的交互式环境，由于它是一个JavaScript shell，可以运行一些简单的算术运算(2+2)，db 命令用于查看当前操作的文档（数据库）.


###MongoDb web 用户界面

MongoDB 提供了简单的 HTTP 用户界面。 如果你想启用该功能，需要在启动的时候指定参数 --rest 。

	./mongod --dbpath=/data/db --rest

##linux安装


	mkdir /usr/local/mongodb/
	tar -xvf mongodb-linux-x86_64-rhel62-3.0.4.gz -C /usr/local/mongodb/
	mkdir /usr/local/mongodb/data/
	mkdir /usr/local/mongodb/log/

启动测试验证：
	
	cd /usr/local/mongodb/bin/
	./mongod --dbpath=/usr/local/mongodb/data/ --logpath=/usr/local/mongodb/log/mongo.log --fork
	./mongo

结束进程：

	ps -ef|grep mongodb
	kill -2 $pid

如启动警告：

	/sys/kernel/mm/transparent_hugepage/enabled is 'always'.
	We suggest setting it to 'never'
 	/sys/kernel/mm/transparent_hugepage/defrag is 'always'.
 	We suggest setting it to 'never'
解决办法：

	echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
	echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
###服务脚本：
	
	# chkconfig: 2345 60 60  
	# description:  The mongodb server service.  
	# processname: mongodb  
	#!/bin/sh  
	  
	# Source function library.  
	. /etc/rc.d/init.d/functions  
	  
	MONGODB_HOME=/usr/local/mongodb 
	  
	# Check that networking is up.  
	if [ "$NETWORKING" = "no" ]  
	then  
	    exit 0  
	fi  
	  
	RETVAL=0  
	prog="mongodb"  
	  
	start () {  
	    echo -n $"Starting $prog: "  
	    chmod +x $MONGODB_HOME/bin/mongod
	    $MONGODB_HOME/bin/mongod -f $MONGODB_HOME/conf/mongodb.cfg 
	    RETVAL=$?  
	    echo  
	    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/mongodb  
	}  
	stop () {  
	    echo -n $"Stopping $prog: "  
	    #killproc $prog
		kill -2 /var/run/mongodb.pid  
	    RETVAL=$?  
	    echo  
	    if [ $RETVAL -eq 0 ] ; then  
	        rm -f /var/lock/subsys/mongodb  
	        rm -f /var/run/mongodb.pid  
	    fi  
	}  
	  
	restart () {  
	    stop  
	    start  
	}  
	  
	  
	# See how we were called.  
	case "$1" in  
	    start)  
	        start  
	        ;;  
	    stop)  
	    stop  
	    ;;  
	    status)  
	    status mongodb  
	    ;;  
	    restart|reload)  
	    restart  
	    ;;  
	    condrestart)  
	    [ -f /var/lock/subsys/mongodb ] && restart || :  
	    ;;  
	    *)  
	    echo $"Usage: $0 {start|stop|restart}"    
	    exit 1  
	esac  
	  
	exit $?  

#配置文件

mongodb2.6版本后就是要yaml语法(每行使用空格缩进，不支持制表符)格式的配置文件

	systemLog:
	    #可以指定为“ file”或者“syslog”，表述输出到日志文件，如果不指定，则会输出到标准输出中（standard output）	
	    destination: file
	    #日志存放位置
	    path: /data/logs/mongod.log
	    #产生日志内容追加到文件,默认false
	    logAppend: true
	    ##防止一个日志文件特别大，可选项：rename(重命名日志文件，默认值);reopen(使用linux日志rotate特性，关闭并重新打开此日志文件，可以避免日志丢失，但是logAppend必须为true)  
	    logRotate: rename	
	    #日志级别0-5,默认0，1-5包含debug信息http://docs.mongoing.com/manual-zh/reference/log-messages.html#log-messages-configure-verbosity
	    #verbosity: 0
	    #在quite模式下会限制输出信息(会尝试减少日志的输出量)不建议在生产环境下开启，否则将会导致跟踪错误比较困难
	    #quiet: false
		#打印异常详细信息
	    #traceAllExceptions: false
	    #syslogFacility: user
	    #默认是iso8601-local，日志信息中还有其他时间戳格式：ctime,iso8601-utc,iso8601-local
	    #timeStampFormat: iso8601-local
	processManagement:
	    #以守护进程的方式运行MongoDB，创建服务器进程.默认 false	
	    fork: true
	    #pid文件路径	
	    pidFilePath: "/data/mongo-data/mongod.pid"
	net:
	    #绑定ip地址访问mongodb，多个ip逗号分隔,不指定则监听所有网卡	
	    # bindIp: 192.168.33.131
	    #监听端口
	    port: 27017
	    #默认65536，mongodb实例接受的最多连接数，如果高于操作系统接受的最大线程数，设置无效。
	    #maxIncomingConnections：60000
	    #当客户端写入数据时，mongos/mongod是否检测数据的有效性(BSON)，如果数据格式不良，此insert、update操作将会被拒 	
	    #wireObjectCheck: true
	    #是否支持mongos/mongod多个实例之间使用IPV6网络，默认值为false。此值需要在整个cluster中保持一致。   
	    #ipv6: false	
	    #unixDomainSocket:		 	
	        #enabled: true  
	        #pathPrefix: /tmp 
	        #filePermissions: 0700 	    
	    #3.2 版后已移除 HTTP
	    #http:
	  	    #enabled: false
	        #JSONPEnabled:	false
	        #即使http接口选项关闭，如果这个选项打开后会有更多的不安全因素
	        #RESTInterfaceEnabled: false
	    #ssl:
		    #2.6 版后已移除.
	        #sslOnNormalPorts: true
		    #2.6 新版功能.disabled、allowSSL、preferSSL、requireSSL
			#mode: disabled	
			#FIPSMode: false

	storage:
		#存储数据目录  
	    dbPath: "/data/mongo-data"
		#当构建索引时mongod意外关闭，那么再次启动是否重新构建索引；索引构建失败，mongod重启后将会删除尚未完成的索引，但是否重建由此参数决定。默认值为true。
		#indexBuildRetry: true
		#配合--repair启动命令参数，在repair期间使用此目录存储临时数据，repair结束后此目录下数据将被删除，此配置仅对mongod进程有效。不建议在配置文件中配置，而是使用mongod启动命令指定。  
		#repairPath: <string> 
	    journal:
		    #64位默认true，32位默认false.是否开启journal操作日志，防止数据丢失，journal日志用来数据恢复，是mongod最基础的特性，通常用于故障恢复。
	        enabled: true
			#日志提交间隔 默认100或30
			#commitIntervalMs: 30
		#将不同DB的数据，分子目录存储，基于dbPath，默认为false，如果在一个已存在的系统使用该选项，需要事先把存在的数据文件移动到目录。                             
	    directoryPerDB: true
		#使用fsync操作将数据flush到磁盘的时间间隔，默认值为60（单位：秒），建议不修改
		#syncPeriodSecs: 60
		#存储引擎，3.2后默认wiredTiger 可选 mmapv1    
		engine: wiredTiger
		#mmapv1:
		    #2.6. 已废弃  
		    #preallocDataFiles: true          
		    #nsSize: 16  
		    #quota:  
		        #enforced: false  
		        #maxFilesPerDB: 8  
		    #smallFiles: false  
		    #journal:  
		        #debugFlags: <int>
				#3.2 版后已移除  
		        #commitIntervalMs: <num>  
	    wiredTiger:
			#wt引擎配置
	        engineConfig:
				#GB，此值决定了wiredTiger与mmapv1的内存模型不同，它可以限制mongod对内存的使用量 .256 MB或50%
	            cacheSizeGB: 2
				#journal日志的压缩算法，可选值为none、zlib(注重压缩比)、snappy(注重速度压缩比不高)
				#journalCompressor： zlib
				#索引是否按数据库名进行单独存储,即index数据保存“index”子目录,collections数据保存在“collection”子目录。默认值为false，仅对mongod有效
	            directoryForIndexes: true
	    	collectionConfig:
				#collection数据压缩算法，可选值为none、zlib、snappy
	      	    blockCompressor: zlib
	    	indexConfig:
				#是否对索引数据使用“前缀压缩”（prefix compression，一种算法）。前缀压缩，对那些经过排序的值存储，有很大帮助，可以有效的减少索引数据的内存使用量。默认值为true。  
	            prefixCompression: true
			#inMemory:
      		    #engineConfig:
					#256MB to 10TB and can be a float
         	        #inMemorySizeGB: <number>    
	  
	operationProfiling:
		#指定慢查询时间，单位毫秒，如果打开功能，则向system.profile集合写入数据
	    slowOpThresholdMs: 100
		#默认off，可选值off、slowOp、all，分别对应关闭，仅打开慢查询，记录所有操作。 
	    mode: slowOp
	security:
	    #指定分片集或副本集成员之间身份验证的key文件存储位置
	    keyFile: "/data/mongodb-keyfile"
	    #集群认证模式，默认是keyFile 可选值为keyFile、sendKeyFile、sendX509、x509，对mongod/mongos有效；官方推荐使用x509,一般设置keyFile(比较易于学习和使用)   
	    clusterAuthMode: keyFile
		#仅对mongod有效.访问数据库和进行操作的用户角色认证
	    authorization: enabled
		#transitionToAuth: false
		#javascriptEnabled: true
		#redactClientLogData: false
		#enableEncryption: false
		#AES256-CBC、AES256-GCM
		#encryptionCipherMode: AES256-CBC
		#encryptionKeyFile:
		#kmip:
		    #keyIdentifier:
		    #rotateMasterKey: False
			#serverName: 
			#port: 5696
			#clientCertificateFile: 
			#clientCertificatePassword: 
			#serverCAFile:
		#sasl:
			#hostName:
			#serviceName:
			#saslauthdSocketPath:
		#ldap:
			#servers: <string>
      		#bind:
         	    #method: <string>
         		#saslMechanism: <string>
         		#queryUser: <string>
         		#queryPassword: <string>
         		#useOSDefaults: <boolean>
      		#transportSecurity: <string>
      		#timeoutMS: <int>
      		#userToDNMapping: <string>
      		#authz:
         		#queryTemplate: <string>  


	#auditLog:
		#syslog、console、file
        #destination: file
		#BSON、JSON
   		#format: BSON
   		#path: <string>
   		#filter: <string>
	#snmp:
   	    #subagent: true
   		#master: true
复制集配置(在以上基础配置上增加)
	
	#复制集相关配置
	replication:
		#默认为磁盘的5%,指定oplog的最大尺寸。对于已经建立过oplog.rs的数据库，指定无效	
	    oplogSizeMB: 50
		#指定副本集的名称
	    replSetName: "rs_zxl"
		#指定副本集成员在接受oplog之前是否加载索引到内存。默认会加载所有的索引到内存。none不加载;all加载所有;_id_only仅加载_id
	    secondaryIndexPrefetch: "all"
		#Enables read concern level of "majority".
		#enableMajorityReadConcern: false
	
分片复制集配置(在复制集配置的基础上)

	#分片配置
	sharding:
		#可选值:configsvr:Start this instance as a config server. The instance starts on port 27019 by default.、shardsvr:Start this instance as a shard. The instance starts on port 27018 by default.
	    clusterRole: shardsvr
config server 配置
	
	#分片配置
	sharding:
		#分片角色
		clusterRole: configsvr
mongos配置

	systemLog：
	  	destination: file
	  	path: /data/logs/mongos.log
	  	logAppend: true
	net:
	  	port: 27019
	sharding:
		#指定config server	
	  	configDB: 192.168.33.131:30000

#日志切割

所谓自动分割MongoDB日志文件，就是指Rotate MongoDB log files，即让MongoDB每天（或每个星期，可自定义控制）生成一个日志文件，而不是将MongoDB所有的运行日志都放置在一个文件中，这样每个日志文件都相对较小，定位问题也更容易。
实现自动分割MongoDB日志的方法可以参考：https://docs.mongodb.com/manual/tutorial/rotate-log-files/

配置文件指定logAppend: true 以及logRotate参数为rename

分割脚本

	#!/bin/bash  
	#Rotate the MongoDB logs to prevent a single logfile from consuming too much disk space.  
	  
	app=mongod  
	  
	mongodPath=/usr/local/mongodb/bin/  
	  
	pidArray=$(pidof $mongodPath/$app)  
	  
	for pid in $pidArray;do  
	if [ $pid ]  
	then  
	    kill -SIGUSR1 $pid  
	fi  
	done  
	  
	exit  

设置定时任务

	crontab -e

	59 23 * * * root /opt/scripts/logRotate.sh  
定时每天23:59以root身份执行脚本logRotate.sh，实现定时自动分割MongoDB日志 


#FAQ

启动报错：

	exited with error number 100
可查看日志获取更多错误信息，一般是由于没有正常关闭mongodb引起，需以修复的方式启动,首先先删除数据目录下的mongod.lock

然后以repair的模式启动：

	./mongod -f ../conf/28001.conf --repair
然后在启动：

	./mongod -f ../conf/28001.conf




mongodb教程：

	http://www.runoob.com/mongodb/mongodb-intro.html

mongodb3:

	http://www.runoob.com/w3cnote/runoob-mongodb-update-3.html

在MongoDB上使用Spark:

	http://www.2cto.com/database/201505/400727.html

配置：

	http://docs.mongoing.com/manual-zh/reference/method.html
	https://docs.mongodb.com/manual/reference/configuration-options/
	
