如数据库采用单点部署，如果碰到数据库宕机或者被毁灭性破坏那是多么的糟糕。mongodb如其他主流数据库，支持读写分离、双击热备份和集群部署,NoSQL的产生就是为了解决大数据量、高扩展性、高性能、灵活数据模型、高可用性

主从复制好处：
	
	<1>  数据备份。
	<2>  数据恢复。
	<3>  读写分离。

主从复制配置：
	
启动主数据库：

		mongod --dbpath=xxx  --master
端口未指定采用默认的27017

启动从库：
		mongod --dbpath=xxx --port=27018 --slave --source=127.0.0.1:27017

从库的启动信息/日志信息中有applied 1 operations信息，发生时间间隔在10s，表示从库每隔10s向主库同步数据，同步依据是寻找主库的OPLog日志（sync_pullOpLog）

可以在启动从时加以下常用参数

	--slavedelay 10      #延时复制 单位为秒
	--autoresync         #自动重新同步
	--only               #复制指定的数据库，默认复制所有的库
	--oplogSize          #主节点的oplog日志大小，单位为M，建议设大点(更改oplog大小时，只需停主库，删除local.*，然后加--oplogSize=* 重新启动即可,*代表大小)

常用命令：
	
	手动同步命令：db.runCommand({"resync":1}) 
	状态查询：db.runCommand({"isMaster":1})  
	查看各Collection状态：db.printCollectionStats(); 
	查看主从复制状态：db.printReplicationInfo();


**测试主从同步：**

登陆主库新增集合、插入数据，然后登陆从库查看集合、数据，发现已经同步更新了


如果想增加一台从库，不在启动时指定主库，也可以在后期指定。主库或从库中都有一个local的数据库，主要用于存放内部复制信息。

		mongod --dbpath=xxx --port=27019 --slave
启动日志提示没有主库(no source given,and a master to local.sources....),新开cmd，进入mongodb的bin目录执行：
		mongo 127.0.0.1:27019
		use local
		db.sources.find()
		db.sources.insert({"host":"127.0.0.1:27017"})
		db.sources.find()
		/* 10s后查询 */
		db.sources.find()

读写分离：

在mongodb中实现读写分离其实很简单，在默认的情况下，从属数据库不支持数据的读取，但是没关系，
在驱动中给我们提供了一个叫做“slaveOkay"来让我们可以显示的读取从属数据库来减轻主数据库的性能压力。


二：复制集/副本集

mongoDB官方已经不建议使用主从模式了，替代方案是采用副本集的模式,副本集合（Replica Sets)，是一个基于主/从复制机制的复制功能，但增加了自动故障转移和恢复特性

复制在为数据提供了冗余同时，也提高了数据的可用性。由于在不同的数据库服务器上拥有多个数据镜像，复制可以有效的防止由于单台服务器故障而导致的数据丢失。复制还能够帮助我们从硬件故障或是服务中断中恢复数据。我们也可以通过增加复制节点来将其用于灾难恢复、报表或是备份

我们可以通过复制的方式来提高读的性能。客户端可以将读与写请求分别发送到不同的服务器上。我们还能够通过在其他数据中心建立分布式复制节点的方式来做异地冗灾，以进一步提高可用性。

	保障数据的安全性
	数据高可用性 (24*7)
	灾难恢复
	无需停机维护（如备份，重建索引，压缩）
	分布式读取数据
特征:

	N 个节点的集群
	任何节点可作为主节点
	所有写入操作都在主节点上
	自动故障转移
	自动恢复
副本集是主从集群，和主从复制有两点区别的。

      <1>:  该集群没有特定的主数据库。
      <2>:  主从在主机宕机后所有服务将停止，而副本集在主机宕机后，集群中就会推选出一个从属数据库作为主数据库顶上，这就具备了自动故障恢复功能
MongoDB 复制集的结构以及基本概念

