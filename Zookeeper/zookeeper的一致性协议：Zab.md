<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">转自：<a href="http://blog.csdn.net/chen77716/article/details/7309915" target="_blank">http://blog.csdn.net/chen77716/article/details/7309915</a></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; &nbsp; &nbsp; &nbsp;</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">&nbsp; &nbsp; &nbsp; &nbsp; Zookeeper使用了一种称为ZabZookeeper Atomic Broadcast的协议作为其一致性复制的核心据其作者说这是一种新发算法其特点是充分考虑了Yahoo的具体情况高吞吐量、低延迟、健壮、简单但不过分要求其扩展性。下面将展示一些该协议的核心内容</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><em>另本文仅讨论Zookeeper使用的一致性协议而非讨论其源码实现</em></p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">Zookeeper的实现是有Client、Server构成Server端提供了一个一致性复制、存储服务Client端会提供一些具体的语义比如分布式锁、选举算法、分布式互斥等。从存储内容来说Server端更多的是存储一些数据的状态而非数据内容本身因此Zookeeper可以作为一个小文件系统使用。数据状态的存储量相对不大完全可以全部加载到内存中从而极大地消除了通信延迟。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">Server可以Crash后重启考虑到容错性Server必须“记住”之前的数据状态因此数据需要持久化但吞吐量很高时磁盘的IO便成为系统瓶颈其解决办法是使用缓存把随机写变为连续写。</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);">考虑到Zookeeper主要操作数据的状态为了保证状态的一致性Zookeeper提出了两个安全属性Safety Property</p>
<p style="margin-top:0px;margin-bottom:0px;padding:0px;font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><br></p>
<ul style="font-family:Arial;font-size:14px;line-height:26px;white-space:normal;background-color:rgb(255,255,255);" class="list-paddingleft-2">
 <li><p>全序Total order如果消息a在消息b之前发送则所有Server应该看到相同的结果</p></li>
 <li><p>因果顺序Causal order如果消息a在消息b之前发生a导致了b并被一起发送则a始终在b之前被执行。</p></li>
</ul>
<p>为了保证上述两个安全属性Zookeeper使用了TCP协议和Leader。通过使用TCP协议保证了消息的全序特性先发先到通过Leader解决了因果顺序问题先到Leader的先执行。因为有了LeaderZookeeper的架构就变为Master-Slave模式但在该模式中MasterLeader会Crash因此Zookeeper引入了Leader选举算法以保证系统的健壮性。归纳起来Zookeeper整个工作分两个阶段</p>
<ul class="list-paddingleft-2">
 <li><p>Atomic Broadcast</p></li>
 <li><p>Leader选举</p></li>
</ul>
<h3 style="margin:0px;padding:0px;"><a style="color:rgb(202,0,0);" name="t0"></a>1. Atomic Broadcast</h3>
<p>同一时刻存在一个Leader节点其他节点称为“Follower”如果是更新请求如果客户端连接到Leader节点则由Leader节点执行其请求如果连接到Follower节点则需转发请求到Leader节点执行。但对读请求Client可以直接从Follower上读取数据如果需要读到最新数据则需要从Leader节点进行Zookeeper设计的读写比例是21。</p>
<p>Leader通过一个简化版的二段提交模式向其他Follower发送请求但与二段提交有两个明显的不同之处</p>
<ul class="list-paddingleft-2">
 <li><p>因为只有一个LeaderLeader提交到Follower的请求一定会被接受没有其他Leader干扰</p></li>
 <li><p>不需要所有的Follower都响应成功只要一个多数派即可</p></li>
</ul>
<p>通俗地说如果有2f+1个节点允许f个节点失败。因为任何两个多数派必有一个交集当Leader切换时通过这些交集节点可以获得当前系统的最新状态。如果没有一个多数派存在存活节点数小于f+1则算法过程结束。但有一个特例</p>
<p>如果有A、B、C三个节点A是Leader如果B Crash则A、C能正常工作因为A是LeaderA、C还构成多数派如果A Crash则无法继续工作因为Leader选举的多数派无法构成。</p>
<h3 style="margin:0px;padding:0px;font-family:Arial;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><a style="color:rgb(202,0,0);" name="t1"></a>2. Leader Election</h3>
<p>Leader选举主要是依赖Paxos算法具体算法过程请参考其他博文这里仅考虑Leader选举带来的一些问题。Leader选举遇到的最大问题是”新老交互“的问题新Leader是否要继续老Leader的状态。这里要按老Leader Crash的时机点分几种情况</p>
<ol class="list-paddingleft-2">
 <li><p>老Leader在COMMIT前Crash已经提交到本地</p></li>
 <li><p>老Leader在COMMIT后Crash但有部分Follower接收到了Commit请求</p></li>
