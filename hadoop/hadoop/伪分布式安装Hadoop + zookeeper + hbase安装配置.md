<p><br></p>
<p style="text-align:left;"><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">一．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">安装JDK,配置环境JAVA环境变量</span></strong></p>
<p style="text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">exportJAVA_HOME=/home/jdk1.6.0_27</span></p>
<p style="text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">exportJRE_HOME=/home/jdk1.6.0_27/jre</span></p>
<p style="text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">exportANT_HOME=/home/apache-ant-1.8.2</span></p>
<p style="text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">二．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">安装Hadoop-1.0.3</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p style="text-indent:0;"><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">下载hadoop文件，地址为：http://hadoop.apache.org/coases.html，下载完成后解压hadoop-1.0.3.tar.gz</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">sudotar -xzf hadoop-1.0.3.tar.gz</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">配置Hadoop环境变量</span></strong></p></li>
</ol>
<p style="margin-left:24px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">exportHADOOP_INSTALL=/home/hadoop-1.0.3</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">exportPATH=$PATH:$HADOOP_INSTALL/bin</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">3.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">查看hadoop版本</span></strong></p></li>
</ol>
<p style="margin-left:24px;text-indent:25px;"><span style="font-family:'微软雅黑', sans-serif;">输入 hadoop version命令后输入下图，则安装hadoop成功</span></p>
<p><br></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">4.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">修改配置文件</span></strong></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">a)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">解压hadoop-1.0.3/</span><span style="font-family:'微软雅黑', sans-serif;">hadoop-core-1.0.3.jar</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">b)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">去解压后的hadoop-core-1.0.3文件夹下,复制文件core-default.xml，hdfs-default.xml，mapred-default.xml三个文件到hadoop-1.0.3/conf/下,删除hadoop-1.0.3/conf/文件夹下的core-site.xml，hdfs-site.xml，mapred-site.xml，将复制过来的三个文件的文件名中的default修改为site</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">c)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">在hadoop-1.0.3文件夹同级创建文件夹hadoop，打开core-site.xml文件,修改属性节点下的name节点为hadoop.tmp.dir对应的value节点，修改为/home/${user.name}/hadoop/hadoop-${user.name}这样hadoop生成的文件会放入这个文件夹下.修改name节点为fs.default.name对应的value节点，修改为hdfs://localhost:9000/</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开mapred-site.xml文件，修改property节点下name为mapred.job.tracker对应的的value， 改为：localhost:9001</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">三．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">安装ssh</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">执行命令安装ssh：sudo apt-get install ssh</span></strong></p></li>
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">基于空口令创建一个新SSH密钥，以启用无密码登陆</span></strong></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">a)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">ssh-keygen-t rsa -P '' -f ~/.ssh/id_rsa</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;b)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">cat ~/.ssh/id_rsa.pub&gt;&gt; ~/.ssh/authorized_keys</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">3.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">测试</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">sshlocalhost</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入yes</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">再次输入ssh localhost</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">成功之后，就不需要密钥</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">四．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">格式化HDFS文件系统</span></strong></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">输入指令:</span></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">hadoopnamenode &#xfffd;format</span></p>
<p style="text-indent:0;"><br></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">五．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">启动和终止守护进程</span></strong></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">启动和终止HDFS和MapReduce守护进程，键入如下指令</span></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">启动start-all.sh(start-dfs.sh,start-mapred.sh)</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">出错了，JAVA_HOME is not set</span></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">需要修改文件，打开hadoop-1.0.3/conf/</span><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">hadoop-env.sh</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">将红线以内部分注释解开,修改为本机JAVA_HOME</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">再次执行启动命令start-all.sh</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">停止stop-all.sh(stop-dfs.sh,stop-mapred.sh) </span></p>
<p style="text-indent:0;"><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">到此，hadoop就已经安装完成了</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">六．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">Hadoop</span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">文件系统</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">查看hadoop所有块文件</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令:</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hadoopfsck / -files &#xfffd;blocks</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">此结果显示，hadoop文件系统中，还没有文件可以显示</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">将文件复制到hadoop文件系统中</span></strong></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">a)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">在hadoop文件系统中创建文件夹,执行命令：</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hadoopfs &#xfffd;mkdir docs</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">b)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">复制本地文件到hadoop文件系统中执行命令：</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hadoopfs -copyFromLocal docs/test.txt \</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hdfs://localhost/user/docs/test.txt</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">c)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">复制hadoop文件系统中的文件回本地,并检查是否一致</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">复制:hadoop fs -copyToLocal docs/test.txt docs/test.txt.bat</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">检查:md5 docs/test.txt docs/text.txt.bat</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">检查结果若显示两个md5加密值相同，则文件内容相同。 </span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">d)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">查看HDFS文件列表</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令:</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hadoopfs &#xfffd;ls</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">e)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">再次查看文件系统文件块</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令：</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hadoopfsck / -files &#xfffd;blocks</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">此处为文件备份数量，可以调整，打开hadoop-1.0.3/conf/</span><span style="font-family:'微软雅黑', sans-serif;">hdfs-site.xml</span><span style="font-family:'微软雅黑', sans-serif;">文件,</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">此处修改文件备份数量</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">七．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">安装zookeeper</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp; </span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">准备</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">zookeeper-3.4.3.tar.gz</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">下载地址：</span></p>
<p><a href="http://apache.etoak.com/zookeeper/zookeeper-3.4.3/zookeeper-3.4.3.tar.gz" target="_blank"><span style="font-family:'微软雅黑', sans-serif;">http://apache.etoak.com/zookeeper/zookeeper-3.4.3/zookeeper-3.4.3.tar.gz</span></a></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp; </span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">安装zookeeper</span></strong></p></li>
</ol>
<p style="margin-left:76px;"><span style="font-family:'微软雅黑', sans-serif;">执行命令：tar zookeeper-3.4.3.tar.gz解压安装文件</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">3.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp; </span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">环境变量</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行sudo vim /etc/profile</span></p>
<p style="margin-left:44px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">打开后加入</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">exportZOOKEEPER_HOME=/home/zookeeper-3.4.3</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">exportPATH=$PATH:$ZOOKEEPER_HOME/bin</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令 source&nbsp; /etc/profile 让环境变量生效</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">4.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp; </span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">配置zookeeper</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开zookeeper /conf/coo.cfg</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">###</span><span style="font-family:'微软雅黑', sans-serif;">以下是文件内容</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">#zookeeper</span><span style="font-family:'微软雅黑', sans-serif;">基本时间单元（毫秒）</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">tickTime=2000</span></p>
<p style="margin-left:44px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">#zookeeper</span><span style="font-family:'微软雅黑', sans-serif;">存储持久数据的本地文件系统位置</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">dataDir=/home/xxx/zookeeper</span></p>
<p style="margin-left:44px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">#zookeeper</span><span style="font-family:'微软雅黑', sans-serif;">用户监听客户端连接的端口</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">clientPort=2181</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">###</span><span style="font-family:'微软雅黑', sans-serif;">文件内容结束</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">保存文件后切换到 zookeeper/bin/目录下</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行./zkServer.sh start</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行./zkServer.sh status ，</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">echostat | nc &#xfffd;q 1 localhost</span><span style="font-family:'微软雅黑', sans-serif;">，</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">echostat | nc localhost 2181 </span><span style="font-family:'微软雅黑', sans-serif;">查看状态</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行 echo ruok | nc localhost 2181</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行结果为 imok&nbsp; 是I am ok的意思表示安装并启动成功</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">关闭zookeeper</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">./zkServer.shstop</span></p>
<p style="text-indent:0;"><br></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">八．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">安装hbase</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">准备</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">hbase-0.92.1.tar.gz</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">下载地址：</span></p>
<p><a href="http://labs.mop.com/apache-mirror/hbase/hbase-0.92.1/hbase-0.92.1.tar.gz" target="_blank"><span style="font-family:'微软雅黑', sans-serif;">http://labs.mop.com/apache-mirror/hbase/hbase-0.92.1/hbase-0.92.1.tar.gz</span></a></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">安装hbase</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令 tar hbase-0.92.1.tar.gz解压安装文件</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">3.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">环境变量</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行sudo vim /etc/profile</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开后加入</span></p>
<p style="margin-left:44px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">exportHBASE_HOME=/home/hbase-0.92.1</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">exportPATH=$PATH:$HBASE_HOME/bin</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">执行命令 source&nbsp; /etc/profile 让环境变量生效</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">4.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">配置hbase</span></strong></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">a)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">打开hbase/conf/hbase-env.sh 加入如下内容</span></p></li>
</ol>
<p style="text-indent:13px;"><span style="font-family:'微软雅黑', sans-serif;">export JAVA_HOME=/home/jdk1.6.0_26</span></p>
<p style="text-indent:13px;"><span style="font-family:'微软雅黑', sans-serif;">export HBASE_MANAGERS_ZK=false</span></p>
<p style="text-indent:13px;"><span style="font-family:'微软雅黑', sans-serif;">export HBASE_HOME=/home/hbase-0.92.1</span></p>
<p style="text-indent:13px;"><span style="font-family:'微软雅黑', sans-serif;">export HADOOP_INSTALL=/home/hadoop-1.0.3</span></p>
<p style="text-indent:20px;"><span style="font-family:'微软雅黑', sans-serif;">修改HBASE_OPTS为：exportHBASE_OPTS="$HBASE_OPTS -XX:+HeapDumpOnOutOfMemoryError-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode"</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">b)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">打开hbase/conf/hbase-site.xml加入如下内容</span></p></li>
</ol>
<p style="text-indent:0;"><br></p>
<p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">&nbsp;</span></strong></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;configuration&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;property&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;name&gt;hbase.rootdir&lt;/name&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;value&gt;hdfs://localhost:9000/hbase&lt;/value&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;/property&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;property&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;name&gt;hbase.cluster.distributed&lt;/name&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;value&gt;true&lt;/value&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;/property&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;property&gt;</span></p>
<p style="margin-left:126px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;name&gt;hbase.master&lt;/name&gt;</span></p>
<p style="margin-left:126px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;value&gt;localhost:60000&lt;/value&gt;</span></p>
<p style="margin-left:98px;text-indent:28px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;/property&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp; &lt;property&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;name&gt;hbase.master.port&lt;/name&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;value&gt;60000&lt;/value&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;description&gt;Theport master should bind to.&lt;/description&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp; &lt;/property&gt;</span></p>
<p style="margin-left:98px;"><span style="font-family:'微软雅黑', sans-serif;">&lt;/configuration&gt;</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开regionservers文件放入localhost</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">先把hadoop启动起来 执行start-all.sh</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">转入hbase/bin/目录下</span></p>
<p style="text-indent:8px;"><span style="font-family:'微软雅黑', sans-serif;">执行./start-hbase.sh 脚本,启动hbase</span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="font-family:'微软雅黑', sans-serif;">启动成功后执行hbase shell进去shell模式下</span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="font-family:'微软雅黑', sans-serif;">执行create ‘test’, ‘data’创建表。执行结果如下：</span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="font-family:'微软雅黑', sans-serif;">执行list查询表，执行结果如下：</span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></p>
<p><span style="font-family:'微软雅黑', sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span><span style="font-family:'微软雅黑', sans-serif;">这样我们就安装成功了</span></p>
<p><strong><span style="font-size:20px;font-family:'微软雅黑', sans-serif;">九．<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">Eclipse</span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">结合MapReduce</span></strong></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">1.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">准备</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">Eclipse&nbsp; IDE version=3.7</span></p>
<p style="text-indent:8px;"><span style="font-family:'微软雅黑', sans-serif;">org.apache.hadoop.eclipse.merit_1.1.0.jar</span></p>
<p style="text-indent:8px;"><span style="font-family:'微软雅黑', sans-serif;">将org.apache.hadoop.eclipse.merit_1.1.0.jar复制到eclipse安装目录的Plugin目录下</span></p>
<p style="text-indent:8px;"><span style="font-family:'微软雅黑', sans-serif;">启动hadoop，start-all.sh</span></p>
<p style="text-indent:8px;"><span style="font-family:'微软雅黑', sans-serif;">启动eclipse</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">2.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:21px;font-family:'微软雅黑', sans-serif;">配置MapReduce</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">点击菜单栏的Window</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">preferences</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">HadoopMap/Reduce</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">配置hadoop目录</span></p>
<p style="text-indent:0;"><br></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">3.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">打开MapReduce视图</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开IDE的Window</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">ShowView</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Other</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">打开Map/Reduce Locations</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">在视图中创建一个新的Hadoop Location</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">将Map/Reduce Master(Job Tracker的IP和端口)中的配置，Host和Port修改为配置文件hadoop-1.0.3/conf/mapred-site.xml中的mapred.job.tracker属性的值</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">选中DFS Master(Name Node的IP和端口)，配置其中Host和Port，修改为配置文件hadoop-1.0.3/conf/core-site.xml中的fs.default.name属性的值</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">username</span><span style="font-family:'微软雅黑', sans-serif;">默认的就行了，</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">点击finish</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">项目栏出现树状菜单，标识设置成功</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">这样就可以在eclipse中使用hadoop的文件系统了</span></p>
<p style="text-indent:0;"><br></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">4.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">创建Map/Reduce项目</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">File</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">New</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Other</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入Map/Reduce Project</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">next</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入项目名称</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">finish</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">创建成功</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">创建Mapper和Reduce类，</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">Mapper</span><span style="font-family:'微软雅黑', sans-serif;">的创建：</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">选中项目中的包，右键</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">New</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Other</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入Mapper</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Next</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入类名</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">finish</span><span style="font-family:'微软雅黑', sans-serif;">，该类自动继承</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">org.apache.hadoop.mapred.MapReduceBase</span><span style="font-family:'微软雅黑', sans-serif;">这个类</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">Reduce</span><span style="font-family:'微软雅黑', sans-serif;">的创建和Mapper是一样的</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">最后导入WordCount这个类此类位置</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">从hadoop自带的$HADOOP_HOME/src/examples/org/apache/hadoop</span><span style="font-family:'微软雅黑', sans-serif;">examples/</span><span style="font-family:'微软雅黑', sans-serif;">WordCount.java</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">将此文件copy到刚创建的MapReduce项目中</span></p>
<ol style="list-style-type:decimal;" class="list-paddingleft-2">
 <li><p><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">5.<span style="font-weight:normal;font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;</span></span></strong><strong><span style="font-size:19px;font-family:'微软雅黑', sans-serif;">运行WordCount</span></strong></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">点击项目右键</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Run As</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">Run on Hadoop</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入WordCount</span><span style="font-family:Wingdings;">à</span><span style="font-family:'微软雅黑', sans-serif;">点击OK</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">选中刚刚配置的Map/Reduce Location点击finish</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">控制台输出</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">这个表示缺少两个参数</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">点击RunConfigurations,选中Arguments</span></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">编写两个参数，一个输入文件所在目录，一个输出文件所在目录，输出文件所在目录项目会自动帮我们创建，输入文件目录需要我们自己手动创建.</span></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">首先在local创建一个文件夹，再创建两个或两个以上文件</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">a)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">mkdirinput</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">b)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">cdinput</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">c)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">touchfile1</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">d)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">touchfile2</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">e)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">打开文件1&nbsp; vim file1，输入”Hello World”, 打开文件2&nbsp; vim file2</span></p></li>
