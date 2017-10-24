<p><a href="http://cloud.github.com/downloads/nileader/ZooKeeper-Notes/%E3%80%90ZooKeeper%20Notes%2010%E3%80%91ZooKeeper%E7%9B%91%E6%8E%A7.pdf" target="_blank">查看PDF</a></p> 
<p>转载请注明：<a href="http://weibo.com/nileader" target="_blank">@ni掌柜</a> nileader@gmail.com</p> 
<p>&nbsp; &nbsp; &nbsp;在公司内部，有不少应用已经强依赖zookeeper，zookeeper的工作状态直接影响它们的正常工作。目前开源世界中暂没有一个比较成熟的zookeeper-monitor, 于是开始zookeeper监控这块工作。</p> 
<div>
 &nbsp; &nbsp; &nbsp;目前zookeeper-monitor能做哪些事情，讲到这个，首先来看看哪些因素对zookeeper正常工作比较大的影响：
</div> 
<div>
 1. 用于zookeeper写日志的目录要有足够大小，并且强烈建议在单独的磁盘（挂载点）上，这是影响ZK性能最大因素之一。
</div> 
<div>
 2. 连接数。
</div> 
<div>
 3. 注册的Watcher数。
</div> 
<div>
 4. ZNode是否可读，可写。
</div> 
<div>
 5. ZK事件通知的延时是否过大。
</div> 
<div>
 围绕以上几点展开，完成了taokeeper一期的开发，目前主要完成以下方面的监控：（项目地址：https://github.com/taobao/taokeeper）
</div> 
<div> 
 <div>
  1. CPU/MEM/LOAD的监控
 </div> 
 <div>
  2. ZK日志目录所在磁盘剩余空间监控
 </div> 
 <div>
  3. 单机连接数的峰值报警
 </div> 
 <div>
  4. 单机 Watcher数的峰值报警
 </div> 
 <div>
  5. 节点自检：是指对集群中每个IP所在ZK节点上的PATH: /YINSHI.MONITOR.ALIVE.CHECK 定期进行三次如下流程 : 节点连接 &#x2013; 数据发布 &#x2013; 修改通知 &#x2013; 获取数据 &#x2013; 数据对比, 在指定的延时内，三次流程均成功视为该节点处于正常状态。
 </div> 
 <div>
  &nbsp;
 </div> 
 <div>
  <span style="font-size: 26px; ">ZooKeeper集群实时状态</span>&nbsp;
 </div> 
 <p><a href="http://img1.51cto.com/attachment/201210/090120387.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/090120387.jpg" border="0" alt=""></a></p> 
 <div>
  &nbsp;
 </div> 
</div> 
<div>
 &nbsp;点击查看按钮可以查看当前服务器上所有订阅者的详细信息：
</div> 
<p><a href="http://img1.51cto.com/attachment/201210/090235622.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/090235622.jpg" border="0" alt=""></a></p> 
<p><span style="font-size: 26px; ">ZooKeeper监控报警设置</span></p> 
<p><a href="http://img1.51cto.com/attachment/201210/090334118.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/090334118.jpg" border="0" alt=""></a></p> 
<p><span style="font-size: 26px; ">ZooKeeper集群状态趋势图</span></p> 
<p><a href="http://img1.51cto.com/attachment/201210/090426488.png" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/090426488.png" border="0" alt=""></a></p> 
<p>&nbsp;</p> 
<p><span style="font-size: 36px; ">如何安装部署</span>&nbsp;</p> 
<p><span style="color: rgb(255, 0, 0); ">首先，对之前使用 maven-war-plugin 来进行配置管理的方式，表示遗憾。不少开发人员反馈部署比较困难，另外还有一些对maven不熟悉的开发人员也是这样认为。现在有了改进，将配置与程序分离开来。对此给大家带来的不便，深表歉意。</span></p> 
<div>
 &nbsp;一、直接部署
</div> 
<div>
 1. 下载
 <a href="https://github.com/downloads/taobao/taokeeper/taokeeper.sql" target="_blank">taokeeper.sql</a>,初始化数据库(Mysql).
</div> 
<div>
 2. 下载
 <a href="https://github.com/downloads/taobao/taokeeper/taokeeper-monitor.tar.gz" target="_blank">taokeeper-monitor.tar.gz</a>文件，解压到tomcat的webapps目前下，确保最后目录结构如下： &nbsp;%TOMCAT_HOME%\webapps\taokeeper-monitor\WEB-INF
