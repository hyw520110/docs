<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">查看</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "><a href="http://cloud.github.com/downloads/nileader/ZooKeeper-Notes/%E3%80%8AZooKeeper%20Notes%2011%E3%80%8BZooKeeper%E5%AE%A2%E6%88%B7%E7%AB%AF%E5%9C%B0%E5%9D%80%E5%88%97%E8%A1%A8%E7%9A%84%E9%9A%8F%E6%9C%BA%E5%8E%9F%E7%90%86.pdf" target="_blank"><span style="font-size: 14px; ">PDF版本 </span></a></span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; "> 转载请用注明：</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "><a href="http://weibo.com/nileader" target="_blank"><span style="font-size: 14px; ">@ni掌柜</span></a></span></span><span style="font-family: 'Comic Sans MS'; ">nileader@gmail.com</span></p> 
<p>&nbsp;</p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">在之前一个文章《ZooKeeper Java API 使用样例》中提到，客户端使用ZooKeeper的时候，首先会建立与ZooKeeper的连接，方法是通过调用下面这个构造方法来实现的。</span></span><span style="font-size: 11px; "><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></span></p> 
<pre>
 <ol class="dp-j">
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "><span class="keyword">public</span>&nbsp;ZooKeeper(String&nbsp;connectString,&nbsp;<span class="comment">//</span>&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "><span class="keyword">int</span>&nbsp;sessionTimeout,&nbsp;<span class="comment">//</span>&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">Watcher&nbsp;watcher,<span class="comment">//</span>&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "><span class="keyword">boolean</span>&nbsp;canBeReadOnly&nbsp;)&nbsp;</span></span></li>
  <li><span class="keyword" style="background-color: rgb(247, 247, 247); ">throws</span><span style="background-color: rgb(247, 247, 247); ">&nbsp;IOException&nbsp;</span></li>
 </ol></pre> 
<p><span style="font-size: 11px; "><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;在这个构造方法中，首先要配置的是ZK服务器的地址列表，即connectString 这个参数，这个参数通常是这样一个格式的字符串：</span></span></p> 
<p><span style="font-size: 11px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span style="font-size: 12px; ">192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181&nbsp;</span></li>
 </ol></pre> 
<p><span style="font-size: 11px; "><span style="font-family: Arial; "> </span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></span></p> 
<p>&nbsp;<span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">很明显，我们可以看到，ZK客户端允许我们将ZK服务器的所有地址都配置在这里，于是一个问题就来了，ZK在连接服务器过程中，是如何选择服务器的呢？下面首先来看看ZK客户端是如何处理这个connectString的：</span></span></p> 
<p><span style="font-size: 11px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span style="font-size: 12px; ">new&nbsp;ZooKeeper(“192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181”,...)&nbsp;</span></li>
 </ol></pre> 
<p><span style="font-size: 11px; "><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></span></p> 
<p>&nbsp;<span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">实例一个ZooKeeper对象的时候，会要求传入一个地址列表的字符串，这个字符串就是ZK服务器的地址列表，用英文状态“，“隔开</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">。</span></span></p> 
<pre>
 <ol class="dp-j">
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">ConnectStringParser&nbsp;connectStringParser&nbsp;=&nbsp;&nbsp;</span></span></li>
 </ol><span style="font-size: 12px; "><span class="keyword"> new</span>&nbsp;ConnectStringParser(“<span class="number">192.168</span>.<span class="number">1.1</span>:<span class="number">2181</span>,<span class="number">192.168</span>.<span class="number">1.2</span>:<span class="number">2181</span>,<span class="number">192.168</span>.<span class="number">1.3</span>:<span class="number">2181</span>”);&nbsp;</span><br></pre> 
<p><span style="font-size: 11px; "><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> </span></span></span></p> 
<p>&nbsp;<span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">之后，这个地址列表会被封装到一个ConnectStringParser 对象中去，这个类主要就是解析传入地址列表字符串，将其它保存在一个ArrayList中。这个对象基本结构如下，这里我们主要关注serverAddresses这个成员</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">。</span></span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">public&nbsp;final&nbsp;class&nbsp;ConnectStringParser&nbsp;{&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;String&nbsp;chrootPath;&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;ArrayList<span class="tag">&lt;</span><span class="tag-name">InetSocketAddress</span><span class="tag">&gt;</span>&nbsp;<span class="attribute">serverAddresses</span>&nbsp;=&nbsp;<span class="attribute-value">new</span>&nbsp;ArrayList<span class="tag">&lt;</span><span class="tag-name">InetSocketAddress</span><span class="tag">&gt;</span>();&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">}&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">接下去，这个地址列表会被进一步封装成StaticHostProvider对象，并且在运行过程中，一直是这个对象来维护整个地址列表。关于这个对象，我们主要关注两点：地址列表的随机和地址获取这两个过程。首先来看地址列表的随机</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">：</span></span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">public&nbsp;StaticHostProvider(Collection<span class="tag">&lt;</span><span class="tag-name">InetSocketAddress</span><span class="tag">&gt;</span>&nbsp;serverAddresses)&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;throws&nbsp;UnknownHostException&nbsp;{&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;……&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; "> ……&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Collections.shuffle(this.serverAddresses);&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">这里可以看到，对于传入地址列表，ZK使用java.util.Collections.shuffle(List
   <!--?--> list) 来对地址列表随机打乱顺序，注意，这个随机过程是一次性的，也就是说，之后使用过程中一直是按照这样的顺序。再来看看地址列表被随机打乱后，又是怎么使用地址的</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">：</span></span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;public&nbsp;InetSocketAddress&nbsp;next(long&nbsp;spinDelay)&nbsp;{&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;++currentIndex;&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(<span class="attribute">currentIndex</span>&nbsp;==&nbsp;serverAddresses.size())&nbsp;{&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="attribute">currentIndex</span>&nbsp;=&nbsp;<span class="attribute-value">0</span>;&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">……&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">……&nbsp;</span></span></li>
  <li><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;serverAddresses.get(currentIndex);&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;</span></span></li>
 </ol></pre> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">看一下StaticHostProvider.next(long spinDelay) 方法就明白了。next方法的实现， 没错，就是“Round Robin”。简单的说，ZK客户端将所有Server保存在一个List中，然后随机打乱，并且形成一个环，具体使用的时候，从0号位开始一个一个使用</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">。</span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">另外两个注意点</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">：</span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">1.通过代码，可以发现ZK本质上是通过一个List来维护地址列表的，因此，Server地址能够重复配置，这样能够弥补客户端无法设置Server权重的缺陷，但是也会加大风险。 比如: 192.168.1.1:2181,192.168.1.1:2181,192.168.1.2:2181</span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">2.如果客户端在进行Server切换过程中耗时过长，那么将会收到SESSION_EXPIRED. 这也是上面第1点中的加大风险之处</span></span><span style="font-size: 12px; "><span style="font-family: 'Comic Sans MS'; ">。</span></span></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/932948">http://nileader.blog.51cto.com/1381108/932948</a></p>
