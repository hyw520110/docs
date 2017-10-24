<p>zookeeper学习也有一段时间了，为以后有机会开发分布式服务做些准备。</p>
<p>今天先做下记录：</p>
<p><br></p>
<p>[zk: localhost:2181(CONNECTED) 1] help<br>ZooKeeper -server host:port cmd args<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; connect host:port<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; get path [watch]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ls path [watch]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; set path data [version]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; delquota [-n|-b] path<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; quit <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; printwatches on|off<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create [-s] [-e] path data acl<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stat path [watch]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; close <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ls2 path [watch]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; history <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; listquota path<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; setAcl path acl<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getAcl path<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; sync path<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; redo cmdno<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; addauth scheme auth<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; delete path [version]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; setquota -n|-b val path</p>
<p><br>1.create [-s] [-e] path data acl<br>其中”-s”表示创建一个顺序自动编号的节点,”-e”表示创建一个临时节点.默认为持久性节点<br>例如：<br>创建一个持久性节点和临时节点<br></p>
<pre class="brush:python;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;7]&nbsp;create&nbsp;/test&nbsp;null
Created&nbsp;/test
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;8]&nbsp;create&nbsp;-e&nbsp;/test0&nbsp;null
Created&nbsp;/test0</pre>
<p>当会话退出，临时节点将会自动删除，并且临时节点无子节点。</p>
<p><br></p>
<p>创建一个顺序自动编号的节点，ACL为使用digest（用户名:test 密码:test）,权限为所有（rwcda）。关于digest的产生，base64.b64encode(hashlib.new("sha1", auth).digest())方法;通过向此方法指定原始的用户名和密码即可获得”digest”之后的字符串,比如传入auth="test:test",将会得到'test:V28q/NynI4JI3Rk54h0r8O5kMug=',其内部原理是将”密码”部分进行加密操作.</p>
<pre class="brush:python;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;1]&nbsp;create&nbsp;-s&nbsp;/test/test&nbsp;null&nbsp;digest:test:V28q/NynI4JI3Rk54h0r8O5kMug=:rwcda
/test/test0000000004
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;getAcl&nbsp;/test/test
'digest,'test:V28q/NynI4JI3Rk54h0r8O5kMug=
:&nbsp;cdrwa</pre>
<p>这样的话，如果我不授权的话，是不允许查看的。所以:</p>
<pre class="brush:python;toolbar:false">[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;1]&nbsp;addauth&nbsp;digest&nbsp;test:test&nbsp;/test/test0000000004
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;get&nbsp;/test/test0000000004
null
cZxid&nbsp;=&nbsp;0x1000001b6
ctime&nbsp;=&nbsp;Fri&nbsp;Dec&nbsp;19&nbsp;16:17:35&nbsp;CST&nbsp;2014
mZxid&nbsp;=&nbsp;0x1000001b6
mtime&nbsp;=&nbsp;Fri&nbsp;Dec&nbsp;19&nbsp;16:17:35&nbsp;CST&nbsp;2014
pZxid&nbsp;=&nbsp;0x1000001b6
cversion&nbsp;=&nbsp;0
dataVersion&nbsp;=&nbsp;0
aclVersion&nbsp;=&nbsp;0
ephemeralOwner&nbsp;=&nbsp;0x0
dataLength&nbsp;=&nbsp;4
numChildren&nbsp;=&nbsp;0</pre>
<p>那么python代码如何创建一个带有digest认证的节点呢?</p>
<pre class="brush:python;toolbar:false">#/usr/bin/env&nbsp;python
#coding:utf8
import&nbsp;zookeeper
import&nbsp;time
import&nbsp;base64
import&nbsp;hashlib

auth="badboy:test"
user="badboy"
sha1&nbsp;=&nbsp;"%s:%s"&nbsp;%&nbsp;(user,&nbsp;base64.b64encode(hashlib.new("sha1",&nbsp;auth).digest()))
acl&nbsp;=&nbsp;[{"perms":0x1f,&nbsp;"scheme":"digest",&nbsp;"id"&nbsp;:sha1}]
handler&nbsp;=&nbsp;zookeeper.init("localhost:2181")
zookeeper.create(handler,'/node',"zkpython",acl)

