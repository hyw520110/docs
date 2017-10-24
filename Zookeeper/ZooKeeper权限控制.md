
Zookeeper对权限的控制是节点级别的，而且不继承，即对父节点设置权限，其子节点不继承父节点的权限。

ZooKeeper 支持以下权限：

- CREATE: 能创建子节点,在setAcl中的简写w
- READ：能获取节点数据和列出其子节点,在setAcl中的简写r
- WRITE: 能设置节点数据,在setAcl中的简写w
- DELETE: 能删除子节点,在setAcl中的简写d
- ADMIN: 能够执行setAcl即能设置访问控制列表/权限,在setAcl中的简写w
- all 所有权限，在setAcl中的简写wrcda


Zookeeper提供了几种认证方式 

- world：有个单一的ID，anyone，表示任何人。 
- auth：不使用任何ID，代表任何已认证的用户。 
- digest：使用 用户名：密码 字符串生成MD5哈希值作为ACL标识符ID。权限的验证通过直接明文发送用户名:密码字符串的方式完成， 
- ip：使用客户端主机ip地址作为一个ACL标识符，ACL表达式是以 addr/bits 这种格式表示的。ZK服务器会将addr的前bits位与客户端地址的前bits位来进行匹配验证权限。 
 
对于管理员来说，通过启用超级用户可以对任意节点进行操作：

方法简单描述如下：

1. 运行java代码：

		System.out.println(DigestAuthenticationProvider.generateDigest( "admin:root" ) );
或cmd运行：

		java -cp %ZK_CLASSPATH% org.apache.zookeeper.server.auth.DigestAuthenticationProvider admin:root
 
2. 开启zookeeper的superDigest模式，配置如下启动参数，然后重启server：

		"-Dzookeeper.DigestAuthenticationProvider.superDigest=admin:0sxEug2Dpm/NpzMPieOlFREd9Ao=" 
启用超级用户，通过该超级用户认证的客户端(shell或java客户端)访问将不受ACL列表限制
3. 在java代码中进行digest模式的授权，方法如下：

		zkClient.addAuthInfo( "digest", "admin:root".getBytes() ); 
 

使用ZooKeeper的地方越来越多，应用大多喜欢自己部署一套ZK集群来使用。考虑到ZK的高可用，并且一套ZK集群至少3台机器，那么每个应用，尤其是一些非核心应用都自己去部署一套的话，对资源利用率很低。另外，随着ZK容灾的提出，单套ZK集群使用的机器量会更大，运维人员开始对这个情况担忧，强烈希望能够合并ZK集群。

ZK集群合并使用本身并没有太大的难度，问题在于应用方是否愿意大家共用一套ZK集群，这其中一个显而易见的问题就是权限：如果我的数据被别人动了怎么办？

<h4>方案一：采用ZooKeeper支持的ACLdigest方式，用户自己定义节点的权限</h4>

<p>这种方案将zookeeper的acl和digest授权认证模式相结合。</p>

