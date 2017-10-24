<p>[root@power_centos_6 ~]# cd /home/downloads/zookeeper-3.4.6</p>
<p>[root@power_centos_6 zookeeper-3.4.6]# cd conf</p>
<p>[root@power_centos_6 conf]# cat zk1.cfg&nbsp;</p>
<p>tickTime=2000</p>
<p>initLimit=10</p>
<p>syncLimit=5</p>
<p>dataDir=/home/apache/zoo/zk1</p>
<p>clientPort=2181</p>
<p>server.1=10.6.212.188:2888:3888</p>
<p>server.2=10.6.212.188:2889:3889</p>
<p>server.3=10.6.212.188:2890:3890</p>
<p>[root@power_centos_6 conf]# cat zk2.cfg&nbsp;</p>
<p>tickTime=2000</p>
<p>initLimit=10</p>
<p>syncLimit=5</p>
<p>dataDir=/home/apache/zoo/zk2</p>
<p>clientPort=2182</p>
<p>server.1=10.6.212.188:2888:3888</p>
<p>server.2=10.6.212.188:2889:3889</p>
<p>server.3=10.6.212.188:2890:3890</p>
<p>[root@power_centos_6 conf]# cat zk3.cfg&nbsp;</p>
<p>tickTime=2000</p>
<p>initLimit=10</p>
<p>syncLimit=5</p>
<p>dataDir=/home/apache/zoo/zk3</p>
<p>clientPort=2183</p>
<p>server.1=10.6.212.188:2888:3888</p>
<p>server.2=10.6.212.188:2889:3889</p>
<p>server.3=10.6.212.188:2890:3890</p>
<p>[root@power_centos_6 conf]# ls</p>
<p>configuration.xsl &nbsp;log4j.properties &nbsp;zk1.cfg &nbsp;zk2.cfg &nbsp;zk3.cfg &nbsp;_zoo.cfg &nbsp;zoo_sample.cfg</p>
<p>[root@power_centos_6 conf]# tree /home/apache/zoo/</p>
<p>/home/apache/zoo/</p>
<p>├── zk1</p>
<p>│ &nbsp; ├── myid</p>
<p>│ &nbsp; └── version-2</p>
<p>│ &nbsp; &nbsp; &nbsp; ├── acceptedEpoch</p>
<p>│ &nbsp; &nbsp; &nbsp; ├── currentEpoch</p>
<p>│ &nbsp; &nbsp; &nbsp; ├── log.100000001</p>
<p>│ &nbsp; &nbsp; &nbsp; └── snapshot.0</p>
<p>├── zk2</p>
<p>│ &nbsp; ├── myid</p>
<p>│ &nbsp; └── version-2</p>
<p>│ &nbsp; &nbsp; &nbsp; ├── acceptedEpoch</p>
<p>│ &nbsp; &nbsp; &nbsp; ├── currentEpoch</p>
<p>│ &nbsp; &nbsp; &nbsp; └── log.100000001</p>
<p>└── zk3</p>
<p>&nbsp; &nbsp; ├── myid</p>
<p>&nbsp; &nbsp; └── version-2</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; ├── acceptedEpoch</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; ├── currentEpoch</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; ├── log.100000001</p>
<p>&nbsp; &nbsp; &nbsp; &nbsp; └── snapshot.100000000</p>
<p><br></p>
<p>6 directories, 14 files</p>
<p>[root@power_centos_6 conf]#&nbsp;</p>
<p><br></p>
<p><br></p>
<p>启动三个zookeeper 服务器：</p>
<p>bin/zkServer.sh start conf/zk1.cfg</p>
<p>bin/zkServer.sh start conf/zk2.cfg</p>
<p>bin/zkServer.sh start conf/zk3.cfg</p>
<p><br></p>
<p>查看zookeeper谁是leader谁是follewer：</p>
<p>bin/zkServer.sh status conf/zk1.cfg</p>
<p>JMX enabled by default</p>
<p>Using config: conf/zk1.cfg</p>
<p>Mode: follower</p>
<p><br></p>
<p>bin/zkServer.sh status conf/zk2.cfg</p>
<p>JMX enabled by default</p>
<p>Using config: conf/zk2.cfg</p>
<p>Mode: leader</p>
<p><br></p>
<p>bin/zkServer.sh status conf/zk3.cfg</p>
<p>JMX enabled by default</p>
<p>Using config: conf/zk3.cfg</p>
<p>Mode: follower</p>
<p><br></p>
<p>很明显2是leader</p>
