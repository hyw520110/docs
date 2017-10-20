 2015.3.3 在经历了改版本号和11个rc版本之后，期待已久的Mongodb3.0.0终于发布，举群欢腾，下面我们就来看一下这个跳票版本主要有哪些改进。

一、插件式存储引擎API
      
MongoDB向MySQL看齐，开发了插件式存储引擎API，为第三方的存储引擎厂商加入Mongodb提供了方便。已经支持和即将支持的一些存储引擎：

MMAP v1 默认存储引擎

WiredTiger

RocksDB

TokuFT

FusionIO（裸设备）

二、WiredTiger存储引擎

毫无疑问，WiredTiger存储引擎的引进是此版本最大的亮点。MongoDB公司已然感受到Tokumx深深的恶意和广大使用者对mongodb耗费巨大内存和磁盘的深恶痛绝，所以MongoDB拿（为）出（了）了（不）最（跳）大（票）的（更）诚（久）意，直接收购了WiredTiger，做了一个土豪应该做的事情。下面看一下这个存储引擎都给MongoDB的使用者带来了哪些福音。


文档锁

WiredTiger通过多版本控制（MVCC）实现了文档锁，再也不用忍受库锁带来的并发性问题。这将大大提高诸如比价，打车等全update类型应用的可用性。这是一个现代数据库应该做的，不用说谢谢。

 
压缩

当，监控报表上几十台机器磁盘报警的时候，当，删了表不释放空间的时候，当，挨个机器重新同步释放碎片的时候，允许我哭一会。现在好了，wiredTiger压缩一切，压缩journal，压缩表，压缩索引，且都是单独文件存储，想删就删，删了就释放，浑身上下哪哪都不疼了。
WiredTiger支持snappy（默认）、zlib压缩算法和None高端不压缩算法。snappy根据测试可以减少80%的磁盘使用。虽然可能会提高一些cpu，但是相比压缩带来的好处，天空飘来五个字儿.....


内存可配置


通过wiredTiger.engineConfig.cacheSizeGB参数可以配置运行时MongoDB内存使用大小，默认为物理内存的一半。老板再也不说MongoDB是内存小恶魔了。
wiredtiger还有其他一些参数配置，具体详见：http://docs.mongodb.org/v3.0/reference/program/mongod/#cli-wiredtiger-options


三、MMAP v1存储引擎

MongoDB给之前内存映射的存储也起了个名字，那就是“内存映射第一版”，MMAPv1依旧是MongoDB的默认存储引擎。此版本最大的改进就是锁力度变成集合锁，也就是表锁。但最大的问题是表空间还是按照库名来的，所以删除表依旧不会释放空间。为了解决空间重用问题和碎片问题，mongodb这次彻底的将Power of 2 Sized Allocations扶正，也就是之前说的usePowerOf2Size，将padding factor废弃。对于增删改频繁的业务，使用Power of 2 Sized Allocations，以提升效率。对于纯写入的应用，使用no padding，以节省空间。

四、复制集改进


最大支持50个数据节点，但是投票节点仅有7个。相配套的，getlasterror中的 w: “majority” 项也仅代表投票节点的大多数。

修改rs.stepDown()机制。在Primary执行stepDown：

①、尝试kill掉长时操作，如建索引，map reduce。

②、判断主从延迟，从库延迟不能超过10s。10s可配置，使用secondaryCatchUpPeriodSecs参数。         


五、sharding改进


添加sh.removeTagRange()函数

为moveChunk和cleanupOrphaned 命令添加writeConcern选项。

废弃releaseConnectionsAfterResponse参数，mongodb在返回之后就会立即释放链接回连接池，这大大降低连接数的使用。


六、查询和索引

修改explain函数，现在explain可以支持count，find，group，aggregate，update，remove等操作。显示结果更全面更精细化。使用方法也有修改

        db.collection.explain().<method(...)>

后台索引建立过程中，不能进行删库删表删索引操作。

使用 createIndexes命令可以同时建立多个索引，并且只扫描一遍数据，提升了建索引的效率。

废弃dropDups参数，以后不能通过这个删除重复数据了。




以上是一些主要的改进，还有很多小地方比如废弃了closeAllDatabase命令，废弃了addUser()函数等，不再一一介绍，更多详见[http://docs.mongodb.org/v3.0/release-notes/3.0/](http://docs.mongodb.org/v3.0/release-notes/3.0/)
      