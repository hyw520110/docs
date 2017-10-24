<p><a href="http://cloud.github.com/downloads/nileader/ZooKeeper-Notes/%E3%80%90ZooKeeper%20Notes%203%E3%80%91ZooKeeper%20Java%20API%20%E4%BD%BF%E7%94%A8%E6%A0%B7%E4%BE%8B.pdf" target="_blank"><span style="font-family: 'Comic Sans MS'; ">查看PDF版本</span></a></p> 
<p><span style="font-family: 'Comic Sans MS'; ">转载请注明：</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family: 'Comic Sans MS'; ">@ni掌柜</span></a><span style="font-family: 'Comic Sans MS'; "> nileader@gmail.com</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">ZooKeeper是一个分布式的，开放源码的分布式应用程序协调服务框架，包含一组简单的原语集合。通过这些原语言的组合使用，能够帮助我们解决更高层次的分布式问题，关于ZooKeeper的典型使用场景，请查看这个文章《</span><a href="http://rdc.taobao.com/team/jm/archives/1232" target="_blank"><span style="font-family: 'Comic Sans MS'; ">ZooKeeper典型使用场景一览</span></a><span style="font-family: 'Comic Sans MS'; ">》</span></p> 
<p><span style="font-family: 'Comic Sans MS'; ">本文主要针对ZooKeeper提供的Java API，通过实际代码讲述如何使用API。</span></p> 
<pre>
 <ol class="dp-j">
  <li class="alt"><span><span class="keyword">package</span><span>&nbsp;com.taobao.taokeeper.research.sample;&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span><span class="keyword">import</span><span>&nbsp;java.io.IOException;&nbsp;</span></span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;java.util.concurrent.CountDownLatch;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.CreateMode;&nbsp;</span></span></li>
  <li class="alt"><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.KeeperException;&nbsp;</span></span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.WatchedEvent;&nbsp;</span></span></li>
  <li class="alt"><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.Watcher;&nbsp;</span></span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.Watcher.Event.KeeperState;&nbsp;</span></span></li>
  <li class="alt"><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.ZooDefs.Ids;&nbsp;</span></span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;org.apache.zookeeper.ZooKeeper;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span><span class="keyword">import</span><span>&nbsp;common.toolkit.java.util.ObjectUtil;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span><span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;*&nbsp;ZooKeeper&nbsp;Java&nbsp;Api&nbsp;使用样例&lt;br&gt;</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;*&nbsp;ZK&nbsp;Api&nbsp;Version:&nbsp;3.4.3</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;*&nbsp;</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;*&nbsp;@author&nbsp;nileader/nileader@gmail.com</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li><span><span class="keyword">public</span><span>&nbsp;</span><span class="keyword">class</span><span>&nbsp;JavaApiSample&nbsp;</span><span class="keyword">implements</span><span>&nbsp;Watcher&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">private</span><span>&nbsp;</span><span class="keyword">static</span><span>&nbsp;</span><span class="keyword">final</span><span>&nbsp;</span><span class="keyword">int</span><span>&nbsp;SESSION_TIMEOUT&nbsp;=&nbsp;</span><span class="number">10000</span><span>;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">private</span><span>&nbsp;</span><span class="keyword">static</span><span>&nbsp;</span><span class="keyword">final</span><span>&nbsp;String&nbsp;CONNECTION_STRING&nbsp;=&nbsp;</span><span class="string">"test.zookeeper.connection_string:2181"</span><span>;&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">private</span><span>&nbsp;</span><span class="keyword">static</span><span>&nbsp;</span><span class="keyword">final</span><span>&nbsp;String&nbsp;ZK_PATH&nbsp;=&nbsp;</span><span class="string">"/nileader"</span><span>;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">private</span><span>&nbsp;ZooKeeper&nbsp;zk&nbsp;=&nbsp;</span><span class="keyword">null</span><span>;&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">private</span><span>&nbsp;CountDownLatch&nbsp;connectedSemaphore&nbsp;=&nbsp;</span><span class="keyword">new</span><span>&nbsp;CountDownLatch(&nbsp;</span><span class="number">1</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;创建ZK连接</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;connectString&nbsp;&nbsp;ZK服务器地址列表</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;sessionTimeout&nbsp;&nbsp;&nbsp;Session超时时间</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;createConnection(&nbsp;String&nbsp;connectString,&nbsp;</span><span class="keyword">int</span><span>&nbsp;sessionTimeout&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">this</span><span>.releaseConnection();&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zk&nbsp;=&nbsp;<span class="keyword">new</span><span>&nbsp;ZooKeeper(&nbsp;connectString,&nbsp;sessionTimeout,&nbsp;</span><span class="keyword">this</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;connectedSemaphore.await();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"连接创建失败，发生&nbsp;InterruptedException"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;IOException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"连接创建失败，发生&nbsp;IOException"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;关闭ZK连接</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;releaseConnection()&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;(&nbsp;!ObjectUtil.isBlank(&nbsp;</span><span class="keyword">this</span><span>.zk&nbsp;)&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">this</span><span>.zk.close();&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">//&nbsp;ignore</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;创建节点</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;path&nbsp;节点path</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;data&nbsp;初始数据内容</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@return</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">boolean</span><span>&nbsp;createPath(&nbsp;String&nbsp;path,&nbsp;String&nbsp;data&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"节点创建成功,&nbsp;Path:&nbsp;"</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;<span class="keyword">this</span><span>.zk.create(&nbsp;path,&nbsp;</span><span class="comment">//</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data.getBytes(),&nbsp;<span class="comment">//</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ids.OPEN_ACL_UNSAFE,&nbsp;<span class="comment">//</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CreateMode.EPHEMERAL&nbsp;)&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;<span class="string">",&nbsp;content:&nbsp;"</span><span>&nbsp;+&nbsp;data&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;KeeperException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"节点创建失败，发生KeeperException"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"节点创建失败，发生&nbsp;InterruptedException"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;</span><span class="keyword">true</span><span>;&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;读取指定节点数据内容</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;path&nbsp;节点path</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@return</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;String&nbsp;readData(&nbsp;String&nbsp;path&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"获取数据成功，path："</span><span>&nbsp;+&nbsp;path&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;</span><span class="keyword">new</span><span>&nbsp;String(&nbsp;</span><span class="keyword">this</span><span>.zk.getData(&nbsp;path,&nbsp;</span><span class="keyword">false</span><span>,&nbsp;</span><span class="keyword">null</span><span>&nbsp;)&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;KeeperException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"读取数据失败，发生KeeperException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;</span><span class="string">""</span><span>;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"读取数据失败，发生&nbsp;InterruptedException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;</span><span class="string">""</span><span>;&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;更新指定节点数据内容</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;path&nbsp;节点path</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;data&nbsp;&nbsp;数据内容</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@return</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">boolean</span><span>&nbsp;writeData(&nbsp;String&nbsp;path,&nbsp;String&nbsp;data&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"更新数据成功，path："</span><span>&nbsp;+&nbsp;path&nbsp;+&nbsp;</span><span class="string">",&nbsp;stat:&nbsp;"</span><span>&nbsp;+&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">this</span><span>.zk.setData(&nbsp;path,&nbsp;data.getBytes(),&nbsp;-</span><span class="number">1</span><span>&nbsp;)&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;KeeperException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"更新数据失败，发生KeeperException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"更新数据失败，发生&nbsp;InterruptedException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span><span>&nbsp;</span><span class="keyword">false</span><span>;&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;删除指定节点</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;@param&nbsp;path&nbsp;节点path</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;deleteNode(&nbsp;String&nbsp;path&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">try</span><span>&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">this</span><span>.zk.delete(&nbsp;path,&nbsp;-</span><span class="number">1</span><span>&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"删除节点成功，path："</span><span>&nbsp;+&nbsp;path&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;KeeperException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"删除节点失败，发生KeeperException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;<span class="keyword">catch</span><span>&nbsp;(&nbsp;InterruptedException&nbsp;e&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"删除节点失败，发生&nbsp;InterruptedException，path:&nbsp;"</span><span>&nbsp;+&nbsp;path&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.printStackTrace();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">static</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;main(&nbsp;String[]&nbsp;args&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;JavaApiSample&nbsp;sample&nbsp;=&nbsp;<span class="keyword">new</span><span>&nbsp;JavaApiSample();&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sample.createConnection(&nbsp;CONNECTION_STRING,&nbsp;SESSION_TIMEOUT&nbsp;);&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;(&nbsp;sample.createPath(&nbsp;ZK_PATH,&nbsp;</span><span class="string">"我是节点初始内容"</span><span>&nbsp;)&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println();&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"数据内容:&nbsp;"</span><span>&nbsp;+&nbsp;sample.readData(&nbsp;ZK_PATH&nbsp;)&nbsp;+&nbsp;</span><span class="string">"\n"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sample.writeData(&nbsp;ZK_PATH,&nbsp;<span class="string">"更新后的数据"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"数据内容:&nbsp;"</span><span>&nbsp;+&nbsp;sample.readData(&nbsp;ZK_PATH&nbsp;)&nbsp;+&nbsp;</span><span class="string">"\n"</span><span>&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sample.deleteNode(&nbsp;ZK_PATH&nbsp;);&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sample.releaseConnection();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">/**</span>&nbsp;</span></li>
  <li class="alt"><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*&nbsp;收到来自Server的Watcher通知后的处理。</span>&nbsp;</span></li>
  <li><span><span class="comment">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="annotation">@Override</span><span>&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">public</span><span>&nbsp;</span><span class="keyword">void</span><span>&nbsp;process(&nbsp;WatchedEvent&nbsp;event&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(&nbsp;<span class="string">"收到事件通知："</span><span>&nbsp;+&nbsp;event.getState()&nbsp;+</span><span class="string">"\n"</span><span>&nbsp;&nbsp;);&nbsp;</span></span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">if</span><span>&nbsp;(&nbsp;KeeperState.SyncConnected&nbsp;==&nbsp;event.getState()&nbsp;)&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;connectedSemaphore.countDown();&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>}&nbsp;</span></li>
 </ol></pre> 
<p><strong><span style="color: rgb(0, 0, 255); "><span style="font-family: 'Comic Sans MS'; ">输出结果：</span></span></strong></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>收到事件通知：SyncConnected&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>节点创建成功,&nbsp;Path:&nbsp;/nileader,&nbsp;content:&nbsp;我是节点初始内容&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>获取数据成功，path：/nileader&nbsp;</span></li>
  <li><span>数据内容:&nbsp;我是节点初始内容&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>更新数据成功，path：/nileader,&nbsp;stat:&nbsp;42950186407,42950186408,1350820182392,1350820182406,1,0,0,232029990722229433,18,0,42950186407&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>获取数据成功，path：/nileader&nbsp;</span></li>
  <li class="alt"><span>数据内容:&nbsp;更新后的数据&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>删除节点成功，path：/nileader&nbsp;</span></li>
 </ol></pre> 
<p>&nbsp;</p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/795265">http://nileader.blog.51cto.com/1381108/795265</a></p>
