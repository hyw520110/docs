<p><span class="date" style="margin:0px;padding:0px;border:0px;font-size:11.6666660308838px;">2013年08月10日</span>&nbsp;<span class="category" style="margin:0px;padding:0px;border:0px;font-size:11.6666660308838px;">&nbsp;<a href="http://www.superwu.cn/category/hadoop/" title="查看hadoop及周边中的全部文章" style="text-decoration:none;color:rgb(115,115,115);" target="_blank">hadoop及周边</a>,&nbsp;<a href="http://www.superwu.cn/category/hadoop/zookeeper/" title="查看zookeeper中的全部文章" style="text-decoration:none;color:rgb(115,115,115);" target="_blank">zookeeper</a></span>&nbsp;<span class="comment" style="margin:0px;padding:0px;border:0px;font-size:11.6666660308838px;">&nbsp;<a href="http://www.superwu.cn/2013/08/10/413/#comments" class="ds-thread-count" title="《ZooKeeper的分布模式安装》上的评论" style="text-decoration:none;color:rgb(115,115,115);" target="_blank">3条评论</a></span><span class="edit" style="margin:0px;padding:0px;border:0px;font-size:11.6666660308838px;background-image:url(&quot;http://www.superwu.cn/wp-content/themes/HotNewspro/images/login.png&quot;);background-position:0px -82px;background-repeat:no-repeat;"></span></p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">ZooKeeper(以下简称ZK)是一个分布式协调服务框架，可以做到<strong>各节点之间的数据强一致性</strong>。简单的理解就是在一个节点修改某个变量的值后，在其他节点可以最新的变化，这种变化是事务性的。通过在ZK节点上注册监听器，就可以获得数据的变化。</p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>1.确定集群结构</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">我们打算在三个节点安装ZK，分别是192.168.1.221(hadoop1)、192.168.1.222(hadoop2)、192.168.1.223(hadoop3)。首先在hadoop1中部署。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;"><strong>注意：一定要保证各节点的系统时间相同。</strong></p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>2.解压缩、设置环境变量</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">在hadoop1，我们把zookeeper-3.4.5.tar.gz复制到/usr/local目录下，解压缩，重命名为zk，然后在/etc/profile中设置环境变量。具体命令可以参照前面的文章。</p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>3.修改集群的配置</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">进入到${ZOOKEEPER_HOME}/conf目录下，有一个文件是zoo_sample.cfg，重命名为zoo.cfg。打开这个文件进行编辑</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">变量dataDir表示数据存放的目录，把该值修改为/usr/local/zk/data。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">在文件的最后增加三行内容，如下</p>
<pre style="margin-top:0px;margin-bottom:10px;">server.1=hadoop1:2888:3888
server.2=hadoop2:2888:3888
server.3=hadoop3:2888:3888</pre>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">每一行表示一个配置信息，现在解释一下每行的内容，以第一行为例。其中的server是固定名称；1只是一个标记，只要保证与下面的所有标记不重复即可；后面的hadoop1表示主机名，即ZK部署的主机；2888表示ZK之间通信用的端口；3888表示ZK之间选举用的端口。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">然后创建/usr/local/zk/data目录。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">进入data目录，创建文件myid。myid的内容是该主机名对应的标记数字。如果是hadoop1，那么数字就是1；如果是hadoop2，那么数字就是2；如果是hadoop3，那么数字就是3。</p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>4.配置其他节点</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">执行命令，把安装文件从hadoop1复制到其他节点，如下</p>
<pre style="margin-top:0px;margin-bottom:10px;">scp&nbsp;-rq&nbsp;/usr/local/zk&nbsp;hadoop2:/usr/local
scp&nbsp;-rq&nbsp;/usr/local/zk&nbsp;hadoop3:/usr/local

scp&nbsp;/etc/profile&nbsp;hadoop2:/etc/scp&nbsp;/etc/profile&nbsp;hadoop3:/etc/</pre>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">进入hadoop2中，把文件myid的内容修改为2；进入hadoop3，把文件myid的内容修改为3。</p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>5.启动集群</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">在三个节点的终端中，分别执行命令</p>
<pre style="margin-top:0px;margin-bottom:10px;">zkServer.sh&nbsp;&nbsp;start</pre>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">这样，就启动了ZK集群。</p>
<h1 style="margin:0px;padding:0px;border:0px;font-size:18px;line-height:33.2999992370606px;"><strong>6.验证</strong></h1>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">我们如何判断启动是否成功哪？</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">可以在终端执行jps查看，会看到一个新的java进程QuorumPeerMain。这就是ZK的java进程。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">也可以在三个终端分别执行命令</p>
<pre style="margin-top:0px;margin-bottom:10px;">zkServer.sh&nbsp;&nbsp;status</pre>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">会看到一个输出信息含有Mode: Leader，两个输出信息含有Mode: Follower。</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">至此，ZooKeeper的分布式安装就结束了。恭喜！</p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;"><br></p>
<p style="margin-top:0px;margin-bottom:10px;padding:0px;border:0px;font-size:13.3333330154419px;text-indent:2em;">原文地址 ： <a href="http://www.superwu.cn/2013/08/10/413/" target="_blank">http://www.superwu.cn/2013/08/10/413/</a>&nbsp;作者：吴超</p>
