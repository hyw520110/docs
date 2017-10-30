<p>Hadoop+zookeepker<span style="font-family:'宋体';">安装与配置</span>:</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">在</span>hadoop-env.sh<span style="font-family:'宋体';">中添加</span>export JAVA<span style="font-family:'宋体';">的环境变量</span></p>
<p><span style="font-family:'宋体';">修改</span>hostname<span style="font-family:'宋体';">文件的名称，</span>/etc/hosts<span style="font-family:'宋体';">文件配置主机名和</span>ip<span style="font-family:'宋体';">的映射关系，将</span>mstaer<span style="font-family:'宋体';">，</span>slave<span style="font-family:'宋体';">的主机名和</span>ip<span style="font-family:'宋体';">地址都添加进来</span></p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">配置</span>ssh<span style="font-family:'宋体';">免密钥配置</span></p>
<p>Ssh-keygen &#xfffd;t rsa</p>
<p><span style="font-family:'宋体';">在</span>./.ssh<span style="font-family:'宋体';">文件中生成两个文件</span>id_rsa<span style="font-family:'宋体';">（私钥），</span>id_rsa.pub(<span style="font-family:'宋体';">公钥</span>)</p>
<p><span style="font-size:13px;font-family:Helvetica, sans-serif;">cat&nbsp;id_rsa.pub&nbsp;</span>&gt;&nbsp;.ssh/authorized_keys</p>
<p><span style="font-size:13px;font-family:Helvetica, sans-serif;">scp authorized_keys user@ipaddress:/home/user/id_rsa.pub</span></p>
<p><span style="font-family:'宋体';">修改</span>authorzed<span style="font-family:'宋体';">文件的权限为</span>600</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>//Namenode<span style="font-family:'宋体';">之间的高可用其实是通过</span>journalNode<span style="font-family:'宋体';">集群或者</span>nfs<span style="font-family:'宋体';">来实现的，两台主从的</span>namenode<span style="font-family:'宋体';">节点通过共享一个共享目录来实现高可用，</span>standy<span style="font-family:'宋体';">的机器时刻同步</span>active<span style="font-family:'宋体';">的</span>namenode<span style="font-family:'宋体';">的机器，</span>namenode<span style="font-family:'宋体';">的自动切换一般使用</span>zookeeper<span style="font-family:'宋体';">集群中来实现</span></p>
<p>&nbsp;</p>
<p>Namenode<span style="font-family:'宋体';">高可用的配置：</span></p>
<p>Core-site.Xml<span style="font-family:'宋体';">添加</span>fs.defaultFS<span style="font-family:'宋体';">的属性为</span>hdfs<span style="font-family:'宋体';">：</span>//mycluster</p>
<p>hdfs-site<span style="font-family:'宋体';">中添加</span>dfs.federation.nameservers<span style="font-family:'宋体';">为</span>mycluster</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-family:'宋体';">添加</span>dfs.namenodes.mycluster<span style="font-family:'宋体';">的值为</span>nn1<span style="font-family:'宋体';">和</span>nn2</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-family:'宋体';">添加</span>dfs.namenode.rpc-address.mycluster.nn1<span style="font-family:'宋体';">的值为</span>hostname1:8020</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-family:'宋体';">添加</span>dfs.namenode.rpc-address.mysqlcluster.nn2<span style="font-family:'宋体';">的值为</span>hostname2<span style="font-family:'宋体';">：</span>8020</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-family:'宋体';">添加</span>dfs.namenode.http-address.mycluster.nn1<span style="font-family:'宋体';">的值为</span>hostname1:50070//<span style="font-family:'宋体';">配置</span>namenode<span style="font-family:'宋体';">节点的</span>web<span style="font-family:'宋体';">查看</span></p>
<p style="text-indent:70px;"><span style="font-family:'宋体';">添加</span>dfs.namenode.http-address.mycluster.nn1<span style="font-family:'宋体';">的值为</span>hostname1:50070</p>
<p style="text-indent:70px;"><span style="font-family:'宋体';">添加</span>dfs.namenode.shared.edits.dir<span style="font-family:'宋体';">共享的存储的目录位置，所有的</span>slave<span style="font-family:'宋体';">端口的</span>8485</p>
<p style="margin-left:7px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="font-family:'宋体';">添加</span>dfs.client.failover.proxy.provider.mycluster<span style="font-family:'宋体';">的值为</span><span style="font-family:'微软雅黑', 'sans-serif';color:#333333;background:#FFFFFF;">org.apache.hadoop.hdfs. server.namenode.ha.ConfigureFailoverProxyProvider&nbsp; //</span><span style="font-family:'微软雅黑', 'sans-serif';color:#333333;background:#FFFFFF;">确认hadoop客户端与active节点通信的java类，使用其来确认active是否活跃</span></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="font-family:'宋体';">添加</span>dfs.ha.fencing.methods<span style="font-family:'宋体';">的值为</span>sshfence<span style="font-family:'宋体';">使用</span>ssh<span style="font-family:'宋体';">来进行切换</span></p>
<p>//<span style="font-family:'宋体';">任何一个期间都必须只有一个</span>namenode<span style="font-family:'宋体';">节点，这个配置使用</span>ssh<span style="font-family:'宋体';">的连接到</span>namenode<span style="font-family:'宋体';">节点杀死</span>namenode<span style="font-family:'宋体';">的</span>active<span style="font-family:'宋体';">状态</span></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">下面是</span>hadoop+zookepper<span style="font-family:'宋体';">的所有配置：</span></p>
<p><span style="font-family:'宋体';">配置</span>hdfs-site.Xml</p>
<p>&lt;configuration&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.replication&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;3&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; //<span style="font-family:'宋体';">将文本复制的份数为</span>3</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;heartbeat.recheckinterval&lt;/name&gt;&nbsp;&nbsp;&nbsp; //datanode<span style="font-family:'宋体';">的心跳时间为</span>10s</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;10&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&lt;name&gt;dfs.name.dir&lt;/name&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>&nbsp;&lt;value&gt;file:/mnt/vdc/hadoopstore/hdfs/name&lt;/value&gt;&nbsp;&nbsp; //<span style="font-family:'宋体';">确定</span>hdfs<span style="font-family:'宋体';">文件系统的元信息保存的目录，设置为多目录的时候，就可以保存元信息数据的多个备份</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.data.dir&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;file:/mnt/vdc/hadoopstore/hdfs/data&lt;/value&gt;&nbsp; //<span style="font-family:'宋体';">确定</span>hdfs<span style="font-family:'宋体';">的文件系统的数据保存的目录，就可以将</span>hdfs<span style="font-family:'宋体';">建立在不同的分区上</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.webhdfs.enabled&lt;/name&gt;&nbsp;&nbsp;&nbsp; //<span style="font-family:'宋体';">在</span>web<span style="font-family:'宋体';">中访问</span>hdfs<span style="font-family:'宋体';">的能力</span></p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;true&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.nameservices&lt;/name&gt;&nbsp;&nbsp;&nbsp;&nbsp; //<span style="font-family:'宋体';">定义一个</span>mycluster<span style="font-family:'宋体';">的</span>nameserver<span style="font-family:'宋体';">族</span></p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;mycluster&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.ha.namenodes.mycluster&lt;/name&gt;&nbsp;&nbsp;&nbsp;&nbsp; //<span style="font-family:'宋体';">支持两个那么</span>namenode<span style="font-family:'宋体';">节点，两个</span>namenode<span style="font-family:'宋体';">节点是</span>nn1<span style="font-family:'宋体';">，</span>nn2<span style="font-family:'宋体';">。</span></p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;nn1,nn2&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp; &lt;name&gt;dfs.namenode.rpc-address.mycluster.nn1&lt;/name&gt;//<span style="font-family:'宋体';">第一个</span>rpc<span style="font-family:'宋体';">的通信地址，端口为</span>8020</p>
<p>&nbsp;&nbsp; &lt;value&gt;master1:8020&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp; &lt;name&gt;dfs.namenode.rpc-address.mycluster.nn2&lt;/name&gt;//<span style="font-family:'宋体';">第二个</span>rpc<span style="font-family:'宋体';">的通信地址，端口为</span>8020</p>
<p>&nbsp;&nbsp; &lt;value&gt;master2:8020&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.namenode.http-address.mycluster.nn1&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:50070&lt;/value&gt;&nbsp;&nbsp; //<span style="font-family:'宋体';">定义第二个</span>namenode<span style="font-family:'宋体';">的</span>http<span style="font-family:'宋体';">端口</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.namenode.http-address.mycluster.nn2&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;master2:50070&lt;/value&gt;&nbsp;&nbsp; //<span style="font-family:'宋体';">定义第二个</span>namenode<span style="font-family:'宋体';">的</span>httpd<span style="font-family:'宋体';">端口</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.namenode.shared.edits.dir&lt;/name&gt;&nbsp;&nbsp;&nbsp;&lt;value&gt;qjournal://master1:8485;master2:8485;slave1:8485;slave2:8485;slave3:8485;slave4:8485;slave5:8485;slave6:8485;slave7:8485;slave8:8485;slave9:8485;slave10:8485/mycluster&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;&nbsp;&nbsp; //<span style="font-family:'宋体';">共享的</span>datanode<span style="font-family:'宋体';">信息</span></p>
<p>//<span style="font-family:'宋体';">客户端故障转移配置</span></p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.client.failover.proxy.provider.mycluster&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;&nbsp; //<span style="font-family:'宋体';">自动切换的时候由哪一个类来自动实现</span></p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.ha.fencing.methods&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;sshfence&lt;/value&gt;//namenode//<span style="font-family:'宋体';">切换时候使用</span>ssh<span style="font-family:'宋体';">等方式来操作</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.ha.fencing.ssh.private-key-files&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;/home/kduser/.ssh/id_rsa&lt;/value&gt;//<span style="font-family:'宋体';">存储的秘钥的位置</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.ha.automatic-failover.enabled&lt;/name&gt;&nbsp; //???<span style="font-family:'宋体';">是否需要加上</span>mycluster<span style="font-family:'宋体';">，故障发生的时候是否自动切换</span></p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;true&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;//<span style="font-family:'宋体';">将这个</span>namenode<span style="font-family:'宋体';">节点</span>id<span style="font-family:'宋体';">配置为</span>nn1</p>
<p>&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.ha.namenode.id&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;nn1&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&lt;/configuration&gt;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">配置</span>mapred-site.xml<span style="font-family:'宋体';">文件</span></p>
<p>&lt;configuration&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&lt;name&gt;mapreduce.framework.name&lt;/name&gt;</p>
<p>&nbsp;&lt;value&gt;yarn&lt;/value&gt;&nbsp;//hadoop2.x<span style="font-family:'宋体';">以后的版本的框架为</span>yarn</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&lt;name&gt;mapreduce.reduce.shuffle.input.buffer.percent&lt;/name&gt;//<span style="font-family:'宋体';">默认为</span>0.7<span style="font-family:'宋体';">，提高系统系统配置</span></p>
<p>&nbsp;&lt;value&gt;0.1&lt;value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;/configuration&gt;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">配置</span>yarn-site.xml</p>
<p>&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.nodemanager.resource.memory-mb&lt;/name&gt;//nodemanager<span style="font-family:'宋体';">总的可用的物理内存</span></p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;10240&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&lt;name&gt;yarn.resourcemanager.address&lt;/name&gt;</p>
<p>//<tt><span style="font-size:12px;background:rgb(247,243,237);">ResourceManager</span></tt><span style="font-family:'Lucida Sans Unicode', sans-serif;background:rgb(247,243,237);">&nbsp;</span><span style="font-size:12px;font-family:'宋体';background:rgb(247,243,237);">对客户端暴露的地址。客户端通过该地址向</span><span style="font-size:12px;font-family:'Lucida Sans Unicode', sans-serif;background:rgb(247,243,237);">RM</span><span style="font-size:12px;font-family:'宋体';background:rgb(247,243,237);">提交应用程序，杀死应用程序等</span></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:8032&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.nodemanager.disk-health-checker.max-disk-utilization-per-disk-percentage&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;95.0&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.resourcemanager.scheduler.address&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:8030&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.resourcemanager.resource-tracker.address&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:8031&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.nodemanager.aux-services&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;mapreduce_shuffle&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.resourcemanager.admin.address&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:8033&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.nodemanager.aux-services.mapreduce.shuffle.class&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;value&gt;org.apache.hadoop.mapred.ShuffleHandler&lt;/value&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;yarn.resourcemanager.webapp.address&lt;/name&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:8088&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">配置</span>core-site.xml<span style="font-family:'宋体';">的配置</span></p>
<p>&lt;configuration&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.native.lib&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;true&lt;/value&gt;</p>
<p style="text-indent:28px;">&lt;description&gt;Shouldnative hadoop libraries, if present, be used.&lt;/description&gt;</p>
<p style="text-indent:28px;">//<span style="font-family:'宋体';">设置启动本地库，默认使用本地库</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&lt;!--</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;fs.default.name&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;hdfs://0.0.0.0:9000&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp; //namenode<span style="font-family:'宋体';">节点的</span>url</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>--&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.tmp.dir&lt;/name&gt;</p>
<p>&nbsp;&lt;value&gt;/mnt/vdc/hadoopstore/tmp&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp; //hdfs<span style="font-family:'宋体';">的临时文件目录</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;fs.defaultFS&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;hdfs://mycluster&lt;/value&gt; //<span style="font-family:'宋体';">指定</span>hdfs<span style="font-family:'宋体';">的</span>nameservice<span style="font-family:'宋体';">为</span>mycluster<span style="font-family:'宋体';">（两个），为</span>hadoop<span style="font-family:'宋体';">的</span>namenode<span style="font-family:'宋体';">节点高可用的配置</span></p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.journalnode.edits.dir&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;/mnt/vdc/hadoopstore/journal/data&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;ha.zookeeper.quorum.mycluster&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;master1:2181,master2:2181,slave1:2181&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.proxyuser.oozie.hosts&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;*&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.proxyuser.oozie.groups&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;*&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.proxyuser.hue.hosts&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;*&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&nbsp;&lt;property&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;name&gt;hadoop.proxyuser.hue.groups&lt;/name&gt;</p>
<p>&nbsp;&nbsp;&nbsp;&lt;value&gt;*&lt;/value&gt;</p>
<p>&nbsp;&lt;/property&gt;</p>
<p>&lt;/configuration&gt;</p>
<p>&nbsp;</p>
<p><span style="font-family:'宋体';">第一次启动的时候需要格式化</span> hadoop &nbsp;namenode &nbsp;&#xfffd;format</p>
<p><span style="font-family:'宋体';">查看集群状态的时候使用</span>jps<span style="font-family:'宋体';">来进行查看</span></p>
<p>Hadoop dfsadmin -report</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>Zookeeper<span style="font-family:'宋体';">命令详解：</span></p>
<p><span style="font-family:'宋体';">配置基本的环境变量：</span></p>
<p>export&nbsp;ZOOKEEPER_HOME=/home/zookeeper-3.3.3</p>
<p>export&nbsp;PATH=$PATH:$ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/conf</p>
<p>zookeeper<span style="font-family:'宋体';">配置文件</span>zoo.cfg</p>
<p>tickTime=2000&nbsp; //<span style="font-family:'宋体';">默认每两秒就会发送一个心跳</span></p>
<p>dataDir=/diskl/zookeeper&nbsp; //<span style="font-family:'宋体';">存储内存中数据库快照的位置</span></p>
<p>dataLogDir=/disk2/zookeeper&nbsp; //<span style="font-family:'宋体';">日记存放的目录</span></p>
<p>clientPort=2181</p>
<p>initlimit=5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; //<span style="font-family:'宋体';">连接超时的心跳次数，这里</span>5<span style="font-family:'宋体';">次就是说</span>10s<span style="font-family:'宋体';">的时候就会退出</span></p>
<p>syncLimit=2&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>server.l=zookeeperl:2888:3888&nbsp;</p>
<p>server.2=zookeeper2:2888:3888&nbsp;</p>
<p>server.3=zookeeper3:2888:3888&nbsp;</p>
<p>&nbsp;</p>
<p>zookeeper<span style="font-family:'宋体';">的</span>2181<span style="font-family:'宋体';">端口用于与客户端连接，</span>2888<span style="font-family:'宋体';">端口用于与跟随者连接，</span>3888<span style="font-family:'宋体';">端口用于选举</span></p>
<p><span style="font-family:'宋体';">修改</span>myid<span style="font-family:'宋体';">文件，这个文件在</span>dataDir<span style="font-family:'宋体';">文件中配置为</span>1<span style="font-family:'宋体';">，</span>2<span style="font-family:'宋体';">，</span>3</p>
<p>&nbsp;</p>
<p>ZkServer.sh start/stop/status&nbsp; <span style="font-family:'宋体';">启动</span>/<span style="font-family:'宋体';">关闭</span>/<span style="font-family:'宋体';">状态</span></p>
<p>zkCLi.sh &#xfffd;serveripaddress:2181&nbsp;&nbsp; //<span style="font-family:'宋体';">连接某台的</span>zookeeper<span style="font-family:'宋体';">服务器</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
<p><span style="font-family:'宋体';">使用</span>ls&nbsp; /<span style="font-family:'宋体';">查看</span><span style="font-family:'宋体';">节点中的内容</span></p>
<p>get&nbsp; /xxxx<span style="font-family:'宋体';">查看字符串里面的内容</span></p>
<p>set/create/deletexxx <span style="font-family:'宋体';">设置</span>/<span style="font-family:'宋体';">创建</span>/<span style="font-family:'宋体';">删除节点的内容</span></p>
<p><span style="font-family:'宋体';">但是</span>zookeeper<span style="font-family:'宋体';">主要是使用</span>api<span style="font-family:'宋体';">的形式来进行访问的</span></p>
<p><br></p>
<p>本文出自 “<a href="http://gdutccd.blog.51cto.com">东神要一打五</a>” 博客，谢绝转载！</p>
