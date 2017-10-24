<p>&nbsp;</p> 
<h2 class="entry-title" style="margin-top: 0.83em; margin-right: 0px; margin-bottom: 0.83em; margin-left: -2px; font-family: Georgia, 'Times New Roman', Times, serif; -webkit-text-size-adjust: none; max-width: 73%; word-break: break-all; word-wrap: break-word; background-color: rgb(255, 255, 255); "><a href="http://blog.jpush.cn/index.php/push_zookeeper_study_usage/" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; ">Zookeeper 的学习与运用</a></h2> 
<div class="posted-on" style="-webkit-text-size-adjust: none; font-size: 0.75rem; margin-right: 3px; padding-top: 6px; padding-right: 6px; padding-bottom: 6px; padding-left: 25px; position: relative; word-break: break-all; word-wrap: break-word; margin-top: 0px; margin-bottom: 10px; margin-left: 0px; color: rgb(25, 25, 25); background-image: -webkit-gradient(linear, 0% 0%, 0% 100%, from(rgb(238, 238, 238)), to(rgb(239, 239, 239))); background-attachment: initial; background-origin: initial; background-clip: initial; background-color: rgb(255, 255, 255); border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: rgba(100, 100, 100, 0.292969); font-family: Geneva, Arial, Helvetica, sans-serif; ">
 <span class="meta-prep meta-prep-author">Posted on</span>&nbsp;
 <a href="http://blog.jpush.cn/index.php/push_zookeeper_study_usage/" title="2012 年 10 月 11 日 下午 4:14" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; background-image: none; background-attachment: initial; background-origin: initial; background-clip: initial; background-color: initial; color: rgb(0, 0, 0); margin-left: 1em; background-position: initial initial; background-repeat: initial initial; "><span class="entry-date updated">2012 年 10 月 11 日 下午 4:14</span></a>&nbsp;
 <span class="meta-sep" style="margin-left: 1em; ">by</span>&nbsp;
 <span class="author vcard"><a class="url fn n" href="http://blog.jpush.cn/index.php/author/wangfeng/" title="View all posts by 椰风" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; background-image: none; background-attachment: initial; background-origin: initial; background-clip: initial; background-color: initial; color: rgb(0, 0, 0); margin-left: 1em; background-position: initial initial; background-repeat: initial initial; ">椰风</a></span>
 <a href="http://blog.jpush.cn/index.php/push_zookeeper_study_usage/#comments" class="enough-comment-link" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; position: absolute; right: 0px; background-image: -webkit-gradient(linear, 0% 0%, 0% 100%, from(rgb(239, 239, 239)), to(rgb(238, 238, 238))); background-attachment: initial; background-origin: initial; background-clip: initial; background-color: initial; color: rgb(0, 0, 0); margin-left: 1em; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: rgba(100, 100, 100, 0.296875); display: inline-block; height: 30px; width: 100px; border-top-left-radius: 5px; border-top-right-radius: 5px; border-bottom-right-radius: 5px; border-bottom-left-radius: 5px; top: -40px; background-position: initial initial; background-repeat: initial initial; "><em style="position: absolute; top: 8px; left: 19px; display: block; ">Comment</em></a>
