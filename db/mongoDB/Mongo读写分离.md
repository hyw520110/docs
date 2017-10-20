 Mongo的主从和复制集结构提供良好的读写分离环境，Mongo的java-driver也实现了读写分离的参数，这给程序开发减少了很多工作。现在我们看一下Mongo-Java-Driver读写分离的一些机制。

MongoJavaDriver的读是通过设置ReadReference参数，顾名思义，读参照，或者读偏好。与之对应的是WriteConcern，字面意思写涉及，就是规定了写的一些参数，比如是否是一致写，对应Mongo中的w，j，fync等参数，我们暂不讨论。在MongoDB 2.0/Java Driver 2.7版本之前，是通过MongoOption的slaveOk参数控制从库的读，在之后的版本已经废弃。

ReadPreference使用方法：

	db.setReadPreference(new ReadPreference().SECONDARY);

ReadReference参数：

	primary 主节点，默认模式，读操作只在主节点，如果主节点不可用，报错或者抛出异常。
	primaryPreferred 首选主节点，大多情况下读操作在主节点，如果主节点不可用，如故障转移，读操作在从节点。
	secondary从节点，读操作只在从节点， 如果从节点不可用，报错或者抛出异常。
	secondaryPreferred首选从节点，大多情况下读操作在从节点，特殊情况（如单主节点架构）读操作在主节点。
	nearest 最邻近节点，读操作在最邻近的成员，可能是主节点或者从节点

ReadReference对应读操作设置，WriteConcern对应写操作设置：

	WriteConcern.NONE:没有异常抛出
	WriteConcern.NORMAL:仅抛出网络错误异常，没有服务器错误异常
	WriteConcern.SAFE:抛出网络错误异常、服务器错误异常；并等待服务器完成写操作。
	WriteConcern.MAJORITY: 抛出网络错误异常、服务器错误异常；并等待一个主服务器完成写操作。
	WriteConcern.FSYNC_SAFE: 抛出网络错误异常、服务器错误异常；写操作等待服务器将数据刷新到磁盘。
	WriteConcern.JOURNAL_SAFE:抛出网络错误异常、服务器错误异常；写操作等待服务器提交到磁盘的日志文件。
	WriteConcern.REPLICAS_SAFE:抛出网络错误异常、服务器错误异常；等待至少2台服务器完成写操作。
write concern的设置，作用是保障write operation的可靠性和性能,合理设置write concern级别，在写操作的性能和可靠性之间做权衡 

一般来说，所有的mongo driver，在执行一个写操作（insert、update、delete）之后，都会立刻调用db.getLastError()方法，以确定写操作是否成功，如果捕获到错误，就可以进行相应的处理。处理逻辑也是完全由client决定的，比如写入日志、抛出错误、等待一段时间再次尝试写入等。作为mongodb server并不关心，server只负责通知client发生了错误，这里有2点需要注意：

1、db.getLastError()方法是由driver负责调用的，所以业务代码不需要自行显式调用db.getLastError()函数，driver在每一个写操作之后，都会立刻自动调用该方法

2、driver一定会调用db.getLastError()函数，但是并不一定能捕获到错误。这主要取决于write concern的设置级别
	
	write concern:0（Unacknowledged）： driver的写入调用立刻返回，即使之后的Apply发生了错误，driver也不知道，所以性能是最好的，但是可靠性是最差的，因此并不推荐使用。在各平台最新版本的driver中，也不再以0作为默认级别。其实还有一个w:-1的级别，是error ignored，基本上和w:0差不多。区别在于，w:-1不会捕获任何错误，而w:0可以捕获network error
	write concern:1（acknowledged）：和Unacknowledged的区别是，现在mongod只有在Apply（实际写入操作）完成之后，才会返回getLastError()的响应。所以如果写入时发生错误，driver就能捕获到，并进行处理。这个级别的write concern具备基本可靠性，也是目前mongodb的默认设置级别
	write concern:1 & journal:true（Jounaled）：Acknowledged级别的write concern也不是绝对可靠的。因为mongodb的Apply操作，是将数据写入内存，定期通过fsync写入硬盘。如果在Apply之后，fsync之前mongod挂了，或者甚至server挂了，那持久化实际上是失败的。但是在w:1的级别下，driver无法捕获到这种情况下的error（因为response在apply之后就已经返回到driver）mongod解决这个问题的办法是使用Journal机制，写操作在写入内存之后，还会写到journal文件中，这样如果mongod非正常down掉，重启以后就可以根据journal文件中的内容，来还原写操作。在64位的mongod下，journal默认是打开的。但是32位的版本，需要用--journal参数来启动在driver层面，则是除了设置w:1之外，再设置journal:true或j:true，来捕获这个情况下的error
	write concern:2（Replica Acknowledged）：这个级别只在replica set的部署模式下生效，只有secondary从primary完成了复制之后，getLastError()的结果才会返回。也可以同时设置journal:true或j:true，则还要等journal写入也成功后才会返回。但是注意，只要primary的journal写入就会返回，而不需要等待secondary的journal也写入。类似的也可以设置w:3，表示至少要有3个节点有数据；或者w:majority，表示>1/2的节点有数据。一般小规模的集群就是3节点部署，所以配置w:2就可以了
