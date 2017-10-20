#集群简介

Redis集群是一个提供在多个Redis间节点间共享数据的程序集.redis3.0以前，只支持主从同步的，如果主的挂了，写入就成问题了。Redis在3.0版正式引入了集群这个特性,它和Sentinel不一样，Sentinel虽然也叫集群，可是它是一种HA策略即High Available或者又通俗的被称为“灾难转移”策略.

Redis Cluster 是Redis的集群实现，内置数据自动分片机制，集群内部将所有的key映射到16384个Slot中，集群中的每个Redis Instance负责其中的一部分的Slot的读写。集群客户端连接集群中任一Redis Instance即可发送命令，当Redis Instance收到自己不负责的Slot的请求时，会将负责请求Key所在Slot的Redis Instance地址返回给客户端，客户端收到后自动将原请求重新发往这个地址，对外部透明。一个Key到底属于哪个Slot由crc16(key) % 16384 决定。在Redis Cluster里对于负载均衡和HA相关都已经支持的相当完善了。

负载均衡（Load Balance）：集群的Redis Instance之间可以迁移数据，以Slot为单位，但不是自动的，需要外部命令触发。集群成员管理：集群的节点(Redis Instance)和节点之间两两定期交换集群内节点信息并且更新，从发送节点的角度看，这些信息包括：集群内有哪些节点，IP和PORT是什么，节点名字是什么，节点的状态(比如OK，PFAIL，FAIL，后面详述)是什么，包括节点角色(master 或者 slave)等。关于可用性，集群由N组主从Redis Instance组成。

主可以没有从，但是没有从 意味着主宕机后主负责的Slot读写服务不可用。

一个主可以有多个从，主宕机时，某个从会被提升为主，具体哪个从被提升为主，协议类似于Raft，参见这里。如何检测主宕机？Redis Cluster采用quorum+心跳的机制。从节点的角度看，节点会定期给其他所有的节点发送Ping，cluster-node-timeout(可配置，秒级)时间内没有收到对方的回复，则单方面认为对端节点宕机，将该节点标为PFAIL状态。通过节点之间交换信息收集到quorum个节点都认为这个节点为PFAIL，则将该节点标记为FAIL，并且将其发送给其他所有节点，其他所有节点收到后立即认为该节点宕机。从这里可以看出，主宕机后，至少cluster-node-timeout时间内该主所负责的Slot的读写服务不可用。

**Redis Cluster的特点如下：**

节点自动发现slave->master选举,集群容错Hot resharding:在线分片集群管理:clusterxxx基于配置(nodes-port.conf)的集群管理ASK 转向/MOVED转向机制布署无需指定master可以支持超过1,000台节点的集群

Redis集群是一个分布式（distributed）、容错（fault-tolerant）的 Redis内存K/V服务，Redis集群可提供:

- 自动分割数据集合在多个节点上;
- 当某个节点挂掉或者不可访问时, 集群继续正确地提供服务.
- **Redis集群并不支持处理多个keys的命令**,因为这需要在不同的节点间移动数据,从而降低性能,在高负载的情况下可能会导致不可预料的错误。

##Redis集群TCP端口

每个节点需要使用两个TCP端口. 一个普通端口给客户端使用, 比如6379, 另外个是集群总线端口，普通端口和之间的差值固定是1000（集群总线端口是在普通端口数字上加1000）. 后者这个集群总线端口, 是节点对节点的二进制数据通信频道. 集群总线用作节点间的宕机侦测, 配置变更, 故障转移认证等等. 客户端应该不使用集群总线端口, 而应该使用那个普通端口. 确保这两个端口都没被防火墙禁掉, 否则Redis集群会工作不正常.

要使集群工作正常, 注意以下两点:

1. 普通端口(通常为6379)要对所有需要连接的客户端开放, 也要对其他节点开放, 为了key的迁移.

2. 集群总线端口(普通端口+1000)必须对其他节点开放. 

##Redis集群数据分片

Redis集群没使用一致性哈希, 而用的是不同的分片方式, 每个key都是hash slot的逻辑组成部分.

Redis集群有16384个hash slot, 计算一个给定key的hash slot, 则是把该key的CRC16值对16384取模.

集群中的每个节点覆盖hash slot的一部分, 比如一个集群有3个节点, 则:

- 节点A覆盖0到5500;
- 节点B覆盖5501到11000;
- 节点C覆盖11001到16384.

这样使得添加和删除节点很容易. 比如想添加一个新节点D, 则只要把一些hash slot从ABC挪到D. 类似的, 想移除节点A, 只要把A下的slot hash移到B和C, 当节点A空了就可以把A完全移除掉了.

因为移动hash solt不需要停止节点的运行, 所以添加删除节点, 或者改变节点持有的hash slot百分比, 都不会有什么宕机时间. 

##Redis集群主从模式

当一个节点挂掉或者不可访问时, 为了保证可用性, Redis集群使用了主从模式, 一个主节点对应一个或多个从节点.

上面那个例子里, 集群有ABC三个节点, 如果B挂掉了, 我们就没法访问5501到11000的hash slot了.

如果在集群建立的时候(或者建完后), 我们为每个主节点都添加了从节点, 比如像这样, 集群包含主节点A B C, 以及从节点A1 B1 C1, 那么即使B挂掉系统也可以继续正确工作.

B1节点替代了B节点，所以Redis集群将会选择B1节点作为新的主节点，集群将会继续正确地提供服务。

不过需要注意，如果节点B和B1同时挂了，Redis集群就无法继续正确地提供服务了。

##Redis集群一致性保证

Redis集群无法保证强一致性。实际情况下这意味着，某些情况下Redis集群有可能会忘记一个已被系统接受的写操作。

Redis集群会丢失写操作的一个原因是它使用异步复制. 这表示写操作包含以下几个步骤:

- 客户端写数据到主节点B.
- 主节点B回复客户端OK.
- 主节点B传播本次写操作给它的从节点B1,B2和B3.

你可以发现, 节点B并没有在回复客户端之前等待B1,B2和B3的接受, 因为这将会造成很大的延迟. 所以当客户端写入数据到B中, B接受了数据, 但是在传播给它的从节点之前就挂了, 那么被提升为主节点的某个从节点将会永久丢失这个写操作.

这很类似于数据库每时每刻刷新配置到磁盘, 所以这种情况你应该已经了解, 因为传统数据库系统并不涉及分布式. 同样的, 为了提高一致性, 你可以在回复客户端之前强制刷新数据到磁盘, 但是这通常会降低性能.

基本上, 在一致性和性能之间, 都需要权衡一下.

注意: Redis集群会在将来允许用户配置同步写操作, 如果确实需要的话.


##Redis集群的几个重要特征：

(1).Redis 集群的分片特征在于将键空间分拆了16384个槽位，每一个节点负责其中一些槽位。

(2).Redis提供一定程度的可用性,可以在某个节点宕机或者不可达的情况下继续处理命令.

(3).Redis 集群中不存在中心（central）节点或者代理（proxy）节点， 集群的其中一个主要设计目标是达到线性可扩展性（linear scalability）。

