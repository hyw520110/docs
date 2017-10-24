<p>转自 <a href="https://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/" target="_blank">https://www.ibm.com/developerworks/cn/opensource/os-cn-zookeeper/</a><br></p>
<h2 id="major1">安装和配置详解</h2>
<p>windows启动脚本：bin/zkServer.cmd</p>
<p>linux启动脚本：bin/zkServer.sh</p>
<p><br></p>
<p>在你执行启动脚本之前，还有几个基本的配置项需要配置一下，Zookeeper 的配置文件在 conf 目录下，这个目录下有 zoo_sample.cfg 和 log4j.properties，你需要做的就是将 zoo_sample.cfg 改名为 zoo.cfg，因为 Zookeeper 在启动时会找这个文件作为默认配置文件。下面详细介绍一下，这个配置文件中各个配置项的意义。</p>
<pre class="displaycode">&nbsp;tickTime=2000&nbsp;
&nbsp;dataDir=/tmp/zookeeper
&nbsp;clientPort=2181</pre>
<ul class="ibm-bullet-list list-paddingleft-2">
 <li><p>tickTime：这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。</p></li>
 <li><p>dataDir：顾名思义就是 Zookeeper 保存数据的目录，默认情况下，Zookeeper 将写数据的日志文件也保存在这个目录里。</p></li>
 <li><p>clientPort：这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。</p></li>
</ul>
<p>当这些配置项配置好后，你现在就可以启动 Zookeeper 了，启动后要检查 Zookeeper 是否已经在服务，可以通过 netstat &#xfffd; ano 命令查看是否有你配置的 clientPort 端口号在监听服务。</p>
<h3 id="minor1.2">集群模式</h3>
<p>Zookeeper 不仅可以单机提供服务，同时也支持多机组成集群来提供服务。实际上 Zookeeper 还支持另外一种伪集群的方式，也就是可以在一台物理机上运行多个 Zookeeper 实例，下面将介绍集群模式的安装和配置。</p>
<p>Zookeeper 的集群模式的安装和配置也不是很复杂，所要做的就是增加几个配置项。集群模式除了上面的三个配置项还要增加下面几个配置项：</p>
<pre class="displaycode">&nbsp;initLimit=5&nbsp;
&nbsp;syncLimit=2&nbsp;
&nbsp;server.1=192.168.211.1:2888:3888&nbsp;
&nbsp;server.2=192.168.211.2:2888:3888</pre>
<ul class="ibm-bullet-list list-paddingleft-2">
 <li><p>initLimit：这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 10 个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒</p></li>
 <li><p>syncLimit：这个配置项标识 Leader 与 Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是 2*2000=4 秒</p></li>
 <li><p>server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</p></li>
</ul>
<p>除了修改 zoo.cfg 配置文件，集群模式下还要配置一个文件 myid，这个文件在 dataDir 目录下，这个文件里面就有一个数据就是 A 的值，Zookeeper 启动时会读取这个文件，拿到里面的数据与 zoo.cfg 里面的配置信息比较从而判断到底是那个 server。</p>
<p><br></p>
<h3 id="minor1.3">数据模型</h3>
<p>Zookeeper 会维护一个具有层次关系的数据结构，它非常类似于一个标准的文件系统，如图 1 所示：</p>
<h5 id="fig1">图 1 Zookeeper 数据结构</h5>
<p><a href="http://s3.51cto.com/wyfs02/M01/4C/D0/wKioL1RFuTfj6MToAAA8jabB5YI371.gif" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/4C/D0/wKioL1RFuTfj6MToAAA8jabB5YI371.gif" title="image001.gif" alt="wKioL1RFuTfj6MToAAA8jabB5YI371.gif"></a></p>
<p>Zookeeper 这种数据结构有如下这些特点：</p>
<ol class="list-paddingleft-2" type="1">
 <li><p>每个子目录项如 NameService 都被称作为 znode，这个 znode 是被它所在的路径唯一标识，如 Server1 这个 znode 的标识为 /NameService/Server1</p></li>
 <li><p>znode 可以有子节点目录，并且每个 znode 可以存储数据，注意 EPHEMERAL 类型的目录节点不能有子节点目录</p></li>
 <li><p>znode 是有版本的，每个 znode 中存储的数据可以有多个版本，也就是一个访问路径中可以存储多份数据</p></li>
 <li><p>znode 可以是临时节点，一旦创建这个 znode 的客户端与服务器失去联系，这个 znode 也将自动删除，Zookeeper 的客户端和服务器通信采用长连接方式，每个客户端和服务器通过心跳来保持连接，这个连接状态称为 session，如果 znode 是临时节点，这个 session 失效，znode 也就删除了</p></li>
 <li><p>znode 的目录名可以自动编号，如 App1 已经存在，再创建的话，将会自动命名为 App2</p></li>
 <li><p>znode 可以被监控，包括这个目录节点中存储的数据的修改，子节点目录的变化等，一旦变化可以通知设置监控的客户端，这个是 Zookeeper 的核心特性，Zookeeper 的很多功能都是基于这个特性实现的，后面在典型的应用场景中会有实例介绍</p></li>
