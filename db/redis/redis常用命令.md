Redis提供了丰富的命令，允许我们连接客户端对其进行直接操作.这里简单介绍一下作为常用的一些命令，包括对字符串、列表、集合、有序集合、哈希表的操作，以及一些其他常用命令。

批量删除：

	./redis-cli keys "abc*" | xargs ./redis-cli del
	./redis-cli -c -p 7000  KEYS "paramCode*" | xargs ./redis-cli del

【 基本操作】

1. 添加记录：通常用于设置字符串(string)类型，或者整数类型；如果key已经存在，则覆盖其对应的值。


		set name James  

2. 获取记录：通过键获取值。


		get name  

3. 递增/递减：针对整数类型，仍然使用类似于字符串的操作方式：并且可以进行递增、递减操作。


	    set age 22  
	    incr age   
	    decr age  

4. 在key不存在时才添加：


    	setnx name Nick  

5. 设置失效时间：以避免数据量的持续增长，如下命令：设置过期时间为5s。 


    	setex name 5 Bill  

  上述命令，等价于：


	    set name Bill  
	    expire name 5  


【列表操作】可以使用列表(list)来模拟队列(queue)/堆栈(stack)。
1. 添加元素：给列表userList从右边压入字符串James。


    	rpush userList James  

 2. 移除元素：从userList左侧移除第一个元素。


    	lpop userList   

 3. 列表范围：如下命令获取从0(左侧起始位置)到-1(右侧最后一个位置)之间的所有元素，并且包含起始位置的元素。


    	lrange userList 0 -1  

 4. 设置元素：设置userList位置1处为新值，对包含空格的字符串使用引号括起来。


    	lset userList 1 "Nick Xu"  

  5. 列表长度：


    	llen userList  

 6. 裁剪列表：执行如下命令后，列表userList只包含原始列表从位置1到3的连续元素。


    	ltrim userList 1 3  

 

【集合操作】集合中元素不能重复，并且集合是无序的。
 1. 添加元素：可同时添加多个元素。


	    sadd fruit watermelon  
	    sadd fruit apple pear  

 2. 查看集合中的所有元素：


    	smembers fruit  

 3. 移除元素：


    	srem fruit apple  

  4. 集合大小：返回集合中包含的元素的个数。


    	scard fruit  

  5. 集合中是否包含元素：


    	sismember fruit pear  

  6. 集合的运算：如下命令返回集合food和fruit的并集，另外还有交集(sinter)、差集(sdiff)运算。


    	sunion food fruit  

 

【有序集合】sorted set
  1. 添加元素：根据第二个参数进行排序。


    	zadd user 23 James  

   2. 重复添加：存在相同的value，权重参数更新为24。


    	zadd user 24 James  

   3. 集合范围：找到从0到-1的所有元素，并且是有序的。


    	zrange user 0 -1  

 

 【哈希表操作】

 1. 添加元素：给哈希表china添加键为shannxi，值为xian的成员。


    	hset china shannxi xian   

  2. 获取元素：获取哈希表china中键shannxi所对应的value值。


    	hget china shannxi   

  3. 返回哈希表所有的key：


    	hkeys china   

  4. 返回哈希表所有的value：


    	hvals china  

 

   【补充：对key的操作】

  1. 删除key：


    	del name  

   2. key是否存在：


    	exists name  

  3. key的存活时间：time to live


    	ttl name  

  4. 查询所有的key：


    	keys *  

  5. 模糊匹配：


    	keys name*  

  6. 将key移动到数据库1中：


    	move name 1  

  
   【其他命令】
   1. 获取服务器信息：  


    	info  

    2. 获取特定信息：


    	info keyspace  

    3. 选择数据库：在Redis中默认有16个数据库(编号从0到15)，默认是对数据库0进行操作。


    	select 1  

    4. 当前数据库中key的数据：


    	dbsize  

5. 清空当前数据库：


    	flushdb  

6. 清空所有数据库：


    	flushall  

7. 测试连接：返回pong即为连接畅通。  


    	ping  

8. 退出客户端：或者是exit   命令。


    	quit  

9. 关闭服务器：


    	shutdown  