设置write concern级别，其实就是在写操作的性能和可靠性之间做权衡。写操作的等待时间越长，可靠性就越好。对于非关键数据，建议使用默认的w:1就可以了，对于关键数据，则使用w:1 & j:true比较好。这里要注意，journal无论如何都是建议打开的，设置j:true，只是说driver调用getLastError()之后是否要等待journal写入完成再返回。并不是说不设置j:true就关闭了server端的journal


我们还是使用复制集连接代码.读测试代码：

	    public static void main(String args[]){
            DB db = m.getDB("test");
            db.authenticate("test", "123".toCharArray());
            while(true){
                DBCollection dbcol = db.getCollection("things");
                System.out.println(dbcol.findOne());
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            
        }

每隔0.5秒查询一次数据库，观察mongostat状态。当我们不设置读参数的时候，Mongo只在主库上读，这跟Mongo文档中写的有出入，我们的观察结果页印证了这点，两个从库上都是是没有任何读的。

当我们设置了

    m.setReadPreference(new ReadPreference().SECONDARY);

之后，再观察两个从库

已经有读了，也可以看出两个从库是交替读的（并不严格，后面会说），而主库没有任何读。
这是为什么呢，我们来看他的实现机制。

首先从findOne()函数开始，这个函数重载了很多方法，最终都是调用：

	    public DBObject findOne( DBObject o, DBObject fields, ReadPreference readPref ) {
            Iterator<DBObject> i = __find( o , fields , 0 , -1 , 0, getOptions(), readPref, getDecoder() );
            DBObject obj = (i == null ? null : i.next());
            if ( obj != null && ( fields != null && fields.keySet().size() > 0 ) ){
                obj.markAsPartialObject();
            }
            return obj;
        }

这是最上层返回数据的函数，我们看到_find()方法中已经存在readPref参数了，这个函数是个抽象函数，DBApiLayer类实现了此方法，继续往下走：

	Response res = _connector.call( _db , this , query , null , 2, readPref, decoder );

函数中调用了_connector.call()，这估计就是执行命令的函数了，continue：

	if (readPref == null)
            readPref = ReadPreference.PRIMARY;

    if (readPref == ReadPreference.PRIMARY && m.hasOption( Bytes.QUERYOPTION_SLAVEOK ))
           readPref = ReadPreference.SECONDARY;
	...
	final DBPort port = mp.get( false , readPref, hostNeeded );
	...
	res = port.call( m , coll, readPref, decoder );
	...

我们看到了我们开头讲的参数设置的判断，如果不设置readPref,那么默认PRIMARY，由于Bytes.QUERYOPTION_SLAVEOK这个参数已经废弃，而且默认是false，所以其他的情况下就是SECONDARY了。
程序是通过DBPort这个类去执行Mongo命令的，我们看得到port的mp.get()函数：

	if ( !(readPref == ReadPreference.PRIMARY) && _rsStatus != null ){
                // if not a primary read set, try to use a secondary
                // Do they want a Secondary, or a specific tag set?
                if (readPref == ReadPreference.SECONDARY) {
                    ServerAddress slave = _rsStatus.getASecondary();
                    if ( slave != null ){
                        return _portHolder.get( slave ).get();
                    }
                } else if (readPref instanceof ReadPreference.TaggedReadPreference) {
                    // Tag based read
                    ServerAddress secondary = _rsStatus.getASecondary( ( (TaggedReadPreference) readPref ).getTags() );
                    if (secondary != null)
                        return _portHolder.get( secondary ).get();
                    else
                        throw new MongoException( "Could not find any valid secondaries with the supplied tags ('" +
                                                  ( (TaggedReadPreference) readPref ).getTags() + "'");
                }
            }
	....
            // use master
            DBPort p = _masterPortPool.get();
            if ( keep && _inRequest ) {
                // if within request, remember port to stick to same server
                _requestPort = p;
            }
	....

这就比较明了了，通过上一篇文章提到的ReplicaSetStatus类的getASecondary()去得到slave：

	int start = pRandom.nextInt( pNodes.size() );
	Node n = pNodes.get( ( start + i ) % nodeCount );
	if ( ! n.secondary() ){
	        mybad++;
	        continue;
	} else if (pTagKey != null && !n.checkTag( pTagKey, pTagValue )){
	        mybad++;
	        continue;
	}

通过一个random的nextInt选择从库，所以说是随即的，不是Round-Robin,交替读也不是这么严格的，但是基本可以这么认为，不是问题。
至于主库的选择，那个实现的比较复杂，他会去判断是不是读的时候主库已经切换，等等严格的检查。

结语：通过简单的设置ReadPreference就可以实现Mongo的读写分离，这对程序再简单不过了。但是由于Mongo跟Mysql都是通过读日志实现的数据同步，短暂的延迟是必然的，而且Mongo现在的版本是全局锁，主从同步也是个问题，特别是设置了严格同步写入的时候。当然这不是Mongo擅长做的事情，你可以用在商品评论，SNS等不在意数据延迟的应用中，真的很奏效。