# 简介

hadoop2.x是在hadoop0.23之后发行的正式版2.2。 
本身是来自于lucene和nutch，在ggl的论文MR、GFS、BigTable组合下生成了hadoop，对海量数据进行分析处理。

相比于hadoop1.x，2.x版本新增加了一个资源调度模块yarn，正是2.x版本的最强之处。2.x版本分为4个模块，hadoop common公共模块即1.x的hadoop core核心模块、hadoop hdfs存储模块、hadoop yarn调度模块、hadoop MR数据处理模块。

hadoop hdfs是一个高性能分布式存储系统。大数据量文件按块划分存储到机柜机架集群中。分布式系统具有高度的内聚性和透明性。hdfs系统中分为name node和datanodes两种节点。namenode存储文件的元数据如文件名，文件目录结构，文件属性（生成时间，文件权限），以及文件的块列表和块所在datanode。datanode是集群中的任一计算机，其功能为在本地文件系统存储文件的块数据以及块数据的校验和。通常集群中存在secondary namenode用来监控HDSF状态的辅助后台程序，每隔一段时间获取HDFS元数据的快照，作为灾难备份，在主namenode发生问题时继续管理datanode。

hadoop yarn是一个资源调度管理系统。yarn分为resource manager和node manager两种节点。客户端操作请求进入resourcemanager，在RM中生成applicationmaster数据appms。 
appms中包含数据的元信息，以及为请求所分配的资源使用方案。 
RM将APPMS的信息分配到Nodemanager中，NM处理RM发来的信息，以及APPMS中的信息，分配任务，生成container来执行任务。


# 安装

## windows

Hadoop 2.0及以后的版本可以直接在windows上跑, 不用cygwin了

http://hadoop.apache.org/releases.html

下载解压

windows下还要下载的一个第三方工具winutils，下载地址:

	https://github.com/steveloughran/winutils
注意比如你hadoop下载的是2.8版本, 那么这个类库你也要用2.8的. 下载完了把里面所有的dll和exe文件都覆盖到hadoop目录的bin子目录下去.

## linux:

	vim  etc/hadoop/hadoop-env.sh 
	export JAVA_HOME=/usr/java/latest
	bin/hadoop
为方便操作可配置HADOOP_HOME并设置PATH环境变量，设置hdfs的alias

	vi /etc/profile
	alias hdfs='hadoop fs'
	source /etc/profile


集群安装

查看是否安装lvm工具

	rpm -qa| grep lvm
虚拟机挂在3块硬盘（20G）后，启动虚拟机查看

	fdisk -l
可以看到3个硬盘(sdb、sdc、sdd)
	
创建物理卷

pvcreate指令用于将物理硬盘分区初始化为物理卷，以便被LVM使用

	pvcreate /dev/sdb
	pvcreate /dev/sdc
	pvcreate /dev/sdd
查看物理卷是否创建成功

	pvdisplay
创建卷组和添加新的物理卷到卷组

创建一个卷组

	  vgcreate test_document /dev/sdb
vgcreate 命令第一个参数是指定该卷组的逻辑名，后面参数是指定希望添加到该卷组的所有分区和磁盘

将sdc物理卷添加到已有的卷组

	vgextend test_document /dev/sdc
将sdd物理卷添加到已有的卷组
	
	vgextend test_document /dev/sdd
查看卷组大小

	vgdisplay test_document
激活卷组

	vgchange -a y test_document
创建逻辑卷
	
	lvcreate -L5120 -n lvhadooptest_document
在卷组test_document上创建名字为lvhadoop，大小为5120M的逻  辑卷，并且设备入口为/dev/test_document/lvhadoop ,test_document为卷组名，lvhadoop为逻辑卷名
	
	lvcreate -L51200 -n lvdatatest_document
在卷组test_document上创建名字为lvdata，大小为51200M的逻  辑卷，并且设备入口为/dev/test_document/lvdata ,test_document为卷组名，lvdata为逻辑卷名

注意，如果分配过大的逻辑卷lvcreate -L10240 -n lvhadoop test_document会提示剩余空间不足，此时可用命令vgdisplay去产查看剩余空间的大小。	
	
创建文件系统

	mkfs -t ext4/dev/test_document/lvhadoop

	mkfs -t ext4/dev/test_document/lvdata
创建文件夹

	mkdir -p /hadoop
	mkdir -p /data
