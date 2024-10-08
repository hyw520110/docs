<p>ZooKeeper是一个高可用的分布式数据管理与系统协调框架。基于对Paxos算法的实现，使该框架保证了分布式环境中数据的强一致性，也正是基于这样的特性，使得ZooKeeper解决很多分布式问题。网上对ZK的应用场景也有不少介绍，本文将结合作者身边的项目例子，系统地对ZK的应用场景进行一个分门归类的介绍。<br></p>
<p>值得注意的是，ZK并非天生就是为这些应用场景设计的，都是后来众多开发者根据其框架的特性，利用其提供的一系列API接口（或者称为原语集），摸索出来的典型使用方法。因此，也非常欢迎读者分享你在ZK使用上的奇技淫巧。</p>
<p>&nbsp;</p>
<table cellspacing="0" cellpadding="0">
 <tbody>
  <tr>
   <td valign="top" bgcolor="#FF8F59" width="909"><p style="text-align:center;"><strong>ZooKeeper</strong><strong>典型应用场景一览</strong></p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>数据发布与订阅（配置中心）</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">发布与订阅模型，即所谓的配置中心，顾名思义就是发布者将数据发布到ZK节点上，供订阅者动态获取数据，实现配置信息的集中式管理和动态更新。例如全局的配置信息，服务式服务框架的服务地址列表等就非常适合使用。</td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#D0D0D0" width="909">
    <ul class="list-paddingleft-2">
     <li><p>应用中用到的一些配置信息放到ZK上进行集中管理。这类场景通常是这样：应用在启动的时候会主动来获取一次配置，同时，在节点上注册一个Watcher，这样一来，以后每次配置有更新的时候，都会实时通知到订阅的客户端，从来达到获取最新配置信息的目的。</p></li>
     <li><p>分布式搜索服务中，索引的元信息和服务器集群机器的节点状态存放在ZK的一些指定节点，供各个客户端订阅使用。</p></li>
     <li><p>分布式日志收集系统。这个系统的核心工作是收集分布在不同机器的日志。收集器通常是按照应用来分配收集任务单元，因此需要在ZK上创建一个以应用名作为path的节点P，并将这个应用的所有机器ip，以子节点的形式注册到节点P上，这样一来就能够实现机器变动的时候，能够实时通知到收集器调整任务分配。</p></li>
     <li><p>系统中有些信息需要动态获取，并且还会存在人工手动去修改这个信息的发问。通常是暴露出接口，例如JMX接口，来获取一些运行时的信息。引入ZK之后，就不用自己实现一套方案了，只要将这些信息存放到指定的ZK节点上即可。</p></li>
    </ul><p><strong>注意</strong>：在上面提到的应用场景中，有个默认前提是：数据量很小，但是数据更新可能会比较快的场景。</p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>负载均衡</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">这里说的负载均衡是指软负载均衡。在分布式环境中，为了保证高可用性，通常同一个应用或同一个服务的提供方都会部署多份，达到对等服务。而消费者就须要在这些对等的服务器中选择一个来执行相关的业务逻辑，其中比较典型的是消息中间件中的生产者，消费者负载均衡。</td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#D0D0D0" width="909">消息中间件中发布者和订阅者的负载均衡，linkedin开源的KafkaMQ和阿里开源的<a href="http://metaq.taobao.org/" target="_blank">metaq</a>都是通过zookeeper来做到生产者、消费者的负载均衡。这里以metaq为例如讲下：<br><strong>生产者负载均衡</strong>：metaq发送消息的时候，生产者在发送消息的时候必须选择一台broker上的一个分区来发送消息，因此metaq在运行过程中，会把所有broker和对应的分区信息全部注册到ZK指定节点上，默认的策略是一个依次轮询的过程，生产者在通过ZK获取分区列表之后，会按照brokerId和partition的顺序排列组织成一个有序的分区列表，发送的时候按照从头到尾循环往复的方式选择一个分区来发送消息。<p>&nbsp;</p><p><strong>消费负载均衡：</strong></p><p>在消费过程中，一个消费者会消费一个或多个分区中的消息，但是一个分区只会由一个消费者来消费。MetaQ的消费策略是：</p>
    <ul class="list-paddingleft-2">
     <li><p>每个分区针对同一个group只挂载一个消费者。</p></li>
     <li><p>如果同一个group的消费者数目大于分区数目，则多出来的消费者将不参与消费。</p></li>
     <li><p>如果同一个group的消费者数目小于分区数目，则有部分消费者需要额外承担消费任务。</p></li>
    </ul><p>在某个消费者故障或者重启等情况下，其他消费者会感知到这一变化（通过 zookeeper watch消费者列表），然后重新进行负载均衡，保证所有的分区都有消费者进行消费。</p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>命名服务(Naming Service)</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">命名服务也是分布式系统中比较常见的一类场景。在分布式系统中，通过使用命名服务，客户端应用能够根据指定名字来获取资源或服务的地址，提供者等信息。被命名的实体通常可以是集群中的机器，提供的服务地址，远程对象等等&amp;mdash;&amp;mdash;这些我们都可以统称他们为名字（Name）。其中较为常见的就是一些分布式服务框架中的服务地址列表。通过调用ZK提供的创建节点的API，能够很容易创建一个全局唯一的path，这个path就可以作为一个名称。</td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#D0D0D0" width="909">阿里巴巴集团开源的分布式服务框架Dubbo中使用ZooKeeper来作为其命名服务，维护全局的服务地址列表，<a href="http://code.alibabatech.com/wiki/display/dubbo/Home" target="_blank">点击这里</a>查看Dubbo开源项目。在Dubbo实现中：<p>&nbsp;</p><p><strong>服务提供者</strong>在启动的时候，向ZK上的指定节点/dubbo/${serviceName}/providers目录下写入自己的URL地址，这个操作就完成了服务的发布。</p><p><strong>服务消费者</strong>启动的时候，订阅/dubbo/${serviceName}/providers目录下的提供者URL地址， 并向/dubbo/${serviceName} /consumers目录下写入自己的URL地址。</p><p><strong>注意</strong>，所有向ZK上注册的地址都是临时节点，这样就能够保证服务提供者和消费者能够自动感应资源的变化。</p><p>另外，Dubbo还有针对服务粒度的监控，方法是订阅/dubbo/${serviceName}目录下所有提供者和消费者的信息。</p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>分布式通知/协调</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">ZooKeeper中特有watcher注册与异步通知机制，能够很好的实现分布式环境下不同系统之间的通知与协调，实现对数据变更的实时处理。使用方法通常是不同系统都对ZK上同一个znode进行注册，监听znode的变化（包括znode本身内容及子节点的），其中一个系统update了znode，那么另一个系统能够收到通知，并作出相应处理</td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#D0D0D0" width="909">
    <ul class="list-paddingleft-2">
     <li><p>另一种心跳检测机制：检测系统和被检测系统之间并不直接关联起来，而是通过zk上某个节点关联，大大减少系统耦合。</p></li>
     <li><p>另一种系统调度模式：某系统有控制台和推送系统两部分组成，控制台的职责是控制推送系统进行相应的推送工作。管理人员在控制台作的一些操作，实际上是修改了ZK上某些节点的状态，而ZK就把这些变化通知给他们注册Watcher的客户端，即推送系统，于是，作出相应的推送任务。</p></li>
     <li><p>另一种工作汇报模式：一些类似于任务分发系统，子任务启动后，到zk来注册一个临时节点，并且定时将自己的进度进行汇报（将进度写回这个临时节点），这样任务管理者就能够实时知道任务进度。</p></li>
    </ul><p>总之，使用zookeeper来进行分布式通知和协调能够大大降低系统之间的耦合</p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>集群管理与Master选举</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">
    <ul class="list-paddingleft-2">
     <li><p>集群机器监控：这通常用于那种对集群中机器状态，机器在线率有较高要求的场景，能够快速对集群中机器变化作出响应。这样的场景中，往往有一个监控系统，实时检测集群机器是否存活。过去的做法通常是：监控系统通过某种手段（比如ping）定时检测每个机器，或者每个机器自己定时向监控系统汇报&amp;ldquo;我还活着&amp;rdquo;。 这种做法可行，但是存在两个比较明显的问题：</p></li>
    </ul>
    <ol class="list-paddingleft-2">
     <li><p>集群中机器有变动的时候，牵连修改的东西比较多。</p></li>
     <li><p>有一定的延时。</p></li>
    </ol><p style="text-align:left;">利用ZooKeeper有两个特性，就可以实时另一种集群机器存活性监控系统：</p>
    <ol class="list-paddingleft-2">
     <li><p>客户端在节点 x 上注册一个Watcher，那么如果 x?的子节点变化了，会通知该客户端。</p></li>
     <li><p>创建EPHEMERAL类型的节点，一旦客户端和服务器的会话结束或过期，那么该节点就会消失。</p></li>
    </ol><p style="text-align:left;">例如，监控系统在 /clusterServers 节点上注册一个Watcher，以后每动态加机器，那么就往 /clusterServers 下创建一个 EPHEMERAL类型的节点：/clusterServers/{hostname}. 这样，监控系统就能够实时知道机器的增减情况，至于后续处理就是监控系统的业务了。</p>
    <ul class="list-paddingleft-2">
     <li><p>Master选举则是zookeeper中最为经典的应用场景了。</p></li>
    </ul><p style="text-align:left;">在分布式环境中，相同的业务应用分布在不同的机器上，有些业务逻辑（例如一些耗时的计算，网络I/O处理），往往只需要让整个集群中的某一台机器进行执行，其余机器可以共享这个结果，这样可以大大减少重复劳动，提高性能，于是这个master选举便是这种场景下的碰到的主要问题。</p><p style="text-align:left;">利用ZooKeeper的强一致性，能够保证在分布式高并发情况下节点创建的全局唯一性，即：同时有多个客户端请求创建 /currentMaster 节点，最终一定只有一个客户端请求能够创建成功。利用这个特性，就能很轻易的在分布式环境中进行集群选取了。</p><p style="text-align:left;">另外，这种场景演化一下，就是动态Master选举。这就要用到?EPHEMERAL_SEQUENTIAL类型节点的特性了。</p><p style="text-align:left;">上文中提到，所有客户端创建请求，最终只有一个能够创建成功。在这里稍微变化下，就是允许所有请求都能够创建成功，但是得有个创建顺序，于是所有的请求最终在ZK上创建结果的一种可能情况是这样： /currentMaster/{sessionId}-1 ,?/currentMaster/{sessionId}-2 ,?/currentMaster/{sessionId}-3 &amp;hellip;.. 每次选取序列号最小的那个机器作为Master，如果这个机器挂了，由于他创建的节点会马上消失，那么之后最小的那个机器就是Master了。</p></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#D0D0D0" width="909">
    <ul class="list-paddingleft-2">
     <li><p>在搜索系统中，如果集群中每个机器都生成一份全量索引，不仅耗时，而且不能保证彼此之间索引数据一致。因此让集群中的Master来进行全量索引的生成，然后同步到集群中其它机器。另外，Master选举的容灾措施是，可以随时进行手动指定master，就是说应用在zk在无法获取master信息时，可以通过比如http方式，向一个地方获取master。</p></li>
     <li><p>在Hbase中，也是使用ZooKeeper来实现动态HMaster的选举。在Hbase实现中，会在ZK上存储一些ROOT表的地址和HMaster的地址，HRegionServer也会把自己以临时节点（Ephemeral）的方式注册到Zookeeper中，使得HMaster可以随时感知到各个HRegionServer的存活状态，同时，一旦HMaster出现问题，会重新选举出一个HMaster来运行，从而避免了HMaster的单点问题</p></li>
    </ul></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>分布式锁</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">分布式锁，这个主要得益于ZooKeeper为我们保证了数据的强一致性。锁服务可以分为两类，一个是<strong>保持独占</strong>，另一个是<strong>控制时序</strong>。<p>&nbsp;</p>
    <ul class="list-paddingleft-2">
     <li><p>所谓保持独占，就是所有试图来获取这个锁的客户端，最终只有一个可以成功获得这把锁。通常的做法是把zk上的一个znode看作是一把锁，通过create znode的方式来实现。所有客户端都去创建 /distribute_lock 节点，最终成功创建的那个客户端也即拥有了这把锁。</p></li>
     <li><p>控制时序，就是所有视图来获取这个锁的客户端，最终都是会被安排执行，只是有个全局时序了。做法和上面基本类似，只是这里 /distribute_lock 已经预先存在，客户端在它下面创建临时有序节点（这个可以通过节点的属性控制：CreateMode.EPHEMERAL_SEQUENTIAL来指定）。Zk的父节点（/distribute_lock）维持一份sequence,保证子节点创建的时序性，从而也形成了每个客户端的全局时序。</p></li>
    </ul></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#8CEA00" width="909"><strong>分布式队列</strong></td>
  </tr>
  <tr>
   <td valign="top" bgcolor="#C2C287" width="909">队列方面，简单地讲有两种，一种是常规的先进先出队列，另一种是要等到队列成员聚齐之后的才统一按序执行。对于第一种先进先出队列，和分布式锁服务中的控制时序场景基本原理一致，这里不再赘述。<p>&nbsp;</p><p>第二种队列其实是在FIFO队列的基础上作了一个增强。通常可以在 /queue 这个znode下预先建立一个/queue/num 节点，并且赋值为n（或者直接给/queue赋值n），表示队列大小，之后每次有队列成员加入后，就判断下是否已经到达队列大小，决定是否可以开始执行了。这种用法的典型场景是，分布式环境中，一个大任务Task A，需要在很多子任务完成（或条件就绪）情况下才能进行。这个时候，凡是其中一个子任务完成（就绪），那么就去 /taskList 下建立自己的临时时序节点（CreateMode.EPHEMERAL_SEQUENTIAL），当 /taskList 发现自己下面的子节点满足指定个数，就可以进行下一步按序进行处理了。</p></td>
  </tr>
 </tbody>
</table>
<p>转自：<a href="http://www.cnblogs.com/ggjucheng/p/3352614.html" target="_blank">http://www.cnblogs.com/ggjucheng/p/3352614.html</a></p>
