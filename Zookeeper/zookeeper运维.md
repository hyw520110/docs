##常见问题

	http://blog.csdn.net/hengyunabc/article/details/19006911

##管理

ZooKeeper能够提供高可用分布式协调服务，是要基于以下两个条件：

- 集群中只有少部分的机器不可用。这里说的不可用是指这些机器或者是本身down掉了，或者是因为网络原因，有一部分机器无法和集群中其它绝大部分的机器通信。例如，如果ZK集群是跨机房部署的，那么有可能一些机器所在的机房被隔离了。
- 正确部署ZK server，有足够的磁盘存储空间以及良好的网络通信环境。



为了确保ZooKeeper服务的稳定与可靠性，通常是搭建成一个ZK集群来对外提供服务。关于ZooKeeper需要明确一个很重要的特性：集群中只要有过半的机器是正常工作的并且彼此之间能够正常通信，那么整个集群对外就是可用的，正是基于这个特性，建议是将ZK集群的机器数量控制为奇数较为合适。基于这个特性，那么如果想搭建一个能够允许F台机器down掉的集群，那么就要部署一个由2*F+1 台机器构成的ZK集群。因此，一个由3台机器构成的ZK集群，能够在down掉一台机器后依然正常工作，而5台机器的集群，能够对两台机器down掉的情况容灾。 注意，如果是一个6台机器构成的ZK集群，同样只能够down掉两台机器，因为如果down掉3台，剩下的机器就没有过半了。基于这个原因，ZK集群通常设计部署成奇数台机器。

所以，为了尽可能地提高ZK集群的可用性，应该尽量避免一大批机器同时down掉的风险，换句话说，最好能够为每台机器配置互相独立的硬件环境。举个例子，如果大部分的机器都挂在同一个交换机上，那么这个交换机一旦出现问题，将会对整个集群的服务造成严重的影响。其它类似的还有诸如：供电线路，散热系统等。其实在真正的实践过程中，如果条件允许，通常都建议尝试跨机房部署。毕竟多个机房同时发生故障的机率还是挺小的。

对于ZK来说，如果在运行过程中，需要和其它应用程序来竞争磁盘，CPU，网络或是内存资源的话，那么整体性能将会大打折扣

首先来看看磁盘对于ZK性能的影响。客户端对ZK的更新操作都是永久的，不可回退的，也就是说，一旦客户端收到一个来自server操作成功的响应，那么这个变更就永久生效了。为做到这点，ZK会将每次更新操作以事务日志的形式写入磁盘，写入成功后才会给予客户端响应。明白这点之后，你就会明白磁盘的吞吐性能对于ZK的影响了，磁盘写入速度制约着ZK每个更新操作的响应。为了尽量减少ZK在读写磁盘上的性能损失：

- 使用单独的磁盘作为事务日志的输出（比如我们这里的ZK集群，使用单独的挂载点用于事务日志的输出）。事务日志的写性能确实对ZK性能，尤其是更新操作的性能影响很大，所以想办法搞到一个单独的磁盘吧！ZK的事务日志输出是一个顺序写文件的过程，本身性能是很高的，所以尽量保证不要和其它随机写的应用程序共享一块磁盘，尽量避免对磁盘的竞争。
- 尽量避免内存与磁盘空间的交换。如果希望ZK能够提供完全实时的服务的话，那么基本是不允许操作系统触发此类swap的。因此在分配JVM堆大小的时候一定要非常小心，确保设置一个合理的JVM堆大小，如果设置太大，会让内存与磁盘进行交换，这将使ZK的性能大打折扣。例如一个4G内存的机器的，如果你把JVM的堆大小设置为4G或更大，那么会使频繁发生内存与磁盘空间的交换，通常设置成3G就可以了。当然，为了获得一个最好的堆大小值，在特定的使用场景下进行一些压力测试。

##清理数据目录

ZK的数据目录，用于存储ZK的快照文件（snapshot）。另外，默认情况下，ZK的事务日志也会存储在这个目录中。在完成若干次事务日志之后（在ZK中，凡是对数据有更新的操作，比如创建节点，删除节点或是对节点数据内容进行更新等，都会记录事务日志），ZK会触发一次快照（snapshot），将当前server上所有节点的状态以快照文件的形式dump到磁盘上去，即snapshot文件。这里的若干次事务日志是可以配置的，默认是100000，具体参看下文中关于配置参数“snapCount”的介绍。 
考虑到ZK运行环境的差异性，以及对于这些历史文件，不同的管理员可能有自己的用途（例如作为数据备份），因此默认ZK是不会自动清理快照和事务日志，需要交给管理员自己来处理。清理方法，参考日志清理. 


