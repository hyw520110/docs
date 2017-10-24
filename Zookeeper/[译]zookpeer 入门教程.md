
本文档包含的信息来帮助你的ZooKeeper快速入门。它是在开发人员希望能够尝试一下主要目的，并包含安装简单说明一个ZooKeeper的服 务器，几个命令，以验证它是否正在运行，一个简单的编程示例。最后，为了方便，还有更多的关于安装复杂，几节，例如运行复制的部署和优化事务日志。然而， 对于商业部署的完整说明，请参阅的<a href="http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html" target="_blank">ZooKeeper管理员指南</a>。 

#下载

从Apache下载镜像下载最近的<a href="http://zookeeper.apache.org/releases.html" target="_blank">稳定版本</a> ，从而得到 ZooKeeper 程序。

#Standalone 模式下操作
设置在独立模式&lt; standalone &gt;下的ZooKeeper服务器很简单。服务器被包含在一个单一的JAR文件中，所以安装包括创建一个新的配置。
一旦你下载一个稳定ZooKeeper的版本 解压它并进入解压的根路径<br>要启动的ZooKeeper你需要一个配置文件。下面是一个示例, 新建文件 conf/zoo.cfg：

	tickTime=2000
	dataDir=/var/lib/zookeeper
	clientPort=2181 
这个文件可以叫任何一个名字，但是一般我们更喜欢 设置为&nbsp; conf/zoo.cfg. 我们需要将 dataDir 的值 设置为一个指定的目录，一开始这个是空的。<br>下面是每个参数的含义：<br>tickTime：基本事件单元，以毫秒为单位。它用来指示心跳，最小的 session 过期时间为两倍的 tickTime. 。<br>dataDir：存储内存中数据库快照的位置，如果不设置参数，更新事务日志将被存储到默认位置。<br>clientPort：监听客户端连接的端口
现在你可以创建文件并且启动它了<br>
<pre class="brush:bash;toolbar:false">bin/zkServer.sh&nbsp;start</pre>
ZooKeeper 日志使用 log4j ― 更多详细信息请查看编程指南的 <a href="http://zookeeper.apache.org/doc/trunk/zookeeperProgrammers.html#Logging" target="_blank">日志</a> 部分。 你将会看到日志出现在控制台&lt; 默认 &gt; 日志文件依赖于log4j 的配置文件。
上面所述的是如何使 ZooKeeper 运行在单点模式下。这里没有复制，所以如果 ZooKeeper 进程出现错误，服务将不可用。这是一个不错的开发解决方案，但是如果想要使 ZooKeeper 运行在复制模式下，请参见 <a href="http://zookeeper.apache.org/doc/trunk/zookeeperStarted.html#sc_RunningReplicatedZooKeeper" target="_blank">Running Replicated ZooKeeper</a>.
<h3>管理 ZooKeeper 存储
对于长期运行在生产环境的 ZooKeeper 来说 存储必须外部管理（dataDir &amp;&amp; logs）。获取更多信息见 <a href="http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html#sc_maintenance" target="_blank">维护部分</a>。
<h3>连接 ZooKeeper
一旦 ZooKeeper 运行起来，你会有很多种方式连接它：
<ul class="list-paddingleft-2">
 <li>&nbsp;Java:<br>bin/zkCli.sh -server 127.0.0.1:2181<br>这样是你的操作变得简单，想文件操作一样。</li>
 <li>C:&nbsp; C: compile cli_mt (multi-threaded) or cli_st (single-threaded) by running make&nbsp;&nbsp;&nbsp;&nbsp; cli_mt or make cli_st in the src/c subdirectory in the ZooKeeper sources. See the&nbsp;&nbsp;&nbsp;&nbsp; README contained within src/c for full details<br>You can run the program from src/c using:<br>LD_LIBRARY_PATH=. cli_mt 127.0.0.1:2181<br>or<br>LD_LIBRARY_PATH=. cli_st 127.0.0.1:2181<br>它会给你在ZooKeeper上提供一个简单的shell执行文件操作。</li>
