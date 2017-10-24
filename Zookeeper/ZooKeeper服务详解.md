<p>ZooKeeper服务详解<br></p>
<p>ZooKeeper是一个具有高可用性的高性能的协调服务。</p>
<p><strong>1.数据模型</strong></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper维护着一个树形层次结构，树中的节点被称为znode。znode可以用于存储数据，并与之相关联一个ACL。<span style="color:rgb(255,0,0);">通常存储小数据文件，限制在1MB以内</span>。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">ZooKeeper的数据访问具有原子性</span>。客户端在读取一个znode数据时，要么读到所有数据，要么操作失败，不能只读到部分数据。写数据也同样。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>znode有两种类型：<span style="color:rgb(255,0,0);">短暂的和持久的</span>，在创建时确定之后不能再修改。短暂znode与客户端会话相关联，会话结束则会被删除，而持久znode不依赖于客户端会话。短暂znode不可以有子节点。（对于那些需要知道特定时刻有哪些分布式资源可用的应用来说，使用短暂znode是一种理想的选择）</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>顺序znode是指名称中包含ZooKeeper指定顺序号的znode。在一个分布式系统中，顺序号可以被用于为所有的事件进行<span style="color:rgb(255,0,0);">全局排序</span>，这样客户端就可以通过顺序号来推断事件的顺序。使用顺序znode可以实现<span style="color:rgb(255,0,0);">共享锁</span>。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>znode以某种方式发生变化时，<span style="color:rgb(255,0,0);">“观察”（watch）机制可以让客户端得到通知</span>。可以针对ZooKeeper服务的操作来设置观察。观察只触发一次，需要多次接收的需要重新注册。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span></p>
<p><strong>2.操作</strong></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper的<span style="color:rgb(255,0,0);">更新操作有一个版本号匹配的条件限制。更新操作是非阻塞操作</span>，一个客户端的更新失败不会阻塞其他进程的执行。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper服务的操作：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>create&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>创建一个znode（必须要有父节点）</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>delete&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>删除一个znode（该znode不能有任何子节点）</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>exists&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>测试一个znode是否存在并且查询它的元数据</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>getACL, setACL&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>获取/设置一个znode的ACL</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>getChildren&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>获取一个znode的子节点列表</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>getData, setData&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>获取/设置一个znode所保存的数据</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>sync&nbsp;&nbsp;&nbsp;&nbsp;<span class="Apple-tab-span" style="white-space:pre;"></span>将客户端的znode视图与ZooKeeper同步</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>对于ZooKeeper客户端来说，主要有两种语言（Java和C）可以绑定使用，并在执行操作时都可以选择同步执行或异步执行。所有的异步操作的结果都是通过回调来传送的。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">同步API or 异步API？</span> 同步API使用简单好理解。异步API--事件驱动编程模型。异步API允许你以流水线方式处理请求，这在某些情况下可以提高更好的吞吐量。可想，如果你打算读取一大批znode，并且分别对他们进行处理。如果使用同步API，每个操作都会阻塞进程，直到该读操作完成；但如果使用异步API，你可以非常快的启动所有的异步读操作，并且在另外一个单独的线程中来处理他们的返回请求。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>观察触发器：在读操作 exits、getChildre和getData上可以设置观察，这些观察可以被写操作 create、delete和setData触发。当一个观察被触发时会产生一个观察事件，这个观察和触发它的操作共同决定了观察事件的类型。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>每个znode创建的时候都会带有一个ACL列表，用于决定谁可以对他执行何种操作。在类ZooDefs.Ids中有一些预定义的ACL，OPEN_ACL_UNSAFE表示将所有的权限（不包括ADMIN）授予每个人。ACL依赖于ZooKeeper的客户端身份验证机制，共提供了以下三种：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>digest：通过用户名和密码来识别客户端。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>host：通过客户端的主机名（hostname）来识别客户端。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ip：通过客户端的ip地址来识别客户端。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span></p>
<p><br></p>
<p><strong>3.实现</strong></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper服务有两种不同的运行模式。独立模式（standalone mode）和复制模式（replicated mode）.</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>独立模式：简单，适合于测试环境，不能保证高可用性和恢复性。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">复制模式</span>：适合生产环境，运行于一个计算机集群上，<span style="color:rgb(255,0,0);">通过复制来实现高可用性，只要集合体中半数以上的机器处于可用状态，它就能提供服务。因此集合体通常包含奇数台机器。</span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper概念：<span style="color:rgb(255,0,0);">它所做的就是确保对znode树的每个修改都会被复制到集合体中超过半数的机器上。如果少于半数的机器出现故障，则最少有一台机器保存最新的状态，其余的副本最终也会更新到这个状态。</span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">ZooKeeper使用了Zab协议，该协议包括两个无限重复的阶段</span>：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">阶段1：领导选举</span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>集合体中的所有机器通过一个选择过程来选出一台被称为“领导者”（leader）的机器，其他的机器被称为“跟随者”（follower）。一旦半数以上（或指定数量）的跟随者已经将其状态与领导者同步，则表明这个阶段已经完成。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">阶段2：原子广播</span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>所有的写请求都被转发给领导者，再由领导者将更新广播给跟随者。当半数以上的跟随者都已经将修改持久化以后，领导者才会提交这个更新，然后客户端才会收到一个更新成功的响应。这个用来达成共识的协议被设计成具有原子性，因此每个修改要么成功要么失败。这类似于数据库的两阶段提交协议。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>当领导者出现故障，其余的机器会选出另外一个领导者，并和新的领导者一起继续提供服务。随后，如果之前的领导者恢复正常，便成为一个跟随者。领导者选举的过程是非常快的，大约200毫米，因此在选举的过程中不会出现明显的性能降低。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>在更新内存中znode树之前，集合体中的所有机器都会先将更新写入磁盘。<span style="color:rgb(255,0,0);">任何一台机器都可以为读请求提供服务，并且由于读请求只涉及内存检索</span><span style="color:rgb(255,0,0);">，因此非常快</span>。</p>
<p><br></p>
<p><strong>4.一致性</strong></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>ZooKeeper服务提供的一致性保证。跟随者可能滞后于领导着几个更新。一个修改被提交之前，只需要集合体中半数以上而非全部机器已经将其持久化。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">每一个对znode树的更新都被赋予一个全局唯一的ID，称为zxid（代表ZooKeeper Transaction ID）。ZooKeeper决定了分布式系统中的顺序，它对所有的更新进行排序</span>，如果zxid z1小于z2，则z1一定发生在z2之前。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>保证数据一致性的几点考虑：</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>顺序一致性：<span style="color:rgb(255,0,0);">来自任意特定客户端的更新都会按其发送顺序被提交</span>。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>原子性：每个更新要么成功，要么失败。<span style="color:rgb(255,0,0);">失败的更新不会有客户端看到</span>。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>单一系统影像：<span style="color:rgb(255,0,0);">一个客户端无论连接到哪一台服务器，它看到的都是同一的系统视图</span>。当一台服务器出现故障，客户端会在同一个会话中尝试连接到一台新的服务器，而所有滞后于故障服务器的服务器都会接收该连接请求，除非这些服务器赶上故障服务器。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>持久性：一个更新一旦成功，其结果就会持久存在不会被撤销，不受服务器故障影响。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>及时性：任何客户端所看到的系统视图的滞后都是有限的，不会超过几十秒。如果一个服务器数据很陈旧就会关闭，并强迫客户端连接到新的服务器。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>出于性能的原因，<span style="color:rgb(255,0,0);">所有的读操作都是从ZooKeeper服务器的内存获得数据</span>，它们不参与写操作的全局排序。</p>
<p><br></p>
<p><strong>5.会话</strong></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span><span style="color:rgb(255,0,0);">每个zookeeper客户端的配置中都包括集合体中服务器的列表</span>。客户端启动时会尝试连接直到成功连接可用为止。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>客户端与zookeeper服务器建立连接会创建一个新的会话，每个会话都有超时设置。会话过期短暂znode会丢失。客户端通过ping请求（心跳）保持会话不过期，zookeeper客户端库自动发送。超时时长设置要足够低，以便能够检测出服务器故障，并且能够在会话超时的时间段内重新连接到另外一台服务器。<span style="color:rgb(255,0,0);">zookeeper客户端可以自动进行故障切换，并且所有的会话仍然有效（短暂znode）</span>。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>在zookeeper中“滴答”（tick time）参数定义了基本时间周期，其他参数都根据该参数来定义。通常滴答参数设置为2秒，对应于允许的超时范围是4到40秒。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>较短的超时设置会更快的检测到机器故障，但避免设的太低，因为繁忙的网络会导致数据包传输延迟，从而可能导致会话过期。这种情况下机器可能会出现<span style="color:rgb(255,0,0);">“振动”（flap）现象：在很短的时间内反复离开而后重新加入组。</span></p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>有些应用状态使用短暂znode并创建较复杂，即重建代价较大，因此可以将超时设置长些，使其在出现故障时能在会话超时之前重启，避免出现会话过期。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>服务器会为每个会话分配一个唯一的ID和密码，可以将其存储起来，只要会话未过期，即可利用它恢复一个会话。</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>一般规则是，zookeeper集合体中的服务器越多，会话超时的设置应越大。连接超时、读超时和 ping周期都被定义为集合体中服务器数量的函数，因此集合体中服务器的数量越多，这些参数的值反而越小。如果频繁遇到连接丢失情况，应考虑增大超时的设置。</p>
<p><br></p>
<p>6.状态</p>
<p><span class="Apple-tab-span" style="white-space:pre;"></span>zookeeper对象在生命周期中会经历：connecting、connected和close三种不同状态，可以通过getState方法来查询。</p>
