<p><span style="font-family:'comic sans ms';"> &nbsp; &nbsp; 转载请用注明：</span><a href="http://weibo.com/nileader" target="_blank"><span style="font-family:'comic sans ms';">@ni掌柜</span></a><span style="font-family:'comic sans ms';"> nileader@gmail.com</span></p>
<p><span style="font-family:'comic sans ms';"><span style="text-indent:28px;">在使用zookeeper过程中，我们知道，会有dataDir和dataLogDir两个目录，分别用于snapshot和事务日志的输出（默认情况下只有dataDir目录，snapshot和事务日志都保存在这个目录中，关于这两个目录的详细说明，请看《</span></span><a href="http://nileader.blog.51cto.com/1381108/795265" style="font-family:'微软雅黑', sans-serif;text-indent:28px;" target="_blank"><span style="font-family:'comic sans ms';">ZooKeeper管理员指南</span></a></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="text-indent:28px;">》）。</span><span style="font-family:'comic sans ms';"></span></p>
<p><span style="font-family:'comic sans ms';"> &nbsp; &nbsp; &nbsp;正常运行过程中，ZK会不断地把快照数据和事务日志输出到这两个目录，并且如果没有人为操作的话，ZK自己是不会清理这些文件的，需要管理员来清理，这里介绍4种清理日志的方法。在这4种方法中，推荐使用第一种方法，对于运维人员来说，将日志清理工作独立出来，便于统一管理也更可控。毕竟zk自带的一些工具并不怎么给力，这里是社区反映的两个问题：</span></p>
<p class="MsoNormal" style="text-indent:28px;text-align:left;"><a href="https://issues.apache.org/jira/browse/ZOOKEEPER-957" target="_blank"><span style="font-family:'comic sans ms';">https://issues.apache.org/jira/browse/ZOOKEEPER-957</span></a></p>
<p class="MsoNormal" style="text-indent:28px;text-align:left;"><a href="http://zookeeper-user.578899.n2.nabble.com/PurgeTxnLog-td6304244.html" target="_blank"><span style="font-family:'comic sans ms';">http://zookeeper-user.578899.n2.nabble.com/PurgeTxnLog-td6304244.html</span></a></p>
<p class="MsoNormal" style="text-indent:28px;text-align:left;"><span style="font-family:'comic sans ms';"><strong><span style="font-size:26px;">第一种</span></strong>，也是运维人员最常用的，写一个删除日志脚本，每天定时执行即可：</span></p>
<pre></pre>
<pre class="brush:pl;toolbar:false;">#!/bin/bash
          
#snapshot file dir
dataDir=/home/nileader/taokeeper/zk_data/version-2
#tran log dir
dataLogDir=/home/nileader/taokeeper/zk_log/version-2
#zk log dir
logDir=/home/nileader/taokeeper/logs
#Leave 60 files
count=60
count=$[$count+1]
ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f
ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f</pre>
<p><span style="font-family:'comic sans ms';"> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 以上这个脚本定义了删除对应两个目录中的文件，保留最新的60个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。<br></span></p>
<p><span style="font-family:'comic sans ms';"><strong><span style="font-size:26px;">第二种</span></strong>，使用ZK的工具类PurgeTxnLog，它的实现了一种简单的历史文件清理策略，可以在这里看一下他的使用方法：http://zookeeper.apache.org/doc/r3.4.3/api/index.html，可以指定要清理的目录和需要保留的文件数目，简单使用如下：</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<pre></pre>
<ol class="dp-xml list-paddingleft-2">
 <li class="alt"><p><span style="font-family:'comic sans ms';">java -cp zookeeper.jar:lib/slf4j-api-1.6.1.jar:lib/slf4j-log4j12-1.6.1.jar:lib/log4j-1.2.15.jar:conf org.apache.zookeeper.server.PurgeTxnLog <span class="tag">&lt;</span><span class="tag-name">dataDir</span><span class="tag">&gt;</span><span class="tag">&lt;</span><span class="tag-name">snapDir</span><span class="tag">&gt;</span> -n <span class="tag">&lt;</span><span class="tag-name">count</span><span class="tag">&gt;</span></span></p></li>
</ol>
<p><span style="font-family:'comic sans ms';"><strong><span style="font-size:26px;"><br></span></strong></span></p>
<p><span style="font-family:'comic sans ms';"><strong><span style="font-size:26px;">第三种</span></strong>，对于上面这个Java类的执行，ZK自己已经写好了脚本，在bin/zkCleanup.sh中，所以直接使用这个脚本也是可以执行清理工作的。</span></p>
<p><span style="font-family:'comic sans ms';"><strong><span style="font-size:26px;">第四种</span></strong>，从3.4.0开始，zookeeper提供了自动清理snapshot和事务日志的功能，通过配置 autopurge.snapRetainCount 和 autopurge.purgeInterval 这两个参数能够实现定时清理了。这两个参数都是在zoo.cfg中配置的：</span></p>
<p><span style="font-family:'comic sans ms';"><strong>autopurge.purgeInterval</strong> &nbsp;这个参数指定了清理频率，单位是小时，需要填写一个1或更大的整数，默认是0，表示不开启自己清理功能。</span></p>
<p><span style="font-family:'comic sans ms';"><strong>autopurge.snapRetainCount</strong> 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。</span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p><span style="font-family:'comic sans ms';"></span></p>
<p>本文出自 “<a href="http://nileader.blog.51cto.com">ni掌柜的IT专栏</a>” 博客，请务必保留此出处<a href="http://nileader.blog.51cto.com/1381108/932156">http://nileader.blog.51cto.com/1381108/932156</a></p>