</ul>
一旦你成功连接，你将会看到类似下面的信息：
<pre class="brush:bash;toolbar:false">Connecting&nbsp;to&nbsp;localhost:2181
log4j:WARN&nbsp;No&nbsp;appenders&nbsp;could&nbsp;be&nbsp;found&nbsp;for&nbsp;logger&nbsp;(org.apache.zookeeper.ZooKeeper).
log4j:WARN&nbsp;Please&nbsp;initialize&nbsp;the&nbsp;log4j&nbsp;system&nbsp;properly.
Welcome&nbsp;to&nbsp;ZooKeeper!
JLine&nbsp;support&nbsp;is&nbsp;enabled
[zkshell:&nbsp;0]</pre>
在shell中，在客户端键入 <code>help</code> 可以得到帮助信息：
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;0]&nbsp;help
ZooKeeper&nbsp;host:port&nbsp;cmd&nbsp;args
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;get&nbsp;path&nbsp;[watch]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ls&nbsp;path&nbsp;[watch]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;set&nbsp;path&nbsp;data&nbsp;[version]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;delquota&nbsp;[-n|-b]&nbsp;path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;quit
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;printwatches&nbsp;on|off
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;create&nbsp;path&nbsp;data&nbsp;acl
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;stat&nbsp;path&nbsp;[watch]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;listquota&nbsp;path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;history
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;setAcl&nbsp;path&nbsp;acl
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;getAcl&nbsp;path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sync&nbsp;path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;redo&nbsp;cmdno
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;addauth&nbsp;scheme&nbsp;auth
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;delete&nbsp;path&nbsp;[version]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;deleteall&nbsp;path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;setquota&nbsp;-n|-b&nbsp;val&nbsp;path</pre>
在这里，你可以键入一些简单的命令来感受这个简单的命令行界面。首先，从list 命令开始 ，如ls：
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;8]&nbsp;ls&nbsp;/
[zookeeper]</pre>
接下来，执行 <code>create /zk_test my_data</code> 创建一个新的 znode。这个新创建的znode 和字符串”my_data”是关联的。你应该可以看到：
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;9]&nbsp;create&nbsp;/zk_test&nbsp;my_data
Created&nbsp;/zk_test</pre>
发出另一个 <code>ls /</code> 命令查看目录：
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;11]&nbsp;ls&nbsp;/
[zookeeper,&nbsp;zk_test]</pre>
请注意，zk_test 目录现在已经创建完成了。<br>接下来，执行 get 命令来验证数据与其关联的znode:
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;12]&nbsp;get&nbsp;/zk_test
my_data
cZxid&nbsp;=&nbsp;5
ctime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;13:57:06&nbsp;PDT&nbsp;2009
mZxid&nbsp;=&nbsp;5
mtime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;13:57:06&nbsp;PDT&nbsp;2009
pZxid&nbsp;=&nbsp;5
cversion&nbsp;=&nbsp;0
dataVersion&nbsp;=&nbsp;0
aclVersion&nbsp;=&nbsp;0
ephemeralOwner&nbsp;=&nbsp;0
dataLength&nbsp;=&nbsp;7
numChildren&nbsp;=&nbsp;0</pre>
我们可以使用 set 命令来修改与zk_test相关的数据：
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;14]&nbsp;set&nbsp;/zk_test&nbsp;junk
cZxid&nbsp;=&nbsp;5
ctime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;13:57:06&nbsp;PDT&nbsp;2009
mZxid&nbsp;=&nbsp;6
mtime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;14:01:52&nbsp;PDT&nbsp;2009
pZxid&nbsp;=&nbsp;5
cversion&nbsp;=&nbsp;0
dataVersion&nbsp;=&nbsp;1
aclVersion&nbsp;=&nbsp;0
ephemeralOwner&nbsp;=&nbsp;0
dataLength&nbsp;=&nbsp;4
numChildren&nbsp;=&nbsp;0
[zkshell:&nbsp;15]&nbsp;get&nbsp;/zk_test
junk
cZxid&nbsp;=&nbsp;5
ctime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;13:57:06&nbsp;PDT&nbsp;2009
mZxid&nbsp;=&nbsp;6
mtime&nbsp;=&nbsp;Fri&nbsp;Jun&nbsp;05&nbsp;14:01:52&nbsp;PDT&nbsp;2009
pZxid&nbsp;=&nbsp;5
cversion&nbsp;=&nbsp;0
dataVersion&nbsp;=&nbsp;1
aclVersion&nbsp;=&nbsp;0
ephemeralOwner&nbsp;=&nbsp;0
dataLength&nbsp;=&nbsp;4
numChildren&nbsp;=&nbsp;0</pre>
（请注意，我们在更新完数据之后通过get得到了它有变动）<br>最后，让我们删除我们之前创建的znode:
<pre class="brush:bash;toolbar:false">[zkshell:&nbsp;16]&nbsp;delete&nbsp;/zk_test
[zkshell:&nbsp;17]&nbsp;ls&nbsp;/
[zookeeper]
[zkshell:&nbsp;18]</pre>
到此为止吧。如果要获取更多信息，继续本文档的其余部分和 <a href="http://zookeeper.apache.org/doc/trunk/zookeeperProgrammers.html" target="_blank">程序员指南</a>。
<h3>ZooKeeper 编程
ZooKeeper提供了 Java 和 C 两种程序语言接口。它们功能上是等价的。但是C接口有两种变种存在：单线程和多线程。这些只有在如何完成消息循环是不同的。欲了解更多信息，请参阅的<a href="http://zookeeper.apache.org/doc/trunk/zookeeperProgrammers.html" target="_blank">ZooKeeper程序员指南中的编程示例</a>使用不同的API的示例代码。
<h3>ZooKeeper Replicated
在开发和测试模式下，将ZooKeeper运行在独立模式下便于评估。但是在生产模式下，你应该讲ZooKeeper运行在 replicated 模式下。对于相同的应用程序来说，一组运行在replicated 的机器被称作 quorum。所有在 quorum 中的机器都有相同配置文件。
<blockquote>
 注意：<br>对于复制模式来说，至少需要三台机器，这里强烈建议你有奇数台机器。如果你只有两台机器，那么你可能会出现这种情况，如果其中一个出现故障，在有些情况下没有足够的机器来形成多数quorum。两个服务器比单个服务器还不稳定，因为当有故障时它们都指向错误。
