#分片

在mongodb里面存在另一种集群，就是分片技术，跟表分区类似，当数据量达到T级别的时候，我们的磁盘，内存就吃不消了,分片技术,可以满足MongoDB数据量大量增长的需求。

当MongoDB存储海量的数据时，一台机器可能不足以存储数据，也可能不足以提供可接受的读写吞吐量。这时，我们就可以通过在多台机器上分割数据，使得数据库系统能存储和处理更多的数据。

为什么使用分片

- 复制所有的写入操作到主节点
- 延迟的敏感数据会在主节点查询
- 单个副本集限制在12个节点
- 当请求量巨大时会出现内存不足。
- 本地磁盘不足
- 垂直扩展价格昂贵

分片集群结构分布：

![](http://www.runoob.com/wp-content/uploads/2013/12/sharding.png)

上图中主要有如下所述三个主要组件：

- Shard:用于存储实际的数据块，实际生产环境中一个shard server角色可由几台机器组个一个relica set承担，防止主机单点故障
- Config Server:mongod实例，存储了整个 ClusterMetadata，其中包括 chunk信息。
- Query Routers:前端路由，客户端由此接入，且让整个集群看上去像单一数据库，前端应用可以透明使用。


mongodb采用将集合进行拆分，然后将拆分的数据均摊到几个片上的一种解决方案。

				    mongod

	客户端-->mongos   mongod
		   	 |		 
		  config	mongod
mongos： 首先我们要了解”片键“的概念，也就是说拆分集合的依据是什么？按照什么键值进行拆分集合....，mongos就是一个路由服务器，它会根据管理员设置的“片键”将数据分摊到自己管理的mongod集群，数据和片的对应关系以及相应的配置信息保存在"config服务器"上。

mongod:   一个普通的数据库实例，如果不分片的话，我们会直接连上mongod。

二： 实战

分片结构端口分布如下：

	Shard Server 1：27020
	Shard Server 2：27021
	Shard Server 3：27022
	Shard Server 4：27023
	Config Server ：27100
	Route Process：40000

首先我们准备4个mongodb程序，可以均摊在不同机器或一台服务器的不同分区或文件夹下

	mkdir -p /www/mongoDB/shard/s0
	mkdir -p /www/mongoDB/shard/s1
	mkdir -p /www/mongoDB/shard/s2
	mkdir -p /www/mongoDB/shard/s3
	mkdir -p /www/mongoDB/shard/log
	/usr/local/mongoDB/bin/mongod --port 27020 --dbpath=/www/mongoDB/shard/s0 --logpath=/www/mongoDB/shard/log/s0.log --logappend --fork
	...
	/usr/local/mongoDB/bin/mongod --port 27023 --dbpath=/www/mongoDB/shard/s3 --logpath=/www/mongoDB/shard/log/s3.log --logappend --fork


开启config服务器
	
	mkdir -p /www/mongoDB/shard/config
	/usr/local/mongoDB/bin/mongod --port 27100 --dbpath=/www/mongoDB/shard/config --logpath=/www/mongoDB/shard/log/config.log --logappend --fork
可以像启动普通mongodb服务一样启动，不需要添加—shardsvr和configsvr参数。因为这两个参数的作用就是改变启动端口的，自行指定端口就可以。

启动Route Process

	/usr/local/mongoDB/bin/mongos --port 40000 --configdb localhost:27100 --fork --logpath=/www/mongoDB/shard/log/route.log --chunkSize 500


这里要注意的是我们开启的是mongos，不是mongod，同时指定下config服务器,chunkSize这一项是用来指定chunk的大小的，单位是MB，默认大小为200MB.
	
配置Sharding

使用MongoDB Shell登录到mongos，添加Shard节点

	/usr/local/mongoDB/bin/mongo admin --port 40000
	db.runCommand({ addshard:"localhost:27020" })
	...
	db.runCommand({ addshard:"localhost:27029" })

片已经集群了，但是mongos不知道该如何切分数据，也就是我们先前所说的片键，在mongodb中设置片键要做两步

- 开启数据库分片功能，命令很简单 enablesharding(),这里我就开启test数据库。
- 指定集合中分片的片键，这里我就指定为person.name字段。

		db.runCommand({ enablesharding:"test" }) #设置分片存储的数据库
		db.runCommand({ shardcollection: "test.log", key: { id:1,time:1}})

程序代码内无需太大更改，直接按照连接普通的mongo数据库那样，将数据库连接接入接口40000


查看效果

分片操作全部结束，接下来我们通过mongos向mongodb插入10w记录，然后通过printShardingStatus命令查看mongodb的数据分片情况。	
		
	mongo 127.0.0.1:3333/admin
	use test
	for(var i=0;i<100000;i++){
		db.person.insert({"name":"jack"+i,"age":i})
	}			
	
	db.printShardingStatus()
这里主要看三点信息：

  ① shards：     我们清楚的看到已经别分为两个片了，shard0000和shard0001。

  ② databases:  这里有个partitioned字段表示是否分区，这里清楚的看到test已经分区。

  ③ chunks：     这个很有意思，我们发现集合被砍成四段：

    无穷小 —— jack0，jack0 ——jack234813，jack234813——jack9999，jack9999——无穷大。
  
    分区情况为：3：1，从后面的 on shardXXXX也能看得出。
