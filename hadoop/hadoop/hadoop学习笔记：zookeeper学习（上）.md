<p>出处：<a href="http://www.cnblogs.com/sharpxiajun/p/3294581.html" target="_blank">http://www.cnblogs.com/sharpxiajun/p/3294581.html</a></p>
<p><br></p>
<p><strong><span style="font-family:'宋体';">大型网站架构交流</span></strong><strong>QQ</strong><strong><span style="font-family:'宋体';">群：</span></strong><strong>466097527 </strong><strong><span style="font-family:'宋体';">每周技术分享</span></strong><strong> </strong><strong><span style="font-family:'宋体';">经典电子书分享</span></strong><strong> </strong><strong><span style="font-family:'宋体';">欢迎加群</span></strong></p>
<p><strong><span style="font-family:'宋体';"><br></span></strong></p>
<p>在前面的文章里我多次提到zookeeper对于分布式系统开发的重要性，因此对zookeeper的学习是非常必要的。本篇博文主要是讲解zookeeper的安装和zookeeper的一些基本的应用，同时我还会教大家如何安装伪分布式，伪分布式不能在windows下实现，只能在linux下实现，我的伪分布式是通过电脑的虚拟机完成了，好了，不废话了，具体内容如下：</p>
<p><br></p>
<p>　　首先我们要下载一个zookeeper，下载地址是：</p>
<p><br></p>
<p>　　http://www.apache.org/dyn/closer.cgi/zookeeper/</p>
<p><br></p>
<p>　　一般我们会选择一个stable版（稳定版）进行下载，我下载的版本是zookeeper-3.4.5。</p>
<p><br></p>
<p>　　我笔记本的操作系统是windows7，windows操作系统可以作为zookeeper的开发平台，但是不能作为zookeeper的生产平台，首先我们在windows下安装一个单机版的zookeeper。</p>
<p><br></p>
<p>　　我们先解压zookeeper的安装包，解压后的zookeeper安装包我放置的路径是：</p>
<p><br></p>
<p>　　E:\zookeeper\zookeeper-3.4.5</p>
<p><br></p>
<p>　　下图是zookeeper的目录结构：</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>　　我们进入conf包，将zoo_sample.cfg文件复制一份，并将复制好的文件改名为zoo.cfg。打开新建的zoo.cfg文件，将里面的内容进行修改，修改后的文件内容如下：</p>
<p><br></p>
<p>#initLimit=10</p>
<p>#syncLimit=5</p>
<p>tickTime=2000</p>
<p>dataDir=E:/zookeeper/zookeeper-3.4.5/data</p>
<p>clientPort=2181</p>
<p>&nbsp;　　下面我来解释下配置文件里的各个参数：</p>
<p><br></p>
<p>　　initLimit和syncLimit是针对集群的参数，在我后面讲解伪分布式安装时候我会再讲解。</p>
<p><br></p>
<p>　　tickTime：该参数用来定义心跳的间隔时间，zookeeper的客户端和服务端之间也有和web开发里类似的session的概念，而zookeeper里最小的session过期时间就是tickTime的两倍。</p>
<p><br></p>
<p>　　dataDir：英文注释可以翻译为存储在内存中的数据库快照功能，我们可以看看运行后dataDir所指向的文件存储了什么样的数据，如下图所示：</p>
<p><br></p>
<p>&nbsp;</p>
<p><br></p>
<p>　　看来dataDir里还存储了日志信息，dataDir不能存放在命名为tmp的文件里。</p>
<p><br></p>
<p>　　clientPort：是监听客户端连接的端口号。</p>
<p><br></p>
<p>　　接下来我们要将zookeeper的安装信息配置到windows的环境变量里，我们在“我的电脑”上点击右键，选择属性，再点击高级系统设置，点击环境变量按钮，在系统变量这一栏，点击新建，添加：</p>
<p><br></p>
<p>变量名：ZOOKEEPER_HOME</p>
<p>变量值：E:\zookeeper\zookeeper-3.4.5</p>
<p>&nbsp;　　还是在系统变量这一栏，找到path，点击编辑path，在变量值里添加：% ZOOKEEPER_HOME %\bin; % ZOOKEEPER_HOME %\conf;</p>
<p><br></p>
<p>　　Zookeeper使用java编写的，因此安装zookeeper之前一定要先安装好jdk，并且jdk的版本要大于或等于1.6。</p>
<p><br></p>
<p>　　这样单机版的zookeeper就安装好了，下面我们将运行zookeeper。</p>
<p><br></p>
<p>　　首先我们打开windows的命令行工具，将文件夹转到zookeeper安装目录的下的bin目录，然后输入zkServer命令，回车执行，那么zookeeper服务就启动成功了。</p>
<p><br></p>
<p>　　下面我们用客户端连接zookeeper的服务端，我们再打开一个命令行工具，输入命令：</p>
<p><br></p>
<p>zkCli -server localhost:2181</p>
<p>&nbsp;　　下面是相关测试，如下图所示：</p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>　　伪分布式的安装，zookeeper和hadoop一样也可以进行伪分布式的安装，下面我就讲解如何进行伪分布式安装。</p>
<p><br></p>
<p>　　我开始尝试在windows下安装伪分布式，但是没有成功，最后是在linux操作系统下才安装好伪分布式，我们首先下载好zookeeper的安装程序，然后新建三个配置文件分别是：</p>
<p><br></p>
<p>zoo1.cfg:</p>
<p><br></p>
<p># The number of milliseconds of each tick</p>
<p>tickTime=2000</p>
<p># The number of ticks that the initial&nbsp;</p>
<p># synchronization phase can take</p>
<p>initLimit=10</p>
<p># The number of ticks that can pass between&nbsp;</p>
<p># sending a request and getting an acknowledgement</p>
<p>syncLimit=5</p>
<p># the directory where the snapshot is stored.</p>
<p># do not use /tmp for storage, /tmp here is just&nbsp;</p>
<p># example sakes.</p>
<p>dataDir=E:/zookeeper/zookeeper-3.4.5/d_1</p>
<p># the port at which the clients will connect</p>
<p>clientPort=2181</p>
<p>#</p>
<p># Be sure to read the maintenance section of the&nbsp;</p>
<p># administrator guide before turning on autopurge.</p>
<p>#</p>
<p># http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance</p>
<p>#</p>
<p># The number of snapshots to retain in dataDir</p>
<p>#autopurge.snapRetainCount=3</p>
<p># Purge task interval in hours</p>
<p># Set to "0" to disable auto purge feature</p>
<p>#autopurge.purgeInterval=1</p>
<p>dataLogDir=E:/zookeeper/zookeeper-3.4.5/log1_2</p>
<p>server.1=localhost:2887:3887</p>
<p>server.2=localhost:2888:3888</p>
<p>server.3=localhost:2889:3889</p>
<p>&nbsp;zoo2.cfg:</p>
<p><br></p>
<p># The number of milliseconds of each tick</p>
<p>tickTime=2000</p>
<p># The number of ticks that the initial&nbsp;</p>
<p># synchronization phase can take</p>
<p>initLimit=10</p>
<p># The number of ticks that can pass between&nbsp;</p>
<p># sending a request and getting an acknowledgement</p>
<p>syncLimit=5</p>
<p># the directory where the snapshot is stored.</p>
<p># do not use /tmp for storage, /tmp here is just&nbsp;</p>
<p># example sakes.</p>
<p>dataDir=E:/zookeeper/zookeeper-3.4.5/d_2</p>
<p># the port at which the clients will connect</p>
<p>clientPort=2182</p>
<p>#</p>
<p># Be sure to read the maintenance section of the&nbsp;</p>
<p># administrator guide before turning on autopurge.</p>
<p>#</p>
<p># http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance</p>
<p>#</p>
<p># The number of snapshots to retain in dataDir</p>
<p>#autopurge.snapRetainCount=3</p>
<p># Purge task interval in hours</p>
<p># Set to "0" to disable auto purge feature</p>
<p>#autopurge.purgeInterval=1</p>
<p>dataLogDir=E:/zookeeper/zookeeper-3.4.5/logs_2</p>
<p>server.1=localhost:2887:3887</p>
<p>server.2=localhost:2888:3888</p>
<p>server.3=localhost:2889:3889</p>
<p>&nbsp;zoo3.cfg:</p>
<p><br></p>
<p># The number of milliseconds of each tick</p>
<p>tickTime=2000</p>
<p># The number of ticks that the initial&nbsp;</p>
<p># synchronization phase can take</p>
<p>initLimit=10</p>
<p># The number of ticks that can pass between&nbsp;</p>
<p># sending a request and getting an acknowledgement</p>
<p>syncLimit=5</p>
<p># the directory where the snapshot is stored.</p>
<p># do not use /tmp for storage, /tmp here is just&nbsp;</p>
<p># example sakes.</p>
<p>dataDir=E:/zookeeper/zookeeper-3.4.5/d_3</p>
<p># the port at which the clients will connect</p>
<p>clientPort=2183</p>
<p>#</p>
<p># Be sure to read the maintenance section of the&nbsp;</p>
<p># administrator guide before turning on autopurge.</p>
<p>#</p>
<p># http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance</p>
<p>#</p>
<p># The number of snapshots to retain in dataDir</p>
<p>#autopurge.snapRetainCount=3</p>
<p># Purge task interval in hours</p>
<p># Set to "0" to disable auto purge feature</p>
<p>#autopurge.purgeInterval=1</p>
<p>dataLogDir=E:/zookeeper/zookeeper-3.4.5/logs_3</p>
<p>server.1=localhost:2887:3887</p>
<p>server.2=localhost:2888:3888</p>
<p>server.3=localhost:2889:3889</p>
<p>&nbsp;　　这里我们把每个配置文件里的clientPort做了一定修改，让每个文件之间的clientPort不一样，dataDir属性也做了同样的调整，同时还添加了新配置内容，如下所示：</p>
<p><br></p>
<p>server.1=localhost:2887:3887</p>
<p>server.2=localhost:2888:3888</p>
<p>server.3=localhost:2889:3889</p>
<p>&nbsp;　　这里localhost指的是组成zookeeper服务的机器IP的地址，2887是用于进行leader选举的端口，3887是zookeeper集群里各个机器之间的通信接口。</p>
<p><br></p>
<p>　　initLimit：是指follower连接并同步到leader的初始化连接，它是通过tickTime的倍数表示，例如我们上面的配置就是10倍的tickTime，当初始化连接时间超过设置的倍数时候则连接失败。</p>
<p><br></p>
<p>　　syncLimit：是指follower和leader之间发送消息时请求和应答的时间长度，如果follower在设置的时间范围内不能喝leader通信，那么该follower将会被丢弃，它也是按tickTime的倍数进行设置的。</p>
<p><br></p>
<p>　　dataLogDir：这个配置是指zookeeper运行的相关日志写入的目录，设定了配置，那么dataLog里日志的目录将无效，专门的日志存放路径，对zookeeper的性能和稳定性有好处。</p>
<p><br></p>
<p>　　这里每一个配置文件都代表一个zookeeper服务器，下面我们启动伪分布式的zookeeper集群。</p>
<p><br></p>
<p>zkServer.sh start zoo1.cfg</p>
<p>&nbsp;</p>
<p>zkServer.sh start zoo2.cfg</p>
<p>&nbsp;</p>
<p>zkServer.sh start zoo3.cfg</p>
<p>&nbsp;</p>
<p><br></p>
<p>&nbsp;　　下面我写一个java程序，该程序作为客户端调用zookeeper的服务，代码如下：</p>
<p><br></p>
<p>package cn.com.test;</p>
<p>&nbsp;</p>
<p>import java.io.IOException;</p>
<p>&nbsp;</p>
<p>import org.apache.zookeeper.CreateMode;</p>
<p>import org.apache.zookeeper.KeeperException;</p>
<p>import org.apache.zookeeper.WatchedEvent;</p>
<p>import org.apache.zookeeper.Watcher;</p>
<p>import org.apache.zookeeper.ZooDefs.Ids;</p>
<p>import org.apache.zookeeper.ZooKeeper;</p>
<p>&nbsp;</p>
<p>public class zkClient {</p>
<p>&nbsp;</p>
<p>&nbsp; &nbsp; public static void main(String[] args) throws Exception{</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; Watcher wh = new Watcher(){</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; @Override</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; public void process(WatchedEvent event) {</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; System.out.println(event.toString());</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; };</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; ZooKeeper zk = new ZooKeeper("localhost:2181",30000,wh);</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("=========创建节点===========");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; zk.create("/sharpxiajun", "znode1".getBytes(), Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.err.println("=============查看节点是否安装成功===============");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println(new String(zk.getData("/sharpxiajun", false, null)));</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("=========修改节点的数据==========");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; zk.setData("/sharpxiajun", "sharpxiajun130901".getBytes(), -1);</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("========查看修改的节点是否成功=========");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println(new String(zk.getData("/sharpxiajun", false, null)));</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("=======删除节点==========");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; zk.delete("/sharpxiajun", -1);</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("==========查看节点是否被删除============");</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; System.out.println("节点状态：" + zk.exists("/sharpxiajun", false));</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; zk.close();</p>
<p>&nbsp; &nbsp; }</p>
<p>&nbsp;</p>
<p>}</p>
<p>&nbsp;　　执行结果如下：</p>
<p><br></p>
<p>log4j:WARN No appenders could be found for logger (org.apache.zookeeper.ZooKeeper).</p>
<p>log4j:WARN Please initialize the log4j system properly.</p>
<p>=========创建节点===========</p>
<p>WatchedEvent state:SyncConnected type:None path:null</p>
<p>=============查看节点是否安装成功===============</p>
<p>znode1</p>
<p>=========修改节点的数据==========</p>
<p>========查看修改的节点是否成功=========</p>
<p>sharpxiajun130901</p>
<p>=======删除节点==========</p>
<p>==========查看节点是否被删除============</p>
<p>节点状态：null</p>
<p>&nbsp;　　程序我今天不讲解了，只是给大伙展示下使用zookeeper的方式，本文可能没啥新颖的东西，但是本文是一个基础，有了这个基础我们才能真正操作zookeeper。</p>
<p><br></p>
