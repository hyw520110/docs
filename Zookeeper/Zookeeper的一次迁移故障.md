<p><span style="font-size:13px;font-family:'宋体';"> &nbsp; &nbsp;前阶段同事迁移</span><span lang="en-us" style="font-size:13px;font-family:consolas;" xml:lang="en-us">Zookeeper</span><span style="font-size:13px;font-family:'宋体';">（是给</span><span lang="en-us" style="font-size:13px;font-family:consolas;" xml:lang="en-us">Kafka</span><span style="font-size:13px;font-family:'宋体';">使用的以及</span><span lang="en-us" style="font-size:13px;font-family:consolas;" xml:lang="en-us">flume</span><span style="font-size:13px;font-family:'宋体';">使用）后发现所有</span><span lang="en-us" style="font-size:13px;font-family:consolas;" xml:lang="en-us">Flume-producer/consumer</span><span style="font-size:13px;font-family:'宋体';">端集体报错：</span></p>
<p><span style="font-size:13px;font-family:'宋体';"></span></p>
<p><span style="font-size:13px;font-family:'宋体';"></span><span style="font-size:13px;font-family:'宋体';"></span></p>
<pre class="brush:java;toolbar:false;">07 Jan 2014 01:19:32,571 INFO  [conf-file-poller-0-SendThread(xxx:2181)] (org.apache.zookeeper.ClientCnxn$SendThread.startConnect:1058)  - Opening socket connection to server xxx:2181
07 Jan 2014 01:19:32,572 INFO  [conf-file-poller-0-SendThread(xxx:2181)] (org.apache.zookeeper.ClientCnxn$SendThread.primeConnection:947)  - Socket connection established to xxx:2181, initiating session
07 Jan 2014 01:19:32,573 INFO  [conf-file-poller-0-SendThread(xxx:2181)] (org.apache.zookeeper.ClientCnxn$SendThread.run:1183)  - Unable to read additional data from server sessionid 0x142f42b91871911, likely server has closed socket, closing socket connection and attempting reconnect
07 Jan 2014 01:19:32,845 INFO  [conf-file-poller-0-SendThread(xxx:2181)] (org.apache.zookeeper.ClientCnxn$SendThread.startConnect:1058)  - Opening socket connection to server xxx:2181</pre>
<p><span style="font-size:13px;font-family:'宋体';">一直在不断的重试连接失败再重试，问同事说：网路连通性早就验证过，然后查看server端日志发现：</span><br></p>
<p><span style="font-size:13px;font-family:'宋体';"></span></p>
<p><span style="font-size:13px;font-family:'宋体';"></span><span style="font-size:13px;font-family:'宋体';"></span></p>
<p><span style="font-size:13px;font-family:'宋体';"></span></p>
<pre class="brush:java;toolbar:false;">2014-01-06 23:59:59,987 [myid:1] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@197] - Accepted socket connection from /xxx:45282
2014-01-06 23:59:59,987 [myid:1] - WARN  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:ZooKeeperServer@793] - Connection request from old client xxx:45282; will
be dropped if server is in r-o mode
2014-01-06 23:59:59,987 [myid:1] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:ZooKeeperServer@812] - Refusing session request for client xxx:45282 as it
has seen zxid 0x60fd15564 our last zxid is 0x10000000f client must try another server
2014-01-06 23:59:59,987 [myid:1] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxn@1001] - Closed socket connection for client xxx:45282 (no se
ssion established for client)
2014-01-06 23:59:59,989 [myid:1] - INFO  [NIOServerCxn.Factory:0.0.0.0/0.0.0.0:2181:NIOServerCnxnFactory@197] - Accepted socket connection from xxx:45285</pre>
<p><span style="font-size:13px;font-family:'宋体';">发现Flume还是保留原来的zxid，但是现在的zxid竟然是0，所以抛出异常！</span><br></p>
<pre class="brush:java;toolbar:false;">if (connReq.getLastZxidSeen() &gt; zkDb.dataTree.lastProcessedZxid) {
            String msg = "Refusing session request for client "
                + cnxn.getRemoteSocketAddress()
                + " as it has seen zxid 0x"
                + Long.toHexString(connReq.getLastZxidSeen())
                + " our last zxid is 0x"
                + Long.toHexString(getZKDatabase().getDataTreeLastProcessedZxid())
                + " client must try another server";
            LOG.info(msg);
            throw new CloseRequestException(msg);
        }</pre>
<p><span style="font-size:13px;font-family:'宋体';"> &nbsp; &nbsp;后来问同事是怎么做的迁移：先启动一套新的集群，然后关闭老的集群，同时在老集群的一个IP：2181起了一个haproxy代理新集群以为这样，可以做到透明迁移=。=，其实是触发了ZK的bug-832导致不停的重试连接，只有重启flume才可以解决</span><br></p>
<p><span style="font-size:13px;font-family:'宋体';"> &nbsp; &nbsp;正确的迁移方式是，把新集群加入老集群，然后修改Flume配置等一段时间（flume自动reconfig）后再关闭老集群就不会触发这个问题了.<br></span></p>
<p>本文出自 “<a href="http://boylook.blog.51cto.com">MIKE老毕的海贼船</a>” 博客，请务必保留此出处<a href="http://boylook.blog.51cto.com/7934327/1365364">http://boylook.blog.51cto.com/7934327/1365364</a></p>