##1. Redis的数据分片（Sharding）

Redis 集群的键空间被分割为 16384 （2^14)个槽（slot）， 集群的最大节点数量也是 16384 个（推荐的最大节点数量为 1000 个），同理每个主节点可以负责处理1到16384个槽位。

当16384个槽位都有主节点负责处理时，集群进入”稳定“上线状态，可以开始处理数据命令。当集群没有处理稳定状态时，可以通过执行重配置（reconfiguration）操作，使得每个哈希槽都只由一个节点进行处理。

重配置指的是将某个/某些槽从一个节点移动到另一个节点。一个主节点可以有任意多个从节点， 这些从节点用于在主节点发生网络断线或者节点失效时， 对主节点进行替换。

集群的使用公式CRC16（Key）&16383计算key属于哪个槽：
HASH_SLOT = CRC16(key) mod 16384

CRC16其结果长度为16位。
##2. Redis集群节点

部分内容摘自附录2。Redis 集群中的节点不仅要记录键和值的映射，还需要记录集群的状态，包括键到正确节点的映射。它还具有自动发现其他节点，识别工作不正常的节点，并在有需要时，在从节点中选举出新的主节点的功能。

为了执行以上列出的任务， 集群中的每个节点都与其他节点建立起了“集群连接（cluster bus）”， 该连接是一个 TCP 连接， 使用二进制协议进行通讯。

节点之间使用 Gossip 协议 来进行以下工作：

a).传播（propagate）关于集群的信息，以此来发现新的节点。

b).向其他节点发送 PING 数据包，以此来检查目标节点是否正常运作。

c).在特定事件发生时，发送集群信息。

除此之外， 集群连接还用于在集群中发布或订阅信息。

集群节点不能前端代理命令请求， 所以客户端应该在节点返回 -MOVED或者 -ASK转向（redirection）错误时， 自行将命令请求转发至其他节点。

客户端可以自由地向集群中的任何一个节点发送命令请求， 并可以在有需要时， 根据转向错误所提供的信息， 将命令转发至正确的节点， 所以在理论上来说， 客户端是无须保存集群状态信息的。但如果客户端可以将键和节点之间的映射信息保存起来， 可以有效地减少可能出现的转向次数， 籍此提升命令执行的效率。

每个节点在集群中由一个独一无二的 ID标识， 该 ID 是一个十六进制表示的 160 位随机数，在节点第一次启动时由 /dev/urandom 生成。节点会将它的 ID 保存到配置文件， 只要这个配置文件不被删除， 节点就会一直沿用这个 ID 。一个节点可以改变它的 IP 和端口号， 而不改变节点 ID 。 集群可以自动识别出IP/端口号的变化， 并将这一信息通过 Gossip协议广播给其他节点知道。

下面是每个节点都有的关联信息， 并且节点会将这些信息发送给其他节点：

a).节点所使用的 IP 地址和 TCP 端口号。

b).节点的标志（flags）。

c).节点负责处理的哈希槽。

b).节点最近一次使用集群连接发送 PING 数据包（packet）的时间。

e).节点最近一次在回复中接收到 PONG 数据包的时间。

f).集群将该节点标记为下线的时间。

g).该节点的从节点数量。
如果该节点是从节点的话，那么它会记录主节点的节点 ID 。 如果这是一个主节点的话，那么主节点 ID 这一栏的值为 0000000。

在了解Redis Cluster的集群基本特征后，我们首先搭建出这个Redis Cluster集群。


##创建和使用Redis集群

###搭建Cluster前的环境准备
安装CentOS或者是RHE

在安装Linux时需要一定记得安装GCC库、LibC、LibStdC++、Rubby库（1.9.2或以上）、ZLIB库（1.2.6或以上），如果你装机时没有安装这些“optional package”可以通过yum install gcc这样的命令在Linux联网的情况下来进行Linux安装后的额外包的安装

	

查看服务器是否安装ruby:

	yum list | grep ruby
	rpm -qa | grep ruby
安装ruby：

	yum list |grep ruby 
如版本大于2.2.2直接安装：

	yum install ruby

如版本太低：

	yum -y upgrade  
	yum groupinstall "Development Tools"  
	rvm -v
安装rvm：

	gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	curl -sSL https://get.rvm.io | bash -s stable
	source /etc/profile.d/rvm.sh 
	rvm -v
查看可以安装ruby列表：

	rvm list known
	rvm install 2.3.0

	
通过源码安装gem ：

	wget https://rubygems.org/downloads/redis-3.3.1.gem

在ruby gems安装后，你必须安装gem的redis模块：

	gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
	gem sources -l
	gem install redis

	 

###集群节点规划

 最小的Redis集群需要包含至少6个节点，其中3个master节点，3个slave节点,端口配置要点：所有Master（如3个Master的端口号以+1方式递增：7001，7002，7003）,所有的Slaver的端口号必须且一定要符合这样的原则：slave的端口比相关的master大1000号，如7001的slave的端口号为8001。举例来说：3个Master为7001，7002，7003，我们的3个Slave就为8001，8002，8003

###安装Redis 3.0.x
	
	wget http://download.redis.io/releases/redis-3.2.1.tar.gz
	tar xvzf redis-3.2.1.tar.gz
	cd redis-3.2.1
	make && make install PREFIX=/usr/local/redis-3.2.1
	cp src/redis-trib.rb /usr/local/redis-3.2.1/bin
	cp ./utils/create-cluster/create-cluster
	ln -s /usr/local/redis-3.2.1 /usr/local/redis   
	###检查版本信息
	./redis-cli -v
	redis-cli 3.2.1


###创建集群节点

首先我们需要几个运行在集群模式下的Redis实例, 运行在集群模式的Redis实例与普通的Redis实例有所不同，集群模式需要通过配置启用cluster特性，开启集群模式后的Redis实例便可以使用集群特有的命令和特性了.

最少选项的集群的配置文件: 
	
	mkdir /usr/local/redis/conf
	cd /usr/local/redis/conf
	vi 7001.conf

	port 7001
	daemonize yes
	pidfile /var/run/redis-7001.pid
	loglevel verbose
	logfile "/srv/logs/redis-7001.log"
	dir	/var/redis-data/
	dbfilename dump-7001.rdb
	appendfilename appendonly-7001.aof
	maxmemory-policy allkeys-lru	
	
	#集群配置
	cluster-enabled yes
	cluster-config-file /var/redis-data/nodes-7001.conf
	cluster-node-timeout 5000
	cluster-require-full-coverage no
	cluster-migration-barrier 1
	appendonly yes

	#安全配置
	bind 192.168.1.34 127.0.0.1
	requirepass "123456"  
	masterauth "123456" 
安全配置也可后期运行时添加（逐台添加）

	config set bind 192.168.1.34
	config set requirepass 123456
	config set masterauth 123456
	config rewrite

	 
说明：	

