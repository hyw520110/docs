#Redis事务
Redis事务让一组命令在单个步骤中执行。
##Redis 事务指令

如下表所示，Redis的事务相关的一些基本命令：

	DISCARD 发出命令MULTI后丢弃所有
	EXEC MULTI后执行发出所有命令
	MULTI 标记事务块的开始
	UNWATCH 取消所有的对应关注键
	WATCH key [key ...] 关注给定项，以确定执行MULTI/EXEC块
以下举例说明Redis的事务如何启动并执行。
	
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


redis的事务处理:

redis事务处理的基础(四个redis指令):MULTI、EXEC、DISCARD、WATCH

1.MULTI用来组装一个事务；

2.EXEC用来执行一个事务；

3.DISCARD用来取消一个事务；

4.WATCH用来监视一些key，一旦这些key在事务执行之前被改变，则取消事务的执行。

	redis> MULTI //标记事务开始
	OK
	redis> INCR user_id //多条命令按顺序入队
	QUEUED
	redis> INCR user_id
	QUEUED
	redis> INCR user_id
	QUEUED
	redis> PING
	QUEUED
	redis> EXEC //执行
	1) (integer) 1
	2) (integer) 2
	3) (integer) 3
	4) PONG
在用MULTI组装事务时，每一个命令都会进入到内存队列中缓存起来，如果出现QUEUED则表示我们这个命令成功插入了缓存队列，在将来执行EXEC时，这些被QUEUED的命令都会被组装成一个事务来执行

对于事务的执行来说，如果redis开启了AOF持久化的话，那么一旦事务被成功执行，事务中的命令就会通过write命令一次性写到磁盘中去，如果在向磁盘中写的过程中恰好出现断电、硬件故障等问题，那么就可能出现只有部分命令进行了AOF持久化，这时AOF文件就会出现不完整的情况，这时，我们可以使用redis-check-aof工具来修复这一问题，这个工具会将AOF文件中不完整的信息移除，确保AOF文件完整可用。

事务经常会遇到的是两类错误：

1.调用EXEC之前的错误
2.调用EXEC之后的错误

“调用EXEC之前的错误”，有可能是由于语法有误导致的，也可能时由于内存不足导致的。只要出现某个命令无法成功写入缓冲队列的情况，redis都会进行记录，在客户端调用EXEC时，redis会拒绝执行这一事务。（这时2.6.5版本之后的策略。在2.6.5之前的版本中，redis会忽略那些入队失败的命令，只执行那些入队成功的命令）。例子：

	127.0.0.1:6379> multi
	OK
	127.0.0.1:6379> haha //一个明显错误的指令
	(error) ERR unknown command 'haha'
	127.0.0.1:6379> ping
	QUEUED
	127.0.0.1:6379> exec
	//redis无情的拒绝了事务的执行，原因是“之前出现了错误”
	(error) EXECABORT Transaction discarded because of previous errors.

而对于“调用EXEC之后的错误”，redis则采取了完全不同的策略，即redis不会理睬这些错误，而是继续向下执行事务中的其他命令。这是因为，对于应用层面的错误，并不是redis自身需要考虑和处理的问题，所以一个事务中如果某一条命令执行失败，并不会影响接下来的其他命令的执行。例子：

	127.0.0.1:6379> multi
	OK
	127.0.0.1:6379> set age 23
	QUEUED
	//age不是集合，所以如下是一条明显错误的指令
	127.0.0.1:6379> sadd age 15
	QUEUED
	127.0.0.1:6379> set age 29
	QUEUED
	127.0.0.1:6379> exec //执行事务时，redis不会理睬第2条指令执行错误
	1) OK
	2) (error) WRONGTYPE Operation against a key holding the wrong kind of value
	3) OK
	127.0.0.1:6379> get age
	"29" //可以看出第3条指令被成功执行了

WATCH”指令，可以实现类似于“乐观锁”的效果，即CAS（check and set）,WATCH本身的作用是“监视key是否被改动过”，而且支持同时监视多个key，只要还没真正触发事务，WATCH都会尽职尽责的监视，一旦发现某个key被修改了，在执行EXEC时就会返回nil，表示事务无法触发。

	127.0.0.1:6379> set age 23
	OK
	127.0.0.1:6379> watch age //开始监视age
	OK
	127.0.0.1:6379> set age 24 //在EXEC之前，age的值被修改了
	OK
	127.0.0.1:6379> multi
	OK
	127.0.0.1:6379> set age 25
	QUEUED
	127.0.0.1:6379> get age
	QUEUED
	127.0.0.1:6379> exec //触发EXEC
	(nil) //事务无法被执行