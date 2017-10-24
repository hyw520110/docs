<p><span style="color:#002060;">在ZooKeeper的运维过程中，我们经常会碰到这样的问题，就是快照数据文件越来越大，但是ZooKeeper上的数据节点数量并没有相应的增加。</span></p>
<p><span style="color:#002060;">这说明什么问题：一定是有客户端在将ZooKeeper当数据库使用了。长此以往，必然会引起ZooKeeper内存数据过大而影响性能及集群间的数据同步。</span></p>
<p><span style="color:#002060;">那么有没有办法能够排查此类问题呢？解决方法是有的，我们首先需要使用SnapshotFormatter可视化快照数据。</span></p>
<p><span style="color:#002060;">数据快照机制是ZooKeeper用来定时进行内存全量数据dump，每次数据快照都会生成磁盘上的一个snapshot文件，例如：snapshot.300000007。</span></p>
<p><span style="color:#002060;">但是令人沮丧的是，这个文件是二进制格式的，无法看出任何有意义的数据信息。</span></p>
<p><span style="color:#002060;">幸好，ZooKeeper提供给我们一个可视化快照数据的工具：SnapshotFormatter</span></p>
<p><strong><span style="color:#002060;">使用方法如下</span></strong><span style="color:#002060;">：</span></p>
<p><span style="color:#002060;">java &nbsp;SnapshotFormatter 快照数据文件</span></p>
<p><span style="color:#002060;">例如我们对上面提到的事务日志对应的快照数据文件进行可视化转换：</span></p>
<p><span style="color:#002060;">java SnapshotFormatter snapshot.300000007</span></p>
<p><span style="color:#002060;">输出内容如下：</span></p>
<pre class="brush:as3;toolbar:false;">ZNode Details (count=7):
----
/
  cZxid = 0x00000000000000
  ctime = Thu Jan 01 08:00:00 CST 1970
  mZxid = 0x00000000000000
  mtime = Thu Jan 01 08:00:00 CST 1970
  pZxid = 0x00000300000003
  cversion = 2
  dataVersion = 0
  aclVersion = 0
  ephemeralOwner = 0x00000000000000
  dataLength = 0
----
/test_log
  cZxid = 0x00000300000003
  ctime = Tue Sep 03 07:08:40 CST 2012
  mZxid = 0x00000300000004
  mtime = Tue Sep 03 08:13:54 CST 2012
  pZxid = 0x00000300000006
  cversion = 1
  dataVersion = 1
  aclVersion = 0
  ephemeralOwner = 0x00000000000000
  dataLength = 2
----
……</pre>
<p><br></p>
<p>从上面的输出中，我们就可以看到ZooKeeper上的所有节点信息了，其中会看到有个dataLength属性，这个就是该数据节点的数据大小了。排序就可以排查出异常节点了。</p>
<p><br></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/983259">http://nileader.blog.51cto.com/1381108/983259</a></p>