- port监听端口
- daemonize 后台运行
- logfile 日志文件路径
- bind绑定地址,不能绑定到127.0.0.1或localhost，否则指导客户端重定向时会报”Connection refused”的错误
- cluster-enabled选项用于开实例的集群模式
- cluster-conf-file选项则设定了保存节点配置文件的路径，默认值为nodes.conf。该节点配置文件无须人为修改，它由Redis集群在启动时自动创建， 并在有需要时自动进行更新。最好把cluster-config-file设置为对应的 端口nodes-xxx.conf这样便于区分
- cluster-node-timeout 集群超时时间,结点超时多久则认为它宕机了 
- cluster-require-full-coverage 槽是否全覆盖,默认是yes,只要有结点宕机导致16384个槽没全被覆盖，整个集群就全部停止服务，所以一定要改为no

官方配置：

https://raw.githubusercontent.com/antirez/redis/4.0/redis.conf

创建余下5个节点的配置文件：

	cat 7001.conf |tee 700{2,3}.conf
	cat 7001.conf |tee 800{1,2,3}.conf 
	
	sed -i "s/7001/7002/g" 7002.conf
	sed -i "s/7001/7003/g" 7003.conf
	sed -i "s/7001/8001/g" 8001.conf
	sed -i "s/7001/8002/g" 8002.conf
	sed -i "s/7001/8003/g" 8003.conf  

修改系统参数：

somaxconn该内核参数默认值一般是128,对于负载很大的服务程序来说大大的不够

	vim /etc/sysctl.conf
	net.core.somaxconn = 2048
	vm.overcommit_memory = 1

	vim /etc/rc.d/rc.local
	if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
	 echo never > /sys/kernel/mm/transparent_hugepage/enabled
	fi
	if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
	 echo never > /sys/kernel/mm/transparent_hugepage/defrag
	fi
	chmod +x /etc/rc.d/rc.local
	
	cat /sys/kernel/mm/transparent_hugepage/enabled
	cat /sys/kernel/mm/transparent_hugepage/defrag 

官方配置：https://redis.io/topics/admin

下面我们打开对应的目录，启动redis实例即可，启动的时候要进入到对应的目录然后启动。
	
	cd ../bin/
	./redis-server ../conf/7001.conf 
	./redis-server ../conf/7002.conf	
	./redis-server ../conf/7003.conf
	./redis-server ../conf/8001.conf
	./redis-server ../conf/8002.conf
	./redis-server ../conf/8003.conf

可以从每个实例的日志中看到， 因为cluster-config-file文件不存在， 所以每个节点都为它自身指定了一个新的 ID ,
	
	cat /srv/logs/redis-7001.log
	27040:M 09 May 22:53:50.197 * No cluster configuration found, I'm 1984c27297c6ef50bbfcbd35c11b93cc40ba17e4
	cat nodes-7001.conf 
	b528f0bb819b994ea0c61eeceaef2372e9d389ca :0 myself,master - 0 0 0 connected
	vars currentEpoch 0 lastVoteEpoch 0
以后每个实例就一直用自己头一次生成的ID了, 每个节点都是通过ID来记住其他节点, 而不是IP或端口号. IP地址和端口号会改变, 但是ID是唯一的,不变的. 这个叫做 Node ID.

现在我们已经有了六个正在运行中的Redis实例， 接下来我们需要使用这些实例来创建集群。

##创建集群

通过redis-trib的Redis集群命令行工具来创建Redis集群, 它是个Ruby程序, 在Redis的src目录中,这个程序通过向实例发送特殊命令来完成创建新集群,检查集群,或者对集群进行重新分片（reshared）等工作。redis-trib依赖Ruby和RubyGems，以及redis扩展。可以先用which命令查看是否已安装ruby和rubygems，用gem list –local查看本地是否已安装redis扩展。

redis-trib.rb具有以下功能：
	
	create：创建集群
	check：检查集群
	info：查看集群信息
	fix：修复集群
	reshard：在线迁移slot
	rebalance：平衡集群节点slot数量
	add-node：将新节点加入集群
	del-node：从集群中删除节点
	set-timeout：设置集群节点间心跳连接的超时时间
	call：在集群全部节点上执行命令
	import：将外部redis数据导入集群


###创建集群语法：
	
	./redis-trib.rb create ip:port ip:port ip:port
每个master有一个slave的创建命令如下：

	./redis-trib.rb create --replicas 1 ip:port ip:port ip:port

创建Redis集群命令(设置一个拥有3个主节点,3个从节点的集群.):
	
	./redis-trib.rb create --replicas 1 192.168.40.95:7001 192.168.40.95:7002 	192.168.40.95:7003 192.168.40.95:8001 192.168.40.95:8002 192.168.40.95:8003

	./redis-trib.rb create --replicas 1 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:8001 127.0.0.1:8002 127.0.0.1:8003
说明：

- 新建集群使用create命令.
- 指定replicas=1 参数表示为每个主节点创建一个从节点. 其他参数是实例的地址集合.

redis-trib 会打印出一份预想中的配置给你看， 如果你觉得没问题的话， 就可以输入 yes ， redis-trib 就会将这份配置应用到集群当中,让各个节点开始互相通讯.执行正常结果：
	
	>>> Creating cluster
	>>> Performing hash slots allocation on 6 nodes...
	...
	[OK] All 16384 slots covered


以上信息的其中一部分可以通过向集群中的任意节点（主节点或者从节点都可以）发送 CLUSTER NODES 命令来获得。该命令还可以获得节点 ID ， IP 地址和端口号， 标志（flag）， 最后发送 PING 的时间， 最后接收 PONG 的时间， 连接状态， 节点负责处理的槽。

Redis还在utils/create-cluster下提供了一个create-cluster脚本，能够创建出一个集群，类似我们上面建立起的3主3从的集群

具体创建流程如下：

- 首先为每个节点创建ClusterNode对象，包括连接每个节点。检查每个节点是否为独立且db为空的节点。执行load_info方法导入节点信息。
- 检查传入的master节点数量是否大于等于3个。只有大于3个节点才能组成集群。
- 计算每个master需要分配的slot数量，以及给master分配slave。分配的算法大致如下：
	- 先把节点按照host分类，这样保证master节点能分配到更多的主机中。
	- 不停遍历遍历host列表，从每个host列表中弹出一个节点，放入interleaved数组。直到所有的节点都弹出为止。
	- master节点列表就是interleaved前面的master数量的节点列表。保存在masters数组。
	- 计算每个master节点负责的slot数量，保存在slots_per_node对象，用slot总数除以master数量取整即可。
	- 遍历masters数组，每个master分配slots_per_node个slot，最后一个master，分配到16384个slot为止。
	- 接下来为master分配slave，分配算法会尽量保证master和slave节点不在同一台主机上。对于分配完指定slave数量的节点，还有多余的节点，也会为这些节点寻找master。分配算法会遍历两次masters数组:
		- 第一次遍历masters数组，在余下的节点列表找到replicas数量个slave。每个slave为第一个和master节点host不一样的节点，如果没有不一样的节点，则直接取出余下列表的第一个节点。
		- 第二次遍历是在对于节点数除以replicas不为整数，则会多余一部分节点。遍历的方式跟第一次一样，只是第一次会一次性给master分配replicas数量个slave，而第二次遍历只分配一个，直到余下的节点被全部分配出去。
