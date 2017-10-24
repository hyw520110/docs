#概述简介

Zookeeper是Hadoop的一个子项目，它是分布式系统中的协调系统，可提供的服务主要有：配置服务、名字服务、分布式同步、组服务等。

它有如下的一些特点：

	简单: Zookeeper的核心是一个精简的文件系统，它支持一些简单的操作和一些抽象操作，例如，排序和通知。
	丰富: Zookeeper的原语操作是很丰富的，可实现一些协调数据结构和协议。例如，分布式队列、分布式锁和一组同级别节点中的“领导者选举”。
	高可靠: Zookeeper支持集群模式，可以很容易的解决单点故障问题。
	松耦合交互: 不同进程间的交互不需要了解彼此，甚至可以不必同时存在，某进程在zookeeper中留下消息后，该进程结束后其它进程还可以读这条消息。
	资源库: Zookeeper实现了一个关于通用协调模式的开源共享存储库，能使开发者免于编写这类通用协议。


#数据模型、命名空间以及节点的概念
**ZooKeeper数据模型和层次命名空间**

提供的命名空间与标准的文件系统非常相似。一个名称是由通过斜线分隔开的路径名序列所组成的。ZooKeeper中的每一个节点是都通过路径来识别。 

下图是Zookeeper中节点的数据模型，这种树形结构的命名空间操作方便且易于理解。

