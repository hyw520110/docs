<p>storm+kestrel+zookeeper</p> 
<div>
 &nbsp;
</div> 
<div>
 环境：
</div> 
<div>
 2台服务器：192.168.1.166
</div> 
<div>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;192.168.1.167
</div> 
<div>
 系统：centos 5.6
</div> 
<div>
 &nbsp;
</div> 
<div>
 部署：192.168.1.166：ui,nimbus,supervisor
</div> 
<div>
 &nbsp; &nbsp; &nbsp; 192.168.1.167:supervisor,kestrel,zookeeper
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp; &nbsp; 因为公司网站对数据的实时性要求比较高，所以最近一直在研究storm，因为9月份刚开源，所以一些资料相对来说比较说，只能从官方wiki上去查，地址：
 <a href="https://github.com/nathanmarz/storm/wiki">https://github.com/nathanmarz/storm/wiki</a>
</div> 
<div>
 &nbsp; &nbsp; storm
 <span style="font-family: 宋体; "><span class="Apple-style-span" style="color: rgb(51, 51, 51); font-size: 14px; line-height: 20px; background-color: rgb(255, 255, 255); ">是一个分布式的、容错的实时计算系统，它被托管在</span></span>
 <a style="padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; color: rgb(62, 98, 166); outline-width: 0px; outline-style: initial; outline-color: initial; font-family: Verdana, Simsun, sans-serif; font-size: 14px; line-height: 20px; text-align: left; background-color: rgb(255, 255, 255); " href="http://www.oschina.net/p/github"><span style="font-family: 宋体; ">GitHub</span></a>
 <span style="font-family: 宋体; "><span class="Apple-style-span" style="color: rgb(51, 51, 51); font-size: 14px; line-height: 20px; text-align: left; background-color: rgb(255, 255, 255); ">上，遵循 Eclipse Public License 1.0。Storm是由BackType开发的实时处理系统，BackType现在已在Twitter麾下。GitHub上的最新版本是Storm 0.5.2，基本是用</span></span>
 <a style="padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; color: rgb(62, 98, 166); outline-width: 0px; outline-style: initial; outline-color: initial; font-family: Verdana, Simsun, sans-serif; font-size: 14px; line-height: 20px; text-align: left; background-color: rgb(255, 255, 255); " href="http://www.oschina.net/p/clojure"><span style="font-family: 宋体; ">Clojure</span></a>
 <span style="font-family: 宋体; "><span class="Apple-style-span" style="color: rgb(51, 51, 51); font-size: 14px; line-height: 20px; text-align: left; background-color: rgb(255, 255, 255); ">写的。</span></span>
</div> 
<div>
 &nbsp;
</div> 
<div>
 1、安装zookeeper
</div> 
<div>
 &nbsp;
</div> 
<div>
 zookeeper集群部署方式：
</div> 
<div>
 tar xvzf zookeeper-3.3.3.tar.gz
</div> 
<div>
 cd zookeeper-3.3.3
</div> 
<div>
 mv conf/zoo-sample.cfg conf/zoo.cfg
</div> 
<div>
 vim conf/zoo.cfg
</div> 
<div>
 &nbsp;
</div> 
<div>
 tickTime=2000
</div> 
<div>
 initLimit=5
</div> 
<div>
 syncLimit=2
</div> 
<div>
 dataDir=/var/lib/storm/zookeeper
</div> 
<div>
 dataLogDir=/var/log/zookeeper
</div> 
<div>
 clientPort=2181
</div> 
<div>
 server.1=192.168.1.166:2888:3888
</div> 
<div>
 server.2=192.168.1.167:2888:3888
</div> 
<div>
 &nbsp;
</div> 
<div>
 保存退出。
</div> 
<div>
 mkdir /var/lib/storm/zookeeper
</div> 
<div>
 vim /var/lib/storm/zookeeper/myid
</div> 
<div>
 本机是166，所以这里输入1
</div> 
<div>
 保存退出。
</div> 
<div>
 &nbsp;
</div> 
<div>
 另外2台机器同样的步骤，不过myid改为2,3即可。
</div> 
<div>
 注意：zookeeper的集群必须是单数的机器，也就是说要么3台做，要么单台做伪集群，2台做出来的话我个人测试是有问题的，这里也不是很确定，如果有哪位知道，麻烦告知下。
</div> 
<div>
 &nbsp;
</div> 
<div>
 启动2台上面的服务：
