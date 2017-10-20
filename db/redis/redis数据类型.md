Redis 支持5种数据类型，说明如下：

##字符串

Redis 字符串是一个字节序列。在 Redis 中字符串是二进制安全的，这意味着它们没有任何特殊终端字符来确定长度，所以可以存储任何长度为 512 兆的字符串(字符串值可以存储最大512兆字节的长度)。
	
	
	redis 127.0.0.1:6379> SET name "yiibai"
	OK
	redis 127.0.0.1:6379> GET name
	"yiibai"

在上面的例子中，SET 和 GET 是 Redis 命令，name 和 "yiibai" 是存储在 Redis 的键和字符串值。

##哈希
Redis哈希是键值对的集合。 Redis哈希是字符串字段和字符串值之间的映射，所以它们用来表示对象。

	
	redis 127.0.0.1:6379> HMSET user:1 username yiibai password yiibai points 200
	OK
	redis 127.0.0.1:6379> HGETALL user:1
	
	1) "username"
	2) "yiibai"
	3) "password"
	4) "yiibai"
	5) "points"
	6) "200"

在上面的例子中，哈希数据类型用于存储包含用户基本信息的用户对象。这里 HSET，HEXTALL 是 Redis 命令同时 user:1 也是一个键。
每个哈希可存储多达232 - 1个 字段 - 值对(超过40亿)

##列表
Redis 列表是简单的字符串列表，通过插入顺序排序。可以添加一个元素到 Redis 列表的头部或尾部。
	
	
	redis 127.0.0.1:6379> lpush tutoriallist redis
	(integer) 1
	redis 127.0.0.1:6379> lpush tutoriallist mongodb
	(integer) 2
	redis 127.0.0.1:6379> lpush tutoriallist rabitmq
	(integer) 3
	redis 127.0.0.1:6379> lrange tutoriallist 0 10
	
	1) "rabitmq"
	2) "mongodb"
	3) "redis"

列表的最大长度为  232 - 1 个元素（4294967295，每个列表的元素超过四十亿）。
##集合
Redis 集合是字符串的无序集合。在 Redis 可以添加，删除和测试成员存在的时间复杂度为 O（1）。
	
	
	redis 127.0.0.1:6379> sadd tutoriallist redis
	(integer) 1
	redis 127.0.0.1:6379> sadd tutoriallist mongodb
	(integer) 1
	redis 127.0.0.1:6379> sadd tutoriallist rabitmq
	(integer) 1
	redis 127.0.0.1:6379> sadd tutoriallist rabitmq
	(integer) 0
	redis 127.0.0.1:6379> smembers tutoriallist
	
	1) "rabitmq"
	2) "mongodb"
	3) "redis"

注：在上面的例子中 rabitmq 被添加两次，但由于它是只集合具有唯一特性。集合中的成员最大数量为 232 - 1（4294967295，每个集合有超过四十亿条记录）。
##集合排序
不同的是，一个有序集合的每个成员都可以排序，就是为了按有序集合排序获取它们，按权重分值从最小到最大排序。虽然成员都是独一无二的，按权重分数值可能会重复。

	
	redis 127.0.0.1:6379> zadd tutoriallist 0 redis
	(integer) 1
	redis 127.0.0.1:6379> zadd tutoriallist 0 mongodb
	(integer) 1
	redis 127.0.0.1:6379> zadd tutoriallist 0 rabitmq
	(integer) 1
	redis 127.0.0.1:6379> zadd tutoriallist 0 rabitmq
	(integer) 0
	redis 127.0.0.1:6379> ZRANGEBYSCORE tutoriallist 0 1000
	
	1) "redis"
	2) "mongodb"
	3) "rabitmq"
	
#Redis键
Redis 中的 keys 命令用于管理 redis 中的键。Redis keys命令使用的语法如下所示：


	redis 127.0.0.1:6379> COMMAND KEY_NAME
例子：
	
	redis 127.0.0.1:6379> SET yiibai redis
	OK
	redis 127.0.0.1:6379> DEL yiibai
	(integer) 1

