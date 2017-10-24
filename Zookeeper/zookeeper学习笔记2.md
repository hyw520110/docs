<p>zookeeper的实用场景有统一配置，统一命名服务,集群管理,分布式锁，分布式队列。</p>
<p>今天，我的实验场景是集群管理的ha功能.</p>
<p><br></p>
<p>实验架构如下:</p>
<p><a href="http://s3.51cto.com/wyfs02/M00/57/73/wKiom1SaYQ7ybNPmAAN_Lek8VRY744.jpg" target="_blank"><img onload="if(this.width>650) this.width=650;" src="http://s3.51cto.com/wyfs02/M00/57/73/wKiom1SaYQ7ybNPmAAN_Lek8VRY744.jpg" title="zk.png" alt="wKiom1SaYQ7ybNPmAAN_Lek8VRY744.jpg"></a></p>
<p>Server[A/B]代码:</p>
<p>此处，我们需要第3方的模块<br>zkclient.py（<a href="https://github.com/phunt/zk-smoketest/blob/master/zkclient.py%EF%BC%89" target="_blank">https://github.com/phunt/zk-smoketest/blob/master/zkclient.py）</a><br></p>
<p>需要做些稍微的修改，因为我这里的ACL采用的是digest，而不是world<br></p>
<p>导入些模块:</p>
<p>import base64<br>import hashlib</p>
<p><br></p>
<p>定义些变量<br></p>
<p>auth="badboy:test"<br>user="badboy"<br>user_auth = "%s:%s" % (user, base64.b64encode(hashlib.new("sha1", auth).digest()))<br>#ZOO_OPEN_ACL_UNSAFE = {"perms":0x1f, "scheme":"world", "id" :"anyone"}<br>ZOO_DIGEST_ACL_SAFE = {"perms":0x1f ,"scheme":"digest", "id" : user_auth}</p>
<p><br></p>
<p>再将代码处的ZOO_OPEN_ACL_UNSAFE修改为ZOO_DIGEST_ACL_SAFE</p>
<p><br></p>
<p>最后就是认证了,我们需要在ZKClient类中的__init__最后一行添加zookeeper.add_auth(self.handle,"digest",auth , None)</p>
<p>这样，我们连接的句柄就是经过认证的了.</p>
<p><br></p>
<p>注意Server[A/B]代码不同之处是service函数处，所输出的ip内容是不一样的。</p>
<pre class="brush:python;toolbar:false">#!/usr/bin/env&nbsp;python
import&nbsp;logging
from&nbsp;os.path&nbsp;import&nbsp;basename,&nbsp;join&nbsp;,dirname
from&nbsp;zkclient&nbsp;import&nbsp;ZKClient,&nbsp;zookeeper
from&nbsp;SimpleXMLRPCServer&nbsp;import&nbsp;SimpleXMLRPCServer

DEBUG=True
BASE_DIR=dirname(__file__)

if&nbsp;DEBUG:
&nbsp;&nbsp;&nbsp;&nbsp;logname=""
&nbsp;&nbsp;&nbsp;&nbsp;file_mode=""
else:
&nbsp;&nbsp;&nbsp;&nbsp;logname=join(BASE_DIR,"app.log")
&nbsp;&nbsp;&nbsp;&nbsp;file_mode="a"

logging.basicConfig(
&nbsp;&nbsp;&nbsp;&nbsp;level&nbsp;=&nbsp;logging.DEBUG,
&nbsp;&nbsp;&nbsp;&nbsp;format&nbsp;=&nbsp;"[%(asctime)s]&nbsp;%(levelname)-8s&nbsp;%(message)s",
&nbsp;&nbsp;&nbsp;&nbsp;datefmt&nbsp;=&nbsp;"%Y-%m-%d&nbsp;%H:%M:%S",
&nbsp;&nbsp;&nbsp;&nbsp;filename&nbsp;=&nbsp;logname,
&nbsp;&nbsp;&nbsp;&nbsp;filemode&nbsp;=&nbsp;file_mode,
)

log&nbsp;=&nbsp;logging

class&nbsp;TCZookeeper(object):

