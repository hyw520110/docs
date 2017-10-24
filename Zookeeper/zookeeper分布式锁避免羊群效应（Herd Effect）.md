<p style="text-align:left;">本文主要讲述在使用ZooKeeper进行分布式锁的实现过程中，如何有效的避免“羊群效应(herdeffect)”的出现。</p>
<h1 align="left"><span style="text-decoration:underline;"><strong>一般的分布式锁实现</strong></span></h1>
<p style="text-align:left;">这里简单的讲下一般的分布式锁如何实现。具体的代码实现可以在这里看到：<a href="https://svn.apache.org/repos/asf/zookeeper/trunk/src/recipes/lock/" target="_blank">https://svn.apache.org/repos/asf/zookeeper/trunk/src/recipes/lock/</a></p>
<p style="text-align:left;">在之前的《<a href="http://nileader.blog.51cto.com/1381108/946788" target="_blank">ZooKeepe数据模型</a>》一文中提到过，zookeeper中节点的创建类型有4类，这里我们重点关注下临时顺序节点。这种类型的节点有几下几个特性：</p>
<ol class="list-paddingleft-2">
 <li><p>节点的生命周期和客户端会话绑定，即创建节点的客户端会话一旦失效，那么这个节点也会被清除。</p></li>
 <li><p>每个父节点都会负责维护其子节点创建的先后顺序，并且如果创建的是顺序节点（SEQUENTIAL）的话，父节点会自动为这个节点分配一个整形数值，以后缀的形式自动追加到节点名中，作为这个节点最终的节点名。</p></li>
</ol>
<p style="text-align:left;">利用上面这两个特性，我们来看下获取实现分布式锁的基本逻辑：</p>
<ol class="list-paddingleft-2">
 <li><p>客户端调用create()方法创建名为“_locknode_/guid-lock-”的节点，需要注意的是，这里节点的创建类型需要设置为EPHEMERAL_SEQUENTIAL。</p></li>
 <li><p>客户端调用getChildren(“_locknode_”)方法来获取所有已经创建的子节点，同时在这个节点上注册上子节点变更通知的Watcher。</p></li>
 <li><p>客户端获取到所有子节点path之后，如果发现自己在步骤1中创建的节点是所有节点中序号最小的，那么就认为这个客户端获得了锁。</p></li>
 <li><p>如果在步骤3中发现自己并非是所有子节点中最小的，说明自己还没有获取到锁，就开始等待，直到下次子节点变更通知的时候，再进行子节点的获取，判断是否获取锁。</p></li>
</ol>
<p style="text-align:left;"><strong>释放锁</strong>的过程相对比较简单，就是删除自己创建的那个子节点即可。</p>
<h1 align="left"><span style="text-decoration:underline;"><strong>问题所在</strong></span></h1>
<p>上面这个分布式锁的实现中，大体能够满足了一般的分布式集群竞争锁的需求。这里说的一般性场景是指集群规模不大，一般在10台机器以内。</p>
<p>不过，细想上面的实现逻辑，我们很容易会发现一个问题，步骤4，“即获取所有的子点，判断自己创建的节点是否已经是序号最小的节点”，这个过程，在整个分布式锁的竞争过程中，大量重复运行，并且绝大多数的运行结果都是判断出自己并非是序号最小的节点，从而继续等待下一次通知――这个显然看起来不怎么科学。客户端无端的接受到过多的和自己不相关的事件通知，这如果在集群规模大的时候，会对Server造成很大的性能影响，并且如果一旦同一时间有多个节点的客户端断开连接，这个时候，服务器就会像其余客户端发送大量的事件通知――这就是所谓的羊群效应。而这个问题的根源在于，没有找准客户端真正的关注点。</p>
<p>我们再来回顾一下上面的分布式锁竞争过程，它的核心逻辑在于：判断自己是否是所有节点中序号最小的。于是，很容易可以联想的到的是，每个节点的创建者只需要关注比自己序号小的那个节点。</p>
<h1 align="left"><strong><span style="text-decoration:underline;">改进后的分布式锁实现</span></strong></h1>
<p>下面是改进后的分布式锁实现，和之前的实现方式唯一不同之处在于，这里设计成每个锁竞争者，只需要关注”_locknode_”节点下序号比自己小的那个节点是否存在即可。实现如下：</p>
<ol class="list-paddingleft-2">
 <li><p>客户端调用create()方法创建名为“_locknode_/guid-lock-”的节点，需要注意的是，这里节点的创建类型需要设置为EPHEMERAL_SEQUENTIAL。</p></li>
 <li><p>客户端调用getChildren(“_locknode_”)方法来获取所有已经创建的子节点，注意，这里不注册任何Watcher。</p></li>
 <li><p>客户端获取到所有子节点path之后，如果发现自己在步骤1中创建的节点序号最小，那么就认为这个客户端获得了锁。</p></li>
 <li><p>如果在步骤3中发现自己并非所有子节点中最小的，说明自己还没有获取到锁。此时客户端需要找到比自己小的那个节点，然后对其调用exist()方法，同时注册事件监听。</p></li>
 <li><p>之后当这个被关注的节点被移除了，客户端会收到相应的通知。这个时候客户端需要再次调用getChildren(“_locknode_”)方法来获取所有已经创建的子节点，确保自己确实是最小的节点了，然后进入步骤3。</p></li>
</ol>
<h1><span style="text-decoration:underline;"><strong>结论</strong></span></h1>
<p>上次两个分布锁实现，都是可行的。具体选择哪个，取决于你的集群规模。</p>
<p></p>
