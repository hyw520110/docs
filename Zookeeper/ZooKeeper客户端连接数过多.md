<p><span style="font-size:12px;">ZooKeeper限制客户端连接数</span></p>
<p><span style="font-size:12px;">问题：</span></p>
<p><span style="font-size:12px;">最近发现ZooKeeper服务器上的连接数过多，都是连接zookeeper的。</span></p>
<p><br></p>
<p><span style="font-size:12px;">解决方案：</span></p>
<p><span style="font-size:12px;">通过查询分析，发现zookeeper的一个客户端使用有问题，创建的连接过多导致的。</span></p>
<p><span style="font-size:12px;">zookeeper有没有相应的功能能做下限制呢？</span></p>
<p><span style="font-size:12px;">查看zookeeper的配置参数，可以发现zookeeper的可以通过相应的配置来限制某ip的连接数。</span></p>
<p><br></p>
<p><span style="font-size:12px;"><strong>maxClientCnxns</strong></span></p>
<p><span style="font-size:12px;"><span style="font-size:12px;text-indent:28px;font-family:'宋体';">这个配置参数将限制连接到</span><span style="font-size:12px;text-indent:28px;">ZooKeeper</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">的客户端的数量，限制并发连接的数量，它通过</span><span style="font-size:12px;text-indent:28px;">IP</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">来区分不同的客户端。此配置选项可以用来阻止某些类别的</span><span style="font-size:12px;text-indent:28px;">Dos</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">攻击。该参数<span style="color:rgb(44,44,44);font-family:'Comic Sans MS';font-size:12px;line-height:24px;background-color:rgb(255,255,255);">默认是60，</span>将它设置为</span><span style="font-size:12px;text-indent:28px;">0</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">将会取消对并发连接的限制。</span></span></p>
<p><span style="font-size:12px;"><span style="font-size:12px;text-indent:28px;font-family:'宋体';">例如，将</span><span style="font-size:12px;text-indent:28px;">maxClientCnxns</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">的值设置为</span><span style="font-size:12px;text-indent:28px;">1</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">，如下所示：</span></span></p>
<p><span style="font-size:12px;">#set maxClientCnxns</span></p>
<p><span style="font-size:12px;">maxClientCnxns=1</span></p>
<p><span style="font-size:12px;"><span style="font-size:12px;text-indent:28px;font-family:'宋体';">启动</span><span style="font-size:12px;text-indent:28px;">ZooKeeper</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">之后，首先用一个客户端连接到</span><span style="font-size:12px;text-indent:28px;">ZooKeeper</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">服务器之上。然后，当第二个客户端尝试对</span><span style="font-size:12px;text-indent:28px;">ZooKeeper</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">进行连接，或者某些隐式的对客户端的连接操作，将会触发</span><span style="font-size:12px;text-indent:28px;">ZooKeeper</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">的上述配置。系统会提示相关信息，如下图</span><span style="font-size:12px;text-indent:28px;">1</span><span style="font-size:12px;text-indent:28px;font-family:'宋体';">所示：</span></span><img onload="if(this.width>650) this.width=650;" src="http://hi.csdn.net/attachment/201102/15/0_1297729063oO51.gif" alt="" style="text-align:center;text-indent:28px;"></p>
<p><br></p>
<p><span style="font-size:12px;">ZooKeeper关于maxClientCnxns参数的官方解释：</span></p>
<p><span style="color:rgb(44,44,44);font-family:'Comic Sans MS';line-height:24px;font-size:12px;background-color:rgb(255,255,255);">单个客户端与单台服务器之间的连接数的限制，是ip级别的，默认是60，如果设置为0，那么表明不作任何限制。请注意这个限制的使用范围，仅仅是单台客户端机器与单台ZK服务器之间的连接数限制，不是针对指定客户端IP，也不是ZK集群的连接数限制，也不是单台ZK对所有客户端的连接数限制。</span></p>
<p><span style="font-size:12px;">maxClientCnxns</span></p>
<p><span style="font-size:12px;">Limits the number of concurrent connections (at the socket level) that a single client, identified by IP address, may make to a single member of the ZooKeeper ensemble. This is used to prevent certain classes of DoS attacks, including file descriptor exhaustion. The default is 60. Setting this to 0 entirely removes the limit on concurrent connections.</span></p>
<p><span style="color:rgb(44,44,44);font-family:'Comic Sans MS';line-height:24px;font-size:12px;background-color:rgb(255,255,255);"><br></span></p>
