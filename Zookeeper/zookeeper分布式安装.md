<p>今天研究了下zookeeper，先跟大家分项下部署过程~~相对于hadoop其他软件来说，zookeeper的安装还是很简单的</p>
<p>环境说明：</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;虚拟机3台</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;IP地址 &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; hostname</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.136&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;namenode</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.137&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; datanode1</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.138&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; datanode2<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;zookeeper-3.4.6.tar</p>
<ol class="list-paddingleft-2" style="list-style-type:decimal;">
 <li><p><strong>准备。</strong></p><p>在每个虚拟机上配置host:</p></li>
</ol>
<pre class="brush:java;toolbar:false">&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.136&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;namenode
&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.137&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;datanode1
&nbsp;&nbsp;&nbsp;&nbsp;192.168.192.138&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;datanode2</pre>
<p>2. <strong>拷贝tar文件到服务器，解压</strong></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;tar -xvf zookeeper-3.4.6.tar</p>
<p>3. <strong>修改配置文件</strong></p>
<p>在conf目录下，叫zoo.cfg 没有自己创建一个&nbsp; <br></p>
<pre class="brush:java;toolbar:false">#这个时间是作为zookeeper&nbsp;服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个&nbsp;tickTime&nbsp;时间就会发送一个心跳。
tickTime=2000
#集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。
initLimit=10
#集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）。
syncLimit=5
#顾名思义就是&nbsp;Zookeeper&nbsp;保存数据的目录，默认情况下，Zookeeper&nbsp;将写数据的日志文件也保存在这个目录里。
dataDir=/home/hUser/zookeeper/data
#日志存放位置
dataLogDir=/home/hUser/zookeeper/datalog
#这个端口就是客户端连接&nbsp;Zookeeper&nbsp;服务器的端口，Zookeeper&nbsp;会监听这个端口，接受客户端的访问请求。
clientPort=2181

server.1=datanode2:2889:3889
server.2=datanode1:2889:3889
server.3=namenode:2889:3889</pre>
<p>4.<strong>创建dataDir和dataLogDir</strong></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;跟上面的配置文件一致就行<br></p>
<p>5.<strong>设置myid</strong></p>
<p>在dataDir目录里创建一个myid的文件，里面的配置跟你上面的server.*一致就行，例如我现在配置datanode2这个节点，那我这个文件就写1就行，其他的以此类推就行。</p>
<p>6.将配置好的目录，和存放dataDir和dataLogDir的文件拷贝到其他服务器，修改myid文件。</p>
<p>scp -R zookeeper-3.4.6 hUser@datanode1:/home/hUser/ <br></p>
<p>7.启动。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;bin/zkServer.sh start</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;可以 tail -f zookeeper.out查看日志</p>
<p>8.验证。</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;第一种：jps. 看看有没有进行为QuorumPeerMain的</p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;第二种：bin/zkServer.sh status 查看启动状态</p>
<pre class="brush:java;toolbar:false">JMX&nbsp;enabled&nbsp;by&nbsp;default
Using&nbsp;config:&nbsp;/home/hUser/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode:&nbsp;leader</pre>
<p>&nbsp;&nbsp;&nbsp;&nbsp;ok，到此你就安装成功了~~<br></p>
<p>&nbsp;&nbsp;&nbsp;&nbsp;<br></p>
<p><br></p>
<p>本文出自 “<a href="http://cdelliqi.blog.51cto.com">&#xfffd;丝程序员的逆袭</a>” 博客，请务必保留此出处<a href="http://cdelliqi.blog.51cto.com/9028667/1439424">http://cdelliqi.blog.51cto.com/9028667/1439424</a></p>
