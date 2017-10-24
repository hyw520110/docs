<p><span style="font-family: 'Comic Sans MS';">转载请注明：</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family: 'Comic Sans MS';">@ni掌柜</span></a></p> 
<p>&nbsp; &nbsp; 本文重点围绕ZooKeeper的Watcher，介绍通知的状态类型和事件类型，以及这些事件通知的触发条件。</p> 
<p>&nbsp;</p> 
<p><u><span style="font-size: 22px;"><strong>1、浅谈Watcher接口</strong></span></u></p> 
<p>在ZooKeeper中，接口类Watcher定义了事件通知相关的逻辑，包含了KeeperState和EventType两个枚举类，分别代表通知状态和事件类型。还有一个比较重要的接口方法：</p> 
<pre>
 <ol class="dp-j">
  <li class="alt"><span><span class="keyword">abstract</span><span>&nbsp;</span><span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;process(WatchedEvent&nbsp;event);&nbsp;</span></span></li>
 </ol></pre> 
<p>这个方法用于处理事件通知，每个实现类都应该自己实现合适的处理逻辑。参数WatchedEvent类封装了上面提到的两个枚举类，以及触发事件对应的ZK节点path，当然，这个path不一定每次通知都有，例如会话建立，会话失效或连接断开等通知类型，就不是针对某一个单独path的。</p> 
<div> 
 <div>
  <u><strong><span style="font-size: 22px;">2、如何注册Watcher</span></strong></u>
 </div> 
 <div>
  上面已经提到，Watcher接口已经提供了基本的回调方法用于处理来自服务器的通知。因此，我们只要在合适的地方实现这个接口，并传给服务器即可。下面来看看哪些是合适的地方：&nbsp;
 </div> 
 <div>
  <strong>A、构造方法</strong>
 </div> 
 <pre>
  <ol class="dp-j">
   <li class="alt"><span><span>ZooKeeper(String&nbsp;connectString,&nbsp;</span><span class="keyword">int</span><span>&nbsp;sessionTimeout,&nbsp;Watcher&nbsp;watcher)&nbsp;</span></span></li>
  </ol></pre> 
 <div>
  上面这个是ZooKeeper的一个构造方法，与ZK创建连接的时候会用到这个。这里我们重点关注第三个参数：Watcher，很显然在，这个就是一个注册Watcher的地方，传入的参数就是开发者自己Watcher接口实现。需要注意的是，这个地方注册的Watcher实现，会成为当前ZK会话的默认Watcher实现。也就是说，其它地方如果也想注册一个Watcher，那么是可以默认使用这个实现的。具体下面会涉及到。
 </div> 
 <div>
  <strong>B、API的读写接口中</strong>
 </div> 
 <pre>
  <ol class="dp-j">
   <li class="alt"><span><span class="keyword">public</span><span>&nbsp;Stat&nbsp;exists(String&nbsp;path,&nbsp;</span><span class="keyword">boolean</span><span>&nbsp;watch)</span><span class="keyword">throws</span><span>&nbsp;KeeperException,&nbsp;InterruptedException&nbsp;</span></span></li>
   <li>&nbsp;</li>
   <li><span><span class="keyword">public</span><span>&nbsp;List&lt;String&gt;&nbsp;getChildren(String&nbsp;path,&nbsp;</span><span class="keyword">boolean</span><span>&nbsp;watch)</span><span class="keyword">throws</span><span>&nbsp;KeeperException,InterruptedException&nbsp;</span></span></li>
   <li class="alt">&nbsp;</li>
   <li class="alt"><span><span class="keyword">public</span><span>&nbsp;</span><span class="keyword">byte</span><span>[]&nbsp;getData(String&nbsp;path,</span><span class="keyword">boolean</span><span>&nbsp;watch,Stat&nbsp;stat)</span><span class="keyword">throws</span><span>&nbsp;KeeperException,InterruptedException&nbsp;</span></span></li>
   <li>&nbsp;</li>
   <li><span><span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;register(Watcher&nbsp;watcher)&nbsp;</span></span></li>
  </ol></pre> 
