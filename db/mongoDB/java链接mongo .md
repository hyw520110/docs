一、链接方式：

1、单台服务器或主从模式：

	Mongo mongo1 = new Mongo( "127.0.0.1" );
    Mongo mongo2 = new Mongo( "127.0.0.1", 27017 );
    Mongo mongo3 = new Mongo( new DBAddress( "127.0.0.1", 27017, "test" ) );
    Mongo mongo4 = new Mongo( new ServerAddress( "127.0.0.1") );
四种方式均可，默认的链接端口是27017。

2、复制集模式链接：请注意，单台机器上配置的复制集最好使用真实ip初始化和链接，不建议使用127.0.0.1或者localhost，否则容易链接不上.

	static Mongo m = null;
    static{
    try {
	    List list= new ArrayList();
	    ServerAddress sap0 = new ServerAddress("192.168.132.100",20011);
	    ServerAddress sas1 = new ServerAddress("192.168.132.100",20012);
	    ServerAddress sas2 = new ServerAddress("192.168.132.100",20013);
	    list.add(sap0);
	    list.add(sas1);
	    list.add(sas2);
	    m = new Mongo(list);
    } catch (UnknownHostException e) {
       	e.printStackTrace();
    }
    }

二、连接选项：

mongo-java-driver中提供了一个类MongoOption，用于初始化链接参数，主要有一下这些：

1、常规选项：

①、connectionsPerHost：单个主机连接到mongo实例允许的最大连接数。这其实相当于c3p0的maxPoolSize参数，mongo是内建连接池的，功能跟c3p0等差不多，超过了就会新建链接，默认值是10，大并发的话较小。

②、threadsAllowedToBlockForConnectionMultiplier：这个参数是跟connectionsPerHost配套的，当连接数超过connectionsPerHost的时候，需要建立新的连接，连接请求会被阻塞，这个参数就代表允许阻塞请求的最大值，超过这个值之后的请求都会报错。默认值5。

③、maxWaitTime：线程等待链接可用的最长时间，ms单位，默认120,000，两分钟。

④、connectTimeout：建立链接的超时时间。默认为10,000，10s（2.9.0）

⑤、socketTimeout：执行io操作的超时时间，默认为0，代表不超时。

⑥、socketKeepAlive：为防火墙设置的，保证socket存活。默认false。

⑦、autoConnectRetry：自动重连，连接池都有的参数。但是在mongo里显的比较鸡肋，不管设置false还是true，mongo-java-driver本身就有重连机制，而且当是复制集的情况下，如果主库宕机，他只会重连宕机机器的ip，我不知道这个是怎么处理的，以后看源码吧，默认false，看来本来也不建议打开。

⑧、maxAutoConnectRetryTime：我去，坑爹啊，竟然是时间！默认为0，代表15s。。。咋想的。

⑨、slaveOk：用于读写分离，废弃了（mongo2.0/driver2.7）。
使用：

2、特殊选项：

Driver对数据库的写操作分几个安全级别，均是通过WriteConcern类控制，在MongoOption中定义了WriteConcern中使用的全局参数。

①、WriteConcern中的几个安全级别：

    /** No exceptions are raised, even for network issues */
        public final static WriteConcern NONE = new WriteConcern(-1);

        /** Exceptions are raised for network issues, but not server errors */
        public final static WriteConcern NORMAL = new WriteConcern(0);

        /** Exceptions are raised for network issues, and server errors; waits on a server for the write operation */
        public final static WriteConcern SAFE = new WriteConcern(1);

        /** Exceptions are raised for network issues, and server errors; waits on a majority of servers for the write operation ,waits for more than 50% of the configured nodes to acknowledge the write (until replication is applied to the point of that write)
    	*/
        public final static WriteConcern MAJORITY = new Majority();

        /** Exceptions are raised for network issues, and server errors; the write operation waits for the server to flush the data to disk*/
        public final static WriteConcern FSYNC_SAFE = new WriteConcern(true);

        /** Exceptions are raised for network issues, and server errors; the write operation waits for the server to group commit to the journal file on disk*/
        public final static WriteConcern JOURNAL_SAFE = new WriteConcern( 1, 0, false, true );

        /** Exceptions are raised for network issues, and server errors; waits for at least 2 servers for the write operation*/
        public final static WriteConcern REPLICAS_SAFE = new WriteConcern(2);


NONE的级别最低，不管出了啥事儿，客户端一股脑的往mongo插入，连网络断了都不管。REPLICAS_SAFE的级别最高，他要等从库都同步完才返回给客户端插入成功，复制集的话要至少两台同步完才行，分布式事务啊，牛叉，但是，它没有事务。。。。


②、参数解释：

WriteConcern的初始化函数，一通重载之后调用：

	    public WriteConcern( int w , int wtimeout , boolean fsync , boolean j, boolean continueOnInsertError){
            _w = w;
            _wtimeout = wtimeout;
            _fsync = fsync;
            _j = j;
            _continueOnErrorForInsert = continueOnInsertError;
        }

这个函数指定写操作需要等待的server的数量和抛出异常的行为。

w：代表server的数量：。

w=-1 不等待，不做异常检查

w=0 不等待，只返回网络错误

w=1 检查本机，并检查网络错误

w>1 检查w个server，并返回网络错误

wtimeout：写操作超时的时间。

fsync ：是不是等待刷新数据到磁盘，参见FSYNC_SAFE的注释。

j：是不是等待提交的数据已经写入到日志，并刷新到磁盘，参见JOURNAL_SAFE的注释。

MongoOption中有全局的设置。还有一个

safe：相当于w=1,wtimeout=0，fsync和j为false，如果这几个指定了，safe不起作用。参见SAFE的注释

三、MongoOption的使用：

	MongoOptions op = new MongoOptions();
    op.safe=true;
    op.connctionPerHost=50;
    op.connctionTimeout=120000;
    ....
    //list是serverAddress的列表
    Mongo m = new Mongo(list,op);
WriteConcern设置好之后用

	m.setWriteConcern(wc);