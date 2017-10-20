#单机认证

首先关闭认证，即启动参数或配置文件中不指定auth选项

	 ./mongo
	 use admin

添加用户

语法：

	db.createUser(user, writeConcern)
- user这个文档创建关于用户的身份认证和访问信息；
	- user字段，为新用户的名字；
	- pwd字段，用户的密码；
	- roles字段，指定用户的角色，可以用一个空数组给新用户设定空角色。在roles字段,可以指定内置角色和用户定义的角色
- [writeConcern](http://docs.mongodb.org/manual/reference/write-concern/)这个文档描述保证MongoDB提供写操作的成功报告。
	- w选项：允许的值分别是 1、0、大于1的值、"majority"、<tag set>；
    - j选项：确保mongod实例写数据到磁盘上的journal（日志），这可以确保mongd以外关闭不会丢失数据。设置true启用。
    - wtimeout：指定一个时间限制,以毫秒为单位。wtimeout只适用于w值大于1。

示例：

	db.createUser({user: "admin",pwd: "superadmin",
	    roles: [
	       { role: "dbAdminAnyDatabase", db: "admin" },
		   { role: "clusterAdmin", db: "admin" }
	    ]
	  },
	  {w: "majority" ,wtimeout: 5000 }
	)

	db.createUser({user: "root",pwd: "superadmin",
	    roles: ["root"]
	  },
	  {w: "majority" ,wtimeout: 5000 }
	)

查看创建的用户 ： 

	show users 
	db.system.users.find()
删除用户(不开启安全认证)

	db.dropUser("admin") 

启用认证：
	
	security:
  	authorization: enabled
重启服务

用户验证使用：

启用用户验证后，再次登录mongo shell ，执行 show dbs 等命令会提示“没有权限”。此时，需要用户验证登录。

	db.auth("admin","admin")

内建的角色

- 数据库用户角色：read、readWrite;
- 数据库管理角色：dbAdmin、dbOwner、userAdmin；
- 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
- 备份恢复角色：backup、restore；
- 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
- 超级用户角色：root这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
- 内部角色：__system

[官方详情角色说明](https://docs.mongodb.com/manual/reference/built-in-roles/#built-in-roles) 

[配置文件示例](https://docs.mongodb.com/manual/reference/configuration-options/)
		      
	
	#此处为配置文件可配置的内容
	#Mongod config file 
	#MongoDB configuration files use the YAML format.
	#The following example configuration file contains several mongod settings.
	#
	########Example Start########
	#systemLog:
	#   destination: file
	#   path: "/var/log/mongodb/mongodb.log"
	#   logAppend: true
	#storage:
	#   journal:
	#      enabled: true
	#processManagement:
	#   fork: true
	#net:
	#   bindIp: 127.0.0.1
	#   port: 27017
	#setParameter:
	#   enableLocalhostAuthBypass: false
	#
	########Example End########
	#
	########Core Options
	systemLog:
	#   verbosity: 0    #Default: 0; 1 to 5 increases the verbosity level to include Debug messages.
	#   quiet: <boolean>
	#   traceAllException: <boolean>
	#   syslogFacility: user
	   path: "/usr/local/mongodb/log/mongod.log"
	   logAppend: true
	#   logRotate: <string>    #rename or reopen
	   destination: file
	#   timeStampFormat: iso8601-local
	#   component:
	#      accessControl:
	#         verbosity: 0
	#      command:
	#         verbosity: 0
	#      # COMMENT additional component verbosity settings omitted for brevity
	#      storage:
	#         verbosity: 0
	#         journal:
	#            verbosity: <int>
	#      write:
	#         verbosity: 0
	#
	#
	########ProcessManagement Options
	processManagement:
	   fork: true
	   pidFilePath: "/usr/local/mongodb/log/mongod.pid"
	#
	#
	#########Net Options
	net:
	   port: 27017
	#   bindIp: <string>    #Default All interfaces.
	#   maxIncomingConnections: 65536
	#   wireObjectCheck: true
	#   ipv6: false
	#   unixDomainSocket:
	#      enabled: true
	#      pathPrefix: "/tmp"
	#      filePermissions: 0700
	#   http:
	#      enabled: false
	#      JSONPEnabled: false
	#      RESTInterfaceEnabled: false
	#   ssl:
	#      sslOnNormalPorts: <boolean>  # deprecated since 2.6
	#      mode: <string>
	#      PEMKeyFile: <string>
	#      PEMKeyPassword: <string>
	#      clusterFile: <string>
	#      clusterPassword: <string>
	#      CAFile: <string>
	#      CRLFile: <string>
	#      allowConnectionsWithoutCertificates: <boolean>
	#      allowInvalidCertificates: <boolean>
	#      allowInvalidHostnames: false
	#      FIPSMode: <boolean>
	#
	#
	########security Options
	#security:
	#   keyFile: <string>
	#   clusterAuthMode: keyFile
	#   authorization: disable
	#   javascriptEnabled:  true
	########security.sasl Options
	#   sasl:
	#      hostName: <string>
	#      serviceName: <string>
	#      saslauthdSocketPath: <string>
	#
	#
	#########setParameter Option
	setParameter:
	   enableLocalhostAuthBypass: false
	#   <parameter1>: <value1>
	#   <parameter2>: <value2>
	#
	#
	#########storage Options
	storage:
	   dbPath: "/data/db"
	#   indexBuildRetry: true
	#   repairPath: "/data/db/_tmp"
	#   journal:
	#      enabled: true
	#   directoryPerDB: false
	#   syncPeriodSecs: 60
	   engine: "mmapv1"  #Valid options include mmapv1 and wiredTiger.
	#########storage.mmapv1 Options
	#   mmapv1:
	#      preallocDataFiles: true
	#      nsSize: 16
	#      quota:
	#         enforced: false
	#         maxFilesPerDB: 8
	#      smallFiles: false
	#      journal:
	#         debugFlags: <int>
	#         commitIntervalMs: 100   # 100 or 30
	#########storage.wiredTiger Options
	#   wiredTiger:
	#      engineConfig:
	#         cacheSizeGB: <number>  #Default: the maximum of half of physical RAM or 1 gigabyte
	#         statisticsLogDelaySecs: 0
	#         journalCompressor: "snappy"
	#         directoryForIndexes: false
	#      collectionConfig:
	#         blockCompressor: "snappy"
	#      indexConfig:
	#         prefixCompression: true
	#
	#
	##########operationProfiling Options
	#operationProfiling:
	#   slowOpThresholdMs: 100
	#   mode: "off"
	#
	#
	##########replication Options
	#replication:
	#   oplogSizeMB: <int>
	#   replSetName: <string>
	#   secondaryIndexPrefetch: all
	#
	#
	##########sharding Options
	#sharding:
	#   clusterRole: <string>    #configsvr or shardsvr
	#   archiveMovedChunks: True
	#
	#
	#########auditLog Options
	#auditLog:
	#   destination: <string>   #syslog/console/file
	#   format: <string>   #JSON/BSON
	#   path: <string>
	#   filter: <string>
	#
	#
	#########snmp Options
	#snmp:
	#   subagent: <boolean>
	#   master: <boolean>
	#
	#
	########mongos-only Options
	#replication:
	#   localPingThresholdMs: 15
	#
	#sharding:
	#   autoSplit: true
	#   configDB: <string>
	#   chunkSize: 64
	#
	#
	########Windows Service Options
	#processManagement:
	#   windowsService:
	#      serviceName: <string>
	#      displayName: <string>
	#      description: <string>
	#      serviceUser: <string>
	#      servicePassword: <string>

#副本集认证

副本集总体思路是用户名、密码和keyfile文件，keyfile需要各个副本集服务启动时加载而且要是同一文件，然后在操作库是需要用户名、密码

KeyFile文件必须满足条件:

（1）至少6个字符，小于1024字节

（2）认证时候不考虑文件中空白字符

（3）连接到副本集的成员和mongos进成的keyfile文件内容必须一样

（4）必须是base64编码,但是不能有等号

（5）文件权限必须是x00,也就是说，不能分配任何权限给group成员和other成员

注：win下可以通过记事本文件，输入任意内容，删除后缀名后使用，是否可行还在试验

 

以下为linux系统操作，win系统出了创建keyfile文件不一样 其他相同

1.生成keyFile文件：

	openssl rand -base64 100 > mongodb-keyfile --文件内容采base64编码，一共100个字符

2.修改文件权限：

	chmod 600 mongodb-keyfile

把生成的文件拷贝到副本集剩余各台机器上，存放的目录可以不一样，注意权限。

3.三台机器启动时指定--keyFile选项
	
	./mongod -f ../conf/28001.conf

在副本集中添加用户需要在服务未加--keyFile参数启动的情况加按照单实例方法添加(访问任意一个副本器操作，其他副本集会自动同步)，账户添加、授权成功后重新加入keyFile启动服务，即可完成并使用。

	./mongo 192.168.1.34:28001/admin -u admin -p
或

	./mongo 192.168.1.34:28001/admin
	db.auth('admin','superadmin')
##证书认证

	mkdir -p ./demoCA/{private,newcerts}  
	touch ./demoCA/index.txt  
	echo 01 > ./demoCA/serial  
	#生成CA密钥对  
	openssl genrsa -des3 -out ./demoCA/private/cakey.pem 2048   
	#生成证书请求和证书  
	openssl req -new -x509 -days 3650 -key ./demoCA/private/cakey.pem -out ./demoCA/cacert.pem  
	#生成用户密钥对,userkey设置密码userpempassword，clusterkey设置密码clusterempassword  
	#生成user证书Common Name必须为127.0.0.1  
	openssl genrsa -des3 -out ./demoCA/private/userkey.pem 2048  
	openssl genrsa -des3 -out ./demoCA/private/clusterkey.pem 2048   
	#生成用户证书请求  
	openssl req -new -key ./demoCA/private/userkey.pem -out userreq.req  
	openssl req -new -key ./demoCA/private/clusterkey.pem -out clusterreq1.req  
	#使用 CA 签发用户证书  
	openssl ca -in userreq.req -out usercert.pem -days 3650  
	openssl ca -in clusterreq1.req -out clustercert1.pem -days 3650  
	#将key和cer打包成pem  
	cat ./demoCA/private/userkey.pem usercert.pem > user.pem  
	cat ./demoCA/private/clusterkey.pem clustercert1.pem > cluster1.pem   
	openssl pkcs12 -export -clcerts -in usercert.pem -inkey ./demoCA/private/userkey.pem -out user.p12  

配置：

	ssl:
	  mode: requireSSL
	  CAFile: "/keys/ca-cert.crt"
      PEMKeyFile: "/keys/user.pem"  
      PEMKeyPassword: "userpempassword"  
      clusterFile: "/keys/cluster1.pem"  
      clusterPassword: "clusterpempassword"  
      allowInvalidHostnames:true  
userpempassword为用户密钥对密码， clusterpempassword为副本密钥对密码

连接：

	mongo 127.0.0.1:27001  --ssl --sslPEMKeyFile "/keys/user.pem" --sslPEMKeyPassword "userpempassword" --sslAllowInvalidCertificates  

java连接：

	import java.io.*;   
	import java.net.Socket;  
	import java.security.*;   
	import java.security.cert.*;   
	import java.util.*;   
	  
	import javax.net.ssl.*;   
	  
	import org.bson.Document;  
	  
	import com.mongodb.*;   
	import com.mongodb.MongoClientOptions.*;   
	import com.mongodb.client.*;   
	import xiaogen.util.Logger;  
	  
	/**  
	 * @author zhg  
	 * 创建于 2015年12月3日 上午11:14:07  
	 */  
	  
	/**  
	 * @author zhg  
	 *  
	 */  
	public class Mains implements MongoDBHelper  
	{  
	    private static SSLSocketFactory sss;  
	  
	    private static void initSSL() throws Exception  
	    {   
	          
	        // 服务端证书  
	        TrustManager[] trust = new TrustManager[] { new EmptyX509TrustManager() };  
	        // 客户端证书  
	        KeyManager[] key = createKeyManager(new FileInputStream("D:/MongoDB3/settings/keys/user.p12"), "sssss",  
	                null);  
	        SSLContext ssl = SSLContext.getInstance("SSL");  
	  
	        ssl.init(key, trust, new java.security.SecureRandom());  
	        sss = ssl.getSocketFactory();  
	    }  
	  
	    /**  
	     * 服务端要求证书  
	     *   
	     * @param stream  
	     * @param password  
	     * @param alias  
	     * @return  
	     */  
	    public static KeyManager[] createKeyManager(InputStream stream, String password, String alias)  
	    {  
	        try  
	        {  
	            if (stream != null)  
	            {  
	                // String type = KeyStore.getDefaultType();  
	                KeyStore ks = KeyStore.getInstance("PKCS12");  
	                ks.load(stream, password.toCharArray());  
	                if (alias != null)  
	                {  
	                    return new KeyManager[] { new AliasKeyManager(ks, alias, password) };  
	                } else  
	                {  
	                    KeyManagerFactory trustManagerFactory = KeyManagerFactory  
	                            .getInstance(KeyManagerFactory.getDefaultAlgorithm());  
	                    trustManagerFactory.init(ks, password.toCharArray());  
	                    return trustManagerFactory.getKeyManagers();  
	                }  
	            }  
	        } catch (Exception e)  
	        {  
	            // TODO  
	            e.printStackTrace();  
	        }  
	        return null;  
	    }  
	  
	    /**  
	     * 检验服务器  
	     *   
	     * @param stream  
	     * @param password  
	     * @return  
	     */  
	    public static TrustManager[] createTrustManager(InputStream stream, String password)  
	    {  
	        try  
	        {  
	            if (stream != null)  
	            {  
	                // String type = KeyStore.getDefaultType();  
	                // System.out.println(type);  
	                KeyStore ks = KeyStore.getInstance("PKCS12");  
	                ks.load(stream, password.toCharArray());  
	                TrustManagerFactory trustManagerFactory = TrustManagerFactory  
	                        .getInstance(TrustManagerFactory.getDefaultAlgorithm());  
	                trustManagerFactory.init(ks);  
	                // Logger.d("Provider : " + ks.getProvider().getName());  
	                // Logger.d("Type : " + ks.getType());  
	                // Logger.d("Size : " + ks.size());  
	                //  
	                // Enumeration<String> en = ks.aliases();  
	                // while (en.hasMoreElements())  
	                // {  
	                // Logger.d("Alias: " + en.nextElement());  
	                // }  
	                return trustManagerFactory.getTrustManagers();  
	            } else  
	            {  
	                return new TrustManager[] { new EmptyX509TrustManager() };  
	            }  
	        } catch (Exception e)  
	        {  
	            // TODO  
	            e.printStackTrace();  
	        }  
	        return null;  
	    }  
	  
	    private static class MyHostnameVerifier implements HostnameVerifier  
	    {  
	        @Override  
	        public boolean verify(String host, SSLSession arg1)  
	        {  
	            // Logger.d(host);  
	            return true;  
	        }  
	  
	    }  
	  
	    private static class EmptyX509TrustManager implements X509TrustManager  
	    {  
	        public EmptyX509TrustManager()  
	        {  
	  
	        }  
	  
	        public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException  
	        {  
	            // Logger.d(authType);  
	        }  
	  
	        public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException  
	        {  
	  
	            // Logger.d(Arrays.asList(chain)+"");  
	        }  
	  
	        public X509Certificate[] getAcceptedIssuers()  
	        {  
	            return null;  
	        }  
	  
	    }  
	  
	    private static class AliasKeyManager implements X509KeyManager  
	    {  
	        private KeyStore _ks;  
	        private String _alias;  
	        private String _password;  
	  
	        public AliasKeyManager(KeyStore ks, String alias, String password)  
	        {  
	            _ks = ks;  
	            _alias = alias;  
	            _password = password;  
	        }  
	  
	        public String chooseClientAlias(String[] arg0, Principal[] arg1, Socket arg2)  
	        {  
	            return _alias;  
	        }  
	  
	        public String chooseServerAlias(String arg0, Principal[] arg1, Socket arg2)  
	        {  
	            return _alias;  
	        }  
	  
	        public String[] getClientAliases(String arg0, Principal[] arg1)  
	        {  
	            return new String[] { _alias };  
	        }  
	  
	        public String[] getServerAliases(String arg0, Principal[] arg1)  
	        {  
	            return new String[] { _alias };  
	        }  
	  
	        public X509Certificate[] getCertificateChain(String arg0)  
	        {  
	            try  
	            {  
	                java.security.cert.Certificate[] certificates = this._ks.getCertificateChain(_alias);  
	                X509Certificate[] x509Certificates = new X509Certificate[certificates.length];  
	                System.arraycopy(certificates, 0, x509Certificates, 0, certificates.length);  
	                return x509Certificates;  
	            } catch (Exception e)  
	            {  
	                e.printStackTrace();  
	                return null;  
	            }  
	        }  
	  
	        public PrivateKey getPrivateKey(String arg0)  
	        {  
	            try  
	            {  
	                return (PrivateKey) _ks.getKey(_alias, _password == null ? null : _password.toCharArray());  
	            } catch (Exception e)  
	            {  
	                e.printStackTrace();  
	                return null;  
	            }  
	        }  
	  
	    }  
	  
	    final static String user = "all";  
	    final static char[] password = "xxxxxx".toCharArray();  
	    final static String auth = "admin";  
	    public static final String url = "192.168.10.105";  
	  
	    public static MongoClient getClients()  
	    {  
	        try  
	        {  
	            initSSL();  
	        } catch (Exception e)  
	        {  
	            e.printStackTrace();  
	        }  
	        Builder build = new MongoClientOptions.Builder();  
	        build.sslEnabled(true);  
	        build.sslInvalidHostNameAllowed(true);  
	        build.socketFactory(sss);  
	        MongoClient client = new MongoClient(Arrays.asList(new ServerAddress(url, 27001)),  
	                Arrays.asList(MongoCredential.createCredential(user, auth, password)), build.build());  
	        return client;  
	    }  
	  
	    Mains()  
	    {  
	        //关闭Mongodb调试输出  
	        java.util.logging.Logger.getLogger("").setLevel(java.util.logging.Level.OFF);  
	        try (MongoClient client = getClients())  
	        {  
	              
	            showDBs(client);  
	            MongoDatabase db = client.getDatabase("admin");  
	            showCollections(db);  
	            // getRoles(db);  
	            db = client.getDatabase("my");  
	            MongoCollection<Document> col = db.getCollection("logs");  
	            ArrayList<Document> list = col.find().into(new ArrayList<Document>());  
	            if (list.isEmpty())  
	            {  
	                ArrayList<Document> documents = new ArrayList<>();  
	                for (int i = 0; i < 10; i++)  
	                {  
	                    documents.add(new Document("index", i).append("uid", UUID.randomUUID().toString()));  
	                }  
	                col.insertMany(documents);  
	            } else  
	            {  
	                Logger.d("list size=" + list.size());  
	                Logger.d(new Document("res", list).toJson());  
	                if (list.size() < 10)  
	                {  
	                    col.drop();  
	                }  
	            }  
	        }  
	    }  
	  
	    /**  
	     * @param args  
	     */  
	    public static void main(String[] args)  
	    {  
	        new Mains();  
	    }  
	  
	}   

#副本集+分片环境下的认证

 

结合上面的两种环境的认证方式，可以实现副本集+分片环境中安全认证，需要注意以下几点

 

1.在分片集群环境中，副本集内成员之间需要用keyFile认证，mongos与配置服务器，副本集之间也要keyFile认证，集群所有mongod和mongos实例使用内容相同的keyFile文件。

2.进行初始化，修改副本集时，都从本地例外登录进行操作

3.由于启用了认证，需要建立一个管理员帐号，才能从远程登录。建立管理员帐户，利用管理员账户从远程登录后，需要建立一个可以操作某个数据库的用户，客户端就用这个用户访问数据库。

4.分片集群中的管理员帐号需要具备配置服务器中admin和config数据库的读写权限，才能进行分片相关操作

5.集群中每个分片有自己的admin数据库，存储了集群的各自的证书和访问权限。如果需要单独远程登录分片，可以按照3.2的办法建立用户

相关操作如下：

1.启动集群中的配置服务器，路由进程和副本集，每个进程都要指定KeyFile文件，而且每个进程的keyfile内容相同，详细操作见3.2。

2.初始化副本集。

3. 连接mongos，为集群建立管理员帐号和普通帐号，步骤如下；

（1）建立管理员帐号

管理员需要具备对集群中配置服务器的读写权限，这些权限包括：

建立新的普通管理员，用于客户端连接集群中的数据库；

分片相关权限，例如查看分片状态，启用分片，设置片键等操纵。

首先用本地例外方式登录，建立管理员帐号：

	mongo --port 30000

	use admin
	db.addUser( { user: "superman",
	 pwd: "superman",
	 roles: [ "clusterAdmin","userAdminAnyDatabase","dbAdminAnyDatabase","readWriteAnyDatabase" ] } )


	db.auth("superman","superman")
	use config

	db.addUser( { user: "superman",
	  pwd: "superman",
	  roles: [ "clusterAdmin","userAdminAnyDatabase","dbAdminAnyDatabase","readWriteAnyDatabase" ] } )

	db.auth("superman","superman")



用上面建立的管理员帐号登录mongos进程，对数据库（比如test）启用分片，设置集合片键。

 

用管理员账户登录，建立新账户，让他可以读写数据库test

	mongo localhost:30000/admin -u superman -p superman

	use test
	db.addUser("test","test")
	
	db.auth("test","test")



（4）用新帐号test登录，操作数据库test

	mongo localhost:30000/test -u test -p test            
	for( var i = 1; i < 100000; i++ ) db.test.insert( { x:i, C_ID:i } );

说明：为分片集群启用认证后，本地例外方式登录由于只具备admin数据库读写权限，无法进行分片操作。对本例来讲，添加分片，查看分片状态等操作都需要用superman帐号登录才行。执行数据库test操作用test帐号，这个帐号就是提供给客户端的帐号。

 

四 java操作中用户验证登陆

对于认证启动的服务，在java中操作在原有基础上增加一部db验证即可
	
	DB db = mongo.getDB("dbname");
	
	boolean auth = db.authenticate("name","password".toCharArray());

验证成功则返回true 否则返回false

注：db验证只能一次，如果成功后就不能继续验证，否则会报重复验证异常

然就就可按需求进行相关操作	



<table border="1" cellspacing="0" cellpadding="0" width="762">
<tbody>
<tr>
<td style="background:#BFBFBF">
<p><strong>角色分类</strong></p>
</td>
<td style="background:#BFBFBF">
<p><strong>角色</strong></p>
</td>
<td style="background:#BFBFBF">
<p><strong>权限及角色</strong></p>
<p><strong>（本文大小写可能有些变化，使用时请参考官方文档）</strong></p>
</td>
</tr>
<tr>
<td rowspan="2" style="background:#C6D9F1">
<p>Database User Roles</p>
</td>
<td style="background:#C6D9F1">
<p>read</p>
</td>
<td valign="top" style="background:#C6D9F1">
<p>CollStats,dbHash,dbStats,find,killCursors,listIndexes,listCollections</p>
</td>
</tr>
<tr>
<td style="background:#C6D9F1">
<p>readWrite</p>
</td>
<td valign="top" style="background:#C6D9F1">
<p>CollStats,ConvertToCapped,CreateCollection,DbHash,DbStats,</p>
<p>DropCollection,CreateIndex,DropIndex,Emptycapped,Find,</p>
<p>Insert,KillCursors,ListIndexes,ListCollections,Remove,</p>
<p>RenameCollectionSameDB,update</p>
</td>
</tr>
<tr>
<td rowspan="3" style="background:#EAF1DD">
<p>Database Administration Roles</p>
</td>
<td style="background:#EAF1DD">
<p>dbAdmin</p>
</td>
<td valign="top" style="background:#EAF1DD">
<p>collStats,dbHash,dbStats,find,killCursors,listIndexes,listCollections,</p>
<p>dropCollection 和 createCollection 在 system.profile </p>
</td>
</tr>
<tr>
<td style="background:#EAF1DD">
<p>dbOwner</p>
</td>
<td valign="top" style="background:#EAF1DD">
<p>角色：readWrite, dbAdmin,userAdmin</p>
</td>
</tr>
<tr>
<td style="background:#EAF1DD">
<p>userAdmin</p>
</td>
<td valign="top" style="background:#EAF1DD">
<p>ChangeCustomData,ChangePassword,CreateRole,CreateUser,</p>
<p>DropRole,DropUser,GrantRole,RevokeRole,ViewRole,viewUser</p>
</td>
</tr>
<tr>
<td rowspan="4" style="background:#E5DFEC">
<p>Cluster Administration Roles</p>
</td>
<td style="background:#E5DFEC">
<p>clusterAdmin</p>
</td>
<td valign="top" style="background:#E5DFEC">
<p>角色：clusterManager, clusterMonitor, hostManager</p>
</td>
</tr>
<tr>
<td style="background:#E5DFEC">
<p>clusterManager</p>
</td>
<td valign="top" style="background:#E5DFEC">
<p>AddShard,ApplicationMessage,CleanupOrphaned,FlushRouterConfig,</p>
<p>ListShards,RemoveShard,ReplSetConfigure,ReplSetGetStatus,</p>
<p>ReplSetStateChange,Resync,</p>
<p>&nbsp;</p>
<p>EnableSharding,MoveChunk,SplitChunk,splitVector</p>
</td>
</tr>
<tr>
<td style="background:#E5DFEC">
<p>clusterMonitor</p>
</td>
<td valign="top" style="background:#E5DFEC">
<p>connPoolStats,cursorInfo,getCmdLineOpts,getLog,getParameter,</p>
<p>getShardMap,hostInfo,inprog,listDatabases,listShards,netstat,</p>
<p>replSetGetStatus,serverStatus,shardingState,top</p>
<p>&nbsp;</p>
<p>collStats,dbStats,getShardVersion</p>
</td>
</tr>
<tr>
<td style="background:#E5DFEC">
<p>hostManager</p>
</td>
<td valign="top" style="background:#E5DFEC">
<p>applicationMessage,closeAllDatabases,connPoolSync,cpuProfiler,</p>
<p>diagLogging,flushRouterConfig,fsync,invalidateUserCache,killop,</p>
<p>logRotate,resync,setParameter,shutdown,touch,unlock</p>
</td>
</tr>
<tr>
<td rowspan="2" style="background:#FDE9D9">
<p>Backup and Restoration Roles</p>
</td>
<td style="background:#FDE9D9">
<p>backup</p>
</td>
<td valign="top" style="background:#FDE9D9">
<p>提供在admin数据库mms.backup文档中insert,update权限</p>
<p>列出所有数据库：listDatabases</p>
<p>列出所有集合索引：listIndexes</p>
<p>&nbsp;</p>
<p>对以下提供查询操作：find</p>
<p>*非系统集合</p>
<p>*系统集合：system.indexes, system.namespaces, system.js</p>
<p>*集合：admin.system.users 和 admin.system.roles</p>
</td>
</tr>
<tr>
<td style="background:#FDE9D9">
<p>restore</p>
</td>
<td valign="top" style="background:#FDE9D9">
<p>非系统集合、system.js，admin.system.users 和 admin.system.roles 及2.6 版本的system.users提供以下权限：</p>
<p>collMod,createCollection,createIndex,dropCollection,insert</p>
<p>&nbsp;</p>
<p>列出所有数据库：listDatabases</p>
<p>system.users ：find,remove,update</p>
</td>
</tr>
<tr>
<td rowspan="4" style="background:#DAEEF3">
<p>All-Database Roles</p>
</td>
<td style="background:#DAEEF3">
<p>readAnyDatabase</p>
</td>
<td valign="top" style="background:#DAEEF3">
<p>提供所有数据库中只读权限：read</p>
<p>列出集群所有数据库：listDatabases</p>
</td>
</tr>
<tr>
<td style="background:#DAEEF3">
<p>readWriteAnyDatabase</p>
</td>
<td valign="top" style="background:#DAEEF3">
<p>提供所有数据库读写权限：readWrite</p>
<p>列出集群所有数据库：listDatabases</p>
</td>
</tr>
<tr>
<td style="background:#DAEEF3">
<p>userAdminAnyDatabase</p>
</td>
<td valign="top" style="background:#DAEEF3">
<p>提供所有用户数据管理权限：userAdmin</p>
<p>Cluster：authSchemaUpgrade,invalidateUserCache,listDatabases</p>
<p>admin.system.users和admin.system.roles：</p>
<p>collStats,dbHash,dbStats,find,killCursors,planCacheRead</p>
<p>createIndex,dropIndex</p>
</td>
</tr>
<tr>
<td style="background:#DAEEF3">
<p>dbAdminAnyDatabase</p>
</td>
<td valign="top" style="background:#DAEEF3">
<p>提供所有数据库管理员权限：dbAdmin</p>
<p>列出集群所有数据库：listDatabases</p>
</td>
</tr>
<tr>
<td style="background:#DDD9C3">
<p>Superuser Roles</p>
</td>
<td style="background:#DDD9C3">
<p>root</p>
</td>
<td valign="top" style="background:#DDD9C3">
<p>角色：dbOwner，userAdmin，userAdminAnyDatabase</p>
<p>readWriteAnyDatabase, dbAdminAnyDatabase,</p>
<p>userAdminAnyDatabase，clusterAdmin</p>
</td>
</tr>
<tr>
<td style="background:#F2DBDB">
<p>Internal Role</p>
</td>
<td style="background:#F2DBDB">
<p>__system</p>
</td>
<td valign="top" style="background:#F2DBDB">
<p>集群中对任何数据库采取任何操作</p>
</td>
</tr>
</tbody>
</table>