- 打印出分配信息，并提示用户输入“yes”确认是否按照打印出来的分配方式创建集群。
- 输入“yes”后，会执行flush_nodes_config操作，该操作执行前面的分配结果，给master分配slot，让slave复制master，对于还没有握手（cluster meet）的节点，slave复制操作无法完成，不过没关系，flush_nodes_config操作出现异常会很快返回，后续握手后会再次执行flush_nodes_config。
- 给每个节点分配epoch，遍历节点，每个节点分配的epoch比之前节点大1。
- 节点间开始相互握手，握手的方式为节点列表的其他节点跟第一个节点握手。
- 然后每隔1秒检查一次各个节点是否已经消息同步完成，使用ClusterNode的get_config_signature方法，检查的算法为获取每个节点cluster nodes信息，排序每个节点，组装成node_id1:slots|node_id2:slot2|...的字符串。如果每个节点获得字符串都相同，即认为握手成功。
- 此后会再执行一次flush_nodes_config，这次主要是为了完成slave复制操作。
- 最后再执行check_cluster，全面检查一次集群状态。包括和前面握手时检查一样的方式再检查一遍。确认没有迁移的节点。确认所有的slot都被分配出去了。
- 至此完成了整个创建流程，返回[OK] All 16384 slots covered.。

##使用集群

此时Redis集群的一个问题是客户端库的缺乏.客户端库实现:

- redis-rb-cluster, 用Ruby写的, 作为一个其他语言的参考. 它是原始redis-rb的简单包装, 实现使用集群的最小功能.
- redis-py-cluster,流行的Predis支持Redis集群, 这功能刚被开发.
- Java使用最多的Jedis最近开始支持Redis集群, 请查看Jedis Cluster的README.
- redis-cli工具实现了一个基本的集群支持, 启动时加上-c参数.

使用redis-cli方式, 举个例子:
	
	$ redis-cli -c -p 7000
	redis 127.0.0.1:7000> set foo bar
	-> Redirected to slot [12182] located at 127.0.0.1:7002
	OK
	redis 127.0.0.1:7002> set hello world
	-> Redirected to slot [866] located at 127.0.0.1:7000
	OK
	redis 127.0.0.1:7000> get foo
	-> Redirected to slot [12182] located at 127.0.0.1:7002
	"bar"
	redis 127.0.0.1:7000> get hello
	-> Redirected to slot [866] located at 127.0.0.1:7000
	"world"

redis-cli仅支持最基础的功能, 所以它一般只用来测试集群节点是否被正确地导向. 一个严谨的客户端能更好地实现此功能, 还能缓存hash slots和节点地址的映射, 能把连接正确地导向到节点. 这个映射只会在集群配置有变动时刷新, 比如某节点挂掉, 或者管理员添加删除了节点. 


###check检查集群
检查集群状态的命令，没有其他参数，只需要选择一个集群中的一个节点即可：
  
	./redis-trib.rb check 127.0.0.1:7001
###info查看集群信息
info命令用来查看集群的信息。info命令也是先执行load_cluster_info_from_node获取完整的集群信息。然后显示ClusterNode的info_string结果，示例如下：
  
	./redis-trib.rb info 127.0.0.1:7001
  
###添加master节点
复制、修改配置文件	，启动服务

**加入空节点到集群**

add-node将一个节点添加到集群里面， 第一个是新节点ip:port, 第二个是任意一个已存在节点ip:port

    redis-trib.rb add-node 127.0.0.1:7007 127.0.0.1:7001
新节点没有包含任何数据， 因为它没有包含任何slot。新加入的加点是一个主节点， 当集群需要将某个从节点升级为新的主节点时， 这个新节点不会被选中，同时新的主节点因为没有包含任何slot，不参加选举和failover。

add-node命令可以将新节点加入集群，节点可以为master，也可以为某个master节点的slave。
	
	add-node    new_host:new_port existing_host:existing_port
	          --slave
	          --master-id <arg>
add-node有两个可选参数：

- --slave：设置该参数，则新节点以slave的角色加入集群
- --master-id：这个参数需要设置了--slave才能生效，--master-id用来指定新节点的master节点。如果不设置该参数，则会随机为节点选择master节点。

add-node流程如下：

- 通过load_cluster_info_from_node方法转载集群信息，check_cluster方法检查集群是否健康。
- 如果设置了--slave，则需要为该节点寻找master节点。设置了--master-id，则以该节点作为新节点的master，如果没有设置--master-id，则调用get_master_with_least_replicas方法，寻找slave数量最少的master节点。如果slave数量一致，则选取load_cluster_info_from_node顺序发现的第一个节点。load_cluster_info_from_node顺序的第一个节点是add-node设置的existing_host:existing_port节点，后面的顺序根据在该节点执行cluster nodes返回的结果返回的节点顺序。
- 连接新的节点并与集群第一个节点握手。
- 如果没设置–slave就直接返回ok，设置了–slave，则需要等待确认新节点加入集群，然后执行cluster replicate命令复制master节点。
- 至此，完成了全部的增加节点的流程。

**为新节点分配slot**
    
	redis-trib.rb reshard 127.0.0.1:7007
    #根据提示选择要迁移的slot数量(ps:这里选择500)  
    How many slots do you want to move (from 1 to 16384)? 500  
    #选择要接受这些slot的node-id  
    What is the receiving node ID? f51e26b5d5ff74f85341f06f28f125b7254e61bf  
    #选择slot来源:  
    #all表示从所有的master重新分配，  
    #或者数据要提取slot的master节点id,最后用done结束  
    Please enter all the source node IDs.  
      Type 'all' to use all the nodes as source nodes for the hash slots.  
      Type 'done' once you entered all the source nodes IDs.  
    Source node #1:all  
    #打印被移动的slot后，输入yes开始移动slot以及对应的数据.  
    #Do you want to proceed with the proposed reshard plan (yes/no)? yes  
###添加新的slave节点
操作同添加master节点基本相同,加入空节点到集群之后，连接新节点：

	./redis-cli -p 7007
	cluster nodes
	根据以上的执行结果，选取master的节点id执行：cluster replicate 对应master的node-id
	cluster replicate 2b9ebcbd627ff0fd7a7bbcc5332fb09e72788835    
注意:在线添加slave 时，需要bgsave整个master数据，并传递到slave，再由 slave加载rdb文件到内存，rdb生成和传输的过程中消耗Master大量内存和网络IO,以此不建议单实例内存过大，线上小心操作。


add-node命令的执行示例：

	$ruby redis-trib.rb add-node --slave --master-id dcb792b3e85726f012e83061bf237072dfc45f99 127.0.0.1:7007 127.0.0.1:7001

###del-node从集群中删除节点

del-node可以把某个节点从集群中删除。del-node只能删除没有分配slot的节点。删除命令传递两个参数：
	
	host:port：从该节点获取集群信息。
	node_id：需要删除的节点id。
**del-node示例如下：**

	$ruby redis-trib.rb del-node 10.180.157.199:6379 d5f6d1d17426bd564a6e309f32d0f5b96962fe53