</div> 
<div>
 /usr/local/zookeeper-3.3.3/bin/zkServer.sh start
</div> 
<div>
 &nbsp;
</div> 
<div>
 #zookeeper单机部署：
</div> 
<div>
 同集群相同：只是配置文件略有不同：
</div> 
<div>
 #vim zoo.cfg
</div> 
<div>
 tickTime=2000
</div> 
<div>
 minSessionTimeout=2000
</div> 
<div>
 maxSessionTimeout=20000
</div> 
<div>
 dataDir=/var/lib/storm/zookeeper
</div> 
<div>
 dataLogDir=/var/log/zookeeper
</div> 
<div>
 clientPort=2181
</div> 
<div>
 保存退出
</div> 
<div>
 然后直接启动服务即可：/usr/local/zookeeper-3.3.3/bin/zkServer.sh start
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;
</div> 
<div>
 1、安装zeromq
</div> 
<div>
 &nbsp;安装依赖包
</div> 
<div>
 &nbsp;yum -y install gcc-c++ e2fsprogs.x86_64 e2fsprogs-devel.x86_64
</div> 
<div>
 &nbsp;&nbsp;
</div> 
<div>
 tar xvzf zeromq-2.1.7.tar.gz
</div> 
<div>
 cd zeromq-2.1.7
</div> 
<div>
 ./configure
</div> 
<div>
 make&nbsp;
</div> 
<div>
 make install
</div> 
<div>
 &nbsp;
</div> 
<div>
 2、安装jzmq
</div> 
<div>
 &nbsp;
</div> 
<div>
 tar xvzf nathanmarz-jzmq-dd3327d.tar.gz
</div> 
<div>
 cd tar xvzf nathanmarz-jzmq-dd3327d
</div> 
<div>
 yum install pkgconfig libtool.x86_64
</div> 
<div>
 ./autogen.sh
</div> 
<div>
 ./configure
</div> 
<div>
 make
</div> 
<div>
 make install
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;
</div> 
<div>
 3、安装python 2.6.6
</div> 
<div>
 &nbsp;
</div> 
<div>
 tar jxvf Python-2.6.6.tar.bz2
</div> 
<div>
 ./configure --bindir=/usr/bin --libdir=/usr/lib
</div> 
<div>
 make&nbsp;
</div> 
<div>
 make install
</div> 
<div>
 &nbsp;
</div> 
<div>
 4、安装kestrel
</div> 
<div>
 安装kestrel需要安装daemon
</div> 
<div>
 tar xvzf daemon-0.6.4.tar.gz
</div> 
<div>
 cd daemon-0.6.4
</div> 
<div>
 ./config
</div> 
<div>
 make
</div> 
<div>
 make test
</div> 
<div>
 make install
</div> 
<div>
 make install-daemon-conf
</div> 
<div>
 make install-slack
</div> 
<div>
 &nbsp;
</div> 
<div>
 tar xvzf kestrel-2.1.3.zip
</div> 
<div>
 mv kestrel-2.1.3 /usr/local/kestrel
</div> 
<div>
 vim /usr/local/kestrel/scripts/kestrel.sh
</div> 
<div>
 修改APP_HOME="/usr/local/$APP_NAME/current"为
</div> 
<div>
 APP_HOME="/usr/local/$APP_NAME"
</div> 
<div>
 保存
</div> 
<div>
 cp -rp /usr/local/kestrel/scripts/kestrel.sh /etc/init.d/kestrel
</div> 
<div>
 service kestrel start
</div> 
<div>
 &nbsp;
</div> 
<div>
 5、安装storm
</div> 
<div>
 unzip storm-0.6.0.zip
</div> 
<div>
 cd storm-0.6.0
</div> 
<div>
 cd conf
</div> 
<div>
 vim strom.yaml
</div> 
<div>
 内容如下：
</div> 
<div>
 ============================================================================
</div> 
<div>
 java.library.path: "/usr/local/lib:/opt/local/lib:/usr/lib"
</div> 
<div>
 &nbsp;
</div> 
<div>
 ### storm.* configs are general configurations
</div> 
<div>
 # the local dir is where jars are kept
</div> 
<div>
 &nbsp;storm.local.dir: "/var/lib/storm/data"
</div> 
<div>
 &nbsp;storm.zookeeper.servers:
</div> 
<div>
 &nbsp; &nbsp; &nbsp;- "192.168.1.166"
</div> 
<div>
 &nbsp;storm.zookeeper.port: 2181
