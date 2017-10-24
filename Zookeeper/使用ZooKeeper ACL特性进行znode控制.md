<p>&nbsp;<span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">Zookeeper作为配置管理服务，因为配置数据有很高的安全要求，需要有权限控制，客户端需要进行登录认证才操作（查看数据，修改数据，创建children znode等等）Zookeeper上面对应znode。</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp; &nbsp;&nbsp;</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">1. 简单的客户端认证zkCli.sh 命令如下：</span></p>
<p><br></p>
<pre class="brush:bash;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;23]&nbsp;ls&nbsp;/tom
Authentication&nbsp;is&nbsp;not&nbsp;valid&nbsp;:&nbsp;/tom</pre>
<p><br></p>
<pre class="brush:bash;toolbar:false">#添加认证之后，即可查看znode&nbsp;/tom
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;27]&nbsp;addauth&nbsp;digest&nbsp;tom:tom
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;28]&nbsp;ls&nbsp;/tom
[]</pre>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;"><span style="font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">2. Zookeeper提供的认证方式</span></span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp; </span>&nbsp;Zookeeper对权限的控制是znode级别的，不继承即对父节点设置权限，其子节点不继承父节点的权限。&nbsp;<br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; world：有个单一的ID，anyone，表示任何人。<br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; auth：不使用任何ID，表示任何通过验证的用户（验证是指创建该znode的权限）。&nbsp;<br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; digest：使用 用户名：密码 字符串生成MD5哈希值作为ACL标识符ID。权限的验证通过直接发送用户名密码字符串 &nbsp;的方式完成，&nbsp;<br style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; ip：使用客户端主机ip地址作为一个ACL标识符，ACL表达式是以 addr/bits 这种格式表示的。ZK服务器会将addr的前bits位与客户端地址的前bits位来进行匹配验证权限。&nbsp;</p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp;</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp;</span>3. auth认证方式</p>
<p>&nbsp; Perm:ALL, Id:("auth","") 即创建者拥有访问权限。</p>
<p><br></p>
<p>&nbsp; /auth的数据是“auth”, auth认证方式，读写权限。</p>
<pre class="brush:bash;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;37]&nbsp;create&nbsp;/auth&nbsp;auth&nbsp;auth::rw
Created&nbsp;/auth</pre>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);"></span>&nbsp;查看/auth的访问控制列表可以看出需要通过digest模式用户名密码是tom/tom认证才可以访问，不对id做限制。</p>
<pre class="brush:bash;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;42]&nbsp;getAcl&nbsp;/auth
'digest,'tom:GcSMsIa2MmdW+zdSJKAv8gcnrpI=
:&nbsp;rw</pre>
<p>&nbsp;成功的认证：<br></p>
<pre class="brush:bash;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;0]&nbsp;ls&nbsp;/auth&nbsp;&nbsp;&nbsp;&nbsp;
Authentication&nbsp;is&nbsp;not&nbsp;valid&nbsp;:&nbsp;/auth
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;1]&nbsp;addauth&nbsp;digest&nbsp;tom:tom
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;ls&nbsp;/auth
[]</pre>
<p>&nbsp;失败的认证：</p>
<pre class="brush:bash;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;addauth&nbsp;digest&nbsp;supper:admin
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;3]&nbsp;ls&nbsp;/auth
Authentication&nbsp;is&nbsp;not&nbsp;valid&nbsp;:&nbsp;/aut</pre>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp;4.通过zkCli.sh 创建znode,并设置ACL</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp; 4.1 创建设置ACL的znode</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp; &nbsp;图1 - 用户/密码super/admin创建/supper：</span></p>
<p><a href="http://s3.51cto.com/wyfs02/M00/71/9B/wKiom1XUQebS6dP3AABboEhkzjQ610.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/71/9B/wKiom1XUQebS6dP3AABboEhkzjQ610.jpg" style="float:none;" title="zk-acl-supper.png" alt="wKiom1XUQebS6dP3AABboEhkzjQ610.jpg"></a></p>
<p>&nbsp;图2-<span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">用户/密码tom/tom创建/tom</span>：</p>
<p><a href="http://s3.51cto.com/wyfs02/M01/71/97/wKioL1XUQ_PyHV37AABWr1IgZxE562.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/97/wKioL1XUQ_PyHV37AABWr1IgZxE562.jpg" style="float:none;" title="zk-acl-tom.png" alt="wKioL1XUQ_PyHV37AABWr1IgZxE562.jpg"></a></p>
<p>&nbsp;图3-查看/supper和/tom的ACL：</p>
<p><a href="http://s3.51cto.com/wyfs02/M01/71/9B/wKiom1XUQebxVoT-AACXNGAfKTg521.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/9B/wKiom1XUQebxVoT-AACXNGAfKTg521.jpg" style="float:none;" title="zk-getacl.png" alt="wKiom1XUQebxVoT-AACXNGAfKTg521.jpg"></a></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);"></span><br></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp; 4.2 使用如下代码来生成用户名和密码的摘要：</span></p>
<pre class="brush:java;toolbar:false">java&nbsp;-cp&nbsp;$ZK_CLASSPATH&nbsp;\
org.apache.zookeeper.server.auth.DigestAuthenticationProvider&nbsp;amy:secret
....
amy:secret-&gt;amy:Iq0onHjzb4KyxPAp8YWOIC8zzwY=</pre>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);"></span>&nbsp;</p>
<p>&nbsp;注：在启动Zookeeper服务是指定</p>
<pre class="brush:java;toolbar:false">-Dzookeeper.DigestAuthenticationProvider.superDigest=super:&lt;base64encoded(SHA1(password))</pre>
<p>&nbsp;将启用超级用户，通过该supper:密码认证的客户端访问将不受ACL列表限制。</p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp;</span></p>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);">&nbsp;5. 客户端验证</span></p>
<p>&nbsp; 5.1验证supper/admin</p>
<pre class="brush:java;toolbar:false">ZooKeeper&nbsp;zooKeeper1&nbsp;=&nbsp;new&nbsp;ZooKeeper("192.168.88.153:2181",&nbsp;10000,&nbsp;new&nbsp;Watcher()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(event);
&nbsp;&nbsp;&nbsp;&nbsp;}
});
//zooKeeper1.addAuthInfo("digest",&nbsp;"supper:admin".getBytes());
Stat&nbsp;stat&nbsp;=&nbsp;new&nbsp;Stat();
byte[]&nbsp;supperData&nbsp;=&nbsp;zooKeeper1.getData("/supper",&nbsp;true,&nbsp;stat);
System.out.println(new&nbsp;String(supperData)&nbsp;+&nbsp;","&nbsp;+&nbsp;stat);</pre>
<p><span style="font-family:Helvetica, Tahoma, Arial, sans-serif;font-size:14px;line-height:25.2000007629395px;background-color:rgb(255,255,255);"></span>&nbsp;运行上面代码，读（r）znode "/supper" ：</p>
<p>&nbsp;<a href="http://s3.51cto.com/wyfs02/M01/71/98/wKioL1XURobjrdJSAAFoTF3wkLo594.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/98/wKioL1XURobjrdJSAAFoTF3wkLo594.jpg" title="zk-noauth.png" alt="wKioL1XURobjrdJSAAFoTF3wkLo594.jpg"></a></p>
<p>&nbsp;去掉注释代码，为客户端添加认证信息之后：</p>
<p>&nbsp;</p>
<pre class="brush:bash;toolbar:false">0,8589940093,8589940093,1439970090902,1439970090902,0,0,0,0,1,0,8589940093</pre>
<p>&nbsp;数据是0，符合4中图1设置的值。</p>
<p><br></p>
<p>&nbsp;5.2验证tom/tom</p>
<p>&nbsp;</p>
<pre class="brush:java;toolbar:false">ZooKeeper&nbsp;zooKeeper2&nbsp;=&nbsp;new&nbsp;ZooKeeper("192.168.88.153:2181",&nbsp;10000,&nbsp;new&nbsp;Watcher()&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;@Override
&nbsp;&nbsp;&nbsp;&nbsp;public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;System.out.println(event);
&nbsp;&nbsp;&nbsp;&nbsp;}
});
zooKeeper2.addAuthInfo("digest",&nbsp;"tom:tom".getBytes());
stat&nbsp;=&nbsp;new&nbsp;Stat();
byte[]&nbsp;tomData&nbsp;=&nbsp;zooKeeper2.getData("/tom",&nbsp;true,&nbsp;stat);
System.out.println(new&nbsp;String(tomData)&nbsp;+&nbsp;","&nbsp;+&nbsp;stat);</pre>
<p>&nbsp; 结果似同5.1.</p>
<p><br></p>
<p>&nbsp; 通过zkCli.sh客户端连接,认证和读取</p>
<p>&nbsp;<a href="http://s3.51cto.com/wyfs02/M01/71/98/wKioL1XUSdeCkx_-AAFruzksR4Y745.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M01/71/98/wKioL1XUSdeCkx_-AAFruzksR4Y745.jpg" title="zk-tom-client.png" alt="wKioL1XUSdeCkx_-AAFruzksR4Y745.jpg"></a></p>
<p><br></p>
<p>6.使用zkCli.sh 验证acl(点击查看大图)<br></p>
<p>&nbsp;<a href="http://s3.51cto.com/wyfs02/M02/71/9B/wKiom1XUTGywiY9SAAMtMoSLiWI715.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M02/71/9B/wKiom1XUTGywiY9SAAMtMoSLiWI715.jpg" title="zk-admin.png" alt="wKiom1XUTGywiY9SAAMtMoSLiWI715.jpg"></a></p>
<p><br></p>
<p>Zookeeper提供的权限信息表：</p>
<p>&nbsp;</p>
<table>
 <tbody>
  <tr>
   <td width="223" valign="top">权限</td>
   <td width="223" valign="top">描述</td>
   <td width="223" valign="top">setAcl中的简写</td>
  </tr>
  <tr>
   <td width="223" valign="top">write</td>
   <td width="223" valign="top">能够设置znode的值</td>
   <td width="223" valign="top">w</td>
  </tr>
  <tr>
   <td width="223" valign="top">read</td>
   <td width="223" valign="top">能够读取znode的值和列出它的children znode</td>
   <td width="223" valign="top">r</td>
  </tr>
  <tr>
   <td width="223" valign="top">create</td>
   <td width="223" valign="top">能够创建children znode</td>
   <td width="223" valign="top">c</td>
  </tr>
  <tr>
   <td width="223" valign="top">delete</td>
   <td width="223" valign="top">能够删除children znode</td>
   <td width="223" valign="top">d</td>
  </tr>
  <tr>
   <td width="223" valign="top">admin</td>
   <td width="223" valign="top">能够执行setAcl即设置访问控制列表</td>
   <td width="223" valign="top">a</td>
  </tr>
  <tr>
   <td width="223" valign="top">all</td>
   <td width="223" valign="top">所有权限</td>
   <td width="223" valign="top">wrcda</td>
  </tr>
 </tbody>