**del-node流程如下：**

- 通过load_cluster_info_from_node方法转载集群信息。
- 根据传入的node id获取节点，如果节点没找到，则直接提示错误并退出。
- 如果节点分配的slot不为空，则直接提示错误并退出。
- 遍历集群内的其他节点，执行cluster forget命令，从每个节点中去除该节点。如果删除的节点是master，而且它有slave的话，这些slave会去复制其他master，调用的方法是get_master_with_least_replicas，与add-node没设置--master-id寻找master的方法一样。
- 然后关闭该节点

**删除一个slave节点**

	#redis-trib del-node ip:port '<node-id>'  
    redis-trib.rb del-node 127.0.0.1:7005 'c7ee2fca17cb79fe3c9822ced1d4f6c5e169e378'  
**删除一个master节点**

删除master节点之前首先要使用reshard移除master的全部slot,然后再删除当前节点(目前redis-trib.rb只能把被删除master的slot对应的数据迁移到一个节点上)

	#把10.10.34.14:6386当前master迁移到10.10.34.14:6380上  
    redis-trib.rb reshard 10.10.34.14:6380  
    #根据提示选择要迁移的slot数量(ps:这里选择500)  
    How many slots do you want to move (from 1 to 16384)? 500(被删除master的所有slot数量)  
    #选择要接受这些slot的node-id(10.10.34.14:6380)  
    What is the receiving node ID? c4a31c852f81686f6ed8bcd6d1b13accdc947fd2 (ps:10.10.34.14:6380的node-id)  
    Please enter all the source node IDs.  
      Type 'all' to use all the nodes as source nodes for the hash slots.  
      Type 'done' once you entered all the source nodes IDs.  
    Source node #1:f51e26b5d5ff74f85341f06f28f125b7254e61bf(被删除master的node-id)  
    Source node #2:done  
    #打印被移动的slot后，输入yes开始移动slot以及对应的数据.  
    #Do you want to proceed with the proposed reshard plan (yes/no)? yes  
**删除空master节点**

	redis-trib.rb del-node 10.10.34.14:6386 'f51e26b5d5ff74f85341f06f28f125b7254e61bf'  
	   
###fix修复集群

fix命令的流程跟check的流程很像，显示加载集群信息，然后在check_cluster方法内传入fix为
true的变量，会在集群检查出现异常的时候执行修复流程。目前fix命令能修复两种异常，一种是集群有处于迁移中的slot的节点，一种是slot未完全分配的异常。

fix_open_slot方法是修复集群有处于迁移中的slot的节点异常。

- 先检查该slot是谁负责的，迁移的源节点如果没完成迁移，owner还是该节点。没有owner的slot无法完成修复功能。
- 遍历每个节点，获取哪些节点标记该slot为migrating状态，哪些节点标记该slot为importing状态。对于owner不是该节点，但是通过cluster countkeysinslot获取到该节点有数据的情况，也认为该节点为importing状态。
- 如果migrating和importing状态的节点均只有1个，这可能是迁移过程中redis-trib.rb被中断所致，直接执行move_slot继续完成迁移任务即可。传递dots和fix为true。
- 如果migrating为空，importing状态的节点大于0，那么这种情况执行回滚流程，将importing状态的节点数据通过move_slot方法导给slot的owner节点，传递dots、fix和cold为true。接着对importing的节点执行cluster stable命令恢复稳定。
- 如果importing状态的节点为空，有一个migrating状态的节点，而且该节点在当前slot没有数据，那么可以直接把这个slot设为stable。
- 如果migrating和importing状态不是上述情况，目前redis-trib.rb工具无法修复，上述的三种情况也已经覆盖了通过redis-trib.rb工具迁移出现异常的各个方面，人为的异常情形太多，很难考虑完全。

fix_slots_coverage方法能修复slot未完全分配的异常。未分配的slot有三种状态。

- 所有节点的该slot都没有数据。该状态redis-trib.rb工具直接采用随机分配的方式，并没有考虑节点的均衡。本人尝试对没有分配slot的集群通过fix修复集群，结果slot还是能比较平均的分配，但是没有了连续性，打印的slot信息非常离散。
- 有一个节点的该slot有数据。该状态下，直接把slot分配给该slot有数据的节点。
- 有多个节点的该slot有数据。此种情况目前还处于TODO状态，不过redis作者列出了修复的步骤，对这些节点，除第一个节点，执行cluster migrating命令，然后把这些节点的数据迁移到第一个节点上。清除migrating状态，然后把slot分配给第一个节点。

###reshard在线迁移slot

对于负载/数据不均匀的情况，可以在线reshard slot来解决,方法与添加新master的reshard一样，只是需要reshard的master节点是已存在的老节点.

reshard命令可以在线把集群的一些slot从集群原来slot负责节点迁移到新的节点，利用reshard可以完成集群的在线横向扩容和缩容。

reshard的参数很多，下面来一一解释一番：
	
	reshard         host:port
	                --from <arg>
	                --to <arg>
	                --slots <arg>
	                --yes
	                --timeout <arg>
	                --pipeline <arg>
- host:port：这个是必传参数，用来从一个节点获取整个集群信息，相当于获取集群信息的入口。
- --from <arg>：需要从哪些源节点上迁移slot，可从多个源节点完成迁移，以逗号隔开，传递的是节点的node id，还可以直接传递--from all，这样源节点就是集群的所有节点，不传递该参数的话，则会在迁移过程中提示用户输入。
- --to <arg>：slot需要迁移的目的节点的node id，目的节点只能填写一个，不传递该参数的话，则会在迁移过程中提示用户输入。
- --slots <arg>：需要迁移的slot数量，不传递该参数的话，则会在迁移过程中提示用户输入。
- --yes：设置该参数，可以在打印执行reshard计划的时候，提示用户输入yes确认后再执行reshard。
- --timeout <arg>：设置migrate命令的超时时间。
- --pipeline <arg>：定义cluster getkeysinslot命令一次取出的key数量，不传的话使用默认值为10。

####迁移的流程如下：

- 通过load_cluster_info_from_node方法装载集群信息。
- 执行check_cluster方法检查集群是否健康。只有健康的集群才能进行迁移。
- 获取需要迁移的slot数量，用户没传递--slots参数，则提示用户手动输入。
- 获取迁移的目的节点，用户没传递--to参数，则提示用户手动输入。此处会检查目的节点必须为master节点。
- 获取迁移的源节点，用户没传递--from参数，则提示用户手动输入。此处会检查源节点必须为master节点。--from all的话，源节点就是除了目的节点外的全部master节点。这里为了保证集群slot分配的平均，建议传递--from all。
- 执行compute_reshard_table方法，计算需要迁移的slot数量如何分配到源节点列表，采用的算法是按照节点负责slot数量由多到少排序，计算每个节点需要迁移的slot的方法为：迁移slot数量 * (该源节点负责的slot数量 / 源节点列表负责的slot总数)。这样算出的数量可能不为整数，这里代码用了下面的方式处理：
	
	n = (numslots/source_tot_slots*s.slots.length)
	if i == 0
	    n = n.ceil
	else
	    n = n.floor
