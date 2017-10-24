zk服务命令:

	启动ZK服务:        bin/zkServer.sh start
	查看ZK服务状态:  	  bin/zkServer.sh status
	停止ZK服务:        bin/zkServer.sh stop
	重启ZK服务:        bin/zkServer.sh restart 	

zk客户端命令：

连接命令：

	./zkCli.sh -timeout 0 -r -server ip:port
- -timeout表示当前会话的超时时间，zookeper依靠与客户端的心跳来判断会话是否有效，单位是毫秒
- -r代表只读模式，zookeeper的只读模式指一个服务器与集群中过半机器失去连接以后，这个服务器就不在不处理客户端的请求，但我们仍然希望该服务器可以提供读服务。
- -server，指定服务器ip地址和端口号

查看帮助：
	
	help	
列出某一节点下的子节点信息
	
	ls /
列出节点的子节点，同时列出节点状态

	ls2 / 
如执行ls或ls2提示:Authentication is not valid表示需添加认证

添加认证

	addauth digest admin:admin
添加认证之后，即可操作节点(查看或修改)

创建节点 
	
	create /zk/testnode zz
-s，顺序节点，-e，临时节点	

创建带访问权限的节点
	
	create /test data auth::rw
	创建数据为data的test节点，auth认证方式，读写权限
	create /super 0 digest:admin:密文密码
- 设置acl格式：scheme:id:perm,perm的写法是简写字母连接，如读写权限rw，和linux文件系统权限类似,有些版本可能是READ|WRITE需注意提示
- scheme是digest的时候，id需要密文
- 客户端编码方式添加认证，digest对应的auth数据是明文
- 自定义认证扩展实现org.apache.zookeeper.server.auth.AuthenticationProvider，然后zk启动参数添加-Dzookeeper.authPorivder.X=xxx.MyProvider或配置文件(zoo.cfg)zookeeper.authProvider.1=xx.MyProvider


查看访问控制列表/权限
	
	getAcl /test

查看节点内容（获取节点存储的数据内容）  					

	get /zk/testnode 
修改节点数据，可携带版本号

	set /zk/testnode abc
修改的时候要么不携带版本号，要么携带的版本号要跟dataVersion的版本号一致，否则就会报错

删除节点

	delete /zk/testnode
只能删除没有子节点的节点，要删除含有子节点的时候需使用rmr命令

配额，给节点限制值，比如限制子节点个数、节点数据的长度

	create /test test
	setquota -n 2 /test
-n，限制子节点个数,	-b，限制值的长度,当创建节点超出配额时，zookeeper不会抛出异常，会在zookeeper.out记录警告信息

查看配额，以及节点的配额状态

	listquota /test
删除配额

	delquota /test

查看节点的状态信息

	stat /test

- 在zookeeper中，每一次对节点的写操作都认为是一次事务，每一个事务，系统都会分配一个唯一的事务ID,czxid代表该节点被创建的事务ID
- ctime表示创建的时间
- mzxid表示最后一次被更新的事务ID，
- mtime是修改时间，
- pzxid表示子节点列表最后一次被更新的事务ID，
- cversion子节点的版本号，
- dataversion数据版本号，
- aclversion权限版本号，
- ephemeralOwner用于临时节点，代表临时节点的事务ID，如果为持久节点则为0，
- dataLength代表节点存储的数据的长度，
- numChildren当前节点的子节点个数。



关闭当前连接

	close
查看历史命令

	history
重复执行命令

	redo

退出客户端

	quit

	

ZooKeeper 常用四字命令：

 ZooKeeper 支持某些特定的四字命令字母与其的交互。它们大多是查询命令，用来获取 ZooKeeper 服务的当前状态及相关信息。用户在客户端可以通过 telnet 或 nc 向 ZooKeeper 提交相应的命令

	conf 输出相关服务配置的详细信息。
	cons 列出所有连接到服务器的客户端的完全的连接 / 会话的详细信息。包括“接受 / 发送”的包数量、会话 id 、操作延迟、最后的操作执行等等信息。
	dump 列出未经处理的会话和临时节点。
	envi输出关于服务环境的详细信息（区别于 conf 命令）。
	reqs列出未经处理的请求
	ruok测试服务是否处于正确状态。如果确实如此，那么服务返回“imok ”，否则不做任何相应。
	stat输出关于性能和连接的客户端的列表。
	wchs列出服务器 watch 的详细信息。
	wchc通过 session 列出服务器 watch 的详细信息，它的输出是一个与watch 相关的会话的列表。
	wchp通过路径列出服务器 watch 的详细信息。它输出一个与 session相关的路径。

