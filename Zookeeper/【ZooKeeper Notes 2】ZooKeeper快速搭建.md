<p><span style="font-family:'Comic Sans MS';"><span style="color:rgb(44,44,44);font-size:14px;line-height:28px;background-color:rgb(255,255,255);">&nbsp;转载请用注明：</span>@</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family:'Comic Sans MS';">ni掌柜</span></a><span style="font-family:'Comic Sans MS';"> </span><span style="color:rgb(44,44,44);font-size:14px;line-height:28px;background-color:rgb(255,255,255);">&nbsp;nileader@gmail.com</span><span style="font-family:'幼圆';"> </span><span style="font-family:'Comic Sans MS';"> </span></p>
<p>&nbsp;<a href="http://cloud.github.com/downloads/nileader/ZooKeeper-Notes/%E3%80%90ZooKeeper%20Notes%202%E3%80%91ZooKeeper%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BA.pdf" target="_blank"><span style="font-family:'Comic Sans MS';">下载PDF版本</span></a></p>
<p><span style="font-family:'Comic Sans MS';"><span style="font-size:10.5pt;color:#FF0000;">&nbsp; &nbsp; &nbsp; &nbsp;本文是<span lang="en-us" xml:lang="en-us">ZooKeeper</span>的快速搭建，旨在帮助大家以最快的速度完成一个<span lang="en-us" xml:lang="en-us">ZK</span>集群的搭建，以便开展其它工作。本方不包含多余说明及任何调优方面的高级配置。如果要进行更深一层次的配置，请移步《<span lang="en-us" xml:lang="en-us">ZooKeeper</span>管理员指南&amp;mdash;&amp;mdash;部署与运维》。</span><br></span></p>
<p>&nbsp;<span style="font-family:'Comic Sans MS';"> </span><strong><span style="font-size:22px;">单机模式（<span lang="en-us" xml:lang="en-us">7</span>步）</span></strong></p>
<p><strong style="font-family:'Comic Sans MS';"><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step1</span><span style="font-size:16pt;">：</span></strong><span style="font-family:'Comic Sans MS';">配置</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">JAVA</span><span style="font-family:'Comic Sans MS';">环境。检验方法：执行</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">java &amp;ndash;version</span><span style="font-family:'Comic Sans MS';">和</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">javac &amp;ndash;version</span><span style="font-family:'Comic Sans MS';">命令。</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step2</span><span style="font-size:16pt;">：</span></strong>下载并解压<span lang="en-us" xml:lang="en-us">zookeeper</span>。</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">链接：</span><span lang="en-us" xml:lang="en-us"><a href="http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.3/" target="_blank"><span style="font-family:'Comic Sans MS';">http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.3/</span></a></span><span style="font-family:'Comic Sans MS';">，（更多版本：</span><span lang="en-us" xml:lang="en-us"><a href="http://dwz.cn/37HGI" target="_blank"><span style="font-family:'Comic Sans MS';">http://dwz.cn/37HGI</span></a></span></p>
<p><span style="font-family:'Comic Sans MS';"> </span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">）最终生成目录类似结构：<span lang="en-us" xml:lang="en-us">/home/admin/taokeeper/zookeeper-3.4.3/bin</span></span></p>
<p><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step3</span><span style="font-size:16pt;">：</span></strong>重命名 <span lang="en-us" xml:lang="en-us">zoo_sample.cfg</span>文件</span></p>
<pre>&nbsp;mv&nbsp;/home/admin/taokeeper/zookeeper-3.4.3/conf/zoo_sample.cfg&nbsp;&nbsp;zoo.cfg</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">&nbsp;<strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step4</span><span style="font-size:16pt;">：</span></strong><span lang="en-us" xml:lang="en-us">vi zoo.cfg</span>，修改<br></span></p>
<pre>dataDir=/home/admin/taokeeper/zookeeper-3.4.3/data</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step5</span><span style="font-size:16pt;">：</span></strong>创建数据目录：<span lang="en-us" xml:lang="en-us">mkdir /home/admin/taokeeper/zookeeper-3.4.3/data</span></span></p>
<pre></pre>
<ol class="dp-xml list-paddingleft-2">
 <li><p><span style="font-family:'Comic Sans MS';">mkdir&nbsp;&nbsp;/home/admin/taokeeper/zookeeper-3.4.3/data&nbsp;</span></p></li>
