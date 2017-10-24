<p>一、ZooKeeper是一个分布式的、提供高可用的、存放键值对的服务<br></p>
<p></p>
<p>分布式</p>Zookeeper提供了分布式独享锁
<br>获取锁实现思路：
<br>1.首先创建一个作为锁目录(znode)，通常用它来描述锁定的实体，称为:/lock_node
<br>2.希望获得锁的客户端在锁目录下创建znode，作为锁/lock_node的子节点，并且节点类型为有序临时节点(EPHEMERAL_SEQUENTIAL)；
<br>&nbsp; 例如：有两个客户端创建znode，分别为/lock_node/lock-1和/lock_node/lock-2
<br>3.当前客户端调用getChildren（/lock_node）得到锁目录所有子节点，不设置watch，接着获取小于自己(步骤2创建)的兄弟节点
<br>4.步骤3中获取小于自己的节点不存在 &amp;&amp; 最小节点与步骤2中创建的相同，说明当前客户端顺序号最小，获得锁，结束。
<br>5.客户端监视(watch)相对自己次小的有序临时节点状态
<br>6.如果监视的次小节点状态发生变化，则跳转到步骤3，继续后续操作，直到退出锁竞争。
<p><br></p>
<p>高可用</p>
<p>&nbsp;通过投票选举leader</p>
<p><br></p>
<p>存放键值对</p>
<p>Zookeeper是以树状结果存放键值对的。</p>
<p></p>
<p>zookeeper的4种节点类型：</p>
<p>1、持久节点：节点创建后，会一直存在，不会因客户端会话失效而删除；</p>
<p>PERSISTENT (0, false, false),&nbsp;</p>
<p>2、 持久顺序节点：基本特性与持久节点一致，创建节点的过程中，zookeeper会在其名字后自动追加一个单调增长的数字后缀，作为新的节点名；&nbsp;</p>
<p>PERSISTENT_SEQUENTIAL (2, false, true),&nbsp;</p>
<p></p>
<p>3、临时节点：客户端会话失效或连接关闭后，该节点会被自动删除，且不能再临时节点下面创建子节点，否则报如下错：org.apache.zookeeper.KeeperException$NoChildrenForEphemeralsException；</p>
<p>EPHEMERAL (1, true, false),</p>
<p></p>
<p>4、临时顺序节点：基本特性与临时节点一致，创建节点的过程中，zookeeper会在其名字后自动追加一个单调增长的数字后缀，作为新的节点名；&nbsp;</p>
<p>EPHEMERAL_SEQUENTIAL (3, true, true);</p>
<p></p>
<p><br></p>
<p>&nbsp;每个znode由3部分组成:</p>
<p style="margin-top:5.76pt;margin-bottom:0pt;margin-left:0in;text-indent:0in;">stat. 此为状态信息, 描述该znode的版本, 权限等信息.</p>
<p>data. 与该znode关联的数据.</p>
<p>children. 该znode下的子节点.</p>
<p><br></p>znode节点的状态信息
<p>czxid. 节点创建时的zxid.</p>
<p>mzxid. 节点最新一次更新发生时的zxid.<br>ctime. 节点创建时的时间戳.<br>mtime. 节点最新一次更新发生时的时间戳.<br>dataVersion. 节点数据的更新次数.<br>cversion.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 其子节点的更新次数.<br>aclVersion. 节点ACL(授权信息)的更新次数.<br>ephemeralOwner. 如果该节点为ephemeral节点, ephemeralOwner值表示与该节点绑定的session id，<br>如果该节点不是ephemeral节点, ephemeralOwner值为0. <br>dataLength. 节点数据的字节数.<br>numChildren. 子节点个数. <br></p>Data
<br>zookeeper默认对每个结点的最大数据量有一个上限是1M,如果你要设置的配置数据大于这个上限将无法写法，
<br>
<p>增加-Djute.maxbuffer=10240000参数&nbsp;</p>
<p><br></p>
<p>持久化</p>&nbsp;所有的操作都是存放在事务日志中的，可以用于数据恢复。
<br>
<p>&nbsp;快照是ZK的data tree的一份拷贝。每一个server每隔一段时间会序列化data tree的所有数据并写入一个文件。</p>
<p>二、安装配置<br></p>
<p>下载 <a href="http://zookeeper.apache.org/" target="_blank">http://zookeeper.apache.org/</a> </p>
<p>配置<br></p>
<p>cat /opt/oracle/zookeeper/conf/zoo.cfg</p>
<p>dataDir=/opt/oracle/data/zookeeper/data</p>
<p>dataLogDir=/opt/oracle/data/zookeeper/datalog</p>
<p>clientPort=2181</p>
<p>initLimit=10</p>
<p>syncLimit=5</p>
<p>server.1=zookeeper01:2888:3888</p>
<p>server.2=zookeeper02:2888:3888</p>
<p>server.3=zookeeper03:2888:3888</p>
<p><br></p>
<p>参数名</p>
<p><br></p>
<p>说明</p>
<p><br></p>
<p>clientPort<span class="Apple-tab-span" style="white-space:pre;"> </span>客户端连接server的端口，即对外服务端口，一般设置为2181吧。</p>
<p>dataDir<span class="Apple-tab-span" style="white-space:pre;"> </span>存储快照文件snapshot的目录。默认情况下，事务日志也会存储在这里。建议同时配置参数dataLogDir, 事务日志的写性能直接影响zk性能。</p>
<p>tickTime<span class="Apple-tab-span" style="white-space:pre;"> </span>ZK中的一个时间单元。ZK中所有时间都是以这个时间单元为基础，进行整数倍配置的。例如，session的最小超时时间是2*tickTime。</p>
<p>dataLogDir<span class="Apple-tab-span" style="white-space:pre;"> </span>事务日志输出目录。尽量给事务日志的输出配置单独的磁盘或是挂载点，这将极大的提升ZK性能。</p>
<p>（No Java system property）</p>
<p>globalOutstandingLimit<span class="Apple-tab-span" style="white-space:pre;"> </span>最大请求堆积数。默认是1000。ZK运行的时候， 尽管server已经没有空闲来处理更多的客户端请求了，但是还是允许客户端将请求提交到服务器上来，以提高吞吐性能。当然，为了防止Server内存溢出，这个请求堆积数还是需要限制下的。</p>
<p>(Java system property:zookeeper.globalOutstandingLimit.)</p>
<p>preAllocSize<span class="Apple-tab-span" style="white-space:pre;"> </span>预先开辟磁盘空间，用于后续写入事务日志。默认是64M，每个事务日志大小就是64M。如果ZK的快照频率较大的话，建议适当减小这个参数。(Java system property:zookeeper.preAllocSize)</p>
<p>snapCount<span class="Apple-tab-span" style="white-space:pre;"> </span>每进行snapCount次事务日志输出后，触发一次快照(snapshot), 此时，ZK会生成一个snapshot.*文件，同时创建一个新的事务日志文件log.*。默认是100000.（真正的代码实现中，会进行一定的随机数处理，以避免所有服务器在同一时间进行快照而影响性能）(Java system property:zookeeper.snapCount)</p>
<p>traceFile<span class="Apple-tab-span" style="white-space:pre;"> </span>用于记录所有请求的log，一般调试过程中可以使用，但是生产环境不建议使用，会严重影响性能。(Java system property:?requestTraceFile)</p>
<p>maxClientCnxns<span class="Apple-tab-span" style="white-space:pre;"> </span>单个客户端与单台服务器之间的连接数的限制，是ip级别的，默认是60，如果设置为0，那么表明不作任何限制。请注意这个限制的使用范围，仅仅是单台客户端机器与单台ZK服务器之间的连接数限制，不是针对指定客户端IP，也不是ZK集群的连接数限制，也不是单台ZK对所有客户端的连接数限制。指定客户端IP的限制策略，这里有一个patch，可以尝试一下：http://rdc.taobao.com/team/jm/archives/1334（No Java system property）</p>
<p>clientPortAddress<span class="Apple-tab-span" style="white-space:pre;"> </span>对于多网卡的机器，可以为每个IP指定不同的监听端口。默认情况是所有IP都监听clientPort指定的端口。New in 3.3.0</p>
<p>minSessionTimeoutmaxSessionTimeout<span class="Apple-tab-span" style="white-space:pre;"> </span>Session超时时间限制，如果客户端设置的超时时间不在这个范围，那么会被强制设置为最大或最小时间。默认的Session超时时间是在2 * tickTime ~ 20 * tickTime这个范围 New in 3.3.0</p>
<p>fsync.warningthresholdms<span class="Apple-tab-span" style="white-space:pre;"> </span>事务日志输出时，如果调用fsync方法超过指定的超时时间，那么会在日志中输出警告信息。默认是1000ms。(Java system property:fsync.warningthresholdms)New in 3.3.4</p>
<p>autopurge.purgeInterval<span class="Apple-tab-span" style="white-space:pre;"> </span>在上文中已经提到，3.4.0及之后版本，ZK提供了自动清理事务日志和快照文件的功能，这个参数指定了清理频率，单位是小时，需要配置一个1或更大的整数，默认是0，表示不开启自动清理功能。(No Java system property) New in 3.4.0</p>
<p>autopurge.snapRetainCount<span class="Apple-tab-span" style="white-space:pre;"> </span>这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。(No Java system property)New in 3.4.0</p>
<p>electionAlg<span class="Apple-tab-span" style="white-space:pre;"> </span>在之前的版本中， 这个参数配置是允许我们选择leader选举算法，但是由于在以后的版本中，只会留下一种“TCP-based version of fast leader election”算法，所以这个参数目前看来没有用了，这里也不详细展开说了。(No Java system property)</p>
<p>initLimit<span class="Apple-tab-span" style="white-space:pre;"> </span>Follower在启动过程中，会从Leader同步所有最新数据，然后确定自己能够对外服务的起始状态。Leader允许F在initLimit时间内完成这个工作。通常情况下，我们不用太在意这个参数的设置。如果ZK集群的数据量确实很大了，F在启动的时候，从Leader上同步数据的时间也会相应变长，因此在这种情况下，有必要适当调大这个参数了。(No Java system property)</p>
<p>syncLimit<span class="Apple-tab-span" style="white-space:pre;"> </span>在运行过程中，Leader负责与ZK集群中所有机器进行通信，例如通过一些心跳检测机制，来检测机器的存活状态。如果L发出心跳包在syncLimit之后，还没有从F那里收到响应，那么就认为这个F已经不在线了。注意：不要把这个参数设置得过大，否则可能会掩盖一些问题。(No Java system property)</p>
<p>leaderServes<span class="Apple-tab-span" style="white-space:pre;"> </span>默认情况下，Leader是会接受客户端连接，并提供正常的读写服务。但是，如果你想让Leader专注于集群中机器的协调，那么可以将这个参数设置为no，这样一来，会大大提高写操作的性能。(Java system property: zookeeper.leaderServes)。</p>
<p>server.x=[hostname]:nnnnn[:nnnnn]<span class="Apple-tab-span" style="white-space:pre;"> </span>这里的x是一个数字，与myid文件中的id是一致的。右边可以配置两个端口，第一个端口用于F和L之间的数据同步和其它通信，第二个端口用于Leader选举过程中投票通信。</p>
<p>(No Java system property)</p>
<p>group.x=nnnnn[:nnnnn]weight.x=nnnnn<span class="Apple-tab-span" style="white-space:pre;"> </span>对机器分组和权重设置，可以 参见这里(No Java system property)</p>
<p>cnxTimeout<span class="Apple-tab-span" style="white-space:pre;"> </span>Leader选举过程中，打开一次连接的超时时间，默认是5s。(Java system property: zookeeper.cnxTimeout)</p>
<p>zookeeper.DigestAuthenticationProvider</p>
<p>.superDigest<span class="Apple-tab-span" style="white-space:pre;"> </span>ZK权限设置相关，具体参见《使用super身份对有权限的节点进行操作》 和 《ZooKeeper权限控制》</p>
<p>skipACL<span class="Apple-tab-span" style="white-space:pre;"> </span>对所有客户端请求都不作ACL检查。如果之前节点上设置有权限限制，一旦服务器上打开这个开头，那么也将失效。(Java system property:zookeeper.skipACL)</p>
<p>forceSync<span class="Apple-tab-span" style="white-space:pre;"> </span>这个参数确定了是否需要在事务日志提交的时候调用FileChannel.force来保证数据完全同步到磁盘。(Java system property:zookeeper.forceSync)</p>
<p>jute.maxbuffer<span class="Apple-tab-span" style="white-space:pre;"> </span>每个节点最大数据量，是默认是1M。这个限制必须在server和client端都进行设置才会生效。(Java system property:jute.maxbuffer)</p>
<p><br></p>
<p><br></p>
<p>ZooKeeper服务命令:</p>
<p>在准备好相应的配置之后，可以直接通过zkServer.sh 这个脚本进行服务的相关操作</p>
<p>1. 启动ZK服务: &nbsp; &nbsp; &nbsp; sh bin/zkServer.sh start</p>
<p>2. 查看ZK服务状态: &nbsp; sh bin/zkServer.sh status</p>
<p>3. 停止ZK服务: &nbsp; &nbsp; &nbsp; sh bin/zkServer.sh stop</p>
<p>4. 重启ZK服务: &nbsp; &nbsp; &nbsp; sh bin/zkServer.sh restart</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>zk客户端命令</p>
<p>ZooKeeper命令行工具类似于Linux的shell环境，不过功能肯定不及shell啦，但是使用它我们可以简单的对ZooKeeper进行访问，数据创建，数据修改等操作.&nbsp;</p>
<p>&nbsp;使用 zkCli.sh -server 127.0.0.1:2181 连接到 ZooKeeper 服务，连接成功后，系统会输出 ZooKeeper 的相关环境以及配置信息。</p>
<p>命令行工具的一些简单操作如下：</p>
<p>1. 显示根目录下、文件： ls / 使用 ls 命令来查看当前 ZooKeeper 中所包含的内容</p>
<p>2. 显示根目录下、文件： ls2 / 查看当前节点数据并能看到更新次数等数据</p>
<p>3. 创建文件，并设置初始内容： create /zk "test" 创建一个新的 znode节点“ zk ”以及与它关联的字符串</p>
<p>4. 获取文件内容： get /zk 确认 znode 是否包含我们所创建的字符串</p>
<p>5. 修改文件内容： set /zk "zkbak" 对 zk 所关联的字符串进行设置</p>
<p>6. 删除文件： delete /zk 将刚才创建的 znode 删除&nbsp;</p>
<p>7. 退出客户端： quit&nbsp;</p>
<p>8. 帮助命令： help&nbsp;</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>三、zookeeper 的 python api<br></p>
<p>zookeeper的python客户端安装</p>
<p>1.由于python客户端依赖c的客户端所以要先安装c版本的客户端</p>
<p><br></p>
<p><br></p>
<p>cd zookeeper-3.4.5/src/c &nbsp;</p>
<p>./configure &nbsp;</p>
<p>make &nbsp;&nbsp;</p>
<p>make install &nbsp;</p>
<p><br></p>
<p>2.测试c版本客户端</p>
<p>./cli_mt localhost:2181 &nbsp;</p>
<p>Watcher SESSION_EVENT state = CONNECTED_STATE &nbsp;</p>
<p>Got a new session id: 0x23f9d77d3fe0001 &nbsp;</p>
<p><br></p>
<p>3、安装zkpython</p>
<p><br></p>
<p>&nbsp;wget --no-check-certificate http://pypi.python.org/packages/source/z/zkpython/zkpython-0.4.tar.gz</p>
<p>&nbsp;tar xf zkpython-0.4.tar.gz</p>
<p>&nbsp;cd zkpython-0.4</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span></p>
<p>python setup.py install</p>
<p><br></p>
<p><br></p>
<p>watch</p>
<p>watch的意思是监听感兴趣的事件. 在命令行中, 以下几个命令可以指定是否监听相应的事件.</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>ls命令. ls命令的第一个参数指定znode, 第二个参数如果为true, 则说明监听该znode的子节点的增减, 以及该znode本身的删除事件.</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>ls /test1 true</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>create /test1/01 123</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>get命令. get命令的第一个参数指定znode, 第二个参数如果为true, 则说明监听该znode的更新和删除事件.</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>get /test true</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>set /test test</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>stat命令. stat命令用于获取znode的状态信息. 第一个参数指定znode, 如果第二个参数为true, 则监听该node的更新和删除事件.</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>清理数据目录</p>
<p><br></p>
<p>快照是ZK的data tree的一份拷贝。每一个server每隔一段时间会序列化data tree的所有数据并写入一个文件</p>
<p><br></p>
<p><br></p>
<p>#!/bin/bash</p>
<p><br></p>
<p>#snapshot file dir</p>
<p>dataDir=/data/zookeeper/data/version-2</p>
<p>#tran log dir</p>
<p>dataLogDir=/data/zookeeper/datalog/version-2</p>
<p>#zk log dir</p>
<p>logDir=/data/zookeeper/log</p>
<p>#Leave 1 files</p>
<p>count=1</p>
<p>count=$[$count+1]</p>
<p>ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f</p>
<p>ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f</p>
<p>ls -t $logDir/zookeeper.* | tail -n +$count | xargs rm -f</p>
<p><br></p>
<p><br></p>
<p>api</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>zkclient.py</p>
<p><br></p>
<p>#!/usr/bin/python</p>
<p># -*- coding: UTF-8 -*-</p>
<p><br></p>
<p>import zookeeper, time, threading</p>
<p>from collections import namedtuple</p>
<p><br></p>
<p>zookeeper.set_debug_level(zookeeper.LOG_LEVEL_ERROR)</p>
<p>DEFAULT_TIMEOUT = 30000</p>
<p>VERBOSE = True</p>
<p><br></p>
<p>ZOO_OPEN_ACL_UNSAFE = {"perms":0x1f, "scheme":"world", "id" :"anyone"}</p>
<p><br></p>
<p># Mapping of connection state values to human strings.</p>
<p>STATE_NAME_MAPPING = {</p>
<p>&nbsp; &nbsp; zookeeper.ASSOCIATING_STATE: "associating",</p>
<p>&nbsp; &nbsp; zookeeper.AUTH_FAILED_STATE: "auth-failed",</p>
<p>&nbsp; &nbsp; zookeeper.CONNECTED_STATE: "connected",</p>
<p>&nbsp; &nbsp; zookeeper.CONNECTING_STATE: "connecting",</p>
<p>&nbsp; &nbsp; zookeeper.EXPIRED_SESSION_STATE: "expired",</p>
<p>}</p>
<p><br></p>
<p># Mapping of event type to human string.</p>
<p>TYPE_NAME_MAPPING = {</p>
<p>&nbsp; &nbsp; zookeeper.NOTWATCHING_EVENT: "not-watching",</p>
<p>&nbsp; &nbsp; zookeeper.SESSION_EVENT: "session",</p>
<p>&nbsp; &nbsp; zookeeper.CREATED_EVENT: "created",</p>
<p>&nbsp; &nbsp; zookeeper.DELETED_EVENT: "deleted",</p>
<p>&nbsp; &nbsp; zookeeper.CHANGED_EVENT: "changed",</p>
<p>&nbsp; &nbsp; zookeeper.CHILD_EVENT: "child",</p>
<p>}</p>
<p><br></p>
<p>class ZKClientError(Exception):</p>
<p>&nbsp; &nbsp; def __init__(self, value):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.value = value</p>
<p>&nbsp; &nbsp; def __str__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return repr(self.value)</p>
<p><br></p>
<p>class ClientEvent(namedtuple("ClientEvent", 'type, connection_state, path')):</p>
<p>&nbsp; &nbsp; """</p>
<p>&nbsp; &nbsp; A client event is returned when a watch deferred fires. It denotes</p>
<p>&nbsp; &nbsp; some event on the zookeeper client that the watch was requested on.</p>
<p>&nbsp; &nbsp; """</p>
<p><br></p>
<p>&nbsp; &nbsp; @property</p>
<p>&nbsp; &nbsp; def type_name(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return TYPE_NAME_MAPPING[self.type]</p>
<p><br></p>
<p>&nbsp; &nbsp; @property</p>
<p>&nbsp; &nbsp; def state_name(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return STATE_NAME_MAPPING[self.connection_state]</p>
<p><br></p>
<p>&nbsp; &nbsp; def __repr__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return &nbsp;"&lt;ClientEvent %s at %r state: %s&gt;" % (</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.type_name, self.path, self.state_name)</p>
<p><br></p>
<p><br></p>
<p>def watchmethod(func):</p>
<p>&nbsp; &nbsp; def decorated(handle, atype, state, path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; event = ClientEvent(atype, state, path)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return func(event)</p>
<p>&nbsp; &nbsp; return decorated</p>
<p><br></p>
<p>class ZKClient(object):</p>
<p>&nbsp; &nbsp; def __init__(self, servers, timeout=DEFAULT_TIMEOUT):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.timeout = timeout</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.connected = False</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv = threading.Condition( )</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.handle = -1</p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.acquire()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if VERBOSE: print("Connecting to %s" % (servers))</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; start = time.time()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.handle = zookeeper.init(servers, self.connection_watcher, timeout)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.wait(timeout/1000)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.release()</p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if not self.connected:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; raise ZKClientError("Unable to connect to %s" % (servers))</p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if VERBOSE:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; print("Connected in %d ms, handle is %d"</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; % (int((time.time() - start) * 1000), self.handle))</p>
<p><br></p>
<p>&nbsp; &nbsp; def connection_watcher(self, h, type, state, path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.handle = h</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.acquire()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.connected = True</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.notifyAll()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.conn_cv.release()</p>
<p><br></p>
<p>&nbsp; &nbsp; def close(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.close(self.handle)</p>
<p><br></p>
<p>&nbsp; &nbsp; def create(self, path, data="", flags=0, acl=[ZOO_OPEN_ACL_UNSAFE]):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; start = time.time()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; result = zookeeper.create(self.handle, path, data, acl, flags)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; #if VERBOSE:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; # &nbsp; &nbsp;print("Node %s created in %d ms"</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; # &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;% (path, int((time.time() - start) * 1000)))</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return result</p>
<p><br></p>
<p>&nbsp; &nbsp; def delete(self, path, version=-1):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; start = time.time()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; result = zookeeper.delete(self.handle, path, version)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if VERBOSE:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; print("Node %s deleted in %d ms"</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; % (path, int((time.time() - start) * 1000)))</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return result</p>
<p><br></p>
<p>&nbsp; &nbsp; def get(self, path, watcher=None):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.get(self.handle, path, watcher)</p>
<p><br></p>
<p>&nbsp; &nbsp; def exists(self, path, watcher=None):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.exists(self.handle, path, watcher)</p>
<p><br></p>
<p>&nbsp; &nbsp; def set(self, path, data="", version=-1):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.set(self.handle, path, data, version)</p>
<p><br></p>
<p>&nbsp; &nbsp; def set2(self, path, data="", version=-1):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.set2(self.handle, path, data, version)</p>
<p><br></p>
<p><br></p>
<p>&nbsp; &nbsp; def get_children(self, path, watcher=None):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.get_children(self.handle, path, watcher)</p>
<p><br></p>
<p>&nbsp; &nbsp; def async(self, path = "/"):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.async(self.handle, path)</p>
<p><br></p>
<p>&nbsp; &nbsp; def acreate(self, path, callback, data="", flags=0, acl=[ZOO_OPEN_ACL_UNSAFE]):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; result = zookeeper.acreate(self.handle, path, data, acl, flags, callback)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return result</p>
<p><br></p>
<p>&nbsp; &nbsp; def adelete(self, path, callback, version=-1):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.adelete(self.handle, path, version, callback)</p>
<p><br></p>
<p>&nbsp; &nbsp; def aget(self, path, callback, watcher=None):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.aget(self.handle, path, watcher, callback)</p>
<p><br></p>
<p>&nbsp; &nbsp; def aexists(self, path, callback, watcher=None):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.aexists(self.handle, path, watcher, callback)</p>
<p><br></p>
<p>&nbsp; &nbsp; def aset(self, path, callback, data="", version=-1):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return zookeeper.aset(self.handle, path, data, version, callback)</p>
<p><br></p>
<p>watch_count = 0</p>
<p><br></p>
<p>"""Callable watcher that counts the number of notifications"""</p>
<p>class CountingWatcher(object):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.count = 0</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; global watch_count</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.id = watch_count</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; watch_count += 1</p>
<p><br></p>
<p>&nbsp; &nbsp; def waitForExpected(self, count, maxwait):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; """Wait up to maxwait for the specified count,</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return the count whether or not maxwait reached.</p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Arguments:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; - `count`: expected count</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; - `maxwait`: max milliseconds to wait</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; """</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; waited = 0</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; while (waited &lt; maxwait):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if self.count &gt;= count:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return self.count</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; time.sleep(1.0);</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; waited += 1000</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; return self.count</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, typ, state, path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.count += 1</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if VERBOSE:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; print("handle %d got watch for %s in watcher %d, count %d" %</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (handle, path, self.id, self.count))</p>
<p><br></p>
<p>"""Callable watcher that counts the number of notifications</p>
<p>and verifies that the paths are sequential"""</p>
<p>class SequentialCountingWatcher(CountingWatcher):</p>
<p>&nbsp; &nbsp; def __init__(self, child_path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; CountingWatcher.__init__(self)</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.child_path = child_path</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, typ, state, path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if not self.child_path(self.count) == path:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; raise ZKClientError("handle %d invalid path order %s" % (handle, path))</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; CountingWatcher.__call__(self, handle, typ, state, path)</p>
<p><br></p>
<p>class Callback(object):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.cv = threading.Condition()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback_flag = False</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.rc = -1</p>
<p><br></p>
<p>&nbsp; &nbsp; def callback(self, handle, rc, handler):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.cv.acquire()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback_flag = True</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.handle = handle</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.rc = rc</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; handler()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.cv.notify()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.cv.release()</p>
<p><br></p>
<p>&nbsp; &nbsp; def waitForSuccess(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; while not self.callback_flag:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.cv.wait()</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.cv.release()</p>
<p><br></p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if not self.callback_flag == True:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; raise ZKClientError("asynchronous operation timed out on handle %d" %</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;(self.handle))</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; if not self.rc == zookeeper.OK:</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; raise ZKClientError(</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "asynchronous operation failed on handle %d with rc %d" %</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (self.handle, self.rc))</p>
<p><br></p>
<p><br></p>
<p>class GetCallback(Callback):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Callback.__init__(self)</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, rc, value, stat):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; def handler():</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.value = value</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.stat = stat</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback(handle, rc, handler)</p>
<p><br></p>
<p>class SetCallback(Callback):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Callback.__init__(self)</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, rc, stat):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; def handler():</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.stat = stat</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback(handle, rc, handler)</p>
<p><br></p>
<p>class ExistsCallback(SetCallback):</p>
<p>&nbsp; &nbsp; pass</p>
<p><br></p>
<p>class CreateCallback(Callback):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Callback.__init__(self)</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, rc, path):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; def handler():</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; self.path = path</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback(handle, rc, handler)</p>
<p><br></p>
<p>class DeleteCallback(Callback):</p>
<p>&nbsp; &nbsp; def __init__(self):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Callback.__init__(self)</p>
<p><br></p>
<p>&nbsp; &nbsp; def __call__(self, handle, rc):</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; def handler():</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pass</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; self.callback(handle, rc, handler)</p>
<p>if __name__ == '__main__':</p>
<p>&nbsp; &nbsp; zk=ZKClient('10.10.79.185:2181,10.10.79.184:2181,10.10.79.183:2181')</p>
<p>&nbsp; &nbsp; zk.create('/test1','123')</p>
<p>&nbsp; &nbsp; zk.close</p>
<p><br></p>
<p>本文出自 “<a href="http://zhoulinjun.blog.51cto.com">我爱技术</a>” 博客，请务必保留此出处<a href="http://zhoulinjun.blog.51cto.com/3911076/1719913">http://zhoulinjun.blog.51cto.com/3911076/1719913</a></p>
