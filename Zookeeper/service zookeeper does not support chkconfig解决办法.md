<p><span style="color:rgb(112,48,160);">一 问题描述</span></p>
<p>&nbsp;部署好ZooKeeper后，需要设置启动脚本并设置开机自动启动。</p>
<p>&nbsp;</p>
<pre class="brush:bash;toolbar:false">cp&nbsp;/opt/app/zookeeper/bin/zkServer.sh&nbsp;/etc/init.d/zookeeper</pre>
<p><br></p>
<p>&nbsp;更改脚本的参数</p>
<p>&nbsp;</p>
<pre class="brush:plain;toolbar:false">&nbsp;ZOOBIN=/opt/app/zookeeper/bin
&nbsp;ZOOBINDIR=/opt/app/zookeeper/bin
&nbsp;ZOO_LOG_DIR=/opt/logs/zookeeper</pre>
<p>这个三个参数随意自己定义</p>
<p>&nbsp; 执行service zookeeper start 正常，但是执行chkconfig --level 35 zookeeper on报以下错误</p>
<p>&nbsp;service zookeeper does not support chkconfig</p>
<p>&nbsp;</p>
<p><br></p>
<p><span style="color:rgb(112,48,160);">二 问题解决</span></p>
<p><span style="color:#7030a0;">&nbsp;</span>以上的问题和chkconfig这个命令有关。查阅chkconfig命令的man手册进行了解。</p>
<p>&nbsp;需要让chkconfig管理的服务需要在/etc/init.d目录下的启动脚本中添加几行代码。如下：</p>
<pre class="brush:bash;toolbar:false">#!/bin/bash
#
#&nbsp;zookeeper&nbsp;&nbsp;---&nbsp;&nbsp;this&nbsp;script&nbsp;is&nbsp;used&nbsp;to&nbsp;start&nbsp;and&nbsp;stop&nbsp;zookeeper
#
#&nbsp;chkconfig:&nbsp;&nbsp;&nbsp;-&nbsp;80&nbsp;12
#&nbsp;description:&nbsp;&nbsp;zookeeper&nbsp;is&nbsp;a&nbsp;centralized&nbsp;service&nbsp;for&nbsp;maintaining&nbsp;configuration&nbsp;information,naming,providing&nbsp;distributed&nbsp;synchronization,and&nbsp;providing&nbsp;group&nbsp;services.&nbsp;
#&nbsp;processname:&nbsp;zookeeper</pre>
<p><br></p>
<p>&nbsp;chkconfig： 一行告诉chkconfig这个服务默认将以什么级别启动，启动和关闭的优先级是多少。- 表示任意级别</p>
<p>&nbsp;description: 一行是这个服务的描述信息</p>
<p><br></p>
<p>添加这两行后就可以正常使用chkconfig设置开机启动了<br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p><br></p>
<p>参考文章：</p>
<p><a href="http://maosheng.iteye.com/blog/2224962" target="_blank">http://maosheng.iteye.com/blog/2224962</a> </p>
<p><br></p>
<p>本文出自 “<a href="http://john88wang.blog.51cto.com">Linux SA John</a>” 博客，请务必保留此出处<a href="http://john88wang.blog.51cto.com/2165294/1745315">http://john88wang.blog.51cto.com/2165294/1745315</a></p>