![image](http://docs.mongodb.org/manual/_images/replica-set-read-write-operations-primary.png)

MongoDB 复制集的架构中，主要分为两部分：主节点（Primary）和从节点（Secondary）。mongodb各个节点常见的搭配方式为：一主一从、一主多从。主节点记录在其上的所有操作oplog，从节点定期轮询主节点获取这些操作，然后对自己的数据副本执行这些操作，从而保证从节点的数据与主节点一致。

主节点：在一个复制集中只有并且必须有一个主节点，主节点点也是众多实例中唯一可以接收客户端写操作的节点，当然也可以进行读操作；

从节点：从节点会复制主节点的操作，以获取完全一致的数据集。客户端不能够直接对从节点进行写操作，但是可以进行读操作，这个需要通过复制集选项进行设置。
	
	注：MongoDB 3.0 把复制集中的成员数量从原来的12个提升到了50个，但是投票节点的数量仍然保持不变，还是7个。
投票节点：投票节点并不含有复制集中的数据集副本，且也无法升职为主节点。**投票节点的存在是为了使复制集中的节点数量为奇数**，这样保证在进行投票的时候不会出现票数相同的情况。**如果添加了一个节点后，总节点数为偶数，那么就需要相应的增加一个投票节点**。

最基本的复制集架构

![image](http://docs.mongoing.com/manual-zh/_images/replica-set-primary-with-two-secondaries.png)

一个主节点，两个从节点

最基本的复制集架构是有3个节点的形式。这样在主节点不可用以后，从节点会进行投票选出一个节点成为主节点，继续工作。如下图所示：
![image](http://docs.mongoing.com/manual-zh/_images/replica-set-trigger-election.png)

重新投票选出主节点


三个节点的复制集架构，还有另外一种形式：一个主节点，一个从节点，一个投票节点。如下图所示：
![iamge](http://docs.mongoing.com/manual-zh/_images/replica-set-primary-with-secondary-and-arbiter.png)
一个主节点，一个从节点，一个投票节点

在这种架构中，当主节点不可用时，只有从节点可以升为主节点，而投票节点是不可以成为主节点的。投票节点仅仅在选举中进行投票。如下图所示：
![image](http://docs.mongoing.com/manual-zh/_images/replica-set-w-arbiter-trigger-election.png)

从节点无法升职为主节点

**其他概念**:
从节点还有几种特殊的设置情况，不同的设置有不同的需求：

优先级为0：设置 priority:0 ，那么该结点将不能成为主节点，但是其数据仍是与主节点保持一致的,而且应用程序也可以进行读操作。这样可以在某些特殊的情况下，保证其他特定节点优先成为主节点
![image](http://docs.mongoing.com/manual-zh/_images/replica-set-three-members-geographically-distributed.png)

隐藏节点：隐藏节点与主节点的数据集一致，但是对于应用程序来说是不可见的。隐藏节点可以很好的与 复制集 中的其他节点隔离，并应对特殊的需求，比如进行报表或者数据备份。隐藏节点也应该是一个不能升职为主节点,优先级为0的节点。
![image](http://docs.mongoing.com/manual-zh/_images/replica-set-hidden-member.png)

延时节点：延时节点也将从复制集中主节点复制数据，然而延时节点中的数据集将会比复制集中主节点的数据延后。举个例子，现在是09：52，如果延时节点延后了1小时，那么延时节点的数据集中将不会有08：52之后的操作。由于延时节点的数据集是延时的，因此它可以帮助我们在人为误操作或是其他意外情况下恢复数据。举个例子，当应用升级失败，或是误操作删除了表和数据库时，我们可以通过延时节点进行数据恢复。
![image](http://docs.mongoing.com/manual-zh/_images/replica-set-delayed-member.png)

配置延时节点需要将 priority 设置为 0 ， hidden 设置为 true ，将 slaveDelay 设置为我们希望延时的秒数：	

	{"_id" : <num>,"host" : <hostname:port>,"priority" : 0,"slaveDelay" :<seconds>,"hidden" : true}
注意：

	延时节点的 slaveDelay 必须设定在oplog大小范围内。如果oplog比 slaveDelay 维护时间内的数据要短，那么延时节点将不能正常的进行复制操作。

oplog：全拼 oprations log，它保存有数据库的所有的操作的记录。在复制集中，主节点产生 oplog，然后从节点复制主节点的 oplog 进行相应的操作，这样达到保持数据集一致的要求。因此从节点的数据与主节点的数据相比是有延迟的。

副本集设置

首先关闭正在运行的MongoDB服务器,通过指定--replSet选项来启动mongoDB。--replSet 基本语法格式如下：

	mongod --port "PORT" --dbpath "YOUR_DB_DATA_PATH" --replSet "REPLICA_SET_INSTANCE_NAME"
实例：
	
	mongod --dbpath=xxx --port 27020 --replSet goldenwx/127.0.0.1:27021
建立集群首先给集群取名goldenwx，--replSet表示让服务器知道goldenwx集群下还有其他数据库，端口为27021是goldenwx集群下的另一个数据库服务器。

在Mongo客户端使用命令rs.initiate()来启动一个新的副本集。可以使用rs.conf()来查看副本集的配置,查看副本集状态使用 rs.status() 命令

拷贝安装mongodb实例，执行:

	mongod --dbpath=xxxx --port 27021 --replSet goldenwx/127.0.0.1:27020
启动日志中会有类似信息：
	replSet can't get local.system.replset config from self or any seed
提示要初始化一下“副本集”，随便连接一下主从集群中的任意一台数据库，不过一定要进入admin集合

	mongo localhost:27020/admin
	#db.runCommand({"replSetInitiate":{"_id":"goldenwx","members":[{"_id":1,"host":"127.0.0.1:27020"},{"_id":2,"host":"127.0.0.1:27021"}]}})	
	rs.initiate({"_id":"goldenwx","members":[{"_id":1,"host":"127.0.0.1:27020"},{"_id":2,"host":"127.0.0.1:27021","priority":2}]})

priority 是设置优先级的，默认优先级为1,可以是1-1000的数字.可以在初始化时增加从库，也可以使用rs.add("ip:port")增加

可以使用rs.conf()来查看副本集的配置，查看副本集状态:

	rs.status()
	use local
	db.system.replset.find()
	
可以看出端口为27020的数据库已成为主数据库服务器,27021已成为从数据库服务器

从库上执行命令db.printSlaveReplicationInfo()可以查看slave延迟情况

	source:从库的ip和端口
	syncedTo：目前的同步情况，以及最后一次同步的时间
从同步时间上可以看出，在数据库内容不变的情况下他是不同步的，数据库变动就会马上同步

mongodb默认是从主节点读写数据的，副本节点上不允许读，需要设置副本节点可以读,登陆副本节点(从库)执行:

	repset:SECONDARY> db.getMongo().setSlaveOk();
	或rs.slaveOk()
通过java访问secondary的话则会报下面的异常

	com.mongodb.MongoException: not talking to master and retries used up
解决的办法：
	
	dbFactory.getDb().slaveOk();
	或在复制集中优先读secondary，如果secondary访问不了的时候就从master中读
	dbFactory.getDb().setReadPreference(ReadPreference.secondaryPreferred());
	或只从secondary中读，如果secondary访问不了的时候就不能进行查询
	dbFactory.getDb().setReadPreference(ReadPreference.secondary());
	或在配置mongo的时候增加slave-ok="true"也支持直接从secondary中读
	<mongo:mongo id="mongo" host="${mongodb.host}" port="${mongodb.port}">
	        <mongo:options slave-ok="true"/> 
	</mongo:mongo>

副本集数据复制功能测试:登陆主库新建 

当副本节点增多，主节点的复制压力加大时，mongodb设计了仲裁服务器,仲裁节点不存储数据，只是负责故障转移的群体投票，这样就少了数据复制的压力.

**开启"仲裁服务器"（仲裁只参与投票选举）：**

拷贝安装mongodb实例,cmd进入bin目录执行：
	
	mongod --dbpath=xxx --port 27022 --replSet goldenwx/127.0.0.1:27020
新开cmd进入mongodb的bin目录执行：

	mongo 127.0.0.1:27020/admin
	rs.addArb("127.0.0.1:27022")
如执行出错，是由于没有初始化副本集，执行：	
	
	replSetConf={"_id":"goldenwx","members":[{"_id":1,"host":"127.0.0.1:27020"},{"_id":2,"host":"127.0.0.1:27021"},{"_id":3,"host":"127.0.0.1:27022","arbiterOnly": true}]}
	rs.initiate(replSetConf)
	如已初始化可以使用rs.reconfig(cfg)或:
		cfg = rs.conf()
		cfg.members[2].priority = 0
		cfg.members[2].hidden = true
		cfg.members[2].slaveDelay = 3600
		rs.reconfig(cfg)
	当更新修改复制集配置的时候，我们通过members的数组下标 （array index）来指定需要修改的节点。数组下标从0开始。不要将数组下标与members中的_id字段混淆了。
执行：

	rs.status()
查看集群中的服务器状态，可以看到主(27020)、从(27021)、仲裁(27022)
参数说明：

	health：1    1表明状态是正常，0表明异常
	state:1       1表明是primary，2表明是slave 
	stateStr：RECOVERING：正在同步数据，不适用读
			  SECONDARY：已经成功同步，可以正常使用。		
			  PRIMARY：主节点
			  STARTUP：刚加入到复制集中，配置还未加载
			  STARTUP2：配置已加载完，初始化状态  
			    
			  ARBITER: 仲裁者  
			  DOWN：节点不可到达  
			  UNKNOWN：未获取其他节点状态而不知是什么状态，一般发生在只有两个成员的架构，脑裂  
			  REMOVED：移除复制集  
			  ROLLBACK：数据回滚，在回滚结束时，转移到RECOVERING或SECONDARY状态  
			  FATAL：出错。查看日志grep “replSet FATAL”找出错原因，重新做同步  
			  			    
**选举触发条件**选举不是什么时刻都会被触发的，有以下情况时触发:

	初始化一个副本集时。
	副本集和主节点断开连接，可能是网络问题。
	主节点挂掉。
选举还有个前提条件，参与选举的节点数量必须大于副本集总节点数量的一半，如果已经小于一半了所有节点保持只读状态。
日志将会出现：
	
	can't see a majority of the set, relinquishing primary

复制集中的节点默认都是参加投票的，不参与投票的节点的 votes 设置是 0 

如果开启了 authorization ，投票节点通过证书的形式与复制集中其他节点进行认证。MongoDB的身份认证过程是加密的。MongoDB的认证交互是通过密码进行的。

复制集对投票节点的认证使用的是 keyfiles

投票节点与其他复制集节点的交流仅有：选举过程中的投票，心跳检测和配置数据。这些交互都是不加密的，与其他MongoDB部件一样，投票节点也需运行在安全可信的网络环境中

**主节点挂掉时人为干预**,可以通过replSetStepDown命令下架主节点。这个命令可以登录主节点使用：

	db.adminCommand({replSetStepDown : 1})
如果杀不掉可以使用强制开关

	db.adminCommand({replSetStepDown : 1, force : true})
或者使用 rs.stepDown(120)也可以达到同样的效果，中间的数字指不能在停止服务这段时间成为主节点，单位为秒。

设置一个从节点有比主节点有更高的优先级。先查看当前集群中优先级，通过rs.conf()命令，默认优先级为1是不显示的

设置，让id为1的主机可以优先成为主节点

	cfg = rs.conf()
	cfg.members[0].priority = 1
	cfg.members[1].priority = 2
	cfg.members[2].priority = 1
	rs.reconfig(cfg)

然后再执行rs.conf()命令查看优先级已经设置成功，主节点选举也会触发

如果不想让一个配置比较差（专门用来备份的从节点）的从节点成为主节点可以：

使用rs.freeze(120)冻结指定的秒数不能选举成为主节点。
设置节点为Non-Voting类型


故障自动恢复测试：

结束27020端口的主数据库进程，27021端口的从库即可顶上，可以再次使用rs.status()看下集群中服务器的状态

mongodb不只有主节点、副本节点、仲裁节点，还有Secondary-Only、Hidden、Delayed、Non-Voting。

Secondary-Only:不能成为primary节点，只能作为secondary副本节点，防止一些性能不高的节点成为主节点。

Hidden:这类节点是不能够被客户端制定IP引用，也不能被设置为主节点，但是可以投票，一般用于备份数据。

Delayed：可以指定一个时间延迟从primary节点同步数据。主要用于备份数据，如果实时同步，误删除数据马上同步到从节点，恢复又恢复不了。

Non-Voting：没有选举权的secondary节点，纯粹的备份数据节点。


**副本集添加成员**

MongoDB中你只能通过主节点将Mongo服务添加到副本集中， 判断当前运行的Mongo服务是否为主节点可以使用命令
	
	db.isMaster() 
	db.$cmd.findOne({ismaster:1})
在启动时也可只指定集合名称不指定集群ip端口,添加副本集的成员，进入主节点Mongo客户端，并使用rs.add()方法来添加副本集的成员。 命令基本语法格式如下：
 	
	rs.add(HOST_NAME:PORT)
实例

假设你已经启动了一个名为Thinkpad-PC，端口号为27018的Mongo服务。 在客户端命令窗口使用rs.add() 命令将其添加到副本集中，命令如下所示：

	rs.add("Thinkpad-PC:27018")

处于种种原因想删除一个节点时使用命令rs.remove("IP：端口")即可移除该节点


**心跳** 

整个集群需要保持一定的通信才能知道哪些节点活着哪些节点挂掉。mongodb节点会向副本集中的其他节点每两秒就会发送一次pings包，如果其他节点在10秒钟之内没有返回就标示为不能访问。每个节点内部都会维护一个状态映射表，表明当前每个节点是什么角色、日志时间戳等关键信息。如果是主节点，除了维护映射表外还需要检查自己能否和集群中内大部分节点通讯，如果不能则把自己降级为secondary只读节点。

**同步**

副本集同步分为初始化同步和keep复制。初始化同步指全量从主节点同步数据，如果主节点数据量比较大同步时间会比较长。而keep复制指初始化同步过后，节点之间的实时同步一般是增量同步。初始化同步不只是在第一次才会被处罚，有以下两种情况会触发：

secondary第一次加入，这个是肯定的。

secondary落后的数据量超过了oplog的大小，这样也会被全量复制。

oplog的大小:oplog保存了数据的操作记录，secondary复制oplog并把里面的操作在secondary执行一遍。但是oplog也是mongodb的一个集合，保存在local.oplog.rs里，但是这个oplog是一个capped collection也就是固定大小的集合，新数据加入超过集合的大小会覆盖。所以这里需要注意，跨IDC的复制要设置合适的oplogSize，避免在生产环境经常产生全量复制。oplogSize 可以通过–oplogSize设置大小，对于linux 和windows 64位，oplog size默认为剩余磁盘空间的5%。

	use local
	db.oplog.rs.find()
	{ "ts" : Timestamp(1440055397, 1), "h" : NumberLong("7474393716778638521"), "v" : 2, "op" : "n", "ns" : "", "o" : { "msg" : "Reconfig set", "version" : 3 } }
	字段说明:
		ts: 某个操作的时间戳
		op: 操作类型，如下：
			i: insert
			d: delete
			u: update
		ns: 命名空间，也就是操作的collection name
		o: document的内容


同步也并非只能从主节点同步，假设集群中3个节点，节点1是主节点在IDC1，节点2、节点3在IDC2，初始化节点2、节点3会从节点1同步数据。后面节点2、节点3会使用就近原则从当前IDC的副本集中进行复制，只要有一个节点从IDC1的节点1复制数据。

设置同步还要注意以下几点：

secondary不会从delayed和hidden成员上复制数据。

只要是需要同步，两个成员的buildindexes必须要相同无论是否是true和false。buildindexes主要用来设置是否这个节点的数据用于查询，默认为true。

如果同步操作30秒都没有反应，则会重新选择一个节点进行同步。

**复制集认证**

登陆主库执行：

	添加系统管理员
	db.createUser({user:"superadmin",pwd:"golden",roles:[{role:"root",db:"admin"}]})
	添加数据库管理员
	db.createUser({user:"root",pwd:"golden",roles:[{role:"dbAdminAnyDatabase",db:"admin"},{role:"readWrite",db:"admin"}]})
	用户认证
	db.auth("root","golden")

生成密码文件：

	openssl rand -base64 741 >mongodb-keyfile
linux系统赋予权限（300或600）

	chmod 300 mongodb-keyfile

在mongodb各节点的配置文件中增加认证参数：

	auth=true
	keyFile=..\conf\mongodb-keyfile
然后逐一启动副本，只有经过密码文件认证的节点才能加入，数据库操作也需要密码认证提高了安全性

连接：

	mongo localhost:27017/admin -u root -p golden --authenticationDatabase admin


**配置复制集标签设置**

标签设定让我们可以为 replica set 定制 write concern 和 read preferences 。MongoDB将标签存储在复制集配置对象中，可以通过 rs.conf() 查看返回信息中的 members[n].tags 。
 

安全写级别和读优先级之间的差异。

自定义读优先级和安全写级别使用标签方式是不同的。

当选择一个节点进行读取的时候，读优先级考虑的是标签的值。
安全写级别不考虑标签的值，而是考虑标签值是否唯一。
举个栗子，一个读操作使用如下的条件：

	{ "disk": "ssd", "use": "reporting" }
为了完成这样的读操作，该节点的标签必须包含这两个标签。下列任意标签组合都可以实现：

	{ "disk": "ssd", "use": "reporting" }
	{ "disk": "ssd", "use": "reporting", "rack": "a" }
	{ "disk": "ssd", "use": "reporting", "rack": "d" }
	{ "disk": "ssd", "use": "reporting", "mem": "r"}
这样的标签将*不*会满足之前的查询：

	{ "disk": "ssd" }
	{ "use": "reporting" }
	{ "disk": "ssd", "use": "production" }
	{ "disk": "ssd", "use": "production", "rack": "k" }
	{ "disk": "spinning", "use": "reporting", "mem": "32" }
为复制集新增标签

现在的复制集配置如下：
	
	{
	    "_id" : "rs0",
	    "version" : 1,
	    "members" : [
	             {
	                     "_id" : 0,
	                     "host" : "mongodb0.example.net:27017"
	             },
	             {
	                     "_id" : 1,
	                     "host" : "mongodb1.example.net:27017"
	             },
	             {
	                     "_id" : 2,
	                     "host" : "mongodb2.example.net:27017"
	             }
	     ]
	}
我们可以在 mongo 窗口中使用如下的命令来为复制集成员添加标签：
	
	conf = rs.conf()
	conf.members[0].tags = { "dc": "east", "use": "production"  }
	conf.members[1].tags = { "dc": "east", "use": "reporting"  }
	conf.members[2].tags = { "use": "production"  }
	rs.reconfig(conf)
在执行完设置命令后， rs.conf() 的输出如下：
	
	{
	    "_id" : "rs0",
	    "version" : 2,
	    "members" : [
	             {
	                     "_id" : 0,
	                     "host" : "mongodb0.example.net:27017",
	                     "tags" : {
	                             "dc": "east",
	                             "use": "production"
	                     }
	             },
	             {
	                     "_id" : 1,
	                     "host" : "mongodb1.example.net:27017",
	                     "tags" : {
	                             "dc": "east",
	                             "use": "reporting"
	                     }
	             },
	             {
	                     "_id" : 2,
	                     "host" : "mongodb2.example.net:27017",
	                     "tags" : {
	                             "use": "production"
	                     }
	             }
	     ]
	}
重要
所有标签的值必须是字符串形式。
自定义多数据中心的安全写级别

假设我们的五个节点位于两个数据中心中：

数据中心 VA` 标签为 ``dc.va
数据中心 GTO` 标签为 ``dc.gto
通过在 mongo 窗口中使用如下命令可来自定义该两个数据中心的安全写级别：

将复制集配置赋予到参数 conf 中：
	
	conf = rs.conf()
根据节点的位置为其设置标签：

	conf.members[0].tags = { "dc.va": "rack1"}
	conf.members[1].tags = { "dc.va": "rack2"}
	conf.members[2].tags = { "dc.gto": "rack1"}
	conf.members[3].tags = { "dc.gto": "rack2"}
	conf.members[4].tags = { "dc.va": "rack1"}
	rs.reconfig(conf)
建立自定义的 getLastErrorModes 设置来确保写操作能至少在每个数据中心的一台节点上完成：
conf.settings = { getLastErrorModes: { MultipleDC : { "dc.va": 1, "dc.gto": 1}}
通过 conf 变量来更新复制集配置：
rs.reconfig(conf)
为了让写操作至少在每个数据中心的一个节点上易用了，我们使用 MultipleDC 安全写模式：

db.users.insert( { id: "xyz", status: "A" }, { writeConcern: { w: "MultipleDC" } } )
此外，如果我们希望每次写操作至少在数据中心的2各节点中应用，可以在 mongo 窗口中进行如下设置：

创建一个有用复制集配置的变量 conf：
conf = rs.conf()
定义 getLastErrorModes 的值，为需要 dc.va 和 dc.gto 中匹配2个不同指:
conf.settings = { getLastErrorModes: { MultipleDC : { "dc.va": 2, "dc.gto": 2}}
通过 conf 变量来更新复制集配置：
rs.reconfig(conf)
现在，下面的写操作将会在2个数据中心中至少有2个节点都应用后才会返回写完成：

在 2.6 版更改: write operations 在写操作的应用是全新的。在之前版本中是需要使用 getLastError 命令来指定安全写级别。

db.users.insert( { id: "xyz", status: "A" }, { writeConcern: { w: "MultipleDC" } } )
通过标签来进行读写操作的功能性隔离

给复制集节点以如下的标签：

数据中心，
物理存储类型
存储（如硬盘）类型
每个复制集节点会是如下的标签设置：[1]

	{"dc.va": "rack1", disk:"ssd", ssd: "installed" }
	{"dc.va": "rack2", disk:"raid"}
	{"dc.gto": "rack1", disk:"ssd", ssd: "installed" }
	{"dc.gto": "rack2", disk:"raid"}
	{"dc.va": "rack1", disk:"ssd", ssd: "installed" }
将读操作发送至拥有ssd硬盘的节点，可以用如下复制集标签设置：

{ disk: "ssd" }
为了创建可用的多个安全写模式，我们需要不同的 getLastErrorModes 配置。可以参考如下配置：

创建一个有用复制集配置的变量 conf：
conf = rs.conf()
配置如下的有2个模式的 getLastErrorModes ：
conf.settings = {
                 "getLastErrorModes" : {
                         "ssd" : {
                                    "ssd" : 1
                         },
                         "MultipleDC" : {
                                 "dc.va" : 1,
                                "dc.gto" : 1
                         }
                 }
               }
通过 conf 变量来更新复制集配置：
rs.reconfig(conf)
我们可以通过指定 MultipleDC 模式，来保证写操作在每个数据中心中都应用了。

在 2.6 版更改: write operations 在写操作的应用是全新的。在之前版本中是需要使用 getLastError 命令来指定安全写级别。

db.users.insert( { id: "xyz", status: "A" }, { writeConcern: { w: "MultipleDC" } } )
又或者我们可以通过指定 ssd 模式来保证写操作至少写到了一个有SSD的实例上。

[1]	
由于读优先级和安全写级别使用标签的方式是不同的，larger deployments may have some redundancy.



	