</ol>
<br>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step6</span><span style="font-size:16pt;">：</span></strong>启动<span lang="en-us" xml:lang="en-us">zookeeper</span>：执行</span></p>
<pre>/home/admin/taokeeper/zookeeper-3.4.3/bin/zkServer.sh&nbsp;start</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step7</span><span style="font-size:16pt;">：</span></strong>检测是否成功启动：执行</span></p>
<pre>/home/admin/taokeeper/zookeeper-3.4.3/bin/zkCli.sh&nbsp;或&nbsp;echo&nbsp;stat|nc&nbsp;localhost&nbsp;2181</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">&nbsp;</span></p>
<p class="MsoNormal" style="text-align:left;"><strong><span style="font-size:22px;">集群模式（<span lang="en-us" xml:lang="en-us">8</span>步）</span></strong></p>
<p><strong style="font-family:'Comic Sans MS';"><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step1</span><span style="font-size:16pt;">：</span></strong><span style="font-family:'Comic Sans MS';">配置</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">JAVA</span><span style="font-family:'Comic Sans MS';">环境。检验方法：执行</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">java &amp;ndash;version</span><span style="font-family:'Comic Sans MS';">和</span><span lang="en-us" style="font-family:'Comic Sans MS';" xml:lang="en-us">javac &amp;ndash;version</span><span style="font-family:'Comic Sans MS';">命令。</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step2</span><span style="font-size:16pt;">：</span></strong>下载并解压<span lang="en-us" xml:lang="en-us">zookeeper</span>。</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">链接：</span><span lang="en-us" xml:lang="en-us"><a href="http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.3/" target="_blank"><span style="font-family:'Comic Sans MS';">http://mirror.bjtu.edu.cn/apache/zookeeper/zookeeper-3.4.3/</span></a></span><span style="font-family:'Comic Sans MS';">，（更多版本：</span><span lang="en-us" xml:lang="en-us"><a href="http://dwz.cn/37HGI" target="_blank"><span style="font-family:'Comic Sans MS';">http://dwz.cn/37HGI</span></a></span><span style="font-family:'Comic Sans MS';">）最终生成目录类似结构：<span lang="en-us" xml:lang="en-us">/home/admin/taokeeper/zookeeper-3.4.3/bin</span></span></p>
<p><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step3</span><span style="font-size:16pt;">：</span></strong>重命名&nbsp;<span lang="en-us" xml:lang="en-us">zoo_sample.cfg</span>文件</span></p>
<pre style="width:587.066650390625px;">&nbsp;mv&nbsp;/home/admin/taokeeper/zookeeper-3.4.3/conf/zoo_sample.cfg&nbsp;&nbsp;zoo.cfg</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">&nbsp;<strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step4</span><span style="font-size:16pt;">：</span></strong><span lang="en-us" xml:lang="en-us">vi zoo.cfg</span>，修改<br></span></p>
<pre style="width:587.066650390625px;">dataDir=/home/admin/taokeeper/zookeeper-3.4.3/data&nbsp;

server.1=1.2.3.4:2888:3888&nbsp;
server.2=1.2.3.5:2888:3888&nbsp;
server.3=1.2.3.6:2888:3888</pre>
<p class="MsoNormal" style="text-align:left;"><span style="color:rgb(255,0,0);">这里要注意下server.1这个后缀，表示的是1.2.3.4这个机器，在机器中的server id是1</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step5</span><span style="font-size:16pt;">：</span></strong>创建数据目录：<span lang="en-us" xml:lang="en-us">mkdir /home/admin/taokeeper/zookeeper-3.4.3/data</span></span></p>
<pre style="width:587.066650390625px;"></pre>
<ol class="dp-xml list-paddingleft-2">
 <li><p><span style="font-family:'Comic Sans MS';">mkdir&nbsp;&nbsp;/home/admin/taokeeper/zookeeper-3.4.3/data&nbsp;</span></p></li>
</ol>
<br>
<p class="MsoNormal" style="text-align:left;"><strong style="font-family:'Comic Sans MS';"><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step6</span><span style="font-size:16pt;">：</span></strong><span style="font-family:'Comic Sans MS';">在标识Server ID.</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><span class="Apple-tab-span" style="white-space:pre;"></span>在/home/admin/taokeeper/zookeeper-3.4.3/data目录中创建文件 myid 文件，每个文件中分别写入当前机器的server id，例如1.2.3.4这个机器，在/home/admin/taokeeper/zookeeper-3.4.3/data目录的myid文件中写入数字1.</span></p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step7</span><span style="font-size:16pt;">：</span></strong>启动<span lang="en-us" xml:lang="en-us">zookeeper</span>：执行</span></p>
<pre style="width:587.066650390625px;">/home/admin/taokeeper/zookeeper-3.4.3/bin/zkServer.sh&nbsp;start</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';"><strong><span lang="en-us" style="font-size:16pt;" xml:lang="en-us">Step8</span><span style="font-size:16pt;">：</span></strong>检测是否成功启动：执行</span></p>
<pre style="width:587.066650390625px;">/home/admin/taokeeper/zookeeper-3.4.3/bin/zkCli.sh&nbsp;或&nbsp;echo&nbsp;stat|nc&nbsp;localhost&nbsp;2181</pre>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'Comic Sans MS';">&nbsp;</span></p>
<p class="MsoNormal" style="text-align:left;text-indent:63pt;">&nbsp;</p>
<p class="MsoNormal" style="text-align:left;"><span style="font-family:'微软雅黑', 'sans-serif';"><span lang="en-us" xml:lang="en-us"></span></span></p>
<p></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/795230">http://nileader.blog.51cto.com/1381108/795230</a></p>
