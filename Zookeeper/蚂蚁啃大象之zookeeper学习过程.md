<p style="text-align:center;">蚂蚁01啃大象：</p>
<p><br></p>
<p># 本文作者-刘晓涛</p>
<p># 创建时间：2016-1-26:22:30</p>
<p># 完成时间：2016-1-27-23:11</p>
<p># 我不比别人聪明，学习东西也慢，记忆力也好像降低了（奔三了），但我不能放弃学习止步不前！</p>
<p># 写此文章，一 督促自己还有任务没有完成 二：记录学习过程，方便后期查找，加深记忆 三 共同交流探讨</p>
<p><br></p>
<p>要啃的大象：</p>
<p>（文章：“使用 Docker，7 个命令部署一个 Mesos 集群”。文章来源于Linux公社网站(www.linuxidc.com) 链接为：http://www.linuxidc.com/Linux/2015-06/118589.htm ）</p>
<p><br></p>
<p>蚂蚁01：下文-all</p>
<p><br></p>
<p>本编文章的目的：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>1 通过zookeeper的Dockerfile复习复习docker</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>2 通过zookeeper的Dockerfile学习zookeeper</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span></p>
<p>该zookeeper镜像信息的地址为：</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://registry.hub.docker.com/u/garland/zookeeper/</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://github.com/sekka1/mesosphere-docker/tree/master/zookeeper</p>
<p>Dockerfile</p>
<pre class="brush:bash;toolbar:false">======================================
#&nbsp;DOCKER-VERSION&nbsp;1.0.1
#&nbsp;VERSION&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.5
#&nbsp;SOURCE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://github.com/jplock/docker-zookeeper
FROM&nbsp;debian:jessie
MAINTAINER&nbsp;Justin&nbsp;Plock&nbsp;&lt;justin@plock.net&gt;
RUN&nbsp;apt-get&nbsp;update&nbsp;&amp;&amp;&nbsp;apt-get&nbsp;install&nbsp;-y&nbsp;openjdk-7-jre-headless&nbsp;wget
RUN&nbsp;wget&nbsp;-q&nbsp;-O&nbsp;-&nbsp;http://apache.mirrors.pair.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz&nbsp;|&nbsp;tar&nbsp;-xzf&nbsp;-&nbsp;-C&nbsp;/opt&nbsp;\
&nbsp;&nbsp;&nbsp;&nbsp;&amp;&amp;&nbsp;mv&nbsp;/opt/zookeeper-3.4.6&nbsp;/opt/zookeeper&nbsp;\
&nbsp;&nbsp;&nbsp;&nbsp;&amp;&amp;&nbsp;cp&nbsp;/opt/zookeeper/conf/zoo_sample.cfg&nbsp;/opt/zookeeper/conf/zoo.cfg&nbsp;\
&nbsp;&nbsp;&nbsp;&nbsp;&amp;&amp;&nbsp;mkdir&nbsp;-p&nbsp;/tmp/zookeeper
ENV&nbsp;JAVA_HOME&nbsp;/usr/lib/jvm/java-7-openjdk-amd64
ADD&nbsp;./run.sh&nbsp;/opt/run.sh
RUN&nbsp;chmod&nbsp;777&nbsp;/opt/run.sh
EXPOSE&nbsp;2181&nbsp;2888&nbsp;3888
WORKDIR&nbsp;/opt/zookeeper
VOLUME&nbsp;["/opt/zookeeper/conf",&nbsp;"/tmp/zookeeper"]
CMD&nbsp;["/opt/run.sh"]
=======================================</pre>
<p>看到此Dockerfile第一眼：我擦，大便系统，没玩过啊，第二眼：没关系，类unix系统，原理通用。</p>
<p><br></p>
<p>大体一看：</p>
<p>&nbsp; 两个RUN命令，得知zookeeper的安装环境需要java和如何安装zookeeper</p>
<p>&nbsp; EXPOSE命令，对外提供三个端口（之前看了一下zookeeper，大概知道zookeeper要三个端口）</p>
<p>&nbsp; ADD命令：擦，加了运行脚本进去，啥脚本啊这是，待我搭好docker环境进入容器拷贝出来之后研究</p>
<p>&nbsp; VOLUME：该命令我只记得是挂载，忘了是挂载 A-B了还是两个都对外挂载，等会创建容器后看看</p>
<p><br></p>
<p>&nbsp; 通过上面的大体一看，可以知道zookeeper如何大概安装运行，配置文件路径，对外提供那个端口服务（软件的原理都差不多：安装运行、配置文件、端口）</p>
<p><br></p>
<p>开始啃大象：</p>
<p>&nbsp; 指定目标：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>1 构建一个Centos7的zookeeper镜像（基本照抄吧）</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>2 制作基于Centos7系统（非镜像）zookeeper的安装部署文档</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>3 尽可能的深入了解zookeeper的原理（zookeeper是什么？可以用来干什么？怎么干的？）</p>
<p>&nbsp;如何去做：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>1 先准备个干净的Centos7环境把zookeeper安装运行一下</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>2 在Centos7安装运行没问题了，可以考虑构建Dockerfile了</p>
<p><span class="Apple-tab-span" style="white-space:pre;"> </span>3 参考百度 谷歌 官方文档 理解zookeeper原理。（之前2步要是遇到问题，我也得去搜去问去解决，我又不是大神）</p>
<p>&nbsp; （刚刚又突然冒出个想法：使用saltstack来安装zookeeper，自己给自己吓一跳，先算了吧，以后再说）</p>
<p><br></p>
<p>目标1-1 下载镜像，并运行（安装docker 略）</p>
<pre class="brush:bash;toolbar:false">systemctl&nbsp;start&nbsp;docker</pre>
<p>导入centos镜像（提前下载好了，不然网络下载太慢，建议翻墙或是用国外主机pull下来后自己保存着）</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;opt]#&nbsp;docker&nbsp;load&nbsp;&lt;&nbsp;centos.tar.gz</pre>
<p>&nbsp;</p>
<p>下载上面文章的zookeeper镜像</p>
<pre class="brush:bash;toolbar:false">docker&nbsp;pull&nbsp;garland/zookeeper</pre>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><br></p>
<p>查看镜像：</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;local]#&nbsp;docker&nbsp;images
REPOSITORY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TAG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IMAGE&nbsp;ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CREATED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VIRTUAL&nbsp;SIZE
docker.io/centos&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;latest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;60e65a8e4030&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4&nbsp;weeks&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;196.6&nbsp;MB
docker.io/garland/zookeeper&nbsp;&nbsp;&nbsp;latest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0e07387e8ab2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;12&nbsp;months&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;378.5&nbsp;MB</pre>
<p>下载完成后，使用该镜像运行容器</p>
<pre class="brush:bash;toolbar:false">docker&nbsp;run&nbsp;-d&nbsp;\
-p&nbsp;2181:2181&nbsp;\
-p&nbsp;2888:2888&nbsp;\
-p&nbsp;3888:3888&nbsp;\
garland/zookeeper</pre>
<p><br></p>
<p>查看运行的容器</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;~]#&nbsp;docker&nbsp;ps
CONTAINER&nbsp;ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IMAGE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;COMMAND&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CREATED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;STATUS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PORTS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NAMES
f09f7d3f100b&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;garland/zookeeper&nbsp;&nbsp;&nbsp;"/opt/run.sh"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;22&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Up&nbsp;22&nbsp;minutes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.0.0.0:2181-&gt;2181/tcp,&nbsp;0.0.0.0:2888-&gt;2888/tcp,&nbsp;0.0.0.0:3888-&gt;3888/tcp&nbsp;&nbsp;&nbsp;lonely_tesla</pre>
<p>进入容器，exit后，容器继续运行的脚本（本脚本来自老男孩教育-讲师找班长）</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;~]#&nbsp;vim&nbsp;enter_doker.sh
#!/bin/bash
PID=`docker&nbsp;inspect&nbsp;--format&nbsp;"{{.State.Pid}}"&nbsp;$1`
nsenter&nbsp;-t&nbsp;$PID&nbsp;-u&nbsp;-i&nbsp;-n&nbsp;-p</pre>
<p>进入容器：</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;~]#&nbsp;./enter_doker.sh&nbsp;f09f7d3f100b
[root@f09f7d3f100b&nbsp;~]#</pre>
<p>run.sh的内容：</p>
<pre class="brush:bash;toolbar:false">=============================================================
#!/bin/sh
ZOO_CFG="/opt/zookeeper/conf/zoo.cfg"
#&nbsp;Output&nbsp;server&nbsp;ID
echo&nbsp;"server&nbsp;id&nbsp;(myid):&nbsp;${SERVER_ID}"
echo&nbsp;"${SERVER_ID}"&nbsp;&gt;&nbsp;/tmp/zookeeper/myid
#&nbsp;Add&nbsp;additional&nbsp;ZooKeeper&nbsp;servers&nbsp;into&nbsp;the&nbsp;zoo.cfg&nbsp;file
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_1}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_2}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_3}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_4}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_5}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_6}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_7}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_8}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_9}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
echo&nbsp;"${ADDITIONAL_ZOOKEEPER_10}"&nbsp;&gt;&gt;&nbsp;${ZOO_CFG}
#&nbsp;Start&nbsp;Zookeeper
/opt/zookeeper/bin/zkServer.sh&nbsp;start-foreground
============================================================</pre>
<p>看到此 有点懵，echo一大堆东西，不知道什么意思啊。</p>
<p>唯一看明白的是要想做zookeeper镜像，那么要让zookeeper运行在前台，参数就是start-foreground</p>
<p><br></p>
<p>先自己在centos7上搭建吧</p>
<pre class="brush:bash;toolbar:false">cd&nbsp;/opt
wget&nbsp;http://apache.mirrors.pair.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz&nbsp;
tar&nbsp;-xzf&nbsp;zookeeper-3.4.6.tar.gz
mv&nbsp;zookeeper-3.4.6&nbsp;zookeeper&nbsp;
cp&nbsp;zookeeper/conf/zoo_sample.cfg&nbsp;zookeeper/conf/zoo.cfg
mkdir&nbsp;-p&nbsp;/tmp/zookeeper</pre>
<p><br></p>
<p>配置文件详解：</p>
<p>zookeeper/conf/zoo_sample.cfg</p>
<pre class="brush:bash;toolbar:false;">tickTime=2000
#&nbsp;zookeeper服务端之间或是服务端与客户端（follower）之间维持心跳的时间间隔（毫秒）
initLimit=10
#&nbsp;这个配置项是用来配置&nbsp;Zookeeper&nbsp;接受客户端（这里所说的客户端不是用户连接&nbsp;Zookeeper&nbsp;服务器的客户端，
而是&nbsp;Zookeeper&nbsp;服务器集群中连接到&nbsp;Leader&nbsp;的&nbsp;Follower&nbsp;服务器）初始化连接时最长能忍受多少个心跳时间间隔数。
当已经超过&nbsp;10&nbsp;个心跳的时间（也就是&nbsp;tickTime）长度后&nbsp;Zookeeper&nbsp;服务器还没有收到客户端的返回信息，
那么表明这个客户端连接失败。总的时间长度就是&nbsp;5*2000=10&nbsp;秒
syncLimit=5
#&nbsp;这个配置项标识&nbsp;Leader&nbsp;与&nbsp;Follower&nbsp;之间发送消息，请求和应答时间长度最长不能超过多少个&nbsp;tickTime&nbsp;的时间长度，
总的时间长度就是&nbsp;2*2000=4&nbsp;秒
dataDir=/tmp/zookeeper
#&nbsp;Zookeeper&nbsp;保存数据的目录，默认情况下，Zookeeper&nbsp;将写数据的日志文件也保存在这个目录里
clientPort=2181
#这个端口就是客户端连接&nbsp;Zookeeper&nbsp;服务器的端口，Zookeeper&nbsp;会监听这个端口，接受客户端的访问请求。
#&nbsp;the&nbsp;maximum&nbsp;number&nbsp;of&nbsp;client&nbsp;connections.&nbsp;increase&nbsp;this&nbsp;if&nbsp;you&nbsp;need&nbsp;to&nbsp;handle&nbsp;more&nbsp;clients
#maxClientCnxns=60
#&nbsp;The&nbsp;number&nbsp;of&nbsp;snapshots&nbsp;to&nbsp;retain&nbsp;in&nbsp;dataDir
#autopurge.snapRetainCount=3
#&nbsp;Purge&nbsp;task&nbsp;interval&nbsp;in&nbsp;hours&nbsp;Set&nbsp;to&nbsp;"0"&nbsp;to&nbsp;disable&nbsp;auto&nbsp;purge&nbsp;feature
#autopurge.purgeInterval=1
#配置集群
server.1=192.168.56.21:2888:3888&nbsp;
server.2=192.168.56.22:2888:3888</pre>
<pre class="brush:bash;toolbar:false">&nbsp;&nbsp;#&nbsp;server.A=B：C：D
&nbsp;&nbsp;其中&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;A&nbsp;是一个数字，表示这个是第几号服务器；
&nbsp;&nbsp;&nbsp;&nbsp;B&nbsp;是这个服务器的&nbsp;ip&nbsp;地址；
&nbsp;&nbsp;&nbsp;&nbsp;C&nbsp;表示的是这个服务器与集群中的&nbsp;Leader&nbsp;服务器交换信息的端口；
&nbsp;&nbsp;&nbsp;&nbsp;D&nbsp;表示的是万一集群中的&nbsp;Leader&nbsp;服务器挂了，需要一个端口来重新进行选举，选出一个新的&nbsp;Leader，而这个端口就是用来执行选举时服务器相互通信的端口。</pre>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><br></p>
<p>&nbsp; &nbsp; 如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。</p>
<p><br></p>
<p>&nbsp; &nbsp; 除了修改 zoo.cfg 配置文件，集群模式下还要配置一个文件 myid，这个文件在 dataDir 目录下，这个文件里面就有一个数据就是 A 的值，Zookeeper 启动时会读取这个文件，拿到里面的数据与 zoo.cfg 里面的配置信息比较从而判断到底是那个 server。</p>
<p><br></p>
<p>完整的配置文件：</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;conf]#&nbsp;cd&nbsp;/opt/zookeeper/conf/
[root@linux-node1&nbsp;conf]#&nbsp;vim&nbsp;zoo.cfg&nbsp;
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/data
clientPort=2181
server.1=192.168.56.21:2888:3888
server.2=192.168.56.22:2888:3888</pre>
<p><br></p>
<p>运行服务:</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;~]#&nbsp;/opt/zookeeper/bin/zkServer.sh&nbsp;start
JMX&nbsp;enabled&nbsp;by&nbsp;default
Using&nbsp;config:&nbsp;/opt/zookeeper/bin/../conf/zoo.cfg
Starting&nbsp;zookeeper&nbsp;...&nbsp;STARTED</pre>
<p>查看状态：</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;~]#&nbsp;/opt/zookeeper/bin/zkServer.sh&nbsp;status
JMX&nbsp;enabled&nbsp;by&nbsp;default
Using&nbsp;config:&nbsp;/opt/zookeeper/bin/../conf/zoo.cfg
Mode:&nbsp;follower</pre>
<pre class="brush:bash;toolbar:false">[root@linux-node2&nbsp;~]#&nbsp;/usr/local/zookeeper-3.4.6/bin/zkServer.sh&nbsp;status
JMX&nbsp;enabled&nbsp;by&nbsp;default
Using&nbsp;config:&nbsp;/usr/local/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode:&nbsp;leader</pre>
<p><br></p>
<p>zookeeper搭建完成，配置文件详解完成，原理可以看http://blog.csdn.net/qinglu000/article/details/23844359，很详细</p>
<p><br></p>
<p>基于centos的zookeeper镜像的Dockerfile构建：</p>
<pre class="brush:bash;toolbar:false">#&nbsp;auther:&nbsp;liuxiaotao
#&nbsp;date:&nbsp;2016-1-27
#&nbsp;version:&nbsp;1.0
FROM&nbsp;centos
MAINTAINER&nbsp;liuxiaotao&nbsp;taoge_admin@163.com
RUN&nbsp;yum&nbsp;update&nbsp;-y&nbsp;\
&nbsp;&nbsp;&nbsp;&nbsp;&amp;&amp;&nbsp;yum&nbsp;install&nbsp;-y&nbsp;java-1.7.0-openjdk&nbsp;java-1.7.0-openjdk-devel&nbsp;java-1.7.0-openjdk-headless
ADD&nbsp;zookeeper-3.4.6.tar.gz&nbsp;/usr/local/src/
#&nbsp;docker&nbsp;can&nbsp;zuto&nbsp;untar&nbsp;zhe&nbsp;*.tar.gz&nbsp;files&nbsp;
RUN&nbsp;mv&nbsp;/usr/local/src/zookeeper-3.4.6&nbsp;/usr/local/zookeeper
ADD&nbsp;zoo.cfg&nbsp;/usr/local/zookeeper/conf/
EXPOSE&nbsp;2181&nbsp;2888&nbsp;3888
VOLUME&nbsp;["/usr/local/zookeeper/conf",&nbsp;"/usr/local/zookeeper/data"]
CMD&nbsp;["/usr/local/zookeeper/bin/zkServer.sh&nbsp;start-foreground"]</pre>
<p>构建</p>
<pre class="brush:bash;toolbar:false">docker&nbsp;build&nbsp;-t&nbsp;lezyo/zookepeer:v2&nbsp;.</pre>
<p><br></p>
<p>查看镜像：</p>
<pre class="brush:bash;toolbar:false">[root@linux-node1&nbsp;docker]#&nbsp;docker&nbsp;images
REPOSITORY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TAG&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IMAGE&nbsp;ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CREATED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VIRTUAL&nbsp;SIZE
lezyo/zookepeer&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;v2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cb3c2eb639ec&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;561.8&nbsp;MB
lezyo/zookeeper&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;v1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b83857ea996f&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;41&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;561.8&nbsp;MB
&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2d8697315524&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;44&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;523&nbsp;MB
&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;898c41613f2f&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;45&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;523&nbsp;MB
&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;none&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e6ef1aaeb302&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;48&nbsp;minutes&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;523&nbsp;MB
docker.io/centos&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;latest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;60e65a8e4030&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4&nbsp;weeks&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;196.6&nbsp;MB
docker.io/garland/zookeeper&nbsp;&nbsp;&nbsp;latest&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0e07387e8ab2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;12&nbsp;months&nbsp;ago&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;378.5&nbsp;MB</pre>
<p>运行：</p>
<pre class="brush:bash;toolbar:false">docker&nbsp;run&nbsp;-d&nbsp;-P&nbsp;lezyo/zookepeer:v2&nbsp;/usr/local/zookeeper/bin/zkServer.sh&nbsp;start-foreground</pre>
<p><br></p>
<p>运行成功，但是简陋了点，好了zookeeper先到这。啃下一个。</p>
<p>本文出自 “<a href="http://xiaotaoge.blog.51cto.com">linux飞龙在天</a>” 博客，请务必保留此出处<a href="http://xiaotaoge.blog.51cto.com/1462401/1739399">http://xiaotaoge.blog.51cto.com/1462401/1739399</a></p>
