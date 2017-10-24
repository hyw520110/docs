<p><br></p>
<p>&nbsp; 下面2张图来自：<a href="http://www.open-open.com/doc/view/2e0a82e0081d489dace301a2c512053c" target="_blank">http://www.open-open.com/doc/view/2e0a82e0081d489dace301a2c512053c</a> </p>
<p>&nbsp;&nbsp;</p>
<p>&nbsp; 关于Zookeeper服务安装，配置，启动, 客户端操作参见：</p>
<p>&nbsp;&nbsp;<a href="http://aiilive.blog.51cto.com/1925756/1684451" target="_blank">http://aiilive.blog.51cto.com/1925756/1684451</a> </p>
<p>&nbsp;&nbsp;<a href="http://aiilive.blog.51cto.com/1925756/1684145" target="_blank">http://aiilive.blog.51cto.com/1925756/1684145</a></p>
<p><br></p>
<p>1.利用Zookeeper的znode数据版本生成序列号</p>
<p><a href="http://s3.51cto.com/wyfs02/M01/71/83/wKioL1XS7Crg6_YaAAQNPtfUuYg724.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/83/wKioL1XS7Crg6_YaAAQNPtfUuYg724.jpg" style="float:none;" title="zk-seq-1.png" alt="wKioL1XS7Crg6_YaAAQNPtfUuYg724.jpg"></a></p>
<p><br></p>
<p>&nbsp;利用zkClient封装包操作实现：</p>
<pre class="brush:java;toolbar:false">//提前创建好存储Seq的"/createSeq"结点&nbsp;CreateMode.PERSISTENT
public&nbsp;static&nbsp;final&nbsp;String&nbsp;SEQ_ZNODE&nbsp;=&nbsp;"/seq"

//通过znode数据版本实现分布式seq生成
public&nbsp;static&nbsp;class&nbsp;Task1&nbsp;implements&nbsp;Runnable&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;String&nbsp;taskName;

&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;Task1(String&nbsp;taskName)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this.taskName&nbsp;=&nbsp;taskName;
&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;run()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkClient&nbsp;zkClient&nbsp;=&nbsp;new&nbsp;ZkClient("192.168.88.153:2181",&nbsp;3000,&nbsp;1000);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stat&nbsp;stat&nbsp;=&nbsp;zkClient.writeData(SEQ_ZNODE,&nbsp;new&nbsp;byte[0],&nbsp;-1);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int&nbsp;versionAsSeq&nbsp;=&nbsp;stat.getVersion();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(taskName&nbsp;+&nbsp;"&nbsp;obtain&nbsp;seq="&nbsp;+&nbsp;versionAsSeq);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.close();
&nbsp;&nbsp;&nbsp;&nbsp;}
}

//main
final&nbsp;ExecutorService&nbsp;service&nbsp;=&nbsp;Executors.newFixedThreadPool(20);