挂载

	mount /dev/test_document/lvhadoop /hadoop
	mount /dev/test_document/lvdata /data

	df -kh
挂载配置写入fstab分区表(重启后可以看到挂载设备)

	vi /etc/fstab
	/dev/test_document/lvhhadoop /hadoop ext4 defaults 1 1
	/dev/test_document/lvdata /data ext4 defaults 1 1
在文件末尾加入以上2行，按esc，shift+: 输入x回车，reboot重启

创建用户组、用户

	groupadd -g 3000 hadoop
	useradd -u3001 -g hadoop hadoop
	passwd hadoop    
	chown -R hadoop:hadoop /hadoop
	chown -R hadoop:hadoop /data
	
	ls -l / | grep hadoop
规划1个主节点，2个从节点

下载hadoop压缩包到/hadoop目录下，切换到hadoop用户解压

克隆虚拟机hd001、hd002

修改主机名

	hostnamectl set-hostname hm

重复以上操作，主机名分别改为hd001、hd002

查看赋值MAC地址

	cat/etc/udev/rules.d/70-persistent-net.rules

分别修改3台虚拟机的ip、MAC地址

	vi /etc/sysconfig/network-scripts/ifcfg-eth0
	修改IPADDR、HWADDR
	service network restart

登录3台虚拟机，修改映射关系（配置3组:ip 主机名）

	vi /etc/hosts
	
	192.168.144.11 node1
	192.168.144.12 node2
	192.168.144.13 node3
配置SSH免密登录

为什么需要免密码登录?在任何一个机器上敲命令启动所有节点,也就是启动整个集群,不然需要逐个启动节点

查看是否安装ssh和ssh-keygen

	which ssh
	which ssh-keygen

如未安装www.openssh.com下载安装

hadoop用户登录执行:

	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	chmod 0600 ~/.ssh/authorized_keys 
3台虚拟机开启ssh证书登录

	vi /etc/ssh/sshd_config
	PubkeyAuthentication yes
传送	authorized_keys到其他2台虚拟机的/root/.ssh目录
	
	scp ~/.ssh/id_rsa.pub   root@node2:~
	scp ~/.ssh/id_rsa.pub   root@node3:~

	[root@node2 ~]# cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
	[root@node3 ~]# cat ~/id_rsa.pub >> ~/.ssh/authorized_keys

SSH免密码登录验证

	ssh hd001 
	ssh hd002 
修改集群配置文件

hadoop用户3台虚拟机上操作

	mkdir -p /data/tmp
	mkdir -p /data/name
	mkdir -p /data/data
	cd /data
	ls
进入hadoop配置文件目录(xxx/etc/hadoop)	

	vi hadoop-env.sh
	export JAVA_HOOME=/usr/java/jdk1.8

	vi core-site.xml
		<property>
			<name>fs.default.name</name>
			<value>hdfs://hm:9000</value>
		</property>
		<property>
			<name>hadoop.tmp.dir</name>
			<value>/data/tmp</value>
		</property>

	vi hdfs-site.xml
		<property>
			<name>fs.name.dir</name>
			<value>/data/name</value>
		</property>
		<property>
			<name>dfs.data.dir</name>
			<value>/data/data</value>
		</property>
		<property>
			<name>dfs.replication</name>
			<value>2</value>
		</property>

		<property>
			<name>dfs.namenode.secondary.http-address</name>
			<value>hm:9001</value>
		</property>

		vi mapred-site.xml
		<property>
			<name>mapred.job.tracker</name>
			<value>hm:9001</value>
		</property>
		
		cp mapred-queues.xml.template mapred-queues.xml
		
		vi slaves
		hd001
		hd002
同步时钟

	ntpdate
分发hadoop到其他2台虚拟机

以hadoop用户格式化hdfs

	bin/hadoop namenode -format
格式化出错

- 查看端口9000占用 netstat -anp|grep 9000
- 只能格式化1次，再次格式化会需要将根目录下清空，在新建data、name、tmp文件夹

启动hadoop系统（1.x在bin目录下，2.x在sbin目录下）


	start-all.sh
检查机器状态

	hadoop dfsadmin -report
网页监控 localhost:8088

# 目录结构

bin目录

