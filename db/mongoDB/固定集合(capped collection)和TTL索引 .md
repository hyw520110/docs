##固定集合(capped collection)和TTL索引 

Mongodb的数据增长是个大问题，尤其是存放大数据，数据不停的增长，导致空间不足，性能下降。Mongodb以库为单位分配空间，每个库包含一系列数据文件，删除表并不能回收空间，删除库才可以。最近一直被空间问题困扰，线上库已经快到1T，空间不足，repair数据时间太长，delete容易锁死库，不好控制。跟研发介绍了两种控制数据的办法，固定集合和TTL索引，供大家借鉴。

固定集合（capped collection），是固定大小的集合，创建的时候确定大小，一经确定，不可更改。插入、检索和删除都按照写入顺序。capped collection类似一个循环缓冲，如果集合已经达到分配空间的大小，那么新插入的数据就会覆盖最老的数据来保证集合不增长。
固定集合有以下几个特性：

固定集合能够确保数据一定是按照插入的顺序排列，不会更改。所以如果要按插入顺序排序是不需要索引的，这也能提高插入性能。

固定集合能够保证插入顺序跟磁盘上的存储顺序是一样的。为了这点，固定集合的更新操作不允许超过原文档大小，以确保不改变存储位置。

固定集合自动覆盖老数据，不用显示的删除。


**使用推荐和限制：**

固定集合不支持sharding结构

更新时不能增加原始文档的大小，如果增加就会更新失败

不能删除固定集合中的数据，如果要remove所有的数据，要使用emptycapped命令。

使用自然顺序（$natural）查询新插入的数据更快，跟tail -f file 一个效果。

使用方法：

创建：
	
	db.createCollection("mycoll", {capped:true, size:100000})

 查询：
	
	db.cappedCollection.find().sort( { $natural: -1 } )

确定集合是不是固定集合：

	db.collection.isCapped()

**TTL索引：**

TTL代表"time to live"，TTL是一种特殊的索引，可以将集合中过期的数据删除。使用expireAfterSeconds 选项创建索引即可。

推荐和限制：

使用usePowerOf2Sizes标识可以更有效的防止磁盘碎片的产生。 

	db.runCommand( {collMod: "products", usePowerOf2Sizes : true })
	db.runCommand( {collMod: "products", usePowerOf2Sizes : false })

TTL索引必须建立在date类型的字段上，如果不是date类型将不会被删除。
TTL索引不能建立在_id字段上
TTL索引不能是联合索引，否则会报错，不让建
如果date类型中包含一个数组，比如time:['date1','date2']，那么TTL会按照一个最早的进行过滤。
TTL不能建立在固定集合上（capped collection）,因为固定集合不能删除数据。 

	db.log.events.ensureIndex( { "createDate": 1 }, { expireAfterSeconds: 3600 } )