for&nbsp;(int&nbsp;i&nbsp;=&nbsp;0;&nbsp;i&nbsp;&lt;&nbsp;20;&nbsp;i++)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;service.execute(new&nbsp;Task1("[Concurrent-"&nbsp;+&nbsp;i&nbsp;+&nbsp;"]"));
}</pre>
<p><br></p>
<p>2.利用临时带序列号的znode实现和分布式锁持久化znode实现</p>
<p><br></p>
<p>2.1 下图是利用分布式锁持久化znode实现</p>
<p><br></p>
<p>客户端采用apache curator 框架，代码：https://code.csdn.net/snippets/929300</p>
<p><br></p>
<p><a href="http://s3.51cto.com/wyfs02/M01/71/83/wKioL1XS7CrzHIyFAAQ4t7a79_I242.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/83/wKioL1XS7CrzHIyFAAQ4t7a79_I242.jpg" style="float:none;" title="zk-seq-2.png" alt="wKioL1XS7CrzHIyFAAQ4t7a79_I242.jpg"></a></p>
<p><br></p>
<p>&nbsp;2.2利用临时带序列号的znode实现</p>
<p>&nbsp;客户端采用：zkClient （<a href="https://github.com/adyliu/zkclient" style="padding:0px;margin:0px;color:rgb(114,41,50);text-decoration:none;font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);" target="_blank">https://github.com/adyliu/zkclient</a>）</p>
<p><br></p>
<pre class="brush:java;toolbar:false">//提前创建好锁对象的结点"/lock"&nbsp;CreateMode.PERSISTENT
public&nbsp;static&nbsp;final&nbsp;String&nbsp;LOCK_ZNODE&nbsp;=&nbsp;"/lock";</pre>
<p><br></p>
<pre class="brush:java;toolbar:false">//分布式锁实现分布式seq生成
public&nbsp;static&nbsp;class&nbsp;Task2&nbsp;implements&nbsp;Runnable,&nbsp;IZkChildListener&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;String&nbsp;taskName;

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;ZkClient&nbsp;zkClient;

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;String&nbsp;lockPrefix&nbsp;=&nbsp;"/loc";

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;final&nbsp;String&nbsp;selfZnode;

&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;Task2(String&nbsp;taskName)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;this.taskName&nbsp;=&nbsp;taskName;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient&nbsp;=&nbsp;new&nbsp;ZkClient("192.168.88.153:2181",&nbsp;30000,&nbsp;10000);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;selfZnode&nbsp;=&nbsp;zkClient.createEphemeralSequential(LOCK_ZNODE&nbsp;+&nbsp;lockPrefix,&nbsp;new&nbsp;byte[0]);
&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;run()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.subscribeChildChanges(LOCK_ZNODE,&nbsp;this);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;do&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;while&nbsp;(zkClient.isConnected());
&nbsp;&nbsp;&nbsp;&nbsp;}


&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;void&nbsp;createSeq()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stat&nbsp;stat&nbsp;=&nbsp;new&nbsp;Stat();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;oldData&nbsp;=&nbsp;zkClient.readData(LOCK_ZNODE,&nbsp;stat);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;newData&nbsp;=&nbsp;update(oldData);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.writeData(LOCK_ZNODE,&nbsp;newData);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(taskName&nbsp;+&nbsp;selfZnode&nbsp;+&nbsp;"&nbsp;obtain&nbsp;seq="&nbsp;+&nbsp;new&nbsp;String(newData));
&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;private&nbsp;byte[]&nbsp;update(byte[]&nbsp;currentData)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;s&nbsp;=&nbsp;new&nbsp;String(currentData);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int&nbsp;d&nbsp;=&nbsp;Integer.parseInt(s);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d&nbsp;=&nbsp;d&nbsp;+&nbsp;1;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;s&nbsp;=&nbsp;String.valueOf(d);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;s.getBytes();
&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;handleChildChange(String&nbsp;parentPath,&nbsp;List&lt;String&gt;&nbsp;currentChildren)&nbsp;throws&nbsp;Exception&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String[]&nbsp;childrensZnode&nbsp;=&nbsp;currentChildren.toArray(new&nbsp;String[currentChildren.size()]);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Arrays.sort(childrensZnode);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;minZnode&nbsp;=&nbsp;LOCK_ZNODE&nbsp;+&nbsp;"/"&nbsp;+&nbsp;childrensZnode[0];
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(selfZnode.equals(minZnode))&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;createSeq();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.unsubscribeChildChanges(LOCK_ZNODE,&nbsp;this);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.delete(selfZnode);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.close();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p><br></p>
<p>&nbsp;完整代码参见：https://code.csdn.net/snippets/929320</p>
<p>本文出自 “<a href="http://aiilive.blog.51cto.com">野马红尘</a>” 博客，请务必保留此出处<a href="http://aiilive.blog.51cto.com/1925756/1685614">http://aiilive.blog.51cto.com/1925756/1685614</a></p>