</ol>
<h2 id="major2">如何使用</h2>
<p>Zookeeper 作为一个分布式的服务框架，主要用来解决分布式集群中应用系统的一致性问题，它能提供基于类似于文件系统的目录节点树方式的数据存储，但是 Zookeeper 并不是用来专门存储数据的，它的作用主要是用来维护和监控你存储的数据的状态变化。通过监控这些数据状态的变化，从而可以达到基于数据的集群管理，后面将 会详细介绍 Zookeeper 能够解决的一些典型问题，这里先介绍一下，Zookeeper 的操作接口和简单使用示例。</p>
<h3 id="minor2.2">基本操作</h3>
<p>下面给出基本的操作 ZooKeeper 的示例代码，这样你就能对 ZooKeeper 有直观的认识了。下面的清单包括了创建与 ZooKeeper 服务器的连接以及最基本的数据操作：</p>
<h5 id="listing2">清单 2. ZooKeeper 基本的操作示例</h5>
<pre class="displaycode">&nbsp;//&nbsp;创建一个与服务器的连接
&nbsp;ZooKeeper&nbsp;zk&nbsp;=&nbsp;new&nbsp;ZooKeeper("localhost:"&nbsp;+&nbsp;CLIENT_PORT,&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ClientBase.CONNECTION_TIMEOUT,&nbsp;new&nbsp;Watcher()&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//&nbsp;监控所有被触发的事件
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("已经触发了"&nbsp;+&nbsp;event.getType()&nbsp;+&nbsp;"事件！");&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;});&nbsp;
&nbsp;//&nbsp;创建一个目录节点
&nbsp;zk.create("/testRootPath",&nbsp;"testRootData".getBytes(),&nbsp;Ids.OPEN_ACL_UNSAFE,
&nbsp;&nbsp;&nbsp;CreateMode.PERSISTENT);&nbsp;
&nbsp;//&nbsp;创建一个子目录节点
&nbsp;zk.create("/testRootPath/testChildPathOne",&nbsp;"testChildDataOne".getBytes(),
&nbsp;&nbsp;&nbsp;Ids.OPEN_ACL_UNSAFE,CreateMode.PERSISTENT);&nbsp;
&nbsp;System.out.println(new&nbsp;String(zk.getData("/testRootPath",false,null)));&nbsp;
&nbsp;//&nbsp;取出子目录节点列表
&nbsp;System.out.println(zk.getChildren("/testRootPath",true));&nbsp;
&nbsp;//&nbsp;修改子目录节点数据
&nbsp;zk.setData("/testRootPath/testChildPathOne","modifyChildDataOne".getBytes(),-1);&nbsp;
&nbsp;System.out.println("目录节点状态：["+zk.exists("/testRootPath",true)+"]");&nbsp;
&nbsp;//&nbsp;创建另外一个子目录节点
&nbsp;zk.create("/testRootPath/testChildPathTwo",&nbsp;"testChildDataTwo".getBytes(),&nbsp;
&nbsp;&nbsp;&nbsp;Ids.OPEN_ACL_UNSAFE,CreateMode.PERSISTENT);&nbsp;
&nbsp;System.out.println(new&nbsp;String(zk.getData("/testRootPath/testChildPathTwo",true,null)));&nbsp;
&nbsp;//&nbsp;删除子目录节点
&nbsp;zk.delete("/testRootPath/testChildPathTwo",-1);&nbsp;
&nbsp;zk.delete("/testRootPath/testChildPathOne",-1);&nbsp;
&nbsp;//&nbsp;删除父目录节点
&nbsp;zk.delete("/testRootPath",-1);&nbsp;
&nbsp;//&nbsp;关闭连接
&nbsp;zk.close();</pre>
<p>输出的结果如下：</p>
<pre class="displaycode">已经触发了&nbsp;None&nbsp;事件！
&nbsp;testRootData&nbsp;
&nbsp;[testChildPathOne]&nbsp;
目录节点状态：[5,5,1281804532336,1281804532336,0,1,0,0,12,1,6]&nbsp;
已经触发了&nbsp;NodeChildrenChanged&nbsp;事件！
&nbsp;testChildDataTwo&nbsp;
已经触发了&nbsp;NodeDeleted&nbsp;事件！
已经触发了&nbsp;NodeDeleted&nbsp;事件！</pre>
<p>当对目录节点监控状态打开时，一旦目录节点的状态发生变化，Watcher 对象的 process 方法就会被调用。</p>
<h2 id="major3">ZooKeeper 典型的应用场景</h2>
<p>Zookeeper 从设计模式角度来看，是一个基于观察者模式设计的分布式服务管理框架，它负责存储和管理大家都关心的数据，然后接受观察者的注册，一旦这些数据的状态发生 变化，Zookeeper 就将负责通知已经在 Zookeeper 上注册的那些观察者做出相应的反应，从而实现集群中类似 Master/Slave 管理模式，关于 Zookeeper 的详细架构等内部细节可以阅读 Zookeeper 的源码</p>
<p>下面详细介绍这些典型的应用场景，也就是 Zookeeper 到底能帮我们解决那些问题？下面将给出答案。</p>
<h3 id="minor3.1">统一命名服务（Name Service）</h3>
<p>分 布式应用中，通常需要有一套完整的命名规则，既能够产生唯一的名称又便于人识别和记住，通常情况下用树形的名称结构是一个理想的选择，树形的名称结构是一 个有层次的目录结构，既对人友好又不会重复。说到这里你可能想到了 JNDI，没错 Zookeeper 的 Name Service 与 JNDI 能够完成的功能是差不多的，它们都是将有层次的目录结构关联到一定资源上，但是 Zookeeper 的 Name Service 更加是广泛意义上的关联，也许你并不需要将名称关联到特定资源上，你可能只需要一个不会重复名称，就像数据库中产生一个唯一的数字主键一样。</p>
<p>Name Service 已经是 Zookeeper 内置的功能，你只要调用 Zookeeper 的 API 就能实现。如调用 create 接口就可以很容易创建一个目录节点。</p>
<h3 id="minor3.2">配置管理（Configuration Management）</h3>
<p>配置的管理在分布式应用环境中很常见，例如同一个应用系统需要多台 PC Server 运行，但是它们运行的应用系统的某些配置项是相同的，如果要修改这些相同的配置项，那么就必须同时修改每台运行这个应用系统的 PC Server，这样非常麻烦而且容易出错。</p>
<p>像 这样的配置信息完全可以交给 Zookeeper 来管理，将配置信息保存在 Zookeeper 的某个目录节点中，然后将所有需要修改的应用机器监控配置信息的状态，一旦配置信息发生变化，每台应用机器就会收到 Zookeeper 的通知，然后从 Zookeeper 获取新的配置信息应用到系统中。</p>
<h5 id="fig2">图 2. 配置管理结构图</h5>
<p style="text-align:center;"><a href="http://s3.51cto.com/wyfs02/M01/4C/CF/wKiom1RFuraxUOq2AAA0675oiFA112.gif" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/4C/CF/wKiom1RFuraxUOq2AAA0675oiFA112.gif" title="image002.gif" alt="wKiom1RFuraxUOq2AAA0675oiFA112.gif"></a></p>
<h3 id="minor3.3">集群管理（Group Membership）</h3>
<p>Zookeeper 能够很容易的实现集群管理的功能，如有多台 Server 组成一个服务集群，那么必须要一个“总管”知道当前集群中每台机器的服务状态，一旦有机器不能提供服务，集群中其它集群必须知道，从而做出调整重新分配服 务策略。同样当增加集群的服务能力时，就会增加一台或多台 Server，同样也必须让“总管”知道。</p>
<p>Zookeeper 不仅能够帮你维护当前的集群中机器的服务状态，而且能够帮你选出一个“总管”，让这个总管来管理集群，这就是 Zookeeper 的另一个功能 Leader Election。</p>
<p>它们的实现方式都是在 Zookeeper 上创建一个 EPHEMERAL 类型的目录节点，然后每个 Server 在它们创建目录节点的父目录节点上调用 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#getChildren%28java.lang.String,%20boolean%29" target="_blank">getChildren</a>(<a href="http://java.sun.com/javase/6/docs/api/java/lang/String.html?is-external=true" target="_blank">String</a>&nbsp;path, boolean&nbsp;watch) 方法并设置 watch 为 true，由于是 EPHEMERAL 目录节点，当创建它的 Server 死去，这个目录节点也随之被删除，所以 Children 将会变化，这时 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#getChildren%28java.lang.String,%20boolean%29" target="_blank">getChildren</a>上的 Watch 将会被调用，所以其它 Server 就知道已经有某台 Server 死去了。新增 Server 也是同样的原理。</p>
<p>Zookeeper 如何实现 Leader Election，也就是选出一个 Master Server。和前面的一样每台 Server 创建一个 EPHEMERAL 目录节点，不同的是它还是一个 SEQUENTIAL 目录节点，所以它是个 EPHEMERAL_SEQUENTIAL 目录节点。之所以它是 EPHEMERAL_SEQUENTIAL 目录节点，是因为我们可以给每台 Server 编号，我们可以选择当前是最小编号的 Server 为 Master，假如这个最小编号的 Server 死去，由于是 EPHEMERAL 节点，死去的 Server 对应的节点也被删除，所以当前的节点列表中又出现一个最小编号的节点，我们就选择这个节点为当前 Master。这样就实现了动态选择 Master，避免了传统意义上单 Master 容易出现单点故障的问题。</p>
<h5 id="fig3">图 3. 集群管理结构图</h5>
<p style="text-align:center;"><a href="http://s3.51cto.com/wyfs02/M00/4C/CF/wKiom1RFuuzx1nyfAAAq_v6lY6Y737.gif" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/4C/CF/wKiom1RFuuzx1nyfAAAq_v6lY6Y737.gif" title="image003.gif" alt="wKiom1RFuuzx1nyfAAAq_v6lY6Y737.gif"></a></p>
<p>这部分的示例代码如下，完整的代码请看附件：</p>
<h5 id="listing3">清单 3. Leader Election 关键代码</h5>
<pre class="displaycode">&nbsp;void&nbsp;findLeader()&nbsp;throws&nbsp;InterruptedException&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;leader&nbsp;=&nbsp;null;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;leader&nbsp;=&nbsp;zk.getData(root&nbsp;+&nbsp;"/leader",&nbsp;true,&nbsp;null);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;catch&nbsp;(Exception&nbsp;e)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;logger.error(e);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(leader&nbsp;!=&nbsp;null)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;following();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;newLeader&nbsp;=&nbsp;null;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;localhost&nbsp;=&nbsp;InetAddress.getLocalHost().getAddress();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;newLeader&nbsp;=&nbsp;zk.create(root&nbsp;+&nbsp;"/leader",&nbsp;localhost,&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZooDefs.Ids.OPEN_ACL_UNSAFE,&nbsp;CreateMode.EPHEMERAL);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;catch&nbsp;(Exception&nbsp;e)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;logger.error(e);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(newLeader&nbsp;!=&nbsp;null)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;leading();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mutex.wait();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;}</pre>
<h3 id="minor3.4">共享锁（Locks）</h3>
<p>共享锁在同一个进程中很容易实现，但是在跨进程或者在不同 Server 之间就不好实现了。Zookeeper 却很容易实现这个功能，实现方式也是需要获得锁的 Server 创建一个 EPHEMERAL_SEQUENTIAL 目录节点，然后调用 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#getChildren%28java.lang.String,%20boolean%29" target="_blank">getChildren</a>方法获取当前的目录节点列表中最小的目录节点是不是就是自己创建的目录节点，如果正是自己创建的，那么它就获得了这个锁，如果不是那么它就调用 <a href="http://hadoop.apache.org/zookeeper/docs/r3.2.2/api/org/apache/zookeeper/ZooKeeper.html#exists%28java.lang.String,%20boolean%29" target="_blank">exists</a>(<a href="http://java.sun.com/javase/6/docs/api/java/lang/String.html?is-external=true" target="_blank">String</a>&nbsp;path, boolean&nbsp;watch) 方法并监控 Zookeeper 上目录节点列表的变化，一直到自己创建的节点是列表中最小编号的目录节点，从而获得锁，释放锁很简单，只要删除前面它自己所创建的目录节点就行了。</p>
<h5 id="fig4">图 4. Zookeeper 实现 Locks 的流程图</h5>
<p style="text-align:center;"><a href="http://s3.51cto.com/wyfs02/M01/4C/CF/wKiom1RFuwqyuaExAAA3GPj19k0055.gif" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/4C/CF/wKiom1RFuwqyuaExAAA3GPj19k0055.gif" title="image004.gif" alt="wKiom1RFuwqyuaExAAA3GPj19k0055.gif"></a></p>
<p>同步锁的实现代码如下，完整的代码请看附件：</p>
<h5 id="listing4">清单 4. 同步锁的关键代码</h5>
<pre class="displaycode">&nbsp;void&nbsp;getLock()&nbsp;throws&nbsp;KeeperException,&nbsp;InterruptedException{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;List&lt;String&gt;&nbsp;list&nbsp;=&nbsp;zk.getChildren(root,&nbsp;false);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String[]&nbsp;nodes&nbsp;=&nbsp;list.toArray(new&nbsp;String[list.size()]);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Arrays.sort(nodes);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(myZnode.equals(root+"/"+nodes[0])){&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;doAction();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;else{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;waitForLock(nodes[0]);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;void&nbsp;waitForLock(String&nbsp;lower)&nbsp;throws&nbsp;InterruptedException,&nbsp;KeeperException&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stat&nbsp;stat&nbsp;=&nbsp;zk.exists(root&nbsp;+&nbsp;"/"&nbsp;+&nbsp;lower,true);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(stat&nbsp;!=&nbsp;null){&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mutex.wait();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;else{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;getLock();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;}</pre>
<h3 id="minor3.5">队列管理</h3>
<p>Zookeeper 可以处理两种类型的队列：</p>
<ol class="list-paddingleft-2" type="1">
 <li><p>当一个队列的成员都聚齐时，这个队列才可用，否则一直等待所有成员到达，这种是同步队列。</p></li>
 <li><p>队列按照 FIFO 方式进行入队和出队操作，例如实现生产者和消费者模型。</p></li>
</ol>
<p>同步队列用 Zookeeper 实现的实现思路如下：</p>
<p>创 建一个父目录 /synchronizing，每个成员都监控标志（Set Watch）位目录 /synchronizing/start 是否存在，然后每个成员都加入这个队列，加入队列的方式就是创建 /synchronizing/member_i 的临时目录节点，然后每个成员获取 / synchronizing 目录的所有目录节点，也就是 member_i。判断 i 的值是否已经是成员的个数，如果小于成员个数等待 /synchronizing/start 的出现，如果已经相等就创建 /synchronizing/start。</p>
<p>用下面的流程图更容易理解：</p>
<h5 id="fig5">图 5. 同步队列流程图</h5>
<p style="text-align:center;"><a href="http://s3.51cto.com/wyfs02/M02/4C/CF/wKiom1RFuzPCCQ4bAAAv2J4WEdM731.gif" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/4C/CF/wKiom1RFuzPCCQ4bAAAv2J4WEdM731.gif" title="image005.gif" alt="wKiom1RFuzPCCQ4bAAAv2J4WEdM731.gif"></a></p>
<p>同步队列的关键代码如下，完整的代码请看附件：</p>
<h5 id="listing5">清单 5. 同步队列</h5>
<pre class="displaycode">&nbsp;void&nbsp;addQueue()&nbsp;throws&nbsp;KeeperException,&nbsp;InterruptedException{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.exists(root&nbsp;+&nbsp;"/start",true);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.create(root&nbsp;+&nbsp;"/"&nbsp;+&nbsp;name,&nbsp;new&nbsp;byte[0],&nbsp;Ids.OPEN_ACL_UNSAFE,&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CreateMode.EPHEMERAL_SEQUENTIAL);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;synchronized&nbsp;(mutex)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;List&lt;String&gt;&nbsp;list&nbsp;=&nbsp;zk.getChildren(root,&nbsp;false);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(list.size()&nbsp;&lt;&nbsp;size)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mutex.wait();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.create(root&nbsp;+&nbsp;"/start",&nbsp;new&nbsp;byte[0],&nbsp;Ids.OPEN_ACL_UNSAFE,
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CreateMode.PERSISTENT);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;}</pre>
<p>当队列没满是进入 wait()，然后会一直等待 Watch 的通知，Watch 的代码如下：</p>
<pre class="displaycode">&nbsp;public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(event.getPath().equals(root&nbsp;+&nbsp;"/start")&nbsp;&amp;&amp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;event.getType()&nbsp;==&nbsp;Event.EventType.NodeCreated){&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("得到通知");&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;super.process(event);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;doAction();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;}</pre>
<p>FIFO 队列用 Zookeeper 实现思路如下：</p>
<p>实现的思路也非常简单，就是在特定的目录 下创建 SEQUENTIAL 类型的子目录 /queue_i，这样就能保证所有成员加入队列时都是有编号的，出队列时通过 getChildren( ) 方法可以返回当前所有的队列中的元素，然后消费其中最小的一个，这样就能保证 FIFO。</p>
<p>下面是生产者和消费者这种队列形式的示例代码，完整的代码请看附件：</p>
<h5 id="listing6">清单 6. 生产者代码</h5>
<pre class="displaycode">&nbsp;boolean&nbsp;produce(int&nbsp;i)&nbsp;throws&nbsp;KeeperException,&nbsp;InterruptedException{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ByteBuffer&nbsp;b&nbsp;=&nbsp;ByteBuffer.allocate(4);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;value;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b.putInt(i);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value&nbsp;=&nbsp;b.array();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.create(root&nbsp;+&nbsp;"/element",&nbsp;value,&nbsp;ZooDefs.Ids.OPEN_ACL_UNSAFE,&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CreateMode.PERSISTENT_SEQUENTIAL);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;true;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;}</pre>
<h5 id="listing7">清单 7. 消费者代码</h5>
<pre class="displaycode">&nbsp;int&nbsp;consume()&nbsp;throws&nbsp;KeeperException,&nbsp;InterruptedException{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int&nbsp;retvalue&nbsp;=&nbsp;-1;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stat&nbsp;stat&nbsp;=&nbsp;null;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;while&nbsp;(true)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;synchronized&nbsp;(mutex)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;List&lt;String&gt;&nbsp;list&nbsp;=&nbsp;zk.getChildren(root,&nbsp;true);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(list.size()&nbsp;==&nbsp;0)&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mutex.wait();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Integer&nbsp;min&nbsp;=&nbsp;new&nbsp;Integer(list.get(0).substring(7));&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for(String&nbsp;s&nbsp;:&nbsp;list){&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Integer&nbsp;tempValue&nbsp;=&nbsp;new&nbsp;Integer(s.substring(7));&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if(tempValue&nbsp;&lt;&nbsp;min)&nbsp;min&nbsp;=&nbsp;tempValue;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;b&nbsp;=&nbsp;zk.getData(root&nbsp;+&nbsp;"/element"&nbsp;+&nbsp;min,false,&nbsp;stat);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk.delete(root&nbsp;+&nbsp;"/element"&nbsp;+&nbsp;min,&nbsp;0);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ByteBuffer&nbsp;buffer&nbsp;=&nbsp;ByteBuffer.wrap(b);&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retvalue&nbsp;=&nbsp;buffer.getInt();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;retvalue;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;
&nbsp;}</pre>
<h2 id="major4"><br></h2>
<h2>总结</h2>
<p>Zookeeper 作为 Hadoop 项目中的一个子项目，是 Hadoop 集群管理的一个必不可少的模块，它主要用来控制集群中的数据，如它管理 Hadoop 集群中的 NameNode，还有 Hbase 中 Master Election、Server 之间状态同步等。</p>
<p>本文介绍的 Zookeeper 的基本知识，以及介绍了几个典型的应用场景。这些都是 Zookeeper 的基本功能，最重要的是 Zoopkeeper 提供了一套很好的分布式集群管理的机制，就是它这种基于层次型的目录树的数据结构，并对树中的节点进行有效管理，从而可以设计出多种多样的分布式的数据管 理模型，而不仅仅局限于上面提到的几个常用应用场景。</p>
<p><br></p>
<p>Zookeeper的重点：四种节点类型（持久、临时、持久自增、临时自增）、客户端对节点的观察、一致性算法；<br></p>
<p><br></p>
<p>一个实现共享公平锁的例子 http://www.open-open.com/lib/view/open1370479522695.html</p>