- hadoop 用于执行hadoop脚本命令，被hadoop-daemon.sh调用执行，也可以单独执行，一切命令的核心
- hadoop-config.sh Hadoop的配置文件
- hadoop-daemon.sh 通过执行hadoop命令来启动/停止一个守护进程(daemon)。该命令会被bin目录下面所有以“start”或“stop”开头的所有命令调用来执行命令，hadoop-daemons.sh也是通过调用hadoop-daemon.sh来执行优命令的，而hadoop-daemon.sh本身由是通过调用hadoop命令来执行任务。
- hadoop-daemons.sh 通过执行hadoop命令来启动/停止多个守护进程(daemons)，它也是调用hadoop-daemon.sh来完成的。
- rcc The Hadoop record compiler
- slaves.sh 该命令用于向所有的slave机器上发送执行命令
- start-all.sh 全部启动，它会调用start-dfs.sh及start-mapred.sh
- start-balancer.sh 启动balancer
- start-dfs.sh 启动Namenode、Datanode及SecondaryNamenode
- start-jobhistoryserver.sh 启动Hadoop任务历史守护线程，在需要执行历史服务的机器上执行该命令。
- start-mapred.sh 启动MapReduce
- stop-all.sh 全部停止，它会调用stop-dfs.sh及stop-mapred.sh
- stop-balancer.sh 停止balancer
- stop-dfs.sh 停止Namenode、Datanode及SecondaryNamenode
- stop-jobhistoryserver.sh 停止Hadoop任务历史守护线程
- stop-mapred.sh 停止MapReduce
- task-controller 任务控制器，这不是一个文本文件，没有被bin下面的shell调用

conf目录

- capacity-scheduler.xml
- configuration.xsl
- core-site.xml Hadoop核心全局配置文件，可以其它配置文件中引用该文件中定义的属性，如在hdfs-site.xml及mapred-site.xml中会引用该文件的属性。该文件的模板文件存在于$HADOOP_HOME/src/core/core-default.xml，可将模板文件拷贝到conf目录，再进行修改。
- fair-scheduler.xml
- hadoop-env.sh Hadoop环境变量
- hadoop-metrics2.properties
- hadoop-policy.xml
- hdfs-site.xml HDFS配置文件，该模板的属性继承于core-site.xml。该文件的模板文件存在于$HADOOP_HOME/src/hdfs/hdfs-default.xml，可将模板文件拷贝到conf目录，再进行修改。
- log4j.properties Log4j的日志属于文件
- mapred-queue-acls.xml MapReduce的队列
- mapred-site.xml MapReduce的配置文件，该模板的属性继承于core-site.xml。该文件的模板文件存在于$HADOOP_HOME/src/mapred/mapredd-default.xml，可将模板文件拷贝到conf目录，再进行修改。
- masters 用于设置所有secondaryNameNode的名称或IP，每一行存放一个。如果是名称，那么设置的secondaryNameNode名称必须在/etc/hosts有ip映射配置。
- slaves 用于设置所有slave的名称或IP，每一行存放一个。如果是名称，那么设置的slave名称必须在/etc/hosts有ip映射配置。
- ssl-client.xml.example
- ssl-server.xml.example
- taskcontroller.cfg
- task-log4j.properties
 

# 配置
在hadoop目录下的etc/hadoop下找到大量配置文件, 文件后缀名为sh的是linux环境用的, cmd的就是windows的脚本

先要配置hadoop-env.cmd/hadoop-env.sh

	set JAVA_HOME=D:\Java\jdk1.8.0_77
注意安装路径最好不要带空格

此外还最好修改HADOOP_HEAP_SIZE、HADOOP_PID_DIR配置

core-site.xml
	
	<configuration>
	        <property>
	                <name>fs.default.name</name>
	                <value>hdfs://localhost:9000</value>
	        </property>
	</configuration>

参数：

- fs.default.name 默认值file:///,NameNode的URI，如：hdfs://locahost:9000/
- hadoop.tmp.dir 默认值/tmp/hadoop-${user.name}，/tmp可能会被系统自动清理掉,生产环境中建议修改，指定的目录如不存在，需先手动创建
- hadoop.native.lib 默认值true，是否使用hadoop的本地库
- hadoop.http.filter.initializers 默认值空，设置Filter初使器，这些Filter必须是hadoop.http.filter.initializers的子类，可以同时设置多个，以逗号分隔。这些设置的Filter，将会对所有用户的jsp及servlet页面起作用，Filter的顺序与配置的顺序相同。


参考:http://blog.csdn.net/bluetropic/article/details/9493995

预先建立好datanode和namenode两个目录

Datanode:存储数据块，负责客户端对数据块的io请求

