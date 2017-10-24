#简介

zookeeper是一个分布式的开源框架，能够提供高性能的分布式服务，应用场景涉猎：数据发布与订阅；软负载均衡；命名服务；分布式通知/协调；集群管理和master选举；分布式锁和分布式队列等等
 
有两种运行的模式：Standalone模式和Distributed模式

#单机模式（7步）
##Step1：
- 配置JAVA环境。检验方法：执行java -version和javac -version命令。

##Step2：
- 下载并解压zookeeper。http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.3/，（更多版本：http://dwz.cn/37HGI
）最终生成目录类似结构：/home/admin/taokeeper/zookeeper-3.4.3/bin

##Step3：
- 重命名 zoo_sample.cfg文件

		mv /home/admin/taokeeper/zookeeper-3.4.3/conf/zoo_sample.cfg  zoo.cfg
##Step4：
- vi zoo.cfg，修改
	
		dataDir=/home/admin/taokeeper/zookeeper-3.4.3/data
##Step5：
- 创建数据目录：
	
		mkdir /home/admin/taokeeper/zookeeper-3.4.3/data
	 

##Step6：
- 启动zookeeper：执行

		/home/admin/taokeeper/zookeeper-3.4.3/bin/zkServer.sh start

##Step7：
- 检测是否成功启动：执行

		/home/admin/taokeeper/zookeeper-3.4.3/bin/zkCli.sh 或 echo stat|nc localhost 2181
 
#集群模式（8步）

zookeeper集群有两个重要的角色:分别是Leader和Follower，所以集群中的每个节点之间需要相互的通信，在没有内部DNS解析的前提下，需要在zookeeper集群的每个节点上配置/etc/hosts文件

##前三步和单机模式相同

##Step4：
- vi zoo.cfg，修改
	
		dataDir=/home/admin/taokeeper/zookeeper-3.4.3/data 

		server.1=1.2.3.4:2888:3888 
		server.2=1.2.3.5:2888:3888 
		server.3=1.2.3.6:2888:3888
这里要注意下server.1这个后缀，表示的是1.2.3.4这个机器，在机器中的server id是1，集群中的每台机器都需要感知整个集群是由哪几台机器组成的，在配置文件中，可以按照这样的格式，每行写一个机器配置：server.id=host:port:port. 关于这个id，我们称之为Server ID，标识host机器在集群中的机器序号，在每个ZK机器上，我们需要在数据目录（数据目录就是dataDir参数指定的那个目录）下创建一个myid文件，myid中就是这个Server ID数字，id的范围是1~255。。
##Step5：
- 创建数据目录：

		mkdir /home/admin/taokeeper/zookeeper-3.4.3/data

##Step6：
- 在标识Server ID.在/home/admin/taokeeper/zookeeper-3.4.3/data目录中创建文件 myid 文件，每个文件中分别写入当前机器的server id，例如1.2.3.4这个机器，在/home/admin/taokeeper/zookeeper-3.4.3/data目录的myid文件中写入数字1.
##Step7：
- 便捷启动zookeeper：

		/home/admin/taokeeper/zookeeper-3.4.3/bin/zkServer.sh start 
- 或执行：
	
		java -cp zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf org.apache.zookeeper.server.quorum.QuorumPeerMain zoo.cfg

	- 注意，不同的ZK版本，依赖的log4j和slf4j版本也是不一样的，请看清楚自己的版本后，再执行上面这个命令。QuorumPeerMain类会启动ZooKeeper Server，同时，JMX MB也会被启动，方便管理员在JMX管理控制台上进行ZK的控制。这里有对ZK JMX的详细介绍： http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html.  

##Step8：
- 检测是否成功启动： 
	
		/home/admin/taokeeper/zookeeper-3.4.3/bin/zkCli.sh 或 echo stat|nc localhost 2181
-当集群中的所有的节点的服务都启动后，我们可以观察各个节点的角色：
	- Zookeeper采用的是Leader election的选举算法，集群的运行过程中，只有一个Leader，其他的都是Follower，当Leader出现宕机或者其他的问题时，会从剩下的Follower节点中重新选举一个Leader。
		
			zkServer status

- java连接检测：

		java -cp zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf:src/java/lib/jline-0.9.94.jar   org.apache.zookeeper.ZooKeeperMain -server 127.0.0.1:2181


服务脚本：

	#!/bin/sh
	# chkconfig: 2345 11 11
	source /etc/profile.d/tomcat.sh
	PATH=/usr/local/bin:/sbin:/usr/bin:/bin
	PID=`ps aux | grep java | awk '/zookeeper/{print $2}'`
	
	case "$1" in
	    start)
	        if [  "${PID}" != "" ]
	        then
	                echo "Zookeeper server is already running"
	        else
	                echo "Starting Zookeeper server..."
	                /usr/local/zookeeper/bin/zkServer.sh start
	        fi
	        ;;
	    stop)
	        if [  "${PID}" = "" ];
	        then
	                echo "Zookeeper server is not running"
	        else
	
	                echo "Stopping ..."
	                kill -9  $PID
	                echo "Zookeeper server stopped"
	        fi
	        ;;
	    status)
	        if [ "${PID}" = "" ]; then
	            echo -e  "\033[33;1m *************************Service Zookeeper not started*************************\033[0m"
	        else
	            echo -e  "\033[31;1m *************************Service Zookeeper is running*************************\033[0m"
	        fi
	        ;;
	   restart|force-reload)
	        ${0} stop
	        ${0} start
	        ;;
	  *)
	    echo "Usage: /etc/init.d/zookeeper {start|stop|restart|status|force-reload}" >&2
	        exit 1
	esac


