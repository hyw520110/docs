<p><strong><span style="font-size:21px;"></span></strong></p>
<h3>Zookeeper总体结构</h3>
<p>Zookeeper服务自身组成一个集群(2n+1个服务允许n个失效)。Zookeeper服务有两个角色，一个是leader，负责写服务和数据同步，剩下的是follower，提供读服务，leader失效后会在follower中重新选举新的leader。</p>
<p>Zookeeper逻辑图如下，</p>
<p><img onload="if(this.width>650) this.width=650;" alt="1.jpg" src="http://blog.jpush.cn/wp-content/uploads/2012/10/1.jpg" width="603" height="188"></p>
<ol class="list-paddingleft-2">
 <li><p><span style="font-size:medium;">客户端可以连接到每个server，每个server的数据完全相同。</span></p></li>
 <li><p><span style="font-size:medium;">每个follower都和leader有连接，接受leader的数据更新操作。</span></p></li>
 <li><p><span style="font-size:medium;">Server记录事务日志和快照到持久存储。</span></p></li>
 <li><p><span style="font-size:medium;">大多数server可用，整体服务就可用。</span></p></li>
</ol>
<h3>Zookeeper数据模型</h3>
<p>Zookeeper表现为一个分层的文件系统目录树结构（不同于文件系统的是，节点可以有自己的数据，而文件系统中的目录节点只有子节点）。</p>
<p>数据模型结构图如下，</p>
<p><img onload="if(this.width>650) this.width=650;" alt="2.png" src="http://blog.jpush.cn/wp-content/uploads/2012/10/2.png" width="439" height="250"></p>
<p>圆形节点可以含有子节点，多边形节点不能含有子节点。一个节点对应一个应用，节点存储的数据就是应用需要的配置信息。</p>
<h3>Zookeeper&nbsp;特点</h3>
<ul class="list-paddingleft-2">
 <li><p>顺序一致性：按照客户端发送请求的顺序更新数据。</p></li>
 <li><p>原子性：更新要么成功，要么失败，不会出现部分更新。</p></li>
 <li><p>单一性&nbsp;：无论客户端连接哪个server，都会看到同一个视图。</p></li>
 <li><p>可靠性：一旦数据更新成功，将一直保持，直到新的更新。</p></li>
 <li><p>及时性：客户端会在一个确定的时间内得到最新的数据。</p></li>
</ul>
<p><strong><span style="font-size:21px;"></span></strong></p>
<p><strong><span style="font-size:21px;"></span></strong></p>
<p>&nbsp;</p>
<p>Zookeeper集群的安装，节点数2*n+1,</p>
<p>&nbsp;</p>
<ul class="list-paddingleft-2">
 <li><p>tickTime:&nbsp;zookeeper中使用的基本时间单位,&nbsp;毫秒值.</p></li>
 <li><p>dataDir:&nbsp;数据目录.&nbsp;可以是任意目录.</p></li>
 <li><p>dataLogDir:&nbsp;log目录,&nbsp;同样可以是任意目录.&nbsp;如果没有设置该参数,&nbsp;将使用和dataDir相同的设置.</p></li>
 <li><p>clientPort:&nbsp;监听client连接的端口号.</p></li>
