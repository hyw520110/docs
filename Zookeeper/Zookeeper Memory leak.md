<p style="text-indent:28px;"><span style="font-size:13px;font-family:'宋体';">依然是前阶段（太久没写</span><span style="font-size:13px;font-family:consolas;">blog</span><span style="font-size:13px;font-family:'宋体';">了）发现线上</span><span style="font-size:13px;font-family:consolas;">Kafka</span><span style="font-size:13px;font-family:'宋体';">用的</span><span style="font-size:13px;font-family:consolas;">Zookeeper</span><span style="font-size:13px;font-family:'宋体';">集群其中一个节点内存用到了</span><span style="font-size:13px;font-family:consolas;">4</span><span style="font-size:13px;font-family:'宋体';">个多</span><span style="font-size:13px;font-family:consolas;">GB</span><span style="font-size:13px;font-family:'宋体';">，进一步发现这个节点的</span><span style="font-size:13px;font-family:consolas;">watcher</span><span style="font-size:13px;font-family:'宋体';">有几百万了</span><span style="font-size:13px;font-family:consolas;">=</span><span style="font-size:13px;font-family:'宋体';">。</span><span style="font-size:13px;font-family:consolas;">=</span></p>
<p style="text-indent:28px;"><span style="font-size:13px;font-family:'宋体';">发现原来在所有的</span><span style="font-size:13px;font-family:consolas;">flume-agent</span><span style="font-size:13px;font-family:'宋体';">上只配置了这个节点，以为会自动感知（线上版本是</span><span style="font-size:13px;font-family:consolas;">3.4.5</span><span style="font-size:13px;font-family:'宋体';">，还没这么高端的功能）；</span></p>
<p style="text-indent:28px;"><span style="font-size:13px;font-family:'宋体';">另外发现</span><span style="font-size:13px;font-family:consolas;">agent</span><span style="font-size:13px;font-family:'宋体';">端的</span><span style="font-size:13px;font-family:consolas;">flume conf</span><span style="font-size:13px;font-family:'宋体';">是自动生成的，其中</span><span style="font-size:13px;font-family:consolas;">topic</span><span style="font-size:13px;font-family:'宋体';">是判断固定路径下所有日志的文件名，每个文件名会生成一个</span><span style="font-size:13px;font-family:consolas;">topic+channel</span><span style="font-size:13px;font-family:'宋体';">，有些应用会不遵守规范在该路径下写很多文件，所以很多</span><span style="font-size:13px;font-family:consolas;">session</span><span style="font-size:13px;font-family:'宋体';">会监听几百个</span><span style="font-size:13px;font-family:consolas;">watcher.</span></p>
<span style="font-size:13px;font-family:'宋体';"> &nbsp; &nbsp;很多</span>
<span style="font-size:13px;font-family:consolas;">session</span>
<span style="font-size:13px;font-family:'宋体';">其实已经</span>
<span style="font-size:13px;font-family:consolas;">closed</span>
<span style="font-size:13px;font-family:'宋体';">掉了但是</span>
<span style="font-size:13px;font-family:consolas;">watcher</span>
<span style="font-size:13px;font-family:'宋体';">还在，这其实是</span>
<span style="font-size:13px;font-family:consolas;">Zookeeper</span>
<span style="font-size:13px;font-family:'宋体';">的一个</span>
<span style="font-size:13px;font-family:consolas;">bug</span>
<span style="font-size:13px;font-family:'宋体';">（</span>
<span style="font-size:13px;font-family:consolas;">ZOOKEEPER-1382</span>
<span style="font-size:13px;font-family:'宋体';">）导致的</span>
<span style="font-size:13px;font-family:consolas;">memory leak,down</span>
<span style="font-size:13px;font-family:'宋体';">掉到无所谓，就怕</span>
<span style="font-size:13px;font-family:consolas;">gc</span>
<span style="font-size:13px;font-family:'宋体';">导致的</span>
<span style="font-size:13px;font-family:consolas;">slow response</span>
<span style="font-size:13px;font-family:'宋体';">进而影响</span>
<span style="font-size:13px;font-family:consolas;">produce/consume.</span>
<p><br></p>
<p>本文出自 “<a href="http://boylook.blog.51cto.com">MIKE老毕的海贼船</a>” 博客，请务必保留此出处<a href="http://boylook.blog.51cto.com/7934327/1365392">http://boylook.blog.51cto.com/7934327/1365392</a></p>