在上面的例子中 DEL 是一个命令，而 yiibai 是一个键。如果键被成功删除，则该命令的输出将是（整数）1，否则这将是（整数）0；
##Redis的键命令

 	DEL key 此命令删除键，如果存在
 	DUMP key该命令返回存储在指定键的值的序列化版本。
 	EXISTS key 此命令检查该键是否存在。
 	EXPIRE key seconds 指定键的过期时间
 	EXPIREAT key timestamp 指定的键过期时间。在这里，时间是在Unix时间戳格式
 	PEXPIRE key milliseconds 设置键以毫秒为单位到期
 	PEXPIREAT key milliseconds-timestamp 设置键在Unix时间戳指定为毫秒到期
 	KEYS pattern 查找与指定模式匹配的所有键
 	MOVE key db 移动键到另一个数据库
 	PERSIST key 移除过期的键
 	PTTL key 以毫秒为单位获取剩余时间的到期键。
 	TTL key 获取键到期的剩余时间。
 	RANDOMKEY 从Redis返回随机键
 	RENAME key newkey 更改键的名称
 	RENAMENX key newkey 重命名键，如果新的键不存在
 	TYPE key 返回存储在键的数据类型的值

#Redis字符串
Redis的字符串命令用于管理redis的字符串值。Redis 的字符串命令语法的使用如下所示：


	redis 127.0.0.1:6379> COMMAND KEY_NAME
例子：
	
	redis 127.0.0.1:6379> SET yiibai redis
	OK
	redis 127.0.0.1:6379> GET yiibai
	"redis"

在上面示例中 SET 和 GET 是 Redis 的命令，这里 yiibai 就是一个键（key）；

	SET key value 此命令用于在指定键设置值
	GET key 键对应的值。
	GETRANGE key start end 得到字符串的子字符串存放在一个键
	GETSET key value 设置键的字符串值，并返回旧值
	GETBIT key offset 返回存储在键位值的字符串值的偏移
	MGET key1 [key2..] 得到所有的给定键的值
	SETBIT key offset value 设置或清除该位在存储在键的字符串值偏移
	SETEX key seconds value 键到期时设置值
	SETNX key value 设置键的值，只有当该键不存在
	SETRANGE key offset value 覆盖字符串的一部分从指定键的偏移
	STRLEN key 得到存储在键的值的长度
	MSET key value [key value ...] 设置多个键和多个值
	MSETNX key value [key value ...] 设置多个键多个值，只有在当没有按键的存在时
	PSETEX key milliseconds value 设置键的毫秒值和到期时间
	INCR key 增加键的整数值一次
	INCRBY key increment 由给定的数量递增键的整数值
	INCRBYFLOAT key increment 由给定的数量递增键的浮点值
	DECR key 递减键一次的整数值
	DECRBY key decrement 由给定数目递减键的整数值
	APPEND key value  追加值到一个键
##Redis哈希
Redis哈希是字符串字段和字符串值之间的映射，所以它是用来表示对象的一个完美的数据类型，Redis 的哈希值最多可存储超过4十亿字段-值对。
	
	
	redis 127.0.0.1:6379> HMSET yiibai name "redis tutorial" description "redis basic commands for caching" likes 20 visitors 23000
	OK
	redis 127.0.0.1:6379> HGETALL yiibai
	
	1) "name"
	2) "redis tutorial"
	3) "description"
	4) "redis basic commands for caching"
	5) "likes"
	6) "20"
	7) "visitors"
	8) "23000"

在上面的例子，我们在设置一个名为 yiibai Redis的哈希的教程详细信息（name, description, likes, visitors）。
###Redis的哈希命令：

	HDEL key field2 [field2] 删除一个或多个哈希字段
	HEXISTS key field 判断一个哈希字段存在与否
	HGET key field 获取存储在指定的键散列字段的值
	HGETALL key 让所有的字段和值在指定的键存储在一个哈希
	HINCRBY key field increment 由给定数量增加的哈希字段的整数值
	HINCRBYFLOAT key field increment 由给定的递增量哈希字段的浮点值
	HKEYS key 获取所有在哈希字段
	HLEN key 获取哈希字段数
	HMGET key field1 [field2] 获得所有给定的哈希字段的值
	HMSET key field1 value1 [field2 value2 ] 设置多个哈希字段的多个值
	HSET key field value 设置哈希字段的字符串值
	HSETNX key field value 设置哈希字段的值，仅当该字段不存在
	HVALS key 获取在哈希中的所有值
	HSCAN key cursor [MATCH pattern] [COUNT count] 增量迭代哈希字段及相关值