namenode负责管理hdfs中文件块的元数据，响应客户端请求，管理datanode上文件block的均衡，维持副本数量

hdfs-site.xml 

可通过将$HADOOP_HOME/src/hdfs/hdfs-default.xml中的文件拷贝过来

	<configuration>
        <property>
                <name>dfs.replication</name>
                <value>1</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/hadoop/data/dfs/namenode</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:/hadoop/data/dfs/datanode</value>
        </property>
	</configuration>

mapred-site.xml（mapred-site.xml.template去掉后缀而来）
	
	<configuration>
	        <property>
	           <name>mapreduce.framework.name</name>
	           <value>yarn</value>
	        </property>
	</configuration>
参数：

- mapred.job.tracker 配置JobTracker，以Host和IP的形式，示例：localhost:9001
- mapred.system.dir MapReduce框架在HDFS存放系统文件的路径，必须能够被server及client访问得到，默认值：${hadoop.tmp.dir}/mapred/system
 
- mapred.local.dir MapReduce框架在本地的临时目录，可以是多个，以逗号作分隔符，多个路径有助于分散IO的读写，默认值：
${hadoop.tmp.dir}/mapred/local
 
- mapred.tasktracker.{map|reduce}.tasks.maximum 在同一台指定的TaskTacker上面同时独立的执行的MapReduce任务的最大数量，默认值是2（2个maps及2个reduces），这个与你所在硬件环境有很大的关系，可分别设定。如：2
- dfs.hosts/dfs.hosts.exclude 允许/排除的NataNodes，如果有必要，使用这些文件控制允许的DataNodes。
 
- mapred.hosts/mapred.hosts.exclude 允许/排除的MapReduces，如果有必要，使用这些文件控制允许的MapReduces。
 
- mapred.queue.names 可用于提交Job的队列，多个以逗号分隔。MapReduce系统中至少存在一个名为“default”的队列，默认值就是“default”。Hadoop中支持的一些任务定时器，如“Capacity Scheduler”，可以同时支持多个队列，如果使用了这种定时器，那么使用的队列名称就必须在这里指定了，一旦指定了这些队列，用户在提交任务，通过在任务配置时指定“mapred.job.queue.name”属性将任务提交到指定的队列中。
这些属于这个队列的属性信息，需要有一个单独的配置文件来管理。如：default
- mapred.acls.enabled 这是一个布尔值，用于指定授权用于在执行队列及任务操作时，是否需要校验队列及任务的ACLs。如果为true，在执行提交及管理性的任务时会检查队列的ACL，在执行授权查看及修改任务时任务的会检查任务ACLs。队列的ACLs通过文件mapred-queue-acls.xml中的mapred.queue.queue-name.acl-name这样格式的参数进行指定，queue-name指的是特定的队列名称；任务的ACLs在mapred中会有说明。
默认值为false。

yarn-site.xml

	<configuration>
        <property>
           <name>yarn.nodemanager.aux-services</name>
           <value>mapreduce_shuffle</value>
        </property>
        <property>
           <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
           <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
	</configuration>
运行hadoop:

格式化namenode,bin目录下执行

	hadoop namenode -format   

sbin目录下执行
	
	start-dfs.cmd   #先启动dfs  
	start-yarn.cmd  #再启动yarn  
	      
	start-all.cmd  #等于上面两条命令的组合  
通过jps命令可以看到4个进程,如果报/tmp下某些文件没有权限, 可以以管理员身份来运行cmd, 去运行上面的脚本.



用浏览器访问localhost:8088查看mapreduce任务，访问localhost:50070->Utilites->Browse the file system看hdfs文件

如果重启hadoop无需再格式化namenode，只要stop-all.cmd或
	  
	stop-dfs.cmd  
	stop-yarn.cmd  
启动再执行start-all.cmd就可以了 



# 测试Hadoop

一个简单的求每年温度最大值的程序。

准备两个文本测试数据

准备两个名为data1.txt及data2.txt的文件，用于做为计算的输入数据，将其放于maven工程的resources目录下的data目录：

	data1.txt
	1999 10
	1999 20
	1999 25
	2000 21
	2000 22
	2000 18
	2000 40
	2001 45
	2001 65
	2002 90
	2002 89
	2002 70
	2003 40
	2003 80
	
	data2.txt
	1999 40
	1999 10
	1999 25
	2000 51
	2000 22
	2000 18
	2000 40
	2001 95
	2001 65
	2002 90
	2002 19
	2002 70
	2003 100
	2003 80
