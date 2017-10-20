Mongodb写入安全机制--GetLastError

一、简介

很多人抱怨mongodb是内存数据库，也没有事务，会不安全，其实这都是对Mongodb的误解，Mongodb有完整的

redolog，binlog和持久化机制，不必太担心数据丢失问题。

journal是Mongodb中的redo log，而Oplog则是负责复制的binlog（对应Mysql）。

在google.groupuser上，mongo的开发者有一段这样的解释： 


    #########
    By default:
    Collection data (including oplog) is fsynced to disk every 60 seconds.
    Write operations are fsynced to journal file every 100 milliseconds.
    Note, oplog is available right away in memory for slaves to read. Oplog is a capped collection
    so a new oplog is never created, old data just rolls off.
    GetLastError with params:
    (no params) = return after data updated in memory.
    fsync: true:
    with --journal = wait for next fsync to journal file (up to 100 milliseconds);
    without --journal = force fsync of collection data to disk then return.
    w: 2 = wait for data to be updated in memory on at least two replicas.
    ########

我们可以看到:

1、如果打开journal，那么即使断电也只会丢失100ms的数据，这对大多数应用来说都可以容忍了。从1.9.2+，mongodb都会默认打开journal功能，以确保数据安全。而且journal的刷新时间是可以改变的，2-300ms的范围,使用 --journalCommitInterval 命令,了解更多:

	http://docs.mongodb.org/manual/core/journaling/#journaling-internals

2、Oplog和数据刷新到磁盘的时间是60s，对于复制来说，不用等到oplog刷新磁盘，在内存中就可以直接复制到Sencondary节点。GetLastError Command
	
	getLastError 是Mongodb的一个命令，从名字上看，它好像是取得最后一个error，但其实它是Mongodb的一种客户端阻塞方式。用这个命令来获得写操作是否成功的信息。
	getlastError有几个参数:j，w，fsync。在大多数的语言驱动中，这个命令是被包装成writeConcern类

 
二、什么时候使用这个命令：


1、Mongodb的写操作默认是没有任何返回值的，这减少了写操作的等待时间，也就是说，不管有没有写

入到磁盘或者有没有遇到错误，它都不会报错。但一般我们是不放心这么做的，这时候就调用getlastError命令，得到返回值。以java为例，举个例子：当我们为字段建立了一个唯一索引，针对这个字段我们插入两条相同的数据，不设置WriterConcern或者设置WriterConcern.NORMAL模式，这时候即便抛出异常，也不会得到任何错误。insert()函数在java中的返回值是WriteResult类， 
	
	WriteResult( CommandResult o , WriteConcern concern ){
        _lastErrorResult = o;
        _lastConcern = concern;
        _lazy = false;
        _port = null;
        _db = null;
    }
这个类实际上包装了getlastError的返回值，但是这时候WriteResult的_lastErrorResult属性实际上是空的。因为dup key错误是server error,只有在WriterConcern.SAFE或更高级别的模式下，才会得到server error。

 2、在多线程模式下读写Mongodb的时候，如果这些读写操作是有逻辑顺序的，那么这时候也有必要调用
getlasterror命令，用以确保上个操作执行完下个操作才能执行，因为两次执行的连接有可能是不同的。在大多数情况下，我们都会使用连接池去连接mongodb，所以这是需要注意的。举个例子：我们之前遇到这个异常"The connection may have been used since this write, cannot obtain a result"，异常原因有两个，连接池数量太小，竞争太激烈，没有设置writerConcern.SAFE。祥见

：

	https://groups.google.com/forum/?fromgroups=#!topic/mongodb-user/xzw0Cb831VY
	在java等语言中，是不需要显示调用这个命令的，只需要设置WriterConcern即可。 

三、getlastError最佳实践

1、如果没有特殊要求，最低级别也要使用WriterConcern.SAFE，即w=1。

2、对于不重要的数据，比如log日志，可以使用WriterConcern.NONE或者WriterConcern.NORMAL，即w=-1或者w=0,省去等待网络的时间。

3、对大量的不连续的数据写入，如果每次写入都调用getLastError会降低性能，因为等待网络的时间太长，这种情况下，可以每过N次调用一下getLastError。但是在Shard结构上，这种方式不一定确保之前的写入是成功的。

4、对连续的批量写入（batchs of write），要在批量写入结束的时候调用getlastError，这不仅能确保最后一次写入正确，而且也能确保所有的写入都能到达服务器。如果连续写入上万条记录而不调用
getlastError，那么不能确保在同一个TCP socket里所有的写入都成功。这在并发的情况下可能就会有问题。避免这个并发问题，可以参考如何在一个链接（请求）里完成批量操作，URL：java driver concurrency
http://www.mongodb.org/display/DOCS/Java+Driver+Concurrency

5、对数据安全要求非常高的的配置：j=true，w="majority"
db.runCommand({getlasterror:1,j:true,w:'majority',wtimeout:10000})
java语言可以在MongoOption中设置，MongoOption中的这些设置是全局的，对于单独的一个（连接）操作，还可以分别设置。 

参考：

1、http://www.mongodb.org/display/DOCS/Journaling
2、http://www.mongodb.org/display/DOCS/Java+Driver+Concurrency
3、http://www.mongodb.org/display/DOCS/getLastError+Command