##Redis列表
Redis列表是简单的字符串列表，通过插入顺序排序。您可以在Redis 列表的头或列表尾添加元素。列表的最大长度为  232 - 1 个元素（4294967295，每个列表可有超过四十亿个元素）。
	
	
	redis 127.0.0.1:6379> LPUSH tutorials redis
	(integer) 1
	redis 127.0.0.1:6379> LPUSH tutorials mongodb
	(integer) 2
	redis 127.0.0.1:6379> LPUSH tutorials mysql
	(integer) 3
	redis 127.0.0.1:6379> LRANGE tutorials 0 10
	
	1) "mysql"
	2) "mongodb"
	3) "redis"

在上面的例子中的三个值由命令LPUSH 插入到 redis 名称为 tutorials 的列表。
###Redis的命令列表

	BLPOP key1 [key2 ] timeout 取出并获取列表中的第一个元素，或阻塞，直到有可用
	BRPOP key1 [key2 ] timeout 取出并获取列表中的最后一个元素，或阻塞，直到有可用
	BRPOPLPUSH source destination timeout 从列表中弹出一个值，它推到另一个列表并返回它;或阻塞，直到有可用
	LINDEX key index 从一个列表其索引获取对应的元素
	LINSERT key BEFORE|AFTER pivot value 在列表中的其他元素之后或之前插入一个元素
	LLEN key 获取列表的长度
	LPOP key 获取并取出列表中的第一个元素
	LPUSH key value1 [value2] 在前面加上一个或多个值的列表
	LPUSHX key value 在前面加上一个值列表，仅当列表中存在
	LRANGE key start stop 从一个列表获取各种元素
	LREM key count value 从列表中删除元素
	LSET key index value 在列表中的索引设置一个元素的值
	LTRIM key start stop 修剪列表到指定的范围内
	RPOP key 取出并获取列表中的最后一个元素
	RPOPLPUSH source destination 删除最后一个元素的列表，将其附加到另一个列表并返回它
	RPUSH key value1 [value2] 添加一个或多个值到列表
	RPUSHX key value 添加一个值列表，仅当列表中存在

##Redis集合
Redis集合是唯一字符串的无序集合。唯一集合是不允许数据有重复的键的。在 Redis 集合中添加，删除和测试成会是否存的时间复杂度为O（1）（恒定的时间，无论集合内包含元素的数量）。集合的最大长度为   232 - 1 个元素（4294967295，每个集合中超过四十亿个元素）。
	
	
	redis 127.0.0.1:6379> SADD yiibai redis
	(integer) 1
	redis 127.0.0.1:6379> SADD yiibai mongodb
	(integer) 1
	redis 127.0.0.1:6379> SADD yiibai mysql
	(integer) 1
	redis 127.0.0.1:6379> SADD yiibai mysql
	(integer) 0
	redis 127.0.0.1:6379> SMEMBERS yiibai
	
	1) "mysql"
	2) "mongodb"
	3) "redis"

在上面的例子中的三个值被 Redis 的命令SADD插入到一个名为 yiibai 集合。
##Redis有序集合
Redis的有序集合类似于Redis的集合，但是存储的值在集合中具有唯一性。另外有序集合的每个成员都使用分值（score）的东西，这个分值就是用于将有序集合排序，从分值最小到最大来排序。

