<p><span style="font-size:20px;">1 概述</span></p>
<hr>
<p><span style="font-size:20px;"></span>1.1 Zookeeper简介</p>
<hr>
<p>Zookeeper分布式服务框架是 Apache Hadoop 的一个子项目，它主要是用来解决分布式应用中经常遇到的一些数据管理问题，如：统一命名服务、状态同步服务、集群管理、分布式应用配置项的管理等。ZooKeeper本身可以以Standalone模式安装运行，不过它的长处在于通过分布式ZooKeeper集群（一个Leader，多个Follower），基于一定的策略来保证ZooKeeper集群的稳定性和可用性，从而实现分布式应用的可靠性。Zookeeper 会维护一个具有层次关系的数据结构，它非常类似于一个标准的文件系统，如下图所示</p>
<p><a href="http://s3.51cto.com/wyfs02/M00/22/A1/wKioL1MhpmuinE7pAAD7FXS_J9w722.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" title="image001.gif" alt="wKioL1MhpmuinE7pAAD7FXS_J9w722.jpg" src="http://s3.51cto.com/wyfs02/M00/22/A1/wKioL1MhpmuinE7pAAD7FXS_J9w722.jpg"></a></p>
<p>Zookeeper 这种数据结构有如下这些特点：</p>
<ol class="list-paddingleft-2" type="1">
 <li><p>每个子目录项如 NameService 都被称作为 znode，这个 znode 是被它所在的路径唯一标识，如 Server1 这个 znode 的标识为 /NameService/Server1</p></li>
 <li><p>znode 可以有子节点目录，并且每个 znode 可以存储数据，注意 EPHEMERAL 类型的目录节点不能有子节点目录</p></li>
 <li><p>znode 是有版本的，每个 znode 中存储的数据可以有多个版本，也就是一个访问路径中可以存储多份数据</p></li>
 <li><p>znode 可以是临时节点，一旦创建这个 znode 的客户端与服务器失去联系，这个 znode 也将自动***，Zookeeper 的客户端和服务器通信采用长连接方式，每个客户端和服务器通过心跳来保持连接，这个连接状态称为 session，如果 znode 是临时节点，这个 session 失效，znode 也就***了</p></li>
 <li><p>znode 的目录名可以自动编号，如 App1 已经存在，再创建的话，将会自动命名为 App2</p></li>
 <li><p>znode 可以被监控，包括这个目录节点中存储的数据的修改，子节点目录的变化等，一旦变化可以通知设置监控的客户端，这个是 Zookeeper 的核心特性，Zookeeper 的很多功能都是基于这个特性实现的，后面在典型的应用场景中会有实例介绍</p></li>
