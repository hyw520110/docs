<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(44,44,44);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><span style="padding:0px;margin:0px;font-family:'楷体', '楷体_GB2312', SimKai;">说明：转载我同事关于hadoop的文章，给大家分享下~</span></p>
<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(44,44,44);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><span style="padding:0px;margin:0px;font-family:'楷体', '楷体_GB2312', SimKai;">地址：</span><span style="padding:0px;margin:0px;color:rgb(104,39,2);font-family:'楷体', '楷体_GB2312', SimKai;text-decoration:underline;"><a href="http://gao-xianglong.iteye.com/blog/2190214" style="padding:0px;margin:0px;color:rgb(104,39,2);" target="_blank">http://gao-xianglong.iteye.com/blog/2189806</a></span></p>
<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(44,44,44);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><br></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);text-align:center;">《Zookeeper3.4.6集群安装》</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">在安装Zookeeper之前，首先需要确保的就是主机名称(可选)、hosts都已经更改，并且JDK成功安装。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);"><strong>1、安装Zookeeper</strong></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">使用命令“tar -zxvf”命令将gz压缩文件解压。笔者Zookeeper的安装目录为：“/home/hadoop”，解压后的Hadoop目录为/home/hadoop/zookeeper-3.4.6”，最好确保Master、Slave1、Slave2机器上的Zookeeper安装路径一致。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);"><strong>2、配置Zookeeper的环境变量</strong></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">成功安装Zookeeper后，接下来要做的事情就是配置Zookeeper的环境变量，并通过命令“source “/etc/profile”命令使修改后的配置生效，如下所示：</p>
<p>Shell代码&nbsp;&nbsp;<a title="收藏这段代码" style="color:rgb(16,138,198);text-decoration:underline;"><img onload="if(this.width>650) this.width=650;" class="star" src="http://gao-xianglong.iteye.com/images/icon_star.png" alt="收藏代码" style="border:0px;"></a></p>
<ol start="1" class="dp-default list-paddingleft-2" style="font-size:1em;line-height:1.4em;margin-bottom:1px;padding:2px 0px;border:1px solid rgb(209,215,220);color:rgb(43,145,175);">
 <li><p><span style="color:#000000;">#ZOOKEEPER&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">ZOOKEEPER=/home/hadoop/zookeeper-<span class="number" style="color:rgb(192,0,0);">3.4</span>.<span class="number" style="color:rgb(192,0,0);">6</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">PATH=$PATH:$ZOOKEEPER/bin&nbsp;&nbsp;</span></p></li>
</ol>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);"><strong>3、修改Zookeeper的配置文件</strong></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">首先将/home/hadoop/zookeeper-3.4.6/conf/zoo_sample.cfg文件复制一份，并更名为zoo.cfg，如下所示：</p>
<p>Shell代码&nbsp;&nbsp;<a title="收藏这段代码" style="color:rgb(16,138,198);text-decoration:underline;"><img onload="if(this.width>650) this.width=650;" class="star" src="http://gao-xianglong.iteye.com/images/icon_star.png" alt="收藏代码" style="border:0px;"></a></p>
<ol start="1" class="dp-default list-paddingleft-2" style="font-size:1em;line-height:1.4em;margin-bottom:1px;padding:2px 0px;border:1px solid rgb(209,215,220);color:rgb(43,145,175);">
 <li><p><span style="color:#000000;">#&nbsp;The&nbsp;number&nbsp;of&nbsp;milliseconds&nbsp;of&nbsp;each&nbsp;tick&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">tickTime=<span class="number" style="color:rgb(192,0,0);">2000</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;The&nbsp;number&nbsp;of&nbsp;ticks&nbsp;that&nbsp;the&nbsp;initial&nbsp;&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;synchronization&nbsp;phase&nbsp;can&nbsp;take&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">initLimit=<span class="number" style="color:rgb(192,0,0);">10</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;The&nbsp;number&nbsp;of&nbsp;ticks&nbsp;that&nbsp;can&nbsp;pass&nbsp;between&nbsp;&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;sending&nbsp;a&nbsp;request&nbsp;and&nbsp;getting&nbsp;an&nbsp;acknowledgement&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">syncLimit=<span class="number" style="color:rgb(192,0,0);">5</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;the&nbsp;directory&nbsp;where&nbsp;the&nbsp;snapshot&nbsp;is&nbsp;stored.&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;do&nbsp;not&nbsp;use&nbsp;/tmp&nbsp;for&nbsp;storage,&nbsp;/tmp&nbsp;here&nbsp;is&nbsp;just&nbsp;&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;example&nbsp;sakes.&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">dataDir=/home/hadoop/zk/data&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">dataLogDir=/home/hadoop/zk/log&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;the&nbsp;port&nbsp;at&nbsp;which&nbsp;the&nbsp;clients&nbsp;will&nbsp;connect&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">clientPort=<span class="number" style="color:rgb(192,0,0);">2181</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;the&nbsp;maximum&nbsp;number&nbsp;of&nbsp;client&nbsp;connections.&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;increase&nbsp;this&nbsp;if&nbsp;you&nbsp;need&nbsp;to&nbsp;handle&nbsp;more&nbsp;clients&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#maxClientCnxns=<span class="number" style="color:rgb(192,0,0);">60</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;Be&nbsp;sure&nbsp;to&nbsp;read&nbsp;the&nbsp;maintenance&nbsp;section&nbsp;of&nbsp;the&nbsp;&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;administrator&nbsp;guide&nbsp;before&nbsp;turning&nbsp;on&nbsp;autopurge.&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;The&nbsp;number&nbsp;of&nbsp;snapshots&nbsp;to&nbsp;retain&nbsp;in&nbsp;dataDir&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#autopurge.snapRetainCount=<span class="number" style="color:rgb(192,0,0);">3</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;Purge&nbsp;task&nbsp;interval&nbsp;in&nbsp;hours&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#&nbsp;Set&nbsp;to&nbsp;<span class="string" style="color:#0000FF;">"0"</span>&nbsp;to&nbsp;disable&nbsp;auto&nbsp;purge&nbsp;feature&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#autopurge.purgeInterval=<span class="number" style="color:rgb(192,0,0);">1</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">server.<span class="number" style="color:rgb(192,0,0);">1</span>=Master:<span class="number" style="color:rgb(192,0,0);">3333</span>:<span class="number" style="color:rgb(192,0,0);">4444</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">server.<span class="number" style="color:rgb(192,0,0);">2</span>=Slave1:<span class="number" style="color:rgb(192,0,0);">3333</span>:<span class="number" style="color:rgb(192,0,0);">4444</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">server.<span class="number" style="color:rgb(192,0,0);">3</span>=Slave2:<span class="number" style="color:rgb(192,0,0);">3333</span>:<span class="number" style="color:rgb(192,0,0);">4444</span>&nbsp;&nbsp;</span></p></li>