</div> 
<div>
 &nbsp;storm.zookeeper.root: "/var/lib/storm/storm"
</div> 
<div>
 &nbsp;storm.zookeeper.session.timeout: 20000
</div> 
<div>
 &nbsp;storm.cluster.mode: "distributed" # can be distributed or local
</div> 
<div>
 &nbsp;storm.local.mode.zmq: false
</div> 
<div>
 &nbsp;
</div> 
<div>
 ### nimbus.* configs are for the master
</div> 
<div>
 &nbsp;nimbus.host: "192.168.1.166"
</div> 
<div>
 &nbsp;nimbus.thrift.port: 6627
</div> 
<div>
 &nbsp;nimbus.childopts: "-Xmx2048m"
</div> 
<div>
 &nbsp;nimbus.task.timeout.secs: 30
</div> 
<div>
 &nbsp;nimbus.supervisor.timeout.secs: 60
</div> 
<div>
 &nbsp;nimbus.monitor.freq.secs: 10
</div> 
<div>
 &nbsp;nimbus.task.launch.secs: 240
</div> 
<div>
 &nbsp;nimbus.reassign: true
</div> 
<div>
 &nbsp;nimbus.file.copy.expiration.secs: 600
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;ui.port: 8080
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;drpc.port: 3772
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;supervisor.slots.ports:
</div> 
<div>
 &nbsp; &nbsp; - 6700
</div> 
<div>
 &nbsp; &nbsp; - 6701
</div> 
<div>
 &nbsp; &nbsp; - 6702
</div> 
<div>
 &nbsp; &nbsp; - 6703
</div> 
<div>
 &nbsp;supervisor.childopts: "-Xmx2048m"
</div> 
<div>
 #how long supervisor will wait to ensure that a worker process is started
</div> 
<div>
 &nbsp;supervisor.worker.start.timeout.secs: 240
</div> 
<div>
 #how long between heartbeats until supervisor considers that worker dead and tries to restart it
</div> 
<div>
 &nbsp;supervisor.worker.timeout.secs: 30
</div> 
<div>
 #how frequently the supervisor checks on the status of the processes it's monitoring and restarts if necessary
</div> 
<div>
 &nbsp;supervisor.monitor.frequency.secs: 3
</div> 
<div>
 #how frequently the supervisor heartbeats to the cluster state (for nimbus)
</div> 
<div>
 &nbsp;supervisor.heartbeat.frequency.secs: 5
</div> 
<div>
 &nbsp;supervisor.enable: true
</div> 
<div>
 &nbsp;
</div> 
<div>
 ### worker.* configs are for task workers
</div> 
<div>
 &nbsp;worker.childopts: "-Xmx768m"
</div> 
<div>
 &nbsp;worker.heartbeat.frequency.secs: 1
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;task.heartbeat.frequency.secs: 3
</div> 
<div>
 &nbsp;task.refresh.poll.secs: 10
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;zmq.threads: 1
</div> 
<div>
 &nbsp;zmq.linger.millis: 5000
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;=======================================================================================================
</div> 
<div>
 日志路径修改：vim log4j/storm.log.properties
</div> 
<div>
 &nbsp;修改：log4j.appender.A1.File = logs/${logfile.name} &nbsp; 为log4j.appender.A1.File = /var/log/${logfile.name}
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;保存退出。启动服务。
</div> 
<div>
 &nbsp;nimbus：nohup /opt/storm/storm-0.6.0/bin/storm nimbus &amp;
</div> 
<div>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;nohup /opt/storm/storm-0.6.0/bin/storm ui &amp;
</div> 
<div>
 <span class="Apple-tab-span" style="white-space:pre"> </span> nohup /opt/storm/storm-0.6.0/bin/storm supervisor &amp;
</div> 
<div>
 &nbsp;supervisor:nohup /opt/storm/storm-0.6.0/bin/storm supervisor &amp;
</div> 
<div>
 &nbsp;
</div> 
<div>
 &nbsp;ui访问：http://192.168.1.166:8080
</div> 
<div>
 &nbsp;
</div> 
<div>
 说明：storm0.5.4的集群部署，我这边测试总是有问题，具体原因未知，也不知道是否为bug，不过6.0的总算成功，有兴趣的可以试试。
</div>
<p>本文出自 “<a href="http://newyue.blog.51cto.com">我的运维之路</a>” 博客，请务必保留此出处<a href="http://newyue.blog.51cto.com/174760/737140">http://newyue.blog.51cto.com/174760/737140</a></p>
