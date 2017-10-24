<p><span style="font-family:'comic sans ms';">转载请注明：</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family:'comic sans ms';">@ni掌柜</span></a><span style="font-family:'comic sans ms';"> nileader@gmail.com</span></p>
<p><span style="font-family:'comic sans ms';"> 本文主要讲述ZooKeeper的数据模型，包括ZooKeeper的数据视图，节点的层次结构以及节点类型等基本属性。Zookeeper的视图结构类似标准的Unix文件系统，但是没有引入文件系统相关概念：目录和文件，而是使用了自己特有的节点(node)概念，称为znode。Znode是ZooKeeper中数据的最小单元，每个znode上都可以保存数据，同时还可以挂载子节点，也构成了一个层次化的命名空间，我们称之为树。</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><strong><span style="font-size:22px;">树</span></strong></p>
<p><span style="font-family:'comic sans ms';"> 首先我们来看下面这张图，对ZooKeeper上的数据节点有一个大概的认识。这个图来自zookeeper官方文档中，相信很多开发者在网上也都看到过很多次了。在ZK中，每一个数据节点称为一个znode，所有znode按层次化进行组织，形成一棵树。znode是一个跟Unix文件系统路径相似的节点，由一系列由斜杠（/ )进行分割的路径表示。可以向这个节点中写入数据，也可以在节点下面创建子节点。</span></p>
<p><a href="http://img1.51cto.com/attachment/201211/085951545.png" target="_blank"><span style="font-family:'comic sans ms';"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201211/085951545.png" border="0" alt="085951545.png"></span></a></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><strong><span style="font-size:22px;">节点类型</span></strong></p>
<p><span style="font-family:'comic sans ms';"> 每个节点是有生命周期的，这取决于节点的类型。在ZooKeeper中，节点类型可以分为持久节点（PERSISTENT ）、临时节点（EPHEMERAL），以及时序节点（SEQUENTIAL ），具体在节点创建过程中，一般是组合使用，可以生成以下4种节点类型：</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="text-decoration:underline;"><span style="font-size:16px;">持久节点（PERSISTENT）</span></span></p>
<p><span style="font-family:'comic sans ms';">所谓持久节点，是指在节点创建后，就一直存在，直到有删除操作来主动清除这个节点――不会因为创建该节点的客户端会话失效而消失。</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="text-decoration:underline;"><span style="font-size:16px;">持久顺序节点（PERSISTENT_SEQUENTIAL ）</span></span></p>
<p><span style="font-family:'comic sans ms';">这类节点的基本特性和上面的节点类型是一致的。额外的特性是，在ZK中，每个父节点会为他的第一级子节点维护一份时序，会记录每个子节点创建的先后顺序。基于这个特性，在创建子节点的时候，可以设置这个属性，那么在创建节点过程中，ZK会自动为给定节点名加上一个数字后缀，作为新的节点名。这个数字后缀的上限是整型的最大值。</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="text-decoration:underline;"><span style="font-size:16px;">临时节点（EPHEMERAL ）</span></span></p>
<p><span style="font-family:'comic sans ms';">和持久节点不同的是，临时节点的生命周期和客户端会话绑定。也就是说，如果客户端会话失效，那么这个节点就会自动被清除掉。注意，这里提到的是会话失效，而非连接断开。另外，在临时节点下面不能创建子节点。</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="text-decoration:underline;"><span style="font-size:16px;">临时顺序节点（EPHEMERAL_SEQUENTIAL）</span></span></p>
<p><span style="font-family:'comic sans ms';"><strong><span style="font-size:22px;">节点信息</span></strong></span></p>
<pre></pre>
<ol class="dp-sql list-paddingleft-2">
 <li class="alt"><p><span style="font-family:'comic sans ms';">[zk: localhost:2181(CONNECTED) 4] get /YINSHI.MONITOR.ALIVE.<span class="keyword">CHECK</span></span></p></li>
 <li><p><span style="font-family:'comic sans ms';">?t 10.232.102.191:21811353595654255 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">cZxid = 0x300000002 </span></p></li>
 <li><p><span style="font-family:'comic sans ms';">ctime = Thu <span class="keyword">Dec</span> 08 23:29:53 CST 2011 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">mZxid = 0xe00008bbf </span></p></li>
 <li><p><span style="font-family:'comic sans ms';">mtime = Thu Jul 28 07:17:34 CST 2012 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">pZxid = 0x300000002 </span></p></li>
 <li><p><span style="font-family:'comic sans ms';">cversion = 0 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">dataVersion = 2164293 </span></p></li>
 <li><p><span style="font-family:'comic sans ms';">aclVersion = 0 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">ephemeralOwner = 0x0 </span></p></li>
 <li><p><span style="font-family:'comic sans ms';">dataLength = 39 </span></p></li>
 <li class="alt"><p><span style="font-family:'comic sans ms';">numChildren = 0 </span></p></li>
</ol>
<p><span style="font-family:'comic sans ms';"> 上面这个信息，是在ZK命令行的一个输出信息，从这个输出内容中可以清楚的看到，ZK的一个节点包含了哪些信息。其中比较重要的信息包括节点的数据内容，节点创建/修改的事务ID，节点/修改创建时间，当前的数据版本号，数据内容长度，子节点个数等。<br></span></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/946788">http://nileader.blog.51cto.com/1381108/946788</a></p>