</ul>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">1&nbsp;<span style="font-family:'宋体';">、准备</span>Zookeeper<span style="font-family:'宋体';">环境</span></p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><span style="font-family:'宋体';">配置</span>java<span style="font-family:'宋体';">环境变量：</span></p>
<p style="margin:0px 0px 0px 28px;text-indent:4px;"><a></a><a></a><a>vi&nbsp;/etc/profile</a></p>
<p style="text-indent:28px;"><a></a><a>export&nbsp;JAVA_HOME=/usr/local/jdk1.7.0_45</a></p>
<p style="text-indent:28px;">export&nbsp;ZOOKEEPER_HOME=/usr/local/zookeeper</p>
<p style="margin:0px 0px 0px 28px;">export&nbsp;CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:<span style="color:#ff0000;">$ZOOKEEPER_HOME/lib</span></p>
<p style="margin:0px 0px 0px 28px;">export&nbsp;PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$HOME/bin:<span style="color:#ff0000;">$ZOOKEEPER_HOME/bin</span></p>
<p style="text-indent:28px;">rpm<span style="font-family:'宋体';color:#ff0000;">安装</span>jdk<span style="font-family:'宋体';color:#ff0000;">路径：</span>export&nbsp;JAVA_HOME=/usr/java/jdk1.7.0_45</p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">配置</span>hostname:</p>
<p style="text-indent:28px;">vi&nbsp;/etc/profile</p>
<p style="text-indent:28px;">172.16.23.195zookeeper1</p>
<p style="text-indent:28px;">172.16.23.196zookeeper2</p>
<p style="text-indent:28px;">reboot</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">2<span style="font-family:'宋体';">、配置</span>zookeeper</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><span style="font-family:calibri;">Wget&nbsp;</span><a href="http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.3.6/"><span style="font-family:calibri;color:#0000ff;">http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.3.6/</span></a></p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">tar&nbsp;&#xfffd;xvzf&nbsp;zookeeper-3.3.6.tar.gz</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">mv&nbsp;/zookeeper-3.3.6&nbsp;/usr/local/zookeeper</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">cd&nbsp;/usr/local/zookeeper/conf</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">mv&nbsp;mv&nbsp;zoo_sample.cfg&nbsp;zoo.cfg</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">vi&nbsp;zoo.cfg</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><span style="font-family:'宋体';">添加以下内容</span>zookeeper<span style="font-family:'宋体';">集群</span>:</p>
<p style="text-indent:28px;"><a>server.1=</a>&nbsp;zookeeper1:2888:3888</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><span style="font-family:calibri;">server.2=&nbsp;zookeeper1:2888:3888</span></p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><span style="font-family:'宋体';">标识Server&nbsp;ID:</span></p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;"><a>cd&nbsp;/tmp/zookeeper</a></p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">touch&nbsp;myid</p>
<p style="margin:0px 0px 0px 28px;text-indent:0px;">1</p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">其它</span>zookeeper<span style="font-family:'宋体';">服务器配置步骤相同，更改</span>myid<span style="font-family:'宋体';">值。</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">启动</span>zookeeper:</p>
<p style="text-indent:28px;">/usr/local/zookeeper/bin/zkServer.sh&nbsp;start</p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">查看启动状态：</span></p>
<p style="text-indent:28px;">/usr/local/zookeeper/bin/zkServer.sh&nbsp;status</p>
<p><a href="http://img1.51cto.com/attachment/201312/093140221.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="1.png" style="float:none;" alt="093140221.png" src="http://img1.51cto.com/attachment/201312/093140221.png"></a></p>
<p><a href="http://img1.51cto.com/attachment/201312/093142542.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="2.png" style="float:none;" alt="093142542.png" src="http://img1.51cto.com/attachment/201312/093142542.png"></a></p>
<p style="text-indent:28px;">&nbsp;</p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">启动客户端脚本：</span></p>
<p style="text-indent:28px;"><a></a><a></a><a></a><a></a><a></a><span style="font-family:calibri;">zkCli.sh&nbsp;-server&nbsp;&nbsp;zookeeper1:2181</span></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">显示根目录下、文件：</span><br><span style="font-family:calibri;">ls&nbsp;/&nbsp;</span></p>
<p style="margin:0px 0px 0px 28px;"><a href="http://img1.51cto.com/attachment/201312/093204739.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="3.png" alt="093204739.png" src="http://img1.51cto.com/attachment/201312/093204739.png"></a></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">创建文件，并设置初始内容：</span><br><a><span style="font-family:calibri;">create&nbsp;/</span></a><span style="font-family:calibri;">test&nbsp;1</span><span style="font-family:'宋体';">注释：</span>1<span style="font-family:'宋体';">为赋值。</span></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">获取文件内容：</span><br><span style="font-family:calibri;">get&nbsp;/test</span></p>
<p style="margin:0px 0px 0px 28px;"><a href="http://img1.51cto.com/attachment/201312/093230989.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="4.png" alt="093230989.png" src="http://img1.51cto.com/attachment/201312/093230989.png"></a></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">测试集群效果，登录另一台</span>zookeeper</p>
<p style="text-indent:28px;">zkCli.sh&nbsp;-server&nbsp;&nbsp;zookeeper2:2181</p>
<p style="margin:0px 0px 0px 28px;">ls&nbsp;/</p>
<p style="margin:0px 0px 0px 28px;"><a href="http://img1.51cto.com/attachment/201312/093250609.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="5.png" alt="093250609.png" src="http://img1.51cto.com/attachment/201312/093250609.png"></a></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">正确显示新建节点</span>test<span style="font-family:'宋体';">，集群正常。</span></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">修改文件内容：</span><br><span style="font-family:calibri;">set&nbsp;/test&nbsp;2</span></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">删除文件：</span><br><span style="font-family:calibri;">delete&nbsp;/test</span></p>
<p style="margin:0px 0px 0px 28px;"><span style="font-family:'宋体';">退出客户端：</span><br><span style="font-family:calibri;">quit&nbsp;</span></p>
<p>&nbsp;</p>
