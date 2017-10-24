<p><span style="font-size:14px;">Zookeeper<br></span></p>
<p><br></p>
<p><span style="font-size:14px;">ZooKeeper 是一个为分布式应用所设计的分布的、开源的协调服务。分布式的应用可以建立在同步、配置管理、分组和命名等服务的更高级别的实现的基础之上。 ZooKeeper 意欲设计一个易于编程的环境，它的文件系统使用我们所熟悉的目录树结构。</span></p>
<p><span style="font-size:14px;">ZooKeeper Server是一个Java语言实现的分布式协调服务框架，因此需要6或更高版本的JDK支持。<br></span></p>
<p><span style="font-size:14px;">Zookeeper主要使用于构建一般的分布式应用，Zookeeper是Hadoop的分布式协调服务。</span></p>
<p><span style="font-size:14px;">分布式协调服务是出了名的难得编写正确，很容易出现竞争条件和死锁之类的错误。ZooKeeper的动机是减轻为分布式应用开发协调服务的负担.</span></p>
<p><span style="font-size:14px;">分布式应用的困难在于会出现“部分失败”，即我们甚至不知道一个操作是否已经失败。Zookeeper并不能根除部分失败，也不能隐藏部分失败，但他提供了一组工具，使你在构建分布式应用时能够对部分失败进行正确处理。</span></p>
<p><br></p>
<p><span style="font-size:14px;"><strong>Zookeeper的特点</strong>：</span></p>
<p><span style="font-size:14px;">1.简单性；Zookeeper的核心是一个精简的文件系统。（提供操作：排序和通知）</span></p>
<p><span style="font-size:14px;">2.富有表现力；实现协调数据结构和协议。（相关实例：分布式队列、分布式锁和一组同级节点中的“领导者选举 leader election”）</span></p>
<p><span style="font-size:14px;">3.高可用性；运行于一组机器上，高可用，完全可以依赖。（避免出现单点故障）</span></p>
<p><span style="font-size:14px;">4.采用松耦合交互方式；在Zookeeper支持的交互过程中，参与者不需要彼此了解。（“约会”机制，让进程在不了解其他进程或网络状况的情况下能够彼此发现并进行交互；参与协调的各方甚至可以不必同时存在，Zookeeper中可以留下一条消息。）</span></p>
<p><span style="font-size:14px;">5.是一个资源库；Zookeeper提供了一个通用协调模式实现和方法的开源共享存储库。</span></p>
<p><br></p>
<p><span style="font-size:14px;">理解Zookeeper的一种方法就是将其看作一个具有高可用性的文件系统。没有文件和目录，而是统一使用“节点”概念，称为znode。</span></p>
<p><span style="font-size:14px;">ZooKeeper中的每一个节点是都通过路径来识别。ZooKeeper的节点是通过像树一样的结构来进行维护的，并且每一个节点通过路径来标示以及访问。除此之外，每一个节点还拥有自身的一些信息，包括：数据、数据长度、创建时间、修改时间等等。</span></p>
<p><br></p>
<p><strong><span style="font-size:14px;">Zookeeper维护一个具有层次关系的数据结构，类似于一个标准的文件系统，这种数据结构有如下这些特点：</span></strong></p>
<ol class="list-paddingleft-2" style="list-style-type:decimal;">
 <li><p><span style="font-size:14px;">每个子目录项如 NameService 都被称作为 znode，这个 znode 是被它所在的路径唯一标识，如 Server1 这个 znode 的标识为 /NameService/Server1</span></p></li>
 <li><p><span style="font-size:14px;">znode 可以有子节点目录，并且每个 znode 可以存储数据，注意 EPHEMERAL 类型的目录节点不能有子节点目录</span></p></li>
 <li><p><span style="font-size:14px;">znode 是有版本的，每个 znode 中存储的数据可以有多个版本，也就是一个访问路径中可以存储多份数据</span></p></li>
 <li><p><span style="font-size:14px;">znode 可以是临时节点，一旦创建这个 znode 的客户端与服务器失去联系，这个 znode 也将自动删除，Zookeeper 的客户端和服务器通信采用长连接方式，每个客户端和服务器通过心跳来保持连接，这个连接状态称为 session，如果 znode 是临时节点，这个 session 失效，znode 也就删除了</span></p></li>
 <li><p><span style="font-size:14px;">znode 的目录名可以自动编号，如 App1 已经存在，再创建的话，将会自动命名为 App2</span></p></li>
 <li><p><span style="font-size:14px;">znode 可以被监控，包括这个目录节点中存储的数据的修改，子节点目录的变化等，一旦变化可以通知设置监控的客户端，这个是 Zookeeper 的核心特性，Zookeeper 的很多功能都是基于这个特性实现的，后面在典型的应用场景中会有实例介绍</span></p></li>
</ol>
<p><br></p>
<p><strong><span style="font-size:14px;">使用示例：</span></strong><br></p>
<p style="white-space:normal;"><span style="font-size:14px;">假设有一组服务器用于为客户端提供某种服务。我们希望每个客户端都能找到其中一台服务器，这样它们就可以使用这项服务。</span></p>
<p style="white-space:normal;"><span style="font-size:14px;">有一个挑战是如何维护这组服务器的列表。这组服务器的成员列表显然不能存储在网络中的单个节点上，否则该节点的故障将意味着整个系统的故障，我们希望这个成员列表是高可用的。</span></p>
<p style="white-space:normal;"><span style="font-size:14px;">我们还希望当其中一台服务器出现故障时，能够从这组服务器成员列表中删除该节点，避免提供不可用的服务。</span></p>
<p><span style="font-size:14px;"><br></span></p>
<p><br></p>