<p>可以把这个访问授权过程看作是用户注册，系统给你一个密码，每次操作使用这个用户名(appName)和密码.于是就可以对应有这样权限管理系统，专门是负责进行节点的创建申请：包含“申请私有节点”和“申请公有节点”。这样一来，节点的创建都是由这个权限管理系统来负责了，每次申请完后，系统都会返回给你的一个key，格式通常是“{appName}:{password}”,以后你的任何操作都要在zksession中携带上这个key，这样就能进行权限控制。当然，用户自己通过zk客户端进行path的创建也是可以的，只是要求他们要使用授权方式来进行zk节点的创建。（注意，如果使用zkclient，请使用<a href="https://github.com/nileader/zkclient" target="_blank">https://github.com/nileader/zkclient</a>）</p>
	
	 	import java.util.ArrayList; 
		import java.util.List; 
		 
		import org.apache.zookeeper.WatchedEvent; 
		import org.apache.zookeeper.Watcher; 
		import org.apache.zookeeper.ZooDefs.Ids; 
		import org.apache.zookeeper.data.ACL; 
		import org.apache.zookeeper.server.auth.DigestAuthenticationProvider; 
 
		public class DemoAuth2 implements Watcher { 
	 
		    final static String SERVER_LIST = "127.0.0.1:2181"; 
		     
		    final static String PATH = "/yinshi_auth_test"; 
		    final static String PATH_DEL = "/yinshi_auth_test/will_be_del"; 
		 
		    final static String authentication_type = "digest"; 
		 
		    final static String correctAuthentication = "taokeeper:true"; 
		    final static String badAuthentication = "taokeeper:errorCode"; 
		    final static String superAuthentication = "super:yinshi.nc-1988"; 
		 
		    static ZkClient zkClient = null; 
		 
		    public static void main( String[] args ) throws Exception { 
		 
		        System.out.println( DigestAuthenticationProvider.generateDigest( "super:yinshi.nc-1988" ) ); 
		         
		        List< ACL > acls = new ArrayList< ACL >( 1 ); 
		        for ( ACL ids_acl : Ids.CREATOR_ALL_ACL ) { 
		            acls.add( ids_acl ); 
		        } 
		 
		        try { 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, correctAuthentication.getBytes() ); 
		        } catch ( Exception e ) { 
		            // TODO Auto-generated catch block 
		            e.printStackTrace(); 
		        } 
		 
		        try { 
		            zkClient.createPersistent( PATH, acls, "init content" ); 
		            System.out.println( "使用授权key：" + correctAuthentication + "创建节点：" + PATH + ", 初始内容是: init content" ); 
		        } catch ( Exception e ) { 
		            e.printStackTrace(); 
		        } 
		        try { 
		            zkClient.createPersistent( PATH_DEL, acls, "待删节点" ); 
		            System.out.println( "使用授权key：" + correctAuthentication + "创建节点：" + PATH_DEL + ", 初始内容是: init content" ); 
		        } catch ( Exception e ) { 
		            // TODO Auto-generated catch block 
		            e.printStackTrace(); 
		        } 
		 
		        // 获取数据 
		        getDataByNoAuthentication(); 
		        getDataByBadAuthentication(); 
		        getDataByCorrectAuthentication(); 
		        getDataByBadAuthentication(); 
		        getDataBySuperAuthentication(); 
			// 
			//      // 更新数据 
			//      updateDataByNoAuthentication(); 
			//      updateDataByBadAuthentication(); 
			//      updateDataByCorrectAuthentication(); 
			// 
			//      // 获取数据 
			//      getDataByNoAuthentication(); 
			//      getDataByBadAuthentication(); 
			//      getDataByCorrectAuthentication(); 
			// 
			//      //删除数据 
			//      deleteNodeByBadAuthentication(); 
			//      deleteNodeByNoAuthentication(); 
			//      deleteNodeByCorrectAuthentication(); 
			// 
			//      deleteParent(); 
		         
		        zkClient.close(); 
		    } 
		 
		    /** 获取数据：采用错误的密码 */ 
		    static void getDataByBadAuthentication() { 
		        String prefix = "[使用错误的授权信息]"; 
		        try { 
		            System.out.println( prefix + "获取数据：" + PATH ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, badAuthentication.getBytes() ); 
		            System.out.println( prefix + "成功获取数据：" + zkClient.readData( PATH ) ); 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "获取数据失败，原因：" + e.getMessage() ); 
		        } 
		    } 
		 
		    /** 获取数据：不采用密码 */ 
		    static void getDataByNoAuthentication() { 
		        String prefix = "[不使用任何授权信息]"; 
		        try { 
		            System.out.println( prefix + "获取数据：" + PATH ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            System.out.println( prefix + "成功获取数据：" + zkClient.readData( PATH ) ); 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "获取数据失败，原因：" + e.getMessage() ); 
		        } 
		    } 
		 
		    /** 采用正确的密码 */ 
		    static void getDataByCorrectAuthentication() { 
		        String prefix = "[使用正确的授权信息]"; 
		        try { 
		            System.out.println( prefix + "获取数据：" + PATH ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, correctAuthentication.getBytes() ); 
		            System.out.println( prefix + "成功获取数据：" + zkClient.readData( PATH ) ); 
		        } catch ( Exception e ) { 
		            System.out.println( prefix + "获取数据失败，原因：" + e.getMessage() ); 
		        } 
		    } 
		     
		    /** 采用超级用户的密码 */ 
		    static void getDataBySuperAuthentication() { 
		        String prefix = "[使用超级用户的授权信息]"; 
		        try { 
		            System.out.println( prefix + "获取数据：" + PATH ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, superAuthentication.getBytes() ); 
		            System.out.println( prefix + "成功获取数据：" + zkClient.readData( PATH ) ); 
		        } catch ( Exception e ) { 
		            System.out.println( prefix + "获取数据失败，原因：" + e.getMessage() ); 
		        } 
		    } 
		 
		    /** 
		     * 更新数据：不采用密码 
		     */ 
		    static void updateDataByNoAuthentication() { 
		         
		        String prefix = "[不使用任何授权信息]"; 
		         
		        System.out.println( prefix + "更新数据： " + PATH ); 
		        try { 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            if( zkClient.exists( PATH ) ){ 
		                zkClient.writeData( PATH, prefix ); 
		                System.out.println( prefix + "更新成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "更新失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		 
		    /** 
		     * 更新数据：采用错误的密码 
		     */ 
		    static void updateDataByBadAuthentication() { 
		         
		        String prefix = "[使用错误的授权信息]"; 
		         
		        System.out.println( prefix + "更新数据：" + PATH ); 
		        try { 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, badAuthentication.getBytes() ); 
		            if( zkClient.exists( PATH ) ){ 
		                zkClient.writeData( PATH, prefix ); 
		                System.out.println( prefix + "更新成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "更新失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		 
		    /** 
		     * 更新数据：采用正确的密码 
		     */ 
		    static void updateDataByCorrectAuthentication() { 
		         
		        String prefix = "[使用正确的授权信息]"; 
		         
		        System.out.println( prefix + "更新数据：" + PATH ); 
		        try { 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, correctAuthentication.getBytes() ); 
		            if( zkClient.exists( PATH ) ){ 
		                zkClient.writeData( PATH, prefix ); 
		                System.out.println( prefix + "更新成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "更新失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		 
		     
		    /** 
		     * 不使用密码 删除节点 
		     */ 
		    static void deleteNodeByNoAuthentication() throws Exception { 
		         
		        String prefix = "[不使用任何授权信息]"; 
		         
		        try { 
		            System.out.println( prefix + "删除节点：" + PATH_DEL ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            if( zkClient.exists( PATH_DEL ) ){ 
		                zkClient.delete( PATH_DEL ); 
		                System.out.println( prefix + "删除成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "删除失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		     
		     
		     
		    /** 
		     * 采用错误的密码删除节点 
		     */ 
		    static void deleteNodeByBadAuthentication() throws Exception { 
		         
		        String prefix = "[使用错误的授权信息]"; 
		         
		        try { 
		            System.out.println( prefix + "删除节点：" + PATH_DEL ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, badAuthentication.getBytes() ); 
		            if( zkClient.exists( PATH_DEL ) ){ 
		                zkClient.delete( PATH_DEL ); 
		                System.out.println( prefix + "删除成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.err.println( prefix + "删除失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		 
		 
		 
		    /** 
		     * 使用正确的密码删除节点 
		     */ 
		    static void deleteNodeByCorrectAuthentication() throws Exception { 
		         
		        String prefix = "[使用正确的授权信息]"; 
		         
		        try { 
		            System.out.println( prefix + "删除节点：" + PATH_DEL ); 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, correctAuthentication.getBytes() ); 
		            if( zkClient.exists( PATH_DEL ) ){ 
		                zkClient.delete( PATH_DEL ); 
		                System.out.println( prefix + "删除成功" ); 
		            } 
		        } catch ( Exception e ) { 
		            System.out.println( prefix + "删除失败，原因是：" + e.getMessage() ); 
		        } 
		    } 
		     
		     
		     
		    /** 
		     * 使用正确的密码删除节点 
		     */ 
		    static void deleteParent() throws Exception { 
		        try { 
		            zkClient = new ZkClient( SERVER_LIST, 50000); 
		            zkClient.addAuthInfo( authentication_type, correctAuthentication.getBytes() ); 
		            if( zkClient.exists( PATH ) ){ 
		                zkClient.delete( PATH ); 
		            } 
		        } catch ( Exception e ) { 
		            e.printStackTrace(); 
		        } 
		    } 
		 
		    @Override 
		    public void process( WatchedEvent event ) { 
		        // TODO Auto-generated method stub 
		         
		    } 

	
		} 

<h4>方案二、对zookeeper的AuthenticationProvider进行扩展，和内部其它系统A打通，从系统A中获取一些信息来判断权限</h4>
<p>这个方案大致是这样：<br>1.A系统上有一份IP和appName对应的数据本地。<br>2.将这份数据在ZK服务器上缓存一份，并定时进行缓存更新。<br>3.每次客户端对服务器发起请求的时候，获取客户端ip进行查询，判断是否有对应appName的权限。限制指定ip只能操作指定/appNameznode。<br>4.其它容灾措施。</p>
<p><strong>个人比较两个方案：</strong><br>1.方案一较方案二，用户的掌控性大，无论线上，日常，测试都可以由应用开发人员自己决定开启/关闭权限。（方案一的优势）<br>2.方案二较方案一，易用性强，用户的使用和无权限基本一致。（方案二的优势）<br>3.方案一较方案二更为纯洁。因为我觉得zk本来就应该是一个底层组件，让他来依赖其它上层的另一个系统？权限的控制精度取决于系统A上信息的准确性。(方案一的优势)</p>
<p><strong>另外附上方案一有权限和无权限对比压测TPS情况</strong><br>

![](http://pic.yupoo.com/nileader/CkKg3Zvd/medish.jpg)

<strong>测试条件</strong>：三台ZK服务器：8核JDK1.6.0-06四台zk客户端机器：5核JDK1.6.0-21<br><strong>测试场景</strong>：800个发布者，对应800个path，每个path3个订阅者，共2400个订阅者。发布者发布数据，通知订阅者。<br><strong>结论</strong>：权限控制对zk的TPS有一定的影响，但是还是保持在较高的水准（1.3w+)</p>
<p></p>