</ol>
<p>第一种情况这些数据只有老Leader自己知道当老Leader重启后需要与新Leader同步并把这些数据从本地删除以维持状态一致。</p>
<p>第二种情况新Leader应该能通过一个多数派获得老Leader提交的最新数据</p>
<p>老Leader重启后可能还会认为自己是Leader可能会继续发送未完成的请求从而因为两个Leader同时存在导致算法过程失败解决办法是把Leader信息加入每条消息的id中Zookeeper中称为zxidzxid为一64位数字高32位为leader信息又称为epoch每次leader转换时递增低32位为消息编号Leader转换时应该从0重新开始编号。通过zxidFollower能很容易发现请求是否来自老Leader从而拒绝老Leader的请求。</p>
<p>因为在老Leader中存在着数据删除情况1因此Zookeeper的数据存储要支持补偿操作这也就需要像数据库一样记录log。</p>
<h3 style="margin:0px;padding:0px;font-family:Arial;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><a style="color:rgb(202,0,0);" name="t2"></a>3. Zab与Paxos</h3>
<p>Zab的作者认为Zab与paxos并不相同只所以没有采用Paxos是因为Paxos保证不了全序顺序</p>
<pre style="white-space:pre-wrap;font-size:14px;line-height:26px;background-color:rgb(255,255,255);">Because&nbsp;multiple&nbsp;leaders&nbsp;can
propose&nbsp;a&nbsp;value&nbsp;for&nbsp;a&nbsp;given&nbsp;instance&nbsp;two&nbsp;problems&nbsp;arise.
First,&nbsp;proposals&nbsp;can&nbsp;conflict.&nbsp;Paxos&nbsp;uses&nbsp;ballots&nbsp;to&nbsp;detect&nbsp;and&nbsp;resolve&nbsp;conflicting&nbsp;proposals.&nbsp;
Second,&nbsp;it&nbsp;is&nbsp;not&nbsp;enough&nbsp;to&nbsp;know&nbsp;that&nbsp;a&nbsp;given&nbsp;instance&nbsp;number&nbsp;has&nbsp;been&nbsp;committed,&nbsp;processes&nbsp;must&nbsp;also&nbsp;be&nbsp;able&nbsp;to&nbsp;figure&nbsp;out&nbsp;which&nbsp;value&nbsp;has&nbsp;been&nbsp;committed.</pre>
<p>Paxos算法的确是不关系请求之间的逻辑顺序而只考虑数据之间的全序但很少有人直接使用paxos算法都会经过一定的简化、优化。</p>
<p>一般Paxos都会有几种简化形式其中之一便是在存在Leader的情况下可以简化为1个阶段Phase2。仅有一个阶段的场景需要有一个健壮的Leader因此工作重点就变为Leader选举在考虑到Learner的过程还需要一个”学习“的阶段通过这种方式Paxos可简化为两个阶段</p>
<ul class="list-paddingleft-2">
 <li><p>之前的Phase2</p></li>
 <li><p>Learn</p></li>
</ul>
<p>如果再考虑多数派要Learn成功这其实就是Zab协议。Paxos算法着重是强调了选举过程的控制对决议学习考虑的不多Zab恰好对此进行了补充。</p>
<p>之前有人说所有分布式算法都是Paxos的简化形式虽然很绝对但对很多情况的确如此但不知Zab的作者是否认同这种说法</p>
<h3 style="margin:0px;padding:0px;font-family:Arial;line-height:26px;white-space:normal;background-color:rgb(255,255,255);"><a style="color:rgb(202,0,0);" name="t3"></a>4.结束</h3>
<p>本文只是想从协议、算法的角度分析Zookeeper而非分析其源码实现因为Zookeeper版本的变化文中描述的场景或许已找不到对应的实现。另本文还试图揭露一个事实Zab就是Paxos的一种简化形式。</p>
<p>【参考资料】</p>
<ul class="list-paddingleft-2">
 <li><p>A simple totally ordered broadcast protocol<br></p></li>
 <li><p>paxos</p></li>
</ul>
<p><br></p>
