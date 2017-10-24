<p>&nbsp; 本文主要贴出通过zookeeper的客户端类访问zookeeper的示例，以及其它第三方更高层次的封装的客户端使用。</p>
<p><br></p>
<p>&nbsp;1.通过org.apache.zookeeper.ZooKeeper来操作zookeeper服务</p>
<p>&nbsp; 有关zookeeper服务的部署参见文：<a href="http://aiilive.blog.51cto.com/1925756/1684145" target="_blank">http://aiilive.blog.51cto.com/1925756/1684145</a>&nbsp;下文将有代码示例展示通过编码方式在应用中启动zookeeper服务。</p>
<p>&nbsp;</p>
<p>&nbsp; ZooKeeper类对zookeeper服务的简单操作示例代码如下：</p>
<p>&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;secondriver.dubbo.client;

import&nbsp;org.apache.zookeeper.*;
import&nbsp;org.apache.zookeeper.data.Stat;

import&nbsp;java.io.IOException;
import&nbsp;java.util.List;
import&nbsp;java.util.concurrent.TimeUnit;

/**
&nbsp;*&nbsp;Author&nbsp;:&nbsp;secondriver
&nbsp;*/
public&nbsp;class&nbsp;TestZookeeper&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;throws&nbsp;IOException,&nbsp;KeeperException,&nbsp;InterruptedException&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//创建zookeeper客户端
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZooKeeper&nbsp;zooKeeper&nbsp;=&nbsp;new&nbsp;ZooKeeper("192.168.88.153:2181",&nbsp;1000,&nbsp;new&nbsp;Watcher()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("EventType:"&nbsp;+&nbsp;event.getType().name());
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;});

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//获取"/"&nbsp;node下的所有子node
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;List&lt;String&gt;&nbsp;znodes&nbsp;=&nbsp;zooKeeper.getChildren("/",&nbsp;true);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for&nbsp;(String&nbsp;path&nbsp;:&nbsp;znodes)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//创建开放权限的持久化node&nbsp;"/test"
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;rs&nbsp;=&nbsp;zooKeeper.create("/test",&nbsp;"test".getBytes(),&nbsp;ZooDefs.Ids.OPEN_ACL_UNSAFE,&nbsp;CreateMode
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;.PERSISTENT);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(rs);

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//同步获取"/test"&nbsp;node的数据
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stat&nbsp;stat&nbsp;=&nbsp;new&nbsp;Stat();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;data&nbsp;=&nbsp;zooKeeper.getData("/test",&nbsp;true,&nbsp;stat);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("value="&nbsp;+&nbsp;new&nbsp;String(data));
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(stat.toString());


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//异步获取"/test"&nbsp;node的数据
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zooKeeper.getData("/test",&nbsp;true,&nbsp;new&nbsp;AsyncCallback.DataCallback()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;processResult(int&nbsp;rc,&nbsp;String&nbsp;path,&nbsp;Object&nbsp;ctx,&nbsp;byte[]&nbsp;data,&nbsp;Stat&nbsp;stat)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(rc);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(ctx);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.printf(new&nbsp;String(data));
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(stat.toString());

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},&nbsp;"Object&nbsp;ctx&nbsp;..(提供的外部对象)");

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TimeUnit.SECONDS.sleep(10);

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zooKeeper.close();
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p><br></p>
<p>&nbsp; 上述代码依赖zookeeper包</p>
<p>&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;org.apache.zookeeper&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;zookeeper&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;3.4.6&lt;/version&gt;
&lt;/dependency&gt;</pre>
<p><br></p>
<p>&nbsp;2.通过zkclient操作zookeeper服务</p>
<p>&nbsp; zkclient github:&nbsp;<a href="https://github.com/sgroschupf/zkclient" target="_blank">https://github.com/sgroschupf/zkclient</a>&nbsp;</p>
<p>&nbsp; 后续有二次开发的版本：</p>
<p>&nbsp; 项目：&nbsp;<a href="https://github.com/adyliu/zkclient" target="_blank">https://github.com/adyliu/zkclient</a></p>
<p>&nbsp; 文档：&nbsp;<a href="https://github.com/adyliu/zkclient/wiki/tutorial" target="_blank">https://github.com/adyliu/zkclient/wiki/tutorial</a></p>
<p>&nbsp;</p>
<p>&nbsp; 下文代码示例使用sgroschupf/zkclient,依赖Zookeeper包。</p>
<p>&nbsp; maven &nbsp;sgroschupf/zkclient</p>
<p>&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;com.101tec&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;zkclient&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;0.5&lt;/version&gt;
&lt;/dependency&gt;</pre>
<p>&nbsp;<br></p>
<p>&nbsp; 应用内server+client:</p>
<p>&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;secondriver.dubbo.server;

