Curator框架是最好用，最流行的zookeeper的客户端。

它有以下三个优点

1. 提供了一套非常友好的操作API
2. 提供一些高级特性（包括但不仅限于前篇文章中提到的）的封装
3. 易测试

maven依赖:

	<dependency>  
		<groupId>org.apache.curator</groupId>  
		<artifactId>curator-recipes</artifactId>  
		<version>2.5.0</version>  
	</dependency>  
按照官方给出的文档和包结构，Curator功能分两大类，一是对zookeeper的一些基本命令的封装，比如增删改查。是他的framework模块，一个是他的高级特性，即recipes模块。

#framework模块
Curator提供了一套Fluent风格的操作API。这在很多脚本类语言里比较流行。

创建client的代码:

	CuratorFramework client = CuratorFrameworkFactory.builder().connectString("192.168.11.56:2180")  
        .sessionTimeoutMs(30000)  
        .connectionTimeoutMs(30000)  
        .canBeReadOnly(false)  
        .retryPolicy(new ExponentialBackoffRetry(1000, Integer.MAX_VALUE))  
        .namespace(namespace)  
        .defaultData(null)  
        .build();  
	client.start();  
一路点到底，这就是所谓的Fluent风格

增删改查:

	public class CrudExamples {  
    private static CuratorFramework client = ClientFactory.newClient();  
    private static final String PATH = "/crud";  
  
    public static void main(String[] args) {  
        try {  
            client.start();  
  
            client.create().forPath(PATH, "I love messi".getBytes());  
  
            byte[] bs = client.getData().forPath(PATH);  
            System.out.println("新建的节点，data为:" + new String(bs));  
  
            client.setData().forPath(PATH, "I love football".getBytes());  
  
            // 由于是在background模式下获取的data，此时的bs可能为null  
            byte[] bs2 = client.getData().watched().inBackground().forPath(PATH);  
            System.out.println("修改后的data为" + new String(bs2 != null ? bs2 : new byte[0]));  
  
            client.delete().forPath(PATH);  
            Stat stat = client.checkExists().forPath(PATH);  
  
            // Stat就是对zonde所有属性的一个映射， stat=null表示节点不存在！  
            System.out.println(stat);  
        } catch (Exception e) {  
            e.printStackTrace();  
        } finally {  
            CloseableUtils.closeQuietly(client);  
        }  
    }  
	} 
常用接口有
	create()增
	delete(): 删
	checkExists(): 判断是否存在
	setData():  改
	getData(): 查
所有这些方法都以forpath()结尾，辅以watch(监听)，withMode（指定模式），和inBackground（后台运行）等方法来使用。 

 此外，Curator还支持事务，一组crud操作同生同灭:

	/** 
	 * 事务操作 
	 */  
	public class TransactionExamples {  
    private static CuratorFramework client = ClientFactory.newClient();  
  
    public static void main(String[] args) {  
        try {  
            client.start();  
            // 开启事务  
            CuratorTransaction transaction = client.inTransaction();  
  
            Collection<CuratorTransactionResult> results = transaction.create()  
                    .forPath("/a/path", "some data".getBytes()).and().setData()  
                    .forPath("/another/path", "other data".getBytes()).and().delete().forPath("/yet/another/path")  
                    .and().commit();  
  
            for (CuratorTransactionResult result : results) {  
                System.out.println(result.getForPath() + " - " + result.getType());  
            }  
        } catch (Exception e) {  
            e.printStackTrace();  
        } finally {  
            // 释放客户端连接  
            CloseableUtils.closeQuietly(client);  
        }  
  
    }  
	}  

这段的代码的运行结果，由于最后一步delete的节点不存在，所以整个事务commit失败。失败的原因会放在Collection<CuratorTransactionResult>中，非常友好。

