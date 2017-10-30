<p>基本都是在群里讨论的时候，别人问的入门问题，以后想到新的问题再补充进来。但是其实入门问题也很重要，对原理的理解决定了学习能够深入的程度。</p>
<p>本篇不讨论Hadoop，只介绍周边软件。</p>
<p><br></p>
<p>Hive：</p>
<p>这个是我被人问的最多的软件，可见它在hadoop周边生态里的利用率也是最高的。</p>
<p>Hive到底是什么？</p>
<p>如何来严格的定义Hive确实不是太容易，通常我们为了非Hadoop专业人士容易理解，往往称它为数据仓库。但是，从技术上说，我觉得这样定义并不严格，Hive自己并不保存任何数据，即使是它的元数据，它没有传统意义上的数据库所具备的为索引和存储所设计的数据结构。它的元数据保存在内存数据库或者关系型数据库里，而数据则是直接读取HDFS上的文件或路径。这跟传统意义上的数据仓库并不一样。</p>
<p>我自己琢磨的一个解释是：<span style="color:#ff0000;">Hive是一个可以将SQL语句转换成map/reduce任务的编译器。</span></p>
<p>它可以免去你自己编写map/reduce的开发周期，仅仅用一条sql语句来完成以前可能要做一天的事情，我觉得这是这个工具最伟大的地方。所以我很感谢facebook将它开源出来。</p>
<p><br></p>
<p>什么是元数据(metadata)？</p>
<p>这也是无数人问的问题，有些人说是用来对数据进行描述的数据。我更愿意说元数据是管理数据的数据。打个比方，兵马俑，大家都知道，有很多个坑，互相都不挨着，每个坑里都有很多兵马俑。这个兵马俑就是数据，而对大坑的编号，一号坑，二号坑，这个一号二号就是元数据。提起一号，就知道，里面有100个，提起二号，就知道有120个。这就是数据和元数据关系。</p>
<p><br></p>
<p>Hive的表结构和数据是从哪里来的？</p>
<p>上面说了，Hive并不自己保存数据，它所有的数据都是来自于存储在HDFS上的文件，而你所设计的表结构，仅仅是对这些文件内容的某一个列的映射名称，是个映射，仅此而已。也就是说，你在HIVE表里面定义字段a，字段b。那么Hive在处理文本文件的时候，就认为文件里面第一列属于a字段，第二列属于b字段。更简单的比喻是，你可以把Hive当成mysql的csv引擎，或者一个可以处理百亿行数据的Excel，一个可以写sql的excel。</p>
<p><br></p>
<p>HiveQL是否兼容SQL92/95？</p>
<p>大部分语法兼容，但并不完全兼容，从使用上来说，很多函数方面还不是很完善，比如聚类，抽样等等。但是已经很好了，并且Hive提供了UDF方法，你可以自己写函数加载到HiveQL里面。HiveQL的语法更类似于Mysql。Hive还提供map/reduce的语言接口，你可以把自己写的map/reduce jar或者脚本嵌入到HiveQL语言里，可以对HQL结果再次做自定义的map/reduce计算。</p>
<p><br></p>
<p>Hive进行远程访问方便吗？</p>
<p>很方便，不过非java语言开发要学习一下thrift框架。针对Java，原生提供JDBC驱动。针对window应用，有第三方开发的ODBC驱动，比如cloudera和mapr都提供hive的ODBC驱动。这意味着，之前基于Oracle或者mysql的数据分析，可以以很小的代价迁移到Hive上。</p>
<p><br></p>
<p>Hive能做到实时处理吗？</p>
<p>完全没戏，别看他是SQL语言，但是其本质是map/reduce。map/reduce的本质是为离线处理准备的，所以别指望Hive可以跟Mysql,Oracle一样用。不过有些基于内存的分布式SQL引擎正在完善，比如Cloudera的Impala或者Hortonworks的Tedz(好像是这么拼的)。对查询速度提升非常大，但是也无法做到实时查询。其实想象，几百亿条，几百个TB的数据，再加上多维度统计和计算。即便磁盘IO，内存IO够，CPU也不一定算的过来。</p>
<p><br></p>
<p>具体语法和更多详细资料请参阅hive.apache.org上关于DDL和DML的文档。</p>
<p>------------------------------------------------------------</p>
<p><br></p>
<p>HBase：</p>
<p>除了Hadoop和Hive，这个是问的最多的了，不管是对它的理解还是对它的错误分析。</p>
<p><br></p>
<p>HBase是数据库吗？</p>
<p>它是NoSQL，不是传统意义上的数据库，是一个基于列族的NoSQL。是对Google BigTable论文的开源实现。</p>
<p><br></p>
<p>什么是列族(Column family)？</p>
<p>我很想给出一个关于这个名词的专业解释，但是找遍了谷歌和百度也没有一个对列族的中文解释。所以，我可以打个不是特别准确的比方，只是为了容易理解。在Hbase中，列族相当于关系型数据库的表。而Key-Value这样的键值对，相当于数据库里面的一行。列，可以算是字段吧。专业一点的比喻就是个矩阵。但是是一个密集矩阵，不是稀疏矩阵。</p>
<p><br></p>
<p>HBase更新记录是怎么做的？</p>
<p>众所周知，HDFS是不允许修改文件的，也就是说，文件一旦被写入关闭了，就无法改变了。只可以做追加操作。所以，HBase在这里也是这样，如果你修改了Key-Value，那么，这个操作将追加到Hbase存储的文件末尾，而不是将原来的记录修改并覆盖掉。那么，这样做有一个最大的好处，就是说，之前的旧记录会保存。修改的数据会像log一样被保留起来，直到超出你所希望保留的限度。</p>
<p><br></p>
<p>装HBase需要装zookeeper吗？</p>
<p>不需要，HBase自己带了zookeeper了。下面会说到zookeeper，所以这里不赘述。</p>
<p><br></p>
<p>Hbase可以做实时查询吗，容量有限制吗？</p>
<p>可以实时，就是干这个用的，facebook之前用cassandra处理用户登录和用户信息等内容，后来全转移到hbase上面了。容量方面几乎没有限制，几百亿行，数百万列轻轻松松完成。</p>
<p> ------------------------------------------------------------</p>
<p><br></p>
<p>Zookeeper：</p>
<p>ZooKeeper是干什么的？</p>
<p>ZooKeeper是一个协同工具，保证分布式系统在工作中的一致性，锁，配置同步等基础运维功能。但是不是说要装Hadoop和周边生态都需要用到它，通常是用不到的，Hbase自带了，而其他基本不会用。有时候会在Hadoop 1.0的HA里面用到，但是要自己做防NameNode脑裂(split brain)的工作，脑裂不解释，上google查。</p>
<p><br></p>
<p><span style="color:#ff0000;"><strong>ZooKeeper是不是需要必须装奇数个服务器才行？</strong></span></p>
<p>这是个特别经典的经久不衰的流言，每个群里提到zookeeper的人基本都会问，有很多中文介绍ZooKeeper的文章都说必须奇数，言之凿凿，但是事情真的是这样吗？其实不是的。</p>
<p>这个要从Paxos算法原理上说，Paxos是个Leader的选举算法，既然是选举，就要超过半数同意，那么一个人是谈不上选举的，两个人也不行，原因是两个人都互相投赞成票。</p>
<p>Paxos也有前提约定，最基本的约定之一就是，第一次的提案，后面的人必须接受。</p>
<p>举例说明：</p>
<p>A提案说，我要选自己当头，B你同意吗？B说，我同意选A</p>
<p>接着B提案说，我要选自己当头，A你同意吗？A说，我同意选B</p>
<p>A又发起提案，我要选自己当头，B你同意吗？B说，我同意选A</p>
<p>接着B又发起提案，我要选自己当头，A你同意吗？A说，我同意选B</p>
<p>......无穷无尽的选下去。</p>
<p>每个人得票数是相同的，会永远这样选下去，所以两个人是选不出来的，要至少三个人才可以，继续举例：</p>
<p>A提案说，我要选自己，B你同意吗？C你同意吗？B说，我同意选A；C说，我同意选A。(注意，这里超过半数了，其实在现实世界选举已经成功了。但是计算机世界是很严格，另外要理解算法，要继续模拟下去。)</p>
<p>接着B提案说，我要选自己，A你同意吗；A说，我已经超半数同意当选，你的提案无效；C说，A已经超半数同意当选，B提案无效。</p>
<p>接着C提案说，我要选自己，A你同意吗；A说，我已经超半数同意当选，你的提案无效；B说，A已经超半数同意当选，C的提案无效。</p>
<p>选举已经产生了Leader，后面的都是follower，只能服从Leader的命令。而且这里还有个小细节，就是其实谁先启动谁当头。</p>
<p>这不是一个能完整描述Paxos算法和基础投票协议的例子，本身这个算法和后续的很多协议是很复杂的，还有很多其他的角色和约定，这个例子只是让人更能容易些的理解这个算法。Paxos算法在百度百科的介绍简直没法看，本来可以简单描述的事情非写的很复杂，装的很懂的样子。</p>
<p>那么通过这样一个选举，可以得知，ZooKeeper只要保证服务器超过3台启动了，就可以正常工作。以后无论加多少台，即便是偶数，也只能接受A是leader。所以，同理，Hbase的服务器也可以不是奇数个。</p>
<p><br></p>
<p>偶数是ZooKeeper不建议的个数，但不是不可以。原因在是这样，如果当你的集群里有4台服务器的时候，2台挂了，就选不出leader了，而你有5台的时候，挂了2个，剩下3个，还能选出leader。所以，ZooKeeper并不是必须奇数台，而是只要大于4，就基本可以保证高可用了。<span style="color:#ff0000;">所以，Zookeeper必须奇数服务器数量的流言被终结了。</span>但是这个流言的影响，可能还需要很久才能消除。</p>
<p><br></p>
<p>以下内容摘自Zookeeper官方文档</p>
<blockquote>
 <h3 class="h4" style="font-family:'trebuchet ms', verdana, arial, helvetica, sans-serif;margin:18px 0px 0px;font-size:17px;padding:0px;background-color:#ffffff;">Clustered (Multi-Server) Setup</h3>
 <p style="line-height:15px;font-family:verdana, helvetica, sans-serif;font-size:13px;background-color:#ffffff;margin-top:.5em;margin-bottom:1em;">For reliable ZooKeeper service, you should deploy ZooKeeper in a cluster known as an <em>ensemble</em>. As long as a majority of the ensemble are up, the service will be available. Because Zookeeper requires a majority, it is best to use an odd number of machines. For example, with four machines ZooKeeper can only handle the failure of a single machine; if two machines fail, the remaining two machines do not constitute a majority. However, with five machines ZooKeeper can handle the failure of two machines.</p>
 <p><br></p>
</blockquote>
<p>大多数人可能只看到odd number of machines 就哦耶了，没继续往下看。</p>
<p><br></p>
<p>顺便提一下，Paxos算法简化版是微软的专利，paxos也是微软的工程师提出来的。Zookeeper是对Google chubby的开源实现。chubby和zookeeper都采用paxos算法实现分布式系统一致性的维护。</p>
<p><br></p>
<p>Mahout什么的留到下回再写。</p>
<p><br></p>
<p>本文出自 “<a href="http://slaytanic.blog.51cto.com">实践检验真理</a>” 博客，转载请与作者联系！</p>
