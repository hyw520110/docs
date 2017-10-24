<p style="text-align:center;"><strong><span style="font-family:'宋体';">Dubbo</span></strong><strong><span style="font-family:'宋体';">注册中心集群Zookeeper-3.4.6</span></strong></p>
<p><span style="font-family:'宋体';">&nbsp;</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">Dubbo</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">建议使用Zookeeper作为服务的注册中心。</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">Zookeeper</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">集群中只要有过半的节点是正常的情况下，那么整个集群对外就是可用的。正是基于这个特性，要将ZK集群的节点数量要为奇数（2n+1：如3、5、7个节点）较为合适。</span></p>
<p><span style="font-family:'宋体';">&nbsp;</span></p>
<p><strong><span style="font-family:'宋体';">ZooKeeper</span></strong><strong><span style="font-family:'宋体';">与Dubbo服务集群架构图</span></strong></p>
<p style="margin-left:56px;text-indent:28px;"><span style="font-family:'宋体';"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </span></p>
<p><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">&nbsp;<a href="http://s4.51cto.com/wyfs02/M00/7A/80/wKiom1aq1U_Ad065AAB91yejcxI238.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s4.51cto.com/wyfs02/M00/7A/80/wKiom1aq1U_Ad065AAB91yejcxI238.jpg" title="1.jpg" alt="wKiom1aq1U_Ad065AAB91yejcxI238.jpg"></a></span><span style="font-family:'宋体';text-indent:28px;">&nbsp;</span></p>
<p><span style="font-family:'宋体';">&nbsp;</span></p>
<p><span style="font-family:'宋体';">服务器1：</span><span style="font-family:'宋体';color:#FF0000;">192.168.1.81</span><span style="font-family:'宋体';">&nbsp; 端口：</span><span style="font-family:'宋体';color:#FF0000;">2181</span><span style="font-family:'宋体';">、</span><span style="font-family:'宋体';color:#FF0000;">2881</span><span style="font-family:'宋体';">、</span><span style="font-family:'宋体';color:#FF0000;">3881</span></p>
<p><span style="font-family:'宋体';">服务器2：<span style="color:#FF0000;">192.168.1.82</span>&nbsp; 端口：<span style="color:#FF0000;">2182</span>、<span style="color:#FF0000;">2882</span>、<span style="color:#FF0000;">3882</span></span></p>
<p><span style="font-family:'宋体';">服务器3：<span style="color:#FF0000;">192.168.1.83</span>&nbsp; 端口：<span style="color:#FF0000;">2183</span>、<span style="color:#FF0000;">2883</span>、<span style="color:#FF0000;">3883</span></span></p>
<p><span style="font-family:'宋体';">&nbsp;</span><span style="font-family:'宋体';">1、<span style="font-family:'Times New Roman';">&nbsp;</span></span><span style="font-family:'宋体';">修改操作系统的/etc/hosts文件，添加IP与主机名映射：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;"># zookeeper clusterservers</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">192.168.1.81&nbsp;&nbsp;edu-zk-01</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">192.168.1.82&nbsp;&nbsp;edu-zk-02</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">192.168.1.83&nbsp;&nbsp;edu-zk-03</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">2、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">下载或上传zookeeper-3.4.6.tar.gz到/home/wusc/zookeeper目录：</span></p>
<p style="text-indent:24px;background:#FFFFFF;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">cd /home/wusc/zookeeper</span></span></p>
<p style="text-indent:24px;background:#FFFFFF;"><span style="font-family:'宋体';">$ </span><span style="font-family:'宋体';color:#FF0000;">wget http://apache.fayea.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">3、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">解压zookeeper安装包，并按节点号对zookeeper目录重命名：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$<span style="color:#FF0000;"> tar -zxvf zookeeper-3.4.6.tar.gz</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">服务器1：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$<span style="color:#FF0000;"> mv zookeeper-3.4.6 node-01</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">服务器2：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$<span style="color:#FF0000;"> mv zookeeper-3.4.6 node-02</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">服务器3：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$<span style="color:#FF0000;"> mv zookeeper-3.4.6 node-03</span></span></p>
<p><span style="font-family:'宋体';">4、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">在各zookeeper节点目录下创建以下目录：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">cd /home/wusc/zookeeper/node-0</span><span style="color:#0070C0;">X&nbsp; (X</span></span><span style="font-family:'宋体';color:#0070C0;">代表节点号1、2、3，以下同解)</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">mkdir data</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">mkdir logs</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">5、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">将zookeeper/node-</span><span style="font-family:'宋体';background:#FFFFFF;">0<span style="color:#0070C0;">X</span><span style="color:#333333;">/conf</span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">目录下的zoo_sample.cfg文件拷贝一份，命名为zoo.cfg:</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">cp zoo_sample.cfg zoo.cfg</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">6、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">修改zoo.cfg配置文件：</span></p>
<p style="text-indent:28px;"><strong><span style="font-family:'宋体';">zookeeper/node-01</span></strong><strong><span style="font-family:'宋体';">的配置（/home/wusc/zookeeper/node-01/conf/zoo.cfg）如下：</span></strong></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">tickTime=2000</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">initLimit=10</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">syncLimit=5</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataDir=/home/wusc/zookeeper/node-01/data</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataLogDir=/home/wusc/zookeeper/node-01/logs</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">clientPort=2181</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.1=edu-zk-01:2881:3881</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.2=edu-zk-02:2882:3882</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.3=edu-zk-03:2883:3883</span></p>
<p style="text-indent:28px;"><strong style="text-indent:24px;"><span style="font-family:'宋体';">zookeeper/node-02</span></strong><strong style="text-indent:24px;"><span style="font-family:'宋体';">的配置（/home/wusc/zookeeper/node-02/conf/zoo.cfg）如下：</span></strong></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">tickTime=2000</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">initLimit=10</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">syncLimit=5</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataDir=/home/wusc/zookeeper/node-02/data</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataLogDir=/home/wusc/zookeeper/node-02/logs</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">clientPort=2182</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.1=edu-zk-01:2881:3881</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.2=edu-zk-02:2882:3882</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.3=edu-zk-03:2883:3883</span></p>
<p style="text-indent:28px;"><strong><span style="font-family:'宋体';">zookeeper/node-03</span></strong><strong><span style="font-family:'宋体';">的配置（/home/wusc/zookeeper/node-03/conf/zoo.cfg）如下：</span></strong></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">tickTime=2000</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">initLimit=10</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">syncLimit=5</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataDir=/home/wusc/zookeeper/node-03/data</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">dataLogDir=/home/wusc/zookeeper/node-03/logs</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">clientPort=2183</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.1=edu-zk-01:2881:3881</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.2=edu-zk-02:2882:3882</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">server.3=edu-zk-03:2883:3883</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">&nbsp;</span><strong style="text-indent:16px;"><span style="font-family:'宋体';">参数说明:</span></strong></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';color:#0070C0;">tickTime=2000</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';">tickTime</span><span style="font-family:'宋体';">这个时间是作为Zookeeper服务器之间或客户端与服务器之间维持心跳的时间间隔,也就是每个tickTime时间就会发送一个心跳。</span></p>
<p style="margin-left:16px;"><span style="color:rgb(0,112,192);font-family:'宋体';">initLimit=10</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';">initLimit</span><span style="font-family:'宋体';">这个配置项是用来配置Zookeeper接受客户端（这里所说的客户端不是用户连接Zookeeper服务器的客户端,而是Zookeeper服务器集群中连接到Leader的Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过10个心跳的时间（也就是tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息,那么表明这个客户端连接失败。总的时间长度就是 10*2000=20 秒。</span></p>
<p style="margin-left:16px;"><span style="color:rgb(0,112,192);font-family:'宋体';">syncLimit=5</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';">syncLimit</span><span style="font-family:'宋体';">这个配置项标识Leader与Follower之间发送消息,请求和应答时间长度,最长不能超过多少个tickTime的时间长度,总的时间长度就是5*2000=10秒。</span></p>
<p style="margin-left:16px;"><span style="color:rgb(0,112,192);font-family:'宋体';">dataDir=/home/wusc/zookeeper/node-01/data</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';">dataDir</span><span style="font-family:'宋体';">顾名思义就是Zookeeper保存数据的目录,默认情况下Zookeeper将写数据的日志文件也保存在这个目录里。</span></p>
<p style="margin-left:16px;"><span style="color:rgb(0,112,192);font-family:'宋体';">clientPort=2181</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';">clientPort</span><span style="font-family:'宋体';">这个端口就是客户端（应用程序）连接Zookeeper服务器的端口,Zookeeper会监听这个端口接受客户端的访问请求。</span></p>
<p><span style="font-family:'宋体';color:#0070C0;">&nbsp; </span><span style="text-indent:16px;font-family:'宋体';color:rgb(0,112,192);">server.A=B</span><span style="text-indent:16px;font-family:'宋体';color:rgb(0,112,192);">：C：D</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';color:#FF0000;">server.1=edu-zk-01:2881:3881</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';color:#FF0000;">server.2=edu-zk-02:2882:3882</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';color:#FF0000;">server.3=edu-zk-03:2883:3883</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';">A</span><span style="font-family:'宋体';">是一个数字,表示这个是第几号服务器；</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';">B</span><span style="font-family:'宋体';">是这个服务器的IP地址（或者是与IP地址做了映射的主机名）；</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';">C</span><span style="font-family:'宋体';">第一个端口用来集群成员的信息交换,表示这个服务器与集群中的Leader服务器交换信息的端口；</span></p>
<p style="text-indent:16px;"><span style="font-family:'宋体';">D</span><span style="font-family:'宋体';">是在leader挂掉时专门用来进行选举leader所用的端口。</span></p>
<p style="margin-left:16px;"><span style="font-family:'宋体';color:#FF0000;">注意：如果是伪集群的配置方式，不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">7、<span style="font-family:'Times New Roman';">&nbsp;</span></span><span style="font-family:'宋体';color:#FF0000;">在dataDir=/home/wusc/zookeeper/node-0</span><span style="font-family:'宋体';color:rgb(0,112,192);">X</span><span style="font-family:'宋体';color:#FF0000;">/data</span><span style="font-family:'宋体';color:#FF0000;">下创建myid文件</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';color:#333333;">编辑myid文件，并在对应的IP的机器上输入对应的编号。如在node-01上，myid文件内容就是</span><span style="font-family:'宋体';color:#0070C0;">1</span><span style="font-family:'宋体';color:#333333;">,node-02</span><span style="font-family:'宋体';color:#333333;">上就是</span><span style="font-family:'宋体';color:#0070C0;">2</span><span style="font-family:'宋体';color:#333333;">，node-03上就是</span><span style="font-family:'宋体';color:#0070C0;">3</span><span style="font-family:'宋体';color:#333333;">：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">vi /home/wusc/zookeeper/node-0</span><span style="color:#0070C0;">1</span><span style="color:#FF0000;">/data/myid&nbsp; </span>## </span><span style="font-family:'宋体';">值为</span><span style="font-family:'宋体';color:#0070C0;">1</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">vi /home/wusc/zookeeper/node-0</span><span style="color:#0070C0;">2</span><span style="color:#FF0000;">/data/myid&nbsp; </span>## </span><span style="font-family:'宋体';">值为</span><span style="font-family:'宋体';color:#0070C0;">2</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">vi /home/wusc/zookeeper/node-0</span><span style="color:#0070C0;">3</span><span style="color:#FF0000;">/data/myid&nbsp; </span>## </span><span style="font-family:'宋体';">值为</span><span style="font-family:'宋体';color:#0070C0;">3</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">8、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">在防火墙中打开要用到的端口218<span style="color:#0070C0;">X</span>、288<span style="color:#0070C0;">X</span>、388<span style="color:#0070C0;">X</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">切换到root用户权限，执行以下命令：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">chkconfigiptables on</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">service iptablesstart</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">编辑/etc/sysconfig/iptables</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">vi/etc/sysconfig/iptables</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">如服务器01增加以下3行：</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">## zookeeper</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">-A INPUT -m state --state NEW -m tcp -p tcp--dport 2181 -j ACCEPT</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">-A INPUT -m state --state NEW -m tcp -p tcp--dport 2881 -j ACCEPT</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';color:#0070C0;">-A INPUT -m state --state NEW -m tcp -p tcp--dport 3881 -j ACCEPT</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">重启防火墙：</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">service iptables restart</span></span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">查看防火墙端口状态：</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">service iptables status</span></span></p>
<p><span style="font-family:'宋体';">9、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">启动并测试zookeeper（<span style="color:#FF0000;">要用wusc用户启动，不要用root</span>）:</span></p>
<p><span style="font-family:'宋体';">(1)<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">使用wusc用户到/home/wusc/zookeeper/node-0<span style="color:#0070C0;">X</span>/bin目录中执行：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">/home/wusc/zookeeper/node-01/bin/zkServer.shstart</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">/home/wusc/zookeeper/node-02/bin/zkServer.shstart</span></span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">/home/wusc/zookeeper/node-03/bin/zkServer.shstart</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">(2)<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">输入jps命令查看进程：</span></p>
<p style="text-indent:52px;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">$ </span><span style="font-family:'宋体';color:#FF0000;background:#FFFFFF;">jps</span></p>
<p style="text-indent:52px;"><span style="font-family:'宋体';color:#0070C0;background:#FFFFFF;">1456QuorumPeerMain</span></p>
<p style="text-indent:54px;"><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">其中，QuorumPeerMain是zookeeper进程，说明启动正常</span></p>
<p><span style="font-family:'宋体';">(3)<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">查看状态：</span></p>
<p style="text-indent:54px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">/home/wusc/zookeeper/node-01/bin/zkServer.sh</span></span><span style="font-family:'宋体';color:#FF0000;background:#FFFFFF;"> status</span></p>
<p><span style="font-family:'宋体';">(4)<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">查看zookeeper服务输出信息：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">由于服务信息输出文件在/home/wusc/zookeeper/node-0<span style="color:#0070C0;">X</span>/bin/zookeeper.out</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">tail-500f zookeeper.out</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">10、</span><span style="font-family:'宋体';color:#333333;background:#FFFFFF;">停止zookeeper进程：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">$</span><span style="font-family:'宋体';color:#FF0000;background:#FFFFFF;"> zkServer.sh stop</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">11、</span><span style="font-family:'宋体';">配置zookeeper开机使用wusc用户启动：</span></p>
<p style="text-indent:0;"><span style="font-family:'宋体';">编辑node-01、node-02、node-03中的/etc/rc.local文件，分别加入：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">su - wusc -c '/home/wusc/zookeeper/node-01/bin/zkServer.shstart'</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">su - wusc -c '/home/wusc/zookeeper/node-02/bin/zkServer.shstart'</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">su - wusc -c '/home/wusc/zookeeper/node-03/bin/zkServer.shstart'</span></p>
<p><strong><span style="font-family:'宋体';">二、安装Dubbo管控台（<span style="color:#FF0000;">基础篇有讲,此处重点讲管控台如何链接集群</span>）：</span></strong></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">Dubbo</span><span style="font-family:'宋体';">管控台可以对注册到zookeeper注册中心的服务或服务消费者进行管理，但管控台是否正常对Dubbo服务没有影响，管控台也不需要高可用，因此可以单节点部署。</span></p>
<p style="text-indent:24px;"><br></p>
<p><span style="font-family:'宋体';">IP: <span style="color:#FF0000;">192.168.1.81</span></span></p>
<p><span style="font-family:'宋体';">部署容器：<span style="color:#FF0000;">Tomcat7</span></span></p>
<p><span style="font-family:'宋体';">端口：<span style="color:#FF0000;">8080</span></span></p>
<p><span style="font-family:'宋体';">1、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">下载（或上传）最新版的Tomcat7（<span style="color:#FF0000;">apache-tomcat-7.0.57.tar.gz</span>）到/home/wusc/</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">2、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">解压：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ </span><span style="font-family:'宋体';color:#FF0000;">tar -zxvf apache-tomcat-7.0.57.tar.gz</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#ff0000;">mv apache-tomcat-7.0.57dubbo-admin-tomcat<br></span></span><span style="color:#FF0000;font-family:'宋体';text-indent:28px;">3、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="color:#FF0000;font-family:'宋体';text-indent:28px;">移除/home/wusc/dubbo-admin-tomcat/webapps目录下的所有文件：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ </span><span style="font-family:'宋体';color:#FF0000;">rm -rf *</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">4、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">上传Dubbo管理控制台程序</span><a href="http://code.alibabatech.com/mvn/releases/com/alibaba/dubbo-admin/2.5.3/dubbo-admin-2.5.3.war" target="_blank"><span style="font-family:'宋体';color:#8F4E0B;background:#FFFFFF;">dubbo-admin-2.5.3.war</span></a></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">到/home/wusc/dubbo-admin-tomcat/webapps</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">5、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">解压并把目录命名为ROOT:</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">unzip dubbo-admin-2.5.3.war -d ROOT</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">把dubbo-admin-2.5.3.war移到/home/wusc/tools目录备份</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#ff0000;">mv dubbo-admin-2.5.3.war/home/wusc/tools<br></span></span><span style="font-family:'宋体';">6、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">配置</span><span style="font-family:'宋体';background:#FFFFFF;">dubbo.properties</span><span style="font-family:'宋体';background:#FFFFFF;">：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">vi ROOT/WEB-INF/dubbo.properties</span></span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">dubbo.registry.address=</span><span style="font-family:'宋体';color:#0070C0;">zookeeper://</span><span style="font-family:'宋体';color:#FF0000;">192.168.1.81:2181?backup=192.168.1.82:2182,192.168.1.83:2183</span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">dubbo.admin.root.password=<span style="color:#FF0000;">wusc.123</span></span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">dubbo.admin.guest.password=<span style="color:#FF0000;">wusc.123</span></span></p>
<p style="text-indent:28px;"><span style="font-family:'宋体';">（以上密码在正式上生产前要修改）</span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">7、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">防火墙开启8080端口，用root用户修改/etc/sysconfig/iptables，</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">vi /etc/sysconfig/iptables</span></span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">增加：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">## dubbo-admin-tomcat:8080</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">-A INPUT -m state --state NEW -m tcp -p tcp--dport 8080 -j ACCEPT</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">重启防火墙：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';"># <span style="color:#FF0000;">service iptables restart</span></span></p>
<p><span style="font-family:'宋体';">8、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">启动Tomat7</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">$ <span style="color:#FF0000;">/home/wusc/dubbo-admin-tomcat/bin/startup.sh</span></span></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">9、<span style="font-family:'Times New Roman';">&nbsp; </span></span><span style="font-family:'宋体';">浏览</span><a href="http://192.168.1.81:8080/" target="_blank"><span style="font-family:'宋体';">http://192.168.1.81:8080/</span></a></p>
<p style="margin-left:24px;"><a href="http://s3.51cto.com/wyfs02/M02/7A/80/wKioL1aq1rPw_ykoAABuwzgxmoQ955.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/7A/80/wKioL1aq1rPw_ykoAABuwzgxmoQ955.jpg" title="1.jpg" alt="wKioL1aq1rPw_ykoAABuwzgxmoQ955.jpg"></a></p>
<p style="text-indent:0;"><br></p>
<p><span style="font-family:'宋体';">10、</span><span style="font-family:'宋体';">配置部署了Dubbo管控台的Tomcat开机启动：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';">在虚拟主机中编辑/etc/rc.local文件，加入：</span></p>
<p style="text-indent:24px;"><span style="font-family:'宋体';color:#0070C0;">su - wusc -c'/home/wusc/dubbo-admin-tomcat/bin/startup.sh'</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">11、</span><span style="font-family:'宋体';color:#FF0000;">应用链接到注册中心群集的测试。（请看视频）</span></p>
<p><span style="font-family:'宋体';color:#FF0000;">12、</span><span style="font-family:'宋体';color:#FF0000;">注册中心高可用集群的测试。（请看视频）</span></p>
<p><strong><span style="font-family:'宋体';color:#FF0000;">提示：下一节，注册中心集群的链接测试，多注册中心集群的升级迁移。<br><br>本文出自龙果学院《基于Dubbo分布式系统架构视频教程》高可用架构篇--第01节--ZooKeeper集群的安装、配置、高可用测试<br><br>Dubbo视频教程官网：</span></strong><strong style="padding:0px;margin:0px;color:rgb(0,112,192);font-family:'Microsoft YaHei', Verdana, sans-serif, '宋体';letter-spacing:.5px;line-height:22.5px;white-space:normal;background-color:rgb(255,255,255);"><a href="http://www.roncoo.com/" style="padding:0px;margin:0px;color:rgb(255,131,115);" target="_blank">http://www.roncoo.com</a></strong><strong><span style="font-family:'宋体';color:#FF0000;"><br></span></strong></p>
<p><br></p>
<p>本文出自 “<a href="http://11142517.blog.51cto.com">11132517</a>” 博客，请务必保留此出处<a href="http://11142517.blog.51cto.com/11132517/1739769">http://11142517.blog.51cto.com/11132517/1739769</a></p>