在 Redis 有序集合添加，删除和测试成员的存在的时间复杂度为 O（1）（恒定时间，无论集合内包含元素的数量）。列表的最大长度为 232 - 1 个元素（4294967295，每个集合的元素超过四十亿）。 
	
	
	redis 127.0.0.1:6379> ZADD yiibai 1 redis
	(integer) 1
	redis 127.0.0.1:6379> ZADD yiibai 2 mongodb
	(integer) 1
	redis 127.0.0.1:6379> ZADD yiibai 3 mysql
	(integer) 1
	redis 127.0.0.1:6379> ZADD yiibai 3 mysql
	(integer) 0
	redis 127.0.0.1:6379> ZADD yiibai 4 mysql
	(integer) 0
	redis 127.0.0.1:6379> ZRANGE yiibai 0 10 WITHSCORES
	
	1) "redis"
	2) "1"
	3) "mongodb"
	4) "2"
	5) "mysql"
	6) "4"

在上面的例子中的三个值及其分值被 ZADD 命令插入一个名称为 yiibai 的 redis 有序集合中 

###Redis排序命令集

	ZADD key score1 member1 [score2 member2] 添加一个或多个成员到有序集合，或者如果它已经存在更新其分数
	ZCARD key 得到的有序集合成员的数量
	ZCOUNT key min max 计算一个有序集合成员与给定值范围内的分数
	ZINCRBY key increment member 在有序集合增加成员的分数
	ZINTERSTORE destination numkeys key [key ...] 多重交叉排序集合，并存储生成一个新的键有序集合。
	ZLEXCOUNT key min max 计算一个给定的字典范围之间的有序集合成员的数量
	ZRANGE key start stop [WITHSCORES] 由索引返回一个成员范围的有序集合。
	ZRANGEBYLEX key min max [LIMIT offset count] 返回一个成员范围的有序集合（由字典范围）
	ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT] 按分数返回一个成员范围的有序集合。
	ZRANK key member 确定成员的索引中有序集合
	ZREM key member [member ...] 从有序集合中删除一个或多个成员
	ZREMRANGEBYLEX key min max 删除所有成员在给定的字典范围之间的有序集合
	ZREMRANGEBYRANK key start stop 在给定的索引之内删除所有成员的有序集合
	ZREMRANGEBYSCORE key min max 在给定的分数之内删除所有成员的有序集合
	ZREVRANGE key start stop [WITHSCORES] 返回一个成员范围的有序集合，通过索引，以分数排序，从高分到低分
	ZREVRANGEBYSCORE key max min [WITHSCORES] 返回一个成员范围的有序集合，按分数，以分数排序从高分到低分
	ZREVRANK key member 确定一个有序集合成员的索引，以分数排序，从高分到低分
	ZSCORE key member 获取给定成员相关联的分数在一个有序集合
	ZUNIONSTORE destination numkeys key [key ...] 添加多个集排序，所得排序集合存储在一个新的键
	ZSCAN key cursor [MATCH pattern] [COUNT count] 增量迭代排序元素集和相关的分数



#Redis HyperLogLog


Redis HyperLogLog 是用来做基数统计的算法，HyperLogLog 的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定 的、并且是很小的。

在 Redis 里面，每个 HyperLogLog 键只需要花费 12 KB 内存，就可以计算接近 2^64 个不同元素的基 数。这和计算基数时，元素越多耗费内存就越多的集合形成鲜明对比。但是，因为 HyperLogLog 只会根据输入元素来计算基数，而不会储存输入元素本身，所以 HyperLogLog 不能像集合那样，返回输入的各个元素。


下面的例子说明了 HyperLogLog Redis 的工作原理：
	
	redis 127.0.0.1:6379> PFADD tutorials "redis"
	
	1) (integer) 1
	
	redis 127.0.0.1:6379> PFADD tutorials "mongodb"
	
	1) (integer) 1
	
	redis 127.0.0.1:6379> PFADD tutorials "mysql"
	
	1) (integer) 1
	
	redis 127.0.0.1:6379> PFCOUNT tutorials
	
	(integer) 3

#Redis发布订阅
Redis订阅和发布实现了通讯系统，发件人（在 Redis 中的术语称为发布者）发送邮件，而接收器（订户）接收它们。信息传输的链路称为通道。Redis 一个客户端可以订阅任意数量的通道。

