<p>本文系统：Centos6.5 x64</p>
<p>一、单机模式安装<br></p>
<p>二、伪集群模式安装</p>
<p>三、集群模式安装</p>
<p>1、单机模式安装zookeeper</p>
<p>1.1、创建帐号zk</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;useradd&nbsp;-d&nbsp;/opt/zk&nbsp;zk
[root@master&nbsp;~]#&nbsp;echo&nbsp;"zk"&nbsp;|passwd&nbsp;--stdin&nbsp;zk</pre>
<p>1.2、下载、解压、</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;su&nbsp;-&nbsp;zk
[zk@master&nbsp;~]$&nbsp;pwd
/opt/zk
[zk@master&nbsp;~]$&nbsp;&nbsp;wget&nbsp;
[zk@master&nbsp;~]$&nbsp;tar&nbsp;zxvf&nbsp;zookeeper-3.5.0-alpha.tar.gz
[zk@master&nbsp;~]$&nbsp;mv&nbsp;zookeeper-3.5.0-alpha&nbsp;zk</pre>
<p>1.3、配置当前用户环境变量</p>
<pre class="brush:bash;toolbar:false">export&nbsp;ZOOKEEPER_HOME=/opt/zk/zk
PATH=$ZOOKEEPER_HOME/bin:$PATH
export&nbsp;PATH</pre>
<p>1.4、配置配置文件zoo.cfg</p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;conf]$&nbsp;cat&nbsp;zoo.cfg
initLimit=10
syncLimit=5
clientPort=2181
tickTime=2000
dataDir=/opt/zk/zk/data
dataLogDir=/opt/zk/zk/logs</pre>
<p>1.5、启动zk</p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;bin]$&nbsp;pwd
/opt/zk/zk/bin
[zk@master&nbsp;bin]$&nbsp;./zkServer.sh&nbsp;start</pre>
<p>1.6、客户端链接测试下：</p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;bin]$&nbsp;pwd
/opt/zk/zk/bin
[zk@master&nbsp;bin]$&nbsp;./zkCli.sh&nbsp;-server&nbsp;localhost:2181
Connecting&nbsp;to&nbsp;localhost:2181
。。。
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;0]&nbsp;ls&nbsp;/
[zookeeper]
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;1]&nbsp;create&nbsp;/Test&nbsp;hellozk
Created&nbsp;/Test
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;get&nbsp;/Test
hellozk
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;3]&nbsp;set&nbsp;/Test&nbsp;hellozookeeper
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;4]&nbsp;get&nbsp;/Test
hellozookeeper
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;5]&nbsp;delete&nbsp;/Test
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;6]&nbsp;get&nbsp;/Test
Node&nbsp;does&nbsp;not&nbsp;exist:&nbsp;/Test
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;7]&nbsp;quit
2014-11-19&nbsp;03:53:50,180&nbsp;[myid:]&nbsp;-&nbsp;INFO&nbsp;&nbsp;[main:ZooKeeper@968]&nbsp;-&nbsp;Session:&nbsp;0x149c475d7db0000&nbsp;closed
2014-11-19&nbsp;03:53:50,182&nbsp;[myid:]&nbsp;-&nbsp;INFO&nbsp;&nbsp;[main-EventThread:ClientCnxn$EventThread@529]&nbsp;-&nbsp;EventThread&nbsp;shut&nbsp;down</pre>
<p>zookeeper的配置文件说明：</p>
<pre class="brush:bash;toolbar:false">clientPort&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;客户端连接server的端口，即对外服务端口，一般设置为2181。
dataDir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;存储快照文件snapshot的目录。默认情况下，事务日志也会存储在这里。建议同时配置参数dataLogDir,&nbsp;事务日志的写性能直接影响zk性能。
tickTime&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;ZK中的一个时间单元。ZK中所有时间都是以这个时间单元为基础，进行整数倍配置的。例如，session的最小超时时间是2*tickTime。
dataLogDir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;事务日志输出目录。尽量给事务日志的输出配置单独的磁盘或是挂载点，这将极大的提升ZK性能。&nbsp;
globalOutstandingLimit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;最大请求堆积数。默认是1000。ZK运行的时候，&nbsp;尽管server已经没有空闲来处理更多的客户端请求了，但是还是允许客户端将请求提交到服务器上来，提高吞吐性能。当然，为了防止Server内存溢出，这个请求堆积数还是需要限制下的。&nbsp;Java&nbsp;system&nbsp;property:zookeeper.globalOutstandingLimit.&nbsp;
preAllocSize&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;预先开辟磁盘空间，用于后续写入事务日志。默认是64M，每个事务日志大小就是64M。如果ZK的快照频率较大的话，建议适当减小这个参数。
snapCount&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;每进行snapCount次事务日志输出后，触发一次快照(snapshot),&nbsp;此时，ZK会生成一个snapshot.*文件，同时创建一个新的事务日志文件log.*。默认是100000.（真正的代码实现中，会进行一定的随机数处理，以避免所有服务器在同一时间进行快照而影响性能）。
traceFile&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;用于记录所有请求的log，一般调试过程中可以使用，但是生产环境不建议使用，会严重影响性能
maxClientCnxns&nbsp;&nbsp;#&nbsp;单个客户端与单台服务器之间的连接数的限制，是ip级别的，默认是60，如果设置为0，那么表明不作任何限制。请注意这个限制的使用范围，仅仅是单台客户端机器与单台ZK服务器之间的连接数限制，不是针对指定客户端IP，也不是ZK集群的连接数限制，也不是单台ZK对所有客户端的连接数限制。
clientPortAddress&nbsp;#&nbsp;对于多网卡的机器，可以为每个IP指定不同的监听端口。默认情况是所有IP都监听&nbsp;clientPort&nbsp;指定的端口。
minSessionTimeoutmaxSessionTimeout&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;Session超时时间限制，如果客户端设置的超时时间不在这个范围，那么会被强制设置为最大或最小时间。默认的Session超时时间是在2&nbsp;*&nbsp;tickTime&nbsp;~&nbsp;20&nbsp;*&nbsp;tickTime&nbsp;这个范围&nbsp;。
fsync.warningthresholdms&nbsp;&nbsp;&nbsp;#&nbsp;事务日志输出时，如果调用fsync方法超过指定的超时时间，那么会在日志中输出警告信息。默认是1000ms。
autopurge.purgeInterval&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;3.4.0及之后版本，ZK提供了自动清理事务日志和快照文件的功能，这个参数指定了清理频率，单位是小时，需要配置一个1或更大的整数，默认是0，表不开启自动清理功能
autopurge.snapRetainCount&nbsp;&nbsp;#&nbsp;这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。
electionAlg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#在之前的版本中，&nbsp;这个参数配置是允许我们选择leader选举算法，但是由于在以后的版本中，只会留下一种“TCP-based&nbsp;version&nbsp;of&nbsp;fast&nbsp;leader&nbsp;election”算法，所以这个参数目前看来没有用了。
initLimit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;Follower在启动过程中，会从Leader同步所有最新数据，然后确定自己能够对外服务的起始状态。Leader允许F在&nbsp;initLimit&nbsp;时间内完成这个工作。通常情况下，我们不用太在意这个参数的设置。如果ZK集群的数据量确实很大了，F在启动的时候，从Leader上同步数据的时间也会相应变长，因此在这种情况下，有必要适当调大这个参数了。
syncLimit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;在运行过程中，Leader负责与ZK集群中所有机器进行通信，例如通过一些心跳检测机制，来检测机器的存活状态。如果L发出心跳包在syncLimit之后，还没有从F那收到响应，那么就认为这个F已经不在线了。注意：不要把这个参数设置得过大，否则可能会掩盖一些问题。
leaderServes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;默认情况下，Leader是会接受客户端连接，并提供正常的读写服务。但是，如果你想让Leader专注于集群中机器的协调，那么可以将这个参数设置为no，这样一来，会大大提高写操作的性能。
server.X=A:B:C&nbsp;&nbsp;#&nbsp;其中X是一个数字,&nbsp;表示这是第几号server.&nbsp;A是该server所在的IP地址.&nbsp;B配置该server和集群中的leader交换消息所使用的端口.&nbsp;C配置选举leader时所使用的端口.&nbsp;这里的x是一个数字，与myid文件中的id是一致的。右边可以配置两个端口，第一个端口用于F和L之间的数据同步和其它通信，第二个端口用于Leader选举过程中投票通信。&nbsp;&nbsp;
group.x=nnnnn[:nnnnn]weight.x=nnnnn&nbsp;&nbsp;#&nbsp;对机器分组和权重设置，
cnxTimeout&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;Leader选举过程中，打开一次连接的超时时间，默认是5s
zookeeper.DigestAuthenticationProvider.superDigest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;ZK权限设置相关
skipACL&nbsp;&nbsp;&nbsp;&nbsp;#&nbsp;对所有客户端请求都不作ACL检查。如果之前节点上设置有权限限制，一旦服务器上打开这个开头，那么也将失效
forceSync&nbsp;&nbsp;&nbsp;#&nbsp;这个参数确定了是否需要在事务日志提交的时候调用&nbsp;FileChannel&nbsp;.force来保证数据完全同步到磁盘
jute.maxbuffer&nbsp;&nbsp;#&nbsp;每个节点最大数据量，是默认是1M。这个限制必须在server和client端都进行设置才会生效。</pre>
<p><br></p>
<p>2、伪集群模式安装：</p>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">伪集群, 是指在单台机器中启动多个zookeeper进程, 并组成一个集群. 以启动3个zookeeper进程为例</span></p>
<p>2.1、拷贝zk目录，分别为zk2、zk3<br></p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;~]$&nbsp;cp&nbsp;-r&nbsp;zk&nbsp;zk2&nbsp;
[zk@master&nbsp;~]$&nbsp;cp&nbsp;-r&nbsp;zk&nbsp;zk3</pre>
<p>2.2、分别修改配置文件<br></p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;conf]$&nbsp;vim&nbsp;zoo.cfg

