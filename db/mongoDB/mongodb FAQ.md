##child process failed, exited with error number 100

一般是没有正常关闭mongodb引起的。查看启动日志，根据提示的链接去看了下，要以修复的方式启动。

先删除数据文件目录下的mongod.lock,然后以repair的模式启动：

	./mongod -f ../conf/28001.conf --repair
	./mongod -f ../conf/28001.conf
正确关闭mongodb

	./mongo
	use admin
	db.shutdownServer()
或直接kill -15 <pid> 注意kill -9 可能导致数据文件损坏

## 为什么java无法连接搭在一台机器上的mongo复制集 ##

这篇文章或许已经不再使用，测试版本为2.7.x，有兴趣可以测试最新版本
一、问题说明：

最近测试mongo复制集，由于没有机器，所以选择在一台虚拟机上搭建。然后使用mongo-java-driver连接。

①、复制集初始化函数如下：
      

    > config = {_id: 'shard1', members: [{_id: 0, host: '127.0.0.1:20011'},{_id: 1, host: '127.0.0.1:20012'},{_id: 2, host:'127.0.0.1:20013'}]}
    > rs.initiate(config)

        或者你换成localhost，都没有关系。
②、java连接代码如下：

    static Mongo m = null;
        static{
            try {
                List<ServerAddress> list= new ArrayList<ServerAddress>();
                ServerAddress sap0 = new ServerAddress("192.168.132.100",20011);
                ServerAddress sas1 = new ServerAddress("192.168.132.100",20012);
                ServerAddress sas2 = new ServerAddress("192.168.132.100",20013);
                list.add(sap0);
                list.add(sas1);
                list.add(sas2);
                m = new Mongo(list);
            } catch (UnknownHostException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

192.168.132.100是虚拟机的IP，并不是使用本地localhost或者127.0.0.1，因为程序不再虚拟机上么。
报错：

    Exception in thread "main" com.mongodb.MongoException: can't find a master


原因分析：
m = new Mongo(list);
使用此方法：

    public Mongo( List<ServerAddress> replicaSetSeeds , MongoOptions options )
            throws MongoException {
            ....
            _addrs = replicaSetSeeds;
            ....
            _connector = new DBTCPConnector( this , _addrs );
            _connector.start();
            ...
    }

数据库连接是DBTCPConnector的实体类。

    public DBTCPConnector( Mongo m , List<ServerAddress> all )
            throws MongoException {
            _portHolder = new DBPortPool.Holder( m._options );
            _checkAddress( all );

            _allHosts = new ArrayList<ServerAddress>( all );
            _rsStatus = new ReplicaSetStatus( m, _allHosts );

            _createLogger.info( all " -> " getAddress() );
        }

错误报错是找不到主，我们关注ReplicaSetStatus类，继续往下走：
       这个类是获取replica set 最新状态的，运行时，后台有一个线程ping服务器，所以这个类的状态都是最新的。他会读取rs的初始化函数，得到host，主从等等状态信息。
初始化函数:

    ReplicaSetStatus( Mongo mongo, List<ServerAddress> initial ){
            _all = Collections.synchronizedList( new ArrayList<Node>() );
            for ( ServerAddress addr : initial ){
                _all.add( new Node( addr ) );
            }
            ...

            _updater = new Updater();
        }

可以看到还有一个Node类，这个类是个内部类，保存address的名称，端口等信息。
Updater即是后台进程，同样是个内部类，继承Thead类：

    class Updater extends Thread {
            Updater(){
                super( "ReplicaSetStatus:Updater" );
                setDaemon( true );
            }

            public void run(){
                while ( ! _closed ){
                    try {
                        updateAll();

                        long now = System.currentTimeMillis();
                        if (inetAddrCacheMS > 0 && _nextResolveTime < now) {
                            _nextResolveTime = now inetAddrCacheMS;
                            for (Node node : _all) {
                                node.updateAddr();
                            }
                        }

                        // force check on master
                        // otherwise master change may go unnoticed for a while if no write concern
                        _mongo.getConnector().checkMaster(true, false);
                    }
                    catch ( Exception e ){
                        _logger.log( Level.WARNING , "couldn't do update pass" , e );
                    }

                    try {
                        Thread.sleep( updaterIntervalMS );
                    }
                    catch ( InterruptedException ie ){
                    }

                }
            }
        }

当_connector.start();执行时，就会启动这个线程。关注绿色代码部分，updateAll()函数

    synchronized void updateAll(){
            HashSet<Node> seenNodes = new HashSet<Node>();
            for ( int i=0; i<_all.size(); i++ ){
                Node n = _all.get(i);
                n.update(seenNodes);
            }
            ...
        }

n.update(seenNodes),继续。。

    synchronized void update(Set<Node> seenNodes){
                try {
                    long start = System.currentTimeMillis();
                    CommandResult res = _port.runCommand( _mongo.getDB("admin") , _isMasterCmd );
                   ...
    }

可以看到程序会远程执行isMaster命令，得到res

    { "serverUsed" : "192.168.72.128:20011" , "setName" : "rstest" , "ismaster" : false , "secondary" : true , "hosts" : [ "localhost:20011" , "localhost:20013" , "localhost:20012"] , "primary" : "localhost:20012" , "me" : "localhost:20011" , "maxBsonObjectSize" : 16777216 , "ok" : 1.0}


这样的信息，看到了吧，hosts里面显示的是localhost:20011，就是我们在config函数里配置的IP
然后后面的程序会更新Node，将host变为localhost：20011，这样，我们的程序就无法连接了，毕竟不是在本地配置的。
其实这是个特例了，如果你的程序和mongo在一起的话，这样配置也不会出错，如果程序和mongo不在一起，那么你就需要用外部IP配置复制集了。解决办法如下：

    > config = {_id: 'shard1', members: [{_id: 0, host: '192.168.132.100:20011'},{_id: 1, host: '192.168.132.100:20012'},{_id: 2, host:'192.168.132.100:20013'}]}
    > rs.initiate(config)

说实在的，写到这里我写不下去了，因为这个是另外启动的线程，我无法调试出来具体的过程。但是原因却是是这个，大家注意就好了，如果有调试出具体过程的，感谢分享。


2012-09-12：今天开发的同事上线遇到问题，新版mongo2.2链接复制集找不到主，其实还是一个问题，因为现在配置复制集都是使用hostname代替IP，所以在程序中连IP的时候他还是找不到，无法解析。新版的driver-2.9.0已经支持，应该是Updater进程已经经过了判断，发现hostname链接不上后又替换了IP，所以大家用新版的driver吧，或者在应用服务器上也配置hosts，让程序能找到机器就好了。




##记一次MongoShard的问题 ##

 今天搭建mongo Shard遇到一个问题
    

    [mongodb-user] User assertion: 15907:
    could not initialize sharding connection:: specified a different configdb

环境：
1、mongo2.0.4
2、9台机器，3个分片，每个分片是一个复制集，3个configsrv，3个mongos

主要是因为启动mongos时，如果已经配置过configsrv又重新搭建，更改了configsrv的顺序或者更改了configsrv的名字，就会报这个错误。因为在每个分片上会缓存configsrv的信息，所以只删除configsrv的数据时没有用的，只能重启三个片或者重新搭建。


    If you changed it while shards were running then they will cache
    (internal state) on the shards.



## mongo 集群时间不同步异常 

**友情提示：您看到此篇文章时可能已经过时了，当前最新版本是2.2.0。**

昨天配置的mongoshard集群，出现了如下异常，今天直接down掉： 
	
	[Balancer] caught exception while doing balance: error checking clock skew of cluster mongotest12:30011,mongotest22:30011,mongotest32:30011 :: caused by :: 13650 clock skew of the cluster mongotest12:30011,mongotest22:30011,mongotest32:30011 is too far out of bounds to allow distributed locking.

看来mongodb的server之间时间必须一致，或者不能差距太大，察看了下源码，记录如下：
报错的信息在client/distlock.cpp的DistributedLock这个类中。DistributedLock（分布锁）这个类为configdb提供了同步整个集群环境任务状态的方法。每个任务在集群中都必须有一个唯一的名字，比如数据平衡任务'balancer'。这个锁的信息记录在configdb的locks集合中。每个锁生效都必须在一个预先规定的时间范围内，在初始化类的时候这个类都会自动去维护这个时间，判断是否超时。

DistributedLock的got函数

	    string got( DistributedLock& lock, unsigned long long sleepTime ) {
        ....
         // Check our clock skew
                try {
                    if( lock.isRemoteTimeSkewed() ) {
                        throw LockException( str::stream() << "clock skew of the cluster " << conn.toString() << " is too far out of bounds to allow distributed locking." , 13650 );
                    }
                }
                catch( LockException& e) {
                    throw LockException( str::stream() << "error checking clock skew of cluster " << conn.toString() << causedBy( e ) , 13651);
                }
        ....
    }
    bool DistributedLock::isRemoteTimeSkewed() {
         return !DistributedLock::checkSkew( _conn, NUM_LOCK_SKEW_CHECKS, _maxClockSkew, _maxNetSkew );
    }

	 
	//Check the skew between a cluster of servers
 
	static bool checkSkew( const ConnectionString& cluster, unsigned skewChecks = NUM_LOCK_SKEW_CHECKS, unsigned long long maxClockSkew = MAX_LOCK_CLOCK_SKEW, unsigned long long maxNetSkew = MAX_LOCK_NET_SKEW );


checkSkew就是判断server之间时间差的函数，此函数有几个参数

1、skewChecks 检查次数

2、maxClockSkew 最大的时间差

3、maxNetSkew 检查时网络的最大时间差

每个参数初始化的时候都有默认值，此默认值在distlock.h头文件中 

    #define LOCK_TIMEOUT (15 * 60 * 1000)
    #define LOCK_SKEW_FACTOR (30)
    #define LOCK_PING (LOCK_TIMEOUT / LOCK_SKEW_FACTOR)
    #define MAX_LOCK_NET_SKEW (LOCK_TIMEOUT / LOCK_SKEW_FACTOR)
    #define MAX_LOCK_CLOCK_SKEW (LOCK_TIMEOUT / LOCK_SKEW_FACTOR)
    #define NUM_LOCK_SKEW_CHECKS (3)

可以看到skewChecks 默认检查3次，maxClockSkew 的默认值是30s，maxNetSkew 也是30s，时间还是比较短的。

maxNetSkew 是从检查机器到被检查机器，执行serverStatus命令返回的最大时间 

	Date_t then = jsTime();
    bool success = conn->get()->runCommand( string("admin"),BSON( "serverStatus" << 1 ), result );
    delay = jsTime() - then;

如果delay>2*MAX_LOCK_NET_SKEW 则认为超时

checkSkew通过相互比较集群中server的时间3次，得到集群中差值最大的时间间隔，如果大于maxClockSkew ，那么报出异常 

	// Make sure our max skew is not more than our pre-set limit
	if(totalSkew > (long long) maxClockSkew) {
	    log( logLvl + 1 ) << "total clock skew of " << totalSkew << "ms for servers " << cluster << " is out of " << maxClockSkew << "ms bounds." << endl;
	    return false;
	}

起初我们认为是由于时间问题引起的down机问题，后来才发现是因为crontab里配置了太多的切割日志的脚本，且都在同一时间，导致一个分片都down掉，整个集群才down的。

切割日志命令：

	killall -SIGUSR1 mongod
    killall -SIGUSR1 mongos


##Mongo复制集搭建 ##

呼~看了一晚上mongo-java-driver的源码也没找到异常在哪   

    com.mongodb.MongoException: unauthorized db:test lock type:-1 client:192.168.72.1

后来想来想去，复制集使用keyfile相互连接，按说不用密码确实不应该连接成功，可惜在公司竟然成功了，我去~~百思不得其解。
以上牢骚，复制集搭建（单台机器测试），以下：
1、初始化环境    

    useradd mongo
    mkdir -p /export/data/mongodb_data
    mkdir -p /export/data/logs
    mkdir -p /export/data/key
    chown mongo.mongo /export/data/*
    su - mongo
    mkdir -p mongodb_data/r0
    mkdir -p mongodb_data/r1
    mkdir -p mongodb_data/r2

 2、 生成keyfile

    echo "AABIwAAAQEArfcoYJYsGYg62tHn31uuJMr6AXPr0rVA3Hkk" > /export/data/key/r0
    echo "AABIwAAAQEArfcoYJYsGYg62tHn31uuJMr6AXPr0rVA3Hkk" > /export/data/key/r1
    echo "AABIwAAAQEArfcoYJYsGYg62tHn31uuJMr6AXPr0rVA3Hkk" > /export/data/key/r2
    chmod 600 /export/data/key/*

 3、启动mongo

    mongod --replSet rstest --keyFile /export/data/key/r0 --port 20011 --dbpath /export/data/mongodb_data/r0/ --logpath /export/data/logs/r0.log --logappend --oplogSize 100 --rest --directoryperdb --maxConns 200 --fork
    mongod --replSet rstest --keyFile /export/data/key/r1 --port 20012 --dbpath /export/data/mongodb_data/r1/ --logpath /export/data/logs/r1.log --logappend --oplogSize 100 --rest --directoryperdb --maxConns 200 --fork
    mongod --replSet rstest --keyFile /export/data/key/r2 --port 20013 --dbpath /export/data/mongodb_data/r2/ --logpath /export/data/logs/r2.log --logappend --oplogSize 100 --rest --directoryperdb --maxConns 200 --fork

4、初始化

    mongo --port 20011
    > config = {_id: 'rstest', members: [{_id: 0, host: '127.0.0.1:20011'},{_id: 1, host: '127.0.0.1:20012'},{_id: 2, host:'127.0.0.1:20013'}]}
    > rs.initiate(config)
    > rs.status()

大概1分钟才会看到Primary和Secondary分配好。





1、count统计结果错误
这是由于分布式集群正在迁移数据，它导致count结果值错误，需要使用aggregate pipeline来得到正确统计结果，例如：

db.collection.aggregate([{$group: {_id: null, count: {$sum: 1}}}])

引用：“On a sharded cluster, count can result in an inaccurate count if orphaned documents exist or if a chunk migration is in progress.”

参考：http://docs.mongodb.org/manual/reference/command/count/ 

2、从shell中更新/写入到文档的数字，会变为float类型
引用：“shell中的数字都被MongoDB当作是双精度数。这意味着如果你从数据库中获得的是一个32位整数，修改文档后，将文档存回数据库的时候，这个整数也就被换成了浮点数，即便保持这个整数原封不动也会这样的。”

参考：《MongoDB权威指南》第一版

3、restore数据到新DB时，不要去先建索引
把bson数据文件restore到另一个DB时，需要注意：不能先创建索引再restore数据，否则性能极差，mongorestore工具默认会在restore完数据时，根据dump出来的index信息创建索引，无须自己创建，如果是要更换索引，也应该在数据入库完之后再创建。

4、DB中的namespace数量太多导致无法创建新的collection
错误提示：error: hashtable namespace index max chain reached:1335，如何解决呢？
这是DB中的collection个数太多导致，在实践中以每个collection 8KB计算（跟官方文档里说的不同，可能跟index有关系），256MB可以支持36000个collection。db.system.namespaces.count() 命令可以统计当前DB内的collection数目，DB可支持collection数量是由于nssize参数指定的，它指定了dbname.ns磁盘文件的大小，也就指定了DB可支持的最大collection数目，ns为namespace缩写。默认nssize为16MB。
如果重启MongoD并修改了nssize参数，这新nssize只会对新加入的DB生效，对以前已经存在的DB不生效，如果你想对已经存在的DB采用新的nssize，必须在加大nssize重启之后新建DB，然后把旧DB的collection 复制到新DB中。
namespace限制相关文档：http://docs.mongodb.org/manual/reference/limits/#Number-of-Namespaces

5、moveChunk因旧数据未删除而失败
错误日志：”moveChunk failed to engage TO-shard in the data transfer: can't accept new chunks because there are still 1 deletes from previous migration“。
意思是说，当前正要去接受新chunk 的shard正在删除上一次数据迁移出的数据，不能接受新Chunk，于是本次迁移失败。这种log里显示的是warning，但有时候会发现shard的删除持续了十几天都没完成，查看日志，可以发现同一个chunk的删除在不断重复执行，重启所有无法接受新chunk的shard可以解决这个问题。
参考：
http://stackoverflow.com/questions/26640861/movechunk-failed-to-engage-to-shard-in-the-data-transfer-cant-accept-new-chunk
如果采用了balancer自动均衡，那么可以加上_waitForDelete参数，如：
{ "_id" : "balancer", "activeWindow" : { "start" : "12:00", "stop" : "19:30" }, "stopped" : false, "_waitForDelete" : true }
，这样就不会因delete堆积而导致后续migrate失败，当然，需要考虑到这里的阻塞是否会影响到程序正常运转，在实践中慎重采用使用waitForDelete，因为发现加上它之后迁移性能非常差，可能出现卡住十几个小时的情况，外界拿住了被迁移chunk的游标句柄，这时候删除不能执行，阻塞了后续其它迁移操作。
游标被打开而导致被迁移数据无法及时删除时的日志：
2015-03-07T10:21:20.118+0800 [RangeDeleter] rangeDeleter waiting for open cursors in: cswuyg_test.cswuyg_test, min: { _id: -6665031702664277348 }, max: { _id: -6651575076051867067 }, elapsedSecs: 6131244, cursors: [ 220477635588 ]
这可能会卡住几十小时，甚至一直卡住，影响后续的moveChunk操作，导致数据不均衡。
解决方法还是：重启。

6、bson size不能超过16MB的限制
单个文档的BSON size不能超过16MB。find查询有时会遇到16MB的限制，譬如使用$in 查询的时候，in中的数组元素不能太多。对一些特殊的数据源做MapReduce，MapReduce中间会将数据组合为“KEY：[VALUE1、VALUE2]”这样的格式，当value特别多的时候，也可能会遇上16MB的限制。 限制无处不在，需要注意，”The issue is that the 16MB document limit applies to everything - documents you store, documents MapReduce tries to generate, documents aggregation tries to return, etc.

7、批量插入
批量插入可以减少数据往服务器的提交次数，提高性能，一般批量提交的BSON size不超过48MB，如果超过了，驱动程序自动修改为往mongos的多次提交。

8、安全写入介绍及其沿革
关键字：acknowledge、write concern。

在2012年11月之前，MongoDB驱动、shell客户端默认是不安全写入，也就是fire-and-forget，动作发出之后，不关心是否真的写入成功，如果这时候出现了_id重复、非UTF8字符等异常，客户端不会知道。在2012年11月之后，默认为安全写入，安全级别相当于参数w=1，客户端可以知道写入操作是否成功。如果代码使用Mongo或者Collection来连接数据库，则说明它是默认不安全写入的legacy代码，安全写入已经把连接数据库修改为MongoClient接口。
安全写入可以分为三个级别，
第一级是默认的安全写入，确认数据写入到内存中就返回（w=N属于这一级）；
第二级是Journal save，数据在写入到DB磁盘文件之前，MongoDB会先把操作写入到Journal文件，这一级指的是确认写入了Journal文件就返回；
第三级是fysnc，所有数据刷写到到DB磁盘文件才返回。
一般第一级就足够了，第二级是为了保证在机器异常断电的情况下也不会丢失数据。安全写入要付出性能的代码：不安全写入的性能大概是默认安全写入的3倍。使用fync参数则性能更差，一般不使用。
如果是副本集（replica set），其w=N参数，N表示安全写入到多少个副本集才返回。
参考：
http://docs.mongodb.org/manual/release-notes/drivers-write-concern/
http://docs.mongodb.org/manual/core/write-concern/
http://blog.mongodirector.com/understanding-durability-write-safety-in-mongodb/
http://whyjava.wordpress.com/2011/12/08/how-mongodb-different-write-concern-values-affect-performance-on-a-single-node/

9、善用索引——可能跟你以为的不一样
使用组合索引的时候，如果有两组索引，在限量查询的情况下，可能跟常规的认识不同：
利用组合索引做的查询，在不同数量级下会有不同性能：
组合索引A： {"age": 1, "username": 1}
组合索引B： {"username": 1, "age": 1}
全量查询： db.user.find({"age": {"$gte": 21, "$lte": 30}}).sort({"username" :1})，使用索引A的性能优于索引B。
限量查询： db.user.find({"age": {"$gte": 21, "$lte": 30}}).sort({"username": 1}).limit(1000)，使用索引B的性能优于索引A。
这两个查询在使用索引A的时候，是先根据age索引找到符合age的数据，然后再对这些结果做排序。使用索引B的时候，是遍历name，对应的数据判断age，然后得到的结果是name有序的。
优先使用sort key索引，在大多数应用上执行得很好。
参考：《MongoDB——The Definitive Guide 2nd Edition》page89

10、查询时索引位置的无顺序性
做find的时候，并不要求索引一定要在前面，
譬如：
db.test集合中对R有索引
db.test.find({R:"AA", "H": "BB"}).limit(100).explain()
db.test.find({"H":"BB", "R" : "AA"}).limit(100).explain()
这两个查找性能一样，它都会使用R索引。

11、使用组合索引做shard key可以大幅度提高集群性能
“固定值+增量值” 两字段做组合索引可以有效的实现分布式集群中的分散多热点写入、读取。以下为读书笔记：
在单个MongoDB实例上，最高效的写入是顺序写入，而MongoDB集群则要求写入能随机，以便平均分散到多个MongoDB实例。所以最高效的写入是有多个局部热点：在多个MongoDB实例之间是分散写入，在实例内部是顺序写入。 要实现这一点，我们采用组合索引。
例如：shardkey的第一部分是很粗糙的，可选集很少的字段，索引的第二部分是递增字段，当数据增加到一定程度时，会出现很多第一部分相同第二部分不同的chunk，数据只会在最后一个chunk里写入数据，当第一部分不同的chunk分散在多个shard上，就实现了多热点的写入。如果在一个shard上，不止一个chunk可以写入数据，那也就是说不止一个热点，当热点非常多的时候，也就等同于无热点的随机写入。当一个chunk分裂之后，只能有一个成为热点，另一个不能再被写入，否则就会产生两个热点，不再写入的chunk也就是死掉了，后续只会对它有读操作。

最典型的应用是具有日期属性的日志处理，shard key选择“日期+用户ID”组合，保证了数据写入时的局部热点（一个shard上只有少数几个chunk被写入，避免随机IO）和全局分散（所有的shard上都有写入数据，充分利用磁盘IO）。
我在实践中除了书中讲到的组合键方式外，还加上了预分片策略，避免了早期数据增长过程中的分片和数据迁移。另外还尽可能的制造能利用局部性原理的数据写入，例如在数据写入之前先对数据排序，有大约30%左右的update性能提升。

预分片是这样子做的：根据组合shardkey信息先分裂好chunk，把这些空chunk移动到各个shard上，避免了后续自动分裂引起的数据迁移。

good case：

环境：一台机器、7分片、MongoDB2.6版本、shard key选择“日期+用户ID组合”，

数据：写入使用批量插入，对10亿条日志级分片集群的写入，写入1000W条日志只需要35分钟，每条日志约0.11K。

bad case：

环境：3台机器、18分片、MongoDB2.6版本、shard key选择 _id的hashid

数据：写入采用批量插入，对3亿条日志级分片集群的写入，写入300W条日志耗时35分钟，每条日志约0.11K。

从对比可以看到，在数据量比较大的情况下选择组合索引做shard key性能明显优于选择hashid。

我在实际应用中还遇到选择hashid的更极端情况：对3条机器&18分片&3亿条日志集群每天写入300W条日志，耗时170分钟，每条日志约4K。每次写入数据时，所有分片磁盘IO使用率都达到100%。

参考：《MongoDB——The Definitive Guide 2nd Edition》 page268

12、怎么建索引更能提高查询性能？
在查询时，索引是否高效，要注意它的cardinality（cardinality越高表示该键可选择的值越多），在组合索引中，让cardinality高的放在前面。注意这里跟分布式环境选择shard key的不同。以下为读书笔记：
index cardinality（索引散列程度），表示的是一个索引所对应到的值的多少，散列程度越低，则一个索引对应的值越多，索引效果越差：在使用索引时，高散列程度的索引可以更多的排除不符合条件的文档，让后续的比较在一个更小的集合中执行，这更高效。所以一般选择高散列程度的键做索引，或者在组合索引中，把高散列程度的键放在前面。
参考：《MongoDB——The Definitive Guide 2nd Edition》 page98

13、非原地update，性能会很差
update文档时，如果新文档的空间占用大于旧文档加上它周围padding的空间，那么就会放弃原来的位置，把数据拷贝到新空间。
参考：《MongoDB——The Definitive Guide 2nd Edition》 page43

14、无法在索引建立之后再去增加索引的过期时间
如果索引建立指定了过期时间，后续要update过期时间可以这样子：db.runCommand({"collMod":"a", index:{keyPattern:{"_":-1}, expireAfterSeconds: 60}})。

注意，通过collMod能修改过期时间的前提是：这个索引有过期时间，如果这个索引之前没有设置过期时间，那么无法update，只能删了索引，重建索引并指定过期时间。
参考：http://docs.mongodb.org/manual/tutorial/expire-data/

15、_id索引无法删除
参考：《MongoDB——The Definitive Guide 2nd Edition》 page114

16、paddingFactor是什么？
它是存储空间冗余系数，1.0表示没有冗余，1.5表示50%的冗余空间，有了冗余空间，可以让后续引发size增加的操作更快（不会导致重新分配磁盘空间和文档迁移），一般是在1到4之间。可以通过db.collection.stats()看到collection的该值“paddingFactor”。
该值是MongoDB自己处理的，使用者无法设置paddingFactor。我们可以在compact的时候对已经有的文档指定该值，但这个paddingFactor值不影响后续新插入的文档。
repairDatabase跟compact类似，也能移除冗余减少存储空间，但冗余空间少了会导致后续增加文档size的update操作变慢。
虽然我们无法设置paddingFactor，但是可以使用usePowerOf2Sizes保证分配的空间是2的倍数，这样也可以起到作用（MongoDB2.6版本起默认启用usePowerOf2Size）。
或者手动实现padding：在插入文档的时候先用默认字符占用一块空间，等到真实数据写入时，再unset掉它。

参考：
http://docs.mongodb.org/v2.4/core/record-padding/
http://docs.mongodb.org/v2.4/faq/developers/#faq-developers-manual-padding

17、usePowerOf2Size是什么
这是为更有效的复用磁盘空间而设置的参数：分配的磁盘空间是2的倍数，如果超过了4MB，则是距离计算值最近的且大于它的完整MB数。
可以通过db.collections.stats()看到该值“userFlags”。
MongoDB2.6之后默认开启usePowerOf2Size参数
使用后的效果可以看这里的PPT：http://www.slideshare.NET/mongodb/use-powerof2sizes-27300759

18、aggregate pipeline 指定运算完成输出文档跟MapReduce相比有不足
（基于MongoDB2.6版本）MapReduce可以指定输出到特定的db.collection中，例如：out_put = bson.SON([("replace", "collection_name" ), ("db", "xx_db")])
aggregate pipeline只能指定collection名字，也就意味着数据只能写入到本db，同时结果不能写入到capped collection、shard collection中。
相比之下，aggregate pipeline限制是比较多的，如果我们需要把结果放到某个DB下，则需要再做一次迁移：
db.runCommand({renameCollection:"sourcedb.mycol",to:"targetdb.mycol"})
但是！！上面的这条命令要求在admin下执行，且只能迁移往同shard下的DB，且被迁移的collection不能是shard的。
附错误码信息：
https://github.com/mongodb/mongo/blob/master/src/mongo/s/commands_public.cpp#L778
uassert(13140, "Don't recognize source or target DB", confFrom && confTo);
uassert(13138, "You can't rename a sharded collection", !confFrom->isSharded(fullnsFrom));
uassert(13139, "You can't rename to a sharded collection", !confTo->isSharded(fullnsTo));
uassert(13137, "Source and destination collections must be on same shard", shardFrom == shardTo);
参考：http://docs.mongodb.org/manual/reference/method/db.collection.mapReduce/#mapreduce-out-mtd

19、杀掉MongoD进程的几种方式
1）进入到MongoD的命令行模式执行shutdown，
eg: 
$ mongo --port 10001
> use admin
> db.shutdownServer()
2）1方式的简化：
eg：mongo admin --port 10001 --eval "db.shutdownServer()"
3）使用MongoD命令行关闭，需要指定db路径：
mongod --dbpath ./data/db --shutdown

20、集群的shard key慎重采用hash
如果你的日志是有日期属性的，那么shard key不要使用hash，否则删除过期日志时无法成块删除；在更新日志的时候，也不能利用局部性原理，查找、更新、插入数据都会因此而变慢。一般来说，hash id应付小数据量时压力不大，但在数据量较大（热数据大于可用内存容量）时，CRUD性能极差，且会放大碎片对性能的影响：数据非常分散，当有过期日志被删除后，这些删除后的空间成为碎片，可能会因为磁盘预读策略被加载到内存中。另外，采用hash shard key还会浪费掉一个索引，浪费不少空间。

21、副本数也不用太多
如果你的副本数量超过了12个（MongoDB3.0.0超过了50个），那么就要选择使用 master-slave ，但这样会失去故障自恢复功能，主节点故障时，需要手动去切换到无故障节点。

22、mongos的config server配置信息中不要使用localhost、127.0.0.1
启动mongos时，config server的配置信息不得使用localhost、127.0.0.1，否则添加其它机器的shard时，会出现错误提示：
"can’t use localhost as a shard since all shards need to communicate. either use all shards and configdbs in localhost or all in actual IPs host: xxxxx isLocalHost"

以新的config server启动mongos，也需要重启config server，否则会有错误提示：
“could not verify config servers were active and reachable before write”

如果改完后面又出现 “mongos specified a different config database string”  错误，那么还需要重启mongod，

修改了config server 几乎是要全部实例重启。另外，在配置replica set时也不得使用localhost、127.0.0.1。
参考：http://stackoverflow.com/questions/21226255/where-is-the-mongos-config-database-string-being-stored

23、shard key的选择跟update性能紧密关联
分布式MongoDB，shard key的选择跟update性能，甚至是update可用性有很大关系，需要注意。
1、在对文档个别字段update时，如果query部分没有带上shard key，性能会很差，因为mongos需要把这条update语句派发给所有的shard 实例。
2、当update 的upsert参数为true时，query部分必须带上 shard key，否则语句执行出错，例子：
mongos> db.test.update({"_id":".7269993106A92327A89ABCD70D46AD5"}, {"$set":{"P": "aaa"}, "$setOnInsert":{"TEST":"a"}}, true)
WriteResult({
"nMatched" : 0,
"nUpserted" : 0,
"nModified" : 0,
"writeError" : {
"code" : 61,
"errmsg" : "upsert { q: { _id: \".7269993106A92327A89ABCD70D46AD5\" }, u: { $set: { P: "aaa" }, $setOnInsert: { TEST: \"a\" } }, multi: false, upsert: true } does not contain shard key for pattern { _: 1.0, B: 1.0 }"
}
})
这是因为如果没有shard key，mongos既不能在所有shard实例上执行这条语句（可能会导致每个shard都插入数据），也无法选择在某个shard上执行这条语句，于是出错了。
另外，需要特别注意，如果使用pymongo引擎，它不会告诉你出错了，只是函数调用陷入不返回，在shell下执行才能看到错误信息。

附：
以下英文部分来自：https://jira.mongodb.org/browse/SERVER-13010
It's actually not clear to me that this is something we can support - problem is this:
> db.coll.update({ _id : 1 }, { }, true);
> db.coll.find()
{ "_id" : ObjectId("53176700a2bc4d46c176f14a") }
Upserts generate new _ids in response to this operation, and therefore we can't actually target this correctly in a sharded environment. The shard on which we need to perform the query may not be the shard on which the new _id is placed.
意思是说，upsert产生了新的_id，_id就是shard key，但是如果query里没有shard key，它们不知道要到哪个shard上执行这个命令，upsert产生的shard key可能并不是执行这条命令的shard的。
另外，如果_id不是shard key我们的例子也是不能成功的，因为没有shard key，这条upsert要在哪个shard上执行呢？不能像普通update那样给所有的shard去做，否则可能导致插入多条。
参考：
https://jira.mongodb.org/browse/SERVER-13010
http://docs.mongodb.org/manual/core/sharding-shard-key/
http://stackoverflow.com/questions/17190246/which-of-the-following-statements-are-true-about-choosing-and-using-a-shard-key

24、通过repairDatabase提高性能
从db.stats()中可以看到几个跟碎片相关的关键字段，dataSize，表示数据的大小，它包含了padding的空间；storageSize，表示这些数据存储占用的空间，包含了dataSize和被删除数据所占空间，可以认为storageSize/dataSize就是磁盘碎片比例，当删除、update文档比较多后，它会变大，考虑做repairDatabase，以减少碎片让数据更紧凑，在实践中，这对提高CURD性能极其有用。repairDatabase时需要注意：它是把数据拷贝到新的地方，然后再做处理，所以repair之前在DB目录所在磁盘需要预留一倍的空闲磁盘空间，如果你发现磁盘空间不足，可以停止服务，然后增加一块新磁盘，再执行实例级别的repair，并指定--repairpath为新磁盘路径，eg：mongod --dbpath /path/to/corrupt/data --repair --repairpath /media/external-hd/data/db，实例的数据会拷贝到/media/external-hd/data/db上做处理。

参考：《MongoDB——The Definitive Guide 2nd Edition》page325

25、索引字段的长度不能大于1024字节
索引字段的长度不能大于1024字节，否则shell下会有插入错误提示："errmsg" : "insertDocument :: caused by :: 17280 Btree::insert: key too large to index”。
使用pymongo的“continue_on_error”参数，不会发出错误提示，要注意。
参考：http://docs.mongodb.org/manual/reference/limits/#Index-Key-Limit
26、修改索引的expireAfterSeconds之后，负载均衡失败
修改索引的expireAfterSeconds之后，负载均衡失败，出现错误提示“2015-06-05T09:59:49.056+0800 [migrateThread] warning: failed to create index before migrating data.  idx: { v: 1, key: { _: -1 }, name: "__-1", ns: "cswuyg_test.cswuyg_test", expireAfterSeconds: 5227200 } error: IndexOptionsConflict Index with name: __-1 already exists with different options
检查发生moveChunk的两个shard，并没有发现不一致，怀疑存在缓存，重启所有shard解决。
27、config DB无法写入
因config DB无法修改，只可读，导致drop、enablesharding失败：
config server 相关日志：2015-06-11T16:51:19.078+0800 [replmaster] local.oplog.$main Assertion failure isOk() src/mongo/db/storage/extent.h 80
mongos 相关日志： [LockPinger] warning: pinging failed for distributed lock pinger 'xxx:1234/xxx:1235:1433993544:1804289383'. : : caused by :: isOk()
这是同事遇到的问题，不确定是什么操作引起的。重启、configdb做repair均无法解决。
最后通过dump、restore解决：（1）把旧configdb dump出来；（2）restore到新的configure server；（3）mongos采用新的configure server；（4）重启全部mongod。
