#redis简介

redis是一个key-value存储系统。和Memcached类似，它支持存储的value类型相对更多，包括string(字符串)、list(链表)、set(集合)、zset(sorted set –有序集合)和hash（哈希类型）。这些数据类型都支持push/pop、add/remove及取交集并集和差集及更丰富的操作，而且这些操作都是原子性的。在此基础上，redis支持各种不同方式的排序。与memcached一样，为了保证效率，数据都是缓存在内存中。区别的是redis会周期性的把更新的数据写入磁盘或者把修改操作写入追加的记录文件，并且在此基础上实现了master-slave(主从)同步。

Redis数据库完全在内存中，使用磁盘仅用于持久性。相比许多键值数据存储，Redis拥有一套较为丰富的数据类型。Redis可以将数据复制到任意数量的从服务器。

Redis有三个主要使其有别于其它很多竞争对手的特点：

- Redis是完全在内存中保存数据的数据库，使用磁盘只是为了持久性目的； 
- Redis相比许多键值数据存储系统有相对丰富的数据类型； 
- Redis可以将数据复制到任意数量的从服务器中； 


##Redis优点：

- 异常快速：Redis的速度非常快，每秒能执行约11万集合，每秒约81000+条记录。

- 支持丰富的数据类型：Redis支持最大多数开发人员已经知道像列表，集合，有序集合，散列数据类型。这使得它非常容易解决各种各样的问题，因为我们知道哪些问题是可以处理通过它的数据类型更好。

- 操作都是原子性：所有Redis操作是原子的，这保证了如果两个客户端同时访问的Redis服务器将获得更新后的值。

- 多功能实用工具：Redis是一个多实用的工具，可以在多个用例如缓存，消息，队列使用(Redis原生支持发布/订阅)，任何短暂的数据，应用程序，如Web应用程序会话，网页命中计数等。

##Redis缺点：

- 单线程

- 耗内存


#安装

编译安装：
	
	mkdir -p /usr/local/redis/conf
	cd /home
	wget http://download.redis.io/releases/redis-3.2.1.tar.gz
	tar zxvf redis-3.2.1.tar.gz
	cd redis-3.2.1
	make PREFIX=/usr/local/redis  install
	如编译安装报错，一般是由于未安装gcc：yum install gcc
	
	或直接编译安装
	make && make install
	make成功后会在src文件夹下产生一些二进制可执行文件，包括redis-server、redis-cli等等,将可执行文件拷贝到/usr/local/bin目录下。这样就可以直接敲名字运行程序了。
	find ./src -type f -executable
	./redis-benchmark //用于进行redis性能测试的工具
	./redis-check-dump //用于修复出问题的dump.rdb文件
	./redis-cli //redis的客户端
	./redis-server //redis的服务端
	./redis-check-aof //用于修复出问题的AOF文件
	./redis-sentinel //用于集群管理
	


yum安装：

	wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
	rpm -ivh epel-release-7-5.noarch.rpm
	yum repolist
	yum -y update
	yum install redis  
	
	systemctl enable redis-server.service
	systemctl start redis-server.service
	systemctl is-active redis-server.service

#卸载

	redis默认安装在/usr/local/bin或你指定的目录下产生下面几个文件

    redis-benchmark 
    redis-check-aof 
    redis-check-dump 
    redis-cli 
    redis-server

	把redis-server停了,然后把文件删除就行了. 

##启动

	#加上`&`号使redis以后台程序方式运行
	./redis-server &
	或者：
	mkdir /usr/local/redis/conf
	mkdir /usr/local/redis/data
	
	cp redis.conf /usr/local/redis/conf

	vi ../conf/redis.conf
	#修改daemonize为yes，即默认以后台程序方式运行
	daemonize yes
	#可修改默认监听端口
	port 6379
	#修改生成默认日志文件位置
	logfile "/src/logs/redis.log"
	#配置持久化文件存放位置
	dir /usr/local/redis/data/redisData

	./redis-server ../conf/redis.conf


##检测

	#检测后台进程是否存在
	ps -ef |grep redis
	
	#检测6379端口是否在监听
	netstat -lntp | grep 6379
	
	#使用`redis-cli`客户端检测连接是否正常.如果更改了端口，使用客户端连接时，也需要指定端口，redis-cli -p 端口
	./redis-cli
	127.0.0.1:6379> ping
	PONG
	127.0.0.1:6379> keys *
	(empty list or set)
	127.0.0.1:6379> set key "hello world"
	OK
	127.0.0.1:6379> get key
	"hello world"