initLimit=10
syncLimit=5
clientPort=2181
tickTime=2000
dataDir=/opt/zk/zk/data
dataLogDir=/opt/zk/zk/logs
server.0=127.0.0.1:5555:6666
server.1=127.0.0.1:5556:6667
server.2=127.0.0.1:5557:6668</pre>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">分别修改其他俩个zk目录配置文件<span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">dataDir, dataLogDir, clientPort参数即可.</span></span></p>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">分别在zk、zk2、zk3、的dataDir中新建myid文件, 写入一个数字, 该数字表示这是第几号server. 该数字必须和zoo.cfg文件中的server.X中的X一一对应.</span><br style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;white-space:normal;background-color:rgb(255,255,255);"><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">/opt/zk/zk/data/myid文件中写入0, /opt/zk/zk2/data/myid文件中写入1, /opt/zk/zk3/data/myid文件中写入2.</span></p>
<pre class="brush:bash;toolbar:false">[zk@master&nbsp;~]$&nbsp;echo&nbsp;0&nbsp;&gt;&nbsp;/opt/zk/zk/data/myid&nbsp;
[zk@master&nbsp;~]$&nbsp;echo&nbsp;1&nbsp;&gt;&nbsp;/opt/zk/zk2/data/myid
[zk@master&nbsp;~]$&nbsp;echo&nbsp;2&nbsp;&gt;&nbsp;/opt/zk/zk3/data/myid</pre>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);"></span>2.3、分别启动</p>
<p>略<br></p>
<p>3、集群模式安装</p>
<p><br></p>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">集群模式的配置和伪集群基本一致.</span><br style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;white-space:normal;background-color:rgb(255,255,255);"><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">由于集群模式下, 各server部署在不同的机器上, 因此各server的conf/zoo.cfg文件可以完全一样.</span></p>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">示例：<br></span></p>
<pre class="brush:bash;toolbar:false">tickTime=2000&nbsp;&nbsp;&nbsp;&nbsp;
initLimit=5&nbsp;&nbsp;&nbsp;&nbsp;
syncLimit=2&nbsp;&nbsp;&nbsp;&nbsp;
dataDir=/opt/zk/zk/data&nbsp;&nbsp;&nbsp;&nbsp;
dataLogDir=/opt/zk/zk/logs&nbsp;&nbsp;&nbsp;&nbsp;
clientPort=2180&nbsp;&nbsp;
server.0=192.168.10.128:5555:6666&nbsp;&nbsp;
server.1=192.168.10.129:5555:6666&nbsp;&nbsp;&nbsp;&nbsp;
server.2=192.168.10.130:5555:6666</pre>
<p><span style="color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);"></span></p>
<p style="margin-top:15px;margin-bottom:15px;padding:0px;white-space:normal;border:0px;color:rgb(51,51,51);font-family:Helvetica, arial, freesans, clean, sans-serif;font-size:15px;line-height:25px;background-color:rgb(255,255,255);">示例文件部署了3台zookeeper server, 分别部署在192.168.10.128~130上. 需要注意的是, 各server的dataDir目录下的myid文件中的数字必须不同.</p>
<p><br></p>
<p>本文出自 “<a href="http://lansgg.blog.51cto.com">大&#xfffd;</a>” 博客，请务必保留此出处<a href="http://lansgg.blog.51cto.com/5675165/1579651">http://lansgg.blog.51cto.com/5675165/1579651</a></p>
