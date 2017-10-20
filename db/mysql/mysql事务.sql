SELECT @@global.tx_isolation; 
SELECT @@session.tx_isolation; 
SELECT @@tx_isolation;

SET tx_isolation='REPEATABLE-READ';
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;

 SHOW ENGINE INNODB STATUS
 SHOW GLOBAL STATUS LIKE 'Innodb_max_trx_id';
 
 	-- 先查询 INNODB_TRX 表，看看都有哪些事务
	SELECT * FROM INFORMATION_SCHEMA.INNODB_TRX;
	-- 再看 INNODB_LOCKS 表，看看都有什么锁
	SELECT * FROM information_schema.INNODB_LOCKS;
	-- 最后看 INNODB_LOCK_WAITS 表，看看当前都有哪些锁等待
	SELECT * FROM information_schema.INNODB_LOCK_WAITS;
	
	 