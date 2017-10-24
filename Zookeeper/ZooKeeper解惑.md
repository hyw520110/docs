<p>最近针对ZK一些比较疑惑的问题，再看了一下相关代码，列举如下。这里只列官方文档中没有的，或者不清晰的。以zookeeper-3.3.3为基准。以下用ZK表示ZooKeeper。</p>
<p>一个ZooKeeper对象，代表一个ZKClient。应用通过ZooKeeper对象中的读写API与ZK集群进行交互。一个简单的创建一条数据的例子，只需如下两行代码：</p>
<pre class="brush:java;toolbar:false;">ZooKeeper zk = new ZooKeeper(serverList, sessionTimeout, watcher);
zk.create("/test", new byte[0], Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);</pre>
<h1>Client和ZK集群的连接和Session的建立过程</h1>
<p>ZooKeeper对象一旦创建，就会启动一个线程（ClientCnxn）去连接ZK集群。ZooKeeper内部维护了一个Client端状态。</p>
<pre class="brush:java;toolbar:false;">public enum States {
CONNECTING, ASSOCIATING, CONNECTED, CLOSED, AUTH_FAILED;
…}</pre>
<p>第一次连接ZK集群时，首先将状态置为CONNECTING，然后挨个尝试连接serverlist中的每一台Server。Serverlist在初始化时，顺序已经被随机打乱：<br>Collections.shuffle(serverAddrsList)<br>这样可以避免多个client以同样的顺序重连server。重连的间隔毫秒数是0-1000之间的一个随机数。<br>一旦连接上一台server，首先发送一个ConnectRequest包，将ZooKeeper构造函数传入的sessionTimeout数值发动给Server。ZooKeeperServer有两个配置项：</p>
<p style="padding-left:30px;">minSessionTimeout单位毫秒。默认2倍tickTime<br>maxSessionTimeout单位毫秒。默认20倍tickTime<br>（tickTime也是一个配置项。是Server内部控制时间逻辑的最小时间单位）</p>
<p>如果客户端发来的sessionTimeout超过min-max这个范围，server会自动截取为min或max，然后为这个Client新建一个Session对象。Session对象包含sessionId、timeout、tickTime三个属性。其中sessionId是Server端维护的一个原子自增long型（8字节）整数；启动时Leader将其初始化为1个字节的leaderServerId+当前时间的后5个字节+2个字节的0；这个可以保证在leader切换中，sessionId的唯一性（只要leader两次切换为同一个Server的时间间隔中session建立数不超过(2的16次方)*间隔毫秒数。。。不可能达到的数值）。</p>
<p>ZKServer端维护如下3个Map结构，Session创建后相关数据分别放入这三个Map中：</p>
<p style="padding-left:30px;">Map&lt;Long[sessionId],Session&gt;sessionsById<br>Map&lt;Long[sessionId],Integer&gt;sessionsWithTimeout<br>Map&lt;Long[tickTime],SessionSet&gt;sessionSets</p>
<p>其中sessionsById简单用来存放Session对象及校验sessionId是否过期。sessionsWithTimeout用来维护session的持久化：数据会写入snapshot，在Server重启时会从snapshot恢复到sessionsWithTimeout，从而能够维持跨重启的session状态。</p>
<p>Session对象的tickTime属性表示session的过期时间。sessionSets这个Map会以过期时间为key，将所有过期时间相同的session收集为一个集合。Server每次接到Client的一个请求或者心跳时，会根据当前时间和其sessionTimeout重新计算过期时间并更新Session对象和sessionSets。计算出的过期时间点会向上取整为ZKServer的属性tickTime的整数倍。Server启动时会启动一个独立的线程负责将大于当前时间的所有tickTime对应的Session全部清除关闭。</p>
<p>Leader收到连接请求后，会发起一个createSession的Proposal，如果表决成功，最终所有的Server都会在其内存中建立同样的Session，并作同样的过期管理。等表决通过后，与客户端建立连接的Server为这个session生成一个password，连同sessionId，sessionTimeOut一起返回给客户端（ConnectResponse）。客户端如果需要重连Server，可以新建一个ZooKeeper对象，将上一个成功连接的ZooKeeper对象的sessionId和password传给Server<br>ZooKeeperzk=newZooKeeper(serverList,sessionTimeout,watcher,sessionId,passwd);<br>ZKServer会根据sessionId和password为同一个client恢复session，如果还没有过期的话。</p>
<p>Server生成password的算法比较有意思：</p>
<p style="padding-left:30px;">newRandom(sessionId^superSecret).nextBytes(byte[]passwd)</p>
<p>superSecret是一个固定的常量。Server不保存password，每次在返回client的ConnectRequest应答时计算生成。在客户端重连时再重新计算，与传入的password作比较。因为Random相同的seed随机生成的序列是完全相同的！</p>
<p>Client发送完ConnectRequest包，会紧接着发送authInfo包(OpCode.auth)和setWatches包OpCode.setWatches；authInfo列表由ZooKeeper的addAuthInfo()方法添加，用来进行自定义的认证和授权。</p>
<p>最后当zookeeper.disableAutoWatchReset为false时，若建立连接时ZooKeeper注册的Watcher不为空，那么会通过setWatches告诉ZKServer重新注册这些Watcher。这个用来在Client自动切换ZKServer或重练时，尚未触发的Watcher能够带到新的Server上</p>
<p>以上是连接初始化的时候做的事情。</p>
<h1>关于ACL</h1>
<p>之前看到很多例子里<br>zk.create(“/test”,newbyte[0],Ids.OPEN_ACL_UNSAFE,CreateMode.PERSISTENT);<br>中Ids.OPEN_ACL_UNSAFE的地方用Ids.CREATOR_ALL_ACL，在zookeeper-3.3.3上面跑直接就挂了，报下面的错：<br>org.apache.zookeeper.KeeperException$InvalidACLException:KeeperErrorCode=InvalidACLfor/test<br>atorg.apache.zookeeper.KeeperException.create(KeeperException.java:112)<br>atorg.apache.zookeeper.KeeperException.create(KeeperException.java:42)<br>atorg.apache.zookeeper.ZooKeeper.create(ZooKeeper.java:637)</p>
<p>是因为3.3.3的ACL进行了细微的调整。先来看下ACL的数据结构：<br>每一个znode节点上都可以设置一个访问控制列表，数据结构为List</p>
<pre class="brush:java;toolbar:false;">ACL
+--perms int （allow What）
+--id Id
+--scheme String （Who）
+--id String      （How）</pre>
<p>一个ACL对象就是一个Id和permission对，用来表示哪个/哪些范围的Id（Who）在通过了怎样的鉴权（How）之后，就允许进行那些操作（What）：WhoHowWhat；permission（What）就是一个int表示的位码，每一位代表一个对应操作的允许状态。类似unix的文件权限，不同的是共有5种操作：CREATE、READ、WRITE、DELETE、ADMIN(对应更改ACL的权限)；Id由scheme（Who）和一个具体的字符串鉴权表达式id(How)构成，用来描述哪个/哪些范围的Id应该怎样被鉴权。Scheme事实上是所使用的鉴权插件的标识。id的具体格式和语义由scheme对应的鉴权实现决定。不管是内置还是自定义的鉴权插件都要实现AuthenticationProvider接口(以下简称AP)。自定义的鉴权插件由zookeeper.authProvider开头的系统属性指定其类名，例如：<br>authProvider.1=com.f.MyAuth<br>authProvider.2=com.f.MyAuth2<br>AP接口的getScheme()方法定义了其对应的scheme</p>
<p>客户端与Server建立连接时，会将ZooKeeper.addAuthInfo()方法添加的每个authInfo都发送给ZKServer。</p>
<pre class="brush:java;toolbar:false;">void addAuthInfo(String scheme, byte auth[])</pre>
<p>addAuthInfo方法本身也会直接将authInfo发送给ZKServer。ZKServer接受到authInfo请求后，首先根据scheme找到对应的AP，然后调用其handleAuthentication()方法将auth数据传入。对应的AP将auth数据解析为一个Id，将其加入连接上绑定的authInfo列表（List）中。Server在接入客户端连接时，首先会自动在连接上加上一个默认的scheme为ip的authIndo：authInfo.add(newId(“ip”,client-ip));</p>
<p>鉴权时调用AP的matches()方法判断进行该操作的当前连接上绑定的authInfo是否与所操作的znode的ACL列表匹配。</p>
<p>ZK有4个内置的scheme：</p>
<p style="padding-left:30px;">world只有一个唯一的id：anyone；表示任何人都可以做对应的操作。这个scheme没有对应的鉴权实现。只要一个znode的ACLlist中包含有这个scheme的Id，其对应的操作就运行执行<br>auth没有对应的id，或者只有一个空串””id。这个scheme没有对应的鉴权实现。语义是当前连接绑定的适合做创建者鉴权的autoInfo(通过调用autoInfo的scheme对应的AP的isAuthenticated()得知)都拥有对应的权限。遇到这个auth后，Server会根据当前连接绑定的符合要求的autoInfo生成ACL加入到所操作znode的acl列表中。<br>digest使用username:password格式的字符串生成MD5hash作为ACLID。具体格式为：username:base64encodedSHA1passworddigest.对应内置的鉴权插件：DigestAuthenticationProvider<br>ip用IP通配符匹配客户端ip。对应内置鉴权插件IPAuthenticationProvider</p>
<p>只有两类API会改变Znode的ACL列表：一个是create()，一个是setACL()。所以这两个方法都要求传入一个List。Server接到这两种更新请求后，会判断指定的每一个ACL中，scheme对应的AuthenticationProvider是否存在，如果存在，调用其isValid(String)方法判断对应的id表达式是否合法。。。具体参见PrepRequestProcessor.fixupACL()方法。上文的那个报错是因为CREATOR_ALL_ACL只包含一个ACL:Perms.ALL,Id(“auth”,“”)，而auth要求将连接上适合做创建者鉴权的autoInfo都加入节点的acl中，而此时连接上只有一个默认加入的Id(“ip”,client-ip)，其对应的IPAuthenticationProvider的isAuthenticated()是返回false的，表示不用来鉴权node的创建者。<br>tbd：具体例子</p>
<h1>关于Watcher</h1>
<p>先来看一下ZooKeeper的API:读API包括exists，getData，getChildren四种</p>
<pre class="brush:java;toolbar:false;">Stat exists(String path, Watcher watcher)
Stat exists(String path, boolean watch)
void exists(String path, Watcher watcher, StatCallback cb, Object ctx)
void exists(String path, boolean watch  , StatCallback cb, Object ctx)
byte[] getData(String path, Watcher watcher, Stat stat)
byte[] getData(String path, boolean watch  , Stat stat)
void   getData(String path, Watcher watcher, DataCallback cb, Object ctx)
void   getData(String path, boolean watch  , DataCallback cb, Object ctx)
List&amp;lt;String&amp;gt; getChildren(String path, Watcher watcher)
List&amp;lt;String&amp;gt; getChildren(String path, boolean watch  )
void  getChildren(String path, Watcher watcher, ChildrenCallback cb, Object ctx)
void  getChildren(String path, boolean watch  , ChildrenCallback cb, Object ctx)
List&amp;lt;String&amp;gt; getChildren(String path, Watcher watcher, Stat stat)
List&amp;lt;String&amp;gt; getChildren(String path, boolean watch  , Stat stat)
void getChildren(String path, Watcher watcher, Children2Callback cb, Object ctx)
void getChildren(String path, boolean watch  , Children2Callback cb, Object ctx)</pre>
<p>每一种按同步还是异步，添加指定watcher还是默认watcher又分为4种。默认watcher是只在ZooKeeperzk=newZooKeeper(serverList,sessionTimeout,watcher)中指定的watch。如果包含booleanwatch的读方法传入true则将默认watcher注册为所关注事件的watch。如果传入false则不注册任何watch</p>
<p>写API包括create、delete、setData、setACL四种，每一种根据同步还是异步又分为两种：</p>
<pre class="brush:java;toolbar:false;">String create(String path, byte data[], List&amp;lt;ACL&amp;gt; acl, CreateMode createMode)
void   create(String path, byte data[], List&amp;lt;ACL&amp;gt; acl, CreateMode createMode, StringCallback cb, Object ctx)
void delete(String path, int version)
void delete(String path, int version, VoidCallback cb, Object ctx)
Stat setData(String path, byte data[], int version)
void setData(String path, byte data[], int version, StatCallback cb, Object ctx)
Stat setACL(String path, List&amp;lt;ACL&amp;gt; acl, int version)
void setACL(String path, List&amp;lt;ACL&amp;gt; acl, int version, StatCallback cb, Object ctx)</pre>
<p><a href="http://img1.51cto.com/attachment/201311/185643226.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="・・・.png" src="http://img1.51cto.com/attachment/201311/185643226.png" alt="185643226.png"></a></p>
<p>可见Watcher机制的轻量性：通知的只是事件。Client和server端额外传输的只是个boolean值。对于读写api操作来说，path和eventType的信息本身就有了。只有在notify的时候才需要加上path、eventType的信息。内部存储上，Server端只维护一个Map(当然会根据watcher的类型分为两个)，key为path，value为本身以及存在的连接对象。所以存储上也不是负担。不会随着watcher的增加无限制的增大</p>
<p>Watcher的一次性设计也大大的减轻了服务器的负担和风险。假设watcher不是一次性，那么在更新很频繁的时候，大量的通知要不要丢弃？精简？并发怎么处理？都是一个问题。一次性的话，这些问题就都丢给了Client端。并且Client端事实上并不需要每次密集更新都去处理。</p>
<p>如果一个znode上大量Client都注册了watcher，那么触发的时候是串行的。这里可能会有一些延迟。</p>
<h1>关于Log文件和snapshot</h1>
<p>Follower/Leader每接收到一个PROPOSAL消息之后，都会写入log文件。log文件的在配置项dataLogDir指定的目录下面。文件名为log.+第一条记录对应的zxid</p>
<p>[linxuan@test036081conf]$ls/usr/zkdataLogDir/version-2/<br>log.100000001log.200000001</p>
<p>ZooKeeper在每次写入log文件时会做检查，当文件剩余大小不足4k的时候，默认会一次性预扩展64M大小。这个预扩展大小可以通过系统属性zookeeper.preAllocSize或配置参数preAllocSize指定，单位为K；</p>
<p>会为每条记录计算checksum，放在实际数据前面</p>
<p>每写1000条log做一次flush(调用BufferedOutputStream.flush()和FileChannel.force(false))。这个次数直到3.3.3都是硬编码的，无法配置</p>
<p>每当log写到一定数目时，ZooKeeper会将当前数据的快照输出为一个snapshot文件：</p>
<pre class="brush:java;toolbar:false;">randRoll = Random.nextInt(snapCount/2);
if (logCount &amp;gt; (snapCount / 2 + randRoll)) {
rollLog();
take_a_snapshot_in_a_new_started_thread();
}</pre>
<p>这个randRoll是一个随机数，为了避免几台ZkServer在同一时间都做snapshot<br>输出快照的log数目阀值snapCount可以通过zookeeper.snapCount系统属性设置，默认是100000条。输出snapshot文件的操作在新创建的单独线程里进行。任一时刻只会有一个snapshot线程。Snapshot文件在配置项dataDir指定的目录下面生成，命名格式为snapshot.+最后一个更新的zxid。</p>
<p>如指定dataDir=/home/linxuan/zookeeper-3.3.3/data，则snapshot文件为：<br>[linxuan@test036081version-2]$ls/home/linxuan/zookeeper-3.3.3/data/version-2<br>snapshot.0snapshot.100000002</p>
<p>每个snapshot文件也都会写入全部数据的一个checksum。</p>
<p>ZK在每次启动snapshot线程前都会将当前的log文件刷出，在下次写入时创建一个新的log文件。不管当前的log文件有没有写满。旧的log文件句柄会在下一次commit（也就是flush的时候）再顺便关闭。</p>
<p>所以这种机制下，log文件会有一定的空间浪费，大多情况下会没有写满就换到下一个文件了。可以通过调整preAllocSize和snapCount两个参数来减少这种浪费。但是定时自动删除没用的log文件还是必须的，只保留最新的即可。</p>
<p>为了保证消息的安全，排队的消息在没有flush到log文件之前不会提交到下一个环节。而为了提高log文件写入的效率，又必须做批量flush。所以更新消息实际上也是和批量flushlog文件的操作一起，批量提交到下一个协议环节的。当请求比较少时（包括读请求），每个更新会很快刷出，即使没有写够1000条。当请求压力很大时，才会一直等堆积到1000条才刷出log文件，同时送出消息到下一个环节。这里的实现比较细致，实质上是在压力大时，不光是写log，连同消息处理都做了一个批量操作。具体实现细节在SyncRequestProcessor中</p>
<h1>Client和ZK集群的完整交互</h1>
<p>ZK整体上来说，通过单线程和大量的队列来达到消息在集群内完成一致性协议的情况下，仍然能保证全局顺序。下面是一个线程和queue的全景图：</p>
<p><a href="http://img1.51cto.com/attachment/201311/185734847.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="12121.png" src="http://img1.51cto.com/attachment/201311/185734847.png" alt="185734847.png"></a></p>
<p>这个图中，除了个别的之外，每个节点都要么代表一个Thread，要么代表一个queue</p>
<h1>其他</h1>
<p>ZKServer内部通过大量的queue来处理消息，保证顺序。这些queue的大小本身都不设上限。有一个配置属性globalOutstandingLimit用来指定Server的最大请求堆积数。ZKServer在读入消息时如果发觉内部的全局消息计数大于这个值，就会直接关闭当前连接上的读取来保护服务端。（取消与当前Client的Nio连接上的读取事件注册）</p>
<p></p>
