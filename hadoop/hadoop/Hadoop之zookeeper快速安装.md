<p><span style="font-family:'comic sans ms';"><span style="font-family:'宋体';">查看jdk环境的版本</span></span></p>
<p><span style="font-family:'宋体';">执行<span lang="en-us" xml:lang="en-us">java&nbsp;&#xfffd;version</span>和<span lang="en-us" xml:lang="en-us">javac&nbsp;&#xfffd;version</span>命令</span></p>
<pre>[root@node10&nbsp;~]#&nbsp;java&nbsp;-version&nbsp;&nbsp;java&nbsp;version&nbsp;"1.6.0_37"&nbsp;&nbsp;Java(TM)&nbsp;SE&nbsp;Runtime&nbsp;Environment&nbsp;(build&nbsp;1.6.0_37-b06)&nbsp;&nbsp;Java&nbsp;HotSpot(TM)&nbsp;64-Bit&nbsp;Server&nbsp;VM&nbsp;(build&nbsp;20.12-b01,&nbsp;mixed&nbsp;mode)</pre>
<p><span style="font-family:'宋体';">下载并解压<span lang="en-us" xml:lang="en-us">zookeeper&nbsp;</span></span></p>
<pre>cd&nbsp;/opt&nbsp;&nbsp;tar&nbsp;xzvf&nbsp;zookeeper-3.3.5.tar.gz</pre>
<p><span style="font-family:'宋体';"><span lang="en-us" xml:lang="en-us">重命名zookeeper的配置文件</span></span></p>
<pre>mv&nbsp;/opt/zookeeper-3.3.5/conf/zoo_sample.cfg&nbsp;&nbsp;zoo.cfg</pre>
<p><span style="font-family:'宋体';"><span lang="en-us" xml:lang="en-us">编辑修改zoo.cfg</span></span></p>
<pre>dataDir=/opt/zookeeper-3.3.5/data</pre>
<p><span style="font-family:'宋体';">创建数据目录：<span lang="en-us" xml:lang="en-us">mkdir&nbsp;/opt/zookeeper-3.3.5/data</span></span></p>
<pre>mkdir&nbsp;&nbsp;/opt/zookeeper-3.3.5/data</pre>
<p>启动zookeeper</p>
<pre></pre>
<ol class="dp-xml list-paddingleft-2">
 <li><p>/opt/zookeeper-3.3.5/bin/zkServer.sh&nbsp;start&nbsp;</p></li>
 <li><p>JMX&nbsp;enabled&nbsp;by&nbsp;default<br>Using&nbsp;config:&nbsp;/opt/zookeeper-3.3.5/bin/../conf/zoo.cfg<br>Starting&nbsp;zookeeper&nbsp;...&nbsp;STARTED&nbsp;</p></li>
</ol>
<p>检查zookeeper进程</p>
<pre>ps&nbsp;-ef&nbsp;|&nbsp;grep&nbsp;zookeeper&nbsp;|&nbsp;grep&nbsp;-v&nbsp;grep&nbsp;&nbsp;oot&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;29530&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1&nbsp;&nbsp;0&nbsp;15:39&nbsp;pts/0&nbsp;&nbsp;&nbsp;&nbsp;00:00:00&nbsp;/usr/java/jdk1.6.0_37/bin/java&nbsp;-Dzookeeper.log.dir=.&nbsp;-Dzookeeper.root.logger=INFO,CONSOLE&nbsp;-cp&nbsp;/opt/zookeeper-3.3.5/bin/../build/classes:/opt/zookeeper-3.3.5/bin/../build/lib/*.jar:/opt/zookeeper-3.3.5/bin/../zookeeper-3.3.5.jar:/opt/zookeeper-3.3.5/bin/../lib/log4j-1.2.15.jar:/opt/zookeeper-3.3.5/bin/../lib/jline-0.9.94.jar:/opt/zookeeper-3.3.5/bin/../src/java/lib/*.jar:/opt/zookeeper-3.3.5/bin/../conf:.:/usr/java/jdk1.6.0_37/lib/dt.jar:/usr/java/jdk1.6.0_37/lib/tools.jar&nbsp;-Dcom.sun.management.jmxremote&nbsp;-Dcom.sun.management.jmxremote.local.only=false&nbsp;org.apache.zookeeper.server.quorum.QuorumPeerMain&nbsp;/opt/zookeeper-3.3.5/bin/../conf/zoo.cfg</pre>
<p>还可以用以下方法检测是否启动成功</p>
<pre>/opt/zookeeper-3.4.3/bin/zkCli.sh&nbsp;或&nbsp;echo&nbsp;stat|nc&nbsp;localhost&nbsp;2181</pre>
<p>&nbsp;停止zookeeper</p>
<pre>kill&nbsp;-9&nbsp;&nbsp;29530</pre>
<p>本文出自 “<a href="http://laoxu.blog.51cto.com">老徐的私房菜</a>” 博客，谢绝转载！</p>