以下举例说明发布订阅用户如何工作。在下面的例子给出一个客户端订阅的通道命名 redisChat 。
	
	redis 127.0.0.1:6379> SUBSCRIBE redisChat
	
	Reading messages... (press Ctrl-C to quit)
	1) "subscribe"
	2) "redisChat"
	3) (integer) 1

现在，两个客户端都在同一个通道名：redisChat 上发布消息，上述订阅客户端接收消息。
	
	redis 127.0.0.1:6379> PUBLISH redisChat "Redis is a great caching technique"
	
	(integer) 1
	
	redis 127.0.0.1:6379> PUBLISH redisChat "Learn redis by tutorials point"
	
	(integer) 1
	
	
	1) "message"
	2) "redisChat"
	3) "Redis is a great caching technique"
	1) "message"
	2) "redisChat"
	3) "Learn redis by tutorials point"


#Redis事务
Redis事务允许一组命令在单一步骤中执行。事务有两个属性，说明如下：

在一个事务中的所有命令作为单个独立的操作顺序执行。在Redis事务中的执行过程中而另一客户机发出的请求，这是不可以的；
Redis事务是原子的。原子意味着要么所有的命令都执行，要么都不执行；


Redis 事务由指令 MULTI 发起的，之后传递需要在事务中和整个事务中，最后由 EXEC 命令执行所有命令的列表。

	redis 127.0.0.1:6379> MULTI
	OK
	List of commands here
	redis 127.0.0.1:6379> EXEC


下面的例子说明了 Redis 的事务是如何开始和执行。
	
	redis 127.0.0.1:6379> MULTI
	OK
	redis 127.0.0.1:6379> SET tutorial redis
	QUEUED
	redis 127.0.0.1:6379> GET tutorial
	QUEUED
	redis 127.0.0.1:6379> INCR visitors
	QUEUED
	redis 127.0.0.1:6379> EXEC
	
	1) OK
	2) "redis"
	3) (integer) 1

#Redis脚本
Redis 脚本是使用Lua解释脚本用来评估（计算）。从 Redis 2.6.0 版本开始内置这个解释器。命令 EVAL 用于执行 脚本命令。

EVAL命令的基本语法如下：

	redis 127.0.0.1:6379> EVAL script numkeys key [key ...] arg [arg ...]


下面的例子说明了 Redis 脚本是如何工作的：
	
	redis 127.0.0.1:6379> EVAL "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
	
	1) "key1"
	2) "key2"
	3) "first"
	4) "second"

#Redis连接
Redis 的连接命令基本上都用于管理 Redis服务器与客户端连接。

下面的例子说明了一个客户端在Redis服务器上，如何检查服务器是否正在运行并验证自己。

	redis 127.0.0.1:6379> AUTH "password"
	OK
	redis 127.0.0.1:6379> PING
	PONG

#Redis备份
Redis的SAVE命令用于创建当前 Redis 数据库的备份。

Redis 的 SAVE 命令的基本语法如下所示：

	127.0.0.1:6379> SAVE


以下示例显示了如何在Redis的当前数据库中创建备份。

	127.0.0.1:6379> SAVE
	OK

这个命令将创建dump.rdb文件在Redis目录。
##Bgsave
创建 Redis 的备份也可以使用备用命令 BGSAVE 。此命令将启动备份过程，并在后台运行此。
	
	127.0.0.1:6379> BGSAVE
	Background saving started

在执行此命令之后，将在 redis 目录中创建一个 dump.rdb 文件。
#恢复Redis数据
要恢复redis数据只需要要将Redis的备份文件（dump.rdb）放到 Redis 的目录中，并启动服务器。要了解知道 Redis 目录在什么位置，可使用 CONFIG 命令，如下所示：

	127.0.0.1:6379> CONFIG get dir
	
	1) "dir"
	2) "/user/yiibai/redis-2.8.13/src"

在上面的命令命令输出为 /user/yiibai/redis-2.8.13/src 就是使用的Redis目录，也就是Redis的服务器安装的目录。

#Redis安全

Redis 数据库可以配置安全保护的，所以任何客户端在连接执行命令时需要进行身份验证。为了确保 Redis 的安全，需要在配置文件设置密码。