</div> 
<div>
 3. 下载 
 <a href="https://github.com/downloads/taobao/taokeeper/taokeeper-monitor-config.properties" target="_blank">taokeeper-monitor-config.properties</a> 文件，存放到一个指定目录，比如
</div> 
<div>
 /home/xiaoming/taokeeper-monitor/config/taokeeper-monitor-config.properties, 其中内容如下，根据需要自己修改下。
</div> 
<div>
 &nbsp;
</div> 
<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span class="attribute">systemInfo.envName</span><span>=</span><span class="attribute-value">TEST</span><span>&nbsp;</span></span></li>
  <li><span>#DBCP&nbsp;</span></li>
  <li class="alt"><span><span class="attribute">dbcp.driverClassName</span><span>=</span><span class="attribute-value">com</span><span>.mysql.jdbc.Driver&nbsp;</span></span></li>
  <li><span><span class="attribute">dbcp.dbJDBCUrl</span><span>=</span><span class="attribute-value">jdbc</span><span>:mysql://1.1.1.1:3306/taokeeper&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">dbcp.characterEncoding</span><span>=</span><span class="attribute-value">GBK</span><span>&nbsp;</span></span></li>
  <li><span><span class="attribute">dbcp.username</span><span>=</span><span class="attribute-value">xiaoming</span><span>&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">dbcp.password</span><span>=</span><span class="attribute-value">123456</span><span>&nbsp;</span></span></li>
  <li><span><span class="attribute">dbcp.maxActive</span><span>=</span><span class="attribute-value">30</span><span>&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">dbcp.maxIdle</span><span>=</span><span class="attribute-value">10</span><span>&nbsp;</span></span></li>
  <li><span><span class="attribute">dbcp.maxWait</span><span>=</span><span class="attribute-value">10000</span><span>&nbsp;</span></span></li>
  <li class="alt"><span>#SystemConstant&nbsp;</span></li>
  <li><span><span class="attribute">SystemConstent.dataStoreBasePath</span><span>=/home/xiaoming/taokeeper-monitor/ZookeeperStore&nbsp;</span></span></li>
  <li class="alt"><span>#SSH&nbsp;account&nbsp;of&nbsp;zk&nbsp;server&nbsp;</span></li>
  <li><span><span class="attribute">SystemConstant.userNameOfSSH</span><span>=</span><span class="attribute-value">xiaoming</span><span>&nbsp;</span></span></li>
  <li class="alt"><span><span class="attribute">SystemConstant.passwordOfSSH</span><span>=</span><span class="attribute-value">123456</span><span>&nbsp;</span></span></li>
 </ol></pre> 
<div> 
 <div>
  4. 在tomcat启动脚本中添加JAVA_OPTS:
 </div> 
 <div>
  windows上：set JAVA_OPTS=-DconfigFilePath="D:\server\tomcat\webapps\taokeeper-monitor-config.properties"
 </div> 
 <div>
  linux上：JAVA_OPTS=-DconfigFilePath="/home/xiaoming/taokeeper-monitor/config/taokeeper-monitor-config.properties"
 </div> 
 <div> 
  <div>
   5. 启动tomcat服务器
  </div> 
  <div>
   6. 正常启动后，访问：http://127.0.0.1:8080/taokeeper-monitor
  </div> 
  <div>
   &nbsp;
  </div> 
  <div>
   二、从源代码开始
  </div> 
  <div>
   1. Check out 源代码：git@github.com:nileader/taokeeper.git
  </div> 
  <div>
   2. 修改代码…
  </div> 
  <div>
   3. 实现 com.taobao.taokeeper.reporter.alarm.MessageSender 接口，用于发送报警信息。（可选）
  </div> 
  <div>
   4. 到taokeeper根目录下执行 package.cmd 命令，打成一个war包，之后进行部署
  </div> 
 </div> 
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;
 <span style="font-size: 36px; ">如何使用</span>
</div> 
<div>
 &nbsp;1. taokeeper-monitor启动后，还没有配置任何zookeeper集群，点击“加入监控”进行集群添加。
</div> 
<p><a href="http://img1.51cto.com/attachment/201210/091527896.png" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/091527896.png" border="0" alt=""></a></p> 
<p>2. 配置zookeeper集群信息</p> 
<p><a href="http://img1.51cto.com/attachment/201210/091517124.png" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://img1.51cto.com/attachment/201210/091517124.png" border="0" alt=""></a></p> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;
</div> 
<p>&nbsp;</p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/1032164">http://nileader.blog.51cto.com/1381108/1032164</a></p>