示例：
	
	echo stat|nc 127.0.0.1 2181 来查看哪个节点被选择作为follower或者leader
	echo ruok|nc 127.0.0.1 2181 测试是否启动了该Server，若回复imok表示已经启动。
	echo dump| nc 127.0.0.1 2181 ,列出未经处理的会话和临时节点。
	echo kill | nc 127.0.0.1 2181 ,关掉server
	echo conf | nc 127.0.0.1 2181 ,输出相关服务配置的详细信息。
	echo cons | nc 127.0.0.1 2181 ,列出所有连接到服务器的客户端的完全的连接 / 会话的详细信息。
	echo envi |nc 127.0.0.1 2181 ,输出关于服务环境的详细信息（区别于 conf 命令）。
	echo reqs | nc 127.0.0.1 2181 ,列出未经处理的请求。
	echo wchs | nc 127.0.0.1 2181 ,列出服务器 watch 的详细信息。
	echo wchc | nc 127.0.0.1 2181 ,通过 session 列出服务器 watch 的详细信息，它的输出是一个与 watch 相关的会话的列表。
	echo wchp | nc 127.0.0.1 2181 ,通过路径列出服务器 watch 的详细信息。它输出一个与 session 相关的路径。

	
查看事务日志命令：

	export zkDir=/root/zookeeper/zookeeper-1/
	JAVA_OPTS="$JAVA_OPTS -Djava.ext.dirs=$zkDir:$zkDir/lib"
	查看事物日志
	java $JAVA_OPTS org.apache.zookeeper.server.LogFormatter      log.100000001
	查看快照
	java $JAVA_OPTS  org.apache.zookeeper.server.SnapshotFormatter        snapshot.0

系统服务脚本：

	#!/bin/bash
	#chkconfig:2345 20 90
	#description:zookeeper
	#processname:zookeeper
	
	case $1 in
	
	          start) su root /usr/local/zookeeper/bin/zkServer.sh start;;
	
	          stop) su root /usr/local/zookeeper/bin/zkServer.sh stop;;
	
	          status) su root /usr/local/zookeeper/bin/zkServer.sh status;;
	
	          restart) su root /usr/local/zookeeper/bin/zkServer.sh restart;;
	
	          *)  echo "require start|stop|status|restart"  ;;
	
	esac


Zookeeper watch参照表

Watcher 设置是开发中最常见的，需要搞清楚watcher的一些基本特征，对于exists、getdata、getchild对于节点的不同操 作会收到不同的 watcher信息。对父节点的变更以及孙节点的变更都不会触发watcher，而对watcher本身节点以及子节点的变更会触发 watcher，具体参照下表。
	
	操作	            方法	  触发watcher	watcher state	watcher type	watcher path
	Create当前节点	getdata	×	×	×	×
	
	getchildren	√	3	4	√
	
	exists	×	×	×	×
	
	set当前节点	getdata	√	3	3	√
	
	getchildren	×	×	×	×
	
	exists	√	3	3	√
	
	delete当前节点	getdata	√	3	2	√
	
	getchildren	√	3	2	√
	
	exists	√	3	2	√
	
	create子节点	getdata	×	×	×	×
	
	getchildren	√	3	4	√
	
	exists	×	×	×	×
	
	set子节点	getdata	×	×	×	×
	
	getchildren	×	×	×	×
	
	exists	×	×	×	×
	
	delete子节点	getdata	×	×	×	×
	
	getchildren	√	3	4	√
	
	exists	×	×	×	×
	
	恢复连接	getdata	√	1	-1	×
	
	getchildren	√	1	-1	×
	
	exists	√	1	-1	×
	
	恢复连接session未超时	getdata	√	-112	-1	×
	
	getchildren	√	-112	-1	×
	
	exists	√	-112	-1	×
	
	恢复连接session超时	getdata	√	3	-1	×
	
	getchildren	√	3	-1	×
	
	exists	√	3	-1	×

注： state = 2 表示删除事件；state = 3表示节点数据变更；state =4表示子节点事件；state = -1表示 session事件。 type = -112表示session失效；type = 1表示session建立中；tpye = = 3表示 session建立成功。×表示否，√表示是。