##停止
	
	#使用客户端
	redis-cli shutdown
	#因为Redis可以妥善处理SIGTERM信号，所以直接kill -9也是可以的
	kill -9 PID

##自启动脚本
	
	cp utils/redis_init_script /etc/init.d/redis
	vi /etc/init.d/redis
	
	#!/bin/sh
	# chkconfig:   2345 80 90
	# description:  Redis is a persistent key-value database
	#
	REDIS_HOME=/usr/local/redis
	#redis服务器监听的端口
	REDISPORT=6379
	#服务端所处位置，在make install后默认存放与`/usr/local/bin/redis-server`，如果未make install则需要修改该路径，下同。
	EXEC=$REDIS_HOME/bin/redis-server
	#客户端位置
	CLIEXEC=$REDIS_HOME/bin/redis-cli
	#Redis的PID文件位置
	PIDFILE=/var/run/redis_${REDISPORT}.pid
	#配置文件位置，需要修改
	CONF="$REDIS_HOME/conf/redis.conf"
 
	case "$1" in
	    start)
	        if [ -f $PIDFILE ]
	        then
	                echo "$PIDFILE exists, process is already running or crashed"
	        else
	                echo "Starting Redis server..."
	                $EXEC $CONF &
	        fi
	        ;;
	    stop)
	        if [ ! -f $PIDFILE ]
	        then
	                echo "$PIDFILE does not exist, process is not running"
	        else
	                PID=$(cat $PIDFILE)
	                echo "Stopping ..."
	                $CLIEXEC -p $REDISPORT shutdown
	                while [ -x /proc/${PID} ]
	                do
	                    echo "Waiting for Redis to shutdown ..."
	                    sleep 1
	                done
	                echo "Redis stopped"
	        fi
	        ;;
	    *)
	        echo "Please use start or stop as first argument"
	        ;;
	esac

	chmod +x /etc/init.d/redis


#redis配置

##Redis配置命令

在Redis有配置文件(redis.conf)可在Redis的根目录下找到。可以通过Redis的CONFIG命令设置所有Redis的配置。

Redis的CONFIG命令的基本语法如下所示：

	redis 127.0.0.1:6379> CONFIG GET CONFIG_SETTING_NAME
	
	redis 127.0.0.1:6379> CONFIG GET loglevel
	
	1) "loglevel"
	2) "notice"

让所有的配置使用*代替CONFIG_SETTING_NAME

	
	redis 127.0.0.1:6379> CONFIG GET *
	
	  1) "dbfilename"
	  2) "dump.rdb"
	  3) "requirepass"
	  4) ""
	  ...

###配置编辑命令

要更新配置，可以直接编辑redis.conf文件或更新配置，通过CONFIG set命令


CONFIG SET命令的基本语法如下所示：

	redis 127.0.0.1:6379> CONFIG SET CONFIG_SETTING_NAME NEW_CONFIG_VALUE
	
	redis 127.0.0.1:6379> CONFIG SET loglevel "notice"
	OK
	redis 127.0.0.1:6379> CONFIG GET loglevel
	
	1) "loglevel"
	2) "notice"

##redis配置文件

redis.conf说明，redis配置文件被分成了几大块区域，它们分别是：

1.通用（general）

2.快照（snapshotting）

3.复制（replication）

4.安全（security）

5.限制（limits)

6.追加模式（append only mode)

7.LUA脚本（lua scripting)

8.慢日志（slow log)

