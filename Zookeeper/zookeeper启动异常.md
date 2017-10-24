<p><span style="font-size:12px;">zookeeper启动异常</span></p>
<p><strong><span style="font-size:12px;">1. 新部署的zookeeper或清理过数据信息后，启动zookeeper的时候报错并启动失败。</span></strong></p>
<p><span style="font-size:12px;">此时可能是以下几个方面引起的：</span></p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p><span style="font-size:12px;">在数据目录下就是dataDir参数指定的那个目录下，没有创建myid文件，需要自己创建myid文件，并在myid文件中写上这个Server ID数字。</span></p></li>
 <li><p><span style="font-size:12px;">没有创建日志文件路径即dataLogDir目录，一定要创建到logs文件夹。</span></p></li>
</ul>
<p><span style="font-size:12px;">创建完以上两个文件后可以重试重启。</span></p>
<p><br></p>
<p><strong><span style="font-size:14px;">2.&nbsp;加载数据出错&nbsp;</span></strong></p>
<p><span style="font-size:12px;">ZK在启动的过程中，首先会根据事务日志中的事务日志记录，从本地磁盘加载最后一次提交时候的快照数据，如果读取事务日志出错或是其它问题（通常在日志中可以看到一些IO异常），将导致server将无法启动。碰到类似于这种数据文件出错导致无法启动服务器的情况，一般按照如下顺序来恢复：&nbsp;</span></p>
<ul class="list-paddingleft-2" style="list-style-type:disc;">
 <li><p><span style="font-size:12px;">确认集群中其它机器是否正常工作，方法是使用&#xfffd;stat‖这个命令来检查：echo stat|nc ip 2181&nbsp;</span></p></li>
 <li><p><span style="font-size:12px;">如果确认其它机器是正常工作的（这里要说明下，所谓正常工作还是指集群中有过半机器可用），那么可以开始删除本机的一些数据了，删除$dataDir/version-2和$dataLogDir/version-2 两个目录下的所有文件。&nbsp;</span></p></li>
</ul>
<p><span style="font-size:12px;">重启server。重启之后，这个机器就会从Leader那里同步到最新数据，然后重新加入到集群中提供服务。</span></p>
<p><strong><span style="font-size:12px;"><br></span></strong></p>
<p><strong><span style="font-size:12px;">3. 集群节点启动异常</span></strong></p>
<p><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">在启动集群中第一个节点时，会</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">发现一些系统异常提示（这种异常不用理会，属于正常情况），如下图</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">所示：</span></p>
<p><img onload="if(this.width>650) this.width=650;" src="http://hi.csdn.net/attachment/201102/15/0_1297729633ViGf.gif" alt="" style="font-size:12px;text-indent:21pt;"></p>
<p><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">产生如上图所示的异常信息是由于</span><span style="font-size:12px;text-indent:21pt;">ZooKeeper</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">服务的每个节点都拥有全局的配置信息，它们在启动的时候需要随时地进行</span><span style="font-size:12px;text-indent:21pt;">Leader</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">选举操作。此时第一个启动的</span><span style="font-size:12px;text-indent:21pt;">Zookeeper节点</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">需要和另外一些</span><span style="font-size:12px;text-indent:21pt;">ZooKeeper节点</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">进行通信。但是，另外两个</span><span style="font-size:12px;text-indent:21pt;">ZooKeeper节点</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">还没有启动起来，因此将会产生上述所示的异常信息。</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">我们直接将其忽略即可，因为当把图示中的“</span><span style="font-size:12px;text-indent:21pt;">2</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">号”和“</span><span style="font-size:12px;text-indent:21pt;">3</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">号”</span><span style="font-size:12px;text-indent:21pt;">ZooKeeper节点</span><span style="font-size:12px;text-indent:21pt;font-family:'宋体';">启动起来之后，相应的异常信息就回自然而然地消失。</span></p>