每行有两列，分别表示年份和温度。

来自于《Hadoop权威指南（第二版）》测试代码：
	
	import java.io.IOException;
	 
	import org.apache.hadoop.fs.Path;
	import org.apache.hadoop.io.IntWritable;
	import org.apache.hadoop.io.LongWritable;
	import org.apache.hadoop.io.Text;
	import org.apache.hadoop.mapreduce.Job;
	import org.apache.hadoop.mapreduce.Mapper;
	import org.apache.hadoop.mapreduce.Reducer;
	import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
	import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
	 
	public class MaxTemperature {
	 
	    static class MaxTemperatureMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
	 
	        @Override
	        public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
	            String line = value.toString();
	            if (line == null || line.trim().equals("")) {
	                return;
	            }
	            String[] arr = line.split(" ");
	            String year = arr[0];
	            int airTemperature = Integer.parseInt(arr[1]);
	            context.write(new Text(year), new IntWritable(airTemperature));
	        }
	    }
	 
	    static class MaxTemperatureReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
	 
	        @Override
	        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
	            int maxValue = Integer.MIN_VALUE;
	            for (IntWritable value : values) {
	                maxValue = Math.max(maxValue, value.get());
	            }
	            context.write(key, new IntWritable(maxValue));
	        }
	    }
	 
	    public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {
	        Job job = new Job();
	        job.setJarByClass(MaxTemperature.class);
	        FileInputFormat.addInputPath(job, new Path(getPath("data")));
        	FileOutputFormat.setOutputPath(job, new Path(getPath("output")));
	        job.setMapperClass(MaxTemperatureMapper.class);
	        job.setReducerClass(MaxTemperatureReducer.class);
	        job.setOutputKeyClass(Text.class);
	        job.setOutputValueClass(IntWritable.class);
	 
	        System.exit(job.waitForCompletion(true) ? 0 : 1);
	    }
		private static String getPath(String path) {
        	return new File("src/main/resources/",path).getAbsolutePath();
    	}
	}

加入依赖：

	<properties>
		<hadoop.version>2.8.0</hadoop.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.apache.hadoop</groupId>
			<artifactId>hadoop-common</artifactId>
			<version>${hadoop.version}</version>
		</dependency>
		<dependency>
			<groupId>org.apache.hadoop</groupId>
			<artifactId>hadoop-hdfs</artifactId>
			<version>${hadoop.version}</version>
		</dependency>
		<dependency>
			<groupId>org.apache.hadoop</groupId>
			<artifactId>hadoop-client</artifactId>
			<version>${hadoop.version}</version>
		</dependency>
	</dependencies>
运行报错：

	
	org.apache.hadoop.io.nativeio.NativeIO$Windows.access(NativeIO.java:557)
解决：

	将winutils中的hadoop.dll拷贝到C:\Windows\System32下 
如错误依旧，可修改NativeIO源码，注释557行，直接return true;重新打包发布到本地maven仓库
 
## 执行

执行的方式有两种，直接通过java命令和$HADOOP_HOME/bin/hadoop命令，不过不同的执行方式有一定的区别

### java命令

	java -cp ${classpath} hadoop/MaxTemperature /home/data /home/output
其中classpath是依赖的所有jar包；/home/data是本地输入文件路径；/home/output是输出路径

### hadoop命令执行

有如下要求：

- 输入文件必须在hdfs上

		hadoop fs -copyFromLocal data /hadoop/data
	- 其中data是输入文件目录；/hadoop/data是hdfs目录，查看是否拷贝成功

		hadoop fs -ls /hadoop/data
- 输出文件必须在hdfs上
- 需要将class打包成jar（mainfest.mf包含Main-Class）

		hadoop hadoop/MaxTemperature /hadoop/data /hadoop/output
		或者
		hadoop jar maxTemperature.jar /hadoop/data /hadoop/output
执行生成4个文件，其中2个.crc文件是隐藏的，用于crc校验；_SUCCESS是一个空文件，只是用于表示当前操作执行成功；part_r_00000里面存放的就是输出结果

通过Hadoop命令执行，里面多了一个_logs目录，它里面存放了本次用于执行的jar文件以及本次执行Hadoop用到的配置信息文件“*_conf.xml”


http://www.cnblogs.com/wangweiNB/p/5711012.html
		
