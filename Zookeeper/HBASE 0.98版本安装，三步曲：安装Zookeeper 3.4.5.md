<p>1、下载zookeeper 3.4.5</p>
<p><br></p>
<p><br></p>
<p>2、解压</p>
<p><br></p>
<p><br></p>
<p>3、挪到合适的位置</p>
<p><br></p>
<p>/home/hadoop/zookeeper</p>
<p><br></p>
<p><br></p>
<p>4、设置一个zookeeper放置数据的位置</p>
<p><br></p>
<p>/home/hadoop/zk</p>
<p><br></p>
<p><br></p>
<p>5、修改zookeeper配置文件</p>
<p><br></p>
<p>vim /home/hadoop/zookeeper/conf/zoo.cfg</p>
<p><br></p>
<p>tickTime=2000<br>initLimit=10<br>syncLimit=5<br>dataDir=/home/hadoop/zk<br>clientPort=2181<br></p>
<p>server.1=hd1:2888:3888<br>server.2=hd2:2888:3888<br>server.3=hd3:2888:3888<br>server.4=hd4:2888:3888<br></p>
<p><br></p>
<p>6、分发zookeeper到别的节点</p>
<p><br></p>
<p>scp -r /home/hadoop/zookeeper hd2:/home/hadoop</p>
<p>scp -r /home/hadoop/zookeeper hd3:/home/hadoop</p>
<p>scp -r /home/hadoop/zookeeper hd4:/home/hadoop</p>
<p><br></p>
<p><br></p>
<p>7、建立myid文件</p>
<p><br></p>
<p>vim /home/hadoop/zk/myid</p>
<p><br></p>
<p>hd1 设为 1</p>
<p>hd2 设为 2</p>
<p>类推</p>
<p><br></p>
<p><br></p>
<p>7、编辑/etc/profile</p>
<p>#zookeeper<br>export ZOOKEEPER_HOME=/home/hadoop/zookeeper<br>export PATH=$PATH:$ZOOKEEPER_HOME/bin<br></p>
<p><br></p>
<p>8、在每个节点独立启动zookeeper</p>
<p>/home/hadoop/zookeeper/bin/zkServer.sh</p>
<p><br></p>
<p><br></p>
<p>9、启动后使用jps查看状态</p>
<p>21408 QuorumPeerMain</p>
<p>出现QuorumPeerMain就正确了。</p>
<p><br></p>
