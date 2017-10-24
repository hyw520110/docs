<p>ZooKeeper构建配置服务</p>
<p>&nbsp;*&nbsp;配置服务是分布式应用所需要的基本服务之一，它使集群中的机器可以共享配置信息中那些公共的部分。</p>
<p>&nbsp;*&nbsp;简单的说，ZooKeeper可以作为一个具有高可用性的配置存储器，允许分布式应用的参与者检索和更新配置文件。</p>
<p>&nbsp;*&nbsp;使用ZooKeeper中的观察机制，可以建立一个活跃的配置服务，使那些感兴趣的客户端能够获得配置信息修改的通知。</p>
<p>在每个znode上存储一个键值对，ActiveKeyValueStore 提供了从zookeeper服务上写和读取键值方法。</p>
<pre class="brush:java;toolbar:false">public&nbsp;class&nbsp;ActiveKeyValueStore&nbsp;extends&nbsp;ConnectionWatcher{

	private&nbsp;static&nbsp;final&nbsp;Charset&nbsp;CHARSET&nbsp;=Charset.forName("GBk");
	private&nbsp;static&nbsp;final&nbsp;int&nbsp;MAX_RETRIES&nbsp;=&nbsp;5;
	private&nbsp;static&nbsp;final&nbsp;long&nbsp;RETRY_PERIOD_SECONDS&nbsp;=&nbsp;60;
	
	public&nbsp;void&nbsp;write(String&nbsp;path,&nbsp;String&nbsp;value)&nbsp;throws&nbsp;Exception{
		int&nbsp;retries&nbsp;=&nbsp;0;
		while(true){
			try&nbsp;{
				Stat&nbsp;stat&nbsp;=&nbsp;zk.exists(path,&nbsp;false);
				if(stat&nbsp;==&nbsp;null){
					zk.create(path,&nbsp;value.getBytes(CHARSET),&nbsp;Ids.OPEN_ACL_UNSAFE,&nbsp;CreateMode.PERSISTENT);
				}else{
					zk.setData(path,&nbsp;value.getBytes(CHARSET),&nbsp;-1);
				}
			}&nbsp;catch&nbsp;(KeeperException.SessionExpiredException&nbsp;e)&nbsp;{
				throw&nbsp;e;
			}catch(KeeperException&nbsp;e){
				if(retries++&nbsp;==&nbsp;MAX_RETRIES){
					throw&nbsp;e;
				}
				TimeUnit.SECONDS.sleep(RETRY_PERIOD_SECONDS);
			}
		}
	}
	
	public&nbsp;String&nbsp;read(String&nbsp;path,&nbsp;Watcher&nbsp;watcher)&nbsp;throws&nbsp;Exception{
		byte[]&nbsp;data&nbsp;&nbsp;=&nbsp;zk.getData(path,&nbsp;watcher,&nbsp;null);
		return&nbsp;new&nbsp;String(data,&nbsp;CHARSET);
	}
}</pre>
<p>与zookeeper服务创建连接</p>
<pre class="brush:java;toolbar:false">public&nbsp;class&nbsp;ConnectionWatcher&nbsp;implements&nbsp;Watcher{

	private&nbsp;static&nbsp;final&nbsp;int&nbsp;SESSION_TIMEOUT&nbsp;=&nbsp;5000;
	protected&nbsp;ZooKeeper&nbsp;zk;
	private&nbsp;CountDownLatch&nbsp;connectedSignal&nbsp;=&nbsp;new&nbsp;CountDownLatch(1);
	
	public&nbsp;void&nbsp;connect(String&nbsp;hosts)&nbsp;throws&nbsp;Exception{
		//创建zookeeper实例的时候会启动一个线程连接到zookeeper服务。
		zk&nbsp;=&nbsp;new&nbsp;ZooKeeper(hosts,&nbsp;SESSION_TIMEOUT,&nbsp;this);
		connectedSignal.await();
	}

	//当客户端已经与zookeeper建立连接后，Watcher的process方法会被调用。
	public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{
		if(event.getState()&nbsp;==&nbsp;KeeperState.SyncConnected){
			connectedSignal.countDown();
		}
	}

	public&nbsp;void&nbsp;close()&nbsp;throws&nbsp;Exception{
		zk.close();
	}
}</pre>
<p>ResilientConfigUpdater类提供了管理更新配置信息方法。</p>
<pre class="brush:java;toolbar:false">public&nbsp;class&nbsp;ResilientConfigUpdater&nbsp;{
	
	public&nbsp;static&nbsp;final&nbsp;String&nbsp;PATH&nbsp;=&nbsp;"/config";
	
	private&nbsp;ActiveKeyValueStore&nbsp;store;
	private&nbsp;Random&nbsp;random&nbsp;=&nbsp;new&nbsp;Random();
	
	public&nbsp;ResilientConfigUpdater(String&nbsp;hosts)&nbsp;throws&nbsp;Exception{
		store&nbsp;=&nbsp;new&nbsp;ActiveKeyValueStore();
		store.connect(hosts);
	}
	
	public&nbsp;void&nbsp;run()&nbsp;throws&nbsp;Exception{
		while(true){
			String&nbsp;value&nbsp;=&nbsp;random.nextInt(100)+"";
			store.write(PATH,&nbsp;value);
			
			System.out.printf("Set&nbsp;%s&nbsp;to&nbsp;%s\n",&nbsp;PATH,&nbsp;value);
			TimeUnit.SECONDS.sleep(random.nextInt(10));
		}
	}
	public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;throws&nbsp;Exception&nbsp;{
		while(true){
			try{
				ResilientConfigUpdater&nbsp;updater&nbsp;=&nbsp;new&nbsp;ResilientConfigUpdater("192.168.44.231");
				updater.run();
			}catch(KeeperException.SessionExpiredException&nbsp;e){
				//start&nbsp;a&nbsp;new&nbsp;session
			}catch(KeeperException&nbsp;e){
				e.printStackTrace();
				break;
			}
		}
	}
}</pre>
<p>ConfigWatcher类提供了配置信息变更观察器，在信息修改后会触发显示方法被调用。</p>
<pre class="brush:java;toolbar:false">public&nbsp;class&nbsp;ConfigWatcher&nbsp;implements&nbsp;Watcher{

	private&nbsp;ActiveKeyValueStore&nbsp;store;
	
	public&nbsp;ConfigWatcher(String&nbsp;hosts)&nbsp;throws&nbsp;Exception{
		store&nbsp;=&nbsp;new&nbsp;ActiveKeyValueStore();
		store.connect(hosts);
	}
	
	public&nbsp;void&nbsp;displayConfig()&nbsp;throws&nbsp;Exception{
		String&nbsp;value&nbsp;=&nbsp;store.read(ConfigUpdater.PATH,&nbsp;this);
		System.out.printf("Read&nbsp;%s&nbsp;as&nbsp;%s\n",&nbsp;ConfigUpdater.PATH,&nbsp;value);
	}
	
	public&nbsp;void&nbsp;process(WatchedEvent&nbsp;event)&nbsp;{
		//&nbsp;TODO&nbsp;Auto-generated&nbsp;method&nbsp;stub
		if(event.getType()&nbsp;==&nbsp;EventType.NodeDataChanged){
			try&nbsp;{
				displayConfig();
			}&nbsp;catch&nbsp;(Exception&nbsp;e)&nbsp;{
				System.out.println("Interrupted.&nbsp;Exiting.");
				Thread.currentThread().interrupt();
			}
		}
	}
	
	public&nbsp;static&nbsp;void&nbsp;main(String[]&nbsp;args)&nbsp;throws&nbsp;Exception&nbsp;{
		ConfigWatcher&nbsp;watcher&nbsp;=&nbsp;new&nbsp;ConfigWatcher("192.168.44.231");
		watcher.displayConfig();
		
		Thread.sleep(Long.MAX_VALUE);
	}
}</pre>
<p><br></p>
