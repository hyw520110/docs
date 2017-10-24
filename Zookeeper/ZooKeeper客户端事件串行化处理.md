<p>为了提升系统的性能，进一步提高系统的吞吐能力，最近公司很多系统都在进行异步化改造。在异步化改造的过程中，肯定会比以前碰到更多的多线程问题，上周就碰到ZooKeeper客户端异步化过程中的一个死锁问题，这里说明下。</p>
<p>通常ZooKeeper对于同一个API，提供了同步和异步两种调用方式。<br>同步接口很容易理解，使用方法如下：</p>
<pre class="brush:java;toolbar:false;">ZooKeeper zk = new ZooKeeper(...);
List children = zk.getChildren( path, true );</pre>
<p>异步接口就相对复杂一点，使用方法如下：</p>
<pre class="brush:java;toolbar:false;">ZooKeeper zk = new ZooKeeper(...);
zk.getChildren( path, true, new AsyncCallback.Children2Callback() {
@Override
public void processResult( int rc, String path, Object ctx, List children, Stat stat ) {
System.out.println( "Recive the response." );
}
}, null);</pre>
<p>我们可以看到，异步调用中，需要注册一个Children2Callback，并实现回调方法：processResult。</p>
<p>上周碰到这样的问题：应用注册了对某znode子节点列表变化的监听，逻辑是在接受到ZooKeeper服务器节点列表变更通知（EventType.NodeChildrenChanged）的时候，会重新获取一次子节点列表。之前，他们是使用同步接口，整个应用可以正常运行，但是这次异步化改造后，出现了诡异现象，能够收到子节点的变更通知，但是无法重新获取子节点列表了。</p>
<p>下面，我首先把应用之前使用同步接口的逻辑代码，用一个简单的demo来演示下，如下：</p>
<pre class="brush:java;toolbar:false;">package book.chapter05;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.ZooKeeper;
import org.apache.zookeeper.Watcher.Event.KeeperState;
/**
* ZooKeeper API 获取子节点列表，使用同步(sync)接口。
* @author &lt;a href="mailto:nileader@gmail.com"&gt;银时&lt;/a&gt;
*/
public class ZooKeeper_GetChildren_API_Sync_Usage implements Watcher {
private CountDownLatch connectedSemaphore = new CountDownLatch( 1 );
private static CountDownLatch _semaphore = new CountDownLatch( 1 );
private ZooKeeper zk;
ZooKeeper createSession( String connectString, int sessionTimeout, Watcher watcher ) throws IOException {
ZooKeeper zookeeper = new ZooKeeper( connectString, sessionTimeout, watcher );
try {
connectedSemaphore.await();
} catch ( InterruptedException e ) {
}
return zookeeper;
}
/** create path by sync */
void createPath_sync( String path, String data, CreateMode createMode ) throws IOException, KeeperException, InterruptedException {
if ( zk == null ) {
zk = this.createSession( "domain1.book.zookeeper:2181", 5000, this );
}
zk.create( path, data.getBytes(), Ids.OPEN_ACL_UNSAFE, createMode );
}
/** Get children znodes of path and set watches */
List getChildren( String path ) throws KeeperException, InterruptedException, IOException{
System.out.println( "===Start to get children znodes.===" );
if ( zk == null ) {
zk = this.createSession( "domain1.book.zookeeper:2181", 5000, this );
}
return zk.getChildren( path, true );
}
public static void main( String[] args ) throws IOException, InterruptedException {
ZooKeeper_GetChildren_API_Sync_Usage sample = new ZooKeeper_GetChildren_API_Sync_Usage();
String path = "/get_children_test";
try {
sample.createPath_sync( path, "", CreateMode.PERSISTENT );
sample.createPath_sync( path + "/c1", "", CreateMode.PERSISTENT );
List childrenList = sample.getChildren( path );
System.out.println( childrenList );
//Add a new child znode to test watches event notify.
sample.createPath_sync( path + "/c2", "", CreateMode.PERSISTENT );
_semaphore.await();
} catch ( KeeperException e ) {
System.err.println( "error: " + e.getMessage() );
e.printStackTrace();
}
}
/**
* Process when receive watched event
*/
@Override
public void process( WatchedEvent event ) {
System.out.println( "Receive watched event：" + event );
if ( KeeperState.SyncConnected == event.getState() ) {
if( EventType.None == event.getType() &amp;amp;&amp;amp; null == event.getPath() ){
connectedSemaphore.countDown();
}else if( event.getType() == EventType.NodeChildrenChanged ){
//children list changed
try {
System.out.println( this.getChildren( event.getPath() ) );
_semaphore.countDown();
} catch ( Exception e ) {}
}
}
}
}</pre>
<p>输出结果如下：</p>
<pre class="brush:java;toolbar:false;">Receive watched event：WatchedEvent state:SyncConnected type:None path:null
===Start to get children znodes.===
[c1]
Receive watched event：WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/get_children_test
===Start to get children znodes.===
[c1, c2]</pre>
<p>在上面这个程序中，我们首先创建了一个父节点:/get_children_test，以及一个子节点：/get_children_test/c1。然后调用getChildren的同步接口来获取/get_children_test节点下的所有子节点，调用的同时注册一个watches。之后，我们继续向/get_children_test节点创建子节点：/get_children_test/c2，这个时候，因为我们之前我们注册了一个watches，因此，一旦此时有子节点被创建，ZooKeeperServer就会向客户端发出“子节点变更”的通知，于是，客户端可以再次调用getChildren方法来获取新的子节点列表。</p>
<p>这个例子当然是能够正常运行的。现在，我们进行异步化改造，如下：</p>
<pre class="brush:java;toolbar:false;">package book.chapter05;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import org.apache.zookeeper.AsyncCallback;
import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.Watcher.Event.EventType;
import org.apache.zookeeper.ZooDefs.Ids;
import org.apache.zookeeper.data.Stat;
import org.apache.zookeeper.ZooKeeper;
import org.apache.zookeeper.Watcher.Event.KeeperState;
/**
* ZooKeeper API 获取子节点列表，使用异步(ASync)接口。
* @author &lt;a href="mailto:nileader@gmail.com"&gt;银时&lt;/a&gt;
*/
public class ZooKeeper_GetChildren_API_ASync_Usage_Deadlock implements Watcher {
private CountDownLatch connectedSemaphore = new CountDownLatch( 1 );
private static CountDownLatch _semaphore = new CountDownLatch( 1 );
private ZooKeeper zk;
ZooKeeper createSession( String connectString, int sessionTimeout, Watcher watcher ) throws IOException {
ZooKeeper zookeeper = new ZooKeeper( connectString, sessionTimeout, watcher );
try {
connectedSemaphore.await();
} catch ( InterruptedException e ) {
}
return zookeeper;
}
/** create path by sync */
void createPath_sync( String path, String data, CreateMode createMode ) throws IOException, KeeperException, InterruptedException {
if ( zk == null ) {
zk = this.createSession( "domain1.book.zookeeper:2181", 5000, this );
}
zk.create( path, data.getBytes(), Ids.OPEN_ACL_UNSAFE, createMode );
}
/** Get children znodes of path and set watches */
void getChildren( String path ) throws KeeperException, InterruptedException, IOException{
System.out.println( "===Start to get children znodes.===" );
if ( zk == null ) {
zk = this.createSession( "domain1.book.zookeeper:2181", 5000, this );
}
final CountDownLatch _semaphore_get_children = new CountDownLatch( 1 );
zk.getChildren( path, true, new AsyncCallback.Children2Callback() {
@Override
public void processResult( int rc, String path, Object ctx, List children, Stat stat ) {
System.out.println( "Get Children znode result: [response code: " + rc + ", param path: " + path + ", ctx: " + ctx + ", children list: "
+ children + ", stat: " + stat );
_semaphore_get_children.countDown();
}
}, null);
_semaphore_get_children.await();
}
public static void main( String[] args ) throws IOException, InterruptedException {
ZooKeeper_GetChildren_API_ASync_Usage_Deadlock sample = new ZooKeeper_GetChildren_API_ASync_Usage_Deadlock();
String path = "/get_children_test";
try {
sample.createPath_sync( path, "", CreateMode.PERSISTENT );
sample.createPath_sync( path + "/c1", "", CreateMode.PERSISTENT );
//Get children and register watches.
sample.getChildren( path );
//Add a new child znode to test watches event notify.
sample.createPath_sync( path + "/c2", "", CreateMode.PERSISTENT );
_semaphore.await();
} catch ( KeeperException e ) {
System.err.println( "error: " + e.getMessage() );
e.printStackTrace();
}
}
/**
* Process when receive watched event
*/
@Override
public void process( WatchedEvent event ) {
System.out.println( "Receive watched event：" + event );
if ( KeeperState.SyncConnected == event.getState() ) {
if( EventType.None == event.getType() &amp;amp;&amp;amp; null == event.getPath() ){
connectedSemaphore.countDown();
}else if( event.getType() == EventType.NodeChildrenChanged ){
//children list changed
try {
this.getChildren( event.getPath() );
_semaphore.countDown();
} catch ( Exception e ) {
e.printStackTrace();
}
}
}
}
}</pre>
<p>输出结果如下：</p>
<pre class="brush:java;toolbar:false;">Receive watched event：WatchedEvent state:SyncConnected type:None path:null
===Start to get children znodes.===
Get Children znode result: [response code: 0, param path: /get_children_test, ctx: null, children list: [c1], stat: 555,555,1373931727380,1373931727380,0,1,0,0,0,1,556
Receive watched event：WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/get_children_test
===Start to get children znodes.===</pre>
<p>在上面这个demo中，执行逻辑和之前的同步版本基本一致，唯一有区别的地方在于获取子节点列表的过程异步化了。这样一改造，问题就出来了，整个程序在进行第二次获取节点列表的时候，卡住了。和应用方确认了，之前同步版本从来没有出现过这个现象的，所以开始排查这个异步化中哪里会阻塞。</p>
<p>这里，我们重点讲解在ZooKeeper客户端中，需要处理来自服务端的两类事件通知：一类是Watches时间通知，另一类则是异步接口调用的响应。值得一提的是，在ZooKeeper的客户端线程模型中，这两个事件由同一个线程处理，并且是串行处理。具体可以自己查看事件处理的核心类：org.apache.zookeeper.ClientCnxn.EventThread。</p>
<p></p>
