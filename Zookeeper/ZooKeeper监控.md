<p></p>
<p>在公司内部，有不少应用已经强依赖zookeeper，zookeeper的工作状态直接影响它们的正常工作。目前开源世界中暂没有一个比较成熟的zookeeper-monitor,于是开始zookeeper监控这块工作。</p>
<p style="text-align:left;">目前zookeeper-monitor能做哪些事情，讲到这个，首先来看看哪些因素对zookeeper正常工作比较大的影响：</p>
<ol class="list-paddingleft-2">
 <li><p>用于zookeeper写日志的目录要有足够大小，并且强烈建议在单独的磁盘（挂载点）上，这是影响ZK性能最大因素之一。</p></li>
 <li><p>连接数。</p></li>
 <li><p>注册的Watcher数。</p></li>
 <li><p>ZNode是否可读，可写。</p></li>
 <li><p>ZK事件通知的延时是否过大。</p></li>
</ol>
<p style="text-align:left;">围绕以上几点展开，完成了taokeeper一期的开发，目前主要完成以下方面的监控：（项目地址：<a href="https://github.com/alibaba/taokeeper" target="_blank">https://github.com/alibaba/taokeeper</a>）</p>
<p style="text-align:left;">l<strong>CPU/MEM/LOAD</strong>的监控</p>
<p style="text-align:left;">l<strong>ZK</strong><strong>日志目录</strong>所在磁盘剩余空间监控</p>
<p style="text-align:left;">l<strong>单机连接数</strong>的峰值报警</p>
<p style="text-align:left;">l<strong>单机Watcher数</strong>的峰值报警</p>
<p style="text-align:left;">l<strong>节点自检</strong>：是指对集群中每个IP所在ZK节点上的PATH:/YINSHI.MONITOR.ALIVE.CHECK定期进行三次如下流程:节点连接&#xfffd;数据发布&#xfffd;修改通知&#xfffd;获取数据&#xfffd;数据对比,在指定的延时内，三次流程均成功视为该节点处于正常状态。</p>
<ul class="list-paddingleft-2">
 <li><p><strong><span style="font-size:medium;">ZooKeeper集群实时状态</span></strong><span style="color:#FF0000;">(点击图片查看大图)</span></p></li>
</ul>
<p><a href="http://img1.51cto.com/attachment/201311/224906553.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" title="monitor-interface.jpg" src="http://img1.51cto.com/attachment/201311/224906553.jpg" alt="224906553.jpg">点击查看按钮可以查看当前服务器上所有订阅者的详细信息：</a></p>
<p><a href="http://img1.51cto.com/attachment/201311/225052497.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" title="zookeeper_monitor_view_watch.jpg" src="http://img1.51cto.com/attachment/201311/225052497.jpg" alt="225052497.jpg"></a></p>
<p><a href="http://img1.51cto.com/attachment/201311/225201898.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" title="alarm-setting-interface1.jpg" src="http://img1.51cto.com/attachment/201311/225201898.jpg" alt="225201898.jpg"></a></p>
<p><span style="color:#FF0000;"><strong><span style="color:#000000;"><span style="font-size:medium;">ZooKeeper集群状态趋势图</span></span></strong>(点击图片查看大图)<a href="http://img1.51cto.com/attachment/201311/225242780.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="taokeeper_monitor_trend_chart-1024x677.png" src="http://img1.51cto.com/attachment/201311/225242780.png" alt="225242780.png"></a></span></p>
<p><span style="color:#FF0000;"></span></p>
<p><strong><span style="font-size:x-large;">如何安装部署</span></strong></p>
<p><span style="color:#FF0000;">首先，对之前使用maven-war-plugin来进行配置管理的方式，表示遗憾。不少开发人员反馈部署比较困难，另外还有一些对maven不熟悉的开发人员也是这样认为。现在有了改进，将配置与程序分离开来。对此给大家带来的不便，深表歉意。</span></p>
<p><strong>一、直接部署</strong></p>
<p>1.下载<a href="http://pan.baidu.com/share/link?shareid=4059329570&amp;uk=2064399439" target="_blank">taokeeper.sql</a>,初始化数据库(Mysql).<br>2.下载<a title="taokeeper" href="http://pan.baidu.com/share/link?shareid=4033853839&amp;uk=2064399439" target="_blank">taokeeper-monitor.war</a>文件，解压到tomcat的webapps目前下，确保最后目录结构如下：<strong>%TOMCAT_HOME%\webapps\taokeeper-monitor.war</strong></p>
<p>3.下载<a href="http://115.com/file/e730luvq" target="_blank"></a><a href="http://pan.baidu.com/share/link?shareid=4057042957&amp;uk=2064399439" target="_blank">taokeeper-monitor-config.properties</a>文件，存放到一个指定目录，比如</p>
<p>/home/xiaoming/taokeeper-monitor/config/taokeeper-monitor-config.properties,其中内容如下，根据需要自己修改下。</p>
<p><span style="color:#FF0000;"></span></p>
<pre class="brush:java;toolbar:false;">----------------------------------------------------------------
systemInfo.envName=TEST
#DBCP
dbcp.driverClassName=com.mysql.jdbc.Driver
dbcp.dbJDBCUrl=jdbc:mysql://1.1.1.1:3306/taokeeper
dbcp.characterEncoding=GBK
dbcp.username=xiaoming
dbcp.password=123456
dbcp.maxActive=30
dbcp.maxIdle=10
dbcp.maxWait=10000
#SystemConstant
SystemConstent.dataStoreBasePath=/home/xiaoming/taokeeper-monitor/ZookeeperStore
#SSH account of zk server
SystemConstant.userNameOfSSH=xiaoming
SystemConstant.passwordOfSSH=123456
------------------------------------------------------------------
4. 在tomcat启动脚本中添加JAVA_OPTS:
&lt;strong&gt;windows&lt;/strong&gt;上：&lt;strong&gt;set&lt;/strong&gt; JAVA_OPTS=-DconfigFilePath="D:servertomcatwebappstaokeeper-monitor-config.properties"
&lt;strong&gt;linux&lt;/strong&gt;上：JAVA_OPTS=-DconfigFilePath="/home/xiaoming/taokeeper-monitor/config/taokeeper-monitor-config.properties"</pre>
<p><span style="color:#FF0000;"></span></p>
<p>5.启动tomcat服务器</p>
<p>6.正常启动后，访问：http://127.0.0.1:8080/taokeeper-monitor</p>
<p><strong>二、从源代码开始</strong></p>
<p>1.Checkout源代码：git@github.com:nileader/taokeeper.git</p>
<p>2.修改代码…</p>
<p>3.实现com.taobao.taokeeper.reporter.alarm.MessageSender接口，用于发送报警信息。（可选）</p>
<p>4.到taokeeper根目录下执行package.cmd命令，打成一个war包，之后进行部署</p>
<p><strong><span style="font-size:x-large;">如何使用</span></strong><br>1.taokeeper-monitor启动后，还没有配置任何zookeeper集群，点击“加入监控”进行集群添加。</p>
<p><span style="color:#FF0000;"><a href="http://img1.51cto.com/attachment/201311/225615206.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="11111.png" src="http://img1.51cto.com/attachment/201311/225615206.png" alt="225615206.png"></a></span></p>
<p><span style="color:#FF0000;">2.配置zookeeper集群信息</span></p>
<p><span style="color:#FF0000;"><a href="http://img1.51cto.com/attachment/201311/225654463.png" target="_blank"><img onload="if(this.width>650) this.width=650;" title="000000.png" src="http://img1.51cto.com/attachment/201311/225654463.png" alt="225654463.png"></a></span></p>