命令行下查看:
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;1]&nbsp;getAcl&nbsp;/node
'digest,'badboy:TiLddZ4sxlajgN4vNV2KuxmOduY=
:&nbsp;cdrwa
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;2]&nbsp;addauth&nbsp;digest&nbsp;badboy:test&nbsp;/node
[zk:&nbsp;localhost:2181(CONNECTED)&nbsp;3]&nbsp;get&nbsp;/node
zkpython
cZxid&nbsp;=&nbsp;0x1000001dd
ctime&nbsp;=&nbsp;Fri&nbsp;Dec&nbsp;19&nbsp;16:37:41&nbsp;CST&nbsp;2014
mZxid&nbsp;=&nbsp;0x1000001dd
mtime&nbsp;=&nbsp;Fri&nbsp;Dec&nbsp;19&nbsp;16:37:41&nbsp;CST&nbsp;2014
pZxid&nbsp;=&nbsp;0x1000001dd
cversion&nbsp;=&nbsp;0
dataVersion&nbsp;=&nbsp;0
aclVersion&nbsp;=&nbsp;0
ephemeralOwner&nbsp;=&nbsp;0x0
dataLength&nbsp;=&nbsp;8
numChildren&nbsp;=&nbsp;0

脚本下如何访问一个digest加密的节点呢?
#!/usr/bin/env&nbsp;python
#coding:utf8
auth="badboy:test"
handler&nbsp;=&nbsp;zookeeper.init("192.168.x.5:2181")
zookeeper.add_auth(handler,&nbsp;auth&nbsp;,&nbsp;None)
zookeeper.get(handler,"/node")

如何使用ip认证
命令行添加:
create&nbsp;/test/test1&nbsp;hello&nbsp;ip:192.168.x.3:r&nbsp;&nbsp;意思是说只允许192.168.x.3这个客户端以只读方式连接
脚本方式添加:
acl=[{"perms":0x1f,&nbsp;"scheme":"ip",&nbsp;"id":"192.168.x.3"}]
zookeeper.create(handler,'/test/test2',"hello&nbsp;world",acl)
注意:命令行添加的内容不能带有空格，及时加双引号也会报错.</pre>
<p>2.setAcl path acl和getAcl path</p>
<p>给某个znode节点重新设置访问权限，需要注意的是ZooKeeper中的目录节点权限都不具有传递性，父znode节点的权限不能传递给子目录节点。在create中已经介绍了ACL的设置方法，可以设置一系列ACL规则（即指定一系列ACL对象，如acl=[{'perms':0x1f,"scheme":"ip","id":"x.x.x.x"},{'perms':0x1f,"scheme":"digest","id":"经过sha1加密的信息"}]此处使用了两种认证）。<br><br><code>List getACL(String path, Stat stat)</code><br>返回某个znode节点的ACL对象的列表。<br><br>例如zkCli中设置某个ACL规则：</p>
<p>[zk: localhost:2181(CONNECTED) 12] getAcl /test<br>'world,'anyone<br>: cdrwa</p>
<p>原先是任何人都有cdrwa权限,现重新设置需要digest授权的用户才有只读权限.</p>
<p>setAcl /test digest:test:V28q/NynI4JI3Rk54h0r8O5kMug=:r</p>
<p>再看下:</p>
<p>[zk: localhost:2181(CONNECTED) 2] getAcl /test<br>'digest,'test:V28q/NynI4JI3Rk54h0r8O5kMug=<br>: r</p>
<p><br></p>
<p>3.get path [watch]和set path data [version]</p>
<p>get是获取Znode的数据及相关属性,而set是修改此Znode的数据.</p>
<p><br></p>
<p>4.ls path [watch]</p>
<p>查看Znode的子节点<br></p>
<p><br></p>
<p>5.stat path [watch]</p>
<p>查看Znode的属性</p>
<p><br></p>
<p>6.delete path [version]</p>
<p>删除Znode，前提若有子节点，先删除其子节点<br></p>
<p><br></p>
<p>7.addauth scheme auth</p>
<p>认证授权，若某个节点需要认证后才能查看，就需要此命令，前面的例子已经给出.</p>
<p><br></p>
<p>本文仅供参考.<br></p>
<p>本文出自 “<a href="http://5ydycm.blog.51cto.com">坏男孩</a>” 博客，请务必保留此出处<a href="http://5ydycm.blog.51cto.com/115934/1591768">http://5ydycm.blog.51cto.com/115934/1591768</a></p>