</ol>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">根据dataDir和dataLogDir变量创建相应的目录。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);"><strong>4、创建myid文件</strong></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">在dataDir目录下创建一个myid文件，然后分别在myid文件中按照zoo.cfg文件的server.A中A的数值，在不同机器上的该文件中填写相应的值。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);"><strong>5、启动Zookeeper</strong></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">执行命令“zkServer.sh start”将会启动Zookeeper。在此大家需要注意，和在Master启动Hadoop不同，不同节点上的Zookeeper需要单独启动。而执行命令“zkServer.sh stop”将会停止Zookeeper。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">开发人员可以使用命令“JPS”查看Zookeeper是否成功启动，以及执行命令“zkServer.sh status”查看Zookeeper集群状态，如下所示：</p>
<p>Shell代码&nbsp;&nbsp;<a title="收藏这段代码" style="color:rgb(16,138,198);text-decoration:underline;"><img onload="if(this.width>650) this.width=650;" class="star" src="http://gao-xianglong.iteye.com/images/icon_star.png" alt="收藏代码" style="border:0px;"></a></p>
<ol start="1" class="dp-default list-paddingleft-2" style="font-size:1em;line-height:1.4em;margin-bottom:1px;padding:2px 0px;border:1px solid rgb(209,215,220);color:rgb(43,145,175);">
 <li><p><span style="color:#000000;">#<span class="number" style="color:rgb(192,0,0);">192.168</span>.<span class="number" style="color:rgb(192,0,0);">1.224</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">JMX&nbsp;enabled&nbsp;by&nbsp;default&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Using&nbsp;config:&nbsp;/home/hadoop/zookeeper-<span class="number" style="color:rgb(192,0,0);">3.4</span>.<span class="number" style="color:rgb(192,0,0);">6</span>/bin/../conf/zoo.cfg&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Mode:&nbsp;follower&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#<span class="number" style="color:rgb(192,0,0);">192.168</span>.<span class="number" style="color:rgb(192,0,0);">1.225</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">JMX&nbsp;enabled&nbsp;by&nbsp;default&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Using&nbsp;config:&nbsp;/home/hadoop/zookeeper-<span class="number" style="color:rgb(192,0,0);">3.4</span>.<span class="number" style="color:rgb(192,0,0);">6</span>/bin/../conf/zoo.cfg&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Mode:&nbsp;leader&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">#<span class="number" style="color:rgb(192,0,0);">192.168</span>.<span class="number" style="color:rgb(192,0,0);">1.226</span>&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">JMX&nbsp;enabled&nbsp;by&nbsp;default&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Using&nbsp;config:&nbsp;/home/hadoop/zookeeper-<span class="number" style="color:rgb(192,0,0);">3.4</span>.<span class="number" style="color:rgb(192,0,0);">6</span>/bin/../conf/zoo.cfg&nbsp;&nbsp;</span></p></li>
 <li><p><span style="color:#000000;">Mode:&nbsp;follower&nbsp;&nbsp;</span></p></li>
</ol>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">&nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">Zookeeper集群在启动的过程中，查阅zookeeper.out，会有如下异常：</p>
<p>Java代码&nbsp;&nbsp;<a title="收藏这段代码" style="color:rgb(16,138,198);text-decoration:underline;"><img onload="if(this.width>650) this.width=650;" class="star" src="http://gao-xianglong.iteye.com/images/icon_star.png" alt="收藏代码" style="border:0px;"></a></p>
<pre class="brush:java;toolbar:false">java.net.ConnectException:&nbsp;Connection&nbsp;refused&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.PlainSocketImpl.socketConnect(Native&nbsp;Method)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:339)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:200)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:182)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.net.Socket.connect(Socket.java:579)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;org.apache.zookeeper.server.quorum.QuorumCnxManager.connectOne(QuorumCnxManager.java:368)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;org.apache.zookeeper.server.quorum.QuorumCnxManager.toSend(QuorumCnxManager.java:341)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;org.apache.zookeeper.server.quorum.FastLeaderElection$Messenger$WorkerSender.process(FastLeaderElection.java:449)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;org.apache.zookeeper.server.quorum.FastLeaderElection$Messenger$WorkerSender.run(FastLeaderElection.java:430)&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;at&nbsp;java.lang.Thread.run(Thread.java:745)</pre>
<p><br><a title="收藏这段代码" style="color:rgb(16,138,198);text-decoration:underline;"></a></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;white-space:normal;background-color:rgb(255,255,255);">上述异常可以忽略，因为集群环境中某些子节点还没有启动zookeeper。</p>
<p><br></p>
