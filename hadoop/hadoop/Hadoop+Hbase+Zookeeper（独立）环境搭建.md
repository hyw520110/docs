<p>转自 ：http://blog.itpub.net/23289442/viewspace-1120056/</p>
<p><br></p>
<p>准备的机器信息：</p>
<p><span style="color:rgb(51,51,51);font-family:Arial;font-size:14px;">192.168.247.128 &nbsp;dengnn（master）&nbsp;&nbsp;&nbsp;</span><br style="color:rgb(51,51,51);font-family:Arial;font-size:14px;"><span style="color:rgb(51,51,51);font-family:Arial;font-size:14px;">192.168.247.129</span><span style="color:rgb(51,51,51);font-family:Arial;font-size:14px;">&nbsp;dengdn1 （slave1） &nbsp;&nbsp;</span></p>
<p><span style="color:rgb(51,51,51);font-family:Arial;font-size:14px;">192.168.247.130</span><span style="color:rgb(51,51,51);font-family:Arial;font-size:14px;">&nbsp;dengdn2 （slave2）</span></p>
<p><span style="color:rgb(102,102,102);font-family:'宋体', Arial;font-size:12px;line-height:26px;background-color:rgb(255,255,255);">集群搭建 参考资料</span></p>
<p><br>&nbsp;cloudera hadoop 搭建</p>
<p><a href="http://heylinux.com/archives/1980.html" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://heylinux.com/archives/1980.html</a></p>
<p><a href="http://www.ibm.com/developerworks/cn/data/library/techarticle/dm-1307yangww/" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://www.ibm.com/developerworks/cn/data/library/techarticle/dm-1307yangww/</a></p>
<p>apache hadoop 搭建</p>
<p><a href="http://blog.csdn.net/hguisu/article/details/7237395" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://blog.csdn.net/hguisu/article/details/7237395</a></p>
<p><a href="http://ju.outofmemory.cn/entry/29825" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://ju.outofmemory.cn/entry/29825</a></p>
<p>拓展介绍</p>
<p><a href="http://www.infoq.com/cn/articles/hadoop-intro" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://www.infoq.com/cn/articles/hadoop-intro</a></p>
<p><a href="http://blog.csdn.net/shatelang/article/details/7605939" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://blog.csdn.net/shatelang/article/details/7605939</a></p>
<p><a href="http://blog.csdn.net/cuirong1986/article/details/7311734" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://blog.csdn.net/cuirong1986/article/details/7311734</a></p>
<p>jdk安装参考资料</p>
<p><a href="http://melin.iteye.com/blog/1848637" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://melin.iteye.com/blog/1848637</a></p>
<p><a href="http://www.cnblogs.com/gaizai/archive/2012/06/12/2545886.html" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://www.cnblogs.com/gaizai/archive/2012/06/12/2545886.html</a></p>
<p>Jdk安装部分指令摘记：</p>
<p>&nbsp;修改/etc/profile文件.用文本编辑器打开/etc/profile。在profile文件末尾加入(root用户登录)：&nbsp;</p>
<p>export JAVA_HOME=/usr/java/jdk1.6.0_45 &nbsp;<br>export JRE_HOME=$JAVA_HOME/jre&nbsp;<br>export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib/rt.jar&nbsp;<br>export PATH=$PATH:$JAVA_HOME/bin&nbsp;</p>
<p>执行source /etc/profile 来使其生效</p>
<p>NameNode与SecondaryNameNode简介</p>
<p><a href="http://a280606790.iteye.com/blog/870123" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://a280606790.iteye.com/blog/870123</a></p>
<p><strong style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;">在每台机器上创建hadoop用户组合hadoop用户</strong><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;">&nbsp;</span><br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;"><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;">1：创建用户组：groupadd hadoop&nbsp;</span><br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;"><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;">2：创建用户：useradd -g hadoop hadoop&nbsp;</span><br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;"><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.1875px;">3：修改密码：passwd hadoop&nbsp;</span></p>
<p><strong>安装SSH</strong>，一些命令的摘记：</p>
<p>Centos系统安装时默认可以选择安装SSH，ubuntu下可以通过如下命令进行安装（前提是必须联网）：</p>
<p>rpm &#xfffd;qa | grep openssh<br>rpm &#xfffd;qa | grep rsync<br></p>
<p>service sshd restart 启动服务</p>
<p>测试是否安装成功：ssh localhost</p>
<p>注意：在所有机子都需要安装ssh。</p>
<p>配置Master无密码登录所有Salve。</p>
<p>（说明：hadoop@hadoop~]$ssh-keygen&nbsp;&nbsp;-t&nbsp;&nbsp;rsa</p>
<p>这个命令将为hadoop上的用户hadoop生成其密钥对，询问其保存路径时直接回车采用默认路径，当提示要为生成的密钥输入passphrase的时候，直接回车，也就是将其设定为空密码。生成的密钥对id_rsa，id_rsa.pub，默认存储在/home/hadoop/.ssh目录下然后将id_rsa.pub的内容复制到每个机器(也包括本机)的/home/dbrg/.ssh/authorized_keys文件中，如果机器上已经有authorized_keys这个文件了，就在文件末尾加上id_rsa.pub中的内容，如果没有authorized_keys这个文件，直接复制过去就行.）</p>
<p>在Master节点上执行以下命令：</p>
<p>su hadoop</p>
<p>1、生成其密钥对</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ssh-keygen -t rsa</p>
<p>2、接着在Master节点上做如下配置，把id_rsa.pub追加到授权的key里面去。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cat ~/.ssh/id_rsa.pub &gt;&gt; ~/.ssh/authorized_keys</p>
<p>3、修改文件"authorized_keys"</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;chmod 600 ~/.ssh/authorized_keys</p>
<p>4、启动服务(需要权限用户)</p>
<p><span style="color:#333333;font-family:Verdana;font-size:2px;"><span style="font-size:10pt;">&nbsp;&nbsp;&nbsp;&nbsp;service sshd restart</span></span></p>
<p>5、把公钥复制所有的Slave机器上：格式&nbsp;<span style="color:#333333;font-family:Verdana;font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">&nbsp;</span></span><span style="color:#FF0000;font-family:Verdana;font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">scp ~/.ssh/id_rsa.pub</span></span><span>&nbsp;</span><span style="color:#FF0000;font-family:'宋体';font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">远程用户名</span></span><span style="color:#FF0000;font-family:Verdana;font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">@</span></span><span style="color:#FF0000;font-family:'宋体';font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">远程服务器</span></span><span style="color:#FF0000;font-family:Verdana;font-size:2px;text-indent:20mm;"><span style="font-size:10pt;">IP:~/</span></span></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;（完整路径显示[hadoop@dengnn .ssh]$ scp authorized_keys dengdn1:/home/hadoop/.ssh/） &nbsp;&nbsp;&nbsp;&nbsp;</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;scp authorized_keys dengdn1:/home/hadoop/.ssh/</p>
<p>&nbsp;</p>
<p><strong>安装hadoop集群</strong>环境的，一些命令摘记：su hadoop 用此用户登录</p>
<p>1、建立hadoop目录</p>
<p>mkdir hadoop</p>
<p>2、解压安装文档</p>
<p>tar -zxvf hadoop-1.0.3.tar.gz</p>
<p>3、修改Master上/etc/profile 新增以下内容：</p>
<p>&nbsp;export HADOOP_HOME=/home/hadoop/hadoop/hadoop-1.0.3</p>
<p>&nbsp;export PATH=$PATH:$HADOOP_HOME/bin</p>
<p>&nbsp;执行source /etc/profile 来使其生效</p>
<p>4、配置conf/hadoop-env.sh文件</p>
<p>#添加 命令</p>
<p>export JAVA_HOME=/usr/java/jdk1.6.0_45</p>
<p>这里修改为你的jdk的安装位置。</p>
<p>（若命令没有添加成功，可以用vi命令手动添加）</p>
<p>5、配置core-site.xml文件</p>
<p><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">在解压的</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">src</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">目录找到</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;">&nbsp;</span><span style="font-size:11pt;color:rgb(1,1,1);font-family:'Times new roman';">&nbsp;core-default.xml</span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">&nbsp;</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">文件，将其复制到</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">conf</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">目录，改名称为</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">：</span></span><span style="text-indent:8mm;">&nbsp;</span><span style="font-size:11pt;color:rgb(1,1,1);font-family:'Times new roman';">core-site.xml</span><span style="color:#010101;font-family:'宋体';text-indent:8mm;">&nbsp;<span style="font-size:11pt;">。然后修改</span></span><span style="font-size:11pt;color:rgb(1,1,1);font-family:'Times new roman';">core-site.xml</span><span style="font-size:11pt;text-indent:8mm;color:rgb(1,1,1);font-family:'宋体';">里面的部分配置为</span></p>
<p>#修改</p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;fs.default.name</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span>&nbsp;<span style="color:#FF0000;font-family:'Times New Roman';"><span style="font-size:11pt;">hdfs://dengnn:9000</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;The name of the default file system.&nbsp;&nbsp;A URI whose</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;scheme and authority determine the FileSystem implementation.&nbsp;&nbsp;The</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;uri's scheme determines the config property (fs.SCHEME.impl) naming</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;the FileSystem implementation class.&nbsp;&nbsp;The uri's authority is used to</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;determine the host, port, etc. for a filesystem.</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;hadoop.tmp.dir</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span>&nbsp;<span style="color:#FF0000;font-family:'Times New Roman';"><span style="font-size:11pt;">/home/hadoop/hadoop/tmp</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;A base for other temporary directories.</span></span></p>
<p>注解：</p>
<p>1）fs.default.name是NameNode的URI。hdfs://主机名:端口/<br>2）hadoop.tmp.dir ：Hadoop的默认临时路径，这个最好配置，如果在新增节点或者其他情况下莫名其妙的DataNode启动不了，就删除此文件中的tmp目录即可。不过如果删除了NameNode机器的此目录，那么就需要重新执行NameNode格式化的命令。&nbsp;</p>
<p>6、配置mapred-site.xml文件</p>
<p><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">在解压的</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">src&nbsp;</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">目录找到</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;">&nbsp;<span style="font-size:11pt;">mapred-default.xml&nbsp;</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">文件，将其复制到</span></span><span style="text-indent:8mm;">&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">conf&nbsp;</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">目录，改名称为</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;">&nbsp;</span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">：</span></span><span style="text-indent:8mm;">&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">mapred-site.xml</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;">&nbsp;<span style="font-size:11pt;">。然后修改</span></span><span style="color:#010101;font-family:'Times New Roman';text-indent:8mm;"><span style="font-size:11pt;">mapred-site.xml&nbsp;</span></span><span style="color:#010101;font-family:'宋体';text-indent:8mm;"><span style="font-size:11pt;">里面的部分配置为</span></span></p>
<p>#修改</p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;mapred.job.tracker</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span>&nbsp;<span style="color:#FF0000;font-family:'Times New Roman';"><span style="font-size:11pt;">dengnn:9001</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;The host and port that the MapReduce job tracker runs</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;at.&nbsp;&nbsp;If "local", then jobs are run in-process as a single map</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;and reduce task.</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span></p>
<p>注解：</p>
<p>1）mapred.job.tracker是JobTracker的主机（或者IP）和端口。主机:端口。</p>
<p>7、配置<span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">hdfs-default.xml</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">文件</span></span></p>
<p><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">在解压的</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">src</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">目录找到</span></span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">hdfs-default.xml</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">文件，将其复制到</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">conf</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">目录，改名称为</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">：</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">hdfs--site.xml</span></span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">。然后修改</span></span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">hdfs -site.xml</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">里面的部分配置为</span></span></p>
<p><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">#修改</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;dfs.replication</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span>&nbsp;<span style="color:#FF0000;font-family:'Times New Roman';"><span style="font-size:11pt;">3</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;Default block replication.</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;The actual number of replications can be specified when the file is created.</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;&nbsp;The default is used if replication is not specified in create time.</span></span></p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">&nbsp;</span></span></p>
<p>注解：</p>
<p>1）&nbsp;&nbsp;&nbsp;dfs.name.dir是NameNode持久存储名字空间及事务日志的本地文件系统路径。 当这个值是一个逗号分割的目录列表时，nametable数据将会被复制到所有目录中做冗余备份。<br>2）&nbsp;&nbsp;&nbsp;dfs.data.dir是DataNode存放块数据的本地文件系统路径，逗号分割的列表。 当这个值是逗号分割的目录列表时，数据将被存储在所有目录下，通常分布在不同设备上。<br>3）dfs.replication是数据需要备份的数量，默认是3，如果此数大于集群的机器数会出错。<br>注意：此处的name1、name2、data1、data2目录不能预先创建，hadoop格式化时会自动创建，如果预先创建反而会有问题。</p>
<p>8、配置masters和slaves主从结点</p>
<p>配置conf/masters和conf/slaves来设置主从结点，注意最好使用主机名，并且保证机器之间通过主机名可以互相访问，每个主机名一行。</p>
<p><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">修改</span></span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">conf&nbsp;</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">目录里面的</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">masters</span></span><span>&nbsp;</span><span style="color:#010101;font-family:'宋体';"><span style="font-size:11pt;">文件，内容为：</span></span></p>
<p>命令 vi masters<br>输入：<br>dengnn</p>
<p>保存退出命令 &nbsp;&nbsp;:wq</p>
<p>命令 vi slaves</p>
<p>dengdn1</p>
<p>dengdn2</p>
<p>保存退出</p>
<p>9、配置结束，把配置好的hadoop文件夹拷贝到其他集群的机器中，并且保证上面的配置对于其他机器而言正确，例如：如果其他机器的Java安装路径不一样，要修改conf/hadoop-env.sh</p>
<p>拷贝的命令：</p>
<p>scp -r /home/hadoop/hadoop/hadoop-1.0.3 hadoop@dengdn1: /home/hadoop/hadoop</p>
<p>(如果不行就直接用其他方式复制)</p>
<p>10、关闭所有机器防火墙&nbsp;</p>
<p><span style="color:rgb(102,102,102);font-family:'宋体', Arial;font-size:12px;line-height:26px;background-color:rgb(255,255,255);">chkconfig iptables off</span><br style="color:rgb(102,102,102);font-family:'宋体', Arial;font-size:12px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><span style="color:rgb(102,102,102);font-family:'宋体', Arial;font-size:12px;line-height:26px;background-color:rgb(255,255,255);">service iptables stop</span></p>
<p>11、启动hadoop集群</p>
<p>登录NameNode，进入bin目录执行命令：</p>
<p>1、先格式化一个新的分布式文件系统</p>
<p>bin/hadoop namenode -format</p>
<p>2、启动（同时启动HDFS和Map/Reduce）</p>
<p>bin/start-all.sh</p>
<p>3、启动（单独启动HDFS）</p>
<p>bin/start-dfs.sh</p>
<p>4、启动（单独启动Map/Reduce）</p>
<p>bin/start-mapred.sh</p>
<p>(给文件夹赋权限)</p>
<p>chmod -R 755 hadoop-1.0.3&nbsp;</p>
<p>可以查看：</p>
<p><span style="font-family:Arial, '宋体';font-size:14px;line-height:25px;">NameNode浏览web地址http://192.168.247.128:50070</span></p>
<p><span style="font-family:Arial, '宋体';font-size:14px;line-height:25px;">MapReduce浏览web地址http://192.168.247.128:50030</span></p>
<p><span style="font-family:Arial, '宋体';font-size:14px;line-height:25px;"><br></span></p>
<p><strong>安装zookeeper</strong>&nbsp;一些摘要记录：su hadoop</p>
<p>1、解压安装文档</p>
<p>tar -zxvf&nbsp;zookeeper-3.4.3.tar.gz</p>
<p>2、修改zookeeper配置文件zoo.cfg</p>
<p>进入到conf目录，将zoo_sample.cfg拷贝一份命名为zoo.cfg（Zookeeper 在启动时会找这个文件作为默认配置文件），打开该文件进行修改为以下格式（注意权限问题，如果最后配置有问题请检查过程中权限是否正确）。</p>
<p>#修改</p>
<p><span style="color:#010101;font-family:'Times New Roman';"><span style="font-size:11pt;">dataDir=/home/hadoop/hadoop/zookeeper/data</span></span></p>
<p>server.0=192.168.247.128:2888:3888</p>
<p>server.1=192.168.247.129:2888:3888</p>
<p>server.2=192.168.247.130:2888:3888</p>
<p>(备注：其中，2888端口号是zookeeper服务之间通信的端口，而3888是zookeeper与其他应用程序通信的端口。而zookeeper是在hosts中已映射了本机的ip。</p>
<p>initLimit：这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 10 个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒。</p>
<p>syncLimit：这个配置项标识 Leader 与 Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是 2*2000=4 秒。</p>
<p>server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器；B 是这个服务器的 ip 地址；C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。)</p>
<p>3、新建目录、新建并编辑myid文件</p>
<p>创建dataDir参数指定的目录(这里指的是“<span style="color:rgb(1,1,1);font-family:'Times new roman';font-size:15px;">/home/hadoop/hadoop/zookeeper/data</span>”)，并在目录下创建文件，命名为“myid”</p>
<p>mkdir&nbsp;<span style="color:rgb(1,1,1);font-family:'Times new roman';font-size:15px;">/home/hadoop/hadoop/zookeeper</span></p>
<p>mkdir&nbsp;<span style="color:rgb(1,1,1);font-family:'Times new roman';font-size:15px;">/home/hadoop/hadoop/zookeeper/data</span></p>
<p>touch myid</p>
<p>4、编辑myid文件</p>
<p>注意：编辑“myid”文件，并在对应的IP的机器上输入对应的编号。如在192.168.247.128上，</p>
<p><span style="color:rgb(102,102,102);font-family:'宋体', Arial;font-size:12px;line-height:26px;background-color:rgb(255,255,255);">“myid”文件内容就是0，在192.168.247.129上，内容就是1</span></p>
<p>5、同步安装</p>
<p>将解压修改后的zookeeper-3.4.3文件夹分别拷贝到Master、Slave1、Slave2的相同zookeeper安装路径下。</p>
<p>注意：myid文件的内容不是一样的，各服务器中分别是对应zoo.cfg中的设置。相应的目录以及文件的创建（需要每台机器创建）<br>6、启动zookeeper<br>Zookeeper的启动与hadoop不一样，需要每个节点都执行，分别进入3个节点的zookeeper-3.4.3目录，启动zookeeper：</p>
<p>bin/zkServer.sh start</p>
<p>注意：此时如果报错先不理会，继续在另两台服务器中执行相同操作。</p>
<p>若文件权限问题，则(给文件夹赋权限)</p>
<p>chmod -R 755 zookeeper-3.4.3&nbsp;</p>
<p>7、检查zookeeper是否配置成功</p>
<p>待3台服务器均启动后，如果过程正确的话zookeeper应该已经自动选好leader，进入每台服务器的zookeeper-3.4.3目录，执行以下操作查看zookeeper启动状态：</p>
<p>bin/zkServer.sh status</p>
<p>如果出现以下代码表示安装成功了。</p>
<pre style="margin-top:0px;margin-bottom:10px;padding:5px;font-family:Consolas, Menlo, Monaco, 'Lucida Console', 'Liberation Mono', 'DejaVu sans Mono', 'Bitstream Vera sans Mono', 'Courier new', monospace, serif;width:auto;font-size:14px;line-height:15.3906px;background-color:rgb(225,225,225);">[java]&nbsp;view&nbsp;plaincopy
JMX&nbsp;enabled&nbsp;by&nbsp;default&nbsp;&nbsp;Using&nbsp;config:&nbsp;/home/hadoop/zookeeper-3.4.3/bin/../conf/zoo.cfg&nbsp;&nbsp;
Mode:&nbsp;follower&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//或者有且只有一个leader</pre>
<p>ps: 启动客户端脚本：zookeeper-3.4.3/bin/zkCli.sh -server zookeeper:2181</p>
<p>另外参考：</p>
<p><a href="http://www.blogjava.net/BucketLi/archive/2010/12/21/341268.html" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://www.blogjava.net/BucketLi/archive/2010/12/21/341268.html</a></p>
<p><strong>安装Hbase</strong>&nbsp;环境的，一些命令摘记：su hadoop 用此用户登录</p>
<p>1、解压安装文档</p>
<p>tar -zxvf&nbsp;hbase-0.92.1.tar.gz</p>
<p>2、修改conf目录下的3个文件（hbase-env.sh ，hbase-site.xml，regionservers 文件）</p>
<p>2.1 修改hbase-env.sh文件</p>
<p>#添加</p>
<p>export JAVA_HOME=/usr/java/jdk1.6.0_45&nbsp;&nbsp;</p>
<p>export HBASE_MANAGES_ZK=false&nbsp;</p>
<p>1） 需要注意的地方是 ZooKeeper的配置。这与 hbase-env.sh 文件相关，文件中 HBASE_MANAGES_ZK 环境变量用来设置是使用hbase默认自带的 Zookeeper还是使用独立的ZooKeeper。HBASE_MANAGES_ZK=false 时使用独立的，为true时使用默认自带的。</p>
<p>2.2修改hbase-site.xml文件</p>
<p>#修改</p>
<pre style="margin-top:0px;margin-bottom:10px;padding:5px;font-family:Consolas, Menlo, Monaco, 'Lucida Console', 'Liberation Mono', 'DejaVu sans Mono', 'Bitstream Vera sans Mono', 'Courier new', monospace, serif;width:auto;line-height:15.3906px;">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hbase.rootdir
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hdfs://dengnn:9000/hbase
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hbase.cluster.distributed
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;true
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hbase.zookeeper.property.clientPort
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2181
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hbase.zookeeper.quorum
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dengnn,dengdn1,dengdn2</pre>
<p>下面的暂时没有配置，在安装zookeeper时在做修改</p>
<pre style="margin-top:0px;margin-bottom:10px;padding:5px;width:auto;line-height:15.3906px;background-color:rgb(225,225,225);">&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hbase.zookeeper.property.dataDir
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/home/hadoop/temp/zookeeper</pre>
<p>1）hbase.cluster.distributed指定了Hbase的运行模式。false是单机模式，true是分布式模式。<br>2）hbase.rootdir目录是region server的共享目录，用来持久化Hbase。注意：注意主机名和端口号要与hadoop的dfs&nbsp;name的对应&nbsp;</p>
<p>3）hbase.zookeeper.quorum是Zookeeper集群的地址列表，用逗号分割。</p>
<p>4）运行一个zookeeper也是可以的，但是在生产环境中，最好部署3，5，7个节点。</p>
<p>部署的越多，可靠性就越高，当然只能部署奇数个，偶数个是不可以的。<br>需要给每个zookeeper 1G左右的内存，如果可能的话，最好有独立的磁盘确保zookeeper是高性能的。<br>如果你的集群负载很重，不要把Zookeeper和RegionServer运行在同一台机器上面，就像DataNodes和TaskTrackers一样。</p>
<p><br></p>
<p>2.3修改regionservers文件</p>
<p>#添加</p>
<p>dengdn1</p>
<p>dengdn2</p>
<p>注意：设置regionservers的服务器，和Hadoop的slaves一样即可</p>
<p>3、同步安装</p>
<p>将解压修改后的hbase-0.92.1&nbsp;文件夹分别拷贝到Master、Slave1、Slave2的相同hbase安装路径下。</p>
<p>注意：文件权限问题。</p>
<p>给文件夹赋权限：chmod -R 755&nbsp;hbase-0.92.1</p>
<p>4、启动Hbase</p>
<p>bin/start-hbase.sh</p>
<p>测试看成功与否</p>
<p>可以查看http://192.168.247.128:60010/</p>
<p>也可以用bin/hbase shell 界面查看。</p>
<p>ps: 若出现重启Hbase后，已有的数据没有了。可以从下面修改着手处理</p>
<p>修改hbase-default.xml文件<br>注意只修改hbase.rootdir这项，文件位置：/root/hbase/src/main/resources目录下<br>&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;hbase.rootdir<br>&nbsp;&nbsp;&nbsp;&nbsp;hdfs://dengnn:9000/hbase<br>注意事项：如果你的版本和我不一样，hbase启动后查看表失败，可以将hadoop的jar拷贝至hbase的lib目录下，这一步很关键！我这个版本不需要拷贝！</p>
<p>另外参考资料</p>
<p><a href="http://blog.chinaunix.net/uid-23916356-id-3255678.html" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://blog.chinaunix.net/uid-23916356-id-3255678.html</a></p>
<p><a href="http://linuxjcq.blog.51cto.com/3042600/760634" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://linuxjcq.blog.51cto.com/3042600/760634</a></p>
<p>集群web访问地址：</p>
<p>namenode&nbsp;<a href="http://192.168.247.128:50070/" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://192.168.247.128:50070</a></p>
<p>mapreduce&nbsp;<a href="http://192.168.247.128:50030/" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://192.168.247.128:50030</a></p>
<p>hbase master&nbsp;<a href="http://192.168.247.128:60010/" style="text-decoration:none;color:rgb(86,86,86);" target="_blank">http://192.168.247.128:60010</a></p>
<p><br></p>
<p><br></p>
<p>转自 ：http://blog.itpub.net/23289442/viewspace-1120056/</p>