</ol>
<p>&nbsp;</p>
<p>1.2 Zookeeper应用示例</p>
<hr>
<p>1 &nbsp;应用场景：</p>
<p>假设我们有一个20个搜索引擎的服务器(每个负责总索引中的一部分的搜索任务)和一个总服务器(负责向这20个搜索引擎的服务器发出搜索请求并合并结果集)，一个备用的总服务器(负责当总服务器宕机时替换总服务器)，一个web的 cgi(向总服务器发出搜索请求)。搜索引擎的服务器中的15个服务器现在提供搜索服务，5个服务器正在生成索引。这20个搜索引擎的服务器经常要让正在提供搜索服务的服务器停止提供服务开始生成索引，或生成索引的服务器已经把索引生成完成可以搜索提供服务了。</p>
<p>&nbsp;</p>
<p>2 Zookeeper应用：</p>
<p><span style="font-size:20px;"></span>使用Zookeeper可以保证总服务器自动感知有多少提供搜索引擎的服务器并向这些服务器发出搜索请求，备用的总服务器宕机时自动启用备用的总服务器，web的cgi能够自动地获知总服务器的网络地址变化。</p>
<p>&nbsp;</p>
<p>3 具体实现：</p>
<ol class="list-paddingleft-2">
 <li><p>提供搜索引擎的服务器都在Zookeeper中创建znode：zk.create("/search/nodes/node1",<br>"hostname".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateFlags.<strong>EPHEMERAL</strong>)；</p><p>&nbsp;</p></li>
 <li><p>总服务器可以从Zookeeper中获取一个znode的子节点的列表，zk.getChildren("/search/nodes", true)；</p><p>&nbsp;</p></li>
 <li><p>总服务器遍历这些子节点，并获取子节点的数据生成提供搜索引擎的服务器列表；</p><p>&nbsp;</p></li>
 <li><p>当总服务器接收到子节点改变的事件信息,重新返回第二步；</p><p>&nbsp;</p></li>
 <li><p>总服务器在Zookeeper中创建节点，zk.create("/search/master", "hostname".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateFlags.EPHEMERAL)；</p><p>&nbsp;</p></li>
 <li><p>备用的总服务器监控Zookeeper中的"/search/master"节点，当这个znode的节点数据改变时，把自己启动变成总服务器，并把自己的网络地址数据放进这个节点；</p><p>&nbsp;</p></li>
 <li><p>web的cgi从Zookeeper中"/search/master"节点获取总服务器的网络地址数据并向其发送搜索请求；</p><p>&nbsp;</p></li>
 <li><p>web的cgi监控Zookeeper中的"/search/master"节点，当这个znode的节点数据改变时，从这个节点获取总服务器的网络地址数据，并改变当前的总服务器的网络地址。</p><p>&nbsp;</p></li>