![](http://www.sxt.cn/editor/attached/image/20141111/349439758/f8ffbd3c-eea1-4358-836d-b229f9e5034b.gif)

ZooKeeper中节点和临时节点

Zookeeper的结构类似标准的文件系统，但这个文件系统中没有文件和目录，而是统一使用节点(node)的概念，称为znode。Znode作为保存数据的容器(限制在1mb以内)，也构成了一个层次化的命名空间。

ZooKeeper的节点是通过像树一样的结构来进行维护的，并且每一个节点通过路径来标示以及访问。除此之外，每一个节点还拥有自身的一些信息，包括：数据、数据长度、创建时间、修改时间等等。从这样一类既含有数据，又作为路径表标示的节点的特点中，可以看出，ZooKeeper的节点既可以被看做是一个文件，又可以被看做是一个目录，它同时具有二者的特点。
节点属性：

	czxid节点被创建的zxid值
	mzxid节点被修改时zxid值
	ctime节点创建的时间
	mtime节点最后一次的修改时间
	vesion节点的版本号
	cversion节点所拥有的子节点被修改的版本号
	aversion节点的ACL被修改的版本号
	dataLength节点数据的长度
	numChildren节点拥有子节点的个数
	ephemeralOwner如果节点为临时节点，那么它的值为这个节点拥有者的session ID；负责它的值为0
Znode是客户端访问的zookeeper的主要实体，它包含了以下主要特征：
	
Watch：
 
		Znode状态发生改变时(增删改等操作)，watch (监视器)机制可以让客户端得到通知，并且仅仅只会触发一次watch。
	  	
		在读操作exists、getChildren和getData上可以设置监视器，这些监视器可以被写操作create、delete和setData触发。ACL相关的操作不参与任何监视器。当一监视器触发时，会产生一个事件，这个监视器和触发它的操作共同绝地沟了监视器事件类型。
		
		当所监视的znode被创建子节点、删除或其他数据更新时，设置在exists操作上的监视器将会被触发。

		当所监视的znode被删除或其更新时，设置在getData上的监视器将会被触发，创建znode不会触发getData上的监视器，因为getData操作成功执行的前提是znode必须已经在。

		当所监视的znode的一个子节点被创建或删除时，或监视的znode自己被删时，设置在getChildren操作上的监视器将会被触发。
数据访问控制：

	每个znode创建时间都会有一个ACL列表，用于决定谁可以执行那些操作。
临时节点：

	Zookeeper节点有两种：临时节点和持久节点。节点类型在创建时确定，并且不能修改。临时节点生命周期依赖创建它的会话，一旦会话结束，临时节点将会被删除。临时节点不允许有子节点
顺序节点:
	
	当创建znode 时设置了顺序节点，那么该znode路径之后便会附加一个递增的计数，这个计数对于此节点的父节点来说是唯一的。

	例如：一个客户端请求创建一个名为/a/b-的顺序节点，则所创建znode的名字可能是a/b-5，稍后另外一个名为/a/b-的顺序节点被创建，计数器会给出一个更大的值来保证znode名称的唯一性，例如/a/b-6。	

具体地说，Znode维护着数据、ACL（access control list，访问控制列表）、时间戳等交换版本号等数据结构，它通过对这些数据的管理来让缓存生效并且令协调更新。每当Znode中的数据更新后它所维护的版本号将增加，这非常类似于数据库中计数器时间戳的操作方式。

另外Znode还具有原子性操作的特点：命名空间中，每一个Znode的数据将被原子地读写。读操作将读取与Znode相关的所有数据，写操作将替换掉所有的数据。除此之外，每一个节点都有一个访问控制列表，这个访问控制列表规定了用户操作的权限。

ZooKeeper中同样存在临时节点。这些节点与session同时存在，当session生命周期结束，这些临时节点也将被删除。临时节点在某些场合也发挥着非常重要的作用。 

#ZooKeeper的安装

ZooKeeper的安装模式分为三种，分别为：单机模式（stand-alone）、集群模式和集群伪分布模式。

ZooKeeper 单机模式的安装相对比较简单，如果第一次接触ZooKeeper的话，建议安装ZooKeeper单机模式或者集群伪分布模式。

**单机模式安装**

使用单机模式时用户需要注意：这种配置方式下没有 ZooKeeper 副本，所以如果 ZooKeeper 服务器出现故障， ZooKeeper 服务将会停止。

Zookeeper的运行环境是需要java的，建议安装oracle的java6.

可去官网下载一个稳定的版本，然后进行安装：http://zookeeper.apache.org/

解压后在zookeeper的conf目录下创建配置文件zoo.cfg，里面的配置信息可参考统计目录下的zoo_sample.cfg文件，我们这里配置为：

	tickTime=2000
	initLimit=10
	syncLimit=5
	dataDir=/opt/zookeeper-data/
	clientPort=2181
	tickTime：指定了ZooKeeper的基本时间单位（以毫秒为单位）；
参数说明：

最低配置即必须配置的参数：clientPort、	dataDir、tickTime

tickTime基本事件单元，以毫秒为单位。它用来控制心跳和超时，默认情况下最小的会话超时时间为两倍的 tickTime 。

initLimit：指定了启动zookeeper时，zookeeper实例中的随从实例同步到领导实例的初始化连接时间限制，超出时间限制则连接失败（tickTime时间单位为毫秒）；它用来指示心跳，最小的 session 过期时间为两倍的 tickTime。

syncLimit：指定了zookeeper正常运行时，主从节点之间同步数据的时间限制，若超过这个时间限制，那么随从实例将会被丢弃；

dataDir：zookeeper存放数据的目录；存储内存中数据库快照的位置，如果不设置参数，更新事务日志将被存储到默认位置。注意 应该谨慎地选择日志存放的位置，使用专用的日志存储设备能够大大地提高系统的性能，如果将日志存储在比较繁忙的存储设备上，那么将会在很大程度上影响系统的性能。

clientPort：用于连接客户端的端口。

**高级配置（可选的配置参数）：**
	
dataLogDir这个操作将管理机器把事务日志写入到“ dataLogDir ”所指定的目录，而不是“ dataDir ”所指定的目录。这将允许使用一个专用的日志设备并且帮助我们避免日志和快照之间的竞争。在log4j.properties中找到zookeeper.log.dir修改日志的存储目录

maxClientCnxns这个操作将限制连接到 ZooKeeper 的客户端的数量，限制并发连接的数量，它通过 IP 来区分不同的客户端。此配置选项可以用来阻止某些类别的 Dos 攻击。将它设置为 0 或者忽略而不进行设置将会取消对并发连接的限制。	
		
minSessionTimeout 和 maxSessionTimeout最小的会话超时时间以及最大的会话超时时间。其中，最小的会话超时时间默认情况下为2倍的tickTme时间，最大的会话超时时间默认情况下为20倍的会话超时时间。在启动时，系统会显示相应信息。在配置 minSessionTmeout 以及 maxSessionTimeout 的值的时候需要注意，如果将此值设置的太小的话，那么会话很可能刚刚建立便由于超时而不得不退出。一般情况下，不能将此值设置的比 tickTime 的值还小。

**集群配置:**

initLimit此配置表示，允许 follower （相对于 leader 而言的“客户端”）连接并同步到 leader 的初始化连接时间，它以 tickTime 的倍数来表示。当超过设置倍数的 tickTime 时间，则连接失败。	

syncLimit此配置表示， leader 与 follower 之间发送消息，请求和应答时间长度。如果 follower 在设置的时间内不能与 leader 进行通信，那么此 follower 将被丢弃。


**启动一个本地的ZooKeeper实例**

	% zkServer.sh start
**交互命令：**

ZooKeeper 支持某些特定的四字命令字母与其的交互。它们大多是查询命令，用来获取 ZooKeeper 服务的当前状态及相关信息。用户在客户端可以通过 telnet 或 nc 向 ZooKeeper 提交相应的命令

	conf 输出相关服务配置的详细信息。
	cons 列出所有连接到服务器的客户端的完全的连接 / 会话的详细信息。包括“接受 / 发送”的包数量、会话 id 、操作延迟、最后的操作执行等等信息。
	dump 列出未经处理的会话和临时节点。	
	envi 输出关于服务环境的详细信息（区别于 conf 命令）。
	reqs 列出未经处理的请求
	ruok 测试服务是否处于正确状态。如果确实如此，那么服务返回“ imok ”，否则不做任何相应。
	stat 输出关于性能和连接的客户端的列表。
	wchs 列出服务器 watch 的详细信息。
	wchc 通过 session 列出服务器 watch 的详细信息，它的输出是一个与 watch 相关的会话的列表。
	wchp 通过路径列出服务器 watch 的详细信息。它输出一个与 session 相关的路径。
示例：

	echo ruok | nc localhost 2181
	如提示nc: command not found, 确认netcat是否安装，如已安装查看命令环境变量配置，如未安装执行：
		yum list nc*
		yum install nc.x86_64
	检查ZooKeeper是否正在运行，若是正常运行的话会打印“imok”。

接到 ZooKeeper 服务：

	zkCli.sh –server 10.77.20.23:2181
连接成功后，系统会输出 ZooKeeper 的相关环境以及配置信息，并在屏幕输出“ Welcome to ZooKeeper ”等信息。输入 help 之后，屏幕会输出可用的 ZooKeeper 命令

使用 ls 命令来查看当前 ZooKeeper 中所包含的内容：
	
	ls /
创建一个新的 znode ，使用 create /zk myData 。这个命令创建了一个新的 znode 节点“ zk ”以及与它关联的字符串：
	
	create /zk myData
	ls /
运行 get 命令来确认第二步中所创建的 znode 是否包含我们所创建的字符串：

	get /zk
通过 set 命令来对 zk 所关联的字符串进行设置：

	set /zk shenlan211314
	get /zk
将刚才创建的 znode 删除：

	delete /zk
	ls /

**集群模式**

为了获得可靠的 ZooKeeper 服务，用户应该在一个集群上部署 ZooKeeper 。只要集群上大多数的 ZooKeeper 服务启动了，那么总的 ZooKeeper 服务将是可用的。另外，最好使用奇数台机器。 如果 zookeeper 拥有 5 台机器，那么它就能处理 2 台机器的故障了。

之后的操作和单机模式的安装类似，我们同样需要对 JAVA 环境进行设置，下载最新的 ZooKeeper 稳定版本并配置相应的环境变量。不同之处在于每台机器上 conf/zoo.cfg 配置文件的参数设置，参考下面的配置：

	tickTime=2000
	dataDir=/var/zookeeper/
	clientPort=2181
	initLimit=5
	syncLimit=2
	server.1=IP1:2888:3888
	server.2=IP2:2888:3888
	server.3=IP3:2888:3888
说明：

“ server.id=host:port:port. ”指示了不同的 ZooKeeper 服务器的自身标识，作为集群的一部分的机器应该知道 ensemble 中的其它机器。用户可以从“ server.id=host:port:port. ”中读取相关的信息。 在服务器的 data （ dataDir 参数所指定的目录）目录下创建一个文件名为 myid 的文件，这个文件中仅含有一行的内容，指定的是自身的 id 值。比如，服务器“ 1 ”应该在 myid 文件中写入“ 1 ”。这个 id 值必须是 ensemble 中唯一的，且大小在 1 到 255 之间。这一行配置中，第一个端口（ port ）是从（ follower ）机器连接到主（ leader ）机器的端口，第二个端口是用来进行 leader 选举的端口。在这个例子中，每台机器使用三个端口，分别是： clientPort ， 2181 ； port ， 2888 ； port ， 3888 。

**集群伪分布**

简单来说，集群伪分布模式就是在单机下模拟集群的ZooKeeper服务。在 zookeeper 配置文档中， clientPort 参数用来设置客户端连接 zookeeper 的端口。 server.1=IP1:2887:3887 中， IP1 指示的是组成 ZooKeeper 服务的机器 IP 地址， 2887 为用来进行 leader 选举的端口， 3887 为组成 ZooKeeper 服务的机器之间通信的端口。集群伪分布模式我们使用每个配置文档模拟一台机器，也就是说，需要在单台机器上运行多个 zookeeper 实例。但是，我们必须要保证各个配置文档的 clientPort 不能冲突。
通过 zoo1.cfg ， zoo2.cfg ， zoo3.cfg 模拟了三台机器的 ZooKeeper 集群

zoo1.cfg ：

	tickTime=2000
	initLimit=10
	syncLimit=5
	dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_1
	dataLogDir=/root/hadoop-0.20.2/zookeeper-3.3.1/logs/log_1
	clientPort=2181
	server.1=localhost:2887:3887
	server.2=localhost:2888:3888
	server.3=localhost:2889:3889
zoo2.cfg ：

	tickTime=2000
	initLimit=10
	syncLimit=5
	dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_2
	dataLogDir=/root/hadoop-0.20.2/zookeeper-3.3.1/logs/log_2
	clientPort=2182
	server.1=localhost:2887:3887 
	server.2=localhost:2888:3888
	server.3=localhost:2889:3889
zoo3.cfg ：

	tickTime=2000
	initLimit=10
	syncLimit=5
	dataDir=/root/hadoop-0.20.2/zookeeper-3.3.1/d_2
	dataLogDir=/root/hadoop-0.20.2/zookeeper-3.3.1/logs/log_2
	clientPort=2182
	server.1=localhost:2887:3887 
	server.2=localhost:2888:3888
	server.3=localhost:2889:3889
除了 clientPort 不同之外， dataDir、dataLogDir也不同。另外，不要忘记在 dataDir 所对应的目录中创建 myid 文件来指定对应的 zookeeper 服务器实例。

伪集群模式下启动时需指定配置文件：

	zkServer.sh start zoo1.cfg
当启动第一实例时会报连接异常，可以忽略，等实例2和实例3启动后连接异常会相应的消失。

#ZooKeeper监控

远程JMX配置

默认情况下，zookeeper是支持本地的jmx监控的。若需要远程监控zookeeper，则需要进行进行如下配置。

默认的配置有这么一行：

	ZOOMAIN="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY org.apache.zookeeper.server.quorum.QuorumPeerMain"

在$JMXLOCALONLY后边添加jmx的相关参数配置：

	ZOOMAIN="-Dcom.sun.management.jmxremote
        -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY
                -Djava.rmi.server.hostname=192.168.1.8
                -Dcom.sun.management.jmxremote.port=1911
                -Dcom.sun.management.jmxremote.ssl=false
                -Dcom.sun.management.jmxremote.authenticate=false
                 org.apache.zookeeper.server.quorum.QuorumPeerMain"
这样就可以远程监控了，可以用jconsole.exe或jvisualvm.exe等工具对其进行监控。

身份验证加上：

	-Dcom.sun.management.jmxremote.authenticate=true  远程连接需要密码认证
	-Dcom.sun.management.jmxremote.password.file=../conf/jmxremote.password  指定连接的用户名和密码配置文件
	-Dcom.sun.management.jmxremote.access.file=../conf/jmxremote.access  指定连接的用户所拥有权限的配置文件

4. Zookeeper的存储模型

Zookeeper的数据存储采用的是结构化存储，结构化存储是没有文件和目录的概念，里边的目录和文件被抽象成了节点（node），zookeeper里可以称为znode。Znode的层次结构如下图：
![znode](http://www.sxt.cn/editor/attached/image/20141117/871038891/8e8985f3-6c7a-4a31-850f-953a2aca06a4.png)
最上边的是根目录，下边分别是不同级别的子目录。

5. Zookeeper客户端的使用

zkCli.sh

可使用./zkCli.sh -server localhost来连接到Zookeeper服务上。

使用ls /可查看根节点下有哪些子节点，可以双击Tab键查看更多命令。

Java客户端

可创建org.apache.zookeeper.ZooKeeper对象来作为zk的客户端，注意，java api里创建zk客户端是异步的，为防止在客户端还未完成创建就被使用的情况，这里可以使用同步计时器，确保zk对象创建完成再被使用。

C客户端

可以使用zhandle_t指针来表示zk客户端，可用zookeeper_init方法来创建。可在ZK_HOME\src\c\src\ cli.c查看部分示例代码。

6. Zookeeper创建Znode

Znode有两种类型：短暂的和持久的。短暂的znode在创建的客户端与服务器端断开（无论是明确的断开还是故障断开）连接时，该znode都会被删除；相反，持久的znode则不会。
	
		
	/**
	 * 连接的观察者，封装了zk的创建等
	 */
	public class ConnectionWatcher implements Watcher {
	
		private static final int SESSION_TIMEOUT = 1000;// 会话延时
	
		protected ZooKeeper zk = null;
		private CountDownLatch countDownLatch = new CountDownLatch(1);// 同步计数器
	
		public void process(WatchedEvent event) {
			if (event.getState() == KeeperState.SyncConnected) {
				countDownLatch.countDown();// 计数器减一
			}
		}
	
		/**
		 * 创建zk对象
		 * 当客户端连接上zookeeper时会执行process(event)里的countDownLatch.countDown()，计数器的值变为0
		 * ，则countDownLatch.await()方法返回。
		 * 
		 * @param hosts
		 * @throws IOException
		 * @throws InterruptedException
		 */
		public void connect(String hosts) throws IOException, InterruptedException {
			zk = new ZooKeeper(hosts, SESSION_TIMEOUT, this);
			countDownLatch.await();// 阻塞程序继续执行
		}
	
		/**
		 * 创建group
		 * 
		 * @param groupName
		 *            组名
		 * @throws KeeperException
		 * @throws InterruptedException
		 */
		public void create(String groupName) throws KeeperException,
				InterruptedException {
			String path = "/" + groupName;
			String createPath = zk.create(path, null,
					Ids.OPEN_ACL_UNSAFE/* 允许任何客户端对该znode进行读写 */,
					CreateMode.PERSISTENT/* 持久化的znode */);
			System.out.println("Created " + createPath);
		}
	
		/**
		 *创建持久态的znode,比支持多层创建.比如在创建/parent/child的情况下,无/parent.无法通过
		 */
		public void create(String path, byte[] data) throws KeeperException,
				InterruptedException {
			this.zk.create(path, data, Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
		}
	
		/**
		 *获取节点信息
		 */
		public void getChild(String path) throws KeeperException,
				InterruptedException {
			try {
				List<String> list = this.zk.getChildren(path, false);
				if (list.isEmpty()) {
					System.out.println(path + "中没有节点");
					return;
				}
				System.out.println(path + "中存在节点");
				for (String child : list) {
					System.out.println("节点为：" + child);
				}
			} catch (KeeperException.NoNodeException e) {
				throw e;
			}
		}
	
		public byte[] getData(String path) throws KeeperException,
				InterruptedException {
			return this.zk.getData(path, false, null);
		}
	
		/**
		 * zk.delete(path,version)方法的第二个参数是znode版本号， 如果提供的版本号和znode版本号一致才会删除这个znode，
		 * 这样可以检测出对znode的修改冲突。通过将版本号设置为-1， 可以绕过这个版本检测机制，无论znode的版本号是什么，都会直接将其删除。
		 */
		public void delete(String groupName) {
			String path = "/" + groupName;
			try {
				List<String> children = zk.getChildren(path, false);
	
				for (String child : children) {
					zk.delete(path + "/" + child, -1);
				}
				zk.delete(path, -1);// 版本号为-1，
			} catch (KeeperException e) {
				e.printStackTrace();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	
		/**
		 * 关闭zk
		 * 
		 * @throws InterruptedException
		 */
		public void close() throws InterruptedException {
			if (zk != null) {
				try {
					zk.close();
				} catch (InterruptedException e) {
					throw e;
				} finally {
					zk = null;
					System.gc();
				}
			}
		}
	}

这里我们使用了同步计数器CountDownLatch，在connect方法中创建执行了zk = new ZooKeeper(hosts, SESSION_TIMEOUT, this);之后，下边接着调用了CountDownLatch对象的await方法阻塞，因为这是zk客户端不一定已经完成了与服务端的连接，在客户端连接到服务端时会触发观察者调用process()方法，我们在方法里边判断一下触发事件的类型，完成连接后计数器减一，connect方法中解除阻塞。

还有两个地方需要注意：这里创建的znode的访问权限是open的，且该znode是持久化存储的。

测试类如下：
			
	public class ConnectionWatcherTest {
		private static String hosts = "192.168.35.3";
		private static String groupName = "zoo";
	
		private ConnectionWatcher watcher = null;
	
		/**
		 * init
		 * 
		 * @throws InterruptedException
		 * @throws KeeperException
		 * @throws IOException
		 */
		@Before
		public void init() throws KeeperException, InterruptedException,
				IOException {
			watcher = new ConnectionWatcher();
			watcher.connect(hosts);
		}
	
		@Test
		public void testCreate() throws KeeperException, InterruptedException {
			watcher.create(groupName);
		}
		
		@Test
		public void testDelete() throws IOException, InterruptedException,
				KeeperException {
			watcher.delete(groupName);
		}
		
		@Test
		public void testCreate2() throws KeeperException, InterruptedException{
			watcher.create("/root", null);
			System.out.println(Arrays.toString(watcher.getData("/root")));
		}
		@Test
		public void testCreate3() throws KeeperException, InterruptedException{
			watcher.create("/root/child1", new byte[]{'a','b','c','d'});
			System.out.println(Arrays.toString(watcher.getData("/root/child1")));
		}
		
		@Test
		public void testCreate4() throws KeeperException, InterruptedException, UnsupportedEncodingException{
			watcher.create("/root/child2", "水电费水电费".getBytes("UTF-8"));
			System.out.println(new String(watcher.getData("/root/child2"),"UTF-8"));
		}	
	
		/**
		 * 销毁资源
		 */
		@After
		public void destroy() {
			try {
				watcher.close();
				watcher = null;
				System.gc();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

**Zookeeper的相关操作** ZooKeeper中共有9中操作：

create：创建一个znode

delete：删除一个znode

exists：测试一个znode

getACL，setACL：获取/设置一个znode的ACL（权限控制）

getChildren：获取一个znode的子节点

getData，setData：获取/设置一个znode所保存的数据

sync：将客户端的znode视图与ZooKeeper同步

这里更新数据是必须要提供znode的版本号（也可以使用-1强制更新，这里可以执行前通过exists方法拿到znode的元数据Stat对象，然后从Stat对象中拿到对应的版本号信息），如果版本号不匹配，则更新会失败。因此一个更新失败的客户端可以尝试是否重试或执行其它操作。

**ZooKeeper的API**

ZooKeeper的api支持多种语言，在操作时可以选择使用同步api还是异步api。同步api一般是直接返回结果，异步api一般是通过回调来传送执行结果的，一般方法中有某参数是类AsyncCallback的内部接口，那么该方法应该就是异步调用，回调方法名为processResult。

**观察触发器**

可以对客户端和服务器端之间的连接设置观察触发器（后边称之为zookeeper的状态观察触发器），也可以对znode设置观察触发器。

**状态观察器**

zk的整个生命周期如下：
![](http://www.sxt.cn/editor/attached/image/20141117/871038891/41a23ba2-2929-4726-9e54-ef17ff59c0ac.png)

可在创建zk对象时传入一个观察器，在完成CONNECTING状态到CONNECTED状态时，观察器会触发一个事件，该触发的事件类型为NONE，通过event.getState()方法拿到事件状态为SyncConnected。有一点需要注意的就是，在zk调用close方法时不会触发任何事件，因为这类的显示调用是开发者主动执行的，属于可控的，不用使用事件通知来告知程序

**设置znode的观察器**

可以在读操作exists、getChildren和getData上设置观察，在执行写操作create、delete和setData将会触发观察事件，当然，在执行写的操作时，也可以选择是否触发znode上设置的观察器，具体可查看相关的api。

当观察的znode被创建、删除或其数据被更新时，设置在exists上的观察将会被触发；

当观察的znode被删除或数据被更新时，设置在getData上的观察将会被触发；

当观察的znode的子节点被创建、删除或znode自身被删除时，设置在getChildren上的观察将会被触发，可通过观察事件的类型来判断被删除的是znode还是它的子节点。
![](http://www.sxt.cn/editor/attached/image/20141117/871038891/0834070f-69fb-460a-8558-50a68d021ceb.png)

对于NodeCreated和NodeDeleted根据路径就能发现是哪个znode被写；对于NodeChildrenChanged可根据getChildren来获取新的子节点列表。

注意：在收到收到触发事件到执行读操作之间，znode的状态可能会发生状态，这点需要牢记。



#ZooKeeper的一致性保证及Leader选举
**一致性保证**

Zookeeper 是一种高性能、可扩展的服务。 Zookeeper 的读写速度非常快，并且读的速度要比写的速度更快。另外，在进行读操作的时候， ZooKeeper 依然能够为旧的数据提供服务。这些都是由于 ZooKeepe 所提供的一致性保证，它具有如下特点：

	顺序一致性: 客户端的更新顺序与它们被发送的顺序相一致。
	原子性: 更新操作要么成功要么失败，没有第三种结果。
	单系统镜像: 无论客户端连接到哪一个服务器，客户端将看到相同的 ZooKeeper 视图。
	可靠性: 一旦一个更新操作被应用，那么在客户端再次更新它之前，它的值将不会改变。。这个保证将会产生下面两种结果：
		1 ．如果客户端成功地获得了正确的返回代码，那么说明更新已经成果。如果不能够获得返回代码（由于通信错误、超时等等），那么客户端将不知道更新操作是否生效。
		2 ．当从故障恢复的时候，任何客户端能够看到的执行成功的更新操作将不会被回滚。
	实时性: 在特定的一段时间内，客户端看到的系统需要被保证是实时的（在十几秒的时间里）。在此时间段内，任何系统的改变将被客户端看到，或者被客户端侦测到。
给予这些一致性保证， ZooKeeper 更高级功能的设计与实现将会变得非常容易，例如： leader 选举、队列以及可撤销锁等机制的实现。

**Leader选举**

ZooKeeper需要在所有的服务（可以理解为服务器）中选举出一个 Leader，然后让这个 Leader 来负责管理集群。此时，集群中的其它服务器则成为此 Leader 的 Follower 。并且，当 Leader 故障的时候，需要 ZooKeeper 能够快速地在Follower中选举出下一个 Leader 。这就是 ZooKeeper 的 Leader 机制，Leader 选举（Leader Election）实现机制：

此操作实现的核心思想是：首先创建一个 EPHEMERAL 目录节点，例如“ /election ”。然后。每一个 ZooKeeper 服务器在此目录下创建一个 SEQUENCE| EPHEMERAL 类型的节点，例如“ /election/n_ ”。在 SEQUENCE 标志下， ZooKeeper 将自动地为每一个 ZooKeeper 服务器分配一个比前一个分配的序号要大的序号。此时创建节点的 ZooKeeper 服务器中拥有最小序号编号的服务器将成为 Leader 。

在实际的操作中，还需要保障：当 Leader 服务器发生故障的时候，系统能够快速地选出下一个 ZooKeeper 服务器作为 Leader 。一个简单的解决方案是，让所有的 follower 监视 leader 所对应的节点。当 Leader 发生故障时， Leader 所对应的临时节点将会自动地被删除，此操作将会触发所有监视 Leader 的服务器的 watch 。这样这些服务器将会收到 Leader 故障的消息，并进而进行下一次的 Leader 选举操作。但是，这种操作将会导致“从众效应”的发生，尤其当集群中服务器众多并且带宽延迟比较大的时候，此种情况更为明显。

在 Zookeeper 中，为了避免从众效应的发生，它是这样来实现的：每一个 follower 对 follower 集群中对应的比自己节点序号小一号的节点（也就是所有序号比自己小的节点中的序号最大的节点）设置一个 watch 。只有当 follower 所设置的 watch 被触发的时候，它才进行 Leader 选举操作，一般情况下它将成为集群中的下一个 Leader 。很明显，此 Leader 选举操作的速度是很快的。因为，每一次 Leader 选举几乎只涉及单个 follower 的操作。