import&nbsp;org.I0Itec.zkclient.IDefaultNameSpace;
import&nbsp;org.I0Itec.zkclient.ZkClient;
import&nbsp;org.I0Itec.zkclient.ZkServer;
import&nbsp;org.apache.zookeeper.CreateMode;

import&nbsp;java.io.IOException;
/**
&nbsp;*&nbsp;Author&nbsp;:&nbsp;secondriver
&nbsp;*/
public&nbsp;class&nbsp;TestI0ItecZk&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;throws&nbsp;IOException&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//Server&nbsp;+&nbsp;Client
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkServer&nbsp;zkServer&nbsp;=&nbsp;new&nbsp;ZkServer("D:/data",&nbsp;"D:/log",&nbsp;new&nbsp;IDefaultNameSpace()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;createDefaultNameSpace(ZkClient&nbsp;zkClient)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.create("/default",&nbsp;"defalut-name-space",&nbsp;CreateMode.PERSISTENT);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;});

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkServer.start();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkClient&nbsp;zkClient&nbsp;=&nbsp;zkServer.getZkClient();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;boolean&nbsp;exists&nbsp;=&nbsp;zkClient.exists("/default");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(exists)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("default&nbsp;name&nbsp;space&nbsp;init&nbsp;create&nbsp;succeed.");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("default&nbsp;name&nbsp;space&nbsp;init&nbsp;create&nbsp;failed.");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.in.read();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.close();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkServer.shutdown();
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p>&nbsp;</p>
<p>&nbsp; 应用外部署server,使用client访问：</p>
<p>&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;secondriver.dubbo.server;

import&nbsp;org.I0Itec.zkclient.ZkClient;

import&nbsp;java.util.List;

/**
&nbsp;*&nbsp;Author&nbsp;:&nbsp;secondriver
&nbsp;*/
public&nbsp;class&nbsp;TestZkClient&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//Only&nbsp;use&nbsp;client
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkClient&nbsp;zkc&nbsp;=&nbsp;new&nbsp;ZkClient("192.168.88.153:2181,192.168.88.153:2182,192.168.88.153:2183");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;List&lt;String&gt;&nbsp;childrens&nbsp;=&nbsp;zkc.getChildren("/");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for&nbsp;(String&nbsp;child&nbsp;:&nbsp;childrens)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(child);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p>&nbsp;&nbsp;<br></p>
<p>&nbsp; 下文代码示例使用adyliu/zkclient,同样依赖Zookeeper包，启动Zookeeper服务并做操作。<br></p>
<p>&nbsp; maven adyliu/zkclient:</p>
<p>&nbsp;</p>
<pre class="brush:xml;toolbar:false">&lt;dependency&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;groupId&gt;com.github.adyliu&lt;/groupId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;artifactId&gt;zkclient&lt;/artifactId&gt;
&nbsp;&nbsp;&nbsp;&nbsp;&lt;version&gt;2.1.1&lt;/version&gt;
&lt;/dependency&gt;</pre>
<p>&nbsp;&nbsp;</p>
<pre class="brush:java;toolbar:false">package&nbsp;secondriver.dubbo.server;

import&nbsp;com.github.zkclient.*;

import&nbsp;java.io.IOException;
import&nbsp;java.util.List;