</ol>
<p>3 测试：</p>
<p>一个Zookeeper的集群中，3个Zookeeper节点。一个leader，两个follower的情况下，停掉leader，然后两个follower选举出一个leader。获取的数据不变。Zookeeper能够帮助Hadoop做到：</p>
<p>Hadoop，使用Zookeeper的事件处理确保整个集群只有一个NameNode，存储配置信息等。<br>HBase，使用Zookeeper的事件处理确保整个集群只有一个HMaster，察觉HRegionServer联机和宕机，存储访问控制列表等。</p>
<p>&nbsp;</p>
<p><span style="font-size:20px;">2 环境部署</span></p>
<hr>
<p>此次Zookeeper集群的部署基于前一篇文章所部署的Hadoop集群，集群配置如下：</p>
<p>zookeeper1 &nbsp; &nbsp;rango &nbsp; &nbsp;192.168.56.1</p>
<p>zookeeper2 &nbsp; &nbsp;vm2 &nbsp; &nbsp;192.168.56.102</p>
<p>zookeeper3 &nbsp; &nbsp;vm3 &nbsp; &nbsp;192.168.56.103</p>
<p>zookeeper4 &nbsp; &nbsp;vm4 &nbsp; &nbsp;192.168.56.104</p>
<p>zookeeper5 &nbsp; &nbsp;vm1 &nbsp; &nbsp;192.168.56.101</p>
<p></p>
<p><span style="font-size:20px;">3 安装和配置</span></p>
<hr>
<p><span style="font-size:20px;"></span>3.1 下载安装Zookeeper</p>
<hr>
<p>从Apache官网下载最新的Zookeeper版本，解压到/usr目录,并重命名为zookeeper：</p>
<p>tar zxvf zookeeper-3.4.5.tar.gz ；mv zookeeper-3.4.5 /usr/zookeeper</p>
<p>设置zookeeper目录的所有者为hadoop:hadoop:</p>
<p>chown -R hadoop:hadoop /usr/zookeeper</p>
<p>ps:可先在master机器上进行安装和配置，然后通过scp命令复制到集群其他节点上：</p>
<p>scp -R /usr/zookeeper 节点ip：/usr<br></p>
<p></p>
<p>3.2 配置Zookeeper</p>
<hr>
<p>3.2.1 创建数据目录</p>
<hr>
<p>在集群所有机器上执行：</p>
<p>mkdir /var/lib/zookeeper</p>
<p></p>
<p>3.2.2 配置环境变量</p>
<hr>
<p>vim /etc/profile：</p>
<p># set zookeeper path<br>export ZOOKEEPER_HOME=/usr/zookeeper<br>export PATH=$PATH:$ZOOKEEPER_HOME/bin</p>
<p></p>
<p>3.2.3 配置Zookeeper集群</p>
<hr>
<p>cp /usr/zookeeper/conf/zoo_sample.cfg zoo.cfg</p>
<p>vim zoo.cfg:</p>
<p># The number of milliseconds of each tick<br>tickTime=2000<br># The number of ticks that the initial <br># synchronization phase can take<br>initLimit=10<br># The number of ticks that can pass between <br># sending a request and getting an acknowledgement<br>syncLimit=5<br># the directory where the snapshot is stored.<br># do not use /tmp for storage, /tmp here is just <br># example sakes.<br>dataDir=/var/lib/zookeeper<br># the port at which the clients will connect<br>clientPort=2181<br>#<br># Be sure to read the maintenance section of the <br># administrator guide before turning on autopurge.<br>#<br># http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance<br>#<br># The number of snapshots to retain in dataDir<br>#autopurge.snapRetainCount=3<br># Purge task interval in hours<br># Set to "0" to disable auto purge feature<br>#autopurge.purgeInterval=1<br><br>server.1=192.168.56.1:2888:3888<br>server.2=192.168.56.102:2888:3888<br>server.3=192.168.56.103:2888:3888<br>server.4=192.168.56.104:2888:3888<br>server.5=192.168.56.101:2888:3888</p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">注解：</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">tickTime：发送心跳时间间隔，单位毫秒</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">initlimit和sysncLimit：两者都是以ticktime的总数进行度量(上面的时间为10*2000=20s)。initLimit参数设定了允许所有跟随者与领导者进行连接并同步的时间，如果在设定的时间内内，半数以上的跟随者未能完成同步，领导者便会宣布放弃领导地位，然后进行另外一次领导 者选举。如果这种情况经常发生，通过查看日志中的记录发现，则表明设定的值太小。</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">syscLimit参数设定了允许一个跟随者与领导者进行同步的时间。如果在设定的时间内，一个跟随者未能完成同步，它将会自己重启，所有关联到这个跟随者的客户端将连接到另外一个跟随者。</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">dataDir：保存的zookeeperk中持久化的数据，zk中存在两种数据，一种用完即消失，一种需要持久存在，zk的日志也保存在这。</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</span></p>
<p><br><span style="font-family:arial, helvetica, sans-serif;font-size:16px;"></span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">在每个服务器的数据目录中创建myid文件，文件的内容为以上对应的server.id中的id:</span></p>
<p><span style="font-family:arial, helvetica, sans-serif;font-size:16px;">echo id &gt;&gt; /var/lib/zookeeper/myid</span></p>
<p></p>
<p>3.3 启动和停止Zookeeper服务</p>
<hr>
<p>在集群所有节点上启动Zookeeper：zkServer.sh start</p>
<p>[root@rango ~]# zkServer.sh start<br>JMX enabled by default<br>Using config: /usr/zookeeper/bin/../conf/zoo.cfg<br>Starting zookeeper ... STARTED</p>
<p>查看：zkserver.sh starus:</p>
<p>[root@rango ~]# zkServer.sh status<br>JMX enabled by default<br>Using config: /usr/zookeeper/bin/../conf/zoo.cfg<br>Mode: follower</p>
<p>ps：启动之前需关闭iptables（内网）<br></p>
<p></p>
<p><span style="font-size:20px;">4 应用场景</span></p>
<hr>
<p>Zookeeper 从设计模式角度来看，是一个基于观察者模式设计的分布式服务管理框架，它负责存储和管理大家都关心的数据，然后接受观察者的注册，一旦这些数据的状态发生变化，Zookeeper 就将负责通知已经在 Zookeeper 上注册的那些观察者做出相应的反应，从而实现集群中类似 Master/Slave 管理模式，关于 Zookeeper 的详细架构等内部细节可以阅读 Zookeeper 的源码。</p>
<p>下面详细介绍这些典型的应用场景，也就是 Zookeeper 到底能帮我们解决那些问题？</p>
<hr>
<h3 id="minor3.1">统一命名服务（Name Service）</h3>
<p>分布式应用中，通常需要有一套完整的命名规则，既能够产生唯一的名称又便于人识别和记住，通常情况下用树形的名称结构是一个理想的选择，树形的名称结构是一个有层次的目录结构，既对人友好又不会重复。说到这里你可能想到了 JNDI，没错 Zookeeper 的 Name Service 与 JNDI 能够完成的功能是差不多的，它们都是将有层次的目录结构关联到一定资源上，但是 Zookeeper 的 Name Service 更加是广泛意义上的关联，也许你并不需要将名称关联到特定资源上，你可能只需要一个不会重复名称，就像数据库中产生一个唯一的数字主键一样。</p>
<p>Name Service 已经是 Zookeeper 内置的功能，你只要调用 Zookeeper 的 API 就能实现。如调用 create 接口就可以很容易创建一个目录节点。</p>
<h3 id="minor3.2">配置管理（Configuration Management）</h3>
<p>配置的管理在分布式应用环境中很常见，例如同一个应用系统需要多台 PC Server 运行，但是它们运行的应用系统的某些配置项是相同的，如果要修改这些相同的配置项，那么就必须同时修改每台运行这个应用系统的 PC Server，这样非常麻烦而且容易出错。</p>
<p>像这样的配置信息完全可以交给 Zookeeper 来管理，将配置信息保存在 Zookeeper 的某个目录节点中，然后将所有需要修改的应用机器监控配置信息的状态，一旦配置信息发生变化，每台应用机器就会收到 Zookeeper 的通知，然后从 Zookeeper 获取新的配置信息应用到系统中。如下为配置结构管理图，</p>
<p><img onload="if(this.width>650) this.width=650;" alt="图 2. 配置管理结构图" src="http://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/image002.gif" width="529"></p>
<p></p>
<h3 id="minor3.3">集群管理（Group Membership）</h3>
<p>Zookeeper 能够很容易的实现集群管理的功能，如有多台 Server 组成一个服务集群，那么必须要一个“总管”知道当前集群中每台机器的服务状态，一旦有机器不能提供服务，集群中其它集群必须知道，从而做出调整重新分配服务策略。同样当增加集群的服务能力时，就会增加一台或多台 Server，同样也必须让“总管”知道。</p>
<p>Zookeeper 不仅能够帮你维护当前的集群中机器的服务状态，而且能够帮你选出一个“总管”，让这个总管来管理集群，这就是 Zookeeper 的另一个功能 Leader Election。</p>
<p>它们的实现方式都是在 Zookeeper 上创建一个 EPHEMERAL 类型的目录节点，然后每个 Server 在它们创建目录节点的父目录节点上调用 getChildren(String path, boolean watch) 方法并设置 watch 为 true，由于是 EPHEMERAL 目录节点，当创建它的 Server 死去，这个目录节点也随之被***，所以 Children 将会变化，这时 getChildren上的 Watch 将会被调用，所以其它 Server 就知道已经有某台 Server 死去了。新增 Server 也是同样的原理。</p>
<p>Zookeeper 如何实现 Leader Election，也就是选出一个 Master Server。和前面的一样每台 Server 创建一个 EPHEMERAL 目录节点，不同的是它还是一个 SEQUENTIAL 目录节点，所以它是个 EPHEMERAL_SEQUENTIAL 目录节点。之所以它是 EPHEMERAL_SEQUENTIAL 目录节点，是因为我们可以给每台 Server 编号，我们可以选择当前是最小编号的 Server 为 Master，假如这个最小编号的 Server 死去，由于是 EPHEMERAL 节点，死去的 Server 对应的节点也被***，所以当前的节点列表中又出现一个最小编号的节点，我们就选择这个节点为当前 Master。这样就实现了动态选择 Master，避免了传统意义上单 Master 容易出现单点故障的问题。如下为集群管理结构图，</p>
<p><img onload="if(this.width>650) this.width=650;" alt="图 3. 集群管理结构图" src="http://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/image003.gif" width="529"></p>
<p></p>
<h3 id="minor3.4">共享锁（Locks）</h3>
<p>共享锁在同一个进程中很容易实现，但是在跨进程或者在不同 Server 之间就不好实现了。Zookeeper 却很容易实现这个功能，实现方式也是需要获得锁的 Server 创建一个 EPHEMERAL_SEQUENTIAL 目录节点，然后调用 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#getChildren%28java.lang.String,%20boolean%29" target="_blank">getChildren</a>方法获取当前的目录节点列表中最小的目录节点是不是就是自己创建的目录节点，如果正是自己创建的，那么它就获得了这个锁，如果不是那么它就调用 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#exists%28java.lang.String,%20boolean%29" target="_blank">exists</a>(<a href="http://java.sun.com/javase/6/docs/api/java/lang/String.html?is-external=true" target="_blank">String</a> path, boolean watch) 方法并监控 Zookeeper 上目录节点列表的变化，一直到自己创建的节点是列表中最小编号的目录节点，从而获得锁，释放锁很简单，只要***前面它自己所创建的目录节点就行了。实现锁流程图，</p>
<p><img onload="if(this.width>650) this.width=650;" alt="图 4. Zookeeper 实现 Locks 的流程图" src="http://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/image004.gif" width="442"></p>
<h3 id="minor3.5">队列管理</h3>
<p>Zookeeper 可以处理两种类型的队列：</p>
<ol class="list-paddingleft-2" type="1">
 <li><p>当一个队列的成员都聚齐时，这个队列才可用，否则一直等待所有成员到达，这种是同步队列。</p></li>
 <li><p>队列按照 FIFO 方式进行入队和出队操作，例如实现生产者和消费者模型。</p></li>