&nbsp;&nbsp;&nbsp;&nbsp;ZK_HOST&nbsp;=&nbsp;"192.168.x.5:2181"
&nbsp;&nbsp;&nbsp;&nbsp;ROOT&nbsp;=&nbsp;"/tc"
&nbsp;&nbsp;&nbsp;&nbsp;WORKERS_PATH&nbsp;=&nbsp;join(ROOT,&nbsp;"nodes")
&nbsp;&nbsp;&nbsp;&nbsp;MASTERS_NUM&nbsp;=&nbsp;1
&nbsp;&nbsp;&nbsp;&nbsp;TIMEOUT&nbsp;=&nbsp;1000

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;__init__(self,&nbsp;verbose&nbsp;=&nbsp;True):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.VERBOSE&nbsp;=&nbsp;verbose
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.masters&nbsp;=&nbsp;[]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.path&nbsp;=&nbsp;None

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.zk&nbsp;=&nbsp;ZKClient(self.ZK_HOST,&nbsp;timeout&nbsp;=&nbsp;self.TIMEOUT)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("login&nbsp;ok!")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.__init_zk()
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.register()
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.start_service()

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;__init_zk(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;nodes&nbsp;=&nbsp;(self.ROOT,&nbsp;self.WORKERS_PATH)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;for&nbsp;node&nbsp;in&nbsp;nodes:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;not&nbsp;self.zk.exists(node):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.zk.create(node,&nbsp;"")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pass

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;register(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.path&nbsp;=&nbsp;self.zk.create(self.WORKERS_PATH&nbsp;+&nbsp;"/node",&nbsp;"192.168.x.4",&nbsp;flags=zookeeper.EPHEMERAL&nbsp;|&nbsp;zookeeper.SEQUENCE)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.paths=self.path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.path&nbsp;=&nbsp;basename(self.path)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("register&nbsp;ok!&nbsp;I'm&nbsp;%s"&nbsp;%&nbsp;self.path)

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;service(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'''
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;do&nbsp;somethings
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'''
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;"My&nbsp;IP&nbsp;is:192.168.x.4"

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;start_service(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server&nbsp;=&nbsp;SimpleXMLRPCServer(("192.168.x.4",&nbsp;8000))
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("Listening&nbsp;on&nbsp;port&nbsp;8000...")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server.register_function(self.service,&nbsp;"service")&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server.serve_forever()

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;say(self,&nbsp;msg):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;self.VERBOSE:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;log.info(msg)

if&nbsp;__name__&nbsp;==&nbsp;"__main__":
&nbsp;&nbsp;&nbsp;&nbsp;tczk=TCZookeeper()</pre>
<p>启动Server[A|B]输出如下:</p>
<pre class="brush:python;toolbar:false">A机192.168.x.4:
[root@web02&nbsp;scripts]#&nbsp;python&nbsp;server.py&nbsp;
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;login&nbsp;ok!
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;register&nbsp;ok!&nbsp;I'm&nbsp;node0000000034
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Listening&nbsp;on&nbsp;port&nbsp;8000...

B机192.168.x.5(zookeeper也在这台机器噢):
[root@web02&nbsp;scripts]#&nbsp;python&nbsp;server.py&nbsp;
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;login&nbsp;ok!
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;register&nbsp;ok!&nbsp;I'm&nbsp;node0000000035
[2014-12-24&nbsp;14:40:37]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Listening&nbsp;on&nbsp;port&nbsp;8000...</pre>
<p><br></p>
<p><br></p>
<p>我们再来看看Agent代码:</p>
<pre class="brush:python;toolbar:false">#!/usr/bin/env&nbsp;python
import&nbsp;xmlrpclib
import&nbsp;logging
from&nbsp;os.path&nbsp;import&nbsp;basename,&nbsp;join&nbsp;,dirname
from&nbsp;zkclient&nbsp;import&nbsp;ZKClient,&nbsp;watchmethod
from&nbsp;SimpleXMLRPCServer&nbsp;import&nbsp;SimpleXMLRPCServer

DEBUG=True
BASE_DIR=dirname(__file__)

if&nbsp;DEBUG:
&nbsp;&nbsp;&nbsp;&nbsp;logname=""
&nbsp;&nbsp;&nbsp;&nbsp;file_mode=""
else:
&nbsp;&nbsp;&nbsp;&nbsp;logname=join(BASE_DIR,"app.log")
&nbsp;&nbsp;&nbsp;&nbsp;file_mode="a"&nbsp;

logging.basicConfig(
&nbsp;&nbsp;&nbsp;&nbsp;level&nbsp;=&nbsp;logging.DEBUG,
&nbsp;&nbsp;&nbsp;&nbsp;format&nbsp;=&nbsp;"[%(asctime)s]&nbsp;%(levelname)-8s&nbsp;%(message)s",
&nbsp;&nbsp;&nbsp;&nbsp;datefmt&nbsp;=&nbsp;"%Y-%m-%d&nbsp;%H:%M:%S",
&nbsp;&nbsp;&nbsp;&nbsp;filename&nbsp;=&nbsp;logname,
&nbsp;&nbsp;&nbsp;&nbsp;filemode&nbsp;=&nbsp;file_mode,
)

log&nbsp;=&nbsp;logging

class&nbsp;TCZookeeper(object):
&nbsp;&nbsp;&nbsp;&nbsp;ZK_HOST&nbsp;=&nbsp;"192.168.x.5:2181"
&nbsp;&nbsp;&nbsp;&nbsp;ROOT&nbsp;=&nbsp;"/tc"
&nbsp;&nbsp;&nbsp;&nbsp;NODES_PATH&nbsp;=&nbsp;join(ROOT,&nbsp;"nodes")
&nbsp;&nbsp;&nbsp;&nbsp;MASTERS_NUM&nbsp;=&nbsp;1
&nbsp;&nbsp;&nbsp;&nbsp;TIMEOUT&nbsp;=&nbsp;1000

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;__init__(self,&nbsp;verbose&nbsp;=&nbsp;True):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.VERBOSE&nbsp;=&nbsp;verbose
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.masters&nbsp;=&nbsp;[]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.path&nbsp;=&nbsp;None

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.zk&nbsp;=&nbsp;ZKClient(self.ZK_HOST,&nbsp;timeout&nbsp;=&nbsp;self.TIMEOUT)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("login&nbsp;ok!")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.get_master()

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;get_master(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;get&nbsp;children,&nbsp;and&nbsp;check&nbsp;who&nbsp;is&nbsp;the&nbsp;smallest&nbsp;child
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"""
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@watchmethod
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;watcher(event):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("child&nbsp;changed,&nbsp;try&nbsp;to&nbsp;get&nbsp;master&nbsp;again.")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.get_master()

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;children&nbsp;=&nbsp;self.zk.get_children(self.NODES_PATH,&nbsp;watcher)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;children.sort()
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("%s's&nbsp;children:&nbsp;%s"&nbsp;%&nbsp;(self.NODES_PATH,&nbsp;children))

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.masters&nbsp;=&nbsp;children[:self.MASTERS_NUM]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.path=self.NODES_PATH+"/"+self.masters[0]
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.serverip=self.zk.get(self.path)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("MasterIP:%s"&nbsp;%self.serverip[0])&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;rpc(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy&nbsp;=&nbsp;xmlrpclib.ServerProxy("http://%s:8000/"&nbsp;%self.serverip[0])&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return&nbsp;"content:&nbsp;%s"&nbsp;%&nbsp;str(proxy.service())
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;except:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pass
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;start_service(self):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server&nbsp;=&nbsp;SimpleXMLRPCServer(("192.168.x.3",&nbsp;8000))
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.say("Listening&nbsp;on&nbsp;port&nbsp;8000...")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server.register_function(self.rpc,&nbsp;"rpc")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;server.serve_forever()

&nbsp;&nbsp;&nbsp;&nbsp;def&nbsp;say(self,&nbsp;msg):
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if&nbsp;self.VERBOSE:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;log.info(msg)

if&nbsp;__name__&nbsp;==&nbsp;"__main__":
&nbsp;&nbsp;tczk&nbsp;=&nbsp;TCZookeeper()
&nbsp;&nbsp;tczk.start_service()</pre>
<p><br>启动agent输出如下:</p>
<pre class="brush:python;toolbar:false">[root@web01&nbsp;scripts]#&nbsp;python&nbsp;agent.py&nbsp;
[2014-12-24&nbsp;14:43:29]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;login&nbsp;ok!
[2014-12-24&nbsp;14:43:29]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/tc/nodes's&nbsp;children:&nbsp;['node0000000034',&nbsp;'node0000000035']
[2014-12-24&nbsp;14:43:29]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MasterIP:192.168.x.4
[2014-12-24&nbsp;14:43:29]&nbsp;INFO&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Listening&nbsp;on&nbsp;port&nbsp;8000...</pre>
<p><br></p>
<p>最后，我们看下client</p>
<pre class="brush:python;toolbar:false">#!/usr/bin/env&nbsp;python
import&nbsp;xmlrpclib
import&nbsp;time
#proxy&nbsp;=&nbsp;xmlrpclib.ServerProxy("http://192.168.x.3:8000/")
while&nbsp;True:
&nbsp;&nbsp;&nbsp;&nbsp;try:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy&nbsp;=&nbsp;xmlrpclib.ServerProxy("http://192.168.x.3:8000/")
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;print&nbsp;proxy.rpc()
&nbsp;&nbsp;&nbsp;&nbsp;except:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pass
&nbsp;&nbsp;&nbsp;&nbsp;time.sleep(1)</pre>
<p><br></p>
<p>输出结果:</p>
<p>root@saltstack:/scripts# python client.py <br>content: My IP is:192.168.x.4<br>content: My IP is:192.168.x.4<br>content: My IP is:192.168.x.4</p>
<p>此时，我们将其192.168.x.4服务关掉.</p>
<p>很快打印的内容就变成</p>
<p>content: My IP is:192.168.x.5<br>content: My IP is:192.168.x.5</p>
<p>再看agent输出有，</p>
<p>[2014-12-24 14:47:34] INFO&nbsp;&nbsp;&nbsp;&nbsp; child changed, try to get master again.<br>[2014-12-24 14:47:34] INFO&nbsp;&nbsp;&nbsp;&nbsp; /tc/nodes's children: ['node0000000035']<br>[2014-12-24 14:47:34] INFO&nbsp;&nbsp;&nbsp;&nbsp; MasterIP:192.168.x.5</p>
<p>看到没，原先MasterIP：192.168.x.4,现在192.168.x.5</p>
<p><br></p>
<p>呵呵，HA的功能试验完成了.<br></p>
<p>参考文档:</p>
<p>http://blog.csdn.net/lengzijian/article/details/9233327</p>
<p>本文出自 “<a href="http://5ydycm.blog.51cto.com">坏男孩</a>” 博客，请务必保留此出处<a href="http://5ydycm.blog.51cto.com/115934/1595201">http://5ydycm.blog.51cto.com/115934/1595201</a></p>
