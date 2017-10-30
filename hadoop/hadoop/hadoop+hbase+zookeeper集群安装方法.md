<pre>
 <ol class="dp-xml">
  <li class="alt"><span><span>&nbsp;&nbsp;&nbsp;最近公司搭建hadoop+hbase+zookeeper集群，期间遇到了许多问题，这里和大家分享一下安装的一些经验，目的在于大家在部署hadoop集群环境中少走一些弯路： &nbsp;</span></span></li>
  <li><span>由于刚开始的时候我用虚拟机安装，安装版本是hadoop0.20.2+hbase0.90.3+zookeeper3.3.3版本，在测试hbase集群的时候hmaster不能正常启动或者是启动后进程自杀（在网上找到的答案应该是虚拟机的内存小，不支持0.90.x以后的hbase版本启动hmaster），最后hbase换成0.20.6或者是0.89.X版本的测试没有问题； &nbsp;</span></li>
  <li class="alt"><span>hadoop的下载地址http://archive.apache.org/dist/hadoop/common/ &nbsp;</span></li>
  <li><span>hbase的下载地址：http://archive.apache.org/dist/hbase/ &nbsp;</span></li>
  <li class="alt"><span>zookeeper的下载地址：http://archive.apache.org/dist/hadoop/zookeeper/ &nbsp;</span></li>
  <li><span>1、&nbsp;我的主机配置如下：（添加到/etc/hosts文件里面）&nbsp;&nbsp; &nbsp;</span></li>
  <li class="alt"><span>192.168.0.211&nbsp;master&nbsp;&nbsp;（用于集群主机提供hmaster&nbsp;namenode&nbsp;jobtasker服务&nbsp;） &nbsp;</span></li>
  <li><span>192.168.0.212&nbsp;s1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;（用于集群丛机提供regionsrever&nbsp;datanode&nbsp;&nbsp;tasktacuter服务） &nbsp;</span></li>
  <li class="alt"><span>192.168.0.213&nbsp;s2 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>2、安装jdk1.6.2.X &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>3、添加java环境变量（/etc/profile），后执行source&nbsp;/etc/profile&nbsp;,使环境变量立即生效 &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">JAVA_HOME</span><span>=/usr/java/jdk1.6.0_26/ &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">CLASSPATH</span><span>=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">PATH</span><span>=$JAVA_HOME/bin:$PATH:$CATALINA_HOME/bin &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">HADOOP_HOME</span><span>=/home/hadoop/hadoop &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">HBASE_HOME</span><span>=/home/hadoop/hbase &nbsp;</span></li>
  <li class="alt"><span class="attribute">PATH</span><span>=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HBASE_HOME/bin &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>4、在三台电脑上添加hadoop用户&nbsp; &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>useradd&nbsp;hadoop &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>5、在/home/hadoop/.bashrc添加变量 &nbsp;</span></li>
  <li><span>（将hadoop&nbsp;hbase的配置文件放到hadoop安装包根目录文件下，目的在于以后升级hadoop和hbase的时候不用重新导入配置文件） &nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">HADOOP_CONF_DIR</span><span>=/home/hadoop/hadoop-config &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">HBASE_CONF_DIR</span><span>=/home/hadoop/hbase-config &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>6、将hadoop&nbsp;hbase&nbsp;zookepper的安装包解压到/home/hadoop/下，并重命名为hadoop&nbsp;hbase&nbsp;zookepper，在home/hadoop/下建立hadoop-config和hbase-config文件夹，并且将home/hadoop/hadoop/conf下的masters、slaves、core-site、mapred-sit、hdfs-site、hadoop-env拷贝到此文件夹，将home/hadoop/hbase/conf下的hbase-site和hbase-env.sh拷贝到次文件夹。 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>7、修改masters、slaves文件： &nbsp;</span></li>
  <li><span>&nbsp;分别为&nbsp;master&nbsp;和s1与s2 &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>8、修改hadoop-env.sh的变量： &nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">JAVA_HOME</span><span>=/usr/java/jdk1.6.0_26/ &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">HADOOP_PID_DIR</span><span>=/home/hadoop/hadoop/tmp &nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;</span></li>
  <li class="alt"><span>9、修改core-site.xml &nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">configuration</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>fs.default.name</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>hdfs://master:9000</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">configuration</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>修改mapred-site.xml &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">configuration</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>mapred.job.tracker</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>hdfs://master:9001/</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">configuration</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>修改hdfs-site.xml（name和data文件夹不要手动建立） &nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">configuration</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>dfs.name.dir</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>/home/hadoop/hadoop/name</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>dfs.data.dir</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>/home/hadoop/hadoop/data/</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>dfs.replication</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;</span><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>3</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>10、设置master,&nbsp;s1,&nbsp;s2&nbsp;&nbsp;机几台器之间无密码访问： &nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(网上有许多文章，这里就不写了&nbsp;) &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>11、scp&nbsp;-r&nbsp;/home/hadoop/hadoop&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s1:/home/hadoop &nbsp;</span></li>
  <li class="alt"><span>&nbsp;scp&nbsp;-r&nbsp;/home/hadoop/hadoop&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s2:/home/hadoop &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>12、切换到/home/hadoop/hadoop目录下 &nbsp;</span></li>
  <li><span>执行bin/hadoop&nbsp;namenode&nbsp;-format（格式化master主机生成name&nbsp;data&nbsp;tmp等文件夹） &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>&nbsp;13、启动namenode&nbsp; &nbsp;</span></li>
  <li class="alt"><span>&nbsp;执行&nbsp;bin/start-dfs.sh &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>使用jps命令查看nomenode、secondnamenode是否正常启动： &nbsp;</span></li>
  <li><span>ie里面输入http://master:50070&nbsp;查看namenode的相关配置信息、运行状态和日志文件 &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>14、启动mapred &nbsp;</span></li>
  <li class="alt"><span>执行&nbsp;bin/start-mapred.sh &nbsp;</span></li>
  <li><span>&nbsp;使用jps命令查看nomenode、secondnamenode是否正常启动： &nbsp;</span></li>
  <li class="alt"><span>ie里面输入http://master:50030&nbsp;&nbsp;查看jobtasker的相关配置信息、运行状态和日志文件 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>hbase+zookeeper集群搭建： &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>1、将/home/hadoop/hadoop/conf/目录下的hbase-site.xml、regionserver和hbase-env.sh拷贝到/home/hadoop/hbase-config/目录下； &nbsp;</span></li>
  <li><span>编辑hbase-site.xml配置文件，如下： &nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>hbase.rootdir</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>hdfs://master:9000/hbase</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>hbase.cluster.distributed</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>true</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>hbase.master</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>master</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>hbase.zookeeper.quorum</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>s1,s2</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>zookeeper.session.timeout</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>60000000</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>hbase.zookeeper.property.clientport</span><span class="tag">&lt;/</span><span class="tag-name">name</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span class="tag">&lt;</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>2222</span><span class="tag">&lt;/</span><span class="tag-name">value</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li><span class="tag">&lt;/</span><span class="tag-name">property</span><span class="tag">&gt;</span><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>2、编辑regionserver文件 &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>S1 &nbsp;</span></li>
  <li class="alt"><span>S2 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>3、编辑hbase-env.xml文件 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">JAVA_HOME</span><span>=/usr/java/jdk1.6.0_26/ &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">CLASSPATH</span><span>=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">PATH</span><span>=$JAVA_HOME/bin:$PATH:$CATALINA_HOME/bin &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">HADOOP_HOME</span><span>=/home/hadoop/hadoop &nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">HBASE_HOME</span><span>=/home/hadoop/hbase &nbsp;</span></li>
  <li><span>export&nbsp;</span><span class="attribute">HBASE_MANAGES_ZK</span><span>=</span><span class="attribute-value">true</span><span>&nbsp;</span></li>
  <li class="alt"><span>export&nbsp;</span><span class="attribute">PATH</span><span>=$PATH:/home/hadoop/hbase/bin &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>4、scp&nbsp;-r&nbsp;/home/hadoop/hbase&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s1:/home/hadoop &nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;scp&nbsp;-r&nbsp;/home/hadoop/hbase&nbsp;&nbsp;&nbsp;&nbsp;s2:/home/hadoop &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>5、进入/home/hadoop/zookeeper/conf/中 &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>(1)cp&nbsp;&nbsp;&nbsp;&nbsp;zoo_sample.cfg&nbsp;&nbsp;&nbsp;&nbsp;zoo.cfg &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>(2)vim&nbsp;zoo.cfg,如下： &nbsp;</span></li>
  <li class="alt"><span>&nbsp;</span></li>
  <li><span>#&nbsp;The&nbsp;number&nbsp;of&nbsp;milliseconds&nbsp;of&nbsp;each&nbsp;tick &nbsp;</span></li>
  <li class="alt"><span class="attribute">tickTime</span><span>=</span><span class="attribute-value">2000</span><span>&nbsp;</span></li>
  <li><span>#&nbsp;The&nbsp;number&nbsp;of&nbsp;ticks&nbsp;that&nbsp;the&nbsp;initial &nbsp;</span></li>
  <li class="alt"><span>#&nbsp;synchronization&nbsp;phase&nbsp;can&nbsp;take &nbsp;</span></li>
  <li><span class="attribute">initLimit</span><span>=</span><span class="attribute-value">10</span><span>&nbsp;</span></li>
  <li class="alt"><span>#&nbsp;The&nbsp;number&nbsp;of&nbsp;ticks&nbsp;that&nbsp;can&nbsp;pass&nbsp;between &nbsp;</span></li>
  <li><span>#&nbsp;sending&nbsp;a&nbsp;request&nbsp;and&nbsp;getting&nbsp;an&nbsp;acknowledgement &nbsp;</span></li>
  <li class="alt"><span class="attribute">syncLimit</span><span>=</span><span class="attribute-value">5</span><span>&nbsp;</span></li>
  <li><span>#&nbsp;the&nbsp;directory&nbsp;where&nbsp;the&nbsp;snapshot&nbsp;is&nbsp;stored. &nbsp;</span></li>
  <li class="alt"><span class="attribute">dataDir</span><span>=/home/hadoop/zookeeper/data &nbsp;</span></li>
  <li><span>#&nbsp;the&nbsp;port&nbsp;at&nbsp;which&nbsp;the&nbsp;clients&nbsp;will&nbsp;connect &nbsp;</span></li>
  <li class="alt"><span class="attribute">clientPort</span><span>=</span><span class="attribute-value">2181</span><span>&nbsp;</span></li>
  <li><span class="attribute">server.1</span><span>=</span><span class="attribute-value">s1</span><span>:2888:3888 &nbsp;</span></li>
  <li class="alt"><span class="attribute">server.2</span><span>=</span><span class="attribute-value">s2</span><span>:2888:3888 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>（3）touch&nbsp;myid &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>编辑：1（此序号设置和zoo.cfg里面的server设置要对应) &nbsp;</span></li>
  <li><span>scp&nbsp;-r&nbsp;/home/hadoop/zookeeper&nbsp;&nbsp;&nbsp;s1:/home/hadoop &nbsp;</span></li>
  <li class="alt"><span>scp&nbsp;-r&nbsp;/home/hadoop/zookeeper&nbsp;&nbsp;s2:/home/hadoop &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>（4）在所有的节点执行chown&nbsp;-R&nbsp;hadoop.hadoop&nbsp;/home/hadoop &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>启动hbase集群： &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>（1）/home/hadoop/hbase/bin/start-base.sh &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>（2）执行jps显示Hmaster是否启动 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>（3）执行bin/hbase&nbsp;shell &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;(4)</span><span class="tag">&gt;</span><span>create&nbsp;'t1'&nbsp;t2''&nbsp;'t3'(测试利用hmaster插入数据) &nbsp;</span></li>
  <li><span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="tag">&gt;</span><span>&nbsp;list&nbsp;（显示已经插入的数据） &nbsp;</span></li>
  <li class="alt"><span>&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="tag">&gt;</span><span>t1+t2+t3 &nbsp;</span></li>
  <li><span>&nbsp;</span></li>
  <li class="alt"><span>输入：http://master:60010 &nbsp;</span></li>
 </ol></pre> 