9.事件通知（event notification）

	
	################################ 通用 ################################
	#度量单位声明
	# 1k => 1000 bytes
	# 1kb => 1024 bytes
	# 1m => 1000000 bytes
	# 1mb => 1024*1024 bytes
	# 1g => 1000000000 bytes
	# 1gb => 1024*1024*1024 bytes
	#redis配置中对单位的大小写不敏感，1GB、1Gb和1gB都是相同的。redis只支持bytes，不支持bit单位。
	
	#分配256M内存
	maxmemory 1024000000 	

	#转为守护进程，否则启动时会每隔5秒输出一行监控信息
	daemonize yes 
	#pid文件位置
	pidfile /var/run/redis.pid
	#监听的端口号 如果端口设置为0的话，redis便不会监听端口,通过配置unixsocket,通过unix socket方式来接收请求
	port 6379
	
	# TCP 监听的最大容纳数量
	# 在高并发的环境下，你需要把这个值调高以避免客户端连接缓慢的问题。
	# Linux 内核会一声不响的把这个值缩小成 /proc/sys/net/core/somaxconn 对应的值，
	# 所以你要修改这两个值才能达到你的预期。
	tcp-backlog 511
	
	# 默认情况下，redis会响应本机所有可用网卡的连接请求,redis允许你通过bind配置项来指定要绑定的IP(一个IP或者多个IP,多个IP用空格隔开)
	# bind 192.168.1.100 10.0.0.1
	# bind 127.0.0.1
	
	# 指定 unix socket 的路径,unixsocketperm来指定文件的权限。
	# unixsocket /tmp/redis.sock
	# unixsocketperm 755
	
	# 请求超时时间.指定在一个 client空闲多少秒之后关闭连接（0永不关闭）
	timeout 0
	
	# TCP连接保活策略tcp心跳包。单位为秒
	# 如果设置为非零，则server端会每60秒向连接空闲的客户端发起一次ACK请求，以检查客户端是否已经挂掉，对于无响应的客户端则会关闭其连接
	# 推荐一个合理的值就是60秒,所以关闭一个连接最长需要120秒的时间。如果设置为0，则不会进行检测。
	tcp-keepalive 60
	
	# 定义日志级别:
	# debug (适用于开发或测试阶段)
	# verbose (many rarely useful info, but not a mess like the debug level)
	# notice (适用于生产环境)
	# warning (仅仅一些重要的消息被记录)
	loglevel notice
 	# 指定日志文件的位置,如果设置为空字符串，则会将日志输出到标准输出,在daemon情况下将日志设置为输出到标准输出，则日志会被写到/dev/null中
	logfile "/srv/logs/redis.log"
	
	# 要想把日志记录到系统日志，就把它改成kyes，
	# 也可以可选择性的更新其他的syslog 参数以达到你的要求
	# syslog-enabled no
	# 如指定syslog里的日志标志
	# syslog-ident redis
	# 还支持指定syslog设备，值可以是USER或LOCAL0-LOCAL7。具体可以参考syslog服务本身的用法
	# syslog-facility local0

	# 可以设置其数据库的总数量,默认数据库是DB 0，可以在每个连接上使用select <dbid>选择一个不同的数据库	
	databases 16

	################################ 快照 ################################
	# 存 DB 到磁盘：
	#   格式：save <间隔时间（秒）> <写入次数>
	#   根据给定的时间间隔和写入次数将数据保存到磁盘(在一定时间内执行一定数量的写操作时，自动保存快照)
	#   900 秒内如果至少有 1 个 key 的值变化，则保存
	#save 900 1
	#   300 秒内如果至少有 10 个 key 的值变化，则保存
	#save 300 10
	#   60 秒内如果至少有 10000 个 key 的值变化，则保存
	save 60 10000
	#   注意：你可以注释掉所有的save行或save ""来禁用RDB持久化的策略。
	
	# 默认情况下，如果 redis最后一次的后台保存失败，redis将停止接受写操作，
	# 以一种强硬的方式让用户知道数据不能正确的持久化到磁盘，否则就会没人注意到灾难的发生。
	# 如果后台保存进程重新启动工作了，redis也将自动的允许写操作。
	# 然而安装了靠谱的监控，或希望在快照写入失败时，也能确保redis继续接受新的写请求，改成no好了。
	stop-writes-on-bgsave-error yes
	
	# 对于存储到磁盘中的快照，可以设置是否进行压缩存储,默认都设为yes使用LZF算法进行压缩
	# 如果你希望保存子进程节省点cpu，你就设置它为 no ，不过这个数据集可能就会比较大
	rdbcompression yes 
	# 是否校验rdb文件,让redis使用CRC64算法来进行数据校验，这样做会增加大约10%的性能消耗，如果希望获取到最大的性能提升，可以关闭此功能
	rdbchecksum yes
	# 设置快照文件的名称
	dbfilename dump.rdb
	#设置这个快照文件存放的路径
	dir ./

	################################# 主从复制 #################################
	# 主从复制。在slave上配置slaveof让一个redis实例成为另一个reids实例的副本。建议为从redis设置一个不同频率的快照持久化的周期，或者为从redis配置一个不同的服务端口
	# slaveof <masterip> <masterport>	 
	# 如果master需要密码认证，就在这里设置
	# masterauth <master-password>	 
	# 当一个slave与master失去联系，或者同步复制正在进行的时候，slave可能会有两种表现：
	# 1) 如果slave-serve-stale-data设置为yes（默认），slave仍然会应答客户端请求，但返回的数据可能是过时，或者数据可能是空的在第一次同步的时候
	# 2) 如果设置为no，在你执行除了info he salveof 之外的其他命令时，slave 都将返回一个 "SYNC with master in progress" 的错误，
	slave-serve-stale-data yes
	 
	# 配置slave是否接受写入操作。一般只适用于那些生命周期非常短的数据，因为在主从同步时，这些临时数据就会被清理掉。自从redis2.6版本之后，默认从redis为只读
	slave-read-only yes
	 
	# Slaves 在一个预定义的时间间隔（默认为10秒）内发送ping命令到server 。
	# repl-ping-slave-period 10
	
	# 设置主从复制过期时间，这个值一定要比repl-ping-slave-period大，在主从同步时，可能在这些情况下会有超时发生：
	#  以从redis的角度来看，当有大规模IO传输时。
	#  以从redis的角度来看，当数据传输或PING时，主redis超时
	# 以主redis的角度来看，在回复从redis的PING时，从redis超时
	# repl-timeout 60
	 
	#在主从同步时是否禁用TCP_NODELAY。如果开启TCP_NODELAY，那么主redis会使用更少的TCP包和更少的带宽来向从redis传输数据。但是这可能会增加一些同步的延迟，大概会达到40毫秒左右。如果你关闭了TCP_NODELAY，那么数据同步的延迟时间会降低，但是会消耗更多的带宽
	repl-disable-tcp-nodelay no
	 
	# 设置同步队列长度（主从复制容量大小），队列长度（backlog)是主redis中的一个缓冲区，在与从redis断开连接期间，主redis会用这个缓冲区来缓存应该发给从redis的数据。当从redis重新连接上之后，就不必重新全量同步数据，只需要同步这部分增量数据即可
	# 这个值越大，salve 可以断开连接的时间就越长。
	repl-backlog-size 1mb
	#如果主redis等了一段时间之后，还是无法连接到从redis，那么缓冲队列中的数据将被清理掉。可以设置主redis要等待的时间长度。如果设置为0，则表示永远不清理。默认是1个小时（3600）
	repl-backlog-ttl 3600
	 
	# 当 master 不能正常工作的时候，Redis Sentinel 会从 slaves 中选出一个新的 master，
	# 这个值越小，就越会被优先选中，但是如果是0意味着这个slave可能被选中,默认优先级为 100。
	slave-priority 100
	 
	#主redis发现有超过M个从redis的连接延时大于N秒，那么主redis就停止接受外来的写请求。这是因为从redis一般会每秒钟都向主redis发出PING，而主redis会记录每一个从redis最近一次发来PING的时间点，所以主redis能够了解每一个从redis的运行情况。
	#假如有大于等于3个从redis的连接延迟大于10秒，那么主redis就不再接受外部的写请求
	min-slaves-to-write 3
	min-slaves-max-lag 10
	 
	################################## 安全 ###################################
	 
	
	# 设置认证密码,当你的redis-server处于一个不太可信的网络环境中时,由于redis性能非常高，所以每秒钟可以完成多达15万次的密码尝试，所以你最好设置一个足够复杂的密码，否则很容易被黑客破解
	# requirepass foobared
	 
	#只读的从redis并不适合直接暴露给不可信的客户端。为了尽量降低风险，可以使用rename-command指令来将一些可能有破坏力的命令重命名，避免外部直接调用。比如
	# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
	#甚至可以禁用掉CONFIG命令,需要注意的是，如果你使用AOF方式进行数据持久化，或者需要与从redis进行通信，那么更改指令的名字可能会引起一些问题。
	# rename-command CONFIG ""
	 
	################################### 限制 ####################################
	
	# 一旦达到最大限制，redis 将关闭所有的新连接并发送一个‘max number of clients reached’的错误。
	# redis会设置为当前的文件句柄限制值减去32
	# maxclients 10000
	 
	# 最大使用内存,redis可以使用的内存量,当缓存的数据容量达到这个值,redis将根据你选择的eviction策略来移除一些 keys。
	# 如果 redis 不能根据策略移除 keys ，或者是策略被设置为 ‘noeviction’，
	# redis 将开始响应错误给命令，如 set，lpush 等等，并继续响应只读的命令，如 get
	# maxmemory <bytes>
	 
	# 对于内存移除规则来说，redis提供了多达6种的移除规则	
	# volatile-lru -> 使用 LRU 算法移除包含过期设置的key 。
	# allkeys-lru -> 使用LRU算法移除key
	# allkeys-lru -> 根据 LRU 算法移除所有的 key 。
	# volatile-random -> 在过期集合中移除随机的key
	# allkeys-random -> 移除随机的key
	# volatile-ttl -> 移除那些TTL值最小的key，即那些最近才过期的key
	# noeviction -> 不进行移除。针对写操作，只是返回错误信息。
	# 如果没有合适的key可以移除的话，redis都会针对写请求返回错误信息
	# maxmemory-policy volatile-lru
	 
	#LRU算法和最小TTL算法都并非是精确的算法，而是估算值。所以可以设置样本的大小。假如redis默认会检查三个key并选择其中LRU的那个，那么你可以改变这个key样本的数量。
	# maxmemory-samples 5
	 
	############################## 追加模式 ###############################
	 
	
	# Please check http://redis.io/topics/persistence for more information.
	#默认情况下，redis会异步的将数据持久化到磁盘。这种模式在大部分应用程序中已被验证是很有效的，但是在一些问题发生时，比如断电，则这种机制可能会导致数分钟的写请求丢失。 
	appendonly no
	 
	# 设置aof文件的名称默认: "appendonly.aof" 
	 
	appendfilename "appendonly.aof"
	 
	# fsync()调用，用来告诉操作系统立即将缓存的指令写入磁盘。一些操作系统会“立即”进行，而另外一些操作系统则会“尽快”进行。#redis支持三种不同的模式：
	#  no：不调用fsync()。而是让操作系统自行决定sync的时间。这种模式下，redis的性能会最快。
	#  always：在每次写请求后都调用fsync()。这种模式下，redis会相对较慢，但数据最安全。
	#  everysec：每秒钟调用一次fsync()。这是性能和安全的折衷。
	# 默认情况下为everysec,当fsync方式设置为always或everysec时，如果后台持久化进程需要执行一个很大的磁盘IO操作，那么redis可能会在fsync()调用时卡住。目前尚未修复这个问题，这是因为即使我们在另一个新的线程中去执行fsync()，也会阻塞住同步写调用。

	appendfsync everysec

	 
	#为了缓解这个问题，我们可以使用下面的配置项，这样的话，当BGSAVE或BGWRITEAOF运行时，fsync()在主进程中的调用会被阻止。这意味着当另一路进程正在对AOF文件进行重构时，redis的持久化功能就失效了，就好像我们设置了“appendsync none”一样。如果你的redis有时延问题，那么请将下面的选项设置为yes。否则请保持no，因为这是保证数据完整性的最安全的选择。
	 
	no-appendfsync-on-rewrite no
	 
	#如果设置auto-aof-rewrite-percentage为0，则会关闭此重写功能。一般允许redis自动重写aof。当aof增长到一定规模时，redis会隐式调用BGREWRITEAOF来重写log文件，以缩减文件体积。
	#redis会记录上次重写时的aof大小。假如redis自启动至今还没有进行过重写，那么启动时aof文件的大小会被作为基准值。这个基准值会和当前的aof大小进行比较。如果当前aof大小超出所设置的增长比例，则会触发重写。另外，你还需要设置一个最小大小，是为了防止在aof很小时就触发重写。
	 
	auto-aof-rewrite-percentage 100
	auto-aof-rewrite-min-size 64mb
	 
	################################ LUA SCRIPTING  ###############################
	 
	#限制lua脚本的最大运行时间，单位是毫秒。如果此值设置为0或负数，则既不会有报错也不会有时间限制
	lua-time-limit 5000
	 
	################################ REDIS 集群  ###############################
	
	# 启用或停用集群。若要让集群正常运作至少需要三个主节点，启动redis实例以后，通过使用Redis集群命令行工具redis-trib（位于源码src文件夹下）， 编写节点配置文件，通过向实例发送特殊命令来完成创建新集群， 检查集群， 或者对集群进行重新分片（reshared）等工作
	# cluster-enabled yes
	
	#设定保存节点配置文件的路径，默认为nodes.conf。该节点配置文件无须人为修改，它由Redis集群在启动时自动创建， 并在有需要时自动进行更新
	# cluster-config-file nodes-6379.conf
	 
	
	# 节点互连超时的阀值  
	# cluster-node-timeout 15000
	 
	# A slave of a failing master will avoid to start a failover if its data
	# looks too old.
	#
	# There is no simple way for a slave to actually have a exact measure of
	# its "data age", so the following two checks are performed:
	#
	# 1) If there are multiple slaves able to failover, they exchange messages
	#    in order to try to give an advantage to the slave with the best
	#    replication offset (more data from the master processed).
	#    Slaves will try to get their rank by offset, and apply to the start
	#    of the failover a delay proportional to their rank.
	#
	# 2) Every single slave computes the time of the last interaction with
	#    its master. This can be the last ping or command received (if the master
	#    is still in the "connected" state), or the time that elapsed since the
	#    disconnection with the master (if the replication link is currently down).
	#    If the last interaction is too old, the slave will not try to failover
	#    at all.
	#
	# The point "2" can be tuned by user. Specifically a slave will not perform
	# the failover if, since the last interaction with the master, the time
	# elapsed is greater than:
	#
	#   (node-timeout * slave-validity-factor) + repl-ping-slave-period
	#
	# So for example if node-timeout is 30 seconds, and the slave-validity-factor
	# is 10, and assuming a default repl-ping-slave-period of 10 seconds, the
	# slave will not try to failover if it was not able to talk with the master
	# for longer than 310 seconds.
	#
	# A large slave-validity-factor may allow slaves with too old data to failover
	# a master, while a too small value may prevent the cluster from being able to
	# elect a slave at all.
	#
	# For maximum availability, it is possible to set the slave-validity-factor
	# to a value of 0, which means, that slaves will always try to failover the
	# master regardless of the last time they interacted with the master.
	# (However they'll always try to apply a delay proportional to their
	# offset rank).
	#
	# Zero is the only value able to guarantee that when all the partitions heal
	# the cluster will always be able to continue.
	#
	# cluster-slave-validity-factor 10
	 
	# Cluster slaves are able to migrate to orphaned masters, that are masters
	# that are left without working slaves. This improves the cluster ability
	# to resist to failures as otherwise an orphaned master can't be failed over
	# in case of failure if it has no working slaves.
	#
	# Slaves migrate to orphaned masters only if there are still at least a
	# given number of other working slaves for their old master. This number
	# is the "migration barrier". A migration barrier of 1 means that a slave
	# will migrate only if there is at least 1 other working slave for its master
	# and so forth. It usually reflects the number of slaves you want for every
	# master in your cluster.
	#
	# Default is 1 (slaves migrate only if their masters remain with at least
	# one slave). To disable migration just set it to a very large value.
	# A value of 0 can be set but is useful only for debugging and dangerous
	# in production.
	#
	# cluster-migration-barrier 1
	 
	# In order to setup your cluster make sure to read the documentation
	# available at http://redis.io web site.
	 
	################################## SLOW LOG ###################################
	 
	#redis慢日志是指一个系统进行日志查询超过了指定的时长。这个时长不包括IO操作，比如与客户端的交互、发送响应内容等，而仅包括实际执行查询命令的时间。
	#针对慢日志，你可以设置两个参数，一个是执行时长，单位是微秒，另一个是慢日志的长度。当一个新的命令被写入日志时，最老的一条会从命令日志队列中被移除。
	#单位是微秒，即1000000表示一秒。负数则会禁用慢日志功能，而0则表示强制记录每一个命令
	slowlog-log-slower-than 10000
	 
	#慢日志最大长度，可以随便填写数值，没有上限，但要注意它会消耗内存。你可以使用SLOWLOG RESET来重设这个值。
	slowlog-max-len 128
	 
	############################# Event notification ##############################
	 
	# Redis can notify Pub/Sub clients about events happening in the key space.
	# This feature is documented at http://redis.io/topics/keyspace-events
	# 
	# For instance if keyspace events notification is enabled, and a client
	# performs a DEL operation on key "foo" stored in the Database 0, two
	# messages will be published via Pub/Sub:
	#
	# PUBLISH __keyspace@0__:foo del
	# PUBLISH __keyevent@0__:del foo
	#
	# It is possible to select the events that Redis will notify among a set
	# of classes. Every class is identified by a single character:
	#
	#  K     Keyspace events, published with __keyspace@<db>__ prefix.
	#  E     Keyevent events, published with __keyevent@<db>__ prefix.
	#  g     Generic commands (non-type specific) like DEL, EXPIRE, RENAME, ...
	#  $     String commands
	#  l     List commands
	#  s     Set commands
	#  h     Hash commands
	#  z     Sorted set commands
	#  x     Expired events (events generated every time a key expires)
	#  e     Evicted events (events generated when a key is evicted for maxmemory)
	#  A     Alias for g$lshzxe, so that the "AKE" string means all the events.
	#
	#  The "notify-keyspace-events" takes as argument a string that is composed
	#  by zero or multiple characters. The empty string means that notifications
	#  are disabled at all.
	#
	#  Example: to enable list and generic events, from the point of view of the
	#           event name, use:
	#
	#  notify-keyspace-events Elg
	#
	#  Example 2: to get the stream of the expired keys subscribing to channel
	#             name __keyevent@0__:expired use:
	#
	#  notify-keyspace-events Ex
	#
	#  By default all notifications are disabled because most users don't need
	#  this feature and the feature has some overhead. Note that if you don't
	#  specify at least one of K or E, no events will be delivered.
	notify-keyspace-events ""
	 
	############################### ADVANCED CONFIG ###############################
	 
	#哈希数据结构的一些配置项
	hash-max-ziplist-entries 512
	hash-max-ziplist-value 64
	 
	#有关列表数据结构的一些配置项
	list-max-ziplist-entries 512
	list-max-ziplist-value 64
	 
	#有关集合数据结构的配置项
	set-max-intset-entries 512
	 
	#有关有序集合数据结构的配置项
	zset-max-ziplist-entries 128
	zset-max-ziplist-value 64
	 
	# HyperLogLog sparse representation bytes limit. The limit includes the
	# 16 bytes header. When an HyperLogLog using the sparse representation crosses
	# this limit, it is converted into the dense representation.
	#
	# A value greater than 16000 is totally useless, since at that point the
	# dense representation is more memory efficient.
	# 
	# The suggested value is ~ 3000 in order to have the benefits of
	# the space efficient encoding without slowing down too much PFADD,
	# which is O(N) with the sparse encoding. The value can be raised to
	# ~ 10000 when CPU is not a concern, but space is, and the data set is
	# composed of many HyperLogLogs with cardinality in the 0 - 15000 range.
	hll-sparse-max-bytes 3000
	 
	#是否需要再哈希的配置项
	activerehashing yes
	 
	#客户端输出缓冲的控制项
	client-output-buffer-limit normal 0 0 0
	client-output-buffer-limit slave 256mb 64mb 60
	client-output-buffer-limit pubsub 32mb 8mb 60
	 
	#有关频率的配置项
	hz 10
	 
	#有关重写aof的配置项
	aof-rewrite-incremental-fsync yes