</div> 
<p>&nbsp;</p> 
<p>&nbsp;</p> 
<p><u><strong><span style="font-size: 22px;">3、通知的状态类型与事件类型</span></strong></u></p> 
<p>在Watcher接口类中，已经定义了所有的状态类型和事件类型，这里把各个状态和事件类型之间的关系整理一下。</p> 
<p><strong>3.1状态：KeeperState.Disconnected(0)</strong></p> 
<p>此时客户端处于断开连接状态，和ZK集群都没有建立连接。</p> 
<p><strong>3.1.1事件：EventType.None(-1)</strong></p> 
<p><strong>触发条件</strong>：一般是在与服务器断开连接的时候，客户端会收到这个事件。</p> 
<p>&nbsp;</p> 
<p><strong>3.2状态：KeeperState. SyncConnected(3)</strong></p> 
<p><strong>3.2.1事件：EventType.None(-1)</strong></p> 
<p><strong>触发条件</strong>：客户端与服务器成功建立会话之后，会收到这个通知。</p> 
<p><strong>3.2.2事件：EventType. NodeCreated (1)</strong></p> 
<p><strong>触发条件</strong>：所关注的节点被创建。</p> 
<p><strong>3.2.3事件：EventType. NodeDeleted (2)</strong></p> 
<p><strong>触发条件</strong>：所关注的节点被删除。</p> 
<p><strong>3.2.4事件：EventType. NodeDataChanged (3)</strong></p> 
<p><strong>触发条件</strong>：所关注的节点的内容有更新。注意，这个地方说的内容是指数据的版本号dataVersion。因此，即使使用相同的数据内容来更新，还是会收到这个事件通知的。无论如何，调用了更新接口，就一定会更新dataVersion的。</p> 
<p><strong>3.2.5事件：EventType. NodeChildrenChanged (4)</strong></p> 
<p><strong>触发条件</strong>：所关注的节点的子节点有变化。这里说的变化是指子节点的个数和组成，具体到子节点内容的变化是不会通知的。</p> 
<p>&nbsp;</p> 
<p><strong>3.3状态 KeeperState. AuthFailed(4)</strong></p> 
<p><strong>3.3.1事件：EventType.None(-1)</strong></p> 
<p>&nbsp;</p> 
<p><strong>3.4状态 KeeperState. Expired(-112)</strong></p> 
<p><strong>3.4.1事件：EventType.None(-1)</strong></p> 
<p>&nbsp;</p> 
<p>&nbsp;</p> 
<p>&nbsp;</p> 
<p style="text-align: left;"><u><strong><span style="font-size: 22px;">4、程序实例</span></strong></u></p> 
<p>这里有一个可以用来演示“触发事件通知”和“如何处理这些事件通知”的程序AllZooKeeperWatcher.java。</p> 
<p>在这里：https://github.com/alibaba/taokeeper/blob/master/taokeeper-research/src/main/java/com/taobao/taokeeper/research/watcher/AllZooKeeperWatcher.java</p> 
<p>运行结果如下：</p> 
<pre>
 <ol class="dp-c">
  <li class="alt"><span><span>2012-08-05&nbsp;06:35:23,779&nbsp;-&nbsp;【Main】开始连接ZK服务器&nbsp;</span></span></li>
  <li><span>2012-08-05&nbsp;06:35:24,196&nbsp;-&nbsp;【Watcher-1】收到Watcher通知&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:24,196&nbsp;-&nbsp;【Watcher-1】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:24,196&nbsp;-&nbsp;【Watcher-1】事件类型:&nbsp;&nbsp;None&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:24,196&nbsp;-&nbsp;【Watcher-1】成功连接上ZK服务器&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:24,196&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:24,354&nbsp;-&nbsp;【Main】节点创建成功,&nbsp;Path:&nbsp;/nileader,&nbsp;content:&nbsp;1353337464279&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:24,554&nbsp;-&nbsp;【Watcher-2】收到Watcher通知&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:24,554&nbsp;-&nbsp;【Watcher-2】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:24,554&nbsp;-&nbsp;【Watcher-2】事件类型:&nbsp;&nbsp;NodeCreated&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:24,554&nbsp;-&nbsp;【Watcher-2】节点创建&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:24,582&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:27,471&nbsp;-&nbsp;【Main】更新数据成功，path：/nileader,&nbsp;&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:27,667&nbsp;-&nbsp;【Watcher-3】收到Watcher通知&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:27,667&nbsp;-&nbsp;【Watcher-3】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:27,667&nbsp;-&nbsp;【Watcher-3】事件类型:&nbsp;&nbsp;NodeDataChanged&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:27,667&nbsp;-&nbsp;【Watcher-3】节点数据更新&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:27,696&nbsp;-&nbsp;【Watcher-3】数据内容:&nbsp;1353337467434&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:27,696&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,534&nbsp;-&nbsp;【Main】节点创建成功,&nbsp;Path:&nbsp;/nileader/ch,&nbsp;content:&nbsp;1353337470471&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,728&nbsp;-&nbsp;【Watcher-4】收到Watcher通知&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,728&nbsp;-&nbsp;【Watcher-4】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,728&nbsp;-&nbsp;【Watcher-4】事件类型:&nbsp;&nbsp;NodeCreated&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,728&nbsp;-&nbsp;【Watcher-4】节点创建&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,758&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,958&nbsp;-&nbsp;【Watcher-5】收到Watcher通知&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,958&nbsp;-&nbsp;【Watcher-5】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,958&nbsp;-&nbsp;【Watcher-5】事件类型:&nbsp;&nbsp;NodeChildrenChanged&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,958&nbsp;-&nbsp;【Watcher-5】子节点变更&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:30,993&nbsp;-&nbsp;【Watcher-5】子节点列表：[ch]&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:30,993&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:33,618&nbsp;-&nbsp;【Main】删除节点成功，path：/nileader/ch&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:33,756&nbsp;-&nbsp;【Main】删除节点成功，path：/nileader&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:33,817&nbsp;-&nbsp;【Watcher-6】收到Watcher通知&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:33,817&nbsp;-&nbsp;【Watcher-6】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:33,817&nbsp;-&nbsp;【Watcher-6】事件类型:&nbsp;&nbsp;NodeDeleted&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:33,817&nbsp;-&nbsp;【Watcher-6】节点&nbsp;/nileader/ch&nbsp;被删除&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:33,817&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,017&nbsp;-&nbsp;【Watcher-7】收到Watcher通知&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:34,017&nbsp;-&nbsp;【Watcher-7】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,017&nbsp;-&nbsp;【Watcher-7】事件类型:&nbsp;&nbsp;NodeChildrenChanged&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:34,017&nbsp;-&nbsp;【Watcher-7】子节点变更&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,109&nbsp;-&nbsp;【Watcher-7】子节点列表：<span class="keyword">null</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:34,109&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,309&nbsp;-&nbsp;【Watcher-8】收到Watcher通知&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:34,309&nbsp;-&nbsp;【Watcher-8】连接状态:&nbsp;&nbsp;SyncConnected&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,309&nbsp;-&nbsp;【Watcher-8】事件类型:&nbsp;&nbsp;NodeDeleted&nbsp;</span></li>
  <li class="alt"><span>2012-08-05&nbsp;06:35:34,309&nbsp;-&nbsp;【Watcher-8】节点&nbsp;/nileader&nbsp;被删除&nbsp;</span></li>
  <li><span>2012-08-05&nbsp;06:35:34,309&nbsp;-&nbsp;--------------------------------------------&nbsp;</span></li>
 </ol></pre> 
<div>
 &nbsp;
</div> 
<p>&nbsp;</p> 
<p>&nbsp;</p> 
<p>&nbsp;</p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/954670">http://nileader.blog.51cto.com/1381108/954670</a></p>