## Server的自检恢复

ZK运行过程中，如果出现一些无法处理的异常，会直接退出进程，也就是所谓的快速失败（fail fast）模式。在上文中有提到，“过半存活即可用”的特性使得集群中少数机器down掉后，整个集群还是可以对外正常提供服务的。另外，这些down掉的机器重启之后，能够自动加入到集群中，并且自动和集群中其它机器进行状态同步（主要就是从Leader那里同步最新的数据），从而达到自我恢复的目的。 
因此，我们很容易就可以想到，是否可以借助一些工具来自动完成机器的状态检测与重启工作。回答是肯定的，这里推荐两个工具： 
Daemontools( http://cr.yp.to/daemontools.html) 和 SMF（ http://en.wikipedia.org/wiki/Service_Management_Facility），能够帮助你监控ZK进程，一旦进程退出后，能够自动重启进程，从而使down掉的机器能够重新加入到集群中去

##监控

- ZK提供一些简单但是功能强大的4字命令，通过对这些4字命令的返回内容进行解析，可以获取不少关于ZK运行时的信息。
- 用jmx也能够获取一些运行时信息，详细可以查看这里： http://zookeeper.apache.org/doc/r3.4.3/zookeeperJMX.html
- 淘宝网已经实现的一个ZooKeeper监控——TaoKeeper，已开源，在这里： https://github.com/alibaba/taokeeper，主要功能:
	- 机器CPU/MEM/LOAD的监控
	- ZK日志目录所在磁盘空间监控
	- 单机连接数的峰值报警
	- 单机Watcher数的峰值报警
	- 节点自检
	- ZK运行时信息展示 
	

##日志管理
ZK使用log4j作为日志系统，conf目录中有一份默认的log4j配置文件，注意，这个配置文件中还没有开启ROLLINGFILE文件输出，配置下即可

##加载数据出错

ZK在启动的过程中，首先会根据事务日志中的事务日志记录，从本地磁盘加载最后一次提交时候的快照数据，如果读取事务日志出错或是其它问题（通常在日志中可以看到一些IO异常），将导致server将无法启动。碰到类似于这种数据文件出错导致无法启动服务器的情况，一般按照如下顺序来恢复：

- 确认集群中其它机器是否正常工作，方法是使用“stat”这个命令来检查：echo stat|nc ip 2181
- 如果确认其它机器是正常工作的（这里要说明下，所谓正常工作还是指集群中有过半机器可用），那么可以开始删除本机的一些数据了，删除$dataDir/version-2和$dataLogDir/version-2 两个目录下的所有文件。
重启server。重启之后，这个机器就会从Leader那里同步到最新数据，然后重新加入到集群中提供服务。

配置参数详解

<table border="1" cellpadding="0" cellspacing="0">
<tr>
<td align="center">参数名</td>
<td align="center">说明</td>
</tr>
 <tr>
  <td >clientPort</td>
  <td >客户端连接server的端口，即对外服务端口，默认2181</td>
</tr>
<tr>
  <td >dataDir</td>
  <td >存储快照文件snapshot的目录。默认情况下，事务日志也会存储在这里。建议同时配置参数dataLogDir, 事务日志的写性能直接影响zk性能。</td>
</tr>
<tr>
  <td >tickTime</td>
  <td >ZK中的一个时间单元。ZK中所有时间都是以这个时间单元为基础，进行整数倍配置的。例如，session的最小超时时间是2*tickTime。</td>
</tr>
<tr>
  <td >dataLogDir</td>
  <td >事务日志输出目录。尽量给事务日志的输出配置单独的磁盘或是挂载点，这将极大的提升ZK性能。</td>
</tr>
<tr>
  <td >globalOutstandingLimit</td>
  <td >最大请求堆积数。默认是1000。ZK运行的时候， 尽管server已经没有空闲来处理更多的客户端请求了，但是还是允许客户端将请求提交到服务器上来，以提高吞吐性能。当然，为了防止Server内存溢出，这个请求堆积数还是需要限制下的。 <br>
    (Java system property: <strong>zookeeper.globalOutstandingLimit.</strong>)</td>
</tr>
<tr>
  <td >preAllocSize</td>
  <td >预先开辟磁盘空间，用于后续写入事务日志。默认是64M，每个事务日志大小就是64M。如果ZK的快照频率较大的话，建议适当减小这个参数。(Java system property: <strong>zookeeper.preAllocSize</strong>)</td>
</tr>
<tr>
  <td >snapCount</td>
  <td >每进行snapCount次事务日志输出后，触发一次快照(snapshot), 此时，ZK会生成一个snapshot.*文件，同时创建一个新的事务日志文件log.*。默认是100000.（真正的代码实现中，会进行一定的随机数处理，以避免所有服务器在同一时间进行快照而影响性能）(Java system property: <strong>zookeeper.snapCount</strong>)</td>
</tr>
<tr>
  <td >traceFile</td>
  <td >用于记录所有请求的log，一般调试过程中可以使用，但是生产环境不建议使用，会严重影响性能。(Java system property:? <strong>requestTraceFile</strong>)</td>
</tr>
<tr>
  <td >maxClientCnxns</td>
  <td >单个客户端与单台服务器之间的连接数的限制，是ip级别的，默认是60，如果设置为0，那么表明不作任何限制。请注意这个限制的使用范围，仅仅是单台客户端机器与单台ZK服务器之间的连接数限制，不是针对指定客户端IP，也不是ZK集群的连接数限制，也不是单台ZK对所有客户端的连接数限制。</td>
</tr>
<tr>
  <td >clientPortAddress</td>
  <td >对于多网卡的机器，可以为每个IP指定不同的监听端口。默认情况是所有IP都监听 <strong>clientPort</strong>指定的端口。 <strong>New in 3.3.0</strong></td>
</tr>
<tr>
  <td >minSessionTimeoutmaxSessionTimeout</td>
  <td >Session超时时间限制，如果客户端设置的超时时间不在这个范围，那么会被强制设置为最大或最小时间。默认的Session超时时间是在2 * <strong>tickTime ~ 20 * tickTime</strong> <strong>这个范围</strong> <strong></strong> <strong>New in 3.3.0</strong></td>
</tr>
<tr>
  <td >fsync.warningthresholdms</td>
  <td >事务日志输出时，如果调用fsync方法超过指定的超时时间，那么会在日志中输出警告信息。默认是1000ms。(Java system property: <strong>fsync.warningthresholdms</strong>) <strong>New in 3.3.4</strong></td>
</tr>
<tr>
  <td >autopurge.purgeInterval</td>
  <td >在上文中已经提到，3.4.0及之后版本，ZK提供了自动清理事务日志和快照文件的功能，这个参数指定了清理频率，单位是小时，需要配置一个1或更大的整数，默认是0，表示不开启自动清理功能。(No Java system property) <strong>New in 3.4.0</strong></td>
</tr>
<tr>
  <td >autopurge.snapRetainCount</td>
  <td >这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。(No Java system property) <strong>New in 3.4.0</strong></td>
</tr>
<tr>
  <td >electionAlg</td>
  <td >在之前的版本中， 这个参数配置是允许我们选择leader选举算法，但是由于在以后的版本中，只会留下一种"TCP-based version of fast leader election"算法，所以这个参数目前看来没有用了，这里也不详细展开说了。(No Java system property)</td>
</tr>
<tr>
  <td >initLimit</td>
  <td >Follower在启动过程中，会从Leader同步所有最新数据，然后确定自己能够对外服务的起始状态。Leader允许F在 <strong>initLimit</strong>时间内完成这个工作。通常情况下，我们不用太在意这个参数的设置。如果ZK集群的数据量确实很大了，F在启动的时候，从Leader上同步数据的时间也会相应变长，因此在这种情况下，有必要适当调大这个参数了。(No Java system property)</td>
</tr>
<tr>
  <td >syncLimit</td>
  <td >在运行过程中，Leader负责与ZK集群中所有机器进行通信，例如通过一些心跳检测机制，来检测机器的存活状态。如果L发出心跳包在syncLimit之后，还没有从F那里收到响应，那么就认为这个F已经不在线了。注意：不要把这个参数设置得过大，否则可能会掩盖一些问题。(No Java system property)</td>
</tr>
<tr>
  <td >leaderServes</td>
  <td >默认情况下，Leader是会接受客户端连接，并提供正常的读写服务。但是，如果你想让Leader专注于集群中机器的协调，那么可以将这个参数设置为no，这样一来，会大大提高写操作的性能。(Java system property: zookeeper. <strong>leaderServes</strong>)。</td>
</tr>
<tr>
  <td >server.x=[hostname]:nnnnn[:nnnnn]</td>
  <td >这里的x是一个数字，与myid文件中的id是一致的。右边可以配置两个端口，第一个端口用于F和L之间的数据同步和其它通信，第二个端口用于Leader选举过程中投票通信。 <br>
    (No Java system property)</td>
</tr>
<tr>
  <td >group.x=nnnnn[:nnnnn]weight.x=nnnnn</td>
  <td >对机器分组和权重设置，可以 <a href="http://zookeeper.apache.org/doc/r3.4.6/zookeeperHierarchicalQuorums.html">参见这里</a>(No Java system property)</td>
</tr>
<tr>
  <td >cnxTimeout</td>
  <td >Leader选举过程中，打开一次连接的超时时间，默认是5s。(Java system property: zookeeper. <strong>cnxTimeout</strong>)</td>
</tr>
<tr>
  <td >zookeeper.DigestAuthenticationProvider <br>
    .superDigest</td>
  <td >ZK权限设置相关，具体参见 <a href="http://nileader.blog.51cto.com/1381108/930635">《 <strong>使用super</strong> <strong>身份对有权限的节点进行操作</strong>》</a> 和 <a href="http://nileader.blog.51cto.com/1381108/795525">《 <strong>ZooKeeper</strong> <strong>权限控制</strong>》</a></td>
</tr>
<tr>
  <td >skipACL</td>
  <td >对所有客户端请求都不作ACL检查。如果之前节点上设置有权限限制，一旦服务器上打开这个开头，那么也将失效。(Java system property: <strong>zookeeper.skipACL</strong>)</td>
</tr>
<tr>
  <td >forceSync</td>
  <td >这个参数确定了是否需要在事务日志提交的时候调用 <a href="http://rdc.taobao.com/team/%5C/java%5C/jdk1.6.0_22%5C/jre%5C/lib%5C/rt.jar%3Cjava.nio.channels(FileChannel.class%E2%98%83FileChannel">FileChannel</a>.force来保证数据完全同步到磁盘。(Java system property: <strong>zookeeper.forceSync</strong>)</td>
</tr>
<tr>
  <td >jute.maxbuffer</td>
  <td >每个节点最大数据量，是默认是1M。这个限制必须在server和client端都进行设置才会生效。(Java system property: <strong>jute.maxbuffer</strong>)</td>
</tr>
</table>


**常用的四字命令**
<table border="1" cellpadding="0" cellspacing="0" width="640">

  <tbody><tr>
   <td align="center">
     参数名 
</td>
   <td align="center">
     说明 
</td>
</tr>
  <tr>
   <td >conf</td>
   <td >输出server的详细配置信息。    <strong>New in 3.3.0</strong>    <p></p>
    <blockquote>     <p>$&gt;echo conf|nc localhost 2181      <br>
clientPort=2181      <br>
dataDir=/home/test/taokeeper/zk_data/version-2      <br>
dataLogDir=/test/admin/taokeeper/zk_log/version-2      <br>
tickTime=2000      <br>
maxClientCnxns=1000      <br>
minSessionTimeout=4000      <br>
maxSessionTimeout=40000      <br>
serverId=2      <br>
initLimit=10      <br>
syncLimit=5      <br>
electionAlg=3      <br>
electionPort=3888      <br>
quorumPort=2888      <br>
peerType=0</p></blockquote>
</td>
</tr>
  <tr>
   <td >cons</td>
   <td >输出指定server上所有客户端连接的详细信息，包括客户端IP，会话ID等。    <br>
    <strong>New in 3.3.0</strong>类似于这样的信息：    <p></p>
    <blockquote>     <p>$&gt;echo cons|nc localhost 2181      <br>
/1.2.3.4:43527[1](queued=0,recved=152802,sent=152806,sid=0x2389e662b98c424,lop=PING,      <br>
est=1350385542196,to=6000,lcxid=0×114,lzxid=0xffffffffffffffff,lresp=1350690663308,      <br>
llat=0,minlat=0,avglat=0,maxlat=483)      <br>
……</p></blockquote>
</td>
</tr>
  <tr>
   <td >crst</td>
   <td >功能性命令。重置所有连接的    <strong>统计</strong>信息。    <strong>New in 3.3.0</strong></td>
</tr>
  <tr>
   <td >dump</td>
   <td >这个命令针对Leader执行，用于输出所有等待队列中的会话和临时节点的信息。</td>
</tr>
  <tr>
   <td >envi</td>
   <td >用于输出server的环境变量。包括操作系统环境和Java环境。</td>
</tr>
  <tr>
   <td >ruok</td>
   <td >用于测试server是否处于无错状态。如果正常，则返回“imok”,否则没有任何响应。    <br>
注意：ruok不是一个特别有用的命令，它不能反映一个server是否处于正常工作。“stat”命令更靠谱。</td>
</tr>
  <tr>
   <td >stat</td>
   <td >输出server简要状态和连接的客户端信息。</td>
</tr>
  <tr>
   <td >srvr</td>
   <td >和stat类似，    <strong>New in 3.3.0</strong>    <p></p>
    <blockquote>     <p>$&gt;echo stat|nc localhost 2181      <br>
Zookeeper version: 3.3.5-1301095, built on 03/15/2012 19:48 GMT      <br>
Clients:      <br>
/10.2.3.4:59179[1](queued=0,recved=44845,sent=44845)</p>
     <p>Latency min/avg/max: 0/0/1036      <br>
Received: 2274602238      <br>
Sent: 2277795620      <br>
Outstanding: 0      <br>
Zxid: 0xa1b3503dd      <br>
Mode: leader      <br>
Node count: 37473</p></blockquote>
    <blockquote>     <p>$&gt;echo srvr|nc localhost 2181      <br>
Zookeeper version: 3.3.5-1301095, built on 03/15/2012 19:48 GMT      <br>
Latency min/avg/max: 0/0/980      <br>
Received: 2592698547      <br>
Sent: 2597713974      <br>
Outstanding: 0      <br>
Zxid: 0xa1b356b5b      <br>
Mode: follower      <br>
Node count: 37473</p></blockquote>
</td>
</tr>
  <tr>
   <td >srst</td>
   <td >重置server的统计信息。</td>
</tr>
  <tr>
   <td >wchs</td>
   <td >列出所有watcher信息概要信息，数量等：    <strong>New in 3.3.0</strong>    <p></p>
    <blockquote>     <p>$&gt;echo wchs|nc localhost 2181      <br>
3890 connections watching 537 paths      <br>
Total watches:6909</p></blockquote>
</td>
</tr>
  <tr>
   <td >wchc</td>
   <td >列出所有watcher信息，以watcher的session为归组单元排列，列出该会话订阅了哪些path：    <strong>New in 3.3.0</strong>    <p></p>
    <blockquote>     <p>$&gt;echo wchc|nc localhost 2181      <br>
0x2389e662b97917f      <br>
/mytest/test/path1/node1      <br>
0x3389e65c83cd790      <br>
/mytest/test/path1/node2      <br>
0x1389e65c7ef6313      <br>
/mytest/test/path1/node3      <br>
/mytest/test/path1/node1</p></blockquote>
</td>
</tr>
  <tr>
   <td >wchp</td>
   <td >列出所有watcher信息，以watcher的path为归组单元排列，列出该path被哪些会话订阅着：    <strong>New in 3.3.0</strong>    <strong></strong>    <p></p>
    <blockquote>     <p>$&gt;echo wchp|nc localhost 2181      <br>
/mytest/test/path1/node      <br>
0x1389e65c7eea4f5      <br>
0x1389e65c7ee2f68      <br>
/mytest/test/path1/node2      <br>
0x2389e662b967c29      <br>
/mytest/test/path1/node3      <br>
0x3389e65c83dd2e0      <br>
0x1389e65c7f0c37c      <br>
0x1389e65c7f0c364</p></blockquote>
    <p>注意，wchc和wchp这两个命令执行的输出结果都是针对session的，对于运维人员来说可视化效果并不理想，可以尝试将cons命令执行输出的信息整合起来，就可以用客户端IP来代替会话ID了，具体可以看这个实现：     <a href="http://rdc.taobao.com/team/jm/archives/1450">http://rdc.taobao.com/team/jm/archives/1450</a>     <strong></strong></p></td>
</tr>
  <tr>
   <td >mntr</td>
   <td >输出一些ZK运行时信息，通过对这些返回结果的解析，可以达到监控的效果。    <strong>New in 3.4.0</strong>    <p></p>
    <blockquote>     <p>$ echo mntr | nc localhost 2185      <br>
zk_version 3.4.0      <br>
zk_avg_latency 0      <br>
zk_max_latency 0      <br>
zk_min_latency 0      <br>
zk_packets_received 70      <br>
zk_packets_sent 69      <br>
zk_outstanding_requests 0      <br>
zk_server_state leader      <br>
zk_znode_count 4      <br>
zk_watch_count 0      <br>
zk_ephemerals_count 0      <br>
zk_approximate_data_size 27      <br>
zk_followers 4 – only exposed by the Leader      <br>
zk_synced_followers 4 – only exposed by the Leader      <br>
zk_pending_syncs 0 – only exposed by the Leader      <br>
zk_open_file_descriptor_count 23 – only available on Unix platforms      <br>
zk_max_file_descriptor_count 1024 – only available on Unix platforms</p></blockquote>
</td>
</tr>

</tbody></table>


**数据文件管理**

默认情况下，ZK的数据文件和事务日志是保存在同一个目录中，建议是将事务日志存储到单独的磁盘上。

- 数据目录,ZK的数据目录包含两类文件：

	- myid – 这个文件只包含一个数字，和server id对应。
	- snapshot. – 按zxid先后顺序的生成的数据快照。
集群中的每台ZK server都会有一个用于惟一标识自己的id，有两个地方会使用到这个id：myid文件和zoo.cfg文件中。myid文件存储在dataDir目录中，指定了当前server的server id。在zoo.cfg文件中，根据server id，配置了每个server的ip和相应端口。Zookeeper启动的时候，读取myid文件中的server id，然后去zoo.cfg 中查找对应的配置。

zookeeper在进行数据快照过程中，会生成 snapshot文件，存储在dataDir目录中。文件后缀是zxid，也就是事务id。（这个zxid代表了zk触发快照那个瞬间，提交的最后一个事务id）。注意，一个快照文件中的数据内容和提交第zxid个事务时内存中数据近似相同。仅管如此，由于更新操作的幂等性，ZK还是能够从快照文件中恢复数据。数据恢复过程中，将事务日志和快照文件中的数据对应起来，就能够恢复最后一次更新后的数据了。

- 事务日志目录

dataLogDir目录是ZK的事务日志目录，包含了所有ZK的事务日志。正常运行过程中，针对所有更新操作，在返回客户端“更新成功”的响应前，ZK会确保已经将本次更新操作的事务日志写到磁盘上，只有这样，整个更新操作才会生效。每触发一次数据快照，就会生成一个新的事务日志。事务日志的文件名是log.，zxid是写入这个文件的第一个事务id。

- 文件管理
不同的zookeeper server生成的snapshot文件和事务日志文件的格式都是一致的（无论是什么环境，或是什么样的zoo.cfg 配置）。因此，如果某一天生产环境中出现一些古怪的问题，你就可以把这些文件下载到开发环境的zookeeper中加载起来，便于调试发现问题，而不会影响生产运行。另外，使用这些较旧的snapshot和事务日志，我们还能够方便的让ZK回滚到一个历史状态。

另外，ZK提供的工具类LogFormatter能够帮助可视化ZK的事务日志，帮助我们排查问题，关于事务日志的可以化，请查看这个文章 《可视化zookeeper的事务日志》.

需要注意的一点是，zookeeper在运行过程中，不断地生成snapshot文件和事务日志，但是不会自动清理它们，需要管理员来处理。（ZK本身只需要使用最新的snapshot和事务日志即可）关于如何清理文件，上面章节“日常运维”有提到。

- 注意事项

	- 保持Server地址列表一致
客户端使用的server地址列表必须和集群所有server的地址列表一致。（如果客户端配置了集群机器列表的子集的话，也是没有问题的，只是少了客户端的容灾。）
集群中每个server的zoo.cfg中配置机器列表必须一致。
	- 独立的事务日志输出
对于每个更新操作，ZK都会在确保事务日志已经落盘后，才会返回客户端响应。因此事务日志的输出性能在很大程度上影响ZK的整体吞吐性能。强烈建议是给事务日志的输出分配一个单独的磁盘。

	- 配置合理的JVM堆大小
确保设置一个合理的JVM堆大小，如果设置太大，会让内存与磁盘进行交换，这将使ZK的性能大打折扣。例如一个4G内存的机器的，如果你把JVM的堆大小设置为4G或更大，那么会使频繁发生内存与磁盘空间的交换，通常设置成3G就可以了。当然，为了获得一个最好的堆大小值，在特定的使用场景下进行一些压力测试。