这样的处理方式会带来最终分配的slot与请求迁移的slot数量不一致，这个BUG已经在github上提给作者，https://github.com/antirez/redis/issues/2990。

- 打印出reshard计划，如果用户没传--yes，就提示用户确认计划。
- 根据reshard计划，一个个slot的迁移到新节点上，迁移使用move_slot方法，该方法被很多命令使用，具体可以参见下面的迁移流程。move_slot方法传递dots为true和pipeline数量。
- 至此，就完成了全部的迁移任务。

move_slot方法可以在线将一个slot的全部数据从源节点迁移到目的节点，fix、reshard、rebalance都需要调用该方法迁移slot。

**move_slot接受下面几个参数:**

- pipeline：设置一次从slot上获取多少个key。
- quiet：迁移会打印相关信息，设置quiet参数，可以不用打印这些信息。
- cold：设置cold，会忽略执行importing和migrating。
- dots：设置dots，则会在迁移过程打印迁移key数量的进度。
- update：设置update，则会更新内存信息，方便以后的操作。

**move_slot流程如下：**

- 如果没有设置cold，则对源节点执行cluster importing命令，对目的节点执行migrating命令。fix的时候有可能importing和migrating已经执行过来，所以此种场景会设置cold。
- 通过cluster getkeysinslot命令，一次性获取远节点迁移slot的pipeline个key的数量.
- 对这些key执行migrate命令，将数据从源节点迁移到目的节点。
- 如果migrate出现异常，在fix模式下，BUSYKEY的异常，会使用migrate的replace模式再执行一次，BUSYKEY表示目的节点已经有该key了，replace模式可以强制替换目的节点的key。不是fix模式就直接返回错误了。
- 循环执行cluster getkeysinslot命令，直到返回的key数量为0，就退出循环。
- 如果没有设置cold，对每个节点执行cluster setslot命令，把slot赋给目的节点。
- 如果设置update，则修改源节点和目的节点的slot信息。
- 至此完成了迁移slot的流程。

###rebalance平衡集群节点slot数量
rebalance命令可以根据用户传入的参数平衡集群节点的slot数量，rebalance功能非常强大，可以传入的参数很多，以下是rebalance的参数列表和命令示例。
	
	rebalance       host:port
	                --weight <arg>
	                --auto-weights
	                --threshold <arg>
	                --use-empty-masters
	                --timeout <arg>
	                --simulate
	                --pipeline <arg>

	./redis-trib.rb rebalance --threshold 1 --weight b31e3a2e=5 --weight 60b8e3a1=5 --use-empty-masters  --simulate 10.180.157.199:6379
下面也先一一解释下每个参数的用法：

- host:port：这个是必传参数，用来从一个节点获取整个集群信息，相当于获取集群信息的入口。
- --weight <arg>：节点的权重，格式为node_id=weight，如果需要为多个节点分配权重的话，需要添加多个--weight <arg>参数，即--weight b31e3a2e=5 --weight 60b8e3a1=5，node_id可为节点名称的前缀，只要保证前缀位数能唯一区分该节点即可。没有传递–weight的节点的权重默认为1。
- --auto-weights：这个参数在rebalance流程中并未用到。
- --threshold <arg>：只有节点需要迁移的slot阈值超过threshold，才会执行rebalance操作。具体计算方法可以参考下面的rebalance命令流程的第四步。
- --use-empty-masters：rebalance是否考虑没有节点的master，默认没有分配slot节点的master是不参与rebalance的，设置--use-empty-masters可以让没有分配slot的节点参与rebalance。
- --timeout <arg>：设置migrate命令的超时时间。
- --simulate：设置该参数，可以模拟rebalance操作，提示用户会迁移哪些slots，而不会真正执行迁移操作。
- --pipeline <arg>：与reshar的pipeline参数一样，定义cluster getkeysinslot命令一次取出的key数量，不传的话使用默认值为10。

**rebalance命令流程如下：**

- load_cluster_info_from_node方法先加载集群信息。
- 计算每个master的权重，根据参数--weight <arg>，为每个设置的节点分配权重，没有设置的节点，则权重默认为1。
- 根据每个master的权重，以及总的权重，计算自己期望被分配多少个slot。计算的方式为：总slot数量 * （自己的权重 / 总权重）。
- 计算每个master期望分配的slot是否超过设置的阈值，即--threshold <arg>设置的阈值或者默认的阈值。计算的方式为：先计算期望移动节点的阈值，算法为：(100-(100.0*expected/n.slots.length)).abs，如果计算出的阈值没有超出设置阈值，则不需要为该节点移动slot。只要有一个master的移动节点超过阈值，就会触发rebalance操作。
- 如果触发了rebalance操作。那么就开始执行rebalance操作，先将每个节点当前分配的slots数量减去期望分配的slot数量获得balance值。将每个节点的balance从小到大进行排序获得sn数组。
- 用dst_idx和src_idx游标分别从sn数组的头部和尾部开始遍历。目的是为了把尾部节点的slot分配给头部节点。

sn数组保存的balance列表排序后，负数在前面，正数在后面。负数表示需要有slot迁入，所以使用dst_idx游标，正数表示需要有slot迁出，所以使用src_idx游标。理论上sn数组各节点的balance值加起来应该为0，不过由于在计算期望分配的slot的时候只是使用直接取整的方式，所以可能出现balance值之和不为0的情况，balance值之和不为0即为节点不平衡的slot数量，由于slot总数有16384个，不平衡数量相对于总数，基数很小，所以对rebalance流程影响不大。

- 获取sn[dst_idx]和sn[src_idx]的balance值较小的那个值，该值即为需要从sn[src_idx]节点迁移到sn[dst_idx]节点的slot数量。
- 接着通过compute_reshard_table方法计算源节点的slot如何分配到源节点列表。这个方法在reshard流程中也有调用，具体步骤可以参考reshard流程的第六步。
- 如果是simulate模式，则只是打印出迁移列表。
- 如果没有设置simulate，则执行move_slot操作，迁移slot，传入的参数为:quiet=>true,:dots=>false,:update=>true。
- 迁移完成后更新sn[dst_idx]和sn[src_idx]的balance值。如果balance值为0后，游标向前进1。
- 直到dst_idx到达src_idx游标，完成整个rebalance操作。



**set-timeout设置集群节点间心跳连接的超时时间**

set-timeout用来设置集群节点间心跳连接的超时时间，单位是毫秒，不得小于100毫秒，因为100毫秒对于心跳时间来说太短了。该命令修改是节点配置参数cluster-node-timeout，默认是15000毫秒。通过该命令，可以给每个节点设置超时时间，设置的方式使用config set命令动态设置，然后执行config rewrite命令将配置持久化保存到硬盘。

示例：

	ruby redis-trib.rb set-timeout 10.180.157.199:6379 30000

**call在集群全部节点上执行命令**

call命令可以用来在集群的全部节点执行相同的命令。call命令也是需要通过集群的一个节点地址，连上整个集群，然后在集群的每个节点执行该命令。

	$ruby redis-trib.rb call 10.180.157.199:6379 get key


