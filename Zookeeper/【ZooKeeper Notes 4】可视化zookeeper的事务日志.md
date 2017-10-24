<p><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">&nbsp; &nbsp; &nbsp; 转载请注明：<a href="http://weibo.com/nileader" target="_blank">@ni掌柜</a> nileader@gmail.com&nbsp;</span></p> 
<p><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">&nbsp; &nbsp; &nbsp; 前面提到，在</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">zookeeper server</span><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">的配置文件</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">zoo.cfg</span><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">中可以通过</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">dataLogDir</span><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">来配置</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">zookeeper</span><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">的事务日志的输出目录</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">,</span><span style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">这个事务日志类似于下面这样的文件</span><span lang="EN-US" style="font-family: 'Comic Sans MS'; color: rgb(44, 44, 44); background-color: white; ">:</span></p> 
<p><span style="font-size: 14px; "><a href="http://img1.51cto.com/attachment/201209/191535410.jpg" target="_blank"><span style="font-family: 'Comic Sans MS'; "><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201209/191535410.jpg" border="0" alt="zookeeper 事务日志"></span></a><br> </span></p> 
<p class="MsoNormal"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">这个文件是一个二进制文件<span lang="EN-US">, </span>一般不能够直接识别<span lang="EN-US">, </span>那么是否有方法可以把这些事务日志转换成正常日志文件呢<span lang="EN-US">, </span>答案是肯定的<span lang="EN-US">~</span></span><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span><br> </span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; "><span lang="EN-US">&nbsp; &nbsp; &nbsp; Zookeeper</span>自带一个工具类：<span lang="EN-US">org.apache.zookeeper.server.LogFormatter, </span>使用这个类可以对<span lang="EN-US">zookeeper</span>的事务日志进行格式化查看<span lang="EN-US">, </span>方法如下<span lang="EN-US">:&nbsp;</span></span></span><span lang="EN-US">
  <o:p></o:p></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; "><span lang="EN-US">java LogFormatter D:\zookeeper-3.4.3\zk_data\version-2\log.48</span></span></span></p> 
<p class="MsoNormal"><span lang="EN-US">
  <o:p></o:p></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp;大家可以自行下载本文的<strong>附件</strong>进行尝试<span lang="EN-US">, </span>通过这种方法<span lang="EN-US">,</span>我们就可以看到类似于下面这样清晰的事务日志了<span lang="EN-US">~</span></span><br> </span></p> 
<pre>
 <ol class="dp-sql">
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">ZooKeeper&nbsp;Transactional&nbsp;Log&nbsp;File&nbsp;<span class="keyword">with</span>&nbsp;dbid&nbsp;0&nbsp;txnlog&nbsp;format&nbsp;version&nbsp;2&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;11:58:04&nbsp;AM&nbsp;CST&nbsp;session&nbsp;0x13893084e900000&nbsp;cxid&nbsp;0x0&nbsp;zxid&nbsp;0x48&nbsp;createSession&nbsp;30000&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:00:57&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900001&nbsp;cxid&nbsp;0x0&nbsp;zxid&nbsp;0x49&nbsp;createSession&nbsp;30000&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:01:24&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900000&nbsp;cxid&nbsp;0x0&nbsp;zxid&nbsp;0x4a&nbsp;closeSession&nbsp;<span class="op">null</span>&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:01:55&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900001&nbsp;cxid&nbsp;0xc&nbsp;zxid&nbsp;0x4b&nbsp;<span class="keyword">create</span>&nbsp;<span class="string">'/test-abc,#61,v{s{31,s{'</span>world,'anyone}}},F,3&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:02:21&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900001&nbsp;cxid&nbsp;0x12&nbsp;zxid&nbsp;0x4c&nbsp;setData&nbsp;'/test-abc,#61,1&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:03:15&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900001&nbsp;cxid&nbsp;0x14&nbsp;zxid&nbsp;0x4d&nbsp;<span class="keyword">create</span>&nbsp;<span class="string">'/test-abc/abc,#61,v{s{31,s{'</span>world,'anyone}}},F,1&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">7/17/12&nbsp;12:03:17&nbsp;PM&nbsp;CST&nbsp;session&nbsp;0x13893084e900001&nbsp;cxid&nbsp;0x15&nbsp;zxid&nbsp;0x4e&nbsp;setData&nbsp;'/test-abc,#61,2&nbsp;</span></span></li>
  <li><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp;</span></span></li>
  <li class="alt"><span style="font-size: 14px; ">&nbsp;</span></li>
 </ol><span style="font-family: 'Comic Sans MS'; "><span style="font-size: 12px; ">
   <ol class="dp-sql">
    <li class="alt"><span style="font-size: 14px; ">EOF&nbsp;reached&nbsp;<span class="keyword">after</span>&nbsp;7&nbsp;txns.&nbsp;</span></li>
   </ol></span></span><span style="font-size: 14px; ">
  <ol class="dp-sql">
   <li class="alt">&nbsp;</li>
  </ol></span><span style="font-size: 12px; ">
  <ol class="dp-sql">
   <li class="alt">&nbsp;</li>
  </ol></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; "><br type="_moz"></span><br></span></pre> 
<p><span style="font-size: 14px; ">&nbsp;</span></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/926753">http://nileader.blog.51cto.com/1381108/926753</a></p>
