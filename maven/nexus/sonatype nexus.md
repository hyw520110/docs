#nexus3安装前提
安装jdk1.8
#安装
下载解压，配置JAVA_HOME环境变量或修改bin/nexus指定JAVA_HOME

安装服务

	vi /etc/profile
	export NEXUS_HOME="/usr/local/nexus"
	vi /usr/local/nexus/bin/nexus.rc
	run_as_user="root"
	ln -s /usr/local/nexus/bin/nexus /etc/init.d/nexus
	chkconfig --add nexus
	chkconfig --levels 345 nexus on
	service nexus start
	tail -f /usr/local/sonatype-work/nexus/log/nexus.log

开放端口

	vim /etc/sysconfig/iptables
	-A INPUT -p tcp -m state --state NEW -m tcp --dport 8081 -j ACCEPT

#配置



##端口配置

Nexus3.x的配置和Nexus1.x、Nexus2.x的配置完全不同，需要修改“NEXUS_HOME\sonatype-work\nexus3\etc”目录下的“nexus.properties”配置文件，修改其中的端口即可

更改虚拟节点

	nexus-context-path=/nexus

#工作目录
	
	-Dkaraf.data=/opt/sonatype-work/nexus3
	-Djava.io.tmpdir=/opt/sonatype-work/nexus3/tmp
	-XX:LogFile=/opt/sonatype-work/nexus3/log/jvm.log
##用户
安装成功后有两个默认账号admin、anonymous，其中admin具有全部权限默认密码admin123；anonymous作为匿名用户，只具有查看权限。 

##仓库

pepositories说明

- maven-central：maven中央库，默认从https://repo1.maven.org/maven2/拉取jar 
- maven-releases：私库发行版jar 
- maven-snapshots：私库快照（调试版本）jar 
- maven-public：仓库分组，把上面三个仓库组合在一起对外提供服务，在本地maven基础配置settings.xml中使用。


nexus的仓库类型分为以下四种：

- group: 仓库组，用于方便开发人员自己设定的仓库；
- proxy：代理，从远程中央仓库中寻找数据的仓库（可以点击对应的仓库的Configuration页签下Remote Storage Location属性的值即被代理的远程仓库的路径）；
	- 代理中央Maven仓库，当PC访问中央库的时候，先通过Proxy下载到Nexus仓库，然后再从Nexus仓库下载到PC本地。这样的优势只要其中一个人从中央库下来了，以后大家都是从Nexus私服上进行下来，私服一般部署在内网，这样大大节约的宽带
	- 创建proxy:create repository-->maven2(proxy)
- hosted：宿主，内部项目的发布仓库（内部开发人员，发布上去存放的仓库）；
	- Hosted有三种方式，Releases、SNAPSHOT、Mixed
		Releases: 一般是已经发布的Jar包
		Snapshot: 未发布的版本
		Mixed：混合的
		- 创建同上，注意事项：Deployment Pollcy: 需要把策略改成“Allow redeploy”。	
- virtual：虚拟
Policy(策略):表示该仓库为发布(Release)版本仓库还是快照(Snapshot)版本仓库；

Nexus仓库分类的概念：

1）Maven可直接从宿主仓库下载构件,也可以从代理仓库下载构件,而代理仓库间接的从远程仓库下载并缓存构件 

2）为了方便,Maven可以从仓库组下载构件,而仓库组并没有时间的内容

仓库配置参考：http://books.sonatype.com/nexus-book/reference3/admin.html#admin-repositories


##Support
包含日志及数据分析。

##System
主要是邮件服务器，调度的设置地方



      
    http://repository.jboss.org/maven2/  
    http://repository.jboss.org/nexus/content/repositories/releases/  
   
    http://developer.k-int.com/maven2/  

    
    http://repository.exoplatform.org/content/groups/public/  

#更新索引
##自动更新

打开Repositories标签，选中远程仓库并打开Configuration，将Download Romote Location 设置为true

在远程仓库上右键选择Update Index，Nexus会自动建立一条任务计划；一般远程仓库都比较大，构建会比较多，索引文件会很大，像http://repo1.maven.org/maven2 就有几百M，因此需要的时间就比较长。

可以进入Scheduled Tasks查看任务的执行情况，当执行完成时，远程仓库的索引就已经建立完毕了。


##手动更新

通过在线更新索引的方式,所消耗的时间较长,手动更新索引文件

访问http://repo.maven.apache.org/maven2/.index/下载中心仓库最新版本的索引文件，在一长串列表中，我们需要下载如下两个文件（一般在列表的末尾位置）

	nexus-maven-repository-index.gz
	nexus-maven-repository-index.properties
下载完成之后最好是通过md5或者sha1校验一下文件是否一致，因为服务器并不在国内，网络传输可能会造成文件损坏。

解压这个索引文件，虽然后缀名为gz，但解压方式却比较特别，我们需要下载一个jar包[indexer-cli-5.1.1.jar](http://maven.aliyun.com/nexus/service/local/repositories/central/content/org/apache/maven/indexer/indexer-cli/5.1.1/indexer-cli-5.1.1.jar)，我们需要通过这个特殊的jar来解压这个索引文件

注：indexer-cli-5.1.1.jar是专门用来解析和发布索引的工具，关于它的详细信息请见这里。前往maven中央仓库下载indexer-cli-5.1.1.jar
将上面三个文件（.gz & .properties & .jar）放置到同一目录下，运行如下命令

	java -jar indexer-cli-5.1.1.jar -u nexus-maven-repository-index.gz -d indexer  

等待程序运行完成之后可以发现indexer文件夹下出现了很多文件，将这些文件放置到{nexus-home}/sonatype-work/nexus/indexer/central-ctx目录下，重新启动nexus

	./nexus restart  

两种方式，只要Browse_Index后看到许多文件的话就说明更新成功
#FAQ

	max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]

解决：

	vim /etc/security/limits.conf
	redhat hard nofile 65536  
	redhat soft nofile 65536  