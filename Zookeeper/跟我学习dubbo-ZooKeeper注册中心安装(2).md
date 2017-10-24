<p><strong><span style="font-size:16px;">注册中心</span></strong></p>
<p><span style="font-size:16px;">可选方案：zookeeper、Redis <br></span></p>
<p><span style="font-size:16px;">1、建议使用dubbo-2.3.3以上版本的使用zookeeper注册中心客户端 <br></span></p>
<p><span style="font-size:16px;">2、Zookeeper是Apache Hadoop的子项目，强度相对较好，建议生产环境使用该注册中心。 <br></span></p>
<p><span style="font-size:16px;">3、Dubbo未对Zookeeper服务器端做任何侵入修改，只需安装原生的Zookeeper服务器即可， 所有注册中心逻辑适配都在调用Zookeeper客户端时完成。</span></p>
<p><strong><span style="font-size:16px;">安装 Dubbo 注册中心(Zookeeper-3.4.6)</span></strong></p>
<p><span style="font-size:16px;">1、 修改操作系统的/etc/hosts 文件中添加： <br></span></p>
<p><span style="font-size:16px;color:rgb(0,176,240);"># zookeeper servers <br></span></p>
<p><span style="font-size:16px;color:rgb(0,176,240);">192.168.3.71 edu-provider-01</span></p>
<p><span style="font-size:16px;">2、 到 http://apache.fayea.com/zookeeper/下载 zookeeper-3.4.6：</span></p>
<p><span style="font-size:16px;color:rgb(0,0,0);">$ </span><span style="font-size:16px;color:rgb(255,0,0);">wget </span><a href="http://apache.fayea.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz" target="_blank"><span style="font-size:16px;color:rgb(255,0,0);">http://apache.fayea.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz</span></a><br></p>
<p><span style="font-size:16px;">3、 解压 zookeeper 安装包：</span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">tar -zxvf zookeeper-3.4.6.tar.gz</span></span></p>
<p><span style="font-size:16px;">4、 在/home/jeesml/zookeeper-3.4.6 目录下创建以下目录：</span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">cd /home/jeesml/zookeeper-3.4.6 </span><br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">mkdir data </span><br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">mkdir logs</span></span></p>
<p><span style="font-size:16px;">5、 将 zookeeper-3.4.6/conf 目录下的 zoo_sample.cfg 文件拷贝一份，命名为为 zoo.cfg <br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">cp zoo_sample.cfg zoo.cfg</span></span></p>
<p><span style="font-size:16px;">6、 修改 zoo.cfg 配置文件：</span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">vi zoo.cfg</span></span></p>
<p><span style="font-size:16px;"># The number of milliseconds of each tick</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">tickTime=2000</span></p>
<p><span style="font-size:16px;"># The number of ticks that the initial</span></p>
<p><span style="font-size:16px;"># synchronization phase can take</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">initLimit=10</span></p>
<p><span style="font-size:16px;"># The number of ticks that can pass between</span></p>
<p><span style="font-size:16px;"># sending a request and getting an acknowledgement</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">syncLimit=5</span></p>
<p><span style="font-size:16px;"># the directory where the snapshot is stored.</span></p>
<p><span style="font-size:16px;"># do not use /tmp for storage, /tmp here is just</span></p>
<p><span style="font-size:16px;"># example sakes.</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">dataDir=/home/jeesml/zookeeper-3.4.6/data</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">dataLogDir=/home/jeesml/zookeeper-3.4.6/logs</span></p>
<p><span style="font-size:16px;"># the port at which the clients will connect</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">clientPort=2181</span></p>
<p><span style="font-size:16px;">#2888,3888 are election port</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">server.1=edu-provider-01:2888:3888</span></p>
<p><span style="font-size:16px;">其中， <br></span></p>
<p><span style="font-size:16px;">2888 端口号是 zookeeper 服务之间通信的端口。 <br></span></p>
<p><span style="font-size:16px;">3888 是 zookeeper 与其他应用程序通信的端口。 <br></span></p>
<p><strong><span style="font-size:16px;color:rgb(255,0,0);">edu-provider-01 是在 hosts 中已映射了 IP 的主机名。 </span></strong><span style="font-size:16px;"><br></span></p>
<p><span style="font-size:16px;">initLimit：这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不 是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper 服务器集群中连接到</span></p>
<p><span style="font-size:16px;">Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。 当已经超过 10 个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没 有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒。 <br></span></p>
<p><span style="font-size:16px;">syncLimit：这个配置项标识 Leader 与 Follower 之间发送消息，请求和应答时 间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是 2*2000=4 秒。 <br></span></p>
<p><span style="font-size:16px;">server.A=B:C:D：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务 器的 IP 地址或/etc/hosts 文件中映射了 IP 的主机名；C 表示的是这个服务器与 集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务 器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是 用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是 一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同 的端口号</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">7、 在 dataDir=/home/jeesml/zookeeper-3.4.6/data 下创建 myid 文件 </span><span style="font-size:16px;"><br></span></p>
<p><span style="font-size:16px;">编辑 myid 文件，并在对应的 IP 的机器上输入对应的编号。如在 zookeeper 上，myid 文件内容就是 1。如果只在单点上进行安装配置，那么只有一个 server.1。 <br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">vi myid </span><br></span></p>
<p><span style="font-size:16px;">1 <br></span></p>
<p><span style="font-size:16px;">8、 jeesml用户下修改 <span style="font-size:16px;color:rgb(255,0,0);">vi /home/jeesml/.bash_profile</span>，增加 zookeeper 配置： <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);"># zookeeper env <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">export ZOOKEEPER_HOME=/home/jeesml/zookeeper-3.4.6 <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">export PATH=$ZOOKEEPER_HOME/bin:$PATH </span><span style="font-size:16px;"><br></span></p>
<p><span style="font-size:16px;">使配置文件生效 $ <span style="font-size:16px;color:rgb(255,0,0);">source /home/jeesml/.bash_profile </span><br></span></p>
<p><span style="font-size:16px;">9、 在防火墙中打开要用到的端口 2181、2888、3888 切换到 root 用户权限，执行以下命令：</span></p>
<p><span style="font-size:16px;"># <span style="font-size:16px;color:rgb(255,0,0);">chkconfig iptables on </span><br></span></p>
<p><span style="font-size:16px;"># <span style="font-size:16px;color:rgb(255,0,0);">service iptables start </span><br></span></p>
<p><span style="font-size:16px;">编辑/etc/sysconfig/iptables <br></span></p>
<p><span style="font-size:16px;"># <span style="font-size:16px;color:rgb(255,0,0);">vi /etc/sysconfig/iptables </span><br></span></p>
<p><span style="font-size:16px;">增加以下 3 行： <br></span></p>
<p><span style="font-size:16px;">-A INPUT -m state --state NEW -m tcp -p tcp --dport 2181 -j ACCEPT <br></span></p>
<p><span style="font-size:16px;">-A INPUT -m state --state NEW -m tcp -p tcp --dport 2888 -j ACCEPT <br></span></p>
<p><span style="font-size:16px;">-A INPUT -m state --state NEW -m tcp -p tcp --dport 3888 -j ACCEPT <br></span></p>
<p><span style="font-size:16px;">重启防火墙： # service iptables restart</span></p>
<p><span style="font-size:16px;">查看防火墙端口状态： <br></span></p>
<p><span style="font-size:16px;"># <span style="font-size:16px;color:rgb(255,0,0);">service iptables status </span><br></span></p>
<p><span style="font-size:16px;">Table: filter <br></span></p>
<p><span style="font-size:16px;">Chain INPUT (policy ACCEPT) <br></span></p>
<p><span style="font-size:16px;">num target prot opt source destination <br></span></p>
<p><span style="font-size:16px;">1 ACCEPT all -- 0.0.0.0/0 0.0.0.0/0 state RELATED,ESTABLISHED <br></span></p>
<p><span style="font-size:16px;">2 ACCEPT icmp -- 0.0.0.0/0 0.0.0.0/0 <br></span></p>
<p><span style="font-size:16px;">3 ACCEPT all -- 0.0.0.0/0 0.0.0.0/0 <br></span></p>
<p><span style="font-size:16px;">4 ACCEPT tcp -- 0.0.0.0/0 0.0.0.0/0 state NEW tcp dpt:22 <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">5 ACCEPT tcp -- 0.0.0.0/0 0.0.0.0/0 state NEW tcp dpt:2181 <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">6 ACCEPT tcp -- 0.0.0.0/0 0.0.0.0/0 state NEW tcp dpt:2888 <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">7 ACCEPT tcp -- 0.0.0.0/0 0.0.0.0/0 state NEW tcp dpt:3888 </span><span style="font-size:16px;"><br></span></p>
<p><span style="font-size:16px;">8 REJECT all -- 0.0.0.0/0 0.0.0.0/0 reject-with icmp-host-prohibited <br></span></p>
<p><span style="font-size:16px;">Chain FORWARD (policy ACCEPT) <br></span></p>
<p><span style="font-size:16px;">num target prot opt source destination <br></span></p>
<p><span style="font-size:16px;">1 REJECT all -- 0.0.0.0/0 0.0.0.0/0 reject-with icmp-host-prohibited</span></p>
<p><span style="font-size:16px;">Chain OUTPUT (policy ACCEPT) <br></span></p>
<p><span style="font-size:16px;">num target prot opt source destination</span></p>
<p><span style="font-size:16px;">10、 启动并测试 zookeeper（<span style="font-size:16px;color:rgb(255,0,0);">要用 jeesml用户启动，不要用 root</span>）:</span></p>
<p><span style="font-size:16px;">(1) 使用 jeesml用户到/home/jeesml/zookeeper-3.4.6/bin 目录中执行：</span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">zkServer.sh start </span><br></span></p>
<p><span style="font-size:16px;">(2) 输入 jps 命令查看进程： <br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">jps</span> <br></span></p>
<p><span style="font-size:16px;">1456 QuorumPeerMain <br></span></p>
<p><span style="font-size:16px;">1475 Jps <br></span></p>
<p><span style="font-size:16px;">其中，QuorumPeerMain 是 zookeeper 进程，启动正常</span></p>
<p><span style="font-size:16px;">(3) 查看状态： <br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">zkServer.sh status </span><br></span></p>
<p><span style="font-size:16px;">(4) 查看 zookeeper 服务输出信息：</span></p>
<p><span style="font-size:16px;">由于服务信息输出文件在/home/jeesml/zookeeper-3.4.6/bin/zookeeper.out <br></span></p>
<p><span style="font-size:16px;">$ <span style="font-size:16px;color:rgb(255,0,0);">tail -500f zookeeper.out</span></span></p>
<p><span style="font-size:16px;">11、 停止 zookeeper 进程：</span></p>
<p><span style="font-size:16px;">$<span style="font-size:16px;color:rgb(255,0,0);"> zkServer.sh stop </span><br></span></p>
<p><span style="font-size:16px;">12、 配置 zookeeper 开机使用 jeesml用户启动： <br></span></p>
<p><span style="font-size:16px;">编辑/etc/rc.local 文件，加入： <br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);">su - jeesml-c '/home/jeesml/zookeeper-3.4.6/bin/zkServer.sh start'</span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);"><br></span></p>
<p><span style="font-size:16px;color:rgb(255,0,0);"></span></p>
<p style="margin:10px auto;padding:0px;font-size:14px;font-style:normal;font-variant:normal;font-weight:normal;letter-spacing:normal;line-height:25.2000007629395px;text-align:left;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;color:rgb(51,51,51);font-family:Verdana, Arial, Helvetica, sans-serif;background-color:rgb(255,255,255);"><span style="margin:0px;padding:0px;">请各位持续关注《跟我学习dubbo-Dubbo管理控制台的安装(2)》</span></p>
<p style="margin:10px auto;padding:0px;font-size:14px;font-style:normal;font-variant:normal;font-weight:normal;letter-spacing:normal;line-height:25.2000007629395px;text-align:left;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;color:rgb(51,51,51);font-family:Verdana, Arial, Helvetica, sans-serif;background-color:rgb(255,255,255);"><span style="margin:0px;padding:0px;">由于第一次写关于dubbo的博客，还希望大家加入dubbo学习<span style="margin:0px;padding:0px;font-size:18px;color:rgb(255,0,0);"><strong>交流群(446855438)</strong></span>，一起学习。</span></p>
<p><br></p>
<p>本文出自 “<a href="http://11081853.blog.51cto.com">11071853</a>” 博客，请务必保留此出处<a href="http://11081853.blog.51cto.com/11071853/1731232">http://11081853.blog.51cto.com/11071853/1731232</a></p>
