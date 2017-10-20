 用户可以用SET TRANSACTION语句改变单个会话或者所有新进连接的隔离级别。它的语法如下：

	SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL {READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE}
注意：默认的行为（不带session和global）是为下一个（未开始）事务设置隔离级别。如果你使用GLOBAL关键字，语句在全局对从那点开始创建的所有新连接（除了不存在的连接）设置默认事务级别。你需要SUPER权限来做这个。使用SESSION关键字为将来在当前连接上执行的事务设置默认事务级别。

可以用下列语句查询全局和会话事务隔离级别：

	SELECT @@global.tx_isolation; 
	SELECT @@session.tx_isolation; 
	SELECT @@tx_isolation;
设置事务隔离级别：
	
	修改mysql.ini配置文件：transaction-isolation = REPEATABLE-READ
	或
	SET tx_isolation='REPEATABLE-READ';
	或
	set global transaction isolation level REPEATABLE READ;  
	set session transaction isolation level REPEATABLEREAD; 




在个别时候可能需要查看当前最新的事务ID，以便做一些业务逻辑上的判断（例如利用事务ID变化以及前后时差，统计每次事务的响应时长等用途）。

通常地，我们有两种方法可以查看当前的事务ID：

1、执行SHOW ENGINE INNODB STATUS，查看事务相关信息

2、查看INFORMATION_SCHEMA.INNODB_TRX、INNODB_LOCKS、INNODB_LOCK_WAITS 三个表，通过这些信息能快速发现哪些事务在阻塞其他事务

	-- 先查询 INNODB_TRX 表，看看都有哪些事务
	SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;
	-- 再看 INNODB_LOCKS 表，看看都有什么锁
	SELECT * FROM information_schema.INNODB_LOCKS;
	-- 最后看 INNODB_LOCK_WAITS 表，看看当前都有哪些锁等待
	SELECT * FROM information_schema.INNODB_LOCK_WAITS;

3、利用percona分支的特性，查看当前最新事务ID，该特性从5.6.11-60.3版本开始引入，执行下面的2个命令：

	mysqladmin ext | grep Innodb_max_trx_id
	或者
	mysql> show global status like 'Innodb_max_trx_id';
	