</ol>
<p>同步队列用 Zookeeper 实现的实现思路如下：</p>
<p>创建一个父目录 /synchronizing，每个成员都监控标志（Set Watch）位目录 /synchronizing/start 是否存在，然后每个成员都加入这个队列，加入队列的方式就是创建 /synchronizing/member_i 的临时目录节点，然后每个成员获取 / synchronizing 目录的所有目录节点，也就是 member_i。判断 i 的值是否已经是成员的个数，如果小于成员个数等待 /synchronizing/start 的出现，如果已经相等就创建 /synchronizing/start。</p>
<p>用下面的流程图更容易理解：</p>
<p><img onload="if(this.width>650) this.width=650;" alt="图 5. 同步队列流程图" src="http://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/image005.gif" width="465"></p>
<p></p>
<p><span style="font-size:20px;">5 总结</span></p>
<hr>
<p><span style="font-size:20px;"></span>本文介绍的 Zookeeper 的基本知识，以及介绍了几个典型的应用场景。这些都是 Zookeeper 的基本功能，最重要的是 Zoopkeeper 提供了一套很好的分布式集群管理的机制，就是它这种基于层次型的目录树的数据结构，并对树中的节点进行有效管理，从而可以设计出多种多样的分布式的数据管理模型，而不仅仅局限于上面提到的几个常用应用场景。后续将会介绍HBase分布式安装、Chukwa集群安装等。</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;――RangoChen</p>
<hr>
<p></p>
<p>本文出自 “<a href="http://rangochen.blog.51cto.com">游响云停</a>” 博客，请务必保留此出处<a href="http://rangochen.blog.51cto.com/2445286/1376115">http://rangochen.blog.51cto.com/2445286/1376115</a></p>