</table>
<p><br></p>
<p>7：注意问题：</p>
<p>&nbsp;7.1 通过zkCli.sh设置acl的格式是scheme:id:perm，perm的写法是简写字母连接，如读写权限rw和Linux的文件系统的权限相似。有些版本可能是：READ|WRITE, 所以需要注意命令行提示信息。</p>
<p>&nbsp;7.2 通过zkCli.sh设置acl时，scheme是digest的时候,id需要密文，具体生成参见文4.2</p>
<p>&nbsp;7.3 通过Zookeeper的客户端编码方式添加认证，digest对应的auth数据是明文，参见文5.1</p>
<p>&nbsp;</p>
<p>8.Zookeeper认证的扩展</p>
<p>&nbsp;实现AuthenticationProvider接口提供自定义的认证方式。</p>
<pre class="brush:java;toolbar:false">org.apache.zookeeper.server.auth.AuthenticationProvider</pre>
<p><br></p>
<p>&nbsp;比如自定义实现AuthenticationProvider类是secondriver.MyProvier，可以通过两种方式注册Zookeeper认证体系中去。</p>
<p>&nbsp;第一种：启动Zookeeper服务是通过-Dzookeeper.authPorivder.X=secondriver.MyProvider</p>
<p>&nbsp;第二种：添加到配置文件（zoo.conf）中如：</p>
<pre class="brush:plain;toolbar:false">zookeeper.authProvider.1=secondriver.MyProvider</pre>
<p>&nbsp;注:上面X是对authProvider实现提供编号用来区别不同的authProvider。</p>
<p><br></p>
<p>本文出自 “<a href="http://aiilive.blog.51cto.com">野马红尘</a>” 博客，请务必保留此出处<a href="http://aiilive.blog.51cto.com/1925756/1686132">http://aiilive.blog.51cto.com/1925756/1686132</a></p>
