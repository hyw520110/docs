<p>在《<a href="http://sstudent.blog.51cto.com/7252708/1381674" target="_blank">hadoop2.0 QJM方式的HA的配置</a>》一文中介绍了HA的配置，是通过手工进行主备切换的。本文在这基础上，继续介绍HA的主备自动切换（automatic failover）的配置。自动切换是通过配置zookeeper来实现的，关于zookeeper的安装和配置，在这里不做介绍了，大家可以参考网上的资料。</p>
<h3>1 准备 &nbsp;</h3>
<p>假定已经有一个zookeeper的集群，3台机器如下：</p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>zookeeper1</p></li>
 <li><p>zookeeper2</p></li>
 <li><p>zookeeper3</p></li>
</ul>
<p>两个namenode节点如下：</p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>namenode1</p></li>
 <li><p>namenode2</p></li>
</ul>
<h3>2 配置 &nbsp;</h3>
<p>只涉及到core-site.xml和hdfs-site.xml两个配置文件，其他配置可以文件参考《<a href="http://sstudent.blog.51cto.com/7252708/1377653" target="_blank">hadoop2.0的安装和基本配置</a>》一文。</p>
<h4>2.1 core-site.xml &nbsp;</h4>
<p>需要增加ha.zookeeper.quorum参数，加上zookeeper的服务地址</p>
<p>完整配置如下：</p>
<pre class="brush:xml;toolbar:false;">&lt;configuration&gt;
        &lt;property&gt;
                &lt;name&gt;fs.defaultFS&lt;/name&gt;
                &lt;value&gt;hdfs://mycluster&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;hadoop.tmp.dir&lt;/name&gt;
                &lt;value&gt;/home/tmp/hadoop2.0&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;ha.zookeeper.quorum&lt;/name&gt;
                &lt;value&gt;zookeeper1:2181,zookeeper2:2181,zookeeper3:2181&lt;/value&gt;
        &lt;/property&gt;
&lt;/configuration&gt;</pre>
<h4>2.2 hdfs-site.xml &nbsp;</h4>
<pre class="brush:xml;toolbar:false;">&lt;configuration&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.replication&lt;/name&gt;
                &lt;value&gt;1&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.name.dir&lt;/name&gt;
                &lt;value&gt;/home/dfs/name&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.datanode.data.dir&lt;/name&gt;
                &lt;value&gt;/home/dfs/data&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.permissions&lt;/name&gt;
                &lt;value&gt;false&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.nameservices&lt;/name&gt;
                &lt;value&gt;mycluster&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.ha.namenodes.mycluster&lt;/name&gt;
                &lt;value&gt;nn1,nn2&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.rpc-address.mycluster.nn1&lt;/name&gt;
                &lt;value&gt;namenode1:8020&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.rpc-address.mycluster.nn2&lt;/name&gt;
                &lt;value&gt;namenode2:8020&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.http-address.mycluster.nn1&lt;/name&gt;
                &lt;value&gt;namenode1:50070&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.http-address.mycluster.nn2&lt;/name&gt;
                &lt;value&gt;namenode2:50070&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.namenode.shared.edits.dir&lt;/name&gt;
                &lt;value&gt;qjournal://journalnode1:8485;journalnode2:8485;journalnode3:8485/mycluster&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.journalnode.edits.dir&lt;/name&gt;
                &lt;value&gt;/home/dfs/journal&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.client.failover.proxy.provider.mycluster&lt;/name&gt;
                &lt;value&gt;org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.ha.fencing.methods&lt;/name&gt;
                &lt;value&gt;shell(/bin/true)&lt;/value&gt;
        &lt;/property&gt;
        &lt;property&gt;
                &lt;name&gt;dfs.ha.automatic-failover.enabled&lt;/name&gt;
                &lt;value&gt;true&lt;/value&gt;
        &lt;/property&gt;
&lt;/configuration&gt;</pre>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>dfs.ha.automatic-failover.enabled </p></li>
</ul>
<p>需要设置为true，启动自动切换。</p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>dfs.ha.fencing.methods</p></li>
</ul>
<p>这里我们把fencing方法设置为shell，一是为了方便测试，二是采用QJM方式的HA本身就有fencing功能，不需要用这个参数中的fencing功能，详解请参考《<a href="http://sstudent.blog.51cto.com/7252708/1381674" target="_blank">hadoop2.0 QJM方式的HA的配置</a>》一文。你用sshfence的方法也是可以的，不过要注意ssh连接的问题和一些权限的问题。</p>
<h3>3 在zookeeper中初始化 &nbsp;</h3>
<pre class="brush:bash;toolbar:false;">$HADOOP_HOME/bin/hdfs zkfc -formatZK</pre>
<p>运行这个命令后，会在zookeeper上创建一个/hadoop-ha/mycluster/的znode，用来存放automatic failover的数据。</p>
<h3>4 启动zkfc(zookeeper failover controller) &nbsp; </h3>
<p>需要在namenode1和namenode2上都启动zkfc daemon进程。</p>
<pre class="brush:bash;toolbar:false;">$HADOOP_HOME/sbin/hadoop-daemon.sh start zkfc</pre>
<h3>5 启动HDFS &nbsp;</h3>
<p>可以参考《<a href="http://sstudent.blog.51cto.com/7252708/1377653" target="_blank">hadoop2.2.0 的安装和基本配置</a>》和《<a href="http://sstudent.blog.51cto.com/7252708/1381674" target="_blank">hadoop2.0 QJM方式的HA的配置</a>》这两篇文章。</p>
<p>在两个namenode都启动之后，会发现，其中一个namenode会自动切换成active状态，不需要手工切换。</p>
<h3>6 测试 &nbsp;</h3>
<p>现在可以享受我们的胜利成果了。我们把active namenode停掉后，会看到standby namenode自动切换成active状态了。</p>
<h3>7 QJM方式HA automatic failover的结构图</h3>
<p>QJM方式HA的结构涉及到active namenode，standby namenode，journalnode，datanode，zookeeper，zkfc，client，这里通过一个图描述他们之间的关系。</p>
<p><a href="http://s3.51cto.com/wyfs02/M00/25/3F/wKiom1NcVi_RWDZiAAJXRRkSiQU224.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/25/3F/wKiom1NcVi_RWDZiAAJXRRkSiQU224.jpg" title="HA_auto_ZK2" alt="wKiom1NcVi_RWDZiAAJXRRkSiQU224.jpg"></a></p>
<h3>8 实战tips &nbsp;</h3>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p>zookeeper可以在hadoop集群中选几台机器同时作为zookeeper节点，给HA私用。</p></li>
 <li><p>在实践中建议采用手工切换的方式，这样更可靠，也方便查找问题。</p></li>
</ul>
<p><br></p>
<h3>参考资料 &nbsp;</h3>
<p><a href="http://hadoop.apache.org/docs/r2.2.0/hadoop-yarn/hadoop-yarn-site/HDFSHighAvailabilityWithQJM.html" target="_blank">http://hadoop.apache.org/docs/r2.2.0/hadoop-yarn/hadoop-yarn-site/HDFSHighAvailabilityWithQJM.html</a></p>
<p><br></p>
<p>本文出自 “<a href="http://sstudent.blog.51cto.com">大数据的自由天空</a>” 博客，请务必保留此出处<a href="http://sstudent.blog.51cto.com/7252708/1388865">http://sstudent.blog.51cto.com/7252708/1388865</a></p>