**import将外部redis数据导入集群**

import命令可以把外部的redis节点数据导入集群。导入的流程如下：

- 通过load_cluster_info_from_node方法转载集群信息，check_cluster方法检查集群是否健康。
- 连接外部redis节点，如果外部节点开启了cluster_enabled，则提示错误。
- 通过scan命令遍历外部节点，一次获取1000条数据。
- 遍历这些key，计算出key对应的slot。
- 执行migrate命令,源节点是外部节点,目的节点是集群slot对应的节点，如果设置了--copy参数，则传递copy参数，如果设置了--replace，则传递replace参数。
- 不停执行scan命令，直到遍历完全部的key。
- 至此完成整个迁移流程
这中间如果出现异常，程序就会停止。没使用--copy模式，则可以重新执行import命令，使用--copy的话，最好清空新的集群再导入一次。

import命令更适合离线的把外部redis数据导入，在线导入的话最好使用更专业的导入工具，以slave的方式连接redis节点去同步节点数据应该是更好的方式。

下面是一个例子

	./redis-trib.rb import --from 10.0.10.1:6379 10.10.10.1:7000
上面的命令是把 10.0.10.1:6379（redis 2.8）上的数据导入到 10.10.10.1:7000这个节点所在的集群
##5. 连接Redis集群

通过上面的输出，我们可以看出Redis三个主节点的slot范围。一个 Redis 客户端可以向集群中的任意节点（包括从节点）发送命令请求。我们首先连接第一个节点：
	
	./redis-cli -p 7001
	127.0.0.1:7001> set a 1 
	(error) MOVED 15495 127.0.0.1:7003
	127.0.0.1:7001> get a
	(error) MOVED 15495 127.0.0.1:7003
	127.0.0.1:7001> set b 1
	OK

节点会对命令请求进行分析和key的slot计算，并且会查找这个命令所要处理的键所在的槽。如果要查找的哈希槽正好就由接收到命令的节点负责处理， 那么节点就直接执行这个命令。

另一方面， 如果所查找的槽不是由该节点处理的话， 节点将查看自身内部所保存的哈希槽到节点 ID 的映射记录， 并向客户端回复一个 MOVED 错误。上面的错误信息包含键 x 所属的哈希槽15495， 以及负责处理这个槽的节点的 IP 和端口号 127.0.0.1:7003 。

虽然我们用Node ID来标识集群中的节点， 但是为了让客户端的转向操作尽可能地简单， 节点在 MOVED 错误中直接返回目标节点的 IP 和端口号， 而不是目标节点的 ID 。客户端应该记录槽15495由节点127.0.0.1:7003负责处理“这一信息， 这样当再次有命令需要对槽15495执行时， 客户端就可以加快寻找正确节点的速度。这样，当集群处于稳定状态时，所有客户端最终都会保存有一个哈希槽至节点的映射记录，使得集群非常高效： 客户端可以直接向正确的节点发送命令请求， 无须转向、代理或者其他任何可能发生单点故障（single point failure）的实体（entiy）。

**测试集群：**

	redis-cli -c -p 7000	
	127.0.0.1:7001> set a 1
	-> Redirected to slot [15495] located at 127.0.0.1:7003
	OK
	127.0.0.1:7003> set b 1
	-> Redirected to slot [3300] located at 127.0.0.1:7001
	OK
	127.0.0.1:7001> get a
	-> Redirected to slot [15495] located at 127.0.0.1:7003
	"1"
	127.0.0.1:7003> get b
	-> Redirected to slot [3300] located at 127.0.0.1:7001
	"1"

##6.java 连接Redis集群

使用 jedis-2.7.2.jar jar 包

    import java.util.HashSet;  
    import java.util.Set;  
      
    import redis.clients.jedis.HostAndPort;  
    import redis.clients.jedis.JedisCluster;  
    import redis.clients.jedis.JedisPoolConfig;  
      
    public class JedisClusterTest {  
      
        public static void main(String[] args) {  
      
            JedisPoolConfig config = new JedisPoolConfig();  
            config.setMaxTotal(20);  
            config.setMaxIdle(2);  
      
            HostAndPort hp0 = new HostAndPort("localhost", 7000);  
            HostAndPort hp1 = new HostAndPort("localhost", 7001);  
            HostAndPort hp2 = new HostAndPort("localhost", 7002);  
            HostAndPort hp3 = new HostAndPort("localhost", 7003);  
            HostAndPort hp4 = new HostAndPort("localhost", 7004);  
            HostAndPort hp5 = new HostAndPort("localhost", 7005);  
      
            Set<HostAndPort> hps = new HashSet<HostAndPort>();  
            hps.add(hp0);  
            hps.add(hp1);  
            hps.add(hp2);  
            hps.add(hp3);  
            hps.add(hp4);  
            hps.add(hp5);  
      
            // 超时，最大的转发数，最大链接数，最小链接数都会影响到集群  
            JedisCluster jedisCluster = new JedisCluster(hps, 5000, 10, config);  
      
            long start = System.currentTimeMillis();  
            for (int i = 0; i < 100; i++) {  
                jedisCluster.set("sn" + i, "n" + i);  
            }  
            long end = System.currentTimeMillis();  
      
            System.out.println("Simple  @ Sharding Set : " + (end - start) / 10000);  
      
            for (int i = 0; i < 1000; i++) {  
                System.out.println(jedisCluster.get("sn" + i));  
            }  
      
            jedisCluster.close();  
      
        }  
      
    } 
 
redis-cluster客户端的一些坑:

- cluster环境下slave默认不接受任何读写操作，在slave执行readonly命令后，可执行读操作
- client端不支持多key操作(mget,mset等)，但当keys集合对应的slot相同时支持mget操作见:hash_tag
- 不支持keys批量操作,不支持多数据库，只有一个db，select 0 
- 不支持密码验证
- 监控一般都是基于info数据统计指标，千万不要用keys,monitor等命令做统计监控。


##cluster操作

cluster集群相关命令,更多redis相关命令见文档:http://redis.readthedocs.org/en/latest/

	集群  
    CLUSTER INFO 打印集群的信息  
    CLUSTER NODES 列出集群当前已知的所有节点（node），以及这些节点的相关信息。  

    节点  
    CLUSTER MEET <ip> <port> 将 ip 和 port 所指定的节点添加到集群当中，让它成为集群的一份子。  
    CLUSTER FORGET <node_id> 从集群中移除 node_id 指定的节点。  
    CLUSTER REPLICATE <node_id> 将当前节点设置为 node_id 指定的节点的从节点。  
    CLUSTER SAVECONFIG 将节点的配置文件保存到硬盘里面。  

    槽(slot)  
    CLUSTER ADDSLOTS <slot> [slot ...] 将一个或多个槽（slot）指派（assign）给当前节点。  
    CLUSTER DELSLOTS <slot> [slot ...] 移除一个或多个槽对当前节点的指派。  
    CLUSTER FLUSHSLOTS 移除指派给当前节点的所有槽，让当前节点变成一个没有指派任何槽的节点。  
    CLUSTER SETSLOT <slot> NODE <node_id> 将槽slot指派给node_id指定的节点，如果槽已经指派给另一个节点，那么先让另一个节点删除该槽>，然后再进行指派。  
    CLUSTER SETSLOT <slot> MIGRATING <node_id> 将本节点的槽 slot 迁移到 node_id 指定的节点中。  
    CLUSTER SETSLOT <slot> IMPORTING <node_id> 从 node_id 指定的节点中导入槽 slot 到本节点。  
    CLUSTER SETSLOT <slot> STABLE 取消对槽 slot 的导入（import）或者迁移（migrate）。  

    键  
    CLUSTER KEYSLOT <key> 计算键key应该被放置在哪个槽上。  
    CLUSTER COUNTKEYSINSLOT <slot> 返回槽slot目前包含的键值对数量。  
    CLUSTER GETKEYSINSLOT <slot> <count> 返回count个slot槽中的键。  