下面给出的例子显示的步骤是用来确保 Redis 实例的安全。

	127.0.0.1:6379> CONFIG get requirepass
	1) "requirepass"
	2) ""

默认情况下此属性是空的，这意味着此实例没有设置密码。可以通过执行以下命令来修改设置此属性

	127.0.0.1:6379> CONFIG set requirepass "yiibaipass"
	OK
	127.0.0.1:6379> CONFIG get requirepass
	1) "requirepass"
	2) "yiibaipass"

如果客户端运行命令无需验证设置密码，那么（错误）NOAUTH 需要验证。错误将返回。因此，客户端需要使用 AUTH 命令来验证自己的身份信息。

AUTH命令的基本语法如下所示：

	127.0.0.1:6379> AUTH password
  


#Redis性能测试/Redis基准
Redis的基准性能测试是通过同时运行 N 个命令以检查 Redis 性能的工具。

Redis的基准测试的基本语法如下所示：

	redis-benchmark [option] [option value]


示例:通过调用 100000 个（次）命令来检查 Redis。

	redis-benchmark -n 100000

例子:显示了多个使用的Redis基准工具选项。
	
	redis-benchmark -h 127.0.0.1 -p 6379 -t set,lpush -n 100000 -q
	
	SET: 146198.83 requests per second
	LPUSH: 145560.41 requests per second  

Redis的基准有许多可供选择，分列如下：
	
	 	-h 	指定服务器的主机名 	127.0.0.1
	 	-p 	指定服务器端口 	6379
	 	-s 	指定服务器套接字 	 
	 	-c 	指定并行连接数 	50
	 	-n 	指定请求总数 	10000
	 	-d 	指定以字节为单位设置/获取值的数据大小 	2
	 	-k 	1=保持活动0=重新连接 	1
	 	-r 	使用随机键对SET/GET/INCR，随机SADD值 	 
	 	-p 	管道<numreq>请求 	1
	 	-h 	指定服务器的主机名 	 
	 	-q 	Redis强制安静操作。只显示查询/秒值 	 
	 	--csv 	输出为CSV格式 	 
	 	-l 	产生循环，永远运行测试 	 
	 	-t 	只有运行的逗号分隔的测试列表。 	 
	 	-I 	空闲模式。刚刚开N个空闲连接和等待。 	 


#Redis客户端连接
如果启用了Redis 的接受配置监听，客户端可在TCP端口上与Unix套接字连接。以下操作执行后新的客户端连接被服务器接受：

- 客户端套接字在非阻塞状态，因为 Redis 使用复用和非阻塞I/O；
- TCP_NODELAY选项设定以确保不会在连接时延迟；
- 创建一个可读的文件事件，以便 Redis 能够尽快收集客户端查询作为新的数据可被套接字读取；

客户端最大连接数量
在Redis的配置文件（redis.conf）有一个属性 maxclients ，它描述了可以连接到 Redis 的客户的最大数量。命令的基本语法是：

	config get maxclients
	
	1) "maxclients"
	2) "10000"

默认情况下此属性设置为 10000（取决于OS的文件标识符限制最大数量），但可以修改这个属性。

在下面给出的例子我们已经设置客户端最大连接数量为 100000，在之后启动服务器：

	redis-server --maxclients 100000

客户端命令

	CLIENT LIST 	返回客户端的列表连接到Redis服务器
	CLIENT SETNAME 	指定名称的当前连接
	CLIENT GETNAME 	返回由CLIENT SETNAME设置当前连接的名称。
	CLIENT PAUSE 	这是一个连接控制命令可以暂停所有Redis客户指定的时间量(以毫秒为单位)。
	CLIENT KILL 	该命令关闭特定的客户端连接。


#Redis管道
Redis是一个TCP服务器，支持请求/响应协议。在 redis 中一个请求完成以下步骤：

- 客户端发送一个查询给服务器，并从套接字中读取，通常服务器的响应是在一个封闭的方式；
- 服务器处理命令并将响应返回给客户端；

##管道的含义
管道的基本含义是：客户端可以发送多个请求给服务器，而不等待全部响应，最后在单个步骤中读取所有响应。

