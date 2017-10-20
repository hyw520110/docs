<一>. 使用list：
 可以使用列表模拟队列(queue)、堆栈(stack)，并且支持双向的操作(L或者R)。

1. 右边入队：


      jedis.rpush("userList", "James");  

2. 左边出队：右边出栈(rpop)，即为对堆栈的操作。


      	jedis.lpop("userList");  

3. 返回列表范围：从0开始，到最后一个(-1) [包含] 


      	List<String> userList = jedis.lrange("userList", 0, -1);  
Redis的TopN操作，即使用list完成：lrange

4. 删除：使用key


	      jedis.del("userList");  
5. 设置：位置1处为新值


	      jedis.lset("userList", 1, "Nick Xu");  

6. 返回长度：


	      Long size = jedis.llen("userList");  

7. 进行裁剪：包含

	      jedis.ltrim("userList", 1, 2);  

 
 <二>. 使用set：和列表不同，集合中的元素是无序的，因此元素也不能重复。

1. 添加到set：可一次添加多个


	      jedis.sadd("fruit", "apple");  
	      jedis.sadd("fruit", "pear", "watermelon");  
	      jedis.sadd("fruit", "apple");  

2. 遍历集合：


      	Set<String> fruit = jedis.smembers("fruit");  

3. 移除元素：remove


      	jedis.srem("fruit", "pear");  

4. 返回长度：


		Long size = jedis.scard("fruit");

5. 是否包含：


		Boolean isMember = jedis.sismember("fruit", "pear");  

6. 集合的操作：包括集合的交运算(sinter)、差集(sdiff)、并集(sunion)


		  jedis.sadd("food", "bread", "milk");   
		  Set<String> fruitFood = jedis.sunion("fruit", "food");  

   
<三>. 使用sorted set：有序集合在集合的基础上，增加了一个用于排序的参数。

1. 有序集合：根据“第二个参数”进行排序。


		jedis.zadd("user", 22, "James");  

2. 再次添加：元素相同时，更新为当前的权重。


		jedis.zadd("user", 24, "James");  

3. zset的范围：找到从0到-1的所有元素。


		Set<String> user = jedis.zrange("user", 0, -1);  

4. 说明：我们可能还有一个疑虑，集合是怎么做到有序的呢？
   实际上，上述user的数据类型为java.util.LinkedHashSet
   
<四>. 使用hash：
 
1. 存放数据：使用HashMap


		  Map<String, String>  capital = new HashMap<String, String>();  
		  capital.put("shannxi", "xi'an");  
		  ...  
		  jedis.hmset("capital", capital);  

2. 获取数据：


		List<String> cities = jedis.hmget("capital", "shannxi", "shanghai");  

  
<五>. 其他操作：

1. 对key的操作：
  @ 对key的模糊查询：


		  Set<String> keys = jedis.keys("*");  
		  Set<String> keys = jedis.keys("user.userid.*");  

  @ 删除key：


		jedis.del("city");  

      @ 是否存在：


		Boolean isExists = jedis.exists("user.userid.14101");  

  2. 失效时间：
  @ expire：时间为5s


      jedis.setex("user.userid.14101", 5, "James");  

  @ 存活时间(ttl)：time to live


      Long seconds = jedis.ttl("user.userid.14101");  

  @ 去掉key的expire设置：不再有失效时间


      jedis.persist("user.userid.14101");  

 3. 自增的整型：
  @ int类型采用string类型的方式存储：


      jedis.set("amount", 100 + "");  

  @ 递增或递减：incr()/decr()


      jedis.incr("amount");  

  @ 增加或减少：incrBy()/decrBy()


      jedis.incrBy("amount", 20);  

 4. 数据清空：
  @ 清空当前db：


      jedis.flushDB();  

      @ 清空所有db：


      jedis.flushAll();  

  5. 事务支持：
  @ 获取事务：


      Transaction tx = jedis.multi();  

      @ 批量操作：tx采用和jedis一致的API接口


      for(int i = 0;i < 10;i ++) {  
             tx.set("key" + i, "value" + i);   
             System.out.println("--------key" + i);  
             Thread.sleep(1000);      
      }  

  @ 执行事务：针对每一个操作，返回其执行的结果，成功即为Ok


      List<Object> results = tx.exec();  