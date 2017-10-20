#概念特点

##复制集的概念

MongoDB复制是将数据同步在多个服务器的过程。
复制提供了数据的冗余备份，并在多个服务器上存储数据副本，提高了数据的可用性， 并可以保证数据的安全性。
复制还允许您从硬件故障和服务中断中恢复数据。

复制集（也叫副本集 Replica Set）就是有自动故障恢复功能的主从集群。
传统的主从结构和复制集最为明显的区别是复制集没有固定的“主节点”：整个节点会选举出一个“主节点”，当其不能工作时则变更到其它节点。复制集总会有一个活跃节点（primary）和一个或多个备份的节点（secondary）
 
对于MongoDB在数据容灾上，推荐的模式是使用副本集模式，**在MongoDB3.0版本以上支持的副本数已经超过50个。**

##用途

- 保障数据的安全性
- 数据高可用性 (24*7)
- 灾难恢复
- 无需停机维护（如备份，重建索引，压缩）
- 分布式读取数据

##特征：
- N 个节点的集群
- 任何节点可作为主节点
- 所有写入操作都在主节点上
- 自动故障转移
- 自动恢复

##复制集的特点

复制集的特点主要有以下四点：

- 主是唯一的，但不是固定的。
- 由大多数据原则保证数据的一致性
- 从库无法写入（默认情况下，不使用驱动连接时，也是不能查询的）
- 相对于传统的主从结构，复制集可以自动容灾。

##复制集成员分类

任何时间活跃节点（也即主节点）只有一个，其它都为备份节点，指定的活跃节点可随时间而变化。有几种不同类型的节点存在于副本集中：
 
- Standard（标准） 这种是常规节点，它存储一份完整的数据副本，参与投票选举，有可能成为活跃节点
- Passive（被动） 存储完整的数据副本，参与投票，不能成为活跃节点。
- Arbiter（投票）仲裁节点只参与投票，不接收复制的数据，也不能成为活跃节点。
 
每个参与节点（非仲裁者）有个优先权，优先权（priority）为0则是被动的，不能成为活跃节点，优先权不为0的，按照由大到小选出活跃节点，优先值一样的则看谁的数据比较新。
 
###按是否存放数据区分：

- 数据节点：存放数据（实体物理文件*.ns *.0等）的节点，包括主节点和从节点

- 投票节点：不存入数据，仅做选举和复制集节点
 
###按功能区分：

- 主节点：提供读写服务的活跃节点
- 从节点：提供读服务的节点
	- 延时节点：延时复制节点（priority=0hidden=true slaveDelay=xx）
	- 隐藏节点：对应用程序不可见（priority=0 hidden=true）
	- “投票”节点：具有投票权的节点，不是arbiter（priority=0）的节点
- 投票节点：Arbiter节点，无数据，仅做选举和充当复制集节点，也称为选举节点。 

#安装部署

部署架构

模拟有三台服务器

10.1.5.123:28001 主节点

10.1.5.123:28002 从节点

10.1.5.123:28003 选举节点
 
复制集架构：一主，一从，一选举节点

##下载安装

下载地址：https://www.mongodb.org/downloads


##部署步骤

###创建目录及用户

	mkdir conf data logs
	cd data
	mkdir 28001 28002 28003

	groupadd mongod
	useradd -g mongod mongod
 
###创建配置文件

	vi /usr/local/mongodb/conf/28001.conf
	
	net:
	 port: 28001
	 bindIp: 192.168.1.34
	systemLog:
	 destination: file  
	 path: "/usr/local/mongodb-linux-x86_64-rhel70-3.4.0/logs/28001.log"
	 logAppend: true
	storage:
	 dbPath: "/usr/local/mongodb-linux-x86_64-rhel70-3.4.0/data/28001/"
	processManagement:
	 fork: true
	 pidFilePath: "/usr/local/mongodb-linux-x86_64-rhel70-3.4.0/data/28001/28001.pid"
	replication:
	 oplogSizeMB: 1024
	 replSetName: MongoReplSet
	#security:
	# authorization: enabled
 	
	cp 28001.conf 28002.conf
	cp 28001.conf 28003.conf
	sed -i "s/28001/28002/g" 28002.conf
	sed -i "s/28001/28003/g" 28003.conf
 
###启动mongo复制集
	
	cd ../bin
	chmod +x *
	./mongod -f ../conf/28001.conf 
	./mongod -f ../conf/28002.conf
	./mongod -f ../conf/28003.conf
 
###初始化复制集

	./mongo 192.168.1.34:28001/admin
	
	config = {
		"_id":"MongoReplSet",
		members:[
		{"_id":0,host:"192.168.1.34:28001"},
		{"_id":1,host:"192.168.1.34:28002"},
		{"_id":2,host:"192.168.1.34:28003"}]
	}

###查看复制集成员

	config.members

###设置arbiter选举节点

	config.members[2]

	config.members[2] ={"_id":2,"host":"192.168.1.34:28003",arbiterOnly:true}
 
###初始化复制集
 
	rs.initiate(config)
 
###查看复制集状态

	rs.status()
###查看当前节点是否主节点
	
	db.isMaster()
###添加成员
 
 	rs.add(HOST_NAME:PORT)
###移除成员

	rs.remove(HOST_NAME:PORT)
###设置读写方式

	#Primary                   #从主的读，默认  
	#primaryPreferred      #基本上从主的读，主不可用时，从从的读  
	#secondary                #从从的读  
	#secondaryPreferred   #基本上从从的读，从不可用时，从主的读  
	#nearest                    #从网络延迟最小的读  
	db.getMongo().setReadPref('secondaryPreferred')  
 
###验证复制集同步

####登录主节点进行测试：
	
	./mongo 192.168.1.34:28001/admin
	db
	use test
	show collections
	db.person.insert({"name":"jack"})
	show collections

####登录从secondary节点进行测试(查看数据库)：

	./mongo 192.168.1.34:28002/admin
	show dbs

在从节点进行查询时会报错，因为在默认情况下，不通过驱动连接mongodb从节点数据库时，如果不开始slaveOK=true，是无法读取从节点数据的。

	rs.slaveOk(true)
	show dbs
	use test
	show collections
	db.person.find()
 
####登录从arbite节点进行测试：

	./mongo 192.168.1.34:28003/admin
然后登录arbite节点，会发现数据没有同步，因为arbite不参与数据库的同步，即不存储数据
但local数据库大小已经改变了，因为local库存储命名空间（local.ns文件）的内容。
 
	rs.slaveOk(true)
	show dbs

 
###模拟主-从故障切换
	
	ps -ef|grep 28001|grep -v grep| awk '{print $2}'|xargs kill -9
	ps -ef|grep mongo

登录28002，发现已切换主节点：
 
	./mongo 192.168.1.34:28002/admin
启动28001，发现已切换成从节点：

	./mongod -f ../conf/28001.conf 