调整内存(如果内存情况比较紧张的话，需要设定内核参数)

	echo 1 > /proc/sys/vm/overcommit_memory
该文件指定了内核针对内存分配的策略，其值可以是0、1、2。

- 0 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；内存申请失败，并把错误返回给应用进程。
- 1 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
- 2 表示内核允许分配超过所有物理内存和交换空间总和的内存

强制刷新数据到磁盘(Redis默认是异步写入磁盘的)

	# /usr/local/redis/bin/redis-cli -p 6379 save

**Redis主从配置**

一个master可以拥有多个slave，而一个slave又可以拥有多个slave.

redis.conf:
	
	#映射到主服务器上
	slaveof 192.168.1.31 6379   
	#如果master设置了验证密码(requirepass 123456)，还需配置masterauth的验证密码
	#masterauth 123456

slave配置完整示例：

	daemonize yes 
	pidfile /var/run/redis_6379.pid 
	bind 0.0.0.0 
	port 6379 
	timeout 120 
	loglevel notice
	logfile /opt/redis/var/redis.log 
	databases 16 
	save 900 1 
	save 300 100 
	save 60 10000 
	stop-writes-on-bgsave-error yes
	rdbcompression yes 
	rdbchecksum yes
	dbfilename dump.rdb 
	dir /opt/redis/var 
	appendonly yes
	appendfilename "appendonly.aof" 
	appendfsync everysec 
	no-appendfsync-on-rewrite no 
	auto-aof-rewrite-percentage 100 
	auto-aof-rewrite-min-size 64mb 
	aof-load-truncated yes
	slowlog-log-slower-than 10000 
	slowlog-max-len 128 
	hash-max-ziplist-entries 512
	hash-max-ziplist-value 64 
	list-max-ziplist-entries 512 
	list-max-ziplist-value 64
	set-max-intset-entries 512
	zset-max-ziplist-entries 128
	zset-max-ziplist-value 64
	hll-sparse-max-bytes 3000
	activerehashing yes 
	maxmemory 2048000000 
	maxclients 10000 
	slave-serve-stale-data yes 
	slave-read-only no
	slave-priority 100
	repl-diskless-sync no
	repl-diskless-sync-delay 5
	repl-disable-tcp-nodelay no
	slaveof 192.168.1.7 6379

