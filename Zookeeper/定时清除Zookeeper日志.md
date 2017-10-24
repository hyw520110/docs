<p><b><font size="6">定时清除Zookeeper日志</font></b></p> 
<p><span class="Apple-style-span" style="font-family: 宋体; font-size: 16px; ">命令格式：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>java&nbsp;-cp&nbsp;zookeeper.jar:log4j.jar:conf&nbsp;org.apache.zookeeper.server.PurgeTxnLog&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">dataDir</span><span class="tag">&gt;</span><span>&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">snapDir</span><span class="tag">&gt;</span><span>&nbsp;-n&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">count</span><span class="tag">&gt;</span><span>&nbsp;</span></span></li>
 </ol></pre> 
<p><span class="Apple-style-span" style="font-family: 宋体; font-size: 16px; ">举例：</span></p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>java&nbsp;-cp&nbsp;zookeeper.jar:log4j.jar:conf&nbsp;org.apache.zookeeper.server.PurgeTxnLog&nbsp;/log/xres/zookeeper/zk_trlog&nbsp;/www/xres/app/zk_data&nbsp;-n&nbsp;10&nbsp;</span></span></li>
 </ol></pre> 
<div>
 定时清除zookeeper日志和快照数据非常简单，只需简单3步。
</div> 
<p><b>Step1</b><b>：</b>在zookeeper/bin目录建立purgeTxnLog.sh文件，内容如下所示：</p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>#!/bin/sh&nbsp;</span></span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>#&nbsp;Only&nbsp;follow&nbsp;symlinks&nbsp;if&nbsp;readlink&nbsp;supports&nbsp;it&nbsp;</span></li>
  <li><span>if&nbsp;readlink&nbsp;-f&nbsp;"$0"&nbsp;<span class="tag">&gt;</span><span>&nbsp;/dev/null&nbsp;2</span><span class="tag">&gt;</span><span>&amp;1&nbsp;</span></span></li>
  <li class="alt"><span>then&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;<span class="attribute">ZOOBIN</span><span>=`readlink&nbsp;-f&nbsp;"$0"`&nbsp;</span></span></li>
  <li class="alt"><span>else&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;<span class="attribute">ZOOBIN</span><span>=</span><span class="attribute-value">"$0"</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>fi&nbsp;</span></li>
  <li><span><span class="attribute">ZOOBINDIR</span><span>=`dirname&nbsp;"$ZOOBIN"`&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>.&nbsp;"$ZOOBINDIR"/zkEnv.sh&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>#echo&nbsp;"Purge&nbsp;transaction&nbsp;log&nbsp;is&nbsp;starting..."&nbsp;</span></li>
  <li class="alt"><span><span class="attribute">PATH</span><span>=</span><span class="attribute-value">"/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/java/jdk1.6.0_21/bin:/usr/java/jdk1.6.0_21/jre/bin:/bin:/home/smdev/bin:$PATH"</span><span>&nbsp;</span></span></li>
  <li><span>export&nbsp;PATH&nbsp;</span></li>
  <li class="alt"><span>#echo&nbsp;"<span class="attribute">PATH</span><span>=$PATH"&nbsp;</span></span></li>
  <li><span>#echo&nbsp;"<span class="attribute">CLASSPATH</span><span>=$CLASSPATH"&nbsp;</span></span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>java&nbsp;-cp&nbsp;"$CLASSPATH"&nbsp;org.apache.zookeeper.server.PurgeTxnLog&nbsp;/log/xres/zookeeper/zk_trlog&nbsp;/www/xres/app/zk_data&nbsp;-n&nbsp;10&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>#echo&nbsp;"Purge&nbsp;transaction&nbsp;log&nbsp;is&nbsp;finished."&nbsp;</span></li>
 </ol></pre> 
<p>&nbsp;<b>Step2</b><b>：</b>创建cron任务。</p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>[smdev@M12-131&nbsp;bin]$&nbsp;crontab&nbsp;&#x2013;e&nbsp;</span></span></li>
 </ol></pre> 
<p>&nbsp;任务内容如下：&nbsp;</p> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>0&nbsp;*/1&nbsp;*&nbsp;*&nbsp;*&nbsp;sh&nbsp;/www/xres/app/zookeeper-3.3.3/bin/purgeTxnLog.sh&nbsp;</span><span class="tag">&gt;</span><span class="tag">&gt;</span><span>&nbsp;/log/xres/zookeeper/log/purgeTxnLog.log&nbsp;</span></span></li>
 </ol></pre> 
<div>
 <b>Step3</b>
 <b>：</b>启动服务
</div> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>[smdev@M12-131&nbsp;bin]$service&nbsp;crond&nbsp;start&nbsp;</span></span></li>
 </ol></pre> 
<div>
 到此为止，定时清除zookeeper日志和快照数据的全部工作已完成。
</div> 
<div>
 &nbsp;
</div>
<p>本文出自 “<a href="http://chenlx.blog.51cto.com">圆石技术之路</a>” 博客，转载请与作者联系！</p>