要检查 Redis 管道只需要启动 Redis 实例，并在终端输入以下命令。

	$(echo -en "PING\r\n SET tutorial redis\r\nGET tutorial\r\nINCR visitor\r\nINCR visitor\r\nINCR visitor\r\n"; sleep 10) | nc localhost 6379

	+PONG
	+OK
	redis
	:1
	:2
	:3

在上面的例子所示，了解使用 PING 命令连接 Redis，之后我们在 Redis 设定一个名为 tutorial 字符串值，之后拿到这个键对应的值并增加访问人数的三倍。在结果中，我们可以看到所有的命令都提交给 Redis 一次，Redis是给单步输出所有命令。
##通道的好处
这种技术的好处是显着提高协议的性能。管道localhost 获得至少达到百倍的网络连接速度。 	

#Redis分区
分区是将数据分割成多个 Redis 实例，使每个实例将只包含键子集的过程。
##分区的好处

- 它允许更大的数据库，使用多台计算机的内存总和。如果不分区，只是一台计算机有限的内存可以支持的数据存储；
- 它允许按比例在多内核和多个计算机计算，以及网络带宽向多台计算机和网络适配器；

##分区的劣势

- 涉及多个键的操作通常不支持。例如，如果它们被存储在被映射到不同的 Redis 实例键，则不能在两个集合之间执行交集；
- 涉及多个键时，Redis事务无法使用；
- 分区粒度是一个键，所以它不可能使用一个键和一个非常大的有序集合分享一个数据集；
- 当使用分区，数据处理比较复杂，比如要处理多个RDB/AOF文件，使数据备份需要从多个实例和主机聚集持久性文件；
- 添加和删除的容量可能会很复杂。例如：Redis的Cluster支持数据在运行时添加和删除节点是透明平衡的，但其他系统，如客户端的分区和代理服务器不支持此功能

##分区类型
Redis 提供有两种类型的分区。假设我们有四个 redis 实例：R0，R1，R2，R3，分别表示用户用户如：user:1, user:2, ...等等
##范围分区
范围分区被映射对象指定 Redis 实例在一个范围内完成。
在我们的例子中，用户从ID为 0 至 ID10000 将进入实例 R0，而用户 ID 10001到ID 20000 将进入实例 R1 等等。
##散列分区
在这种类型的分区是一个散列函数（例如，模数函数）用于将键转换为数字数据，然后存储在不同的 redis 实例。 

#Redis发布订阅
Redis的pub sub实现了邮件系统，发送者(在 Redis 术语中被称为发布者)发送的邮件，而接收器(用户)接收它们。由该消息传送的链路被称为信道。

Redis客户端可以订阅任何数目的通道。

以下举例说明如何发布用户的概念工作。在下面的例子给出一个客户端订阅一个通道名为redisChat

	redis 127.0.0.1:6379> SUBSCRIBE redisChat
	
	Reading messages... (press Ctrl-C to quit)
	1) "subscribe"
	2) "redisChat"
	3) (integer) 1

现在，两个客户端都发布在同一个通道名redisChat消息及以上的订阅客户端接收消息。

	redis 127.0.0.1:6379> PUBLISH redisChat "Redis is a great caching technique"
	
	(integer) 1
	
	redis 127.0.0.1:6379> PUBLISH redisChat "Learn redis by tutorials point"
	
	(integer) 1
	
	
	1) "message"
	2) "redisChat"
	3) "Redis is a great caching technique"
	1) "message"
	2) "redisChat"
	3) "Learn redis by tutorials point"

##Redis PubSub 命令

如下表所示相关Redis PubSub的一些基本的命令：

	PSUBSCRIBE pattern [pattern ...] 订阅通道匹配给定的模式。
	PUBSUB subcommand [argument [argument ...]] 讲述了PubSub的系统，例如它的客户是活动在服务器上的状态。
	PUBLISH channel message 发布一条消息到通道。
	PUNSUBSCRIBE [pattern [pattern ...]] 停止监听发布到通道匹配给定模式的消息。
	SUBSCRIBE channel [channel ...] 监听发布到指定的通道信息。
	UNSUBSCRIBE [channel [channel ...]] 停止监听发布给定的通道信息。


