<p>Hadoop部署</p>
<p><br></p>
<p>1. 安装完全分布式Hadoop</p>
<p><br></p>
<p>1.1 安装准备工作</p>
<p><br></p>
<p>1.1.1 规划&nbsp;</p>
<p>本安装示例将使用六台服务器(CentOS 6.5 64bit)来实现，其规划如下所示：</p>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IP地址&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;主机名&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;运行的进程或扮演的角色
192.168.40.30&nbsp;&nbsp;master.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NameNode,JobTracker,Hive,Hbase
192.168.40.31&nbsp;&nbsp;snn.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SecondaryNameNode
192.168.40.32&nbsp;&nbsp;datanode-1.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;DataNode,TaskTracker,zookeeper,regionserver
192.168.40.33&nbsp;&nbsp;datanode-2.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;DataNode,TaskTracker,zookeeper,regionserver
192.168.40.35&nbsp;&nbsp;datanode-3.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;DataNode,TaskTracker,zookeeper,regionserver
192.168.40.34&nbsp;&nbsp;mysql.dbq168.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MySQL</pre>
<p><br></p>
<p>1.1.2 版本说明：</p>
<p>用到的应用程序：</p>
<pre class="brush:bash;toolbar:false">CentOS&nbsp;&nbsp;&nbsp;release&nbsp;6.5&nbsp;(Final)
kernel:&nbsp;&nbsp;2.6.32-431.el6.x86_64
JDK:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;jdk-7u45-linux-x64.gz
Hadoop：&nbsp;hadoop-2.6.1.tar.gz
Hive:&nbsp;&nbsp;&nbsp;&nbsp;apache-hive-1.2.1-bin.tar.gz
Hbase:&nbsp;&nbsp;&nbsp;hbase-1.1.2-bin.tar.gz
zookeeper:zookeeper-3.4.6.tar.gz</pre>
<p><br></p>
<p>1.1.3 hosts文件：</p>
<p>设置集群各节点的/etc/hosts文件内容如下：</p>
<pre class="brush:bash;toolbar:false">192.168.40.30&nbsp;&nbsp;&nbsp;master&nbsp;master.dbq168.com
192.168.40.31&nbsp;&nbsp;&nbsp;snn&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;snn.dbq168.com
192.168.40.32&nbsp;&nbsp;&nbsp;datanode-1&nbsp;datanode-1.dbq168.com
192.168.40.33&nbsp;&nbsp;&nbsp;datanode-2&nbsp;datanode-2.dbq168.com
192.168.40.35&nbsp;&nbsp;&nbsp;datanode-3&nbsp;datanode-3.dbq168.com
192.168.40.34&nbsp;&nbsp;&nbsp;mysql&nbsp;&nbsp;&nbsp;mysql.dbq168.com</pre>
<p><br></p>
<p>1.1.4 SSH免密码登陆</p>
<p>主要是为了方便管理，或者可以使用自动化管理工具，如ansible等；</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;ssh-keygen&nbsp;-t&nbsp;rsa&nbsp;-P&nbsp;''
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@master
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@snn
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@datanode-1
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@datanode-2
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@datanode-3
[root@master&nbsp;~]#&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;root@mysql</pre>
<p><br></p>
<p>先在集群中的每个节点上建立运行hadoop进程的用户hadoop并给其设定密码。</p>
<pre class="brush:bash;toolbar:false">#&nbsp;useradd&nbsp;hadoop
#&nbsp;echo&nbsp;"hadoop"&nbsp;|&nbsp;passwd&nbsp;--stdin&nbsp;hadoop&nbsp;
[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;"useradd&nbsp;hadoop&nbsp;&amp;&amp;&nbsp;echo&nbsp;'hadoop'|passwd&nbsp;--stdin&nbsp;hadoop";done</pre>
<p><br></p>
<p><br></p>
<p>而后配置master节点的hadoop用户能够以基于密钥的验正方式登录其它各节点，以便启动进程并执行监控等额外的管理工作。以下命令在master节点上执行即可。</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;su&nbsp;-&nbsp;hadoop
[hadoop@master&nbsp;~]$&nbsp;ssh-keygen&nbsp;-t&nbsp;rsa&nbsp;-P&nbsp;''&nbsp;
[hadoop@master&nbsp;~]$&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;hadoop@datanode-1
[hadoop@master&nbsp;~]$&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;hadoop@datanode-2
[hadoop@master&nbsp;~]$&nbsp;ssh-copy-id&nbsp;-i&nbsp;.ssh/id_rsa.pub&nbsp;hadoop@snn
......</pre>
<p><br></p>
<p>测试执行命令：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;ssh&nbsp;snn&nbsp;'ls&nbsp;/home/hadoop/&nbsp;-la'&nbsp;
[hadoop@master&nbsp;~]$&nbsp;ssh&nbsp;datanode&nbsp;'ls&nbsp;/home/hadoop/&nbsp;-la'</pre>
<p><br></p>
<p>1.2 安装JDK</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;scp&nbsp;jdk-7u45-linux-x64.gz&nbsp;192.168.40.$i:/usr/local/;done
[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;'tar&nbsp;-xf&nbsp;/usr/local/jdk-7u45-linux-x64.gz&nbsp;-C&nbsp;/usr/local/';done
[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;'ln&nbsp;-sv&nbsp;/usr/local/jdk-7u45-linux-x64&nbsp;/usr/local/java';done</pre>
<p>编辑/etc/profile.d/java.sh，在文件中添加如下内容：</p>
<pre class="brush:bash;toolbar:false">JAVA_HOME=/usr/local/java/
PATH=$JAVA_HOME/bin:$PATH
export&nbsp;JAVA_HOME&nbsp;PATH</pre>
<p>复制变量文件到其他节点：</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;scp&nbsp;/etc/profile.d/java.sh&nbsp;192.168.40.$i:/etc/profile.d/;done</pre>
<p><br></p>
<p>切换至hadoop用户，并执行如下命令测试jdk环境配置是否就绪。</p>
<pre class="brush:bash;toolbar:false">#&nbsp;su&nbsp;-&nbsp;hadoop
$&nbsp;java&nbsp;-version
java&nbsp;version&nbsp;"1.7.0_45"
Java(TM)&nbsp;SE&nbsp;Runtime&nbsp;Environment&nbsp;(build&nbsp;1.7.0_45-b18)
Java&nbsp;HotSpot(TM)&nbsp;64-Bit&nbsp;Server&nbsp;VM&nbsp;(build&nbsp;24.45-b08,&nbsp;mixed&nbsp;mode)</pre>
<p><br></p>
<p>1.3 安装Hadoop</p>
<p>Hadoop通常有三种运行模式：本地(独立)模式、伪分布式(Pseudo-distributed)模式和完全分布式(Fully distributed)模式。</p>
<p>&nbsp; &nbsp; 本地模式，也是Hadoop的默认模式，此时hadoop使用本地文件系统而非分布式文件系统，而且也不会启动任何hadoop相关进程，map和reduce都作为同一进程的不同部分来执行。因此本地模式下的hadoop仅运行于本机，适合开发调试map reduce应用程序但却避免复杂的后续操作；</p>
<p>&nbsp; &nbsp; 伪分布式模式：Hadoop将所有进程运行于同一个主机，但此时Hadoop将使用分布式文件系统，而且各Job也是由Jobtracker服务管理的独立进程；同时伪分布式的hadoop集群只有一个节点，因此HDFS的块复制将限制为单个副本，其中Secondary-master和slave也都将运行于本机。 这种模式除了并非真正意义上的分布式以外，其程序执行逻辑完全类似于分布式，因此常用于开发人员测试程序执行；</p>
<p>&nbsp; &nbsp; 完全分布式：能真正发挥Hadoop的威力，由于Zookeeper实现高可用依赖于基数法定票数(an odd-numbered quorum),因此，完全分布式环境至少需要三个节点。</p>
<p><br></p>
<p>本文档采用完全分布式模式安装。</p>
<p><br></p>
<p>集群中的每个节点均需要安装Hadoop，以根据配置或需要启动相应的进程等，因此，以下安装过程需要在每个节点上分别执行。</p>
<pre class="brush:bash;toolbar:false">#&nbsp;tar&nbsp;xf&nbsp;hadoop-2.6.1.tar.gz&nbsp;-C&nbsp;/usr/local
#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;'chown&nbsp;hadoop.hadoop&nbsp;-R&nbsp;/usr/local/hadoop-2.6.1';done
#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;'ln&nbsp;-sv&nbsp;/usr/local/hadoop-2.6.1&nbsp;/usr/local/hadoop';done</pre>
<p><br></p>
<p>Master上执行：</p>
<p>然后编辑/etc/profile，设定HADOOP_HOME环境变量的值为hadoop的解压目录，并让其永久有效。编辑/etc/profile.d/hadoop.sh，添加如下内容：</p>
<pre class="brush:bash;toolbar:false">HADOOP_HOME=/usr/local/hadoop
PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export&nbsp;HADOOP_BASE&nbsp;PATH</pre>
<p><br></p>
<p>切换至hadoop用户，并执行如下命令测试jdk环境配置是否就绪。</p>
<pre class="brush:bash;toolbar:false">$&nbsp;hadoop&nbsp;version
Hadoop&nbsp;2.6.1
Subversion&nbsp;https://git-wip-us.apache.org/repos/asf/hadoop.git&nbsp;-r&nbsp;b4d876d837b830405ccdb6af94742f99d49f9c04
Compiled&nbsp;by&nbsp;jenkins&nbsp;on&nbsp;2015-09-16T21:07Z
Compiled&nbsp;with&nbsp;protoc&nbsp;2.5.0
From&nbsp;source&nbsp;with&nbsp;checksum&nbsp;ba9a9397365e3ec2f1b3691b52627f
This&nbsp;command&nbsp;was&nbsp;run&nbsp;using&nbsp;/usr/local/hadoop-2.6.1/share/hadoop/common/hadoop-common-2.6.1.jar</pre>
<p><br></p>
<p><br></p>
<p>1.4 配置Hadoop</p>
<p><br></p>
<p>集群中的每个节点上Hadoop的配置均相同，Hadoop在启动时会根据配置文件判定当前节点的角色及所需要运行的进程等，因此，下述的配置文件修改需要在每一个节点上运行。</p>
<p><br></p>
<p>(1) 修改core-site.xml内容如下</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;cd&nbsp;/usr/local/hadoop/etc/hadoop/
[hadoop@master&nbsp;hadoop]$&nbsp;vim&nbsp;core-site.xml
&lt;?xml&nbsp;version="1.0"?&gt;
&lt;?xml-stylesheet&nbsp;type="text/xsl"&nbsp;href="configuration.xsl"?&gt;
&lt;!--&nbsp;Put&nbsp;site-specific&nbsp;property&nbsp;overrides&nbsp;in&nbsp;this&nbsp;file.&nbsp;--&gt;
&lt;configuration&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;fs.default.name&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;hdfs://master.dbq168.com:8020&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;final&gt;true&lt;/final&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;name&nbsp;of&nbsp;the&nbsp;default&nbsp;file&nbsp;system.&nbsp;A&nbsp;URI&nbsp;whose&nbsp;scheme&nbsp;and&nbsp;authority&nbsp;determine&nbsp;the&nbsp;FileSystem&nbsp;implimentation.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&lt;/configuration&gt;</pre>
<p><br></p>
<p>(2)修改mapred-site.xml文件为如下内容</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;cd&nbsp;/usr/local/hadoop/etc/hadoop/
[hadoop@master&nbsp;hadoop]$&nbsp;cp&nbsp;mapred-site.xml.template&nbsp;mapred-site.xml
&lt;?xml&nbsp;version="1.0"?&gt;
&lt;?xml-stylesheet&nbsp;type="text/xsl"&nbsp;href="configuration.xsl"?&gt;
&lt;configuration&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;mapred.job.tracker&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;master.dbq168.com:8021&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;final&gt;true&lt;/final&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;host&nbsp;and&nbsp;port&nbsp;that&nbsp;the&nbsp;MapReduce&nbsp;JobTracker&nbsp;runs&nbsp;at.&nbsp;&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&lt;/configuration&gt;</pre>
<p>(3) 修改hdfs-site.xml文件为如下内容&nbsp;</p>
<pre class="brush:bash;toolbar:false;">[hadoop@master&nbsp;hadoop]$&nbsp;cd&nbsp;/usr/local/hadoop/etc/hadoop
&lt;configuration&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.replication&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;3&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;actual&nbsp;number&nbsp;of&nbsp;replications&nbsp;can&nbsp;be&nbsp;specified&nbsp;when&nbsp;the&nbsp;file&nbsp;is&nbsp;created.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.data.dir&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;/hadoop/data&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;final&gt;ture&lt;/final&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;directories&nbsp;where&nbsp;the&nbsp;datanode&nbsp;stores&nbsp;blocks.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.name.dir&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;/hadoop/name&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;final&gt;ture&lt;/final&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;directories&nbsp;where&nbsp;the&nbsp;namenode&nbsp;stores&nbsp;its&nbsp;persistent&nbsp;matadata.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;fs.checkpoint.dir&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;/hadoop/namesecondary&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;final&gt;ture&lt;/final&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;directories&nbsp;where&nbsp;the&nbsp;secondarynamenode&nbsp;stores&nbsp;checkpoints.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&lt;/configuration&gt;</pre>
<p><br></p>
<p><br></p>
<p>说明：根据此配置，需要事先在各节点上创建/hadoop/，并让hadoop用户对其具有全部权限。也可以不指定最后三个属性，让Hadoop为其使用默认位置。</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;~]#&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;ssh&nbsp;192.168.40.$i&nbsp;'mkdir&nbsp;/hadoop/{name,data,namesecondary}&nbsp;-pv;&nbsp;chown&nbsp;-R&nbsp;hadoop.hadoop&nbsp;-R&nbsp;/hadoop';done</pre>
<p><br></p>
<p>(4)指定SecondaryNameNode节点的主机名或IP地址，本示例中为如下内容：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>hadoop从2.2.0以后就没有masters文件了，更改需要在hdfs-site.xml里写下本例中的：</p>
<pre class="brush:bash;toolbar:false">&lt;property&gt;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;dfs.secondary.http.address&lt;/name&gt;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;snn:50090&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;NameNode&nbsp;get&nbsp;the&nbsp;newest&nbsp;fsimage&nbsp;via&nbsp;dfs.secondary.http.address&lt;/description&gt;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</pre>
<p><br></p>
<p><br></p>
<p>(5)修改/usr/local/hadoop/etc/hadoop/slaves文件，指定各DataNode节点的主机名或IP地址，本示例中只有一个DataNode：</p>
<pre class="brush:bash;toolbar:false">datanode-1
datanode-2
datanode-3</pre>
<p><br></p>
<p>(6)初始化数据节点，在master上执行如下命令</p>
<pre class="brush:bash;toolbar:false">$&nbsp;hadoop&nbsp;namenode&nbsp;-format</pre>
<p><br></p>
<p>(7)copy文件到两个节点:</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;hadoop]$&nbsp;for&nbsp;i&nbsp;in&nbsp;30&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;scp&nbsp;mapred-site.xml&nbsp;core-site.xml&nbsp;slaves&nbsp;yarn-site.xml&nbsp;hdfs-site.xml&nbsp;192.168.40.$i:/usr/local/hadoop/etc/hadoop/;done</pre>
<p><br></p>
<p>1.5 启动Hadoop</p>
<p><br></p>
<p>在master节点上执行Hadoop的start-all.sh脚本即可实现启动整个集群。</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;start-all.sh</pre>
<p>其输出内容如下所示：</p>
<pre class="brush:bash;toolbar:false">starting&nbsp;namenode,&nbsp;logging&nbsp;to&nbsp;/usr/local/hadoop/logs/hadoop-hadoop-namenode-master.dbq168.com.out
datanode.dbq168.com:&nbsp;starting&nbsp;datanode,&nbsp;logging&nbsp;to&nbsp;/usr/local/hadoop/logs/hadoop-hadoop-datanode-datanode.dbq168.com.out
snn.dbq168.com:&nbsp;starting&nbsp;secondarynamenode,&nbsp;logging&nbsp;to&nbsp;/usr/local/hadoop/logs/hadoop-hadoop-secondarynamenode-node3.dbq168.com.out
starting&nbsp;jobtracker,&nbsp;logging&nbsp;to&nbsp;/usr/local/hadoop/logs/hadoop-hadoop-jobtracker-master.dbq168.com.out
datanode.dbq168.com:&nbsp;starting&nbsp;tasktracker,&nbsp;logging&nbsp;to&nbsp;/usr/local/hadoop/logs/hadoop-hadoop-tasktracker-datanode.dbq168.com.out</pre>
<p><br></p>
<p>如果要停止Hadoop的各进程，则使用stop-all.sh脚本即可。</p>
<p><br></p>
<p>不过，在一个较大规模的集群环境中，NameNode节点需要在内在中维护整个名称空间中的文件和块的元数据信息，因此，其有着较大的内在需求；而在运行着众多MapReduce任务的环境中，JobTracker节点会用到大量的内存和CPU资源，因此，此场景中通常需要将NameNode和JobTracker运行在不同的物理主机上，这也意味着HDFS集群的主从节点与MapReduce的主从节点将分属于不同的拓扑。启动HDFS的主从进程则需要在NameNode节点上使用start-dfs.sh脚本，而启动MapReduce的各进程则需要在JobTracker节点上通过start-mapred.sh脚本进行。这两个脚本事实上都是通过hadoop-daemons.sh脚本来完成进程启动的。</p>
<p><br></p>
<p><br></p>
<p>1.6 管理JobHistory Server</p>
<p><br></p>
<p>启动可以JobHistory Server，能够通过Web控制台查看集群计算的任务的信息，执行如下命令：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;logs]$&nbsp;/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh&nbsp;start&nbsp;historyserver</pre>
<p><br></p>
<p>默认使用19888端口。</p>
<p>通过访问http://master:19888/查看任务执行历史信息。</p>
<p>终止JobHistory Server，执行如下命令：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;logs]$&nbsp;/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh&nbsp;stop&nbsp;historyserver</pre>
<p>1.7 检查</p>
<p>Master:</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;hadoop]$&nbsp;jps
14846&nbsp;NameNode
15102&nbsp;ResourceManager
15345&nbsp;Jps
12678&nbsp;JobHistoryServer</pre>
<p>DataNode：</p>
<pre class="brush:bash;toolbar:false">[hadoop@datanode&nbsp;~]$&nbsp;jps
12647&nbsp;Jps
12401&nbsp;DataNode
12523&nbsp;NodeManager</pre>
<p>SecondaryNode:</p>
<pre class="brush:bash;toolbar:false">[hadoop@snn&nbsp;~]$&nbsp;jps
11980&nbsp;SecondaryNameNode
12031&nbsp;Jps</pre>
<pre class="brush:bash;toolbar:false">#查看服务器监听端口:
[hadoop@master&nbsp;~]$&nbsp;netstat&nbsp;-tunlp&nbsp;|grep&nbsp;java
(Not&nbsp;all&nbsp;processes&nbsp;could&nbsp;be&nbsp;identified,&nbsp;non-owned&nbsp;process&nbsp;info
&nbsp;will&nbsp;not&nbsp;be&nbsp;shown,&nbsp;you&nbsp;would&nbsp;have&nbsp;to&nbsp;be&nbsp;root&nbsp;to&nbsp;see&nbsp;it&nbsp;all.)
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;192.168.40.30:8020&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1294/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;0.0.0.0:50070&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1294/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8088&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1551/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8030&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1551/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8031&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1551/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:16000&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2008/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8032&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1551/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8033&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1551/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;:::16010&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2008/java</pre>
<p>用浏览器打开：</p>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;http://master:8088&nbsp;&nbsp;&nbsp;#查看、配置集群信息
&nbsp;&nbsp;&nbsp;&nbsp;http://master:50070&nbsp;&nbsp;#类似于Hadoop的一个dashboard</pre>
<p><br></p>
<p>1.8 测试Hadoop</p>
<p>&nbsp; &nbsp; Hadoop提供了MapReduce编程框架，其并行处理能力的发挥需要通过开发Map及Reduce程序实现。为了便于系统测试，Hadoop提供了一个单词统计的应用程序算法样例，其位于Hadoop安装目录下${HADOOP_BASE}/share/hadoop/mapreduce/名称类似hadoop-examples-*.jar的文件中。除了单词统计，这个jar文件还包含了分布式运行的grep等功能的实现，这可以通过如下命令查看。 &nbsp; &nbsp;</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;hadoop&nbsp;jar&nbsp;/usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.1.jar&nbsp;
An&nbsp;example&nbsp;program&nbsp;must&nbsp;be&nbsp;given&nbsp;as&nbsp;the&nbsp;first&nbsp;argument.
Valid&nbsp;program&nbsp;names&nbsp;are:
&nbsp;&nbsp;aggregatewordcount:&nbsp;An&nbsp;Aggregate&nbsp;based&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.
&nbsp;&nbsp;aggregatewordhist:&nbsp;An&nbsp;Aggregate&nbsp;based&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;computes&nbsp;the&nbsp;histogram&nbsp;of&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.
&nbsp;&nbsp;bbp:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;uses&nbsp;Bailey-Borwein-Plouffe&nbsp;to&nbsp;compute&nbsp;exact&nbsp;digits&nbsp;of&nbsp;Pi.
&nbsp;&nbsp;dbcount:&nbsp;An&nbsp;example&nbsp;job&nbsp;that&nbsp;count&nbsp;the&nbsp;pageview&nbsp;counts&nbsp;from&nbsp;a&nbsp;database.
&nbsp;&nbsp;distbbp:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;uses&nbsp;a&nbsp;BBP-type&nbsp;formula&nbsp;to&nbsp;compute&nbsp;exact&nbsp;bits&nbsp;of&nbsp;Pi.
&nbsp;&nbsp;grep:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;matches&nbsp;of&nbsp;a&nbsp;regex&nbsp;in&nbsp;the&nbsp;input.
&nbsp;&nbsp;join:&nbsp;A&nbsp;job&nbsp;that&nbsp;effects&nbsp;a&nbsp;join&nbsp;over&nbsp;sorted,&nbsp;equally&nbsp;partitioned&nbsp;datasets
&nbsp;&nbsp;multifilewc:&nbsp;A&nbsp;job&nbsp;that&nbsp;counts&nbsp;words&nbsp;from&nbsp;several&nbsp;files.
&nbsp;&nbsp;pentomino:&nbsp;A&nbsp;map/reduce&nbsp;tile&nbsp;laying&nbsp;program&nbsp;to&nbsp;find&nbsp;solutions&nbsp;to&nbsp;pentomino&nbsp;problems.
&nbsp;&nbsp;pi:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;estimates&nbsp;Pi&nbsp;using&nbsp;a&nbsp;quasi-Monte&nbsp;Carlo&nbsp;method.
&nbsp;&nbsp;randomtextwriter:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;writes&nbsp;10GB&nbsp;of&nbsp;random&nbsp;textual&nbsp;data&nbsp;per&nbsp;node.
&nbsp;&nbsp;randomwriter:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;writes&nbsp;10GB&nbsp;of&nbsp;random&nbsp;data&nbsp;per&nbsp;node.
&nbsp;&nbsp;secondarysort:&nbsp;An&nbsp;example&nbsp;defining&nbsp;a&nbsp;secondary&nbsp;sort&nbsp;to&nbsp;the&nbsp;reduce.
&nbsp;&nbsp;sort:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;sorts&nbsp;the&nbsp;data&nbsp;written&nbsp;by&nbsp;the&nbsp;random&nbsp;writer.
&nbsp;&nbsp;sudoku:&nbsp;A&nbsp;sudoku&nbsp;solver.
&nbsp;&nbsp;teragen:&nbsp;Generate&nbsp;data&nbsp;for&nbsp;the&nbsp;terasort
&nbsp;&nbsp;&nbsp;terasort:&nbsp;Run&nbsp;the&nbsp;terasort
&nbsp;&nbsp;teravalidate:&nbsp;Checking&nbsp;results&nbsp;of&nbsp;terasort
&nbsp;&nbsp;wordcount:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.
&nbsp;&nbsp;wordmean:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;average&nbsp;length&nbsp;of&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.
&nbsp;&nbsp;wordmedian:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;median&nbsp;length&nbsp;of&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.
&nbsp;&nbsp;wordstandarddeviation:&nbsp;A&nbsp;map/reduce&nbsp;program&nbsp;that&nbsp;counts&nbsp;the&nbsp;standard&nbsp;deviation&nbsp;of&nbsp;the&nbsp;length&nbsp;of&nbsp;the&nbsp;words&nbsp;in&nbsp;the&nbsp;input&nbsp;files.</pre>
<p>&nbsp;</p>
<p>下面我们用wordcount来计算单词显示数量:</p>
<p>在HDFS的wc-in目录中存放两个测试文件，而后运行wordcount程序实现对这两个测试文件中各单词出现次数进行统计的实现过程。首先创建wc-in目录，并复制文件至HDFS文件系统中。</p>
<pre class="brush:bash;toolbar:false">$&nbsp;hadoop&nbsp;fs&nbsp;-mkdir&nbsp;wc-in
$&nbsp;hadoop&nbsp;fs&nbsp;-put&nbsp;/etc/rc.d/init.d/functions&nbsp;/etc/profile&nbsp;wc-in</pre>
<p><br></p>
<p>接下来启动分布式任务，其中的WC-OUT为reduce任务执行结果文件所在的目录，此目标要求事先不能存在，否则运行将会报错。</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;hadoop&nbsp;jar&nbsp;/usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.1.jar&nbsp;wordcount&nbsp;wc-in&nbsp;WC-OUT
15/11/05&nbsp;15:18:59&nbsp;INFO&nbsp;Configuration.deprecation:&nbsp;session.id&nbsp;is&nbsp;deprecated.&nbsp;Instead,&nbsp;use&nbsp;dfs.metrics.session-id
15/11/05&nbsp;15:18:59&nbsp;INFO&nbsp;jvm.JvmMetrics:&nbsp;Initializing&nbsp;JVM&nbsp;Metrics&nbsp;with&nbsp;processName=JobTracker,&nbsp;sessionId=
15/11/05&nbsp;15:19:00&nbsp;INFO&nbsp;input.FileInputFormat:&nbsp;Total&nbsp;input&nbsp;paths&nbsp;to&nbsp;process&nbsp;:&nbsp;2
15/11/05&nbsp;15:19:00&nbsp;INFO&nbsp;mapreduce.JobSubmitter:&nbsp;number&nbsp;of&nbsp;splits:2
15/11/05&nbsp;15:19:01&nbsp;INFO&nbsp;mapreduce.JobSubmitter:&nbsp;Submitting&nbsp;tokens&nbsp;for&nbsp;job:&nbsp;job_local244789678_0001
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapreduce.Job:&nbsp;The&nbsp;url&nbsp;to&nbsp;track&nbsp;the&nbsp;job:&nbsp;http://localhost:8080/
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapreduce.Job:&nbsp;Running&nbsp;job:&nbsp;job_local244789678_0001
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;OutputCommitter&nbsp;set&nbsp;in&nbsp;config&nbsp;null
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;OutputCommitter&nbsp;is
org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Waiting&nbsp;for&nbsp;map&nbsp;tasks
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Starting&nbsp;task:&nbsp;attempt_local244789678_0001_m_000000_0
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.Task:&nbsp;&nbsp;Using&nbsp;ResourceCalculatorProcessTree&nbsp;:&nbsp;[&nbsp;]
15/11/05&nbsp;15:19:02&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Processing&nbsp;split:&nbsp;hdfs://master.dbq168.com:8020/user/hadoop/wc-in/functions:0+18586
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapreduce.Job:&nbsp;Job&nbsp;job_local244789678_0001&nbsp;running&nbsp;in&nbsp;uber&nbsp;mode&nbsp;:&nbsp;false
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapreduce.Job:&nbsp;&nbsp;map&nbsp;0%&nbsp;reduce&nbsp;0%
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;(EQUATOR)&nbsp;0&nbsp;kvi&nbsp;26214396(104857584)
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;mapreduce.task.io.sort.mb:&nbsp;100
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;soft&nbsp;limit&nbsp;at&nbsp;83886080
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;kvstart&nbsp;=&nbsp;26214396;&nbsp;length&nbsp;=&nbsp;6553600
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Map&nbsp;output&nbsp;collector&nbsp;class&nbsp;=&nbsp;org.apache.hadoop.mapred.MapTask$MapOutputBuffer
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Starting&nbsp;flush&nbsp;of&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Spilling&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufend&nbsp;=&nbsp;27567;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;kvstart&nbsp;=&nbsp;26214396(104857584);&nbsp;kvend&nbsp;=&nbsp;26203416(104813664);&nbsp;length&nbsp;=&nbsp;10981/6553600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Finished&nbsp;spill&nbsp;0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task:attempt_local244789678_0001_m_000000_0&nbsp;is&nbsp;done.&nbsp;And&nbsp;is&nbsp;in&nbsp;the&nbsp;process&nbsp;of&nbsp;committing
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;map
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task&nbsp;'attempt_local244789678_0001_m_000000_0'&nbsp;done.
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Finishing&nbsp;task:&nbsp;attempt_local244789678_0001_m_000000_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Starting&nbsp;task:&nbsp;attempt_local244789678_0001_m_000001_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;&nbsp;Using&nbsp;ResourceCalculatorProcessTree&nbsp;:&nbsp;[&nbsp;]
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Processing&nbsp;split:&nbsp;hdfs://master.dbq168.com:8020/user/hadoop/wc-in/profile:0+1796
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;(EQUATOR)&nbsp;0&nbsp;kvi&nbsp;26214396(104857584)
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;mapreduce.task.io.sort.mb:&nbsp;100
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;soft&nbsp;limit&nbsp;at&nbsp;83886080
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Map&nbsp;output&nbsp;collector&nbsp;class&nbsp;=&nbsp;org.apache.hadoop.mapred.MapTask$MapOutputBuffer
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Starting&nbsp;flush&nbsp;of&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Spilling&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufend&nbsp;=&nbsp;27567;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:03&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;kvstart&nbsp;=&nbsp;26214396(104857584);&nbsp;kvend&nbsp;=&nbsp;26203416(104813664);&nbsp;length&nbsp;=&nbsp;10981/6553600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Finished&nbsp;spill&nbsp;0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task:attempt_local244789678_0001_m_000000_0&nbsp;is&nbsp;done.&nbsp;And&nbsp;is&nbsp;in&nbsp;the&nbsp;process&nbsp;of&nbsp;committing
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;map
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task&nbsp;'attempt_local244789678_0001_m_000000_0'&nbsp;done.
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Finishing&nbsp;task:&nbsp;attempt_local244789678_0001_m_000000_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Starting&nbsp;task:&nbsp;attempt_local244789678_0001_m_000001_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;&nbsp;Using&nbsp;ResourceCalculatorProcessTree&nbsp;:&nbsp;[&nbsp;]
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Processing&nbsp;split:&nbsp;hdfs://master.dbq168.com:8020/user/hadoop/wc-in/profile:0+1796
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;(EQUATOR)&nbsp;0&nbsp;kvi&nbsp;26214396(104857584)
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;mapreduce.task.io.sort.mb:&nbsp;100
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;soft&nbsp;limit&nbsp;at&nbsp;83886080
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;kvstart&nbsp;=&nbsp;26214396;&nbsp;length&nbsp;=&nbsp;6553600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Map&nbsp;output&nbsp;collector&nbsp;class&nbsp;=&nbsp;org.apache.hadoop.mapred.MapTask$MapOutputBuffer
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Starting&nbsp;flush&nbsp;of&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Spilling&nbsp;map&nbsp;output
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;bufstart&nbsp;=&nbsp;0;&nbsp;bufend&nbsp;=&nbsp;2573;&nbsp;bufvoid&nbsp;=&nbsp;104857600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;kvstart&nbsp;=&nbsp;26214396(104857584);&nbsp;kvend&nbsp;=&nbsp;26213368(104853472);&nbsp;length&nbsp;=&nbsp;1029/6553600
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapreduce.Job:&nbsp;&nbsp;map&nbsp;50%&nbsp;reduce&nbsp;0%
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.MapTask:&nbsp;Finished&nbsp;spill&nbsp;0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task:attempt_local244789678_0001_m_000001_0&nbsp;is&nbsp;done.&nbsp;And&nbsp;is&nbsp;in&nbsp;the&nbsp;process&nbsp;of&nbsp;committing
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;map
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;Task&nbsp;'attempt_local244789678_0001_m_000001_0'&nbsp;done.
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Finishing&nbsp;task:&nbsp;attempt_local244789678_0001_m_000001_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;map&nbsp;task&nbsp;executor&nbsp;complete.
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Waiting&nbsp;for&nbsp;reduce&nbsp;tasks
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.LocalJobRunner:&nbsp;Starting&nbsp;task:&nbsp;attempt_local244789678_0001_r_000000_0
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.Task:&nbsp;&nbsp;Using&nbsp;ResourceCalculatorProcessTree&nbsp;:&nbsp;[&nbsp;]
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;mapred.ReduceTask:&nbsp;Using&nbsp;ShuffleConsumerPlugin:&nbsp;org.apache.hadoop.mapreduce.task.reduce.Shuffle@775b8754
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;reduce.MergeManagerImpl:&nbsp;MergerManager:&nbsp;memoryLimit=363285696,&nbsp;maxSingleShuffleLimit=90821424,&nbsp;mergeThreshold=239768576,&nbsp;ioSortFactor=10,&nbsp;memToMemMergeOutputsThreshold=10
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;reduce.EventFetcher:&nbsp;attempt_local244789678_0001_r_000000_0&nbsp;Thread&nbsp;started:&nbsp;EventFetcher&nbsp;for&nbsp;fetching&nbsp;Map&nbsp;Completion&nbsp;Events
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;reduce.LocalFetcher:&nbsp;localfetcher#1&nbsp;about&nbsp;to&nbsp;shuffle&nbsp;output&nbsp;of&nbsp;map&nbsp;attempt_local244789678_0001_m_000001_0&nbsp;decomp:&nbsp;2054&nbsp;len:&nbsp;2058&nbsp;to&nbsp;MEMORY
15/11/05&nbsp;15:19:04&nbsp;INFO&nbsp;reduce.InMemoryMapOutput:&nbsp;Read&nbsp;2054&nbsp;bytes&nbsp;from&nbsp;map-output&nbsp;for&nbsp;attempt_local244789678_0001_m_000001_0</pre>
<p><br></p>
<p>命令的执行结果按上面命令的指定存储于WC-OUT目录中：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;hadoop&nbsp;fs&nbsp;-ls&nbsp;WC-OUT
Found&nbsp;2&nbsp;items
-rw-r--r--&nbsp;&nbsp;&nbsp;2&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-11-05&nbsp;15:19&nbsp;WC-OUT/_SUCCESS
-rw-r--r--&nbsp;&nbsp;&nbsp;2&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10748&nbsp;2015-11-05&nbsp;15:19&nbsp;WC-OUT/part-r-00000</pre>
<p><br></p>
<p>其中的part-r-00000正是其执行结果的输出文件，使用如下命令查看其执行结果。</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;~]$&nbsp;hadoop&nbsp;fs&nbsp;-cat&nbsp;WC-OUT/part-r-00000
!&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3
!=&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;15
"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7
""&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"",&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$#"&nbsp;&nbsp;&nbsp;&nbsp;4
"$-"&nbsp;&nbsp;&nbsp;&nbsp;1
"$1"&nbsp;&nbsp;&nbsp;&nbsp;21
"$1")"&nbsp;&nbsp;2
"$2"&nbsp;&nbsp;&nbsp;&nbsp;5
"$3"&nbsp;&nbsp;&nbsp;&nbsp;1
"$4"&nbsp;&nbsp;&nbsp;&nbsp;1
"$?"&nbsp;&nbsp;&nbsp;&nbsp;2
"$@"&nbsp;&nbsp;&nbsp;&nbsp;2
"$BOOTUP"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;17
"$CONSOLETYPE"&nbsp;&nbsp;1
"$EUID"&nbsp;2
"$HISTCONTROL"&nbsp;&nbsp;1
"$RC"&nbsp;&nbsp;&nbsp;4
"$STRING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$answer"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4
"$base&nbsp;&nbsp;1
"$base"&nbsp;1
"$corelimit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2
"$count"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$dst"&nbsp;&nbsp;4
"$dst:&nbsp;&nbsp;1
"$file"&nbsp;3
"$force"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$fs_spec"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$gotbase"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$have_random"&nbsp;&nbsp;1
"$i"&nbsp;&nbsp;&nbsp;&nbsp;3
"$key"&nbsp;&nbsp;6
"$key";&nbsp;3
"$killlevel"&nbsp;&nbsp;&nbsp;&nbsp;3
"$line"&nbsp;2
"$makeswap"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2
"$mdir"&nbsp;4
"$mke2fs"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1
"$mode"&nbsp;1
"$mount_point"&nbsp;&nbsp;1
"$mount_point")&nbsp;1
......</pre>
<p><br></p>
<p><br></p>
<p>2. Hive 部属：</p>
<p>2.1 环境介绍:</p>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;Hive：1.2.1
&nbsp;&nbsp;&nbsp;&nbsp;Mysql-connector-jar:&nbsp;Mysql-connector-java-5.1.37
&nbsp;&nbsp;&nbsp;&nbsp;Hadoop:&nbsp;2.6.1&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;MySQL:&nbsp;5.6.36&nbsp;64</pre>
<p>2.1.1 Hive介绍:</p>
<p>Hive, 适用于数据仓库类的应用程序，但其并不是一个全状态的数据库，这主要受限于Hadoop自身设计的缺陷。其最大的缺陷在于Hive不支持行级别的更新、插入和删除操作。其次，Hadoop是面向批处理的系统，其MapReduce job的启动有着很大的开销，因此Hive查询有着很高的延迟，通常在传统数据上可以几秒钟完成的查询操作在Hive需要更长的时间，即使数据集非常小也无法避免。再次，Hive无法支持OLTP(Online Transaction Processing)的关键特性，而是接近于OLAP(Online Analytic Processing)，然而在Online能力方面的表现仍然与期望有着一定的差距。故此，Hive最适用于数据仓库类的应用场景，即通过数据挖掘完成数据分析、生成报告并支持智能决策等。</p>
<p><br></p>
<p>鉴于Hive本身的限制，如果期望在大数据集上实现OLTP式的特性，就得认真考虑NoSQL数据库了，比如HBase、Cassandra和DynamoDB等。 &nbsp; &nbsp;</p>
<p>2.2 Hive 运行模式</p>
<p>与 Hadoop 类似，Hive 也有 3 种运行模式：</p>
<p>2.2.1 内嵌模式</p>
<p>将元数据保存在本地内嵌的 Derby 数据库中，这是使用 Hive 最简单的方式。但是这种方式缺点也比较明显，因为一个内嵌的 Derby 数据库每次只能访问一个数据文件，这也就意味着它不支持多会话连接。</p>
<p>2.2.2 本地模式</p>
<p>这种模式是将元数据保存在本地独立的数据库中（一般是 MySQL），这用就可以支持多会话和多用户连接了。</p>
<p>2.2.3 远程模式</p>
<p>此模式应用于 Hive 客户端较多的情况。把 MySQL 数据库独立出来，将元数据保存在远端独立的 MySQL 服务中，避免了在每个客户端都安装 MySQL 服务从而造成冗余浪费的情况。</p>
<p><br></p>
<p>2.3 安装 Hive</p>
<p>Hive 是基于 Hadoop 文件系统之上的数据仓库,由Facebook提供。因此，安装Hive之前必须确保 Hadoop 已经成功安装。</p>
<p>2.3.1下载完成后解压：</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;src]#&nbsp;wget&nbsp;http://119.255.9.53/mirror.bit.edu.cn/apache/hive/stable/apache-hive-1.2.1-bin.tar.gz</pre>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;src]#&nbsp;tar&nbsp;xf&nbsp;apache-hive-1.2.1-bin.tar.gz&nbsp;&nbsp;-C&nbsp;/usr/local/</pre>
<p># 修改属主属组，hadoop用户已在hadoop集群中添加</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;src]#&nbsp;chown&nbsp;hadoop.hadoop&nbsp;-R&nbsp;apache-hive-1.2.1-bin/</pre>
<p># 创建软链接：&nbsp;</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;src]#&nbsp;ln&nbsp;-sv&nbsp;apache-hive-1.2.1-bin&nbsp;hive</pre>
<p><br></p>
<p>2.3.2 配置系统环境变量</p>
<pre class="brush:bash;toolbar:false">#&nbsp;vim&nbsp;/etc/profile.d/hive.sh&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
HIVE_HOME=/usr/local/hive
PATH=$PATH:$HIVE_HOME/bin
export&nbsp;HIVE_HOME</pre>
<p><br></p>
<p>使之立即生效</p>
<pre class="brush:bash;toolbar:false">#&nbsp;.&nbsp;&nbsp;/etc/profile.d/hive.sh</pre>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br></p>
<p><br></p>
<p>2.3.3 修改hive配置脚本</p>
<pre class="brush:bash;toolbar:false">#&nbsp;vim&nbsp;/usr/local/hive/bin/hive-config.sh&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
export&nbsp;JAVA_HOME=/usr/local/java
export&nbsp;HIVE_HOME=/usr/local/hive
export&nbsp;HADOOP_HOME=/usr/local/hadoop</pre>
<p><br></p>
<p>2.3.4 创建必要目录</p>
<p>前面我们看到 hive-site.xml 文件中有两个重要的路径，切换到 hadoop 用户下查看 HDFS 是否有这些路径：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;hadoop&nbsp;fs&nbsp;-ls&nbsp;/
Found&nbsp;4&nbsp;items
drwxr-xr-x&nbsp;&nbsp;&nbsp;-&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-11-04&nbsp;06:38&nbsp;/hbase
drwxr-xr-x&nbsp;&nbsp;&nbsp;-&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-11-05&nbsp;09:38&nbsp;/hive_data
drwx-wx-wx&nbsp;&nbsp;&nbsp;-&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-10-28&nbsp;17:04&nbsp;/tmp
drwxr-xr-x&nbsp;&nbsp;&nbsp;-&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-11-02&nbsp;14:29&nbsp;/user</pre>
<p><br></p>
<p>没有发现上面提到的路径，需要自己新建这些目录，并且给它们赋予用户写（W）权限。</p>
<pre class="brush:bash;toolbar:false">$&nbsp;hadoop&nbsp;dfs&nbsp;-mkdir&nbsp;/user/hive/warehouse
$&nbsp;hadoop&nbsp;dfs&nbsp;-mkdir&nbsp;/tmp/hive
$&nbsp;hadoop&nbsp;dfs&nbsp;-chmod&nbsp;777&nbsp;/user/hive/warehouse
$&nbsp;hadoop&nbsp;dfs&nbsp;-chmod&nbsp;777&nbsp;/tmp/hive</pre>
<p><br></p>
<p>检查是否新建成功 hadoop dfs -ls / 以及 hadoop dfs -ls /user/hive/ ：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;hadoop&nbsp;fs&nbsp;-ls&nbsp;/user/hive/
Found&nbsp;1&nbsp;items
drwxrwxrwx&nbsp;&nbsp;&nbsp;-&nbsp;hadoop&nbsp;supergroup&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;2015-11-05&nbsp;15:57&nbsp;/user/hive/warehouse</pre>
<p><br></p>
<p>2.4 配置远程模式的数据库MySQL</p>
<p><br></p>
<p>2.4.1 安装 MySQL：</p>
<p>此处使用的是通用二进制5.6.26版本，mysql安装在/usr/local/mysql，过程略...</p>
<p><br></p>
<p>2.4.2 创建数据库并授权:</p>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;mysql&gt;&nbsp;CREATE&nbsp;DATABASE&nbsp;`hive`&nbsp;/*!40100&nbsp;DEFAULT&nbsp;CHARACTER&nbsp;SET&nbsp;latin1&nbsp;*/;
&nbsp;&nbsp;&nbsp;&nbsp;mysql&gt;&nbsp;GRANT&nbsp;ALL&nbsp;PRIVILEGES&nbsp;ON&nbsp;`hive`.*&nbsp;TO&nbsp;'hive'@'192.168.40.%'&nbsp;IDENTIFIED&nbsp;BY&nbsp;'hive';
&nbsp;&nbsp;&nbsp;&nbsp;mysql&gt;&nbsp;FLUSH&nbsp;PRIVILEGES;</pre>
<p><br></p>
<p>2.4.3 下载jdbc驱动：</p>
<p>下载MySQL 的 JDBC 驱动包。这里使用 mysql-connector-java-5.1.37-bin.jar，将其复制到 $HIVE_HOME/lib 目录下:</p>
<p>下载地址: http://dev.mysql.com/downloads/connector/j/</p>
<pre class="brush:bash;toolbar:false">$&nbsp;tar&nbsp;xf&nbsp;mysql-connector-java-5.1.37.tar.gz&nbsp;&amp;&amp;&nbsp;cd&nbsp;mysql-connector-java-5.1.37
$&nbsp;cp&nbsp;mysql-connector-java-5.1.37-bin.jar&nbsp;/usr/local/hive/lib/</pre>
<p><br></p>
<p>2.5 修改Hive配置文件</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;conf]#&nbsp;su&nbsp;-&nbsp;hadoop
[hadoop@master&nbsp;~]$&nbsp;cd&nbsp;/usr/local/hive/conf/
[hadoop@master&nbsp;conf]$&nbsp;cp&nbsp;hive-site.xml.template&nbsp;hive-site.xml
[hadoop@master&nbsp;conf]$&nbsp;vim&nbsp;hive-site.xml
[hadoop@master&nbsp;conf]$&nbsp;cp&nbsp;hive-site.xml.template&nbsp;hive-site.xml
&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;javax.jdo.option.ConnectionPassword&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;hive&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;password&nbsp;to&nbsp;use&nbsp;against&nbsp;metastore&nbsp;database&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;javax.jdo.option.Multithreaded&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;true&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Set&nbsp;this&nbsp;to&nbsp;true&nbsp;if&nbsp;multiple&nbsp;threads&nbsp;access&nbsp;metastore&nbsp;through&nbsp;JDO&nbsp;concurrently.&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;javax.jdo.option.ConnectionURL&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;jdbc:mysql://mysql:3306/hive&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;JDBC&nbsp;connect&nbsp;string&nbsp;for&nbsp;a&nbsp;JDBC&nbsp;metastore&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;javax.jdo.option.ConnectionDriverName&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;com.mysql.jdbc.Driver&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Driver&nbsp;class&nbsp;name&nbsp;for&nbsp;a&nbsp;JDBC&nbsp;metastore&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;javax.jdo.option.ConnectionUserName&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;hive&lt;/value&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Username&nbsp;to&nbsp;use&nbsp;against&nbsp;metastore&nbsp;database&lt;/description&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</pre>
<p>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</p>
<p>2.6 删除多余文件，启动Hive：</p>
<p>Hive 中的 Jline jar 包和 Hadoop 中的 Jline 冲突了，在路径：$HADOOP_HOME/share/hadoop/yarn/lib/jline-0.9.94.jar 将其删除，不然启动Hive会报错。</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;lib]$&nbsp;mv&nbsp;/usr/local/hadoop/share/hadoop/yarn/lib/jline-0.9.94.jar&nbsp;~/</pre>
<p>2.6.2 启动hive</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;hive
Logging&nbsp;initialized&nbsp;using&nbsp;configuration&nbsp;in&nbsp;jar:file:/usr/local/apache-hive-1.2.1-bin/lib/hive-common-1.2.1.jar!/hive-log4j.properties
hive&gt;&nbsp;show&nbsp;tables;
OK
gold_log
gold_log_tj1
person
student
Time&nbsp;taken:&nbsp;2.485&nbsp;seconds,&nbsp;Fetched:&nbsp;4&nbsp;row(s)</pre>
<p><br></p>
<p>3. Hbase安装</p>
<p>3.0.1 环境介绍：</p>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;HBase：1.1.2&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;Zookeeper：3.4.6&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;http://hbase.apache.org/
&nbsp;&nbsp;&nbsp;&nbsp;http://zookeeper.apache.org/</pre>
<p>3.1 解压包设置权限:(以下操作Master上执行)</p>
<pre class="brush:bash;toolbar:false">#&nbsp;tar&nbsp;xf&nbsp;hbase-1.1.2-bin.tar.gz&nbsp;-C&nbsp;/usr/local/
#&nbsp;cd&nbsp;/usr/local
#&nbsp;chown&nbsp;-R&nbsp;hadoop.hadoop&nbsp;hbase-1.1.2/
#&nbsp;ln&nbsp;-sv&nbsp;hbase-1.1.2&nbsp;hbase</pre>
<p><br></p>
<p>3.2 添加环境变量：</p>
<pre class="brush:bash;toolbar:false">#&nbsp;vim&nbsp;/etc/profile.d/hbase.sh
export&nbsp;HBASE_HOME=/usr/local/hbase
export&nbsp;PATH=$PATH:$HBASE_HOME/bin</pre>
<p><br></p>
<p>3.3 完全分布式模式配置:</p>
<p>主要的修改的配置文件-- hbase-site.xml, regionservers, 和 hbase-env.sh -- 可以在 conf目录</p>
<pre class="brush:bash;toolbar:false">#&nbsp;cd&nbsp;/usr/local/hbase
3.3.1&nbsp;修改hbase-site.xml</pre>
<p>要想运行完全分布式模式，你要进行如下配置，先在 hbase-site.xml, 加一个属性 hbase.cluster.distributed 设置为 true 然后把 hbase.rootdir 设置为HDFS的NameNode的位置。 例如，你的namenode运行在master.dbq168.com，端口是8020 你期望的目录是 /hbase,使用如下的配置:</p>
<pre class="brush:bash;toolbar:false">&lt;configuration&gt;
&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;hbase.rootdir&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;hdfs://master:8020/hbase&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;directory&nbsp;shared&nbsp;by&nbsp;RegionServers.
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;hbase.cluster.distributed&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;true&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;The&nbsp;mode&nbsp;the&nbsp;cluster&nbsp;will&nbsp;be&nbsp;in.&nbsp;Possible&nbsp;values&nbsp;are
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;false:&nbsp;standalone&nbsp;and&nbsp;pseudo-distributed&nbsp;setups&nbsp;with&nbsp;managed&nbsp;Zookeeper
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;true:&nbsp;fully-distributed&nbsp;with&nbsp;unmanaged&nbsp;Zookeeper&nbsp;Quorum&nbsp;(see&nbsp;hbase-env.sh)
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/description&gt;
&nbsp;&nbsp;&lt;/property&gt;
&lt;/configuration&gt;</pre>
<p><br></p>
<p>3.3.2 修改regionservers</p>
<p>完全分布式模式的还需要修改conf/regionservers</p>
<pre class="brush:bash;toolbar:false">$&nbsp;vim&nbsp;regionservers
datanode-1
datanode-2
datanode-3</pre>
<p>3.4 ZooKeeper</p>
<p>一个分布式运行的Hbase依赖一个zookeeper集群。所有的节点和客户端都必须能够访问zookeeper。默认的情况下Hbase会管理一个zookeep集群。这个集群会随着Hbase的启动而启动。当然，你也可以自己管理一个zookeeper集群，但需要配置Hbase。你需要修改conf/hbase-env.sh里面的HBASE_MANAGES_ZK 来切换。这个值默认是true的，作用是让Hbase启动的时候同时也启动zookeeper.</p>
<p>当Hbase管理zookeeper的时候，你可以通过修改zoo.cfg来配置zookeeper，一个更加简单的方法是在 conf/hbase-site.xml里面修改zookeeper的配置。Zookeep的配置是作为property写在 hbase-site.xml里面的。option的名字是 hbase.zookeeper.property. 打个比方， clientPort 配置在xml里面的名字是 hbase.zookeeper.property.clientPort. 所有的默认值都是Hbase决定的，包括zookeeper, &nbsp;“HBase 默认配置”. 可以查找 hbase.zookeeper.property 前缀，找到关于zookeeper的配置。</p>
<p><br></p>
<p>对于zookeepr的配置，你至少要在 hbase-site.xml中列出zookeepr的ensemble servers，具体的字段是 hbase.zookeeper.quorum. 该这个字段的默认值是 localhost，这个值对于分布式应用显然是不可以的. (远程连接无法使用).</p>
<p><br></p>
<p>你运行一个zookeeper也是可以的，但是在生产环境中，你最好部署3，5，7个节点。部署的越多，可靠性就越高，当然只能部署奇数个，偶数个是不可以的。你需要给每个zookeeper 1G左右的内存，如果可能的话，最好有独立的磁盘。 (独立磁盘可以确保zookeeper是高性能的。).如果你的集群负载很重，不要把Zookeeper和RegionServer运行在同一台机器上面。就像DataNodes 和 TaskTrackers一样</p>
<p>打个比方，Hbase管理着的ZooKeeper集群在节点 rs{1,2,3,4,5}.dbq168.com, 监听2222 端口(默认是2181)，并确保conf/hbase-env.sh文件中 HBASE_MANAGE_ZK的值是 true ，再编辑 conf/hbase-site.xml 设置 hbase.zookeeper.property.clientPort 和 hbase.zookeeper.quorum。你还可以设置 hbase.zookeeper.property.dataDir属性来把ZooKeeper保存数据的目录地址改掉。默认值是 /tmp ，这里在重启的时候会被操作系统删掉，可以把它修改到 /hadoop/zookeeper.</p>
<p><br></p>
<p>3.4.1 配置zookeeper</p>
<pre class="brush:bash;toolbar:false">$&nbsp;vim&nbsp;hbase-site.xml&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;hbase.zookeeper.property.clientPort&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;2222&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Property&nbsp;from&nbsp;ZooKeeper's&nbsp;config&nbsp;zoo.cfg.The&nbsp;port&nbsp;at&nbsp;which&nbsp;the&nbsp;clients&nbsp;will&nbsp;connect.&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;hbase.zookeeper.quorum&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;datanode-1,datanode-2,datanode-3&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Comma&nbsp;separated&nbsp;list&nbsp;of&nbsp;servers&nbsp;in&nbsp;the&nbsp;ZooKeeper&nbsp;Quorum.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For&nbsp;example,&nbsp;"host1.mydomain.com,host2.mydomain.com,host3.mydomain.com".
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;By&nbsp;default&nbsp;this&nbsp;is&nbsp;set&nbsp;to&nbsp;localhost&nbsp;for&nbsp;local&nbsp;and&nbsp;pseudo-distributed&nbsp;modes
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;of&nbsp;operation.&nbsp;For&nbsp;a&nbsp;fully-distributed&nbsp;setup,&nbsp;this&nbsp;should&nbsp;be&nbsp;set&nbsp;to&nbsp;a&nbsp;full
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;list&nbsp;of&nbsp;ZooKeeper&nbsp;quorum&nbsp;servers.&nbsp;If&nbsp;HBASE_MANAGES_ZK&nbsp;is&nbsp;set&nbsp;in&nbsp;hbase-env.sh
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this&nbsp;is&nbsp;the&nbsp;list&nbsp;of&nbsp;servers&nbsp;which&nbsp;we&nbsp;will&nbsp;start/stop&nbsp;ZooKeeper&nbsp;on.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;property&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;name&gt;hbase.zookeeper.property.dataDir&lt;/name&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;value&gt;/hadoop/zookeeper&lt;/value&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;description&gt;Property&nbsp;from&nbsp;ZooKeeper's&nbsp;config&nbsp;zoo.cfg.
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The&nbsp;directory&nbsp;where&nbsp;the&nbsp;snapshot&nbsp;is&nbsp;stored.
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/description&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;/property&gt;</pre>
<p>&nbsp; &nbsp;&nbsp;</p>
<p>&nbsp; &nbsp;&nbsp;</p>
<p>3.4.2 复制包到其他节点:(包括secondarynode、datanode1-3)</p>
<pre class="brush:bash;toolbar:false">[root@master&nbsp;src]#&nbsp;for&nbsp;i&nbsp;in&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;scp&nbsp;hbase-1.1.2-bin.tar.gz&nbsp;zookeeper-3.4.6.tar.gz&nbsp;192.168.40.$i:/usr/local/src/;done</pre>
<p><br></p>
<p>3.4.3 datanode三个节点的操作:</p>
<pre class="brush:bash;toolbar:false">#&nbsp;cd&nbsp;/usr/local/src
#&nbsp;tar&nbsp;xf&nbsp;hbase-1.1.2-bin.tar.gz&nbsp;-C&nbsp;..
#&nbsp;chown&nbsp;hadoop.hadoop&nbsp;-R&nbsp;hbase-1.1.2/
#&nbsp;ln&nbsp;-sv&nbsp;hbase-1.1.2&nbsp;hbase
#&nbsp;tar&nbsp;xf&nbsp;zookeeper-3.4.6.tar.gz&nbsp;-C&nbsp;..
#&nbsp;chown&nbsp;hadoop.hadoop&nbsp;zookeeper-3.4.6/&nbsp;-R
#&nbsp;ln&nbsp;-sv&nbsp;zookeeper-3.4.6/&nbsp;zookeeper
[root@datanode-1&nbsp;~]$&nbsp;cd&nbsp;/usr/local/zookeeper/conf/&nbsp;
[root@datanode-1&nbsp;~]$&nbsp;cp&nbsp;zoo_sample.cfg&nbsp;zoo.cfg
[root@datanode-1&nbsp;~]$&nbsp;vim&nbsp;zoo.cfg</pre>
<pre class="brush:bash;toolbar:false">tickTime=2000
initLimit=10
syncLimit=5
dataDir=/hadoop/zookeeper
clientPort=2222
[root@datanode-1&nbsp;~]#&nbsp;mkdir&nbsp;/hadoop/zookeeper
[root@datanode-1&nbsp;~]#&nbsp;chown&nbsp;hadoop.hadoop&nbsp;-R&nbsp;/hadoop/zookeeper/</pre>
<p><br></p>
<p>以上操作在每个datanode节点上都执行，其余两个节点不再演示。</p>
<p><br></p>
<p>3.4.4 复制Hbase配置文件到Datanode各节点：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;cd&nbsp;/usr/local/hbase/conf
[hadoop@master&nbsp;conf]$&nbsp;for&nbsp;i&nbsp;in&nbsp;31&nbsp;32&nbsp;33&nbsp;35;do&nbsp;scp&nbsp;-p&nbsp;hbase-env.sh&nbsp;hbase-site.xml&nbsp;regionservers&nbsp;192.168.40.$i:/usr/local/hbase/conf/;done</pre>
<p><br></p>
<p>3.5 启动Hbase：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;start-hbase.sh&nbsp;
datanode-2:&nbsp;starting&nbsp;zookeeper,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-datanode-2.cnfol.com.out
datanode-3:&nbsp;starting&nbsp;zookeeper,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-datanode-3.cnfol.com.out
datanode-1:&nbsp;starting&nbsp;zookeeper,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-datanode-1.cnfol.com.out
starting&nbsp;master,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/logs/hbase-hadoop-master-master.cnfol.com.out
datanode-3:&nbsp;starting&nbsp;regionserver,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-datanode-3.cnfol.com.out
datanode-2:&nbsp;starting&nbsp;regionserver,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-datanode-2.cnfol.com.out
datanode-1:&nbsp;starting&nbsp;regionserver,&nbsp;logging&nbsp;to&nbsp;/usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-datanode-1.cnfol.com.out</pre>
<p><br></p>
<p>3.5.1 检验启动情况：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;jps
3750&nbsp;Jps
32515&nbsp;NameNode
301&nbsp;ResourceManager
3485&nbsp;HMaster</pre>
<pre class="brush:bash;toolbar:false">[hadoop@datanode-1&nbsp;~]$&nbsp;jps
3575&nbsp;DataNode
3676&nbsp;NodeManager
5324&nbsp;Jps
5059&nbsp;HQuorumPeer
5143&nbsp;HRegionServer
[hadoop@datanode-2&nbsp;~]$&nbsp;jps
4512&nbsp;Jps
3801&nbsp;NodeManager
4311&nbsp;HRegionServer
4242&nbsp;HQuorumPeer
3700&nbsp;DataNode
[hadoop@datanode-3&nbsp;~]$&nbsp;jps
2128&nbsp;HRegionServer
2054&nbsp;HQuorumPeer
1523&nbsp;DataNode
1622&nbsp;NodeManager
2289&nbsp;Jps</pre>
<p><br></p>
<p>3.5.2 查看master上监听的端口：</p>
<pre class="brush:bash;toolbar:false">[hadoop@master&nbsp;conf]$&nbsp;netstat&nbsp;-tunlp
(Not&nbsp;all&nbsp;processes&nbsp;could&nbsp;be&nbsp;identified,&nbsp;non-owned&nbsp;process&nbsp;info
&nbsp;will&nbsp;not&nbsp;be&nbsp;shown,&nbsp;you&nbsp;would&nbsp;have&nbsp;to&nbsp;be&nbsp;root&nbsp;to&nbsp;see&nbsp;it&nbsp;all.)
Active&nbsp;Internet&nbsp;connections&nbsp;(only&nbsp;servers)
Proto&nbsp;Recv-Q&nbsp;Send-Q&nbsp;Local&nbsp;Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Foreign&nbsp;Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;State&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PID/Program&nbsp;name&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;192.168.40.30:8020&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;32515/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;0.0.0.0:50070&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;32515/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;0.0.0.0:22&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;127.0.0.1:25&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;:::22&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8088&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;301/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::1:25&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8030&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;301/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8031&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;301/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:16000&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3485/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8032&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;301/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;::ffff:192.168.40.30:8033&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;301/java&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0&nbsp;:::16010&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:::*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LISTEN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3485/java</pre>
<p><br></p>
<p>3.5.3 通过浏览器访问，查看HBase情况:</p>
<pre class="brush:bash;toolbar:false">http://192.168.40.30:16010/master-status</pre>
<p>最后是几张截图：</p>
<p><a href="http://s3.51cto.com/wyfs02/M00/75/8D/wKioL1Y8JsmghoT_AAKZUFDGucw293.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/75/8D/wKioL1Y8JsmghoT_AAKZUFDGucw293.jpg" style="float:none;" title="hadoop1.png" alt="wKioL1Y8JsmghoT_AAKZUFDGucw293.jpg"></a></p>
<p><a href="http://s3.51cto.com/wyfs02/M00/75/8D/wKioL1Y8JsnTu0ZGAASk9Vwqs3s326.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/75/8D/wKioL1Y8JsnTu0ZGAASk9Vwqs3s326.jpg" style="float:none;" title="hadoop2.png" alt="wKioL1Y8JsnTu0ZGAASk9Vwqs3s326.jpg"></a></p>
<p><a href="http://s3.51cto.com/wyfs02/M01/75/8F/wKiom1Y8JonwXR7hAALmHxj4MYc152.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/75/8F/wKiom1Y8JonwXR7hAALmHxj4MYc152.jpg" style="float:none;" title="hadoop3.png" alt="wKiom1Y8JonwXR7hAALmHxj4MYc152.jpg"></a></p>
<p><br></p>
<p>本文出自 “<a href="http://naonao.blog.51cto.com">DBQ blog</a>” 博客，请务必保留此出处<a href="http://naonao.blog.51cto.com/1135983/1710296">http://naonao.blog.51cto.com/1135983/1710296</a></p>