<p><br> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img onload="if(this.width>650) this.width=650;" class="zoom" id="aimg_1" title="QQ截图未命名.png" alt="QQ截图未命名.png" width="600" initialized="true" outfunc="null" status="2" inpost="1" file="data/attachment/forum/201107/25/155106ncc9hsm0ljjckxh4.png" zoomfile="data/attachment/forum/201107/25/155106ncc9hsm0ljjckxh4.png" unselectable="true" src="http://sea.adsit.cn/data/attachment/forum/201107/25/155106ncc9hsm0ljjckxh4.png"></p> 
<div class="tip tip_4 aimg_tip" id="aimg_1_menu" style="z-index: 301; left: 194px; position: absolute; top: 4407px" initialized="true" ctrlkey="aimg_1" mtype="menu" cover="0" fade="false" cache="1" layer="1"> 
 <div class="tip_c xs0"> 
  <div class="y">
   2011-7-25 15:51:06 上传
  </div> 
  <a title="QQ截图未命名.png 下载次数:0" target="_blank" href="http://sea.adsit.cn/forum.php?mod=attachment&amp;aid=MXw0ZGY2OGQ3MHwxMzEyMjcwMDk1fDN8OA%3D%3D&amp;nothumb=yes"><strong>下载附件</strong> <span class="xs0">(10.84 KB)</span></a>
 </div> 
 <div class="tip_horn">
  &nbsp;
 </div> 
</div> 
<p><br> <br> <br> &nbsp;</p>
<p>本文出自 “<a href="http://marysee.blog.51cto.com">mary的博客</a>” 博客，请务必保留此出处<a href="http://marysee.blog.51cto.com/1000292/629405">http://marysee.blog.51cto.com/1000292/629405</a></p>
