#三个概念
**1.CreateMode**

在create的时候可以设置znode的类型，主要有四种：

	PERSISTENT (持续的，相对于EPHEMERAL，不会随着client的断开而消失)
	PERSISTENT_SEQUENTIAL（持久的且带顺序的）
	EPHEMERAL (短暂的，生命周期依赖于client session)
	EPHEMERAL_SEQUENTIAL  (短暂的，带顺序的)
 
**2.Watcher**

Watcher是一种反向推送机制，即zonde（包括他的child）有改变的时候会通知客户端。

可以自定义Watcher，注册给zonde。

watcher分为两大类：data watches和child watches。前者监听数据的变动，后者监听子node的变动。

Watcher是一次性的！一旦被调用，则需要重新注册。
 
**3.ACL**

acl即access control。zookeeper通过ACL机制来控制权限。创建znode的时候可以指定。前边我们讲过，一套zookeeper会被多个程序使用。就像linux支持多用户一样。所以需要有一套权限控制：不然自己创建的节点，被别的应用程序无缘无故删了，那找谁去？
 
Zookeeper的权限级别：

	READ: 允许获取该节点的值和列出子节点。
	WRITE: 允许设置该节点的值。
	CREATE: 允许创建子节点。
	DELETE: 可以删除子节点。
	ADMIN: 超级权限。相当于root
从上到下递次增强，后面的权限包含前面的权限。
 
 
zookeeper的很多高级特性，都是基于以上三个概念来实现的。特别是CreateMode和Watcher
 
#java客户端
zookeeper官方提供了java客户端。提供的接口也比较基础。比前一篇测试用到的telnet客户端唯一强的一点就是：我们可以在代码里实现Watcher接口实现扩展的业务，在命令行可是做不到这点的。。
maven依赖：

	<dependency>  
	    <groupId>org.apache.zookeeper</groupId>  
	    <artifactId>zookeeper</artifactId>  
	    <version>3.4.6</version>  
	</dependency>  

#一些高级特性实现原理
1.Name Service：有点类似JNDI，树形目录天生的就有全局唯一名称。这功能实践中也没什么用，而且替代方案也很多

2.配置推送：比如某个前端网站有100台机器，我们要做的是在每台机器上都有一个main程序连zookeeper，注册好Watcher。在本地连zookeeper把配置写入，zookeeper就会通过Watcher，自动把配置推送到这些机器上。而不需要去手动去更新。（相当于运维的脚本。）

![image](http://dl2.iteye.com/upload/attachment/0099/3498/604df069-cb9f-37ec-88b0-5b3b98bffd41.jpg)

3.集群管理：

每个Server起来之后都在 Zookeeper 上创建一个 EPHEMERAL 类型的znode，假设他们都有一个共同的父GroupMembers！我们在每个Server上调用getChildren(GroupMembers)方法，并注册一个 Child Watcher。由于是 EPHEMERAL 的znode，当创建它的 Server 死去，这个znode也随之被删除，所以 Children 将会变化，这时 getChildren上的 Watcher 将会被调用，所以其它 Server 就知道已经有某台Server死去了。新增Server也是同样的原理。
 
4.Leader选举

和集群管理的设计基本一样，不同的地方是，这次创建的znone类型是EPHEMERAL_SEQUENTIAL ，不仅仅随着member的同生同灭，而且是有顺序的。我们只要把编号最小的member认为是Master，就可以做到Leader的动态选举.
![](http://dl2.iteye.com/upload/attachment/0099/3503/f113836d-3916-3d8c-a4d8-5bf3a27bf4dd.jpg)

5.全局锁

zookeeper可以利用他优秀的数据一致性算法来提供可靠的全局锁服务。
获得锁是一个递归的过程

1.创建znode "/distributed_lock"

2.在distributed_lock下新建子节点"/distributed_lock/xxxxxx"，EPHEMERAL_SEQUENTIAL 模式，当前序号假如是i。

3.对distributed_lock调用getChildren()，如果i是children列表里最小的，则获得锁；否则进入第4步

4.等待children列表里紧跟在i后边的那个节点被删除的通知（exists()方法）。记为j。而j又依赖于仅比j小的节点k。一直递归等待最小的znode的被删除。。
 
注：虽然EPHEMERAL_SEQUENTIAL是递增的，但仍然不能粗暴的认为紧跟在i后边的节点j=i-1。这是因为释放锁的顺序并不是完全按照节点顺序！
 
释放锁：
删除自己创建的子节点即可
 
6.分布式队列

类似于上边全局锁的设计。只要确保每次消费的时候编号都是最小的。就能做到先进先出。
 
7.根据zookeeper创建节点类型的不同，再结合Watcher特性。还可以提供其他很多的功能。比如各种类型queue，各种类型的Lock（上面仅仅介绍了write锁），barriers，信号量Semaphore  原子类型AtomicInteger等等。。。

所有的这些都是分布式的，高可靠的。
 
更多更全的功能在netflix 公司开源的 zookeeper客户端Curator中有实现。作为普通开发者，直接使用Curator是最高效的！