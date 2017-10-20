<一>. 背景介绍：

 1. sharding机制：即通常所说的“分片”，允许数据存放在不同的物理机器上，  以适应数据量过大的场景，克服单台机器内存或者磁盘空间的限制。而这种“离散式”地存放，对客户端来说是透明的，对客户端来讲，完全看不到这种差别。
 2. 常见的内存缓存中间件，比如Memcached支持服务器端Sharding，客户端根本无须关心具体的实现细节。而Redis并不支持服务器端分片，不过我们可以使用Jedis提供的API来实现客户端的分片，通过“一致性hash”算法，使得数据离散地存放在不同的服务器上面。
 3. 对客户端来说，这是透明的，数据具体存在在那一台机器上面，对客户端来讲是无差别的。然后，通过不同机器上面的Redis控制台，我们还是可以看出数据的存储情况。
 4. 优缺点：使用Sharding机制，克服了单台服务器的“内存限制”，但是不可避免的降低了数据的存储和访问效率。

 

<二>. 进行配置：
 1. 增加节点：去掉之前的主从配置，作为用作Sharding的一台服务器，增加属性设置


    redis.host2=192.168.142.34  

  2. 连接池配置：使用shardedJedisPool


	    <bean id = "shardedJedisPool" class = "redis.clients.jedis.ShardedJedisPool">  
	        <constructor-arg index="0" ref="jedisPoolConfig"/>  
	        <constructor-arg index="1">  
	            <list>  
	                <bean class="redis.clients.jedis.JedisShardInfo">  
	                    <constructor-arg index="0" value="${redis.host}"/>         
	                    <constructor-arg index="1" value="${redis.port}" type="int"/>  
	                    <constructor-arg index="2" value="${redis.timeout}" type="int"/>  
	                    <property name="password" value="${redis.password}"/>  
	                </bean>  
	                <bean class="redis.clients.jedis.JedisShardInfo">  
	                    <constructor-arg index="0" value="${redis.host2}"/>         
	                    <constructor-arg index="1" value="${redis.port}" type="int"/>  
	                    <constructor-arg index="2" value="${redis.timeout}" type="int"/>  
	                    <property name="password" value="${redis.password}"/>  
	                </bean>  
	            </list>             
	        </constructor-arg>  
	    </bean>  

 <三>. 使用API编程：

1. 获取shardedJedis：


	    ShardedJedisPool shardedPool = (ShardedJedisPool)context.getBean("shardedJedisPool");  
	    ShardedJedis shardedJedis = shardedPool.getResource();  
	     ...  
	    shardedPool.returnResource(shardedJedis);   

2. 存储/访问/删除数据：


	    shardedJedis.set("president", "Obama");  
	    String president = shardedJedis.get("president");  
	    shardedJedis.del("president");  