</blockquote>
这里在复制模式下需要的 cong/zoo.cfg 文件与在单节点模式下很相近，但是这里有些不同。<br>请看下面的例子：
<pre class="brush:bash;toolbar:false">tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=zoo1:2888:3888
server.2=zoo2:2888:3888
server.3=zoo3:2888:3888</pre>
新的条目<br>initLimit 在心跳连接中，允许followers连接leader和与leader同步数据的时间。如果zookeeper管理的数据比较大，可以增加此值。<br>syncLimit 在心跳连接中，允许followers同步zookeeper数据的时间。如果followers与leader长久失去连接，它将被丢弃。
有了这两个关于超时的参数，你可以使用tickTime确定时间单元。在这个例子中，initLimit 的超时是 5 ticks &lt;2000 毫秒 一 tick &gt;,或者是10 秒。
表单中的 <code>server.x</code> 列出了组成 ZooKeeper 服务的机器。当服务启动的时候，它通过查找数据目录中的文件身份识别码来识别它是哪台服务器。这个文件有包含了以ASCII码 编码的服务器编号。
最后，注意每个服务器名称后的两个端口号：”2888″和”3888″。同行使用当前端口连接到其他节点。这样的连接测试是必要的，这样对等体可以 进行通信，例如，在更新的顺序一致中。更具体地说，ZooKeeper的服务器使用此端口将follower连接到leader。当一个新的leader 出现，follower打开一个TCP连接，使用此端口连接到leader。因为默认leader选举也采用TCP，我们目前需要的其他端口用来 leader的选举。这就是在server条目的第二端口。
<blockquote>
 注意：<br>如果你现在单机上测试集群伪分布。在本地主机该服务器的配置文件中的每个server.X 中指定服务器名与唯一的 quorum &amp; leader 选举端口(如：2888:3888, 2889:3889, 2890:3890 )。当然，独立的dataDirs和不同的客户端端口也是必要的（在上面的复制例如，在一个单一的本地主机上运行，你仍然有三个配置文件）。
 请注意，在一台机器上设置的集群伪分布不会产生任何冗余。如果出了什么错误造成机器不能正常提供服务，所有的ZooKeeper服务将下线。完全冗余需要每个服务器都有它自己的机器。它必须是一个完全独立的物理服务器。在同一台物理主机上的多个虚拟机仍然容易受到威胁。
</blockquote>
&nbsp;
<h3>其他操作
这里仍有一些其他配置参数可以大大提升性能：
有一个专门的事务日志目录是很重要的可以在更新的时候降低延迟。在默认情况下，在同一目录存放 data snapshots 和 myid 文件.这个 dataLogDir 参数表示不同的目录用于事务日志。
待定： … …
原文：<a href="http://zookeeper.apache.org/doc/trunk/zookeeperStarted.html" target="_blank">ZooKeeper Getting Started Guide</a>
<br> 