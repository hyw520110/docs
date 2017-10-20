BoneCP配置文件格式(bonecp-config.xml)： 
	
	<?xml version="1.0" encoding="UTF-8"?>  
    <bonecp-config>  
      <default-config>  
        <!-- ... -->  
        <property name="...">...</property>  
      </default-config>   
    </bonecp-config>   

BoneCP主要配置参数
1.jdbcUrl 设置数据库URL

2.username 设置数据库用户名

3.password 设置数据库密码

4.partitionCount

设置分区个数。这个参数默认为1，建议3-4（根据特定应用程序而定）。
为了减少锁竞争和改善性能，从当前线程分区(thread-affinity)中获取一个connection，
也就是这个样子：partitions[Thread.currentThread().getId() % partitionCount]。当拥有充足的短期(short-lived)的线程时候，这个参数设置越大，性能越好。当超过一定的阀值时，连接池的维护工作就可能对性能造成一定的负面影响（仅当分区上的connection使用耗尽时）。

5.maxConnectionsPerPartition
设置每个分区含有connection最大个数。这个参数默认为2。如果小于2，BoneCP将设置为50。
比如：partitionCount设置为3，maxConnectionPerPartition设置为5，你就会拥有总共15个connection。
注意：BoneCP不会将这些connection一起创建出来，而是说在需要更多connection的时候从minConnectionsPerPartition参数开始逐步地增长connection数量。

6.minConnectionsPerPartition
设置每个分区含有connection最大小个数。这个参数默认为0。

7.acquireIncrement
设置分区中的connection增长数量。这个参数默认为1。
当每个分区中的connection大约快用完时，BoneCP动态批量创建connection，
这个属性控制一起创建多少个connection（不会大于maxConnectionsPerPartition）。
注意：这个配置属于每个分区的设置。

8.poolAvailabilityThreshold
设置连接池阀值。这个参数默认为20。如果小于0或是大于100，BoneCP将设置为20。
连接池观察线程(PoolWatchThread)试图为每个分区维护一定数量的可用connection。
这个数量趋于maxConnectionPerPartition和minConnectionPerPartition之间。这个参数是以百分比的形式来计算的。例如：设置为20，下面的条件如果成立：Free Connections / MaxConnections < poolAvailabilityThreshold；就会创建出新的connection。
换句话来说连接池为每个分区至少维持20%数量的可用connection。
设置为0时，每当需要connection的时候，连接池就要重新创建新connection，这个时候可能导致应用程序可能会为了获得新connection而小等一会。

9.connectionTimeout
设置获取connection超时的时间。这个参数默认为Long.MAX_VALUE;单位：毫秒。
在调用getConnection获取connection时，获取时间超过了这个参数，就视为超时并报异常。

三、BoneCP线程配置参数

1.releaseHelperThreads
设置connection助手线程个数。这个参数默认为3。如果小于0，BoneCP将设置为3。
设置为0时，应用程序线程被阻塞，直到连接池执行必要地清除和回收connection，并使connection在其它线程可用。
设置大于0时，连接池在每个分区中创建助手线程处理回收关闭后的connection（应用程序会通过助手线程异步地将这个connection放置到一个临时队列中进行处理)。
对于应用程序在每个connection上处理大量工作时非常有用。可能会降低运行速度，不过在高并发的应用中会提高性能。

2.statementReleaseHelperThreads
设置statement助手线程个数。这个参数默认为3。如果小于0，BoneCP将设置为3。
设置为0时，应用程序线程被阻塞，直到连接池或JDBC驱动程序关闭statement。
设置大于0时，连接池会在每个分区中创建助理线程，异步地帮助应用程序关闭statement当应用程序打开了大量的statement是非常有用的。可能会降低运行速度，不过在高并发的应用中会提高性能。

3.maxConnectionAge
设置connection的存活时间。这个参数默认为0，单位：毫秒。设置为0该功能失效。
通过ConnectionMaxAgeThread观察每个分区中的connection，不管connection是否空闲，如果这个connection距离创建的时间大于这个参数就会被清除。当前正在使用的connection不受影响，直到返回到连接池再做处理。

4.idleMaxAge
设置connection的空闲存活时间。这个参数默认为60，单位：分钟。设置为0该功能失效。
通过ConnectionTesterThread观察每个分区中的connection，如果这个connection距离最后使用的时间大于这个参数就会被清除。
注意：这个参数仅和idleConnectionTestPeriod搭配使用，而且不要在这里设置任何挑衅的参数！

5.idleConnectionTestPeriod
设置测试connection的间隔时间。这个参数默认为240，单位：分钟。设置为0该功能失效。
通过ConnectionTesterThread观察每个分区中的connection， 如果这个connection距离最后使用的时间大于这个参数并且距离上一次测试的时间大于这个参数就会向数据库发送一条测试语句，如果执行失败则将这个connection清除。
注意：这个值仅和idleMaxAge搭配使用，而且不要在这里设置任何挑衅的参数！

三、BoneCP可选配置参数

1.acquireRetryAttempts
设置重新获取连接的次数。这个参数默认为5。
获取某个connection失败之后会多次尝试重新连接，如果在这几次还是失败则放弃。

2.acquireRetryDelay
设置重新获取连接的次数间隔时间。这个参数默认为7000，单位：毫秒。如果小于等于0，BoneCP将设置为1000。
获取connection失败之后再次尝试获取connection的间隔时间。

3.lazyInit
设置连接池初始化功能。这个参数默认为false。
设置为true，连接池将会初始化为空，直到获取第一个connection。

4.statementsCacheSize
设置statement缓存个数。这个参数默认为0。

5.disableJMX
设置是否关闭JMX功能。这个参数默认为false。

6.poolName
设置连接池名字。用于当作JMX和助手线程名字的后缀。

四、BoneCP调试配置参数

1.closeConnectionWatch
设置是开启connection关闭情况监视器功能。这个参数默认为false。
每当调用getConnection()时，都会创建CloseThreadMonitor，监视connection有没有关闭或是关闭了两次。警告：这个参数对连接池性能有很大的负面影响，慎用！仅在调试阶段使用！

2.closeConnectionWatchTimeout
设置关闭connection监视器（CloseThreadMonitor）持续多长时间。这个参数默认为0；单位：毫秒。仅当closeConnectionWatch参数设置为可用时，设置这个参数才会起作用。
设置为0时，永远不关闭。

3.logStatementsEnabled
设置是否开启记录SQL语句功能。这个参数默认是false。
将执行的SQL记录到日志里面（包括参数值）。

4.queryExecuteTimeLimit
设置执行SQL的超时时间。这个参数默认为0；单位：毫秒。
当查询语句执行的时间超过这个参数，执行的情况就会被记录到日志中。
设置为0时，该功能失效。

5.disableConnectionTracking
设置是否关闭connection跟踪功能。这个参数默认为false。
设置为true，连接池则不会监控connection是否严格的关闭；设置为false，则启用跟踪功能（仅追踪通过Spring或一些事务管理等机制确保正确释放connection并放回到连接池中）。

6.transactionRecoveryEnabled
设置事务回放功能。这个参数默认为false。
设置为true时，MemorizeTransactionProxy可以记录所有在connection上操作的情况，当connetion操作失败的时候会自动回放先前的操作，如果在回放期间还是失败，则抛出异常。注意：这个功能会使连接池微弱地降低运行速度。 