#Recipes模块
Recipes部分提供的功能[官网](http://curator.apache.org/curator-recipes/index.html)列的很详细。注意文章第一段：Curator宣称，Recipes模块实现了除二阶段提交之外的所有zookeeper特性.

主要有:

Elections(选举)，Locks（锁），Barriers（关卡），Atomic（原子量），Caches，Queues等

1. Elections: 选举主要依赖于LeaderSelector和LeaderLatch2个类。前者是所有存活的客户端不间断的轮流做Leader，大同社会。后者是一旦选举出Leader，除非有客户端挂掉重新触发选举，否则不会交出领导权。

LeaderSelector示例：

		
	import java.io.Closeable;
	import java.io.IOException;
	import java.util.concurrent.TimeUnit;
	
	import org.apache.curator.framework.CuratorFramework;
	import org.apache.curator.framework.recipes.leader.LeaderSelector;
	import org.apache.curator.framework.recipes.leader.LeaderSelectorListenerAdapter;
	
	/**
	 * 本类基于leaderSelector实现,所有存活的client会公平的轮流做leader
	 * 如果不想频繁的变化Leader，需要在takeLeadership方法里阻塞leader的变更！ 或者使用 {@link}
	 * LeaderLatchClient
	 */
	public class LeaderSelectorClient extends LeaderSelectorListenerAdapter implements Closeable {
		private final String name;
		private final LeaderSelector leaderSelector;
		private final String PATH = "/leaderselector";
	
		public LeaderSelectorClient(CuratorFramework client, String name) {
			this.name = name;
			leaderSelector = new LeaderSelector(client, PATH, this);
			leaderSelector.autoRequeue();
		}
	
		public void start() throws IOException {
			leaderSelector.start();
		}
	
		@Override
		public void close() throws IOException {
			leaderSelector.close();
		}
	
		public boolean isLeader() {
			return leaderSelector.hasLeadership();
		}
	
		public void release() {
			leaderSelector.interruptLeadership();
		}
	
		public void take() {
			leaderSelector.requeue();
		}
	
		/**
		 * client成为leader后，会调用此方法
		 */
		@Override
		public void takeLeadership(CuratorFramework client) throws Exception {
	
			int waitSeconds = (int) (5 * Math.random()) + 1;
			System.out.println(name + "是当前的leader");
			try {
				Thread.sleep(TimeUnit.SECONDS.toMillis(waitSeconds));
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			} finally {
				System.out.println(name + " 让出领导权\n");
			}
		}
	}

		
	/**
	 * leader选举
	 */
	public class LeaderSelectorExample {
	
		public static void main(String[] args) {
			List<CuratorFramework> clients = Lists.newArrayList();
			List<LeaderSelectorClient> examples = Lists.newArrayList();
			try {
				for (int i = 0; i < 10; i++) {
					CuratorFramework client = ClientFactory.newClient();
					LeaderSelectorClient example = new LeaderSelectorClient(client, "Client #" + i);
					clients.add(client);
					examples.add(example);
	
					client.start();
					example.start();
				}
	
				Thread.sleep(10000);
	
				System.out.println("----------关闭前5个客户端，再观察选举leader的结果-----------");
				for (int i = 0; i < 5; i++) {
					clients.get(i).close();
				}
	
				// 这里有个小技巧，让main程序一直监听控制台输入，异步的代码就可以一直在执行。不同于while(ture)的是，按回车或esc可退出
				new BufferedReader(new InputStreamReader(System.in)).readLine();
	
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				for (LeaderSelectorClient exampleClient : examples) {
					CloseableUtils.closeQuietly(exampleClient);
				}
				for (CuratorFramework client : clients) {
					CloseableUtils.closeQuietly(client);
				}
			}
		}
	}	

	
		
	import java.io.Closeable;
	import java.io.IOException;
	import java.util.concurrent.Executor;
	import java.util.concurrent.Executors;
	
	import org.apache.curator.framework.CuratorFramework;
	import org.apache.curator.framework.recipes.leader.LeaderLatch;
	import org.apache.curator.framework.recipes.leader.LeaderLatchListener;
	
	/**
	 * leader选举
	 */
	public class LeaderLatchClient implements Closeable {
		private final LeaderLatch leaderLatch;
		private final String PATH = "/leaderlatch";
		private static Executor executor = Executors.newCachedThreadPool();
	
		public LeaderLatchClient(CuratorFramework client, final String name) {
			leaderLatch = new LeaderLatch(client, PATH);
	
			LeaderLatchListener latchListener = new LeaderLatchListener() {
				@Override
				public void isLeader() {
					System.out.println("I am leader, my name is " + name);
				}
	
				@Override
				public void notLeader() {
					System.out.println("I release my leader ship, my name is " + name);
				}
			};
	
			// 可以添加多个Listener，告知外界
			leaderLatch.addListener(latchListener, executor);
		}
	
		public void start() throws Exception {
			leaderLatch.start();
		}
	
		@Override
		public void close() throws IOException {
			leaderLatch.close();
		}
	
		public boolean isLeader() {
			return leaderLatch.hasLeadership();
		}
	}

		
	import java.io.BufferedReader;
	import java.io.InputStreamReader;
	import java.util.List;
	
	import org.apache.curator.framework.CuratorFramework;
	import org.apache.curator.utils.CloseableUtils;
	
	import com.bj58.emc.study.curator.demo.utils.ClientFactory;
	import com.google.common.collect.Lists;
	
	public class LeaderLatchExample {
		public static void main(String[] args) {
	
			List<CuratorFramework> clients = Lists.newArrayList();
			List<LeaderLatchClient> examples = Lists.newArrayList();
			try {
				for (int i = 0; i < 10; i++) {
					CuratorFramework client = ClientFactory.newClient();
					LeaderLatchClient example = new LeaderLatchClient(client, "Client #" + i);
					clients.add(client);
					examples.add(example);
	
					client.start();
					example.start();
				}
	
				Thread.sleep(10000);
	
				System.out.println("----------关闭前5个客户端，再观察选举leader的结果-----------");
				for (int i = 0; i < 5; i++) {
					clients.get(i).close();
				}
	
				// 让main程序一直监听控制台输入，不退出
				new BufferedReader(new InputStreamReader(System.in)).readLine();
	
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				for (LeaderLatchClient exampleClient : examples) {
					CloseableUtils.closeQuietly(exampleClient);
				}
				for (CuratorFramework client : clients) {
					CloseableUtils.closeQuietly(client);
				}
			}
		}
	}


2. locks: curator lock相关的实现在recipes.locks包里。顶级接口都是InterProcessLock。我们直接看最有代表性的InterProcessReadWriteLock 进程内部读写锁（可重入读写锁）。什么叫[可重入](http://ifeve.com/java_lock_see4/)，什么叫读写锁，[参考](http://www.cnblogs.com/hzhuxin/archive/2012/11/01/2749341.html)。总之读写锁一定是成对出现的.

先定义两个任务，可并行的执行的，和互斥执行的:

	//并行任务
	public class ParallelJob implements Runnable {  
	    private final String name;  
	    private final InterProcessLock lock;  
	    // 锁等待时间  
	    private final int wait_time = 5;  
	    ParallelJob(String name, InterProcessLock lock) {  
	        this.name = name;  
	        this.lock = lock;  
	    }  
	  
	    @Override  
	    public void run() {  
	        try {  
	            doWork();  
	        } catch (Exception e) {  
	            // ingore;  
	        }  
	    }  
	  
	    public void doWork() throws Exception {  
	        try {  
	            if (!lock.acquire(wait_time, TimeUnit.SECONDS)) {  
	                System.err.println(name + "等待" + wait_time + "秒，仍未能获取到lock,准备放弃。");  
	            }  
	            // 模拟job执行时间0-4000毫秒  
	            int exeTime = new Random().nextInt(4000);  
	            System.out.println(name + "开始执行,预计执行时间= " + exeTime + "毫秒----------");  
	            Thread.sleep(exeTime);  
	        } catch (Exception e) {  
	            e.printStackTrace();  
	        } finally {  
	            lock.release();  
	        }  
	    }  
	}  
	
	/** 
	 * 互斥任务 
	 */  
	public class MutexJob implements Runnable {  	  
	    private final String name;  	  
	    private final InterProcessLock lock;	  
	    // 锁等待时间  
	    private final int wait_time = 10;  	  
	    MutexJob(String name, InterProcessLock lock) {  
	        this.name = name;  
	        this.lock = lock;  
	    }  
	  
	    @Override  
	    public void run() {  
	        try {  
	            doWork();  
	        } catch (Exception e) {  
	            // ingore;  
	        }  
	    }  
	  
	    public void doWork() throws Exception {  
	        try {  
	            if (!lock.acquire(wait_time, TimeUnit.SECONDS)) {  
	                System.err.println(name + "等待" + wait_time + "秒，仍未能获取到lock,准备放弃。");  
	            }  
	            // 模拟job执行时间0-2000毫秒  
	            int exeTime = new Random().nextInt(2000);  
	            System.out.println(name + "开始执行,预计执行时间= " + exeTime + "毫秒----------");  
	            Thread.sleep(exeTime);  
	        } catch (Exception e) {  
	            e.printStackTrace();  
	        } finally {  
	            lock.release();  
	        }  
	    }  
	}  

	/** 
	 * 分布式锁实例 
	 */  
	public class DistributedLockExample {  
	    private static CuratorFramework client = ClientFactory.newClient();  
	    private static final String PATH = "/locks";  
	  
	    // 进程内部（可重入）读写锁  
	    private static final InterProcessReadWriteLock lock;  
	    // 读锁  
	    private static final InterProcessLock readLock;  
	    // 写锁  
	    private static final InterProcessLock writeLock;  
	  
	    static {  
	        client.start();  
	        lock = new InterProcessReadWriteLock(client, PATH);  
	        readLock = lock.readLock();  
	        writeLock = lock.writeLock();  
	    }  
	  
	    public static void main(String[] args) {  
	        try {  
	            List<Thread> jobs = Lists.newArrayList();  
	            for (int i = 0; i < 10; i++) {  
	                Thread t = new Thread(new ParallelJob("Parallel任务" + i, readLock));  
	                jobs.add(t);  
	            }  
	  
	            for (int i = 0; i < 10; i++) {  
	                Thread t = new Thread(new MutexJob("Mutex任务" + i, writeLock));  
	                jobs.add(t);  
	            }  
	  
	            for (Thread t : jobs) {  
	                t.start();  
	            }  
	        } catch (Exception e) {  
	            e.printStackTrace();  
	        } finally {  
	            CloseableUtils.closeQuietly(client);  
	        }  
	    }  
	}  
用法和java concurrent包里的ReentrantReadWriteLock 是一模一样的。

事实上，整个recipes包的目录结构、实现原理同java concurrent包的设置是很一致的。比如有queue，Semaphore，Barrier等类，。他整个就是模仿jdk的实现，只不过是基于分布式的！

Barriers（关卡），Atomic（原子量），Caches，Queues和java concurrent包里的类的用法是一样的

要说明的是：有的功能性能不是特别理想，网上也没见有大的项目的使用案例。比如基于CAS机制的atomic，在某些情况重试的效率还不如硬同步，要是zookeeper节点再一多，各个节点之间通过event触发的数据同步极其频繁。那性能可以想象。

#测试方法

curator提供了很好的测试工具，你甚至是可以在完全没有搭建zookeeper server端的情况下，完成测试。
有2个重要的类TestingServer 模拟单点， TestingCluster模拟集群。

maven依赖:

	<dependency>  
	    <groupId>org.apache.curator</groupId>  
	    <artifactId>curator-test</artifactId>  
	    <version>2.5.0</version>  
	</dependency>  