查看状态：

	redis-cli.exe -h 127.0.0.1 -p 6379
	info
	

Redis 未授权访问缺陷可轻易导致系统被黑，网址：http://www.chinaz.com/server/2015/1112/469670_2.shtml
临时解决方案                            

- 配置bind选项, 限定可以连接Redis服务器的IP, 并修改redis的默认端口6379.
- 配置AUTH, 设置密码, 密码会以明文方式保存在redis配置文件中.
- 配置rename-command CONFIG "RENAME_CONFIG", 这样即使存在未授权访问, 也能够给攻击者使用config指令加大难度
- 好消息是Redis作者表示将会开发”real user”，区分普通用户和admin权限，普通用户将会被禁止运行某些命令，如config






redis持久化两种方式：redis提供了两种持久化的方式，分别是RDB（Redis DataBase）和AOF（Append Only File）。

- RDB，简而言之，就是在不同的时间点，将redis存储的数据生成快照并存储到磁盘等介质上；

- AOF，则是换了一个角度来实现持久化，那就是将redis执行过的所有写指令记录下来，在下次redis重新启动时，只要把这些写指令从前到后再重复执行一遍，就可以实现数据恢复了。
	- AOF:Append Only File，即只允许追加不允许改写的文件,通过配置redis.conf中的appendonly yes就可以打开AOF功能。如果有写操作（如SET等），redis就会被追加到AOF文件的末尾。默认的AOF持久化策略是每秒钟fsync一次（fsync是指把缓存中的写指令记录到磁盘中），因为在这种情况下，redis仍然可以保持很好的处理性能，即使redis故障，也只会丢失最近1秒钟的数据
	- 如果在追加日志时，恰好遇到磁盘空间满、inode满或断电等情况导致日志写入不完整，也没有关系，redis提供了redis-check-aof工具，可以用来进行日志修复。
	- 因为采用了追加方式，如果不做任何处理的话，AOF文件会变得越来越大，为此，redis提供了AOF文件重写（rewrite）机制，即当AOF文件的大小超过所设定的阈值时，redis就会启动AOF文件的内容压缩，只保留可以恢复数据的最小指令集
	- 直接执行BGREWRITEAOF命令，redis会生成一个全新的AOF文件，其中便包括了可以恢复现有数据的最少的命令集。
	- 在进行AOF重写时，仍然是采用先写临时文件，全部完成后再替换的流程，所以断电、磁盘满等问题都不会影响AOF文件的可用性
	- AOF方式也同样存在缺陷，比如在同样数据规模的情况下，AOF文件要比RDB文件的体积大。而且，AOF方式的恢复速度也要慢于RDB方式。
	- AOF文件出现了被写坏的情况,redis并不会贸然加载这个有问题的AOF文件，而是报错退出。这时可以通过以下步骤来修复出错的文件：
		- 备份被写坏的AOF文件
		- 运行redis-check-aof –fix进行修复
		- 用diff -u来看下两个文件的差异，确认问题点
		- 重启redis，加载修复后的AOF文件
	- 内部运行原理:
		- 在重写即将开始之际，redis会创建（fork）一个“重写子进程”，这个子进程会首先读取现有的AOF文件，并将其包含的指令进行分析压缩并写入到一个临时文件中。
		- 与此同时，主工作进程会将新接收到的写指令一边累积到内存缓冲区中，一边继续写入到原有的AOF文件中，这样做是保证原有的AOF文件的可用性，避免在重写过程中出现意外。
		- 当“重写子进程”完成重写工作后，它会给父进程发一个信号，父进程收到信号后就会将内存中缓存的写指令追加到新AOF文件中。
		- 当追加结束后，redis就会用新AOF文件来代替旧AOF文件，之后再有新的写指令，就都会追加到新的AOF文件中了。

其实RDB和AOF两种方式也可以同时使用(官方的建议是两个同时使用,这样可以提供更可靠的持久化方案)，在这种情况下，如果redis重启的话，则会优先采用AOF方式来进行数据恢复，这是因为AOF方式的数据恢复完整度更高。

如果没有数据持久化的需求，也完全可以关闭RDB和AOF方式，这样的话，redis将变成一个纯内存数据库，就像memcache一样。






	