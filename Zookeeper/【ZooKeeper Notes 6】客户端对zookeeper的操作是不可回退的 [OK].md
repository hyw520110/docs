<p>&nbsp;</p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">&nbsp; &nbsp; &nbsp; &nbsp;zookeeper客户端对server的操作都是不可回退的，意思是说，zk的客户端每次和server进行通信的时候，</span></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">会记住server上最新的zxid。如果某个时刻，客户端和server断开了连接，那么等到下次重新连接到集群中的</span></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">机器上时，会检查当前连接上的那个server是否和client有相同的zxid，或者已经是更新的zxid了。一旦客户端发现server的</span></span><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">zxid比自己小，那么客户端会断开和这个server的连接，并且重新连接集群中的其它server~</span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">1. zxid是检验的标准</span></span></p> 
<p><span style="font-size: 14px; "><span style="font-family: 'Comic Sans MS'; ">2. 这里是客户端主动断开连接，尝试连接其它server的~</span></span></p> 
<p>&nbsp;</p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/929588">http://nileader.blog.51cto.com/1381108/929588</a></p>
