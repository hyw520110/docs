<p><span style="font-size:14px;">1. 为什么选择奇数台机器部署zookeeper集群：</span></p>
<p><span style="font-size:14px;">关于ZooKeeper，需要明确一个很重要的特性：集群中只要有过半的机器是正常工作的，那么整个集群对外就是可用的，即过半存活即可用。</span></p>
<p><span style="font-size:14px;">部署奇数台机器可以充分利用集群中的每个节点提供容灾能力。</span></p>
<p><span style="font-size:14px;">如果想搭建一个能够允许F台机器down掉的集群，那么就要部署一个由2xF+1 台机器构成的ZK集群。</span></p>
<p><span style="font-size:14px;">通常都建议尝试跨机房部署。</span></p>
<p><br></p>
<p><span style="font-size:14px;">2. Server的自检恢复&nbsp;</span></p>
<p><span style="font-size:14px;">ZK运行过程中，如果出现一些无法处理的异常，会直接退出进程，也就是所谓的快速失败（fail fast）模式。</span></p>
<p><span style="font-size:14px;">由于zookeeper具有过半存活即可用的特性，使得集群中少数机器down掉后，整个集群还是可以对外正常提供服务的。另外，这些down掉的机器重启之后，能够自动加入到集群中，并且自动和集群中其它机器进行状态同步（主要就是从Leader那里同步最新的数据），从而达到自我恢复的目的。&nbsp;</span></p>
<p><span style="font-size:14px;">因此，我们很容易就可以想到，是否可以借助一些工具来自动完成机器的状态检测与重启工作。回答是肯定的，这里推荐两个工具： Daemontools(http://cr.yp.to/daemontools.html) 和 SMF（http://en.wikipedia.org/wiki/Service_Management_Facility），能够帮助你监控ZK进程，一旦进程退出后，能够自动重启进程，从而使down掉的机器能够重新加入到集群中去。</span></p>
<p><br></p>
<p style="white-space:normal;"><span style="font-size:14px;">3. syncLimit参数设定了允许一个跟随者与领导者进行同步的时间。</span></p>
<p style="white-space:normal;"><span style="font-size:14px;">如果在设定的时间段内，一个跟随者未能完成同步，它将会自己重启。所有关联到这个跟随者的客户端将连接到另外一个跟随者。</span></p>
<p><br></p>
<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(85,85,85);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><span style="font-size:14px;">4. initLimit参数设定了允许所有跟随者与领导者进行连接并同步的时间。</span></p>
<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(85,85,85);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><span style="font-size:14px;">如果在设定的时间段内，半数以上的跟随者未能完成同步，领导者便会宣布放弃领导地位，然后进行另外一次领导者选举。</span></p>
<p style="padding:0px;margin-top:0px;margin-bottom:0px;clear:both;height:auto;color:rgb(85,85,85);font-family:'宋体', 'Arial Narrow', arial, serif;font-size:14px;line-height:28px;white-space:normal;background-color:rgb(255,255,255);"><span style="font-size:14px;">如果这种情况经常发生（可以通过日志中的记录发现这种情况），则表明设定的值太小。</span></p>
<p><br></p>
<p><span style="font-size:14px;">5. 设置Java heap 大小</span></p>
<p><span style="font-size:14px;">避免内存与磁盘空间的交换，能够大大提升ZK的性能，设置合理的heap大小则能有效避免此类空间交换的触发。</span></p>
<p><span style="font-size:14px;">通常在一个物理内存为4G的机器上，最多设置-Xmx为3G。</span></p>
<p><br></p>