</div> 
<div class="entry-content" style="-webkit-text-size-adjust: none; max-width: 100%; word-break: break-all; word-wrap: break-word; font-family: Geneva, Arial, Helvetica, sans-serif; font-size: 16px; background-color: rgb(255, 255, 255); "> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">引子？</h3> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">云计算越来越流行的今天，单一机器处理能力已经不能满足我们的需求，不得不采用大量的服务集群。服务集群对外提供服务的过程中，有很多的配置需要随时更新，服务间需要协调工作，这些信息如何推送到各个节点？并且保证信息的一致性和可靠性？</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">众所周知，分布式协调服务很难正确无误的实现，它们很容易在竞争条件和死锁上犯错误。如何在这方面节省力气？Zookeeper是一个不错的选择。Zookeeper背后的动机就是解除分布式应用在实现协调服务上的痛苦。本文在介绍Zookeeper的基本理论基础上，用Zookeeper实现了一个配置管理中心，利用Zookeeper将配置信息分发到各个服务节点上，并保证信息的正确性和一致性。</p> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper是什么？</h3> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">引用官方的说法：“Zookeeper是一个高性能，分布式的，开源分布式应用协调服务。它提供了简单原始的功能，分布式应用可以基于它实现更高级的服务，比如同步，配置管理，集群管理，名空间。它被设计为易于编程，使用文件系统目录树作为数据模型。服务端跑在java上，提供java和C的客户端API”。</p> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper总体结构</h3> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">Zookeeper服务自身组成一个集群(2n+1个服务允许n个失效)。Zookeeper服务有两个角色，一个是leader，负责写服务和数据同步，剩下的是follower，提供读服务，leader失效后会在follower中重新选举新的leader。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">Zookeeper逻辑图如下，</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; "><img onload="if(this.width>650) this.width=650;" src="http://blog.jpush.cn/wp-content/uploads/2012/10/1.jpg" alt="" width="603" height="188" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; border-image: initial; margin-top: 0.5rem; margin-right: 0.5rem; margin-bottom: 0.5rem; margin-left: 0.5rem; height: auto; max-width: 96%; "></p> 
 <ol style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; "> 
  <li><span style="font-size: medium; ">客户端可以连接到每个server，每个server的数据完全相同。</span></li> 
  <li><span style="font-size: medium; ">每个follower都和leader有连接，接受leader的数据更新操作。</span></li> 
  <li><span style="font-size: medium; ">Server记录事务日志和快照到持久存储。</span></li> 
  <li><span style="font-size: medium; ">大多数server可用，整体服务就可用。</span></li> 
 </ol> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper数据模型</h3> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">Zookeeper表现为一个分层的文件系统目录树结构（不同于文件系统的是，节点可以有自己的数据，而文件系统中的目录节点只有子节点）。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">数据模型结构图如下，</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; "><img onload="if(this.width>650) this.width=650;" src="http://blog.jpush.cn/wp-content/uploads/2012/10/2.png" alt="" width="439" height="250" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; border-image: initial; margin-top: 0.5rem; margin-right: 0.5rem; margin-bottom: 0.5rem; margin-left: 0.5rem; height: auto; max-width: 96%; "></p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">圆形节点可以含有子节点，多边形节点不能含有子节点。一个节点对应一个应用，节点存储的数据就是应用需要的配置信息。</p> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper 特点</h3> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>顺序一致性：按照客户端发送请求的顺序更新数据。</li> 
  <li>原子性：更新要么成功，要么失败，不会出现部分更新。</li> 
  <li>单一性 ：无论客户端连接哪个server，都会看到同一个视图。</li> 
  <li>可靠性：一旦数据更新成功，将一直保持，直到新的更新。</li> 
  <li>及时性：客户端会在一个确定的时间内得到最新的数据。</li> 
 </ul> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper运用场景</h3> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>数据发布与订阅 （我的业务用到这个特性，后面会有详细介绍）</li> 
 </ul> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">应用配置集中到节点上，应用启动时主动获取，并在节点上注册一个watcher，每次配置更新都会通知到应用。</p> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>名空间服务</li> 
 </ul> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">分布式命名服务，创建一个节点后，节点的路径就是全局唯一的，可以作为全局名称使用。</p> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>分布式通知/协调</li> 
 </ul> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">不同的系统都监听同一个节点，一旦有了更新，另一个系统能够收到通知。</p> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>分布式锁</li> 
 </ul> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">Zookeeper能保证数据的强一致性，用户任何时候都可以相信集群中每个节点的数据都是相同的。一个用户创建一个节点作为锁，另一个用户检测该节点，如果存在，代表别的用户已经锁住，如果不存在，则可以创建一个节点，代表拥有一个锁。</p> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li>集群管理</li> 
 </ul> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">每个加入集群的机器都创建一个节点，写入自己的状态。监控父节点的用户会受到通知，进行相应的处理。离开时删除节点，监控父节点的用户同样会收到通知。</p> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">Zookeeper在我们业务逻辑上的运用</h3> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">我们公司做极光推送，Push 业务平台有大量的逻辑服务器，按业务类型分组。逻辑服务的运行依赖于配置，并且配置会在线调整，需要一个集中的配置项管理中心。Zookeeper的发布与订阅特性以及发送更新通知的机制很好的满足了我们的需求。Zookeeper的容灾特性也免去了我们相关的大量管理工作。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">下面我主要和大家分享一下Zookeeper在我们内部服务中的应用。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">a. 我们的逻辑服务器包含两类配置。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">一种为Acl（访问控制列表），用户的消息消费后，按照列表中的条件走向下一个逻辑服务器。另一种只是单独的算法逻辑的外提，称为Agl（访问算法列表），但是其中某些判断条件会经常变化。这两类配置被收集到了配置管理中心（即Zookeeper）。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">逻辑图如下，</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; "><img onload="if(this.width>650) this.width=650;" src="http://blog.jpush.cn/wp-content/uploads/2012/10/3.jpg" alt="" width="388" height="416" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; border-image: initial; margin-top: 0.5rem; margin-right: 0.5rem; margin-bottom: 0.5rem; margin-left: 0.5rem; height: auto; max-width: 96%; "></p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">用户编辑好策略配置信息（xml格式），通过客户端加载到Zookeeper。Zookeeper立即通知其下的逻辑服务器（BLx），逻辑服务器下载最新的配置策略，并应用新的策略。新的策略有可能改变某一段id范围内用户的数据流向，或越过原来的逻辑服务器，或指向新加入的逻辑服务器。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">b. 数据模型设计</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">同一类型的逻辑服务在Zookeeper上创建一个节点，共享相同的配置信息。<br> 该节点下面为策略配置项，分为Acl和Agl两类，如下图：（以代理逻辑服务为例）</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; "><img onload="if(this.width>650) this.width=650;" src="http://blog.jpush.cn/wp-content/uploads/2012/10/4.jpg" alt="" width="382" height="445" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; border-image: initial; margin-top: 0.5rem; margin-right: 0.5rem; margin-bottom: 0.5rem; margin-left: 0.5rem; height: auto; max-width: 96%; "></p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">Acl1, Acl2, Acl3, Agl1, Agl2分别存有策略配置信息。变化后会通知监听Proxy节点的逻辑服务器，Proxy逻辑服务器下载最新策略，并应用该策略。新节点的加入和退出也会通知到Proxy逻辑服务器。</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; ">c. 业务处理流程如下图</p> 
 <p style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; line-height: 1.5; "><img onload="if(this.width>650) this.width=650;" src="http://blog.jpush.cn/wp-content/uploads/2012/10/5.jpg" alt="" width="370" height="386" style="border-top-width: 0px; border-right-width: 0px; border-bottom-width: 0px; border-left-width: 0px; border-style: initial; border-color: initial; border-image: initial; margin-top: 0.5rem; margin-right: 0.5rem; margin-bottom: 0.5rem; margin-left: 0.5rem; height: auto; max-width: 96%; "></p> 
 <ol style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; "> 
  <li>逻辑服务监听自己类型节点（本例如前图Proxy节点）</li> 
  <li>编辑新策略,加载策略到Zookeeper（策略保存在Proxy/Acls/Acl[1..n]，或Proxy/Agls/Agl1[1..n]）</li> 
  <li>Zookeeper通知各逻辑节点</li> 
  <li>各逻辑节点下载新策略到本地，并应用新策略</li> 
 </ol> 
 <h3 style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; font-family: Georgia, 'Times New Roman', Times, serif; ">参考</h3> 
 <ul style="margin-top: 1em; margin-right: 0px; margin-bottom: 1em; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 40px; -webkit-padding-start: 1rem; "> 
  <li><a href="http://zookeeper.apache.org/doc/trunk/ZookeeperOver.html" target="_blank" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; ">Zookeeper官方介绍</a></li> 
  <li><a href="http://rdc.taobao.com/team/jm/archives/1232" target="_blank" style="max-width: 100%; text-decoration: none; word-break: break-all; word-wrap: break-word; ">Zookeeper典型使用场景一览 － 淘宝综合业务平台团队博客</a></li> 
 </ul> 
</div>
