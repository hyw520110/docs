<p>本文为《基于Dubbo的分布式系统架构视频教程》的课程系列文档，更多课程信息，请关注：<a href="http://www.roncoo.com" title="龙果学院" target="_blank">http://www.roncoo.com</a></p>
<p><br></p>
<p>Dubbo视频教程--基础篇--第03节--ZooKeeper注册中心安装详细步骤（单节点）</p>
<p><strong style="text-align:center;"><span style="font-family:'宋体';"><br></span></strong></p>
<p><strong style="text-align:center;"><span style="font-family:'宋体';">安装</span>Dubbo</strong><strong style="text-align:center;"><span style="font-family:'宋体';">注册中心</span>(Zookeeper-3.4.6)</strong></p>
<p><span style="text-indent:28px;font-family:Georgia, serif;color:rgb(51,51,51);background:#FFFFFF;"><br></span></p>
<p><span style="text-indent:28px;font-family:Georgia, serif;color:rgb(51,51,51);background:#FFFFFF;">Dubbo</span><span style="text-indent:28px;font-family:'宋体';color:rgb(51,51,51);background:#FFFFFF;">建议使用</span><span style="text-indent:28px;font-family:Georgia, serif;color:rgb(51,51,51);background:#FFFFFF;">Zookeeper</span><span style="text-indent:28px;font-family:'宋体';color:rgb(51,51,51);background:#FFFFFF;">作为服务的注册中心。</span></p>
<p><span style="font-family:'宋体';text-indent:28px;"><br></span></p>
<p><span style="font-family:'宋体';text-indent:28px;">注册中心服务器（192.168.3.71）配置，安装Zookeeper:</span></p>
<p><span style="font-size:12px;font-family:'宋体';">1、<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;</span></span><span style="font-size:12px;font-family:'宋体';">修改操作系统的/etc/hosts文件中添加：</span></p>
<p style="text-indent:0;"><span style="font-size:12px;font-family:'宋体';color:#0070C0;">#zookeeper servers</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p style="text-indent:0;"><span style="font-size:12px;font-family:'宋体';color:#0070C0;">192.168.3.71&nbsp;&nbsp; edu-provider-01&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p></li>
</ol>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">2、</span><span style="font-family:'宋体';">到http://apache.fayea.com/zookeeper/下载zookeeper-3.4.6：</span></p>
<p style="text-indent:0;line-height:29px;background:#FFFFFF;"><span style="font-family:'宋体';">$ </span><span style="font-size:12px;font-family:'宋体';color:#FF0000;">wget http://apache.fayea.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">3、</span><span style="font-family:'宋体';">解压zookeeper安装包：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$<span style="color:#FF0000;"> tar -zxvf zookeeper-3.4.6.tar.gz</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">4、</span><span style="font-family:'宋体';">在/home/wusc/zookeeper-3.4.6目录下创建以下目录：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">cd /home/wusc/zookeeper-3.4.6</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">mkdir data</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">mkdir logs</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">5、</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">将zookeeper-3.4.6/conf目录下的zoo_sample.cfg文件拷贝一份，命名为为zoo.cfg</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">cp zoo_sample.cfg zoo.cfg</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-size:12px;font-family:'宋体';">6、<span style="font-size:9px;font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">修改zoo.cfg配置文件：</span></p>
<p style="margin-left:48px;"><span style="font-size:12px;font-family:'宋体';">$ <span style="color:#FF0000;">vi zoo.cfg</span></span></p>
<p style="margin-left:48px;"><span style="font-family:'宋体';font-size:12px;text-indent:20px;"># The number of milliseconds of each tick</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">tickTime=2000</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># The number of ticks thatthe initial</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># synchronization phase cantake</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">initLimit=10</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># The number of ticks thatcan pass between</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># sending a request andgetting an acknowledgement</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">syncLimit=5</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># the directory where thesnapshot is stored.</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># do not use /tmp forstorage, /tmp here is just</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># example sakes.</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">dataDir=/home/wusc/zookeeper-3.4.6/data</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">dataLogDir=/home/wusc/zookeeper-3.4.6/logs</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># the port at which theclients will connect</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">clientPort=2181</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';">#2888,3888 are election port</span></p>
<p style="text-indent:4px;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">server.1=edu-provider-01:2888:3888</span></p>
<p style="text-indent:4px;"><br></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">其中，</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">2888</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">端口号是zookeeper服务之间通信的端口。</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">3888</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">是zookeeper与其他应用程序通信的端口。</span></p>
<p style="text-indent:0;"><span style="font-size:12px;font-family:'宋体';color:#FF0000;">edu-provider-01</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">是在hosts中已映射了IP的主机名。</span></p>
<p style="text-indent:0;"><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);"><br></span></p>
<p style="text-indent:0;"><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">initLimit</span><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">：这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 10个心跳的时间（也就是 tickTime）长度后Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是5*2000=10 秒。</span></p>
<p style="text-indent:0;"><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">syncLimit</span><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">：这个配置项标识 Leader 与 Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是 2*2000=4 秒。</span></p>
<p style="text-indent:0;"><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">server.A=B:C:D</span><span style="line-height:26px;font-family:'宋体';color:rgb(51,51,51);">：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务器的IP地址或/etc/hosts文件中映射了IP的主机名；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</span><br></p>
<p><span style="font-family:'宋体';">&nbsp;</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">7、</span><span style="font-family:'宋体';color:#FF0000;">在dataDir=/home/wusc/zookeeper-3.4.6/data下创建myid文件</span></p>
<p style="text-indent:0;line-height:26px;background:#FFFFFF;"><span style="font-family:'宋体';color:#333333;">编辑myid文件，并在对应的IP的机器上输入对应的编号。如在zookeeper上，myid文件内容就是1。如果只在单点上进行安装配置，那么只有一个server.1。</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">vi myid</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">1</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">8、</span><span style="font-family:'宋体';">wusc</span><span style="font-family:'宋体';">用户下修改<span style="color:#FF0000;">vi /home/wusc/.bash_profile</span>，增加zookeeper配置：</span></p>
<p><span style="font-family:'宋体';color:#FF0000;"># zookeeper env</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">export ZOOKEEPER_HOME=/home/wusc/zookeeper-3.4.6</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#FF0000;">export PATH=$ZOOKEEPER_HOME/bin:$PATH</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">使配置文件生效</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">source /home/wusc/.bash_profile</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">9、</span><span style="font-family:'宋体';">在防火墙中打开要用到的端口2181、2888、3888</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">切换到root用户权限，执行以下命令：</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># <span style="color:#FF0000;">chkconfigiptables on</span></span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># <span style="color:#FF0000;">serviceiptables start</span></span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';">编辑/etc/sysconfig/iptables</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';"># <span style="color:#FF0000;">vi/etc/sysconfig/iptables</span></span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';">增加以下3行：</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#0070C0;">-A INPUT -mstate --state NEW -m tcp -p tcp --dport 2181 -j ACCEPT</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#0070C0;">-A INPUT -mstate --state NEW -m tcp -p tcp --dport 2888 -j ACCEPT</span></p>
<p style="text-indent:24px;"><span style="font-size:12px;font-family:'宋体';color:#0070C0;">-A INPUT -mstate --state NEW -m tcp -p tcp --dport 3888 -j ACCEPT</span></p>
<p style="text-indent:24px;"><br></p>
<p style="text-indent:4px;"><span style="font-size:12px;font-family:'宋体';">重启防火墙：</span></p>
<p style="text-indent:4px;"><span style="font-size:12px;font-family:'宋体';"># <span style="color:#FF0000;">service iptables restart</span></span></p>
<p style="text-indent:4px;"><br></p>
<p style="text-indent:4px;"><span style="font-size:12px;font-family:'宋体';">查看防火墙端口状态：</span></p>
<p style="text-indent:4px;"><span style="font-size:12px;font-family:'宋体';"># <span style="color:#FF0000;">service iptables status</span></span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">Table: filter</span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">Chain INPUT (policy ACCEPT)</span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">num&nbsp; target&nbsp;&nbsp;&nbsp;&nbsp;prot opt source&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destination&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">1&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;all&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; state RELATED,ESTABLISHED </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">2&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;icmp --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">3&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;all&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">4&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;tcp&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; state NEW tcp dpt:22 </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';color:#FF0000;">5&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;tcp&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; state NEW tcp dpt:2181 </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';color:#FF0000;">6&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;tcp&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; state NEW tcp dpt:2888 </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';color:#FF0000;">7&nbsp;&nbsp;&nbsp; ACCEPT&nbsp;&nbsp;&nbsp;&nbsp;tcp&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; state NEW tcp dpt:3888 </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">8&nbsp;&nbsp;&nbsp; REJECT&nbsp;&nbsp;&nbsp;&nbsp;all&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; reject-with icmp-host-prohibited </span></p>
<p style="text-indent:17px;"><br></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">Chain FORWARD (policy ACCEPT)</span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">num&nbsp; target&nbsp;&nbsp;&nbsp;&nbsp;prot opt source&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destination&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">1&nbsp;&nbsp;&nbsp; REJECT&nbsp;&nbsp;&nbsp;&nbsp;all&nbsp; --&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0.0.0.0/0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; reject-with icmp-host-prohibited </span></p>
<p style="text-indent:17px;"><br></p>
<p style="text-indent:17px;"><span style="font-size:9px;font-family:'宋体';">Chain OUTPUT (policy ACCEPT)</span></p>
<p style="text-indent:4px;"><span style="font-size:9px;font-family:'宋体';">num&nbsp; target&nbsp;&nbsp;&nbsp;&nbsp;prot opt source&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destination&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p><span style="font-family:'宋体';">&nbsp;</span></p>
<p><span style="font-family:'宋体';">10、<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style="font-family:'宋体';">启动并测试zookeeper（<span style="color:#FF0000;">要用wusc用户启动，不要用root</span>）:</span></p>
<p><span style="font-family:'宋体';">(1)</span><span style="font-family:'宋体';">使用wusc用户到/home/wusc/zookeeper-3.4.6/bin目录中执行：</span></p>
<p style="text-indent:0;"><strong><span style="font-family:'宋体';">$ <span style="color:#FF0000;">zkServer.shstart</span></span></strong></p>
<p style="text-indent:0;"><strong><span style="font-family:'宋体';">&nbsp;</span></strong></p>
<p><span style="font-family:'宋体';">(2)</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">输入</span><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">jps</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">命令查看进程：</span></p>
<p><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">$ </span><span style="font-family:Arial, sans-serif;color:#FF0000;background:#FFFFFF;">jps</span></p>
<p><span style="font-family:Arial, sans-serif;color:#0070C0;background:#FFFFFF;">1456 QuorumPeerMain</span></p>
<p><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">1475 Jps</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">其中，</span><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">QuorumPeerMain</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">是</span><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">zookeeper</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">进程，启动正常</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">(3)</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">查看状态：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">zkServer.sh</span></span><span style="font-family:Arial, sans-serif;color:#FF0000;background:#FFFFFF;"> status</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><strong><span style="font-family:'宋体';">&nbsp;</span></strong></p>
<p><span style="font-family:'宋体';">(4)</span><span style="font-family:'宋体';">查看zookeeper服务输出信息：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">由于服务信息输出文件在/home/wusc/zookeeper-3.4.6/bin/zookeeper.out</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">tail -500f zookeeper.out</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">11、<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">停止</span><span style="font-family:Arial, sans-serif;color:#333333;background:#FFFFFF;">zookeeper</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">进程：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$</span><span style="font-family:Arial, sans-serif;color:#FF0000;background:#FFFFFF;"> zkServer.sh stop</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">12、<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></span><span style="font-family:'宋体';">配置zookeeper开机使用wusc用户启动：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">编辑/etc/rc.local文件，加入：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#0070C0;">su - wusc -c '/home/wusc/zookeeper-3.4.6/bin/zkServer.shstart'</span></p>
<p><br></p>
<p>本文出自 “<a href="http://wushuicheng.blog.51cto.com">水到渠成</a>” 博客，请务必保留此出处<a href="http://wushuicheng.blog.51cto.com/9357402/1703368">http://wushuicheng.blog.51cto.com/9357402/1703368</a></p>