##7.Redis集群常见错误

### java 连接redis集群异常：Too many Cluster redirections
这种情况一般情况下都是redis绑定ip问题，默认情况下redis绑定的ip是本机的127.0.0.1如果redis部署在其他机器上，而本地测试程序想要通过网络链接到redis集群，那么就需要注意，在redis.conf文件中配置 bind xxx.xxx.xxx.xxx 注意这个地方要配置成客户端链接的 ip

注意：如果 redis 绑定了指定的 ip 地址了，这时候在启动集群的时候也需要注意，需要指定ip地址了，本来启动集群的方式是这样的：

	./redis-trib.rb create --replicas 1 127.0.0.1:7000  127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
现在就是这样的

	./redis-trib.rb create --replicas 1 xxx.xxx.xxx.xxx:7000  xxx.xxx.xxx.xxx:7001 xxx.xxx.xxx.xxx:7002 xxx.xxx.xxx.xxx:7003 xxx.xxx.xxx.xxx:7004 xxx.xxx.xxx.xxx:7005./redis-trib.rb create --replicas 1 127.0.0.1:7000  127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005

### 创建集群异常:[ERR] Node 192.168.1.34:7001 is not empty. Either the node already knows other nodes
解决执行1、2或3：

1. 将需要新增的节点下aof、rdb等本地备份文件删除；

2. 同时将新Node的集群配置文件删除,即：删除你redis.conf里面cluster-config-file所在的文件；

3. 再次添加新节点如果还是报错，则登录新Node,./redis-cli–h x –p对数据库进行清除：

		172.168.63.201:7001>  flushdb      #清空当前数据库

###创建集群异常:redis-trib.rb:24:in `require': no such file to load -- rubygems (LoadError)

提示缺少ruby、rubygems组件，使用yum安装：

	yum install -y rubygems

###创建集群异常：no such file to load -- redis (LoadError)

是因为缺少redis和ruby的接口，使用gem 安装

	gem install redis	
	指定版本安装：gem install redis --version 3.2.1  
	下载失败可手动下载http://rubygems.org/gems/redis/versions/3.2.1  
###确保系统安装zlib,否则gem install会报(no such file to load -- zlib)
    下载:zlib-1.2.6.tar并解压  
    ./configure  
    make  
    make install  
###gem install redis执行出错提示无法连接gem服务器，则需下载安装:

	wget https://rubygems.global.ssl.fastly.net/gems/redis-3.2.1.gem
	gem install -l ./redis-3.2.1.gem
	或者使用万能淘宝的镜像站http://ruby.taobao.org/淘宝ruby资源站是完全的镜像复制，而且十五分钟复制更新一次，连接速度很快很稳定
	步骤：
		gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
		gem sources -l
	这一步可能报错 ssl 的问题无法打开https的连接，解决办法参考:
	http://blog.csdn.net/beyondlpf/article/details/51275051

执行redis-trib.rb创建命令，还会报错，提示连接节点错误：
	
	[ERR] Sorry, can't connect to node 
可能原因是ruby和gem版本太低，安装新版本。

	wget ftp://ftp.ruby-lang.org/pub/ruby/ruby-2.3.1.tar.gz
	./configure --prefix=/usr/local --disable-install-doc --with-opt-dir=/usr/local/lib
	make && make install

	gem update --system
	gem install redis


如果需要全部重新自动配置,则删除所有的配置好的cluster-config-file,重新启动所有的redis-server,然后重新执行配置命令即可


###用check检查集群运行状态时，遇到错误：

	[ERR] Not all 16384 slots are covered by nodes.
原因：

这个往往是由于主node移除了，但是并没有移除node上面的slot，从而导致了slot总数没有达到16384，其实也就是slots分布不正确。所以在删除节点的时候一定要注意删除的是否是Master主节点。

1)、官方是推荐使用redis-trib.rb fix 来修复集群…. ….  通过cluster nodes看到7001这个节点被干掉了… 那么

	./redis-trib.rb fix localhost:7001


修复完成后再用check命令检查下是否正确

	./redis-trib.rb check172.168.63.202:7000

只要输入任意集群中节点即可，会自动检查所有相关节点。可以查看相应的输出看下是否是每个Master都有了slots,如果分布不均匀那可以使用下面的方式重新分配slot:

	./redis-trib.rb reshard localhost:7001


#内部数据结构

Redis Cluster功能涉及三个核心的数据结构clusterState、clusterNode、clusterLink都在cluster.h中定义。这三个数据结构中最重要的属性就是：clusterState.slots、clusterState.slots_to_keys和clusterNode.slots了，它们保存了三种映射关系：

- clusterState：集群状态 
	- nodes：所有结点
	- migrating_slots_to：迁出中的槽
	- importing_slots_from：导入中的槽
	- slots_to_keys：槽中包含的所有Key，用于迁移Slot时获得其包含的Key
	- slots：Slot所属的结点，用于处理请求时判断Key所在Slot是否自己负责
- clusterNode：结点信息 
	- slots：结点负责的所有Slot，用于发送Gossip消息通知其他结点自己负责的Slot。通过位图方式保存节省空间，16384/8恰好是2048字节，所以槽总数16384不是随意定的。
- clusterLink：与其他结点通信的连接

#处理流程

在单机模式下，Redis对请求的处理很简单。Key存在的话，就执行请求中的操作；Key不存在的话，就告诉客户端Key不存在。然而在集群模式下，因为涉及到请求重定向和Slot迁移，所以对请求的处理变得很复杂，流程如下：

- 检查Key所在Slot是否属于当前Node？ 
	- 1 计算crc16(key) % 16384得到Slot 
	- 2 查询clusterState.slots负责Slot的结点指针 
	- 3 与myself指针比较
- 若不属于，则响应MOVED错误重定向客户端
- 若属于且Key存在，则直接操作，返回结果给客户端
- 若Key不存在，检查该Slot是否迁出中？(clusterState.migrating_slots_to)
- 若Slot迁出中，返回ASK错误重定向客户端到迁移的目的服务器上
- 若Slot未迁出，检查Slot是否导入中？(clusterState.importing_slots_from)
- 若Slot导入中且有ASKING标记，则直接操作
- 否则响应MOVED错误重定向客户端