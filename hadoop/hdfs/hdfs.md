# 简介
Hadoop分布式文件系统(HDFS)是一种被设计成适合运行在通用硬件上的分布式文件系统。HDFS是一个高度容错性的系统，适合部署在廉价的 机器上。它能提供高吞吐量的数据访问，非常适合大规模数据集上的应用,适用于一次写入、多次查询的情况，不支持并发写情况，小文件不合适

## 优点:

- 高容错性:数据自动保存多个副本,副本丢失后,自动恢复,可靠性同时也实现了加快处理速度,A节点负载高,可读取B节点

- 适合批处理:移动计算而非数据,数据位置暴漏给计算框架

- 适合大数据处理:甚至PB级数据,百万规模以上文件数量,10k+节点

- 可构建在廉价机器上:通过多副本提高可靠性,提供容错和恢复机制

## 缺点:

- 低延迟数据访问:比如订单是不适合存储HDFS中的,要求数据毫秒级就要查出来

- 小文件存取:不适合大量的小文件存储,如真有这种需求的话,要对小文件进行压缩

- 并发写入、文件随机修改:不适合修改,实际中网盘、云盘内容是不允许修改的,只能删了从新上传,他们都是hadoop做的

HDFS中的存储单元(block),一个文件会被切分成若干个固定大小的block(块默认是64MB,可配置,若不足64MB,则单独一个块),存储在不同节点上,默认每个block有三个副本(副本越多,磁盘利用率越低),block大小和副本数通过Client端上传文件时设置,文件上传成功后副本数可变,block size不可变.如一个200M文件会被切成4块,存在不同节点,如挂了一台机器后,会自动在复制副本,恢复到正常状态,只要三个机器不同时挂,数据不会丢失.


HDFS包含3种节点,NameNode(NN),secondary NameNode(SNN),DataNode(DN).

## 分布式文件系统

分布式文件系统是分布式系统的一个子集，它们解决的问题就是数据存储。换句话说，它们是横跨在多台计算机上的存储系统。存储在分布式文件系统上的数据自动分布在不同的节点上。

## 分离元数据(NameNode)和数据(DataNode)

存储到文件系统中的每个文件都有相关联的元数据。元数据包括了文件名、i节点(inode)数、数据块位置等，而数据则是文件的实际内容

HDFS的设计理念是拿出一台或多台机器来保存元数据，并让剩下的机器来保存文件的内容

NameNode和DataNode是HDFS的两个主要组件。其中，元数据存储在NameNode上，而数据存储在DataNode的集群上。 NameNode不仅要管理存储在HDFS上内容的元数据，而且要记录一些事情，比如哪些节点是集群的一部分，某个文件有几份副本等。它还要决定当集群的节点宕机或者数据副本丢失的时候系统需要做什么。


存储在HDFS上的每份数据片有多份副本(replica)保存在不同的服务器上。在本质上，NameNode是HDFS的Master(主服务器)，DataNode是Slave(从服务器)。

### NameNode

#### 作用 
 
NameNode的作用是管理文件目录结构，接受用户的操作请求,是管理数据节点的。

维护两套数据，一套是文件目录与数据块之间的关系，另一套是数据块与节点之间的关系。前一套数据是静态的，是存放在磁盘上的，通过fsimage和edits文件来维护；后一套数据是动态的，不持久放到到磁盘的，每当集群启动的时候，会自动建立这些信息，所以一般都放在内存中。

所以他是整个文件系统的管理节点。它维护着整个文件系统的 文件目录树，文件/目录的元信息和每个文件对应的数据块列表。接收用户的操作请求 。

文件包括：

- fsimage （文件系统镜像）:元数据镜像文件。存储某一时段NameNode内存 元数据信息。
- edits: 操作日志文件。
- fstime: 保存最近一次checkpoint的时间

以上这些文件是保存在linux的文件系统中

#### 特点

- 是一种允许文件 通过网络在多台主机上分享的文件系统，可让多机器上的多用户分享文件和存储空间。

- 通透性。让实际上是通过网络来访问文件的动作，由程序与用户看来，就像是访问本地的磁盘一般。

- 容错。即使系统中有某些节点脱机，整体来说系统仍然可以持续运作而不会有数据损失。

- 适用于 一次写入、 多次查询的情况，不支持并发写情况，小文件不合适

## HDFS写过程
NameNode负责管理存储在HDFS上所有文件的元数据，它会确认客户端的请求，并记录下文件的名字和存储这个文件的DataNode集合。它把该信息存储在内存中的文件分配表里.

例如，dataNode有A、B、C、D、E，客户端请求NameNode将文件app.log写入HDFS,执行流程：

- 客户端发送写文件请求给NameNode
- NameNode响应，分配数据存储到A、B、D
- 客户端发送文件给dataNode B
- dataNode B分发文件给A
- dataNode A 分发文件给D
- dataNode D写入文件完成，发送消息给A
- dataNode A发送消息给B
- dataNode B发送消息给客户端，表示写入完成

在分布式文件系统的设计中，挑战之一是如何确保数据的一致性。对于HDFS来说，直到所有要保存数据的DataNodes确认它们都有文件的副本 时，数据才被认为写入完成。因此，数据一致性是在写的阶段完成的。一个客户端无论选择从哪个DataNode读取，都将得到相同的数据。

## HDFS读过程
为了理解读的过程，可以认为一个文件是由存储在DataNode上的数据块组成的。客户端查看之前写入的内容的执行流程

- 客户端询问NameNode它应该从哪里读取文件。 
- NameNode发送数据块的信息给客户端。(数据块信息包含了保存着文件副本的DataNode的IP地址，以及DataNode在本地硬盘查找数据块所需要的数据块ID。)  
- 客户端检查数据块信息，联系相关的DataNode，请求数据块。 
- DataNode返回文件内容给客户端，然后关闭连接，完成读操作。




HDFS中常用到的命令

hadoop fs

	 
	hadoop fs -ls /
	hadoop fs -lsr
	hadoop fs -mkdir /user/hadoop
	hadoop fs -put a.txt /user/hadoop/
	hadoop fs -get /user/hadoop/a.txt /
	hadoop fs -cp src dst
	hadoop fs -mv src dst
	hadoop fs -cat /user/hadoop/a.txt
	hadoop fs -rm /user/hadoop/a.txt
	hadoop fs -rmr /user/hadoop/a.txt
	hadoop fs -text /user/hadoop/a.txt
	hadoop fs -copyFromLocal localsrc dst 与hadoop fs -put功能类似。
	hadoop fs -moveFromLocal localsrc dst 将本地文件上传到hdfs，同时删除本地文件。

hadoop fsadmin 
	 
	hadoop dfsadmin -report
	hadoop dfsadmin -safemode enter | leave | get | wait
	hadoop dfsadmin -setBalancerBandwidth 1000

hadoop fsck