</ol>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">输入”Hello Hadoop”</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">f)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">cd ..</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">g)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">将input文件夹下的文件放入hadoop文件系统中hadoop fs &#xfffd;put input input</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">h)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">在Arguments中的Program arguments中输入两个参数，一个输入文件夹，一个输出文件夹，/user/input /user/output,输出文件夹项目会帮我们创建</span></p></li>
 <li><p><span style="font-family:'微软雅黑', sans-serif;">i)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">再次运行项目</span></p></li>
</ol>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">这样证明项目正常运行了</span></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">j)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">刷新eclipse中的文件系统目录</span></p></li>
</ol>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><br></p>
<ol style="list-style-type:lower-alpha;" class="list-paddingleft-2">
 <li><p><span style="font-family:'微软雅黑', sans-serif;">k)<span style="font-size:9px;font-family:'Times New Roman';">&nbsp;&nbsp;&nbsp; </span></span><span style="font-family:'微软雅黑', sans-serif;">双击part-r-00000 </span></p></li>
</ol>
<p style="text-indent:0;"><br></p>
<p style="text-indent:0;"><span style="font-family:'微软雅黑', sans-serif;">这样表示input文件夹下的所有文件包含内容信息</span></p>
<p><br></p>
<p><span style="font-family:'微软雅黑', 'Microsoft YaHei';"></span><br></p>
<p>本文出自 “<a href="http://maxli.blog.51cto.com">攻城狮</a>” 博客，请务必保留此出处<a href="http://maxli.blog.51cto.com/7023628/1643450">http://maxli.blog.51cto.com/7023628/1643450</a></p>
