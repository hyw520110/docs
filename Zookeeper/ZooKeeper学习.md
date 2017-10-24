<p><span style="color:rgb(112,48,160);">一 应用场景描述</span></p>
<p>&nbsp;目前在测试豌豆荚的Codis作为Redis的集群部署方案，但是Codis2.0目前依赖于Zookeeper作为配置信息的存放和同步工具。在接触Zookeeper之前只是看过一些文档和资料大概知道很多公司使用Zookeeper作为配置数据同步和管理的中间件。</p>
<p><br></p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">二 Zookeeper原理</span></p>
<p>按照ZooKeeper官方的说法，ZooKeeper是一个用于维护配置信息，命名空间，提供分布式同步和分组服务的一个中央服务协调工具。</p>
<p>设计目标Design Goals</p>
<p><strong>ZooKeeper很简单</strong></p>
<p>&nbsp;ZooKeeper允许分布式程序相互之间通过一个共享的类似标准文件系统的层级命名空间进行协调工作。这个命名空间由多个数据寄存器组成，又叫做znodes。和典型的文件系统不同的是，ZooKeeper的数据是保存到内存中的，而文件系统上的数据是保存到磁盘上的，这样ZooKeeper可以达到更高的吞吐量和较低的延迟。</p>
<p><br></p>
<p><strong>ZooKeeper可以复制</strong></p>
<p>&nbsp;和ZooKeeper协调的分布式程序一样，ZooKeeper本身设计就是可以在一组主机间进行复制。组成ZooKeeper服务的服务器必须相互之间知道彼此。他们维护一个ZooKeeper服务状态的内存镜像，日志和快照信息存储在磁盘上。只要大部分服务器可用，ZooKeeper服务就可用。</p>
<p>&nbsp;客户端连接到单个ZooKeeper服务器，维护一个用于发送请求，获得响应，获得watch事件和发送心跳的TCP连接。如果这个TCP连接断了，这个客户端将连接到另一个不同的服务器。</p>
<p><br></p>
<p><br></p>
<p><img onload="if(this.width>650) this.width=650;" alt="" src="http://zookeeper.apache.org/doc/r3.4.6/images/zkservice.jpg"></p>
<p><br></p>
<p><br></p>
<p><strong>ZooKeeper是有序的</strong></p>
<p>&nbsp;ZooKeeper用一个数字来标记每个更新来反映所有事务的序列号。后续操作可以使用这个序列号来实现更高层面的抽象概念，比如同步原因。</p>
<p><br></p>
<p><strong>ZooKeeper很快</strong></p>
<p>&nbsp;ZooKeeper在读操作为主导的应用中速度更快。</p>
<p><br></p>
<p><br></p>
<p><strong>数据模型和层级命令空间</strong></p>
<p>&nbsp;ZooKeeper的命名空间很像一个标准的文件系统。不像标准的文件系统那样，ZooKeeper命令空间的每个节点和子节点都可以关联数据。使用znode这个术语来表示ZooKeeper的数据节点</p>
<p><img onload="if(this.width>650) this.width=650;" alt="" src="http://zookeeper.apache.org/doc/r3.4.6/images/zknamespace.jpg"><strong><br></strong></p>
<p><br></p>
<p><strong>Conditional updates and watches</strong></p>
<p>&nbsp;ZooKeeper支持watches的概念。客户端可以在一个znode上设置一个watch。当这个znode改变时，在它上设置的watch也会被触发和移除。</p>
<p><strong><br></strong></p>
<p><strong>Guaranters</strong></p>
<p>&nbsp;ZooKeeper非常快和简单。因为它的设计目标是成为例如同步这些更复杂服务的基础组件，所以它提供一系列的保证措施。</p>
<p>&nbsp;Sequential Consistency序列号一致性 客户端的更新会根据它们发送的顺序</p>
<p>&nbsp;Atomicity原子性 &nbsp; 要么更新失败要么更新成功</p>
<p>&nbsp;Single System Image 无论客户端连接到哪个ZooKeeper服务端得到的数据都是一样的</p>
<p>&nbsp;Reliability &nbsp;一旦一个更新被提交，它将一直保持更新的状态直到更新被重写</p>
<p>&nbsp;Timeliness &nbsp;&nbsp;</p>
<p><strong><br></strong></p>
<p><strong><br></strong></p>
<p><strong><br></strong></p>
<p><span style="color:rgb(112,48,160);">三 ZooKeeper部署和管理</span></p>
<p><strong>1.依赖软件</strong></p>
<p>ZooKeeper需要JDK1.6以上，最好将ZooKeeper部署到不同的机器上。<br></p>
<p><strong>2.设置ZooKeeper集群</strong></p>
<p>为了搭建可靠的ZooKeeper服务，应该部署ZooKeeper集群，又叫做ensemble集合。只要集合中大部分成员可用，那么整个ZooKeeper服务就可用。集合中的成员数量必须是奇数个。</p>
<pre class="brush:bash;toolbar:false">wget&nbsp;
tar&nbsp;zxvf&nbsp;zookeeper-3.4.6.tar.gz
cd&nbsp;zookeeper-3.4.6
cp&nbsp;conf/zoo_sample.cfg&nbsp;&nbsp;conf/zoo.cfg</pre>
<p>zoo.cfg的内容如下</p>
<pre class="brush:plain;toolbar:false">tickTime=2000
initLimit=10
syncLimit=5
dataDir=/tmp/zookeeper
clientPort=2181
autopurge.snapRetainCount=500
autopurge.purgeInterval=24
server.1=zookeeper1:2888:3888
server.2=zookeeper2:2888:3888
server.3=zookeeper3:2888:3888</pre>
<p><br></p>
<p>tickTime 单个计时时间长短，ZooKeeper的基本时间单位，以毫秒为单位。用于常规先跳检测和超时</p>
<p>initLimit &nbsp;允许followers连接并同步到leader的时间总量，如果ZooKeeper管理的数据量比较大就增大这个值<br></p>
<p>syncLimit &nbsp;允许followers向leader同步的时间总量</p>
<p>dataDir &nbsp; 指定ZooKeeper相关数据存放路径</p>
<p><br></p>
<p>dataLogDir 如果设置这个参数那么存放日志到这个参数指定的目录下。dataDir和dataLogDir分开到两个不同的磁盘可以大大提高ZooKeeper的性能。所以ZooKeeper的镜像文件和日志文件最好分开存放，避免日志写入影响性能</p>
<p><br></p>
<p>clientPort 指定监听端口<br></p>
<p><br></p>
<p>autopurge.snapRetainCount 开启自动清理日志</p>
<p>autopurge.purgeInterval &nbsp; &nbsp; &nbsp;清理日志的时间间隔，以小时为单位</p>
<p><br></p>
<p>每个集合成员都有一个ID，这个ID记录到各自的dataDir目录下的myid文件，这个文件需要手动创建。</p>
<p>echo "1" &gt; /tmp/zookeeper/myid</p>
<p><br></p>
<p><br></p>
<p><strong>3.ZooKeeper监控</strong></p>
<p>监控ZooKeeper有两种方法，一种是使用ZooKeeper自身提供的4个字母的命令查看ZooKeeper的各种状态，另外一种就是使用JMX查看</p>
<p>conf 查看ZooKeeper的配置信息<br></p>
<p>&nbsp; &nbsp;echo conf|nc 127.0.0.1 2181</p>
<p><br></p>
<p>cons 列出连接信息</p>
<p>&nbsp; &nbsp;echo cons|nc 172.28.2.157 2181</p>
<p><br></p>
<p>crst 重置连接/会话数据</p>
<p>&nbsp; &nbsp;echo crst|nc 172.28.2.157 2181</p>
<p><br></p>
<p>dump 列出比较显著的会话和节点。只能在Leader节点上使用</p>
<p>envi 列出环境变量</p>
<p>ruok 测试服务是否正常运行，如果是返回imok，否则不响应</p>
<p>srst 重置服务器状态<br></p>
<p>srvr 列出完整的详细信息</p>
<pre class="brush:plain;toolbar:false">#&nbsp;echo&nbsp;srvr|nc&nbsp;127.0.0.1&nbsp;2181
Zookeeper&nbsp;version:&nbsp;3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
Latency&nbsp;min/avg/max:&nbsp;0/0/0
Received:&nbsp;1
Sent:&nbsp;1
Connections:&nbsp;1
Outstanding:&nbsp;0
Zxid:&nbsp;0x300000025
Mode:&nbsp;leader
Node&nbsp;count:&nbsp;17158</pre>
<p><br></p>
<p>stat 列出服务器的详细信息和连接到的客户端</p>
<p>wchs 列出watches的简洁信息<br></p>
<p>wchc 列出watches的详细信息<br></p>
<p>wchp 列出watches的详细信息，根据路径显示。这个命令可能会影响性能，慎用<br></p>
<p>mntr 列出集群的监控状况<br></p>
<pre class="brush:plain;toolbar:false">echo&nbsp;mntr|nc&nbsp;127.0.0.1&nbsp;2181
zk_version	3.4.6-1569965,&nbsp;built&nbsp;on&nbsp;02/20/2014&nbsp;09:09&nbsp;GMT
zk_avg_latency	0
zk_max_latency	8
zk_min_latency	0
zk_packets_received	10464
zk_packets_sent	10464
zk_num_alive_connections	3
zk_outstanding_requests	0
zk_server_state	leader
zk_znode_count	17159
zk_watch_count	2
zk_ephemerals_count	1
zk_approximate_data_size	6666471
zk_open_file_descriptor_count	32
zk_max_file_descriptor_count	102400
zk_followers	2
zk_synced_followers	2
zk_pending_syncs	0</pre>
<p><br></p>
<p>zk_followers，zk_synced_followers,zk_pending_syncs这几个只有leader角色才会显示</p>
<p><br></p>
<p><strong>4.管理数据文件</strong></p>
<p>ZooKeeper将它的数据存在数据目录下，将事务日志存在日志目录下。在默认的情况下都是存储在dataDir指定的目录下。在实际部署的时候应该将事务日志分开存放可以增加ZooKeeper服务的吞吐量和减小延迟。</p>
<pre class="brush:plain;toolbar:false">#&nbsp;ls&nbsp;-lh&nbsp;/tmp/zookeeper/version-2/
total&nbsp;20M
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;&nbsp;&nbsp;1&nbsp;Feb&nbsp;23&nbsp;21:36&nbsp;acceptedEpoch
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;&nbsp;&nbsp;1&nbsp;Feb&nbsp;23&nbsp;21:36&nbsp;currentEpoch
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;65M&nbsp;Feb&nbsp;18&nbsp;17:39&nbsp;log.1
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;65M&nbsp;Feb&nbsp;23&nbsp;20:30&nbsp;log.100000001
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;65M&nbsp;Feb&nbsp;21&nbsp;17:20&nbsp;log.1cfe
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;65M&nbsp;Feb&nbsp;25&nbsp;15:33&nbsp;log.300000001
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;&nbsp;296&nbsp;Feb&nbsp;16&nbsp;18:26&nbsp;snapshot.0
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;892K&nbsp;Feb&nbsp;18&nbsp;17:42&nbsp;snapshot.1cfd
-rw-r--r--&nbsp;1&nbsp;root&nbsp;root&nbsp;5.4M&nbsp;Feb&nbsp;23&nbsp;15:29&nbsp;snapshot.807d</pre>
<p>每个ZooKeeper服务端都有一个唯一的ID。这个ID用在两个地方，一个是myid文件，另一个是配置文件。</p>
<p>myid文件用来标记本地服务端的ID，在配置文件中ID用来连接其他服务器端。<br></p>
<p><br></p>
<p>snapshot.&lt;zxid&gt; 是ZooKeeper的模糊镜像文件</p>
<p><br></p>
<p><strong>5.需要避免的事情</strong></p>
<p>在部署ZooKeeper的时候需要避免以下几个问题：</p>
<p>&nbsp;<strong>ZooKeeper主机列表不一致</strong></p>
<p>&nbsp; &nbsp;每个ZooKeeper主机的配置文件中的集群主机列表应该一致，连接到ZooKeeper集群的客户端配置的主机列表页应该和ZooKeeper主机配置的列表一致</p>
<p><br></p>
<p>&nbsp;<strong>ZooKeeper的事务日志放错地方</strong></p>
<p>&nbsp; &nbsp;影响ZooKeeper性能最重要的一点就是事务日志。ZooKeeper返回一个响应之前会将事务同步到磁盘上。将事务日志单独存放到一个磁盘上会大大提高ZooKeeper性能。如果将事务日志存放到一个繁忙的磁盘上明显会影响性能。</p>
<p><br></p>
<p><strong>&nbsp;Java Heap大小设置错误</strong></p>
<p>&nbsp; &nbsp;需要特别关注Java Heap大小的设置,ZooKeeper服务器不能有使用SWAP的情况发生。DON'T SWAP</p>
<p>&nbsp; 保守估计的话，如果有4GB内存，那么久不能把Java的Heap大小设置成为6GB或者是4GB。最多设置成3GB左右，因为操作系统需要一些内存作为缓存。最好的就是作下压力测试。<br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">四 ZooKeeper开发相关</span></p>
<p>想要利用ZooKeeper的协同服务来创建分布式应用的开发者需要了解以下以下的信息。</p>
<p><strong>1.ZooKeeper的数据模型</strong></p>
<p>&nbsp;ZooKeeper有一个层级域名空间</p>
<p><br></p>
<p><strong>2.Znodes</strong></p>
<p>&nbsp;ZooKeeper分层域名空间树种的每一个节点都叫做znode。</p>
<p><br></p>
<p><strong>3.Watches</strong></p>
<p>&nbsp;客户端可以在znodes上设置watches。znode有变更就会触发watch然后清理watch。当一个watch被触发，ZooKeeper会发送一个通知给客户端。ZooKeeper所有的读操作都可以设置一个watch。ZooKeeper关于watch的定义是：一个watch事件是个一次性的触发器.</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><span style="color:#7030a0;">参考文档</span></p>
<p><a href="http://zookeeper.apache.org/" target="_blank">http://zookeeper.apache.org/</a> </p>
<p><a href="http://www.us.apache.org/dist/zookeeper/" target="_blank">http://www.us.apache.org/dist/zookeeper/</a> </p>
<p><a href="http://zookeeper.apache.org/doc/r3.4.6/zookeeperOver.html" target="_blank">http://zookeeper.apache.org/doc/r3.4.6/zookeeperOver.html</a> </p>
<p><a href="http://zookeeper.apache.org/doc/r3.4.6/zookeeperProgrammers.html" target="_blank">http://zookeeper.apache.org/doc/r3.4.6/zookeeperProgrammers.html</a> </p>
<p><br></p>
<p><br></p>
<p>本文出自 “<a href="http://john88wang.blog.51cto.com">Linux SA John</a>” 博客，请务必保留此出处<a href="http://john88wang.blog.51cto.com/2165294/1744414">http://john88wang.blog.51cto.com/2165294/1744414</a></p>