/**
&nbsp;*&nbsp;Author&nbsp;:&nbsp;secondriver
&nbsp;*/
public&nbsp;class&nbsp;TestZk&nbsp;{


&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;throws&nbsp;IOException&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;home&nbsp;=&nbsp;System.getProperty("user.home");

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//创建zookeeper服务并启动
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkServer&nbsp;zkServer&nbsp;=&nbsp;new&nbsp;ZkServer(home&nbsp;+&nbsp;"/zookeeper/data",&nbsp;home&nbsp;+&nbsp;"/zookeeper/log",&nbsp;2181);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkServer.start();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//方式一
//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkClient&nbsp;zkClient&nbsp;=&nbsp;new&nbsp;ZkClient("127.0.0.1:2181",&nbsp;1000);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//方式二
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ZkClient&nbsp;zkClient&nbsp;=&nbsp;zkServer.getZkClient();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;path&nbsp;=&nbsp;"/test"&nbsp;+&nbsp;Math.random();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//数据监听
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;final&nbsp;IZkDataListener&nbsp;dataListener&nbsp;=&nbsp;new&nbsp;IZkDataListener()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;handleDataChange(String&nbsp;dataPath,&nbsp;byte[]&nbsp;data)&nbsp;throws&nbsp;Exception&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(dataPath&nbsp;+&nbsp;"&nbsp;data&nbsp;change");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;handleDataDeleted(String&nbsp;dataPath)&nbsp;throws&nbsp;Exception&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//结点（node）监听
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;final&nbsp;IZkChildListener&nbsp;childListener&nbsp;=&nbsp;new&nbsp;IZkChildListener()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;handleChildChange(String&nbsp;parentPath,&nbsp;List&lt;String&gt;&nbsp;currentChildren)&nbsp;throws&nbsp;Exception&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(parentPath&nbsp;+&nbsp;"&nbsp;parentPath");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for&nbsp;(String&nbsp;path&nbsp;:&nbsp;currentChildren)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//为指定node添加监听
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.subscribeDataChanges(path,&nbsp;dataListener);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.subscribeChildChanges("/",&nbsp;childListener);

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//zkclient操作Zookeeper服务
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;///检测node是否存在
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;(zkClient.exists("/zookeeper"))&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("Exist&nbsp;zookeeper&nbsp;path");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;else&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("Not&nbsp;Exist&nbsp;zookeeper&nbsp;path");
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.createPersistent(path,&nbsp;path.getBytes());
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;before&nbsp;=&nbsp;zkClient.readData(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("before:"&nbsp;+&nbsp;new&nbsp;String(before));

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//以原子的方式更新指定的path&nbsp;node的数据
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.cas(path,&nbsp;new&nbsp;IZkClient.DataUpdater()&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;byte[]&nbsp;update(byte[]&nbsp;currentData)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;new&nbsp;String(currentData).concat(new&nbsp;String("&nbsp;updated")).getBytes();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;});

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;after&nbsp;=&nbsp;zkClient.readData(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println("after:"&nbsp;+&nbsp;new&nbsp;String(after));

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;//取消指定path&nbsp;node的数据监听
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.unsubscribeDataChanges(path,&nbsp;dataListener);

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.writeData(path,&nbsp;"new-data".getBytes());

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;byte[]&nbsp;dataBytes&nbsp;=&nbsp;zkClient.readData(path);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;String&nbsp;data&nbsp;=&nbsp;new&nbsp;String(dataBytes);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(path&nbsp;+&nbsp;"&nbsp;data&nbsp;:"&nbsp;+&nbsp;data);

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.in.read();

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkClient.close();
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;zkServer.shutdown();
&nbsp;&nbsp;&nbsp;&nbsp;}
}</pre>
<p><br></p>
<p>&nbsp;3. Zookeeper客户端和富Zookeeper框架之curator<br></p>
<p>&nbsp; github:&nbsp;<a href="https://github.com/Netflix/curator" target="_blank">https://github.com/Netflix/curator</a></p>
<p>&nbsp; 已成为apache项目：<a href="http://curator.apache.org" target="_blank">http://curator.apache.org</a></p>
<p>本文出自 “<a href="http://aiilive.blog.51cto.com">野马红尘</a>” 博客，请务必保留此出处<a href="http://aiilive.blog.51cto.com/1925756/1684451">http://aiilive.blog.51cto.com/1925756/1684451</a></p>
