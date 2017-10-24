<p>配置文件说明，官网的最权威</p>
<p>ZooKeeper官网配置参数详解<br></p>
<p><a href="http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_minimumConfiguration" target="_blank">http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_minimumConfiguration</a> </p>
<p><br></p>
<p>下面列出一些自认为比较有用和重要的参数：</p>
<p><br></p>
<p><strong>clientPort</strong></p>
<p>客户端连接server的端口，即对外服务端口，一般设置为2181吧。</p>
<p><strong>dataDir</strong></p>
<p>存储快照文件snapshot的目录。默认情况下，事务日志也会存储在这里。建议同时配置参数dataLogDir, 事务日志的写性能直接影响zk性能。</p>
<p><strong>tickTime</strong><br></p>
<p>ZK中的一个时间单元。ZK中所有时间都是以这个时间单元为基础，进行整数倍配置的。例如，session的最小超时时间是2*tickTime。</p>
<p><strong>dataLogDir</strong><br></p>
<p>事务日志输出目录。尽量给事务日志的输出配置单独的磁盘或是挂载点，这将极大的提升ZK性能。 （No Java system property）<br></p>
<p><strong>globalOutstandingLimit</strong><br></p>
<p>最大请求堆积数。默认是1000。ZK运行的时候， 尽管server已经没有空闲来处理更多的客户端请求了，但是还是允许客户端将请求提交到服务器上来，以提高吞吐性能。当然，为了防止Server内存溢出，这个请求堆积数还是需要限制下的。 (Java system property:?zookeeper.globalOutstandingLimit.)</p>
<p><strong>snapCount</strong><br></p>
<p>每进行snapCount次事务日志输出后，触发一次快照(snapshot), 此时，ZK会生成一个snapshot.*文件，同时创建一个新的事务日志文件log.*。默认是100000.（真正的代码实现中，会进行一定的随机数处理，以避免所有服务器在同一时间进行快照而影响性能）(Java system property:zookeeper.snapCount)&nbsp;</p>
<p><strong>initLimit</strong></p>
<p>Follower在启动过程中，会从Leader同步所有最新数据，然后确定自己能够对外服务的起始状态。Leader允许F在initLimit时间内完成这个工作。通常情况下，我们不用太在意这个参数的设置。如果ZK集群的数据量确实很大了，F在启动的时候，从Leader上同步数据的时间也会相应变长，因此在这种情况下，有必要适当调大这个参数了。(No Java system property)</p>
<p><strong>syncLimit</strong></p>
<p>在运行过程中，Leader负责与ZK集群中所有机器进行通信，例如通过一些心跳检测机制，来检测机器的存活状态。如果L发出心跳包在syncLimit之后，还没有从F那里收到响应，那么就认为这个F已经不在线了。注意：不要把这个参数设置得过大，否则可能会掩盖一些问题。(No Java system property)</p>
<p><br></p>