#Redis脚本
Redis脚本使用Lua解释器用于计算脚本。它Redis从2.6.0版本开始内置。使用脚本eval命令。

eval命令的基本语法如下：

	redis 127.0.0.1:6379> EVAL script numkeys key [key ...] arg [arg ...]

以下举例说明Redis脚本的工作原理：
	
	redis 127.0.0.1:6379> EVAL "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
	
	1) "key1"
	2) "key2"
	3) "first"
	4) "second"

Redis脚本的一些基本命令：

	EVAL script numkeys key [key ...] arg [arg ...] 执行一个Lua脚本。
	EVALSHA sha1 numkeys key [key ...] arg [arg ...] 执行一个Lua脚本。
	SCRIPT EXISTS script [script ...] 检查脚本是否存在于缓存中。
	SCRIPT FLUSH 删除脚本缓存中的所有脚本。
	SCRIPT KILL 终止目前在执行的脚本。
	SCRIPT LOAD script 加载指定的Lua脚本到脚本缓存。
#Redis连接
Redis的连接命令基本上都是用于管理Redis的服务器与客户端连接。


下面的例子说明如何验证自己是否与Redis服务器连接，并检查是否服务器正在运行。
	
	redis 127.0.0.1:6379> AUTH "password"
	OK
	redis 127.0.0.1:6379> PING
	PONG

Redis的连接相关的一些基本命令：

	AUTH password 服务器验证给定的密码
	ECHO message 打印给定的字符串
	PING 检查服务器是否正在运行
	QUIT 关闭当前连接
	SELECT index 更改当前连接所选数据库
#Redis服务器
Redis服务器命令基本上都用于管理Redis服务器。

下面的例子说明了我们可以得到所有关于服务器的统计数据和信息。

	redis 127.0.0.1:6379> INFO
	

##Redis服务器的一些基本的命令：

	BGREWRITEAOF 异步改写仅追加文件
	BGSAVE 异步保存数据集到磁盘
	CLIENT KILL [ip:port] [ID client-id] 杀死一个客户端的连接
	CLIENT LIST 获取客户端连接到服务器的连接列表
	CLIENT GETNAME 获取当前连接的名称
	CLIENT PAUSE timeout 停止指定的时间处理来自客户端的命令
	CLIENT SETNAME connection-name 设置当前连接名称
	CLUSTER SLOTS 获取集群插槽数组节点的映射
	COMMAND 获取Redis的命令的详细信息数组
	COMMAND COUNT 得到的Redis命令的总数
	COMMAND GETKEYS 给予充分的Redis命令提取键
	BGSAVE 异步保存数据集到磁盘
	COMMAND INFO command-name [command-name ...] 获取具体的Redis命令的详细信息数组
	CONFIG GET parameter 获取配置参数的值
	CONFIG REWRITE 重写的存储器配置的配置文件
	CONFIG SET parameter value 配置参数设置为给定值
	CONFIG RESETSTAT 复位信息返回的统计
	DBSIZE 返回所选数据库中的键的数目
	DEBUG OBJECT key 获取有关的一个关键的调试信息
	DEBUG SEGFAULT 使服务器崩溃
	FLUSHALL 从所有数据库中删除所有项
	FLUSHDB 从当前数据库中删除所有项
	INFO [section] 获取有关服务器的信息和统计数据
	LASTSAVE 获得最后成功的UNIX时间时间戳保存到磁盘
	MONITOR 监听由实时服务器接收到的所有请求
	ROLE 返回在复制的情况下实例的角色
	SAVE 同步保存数据集到磁盘
	SHUTDOWN [NOSAVE] [SAVE] 同步的数据集保存到磁盘，然后关闭服务器
	SLAVEOF host port 使服务器为另一个实例的从站或者促进其作为主
	SLOWLOG subcommand [argument] 管理Redis的慢查询日志
	SYNC 命令用于复制
	TIME 返回当前服务器时间



http://doc.redisfans.com/