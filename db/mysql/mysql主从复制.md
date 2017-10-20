主从复制：

首先必须开启master库的bin-log，因为MySQL的主从复制是异步的，所以master库必须将更新操作记录下来以供slave库读取。 

主服务器：修改my.ini 设置日志等配置重启

	#MySQL日志包括错误日志(ErrorLog),更新日志(UpdateLog老版本，已经被二进制日志替代)，二进制日志(Binlog)，查询日志(QueryLog)，慢查询日志(SlowQueryLog)等。
	#可以用于实时的还原和复制(slave会基于此log-bin来做replication,确保此文件可写)
	log-bin=mysql-bin.log
	#MySQL复制的几种模式,从 MySQL5.1.12开始,可以用:基于SQL语句的复制(statement-based replication, SBR)，基于行的复制(row-based replication, RBR)，混合模式复制(mixed-based replication, MBR)。
	#相应地，binlog的格式也有三种：STATEMENT，ROW，MIXED.也可运行时修改.
	#binlog_format=ROW
	#如果同时为从服务器，除了打开log-bin外,还需要打开log-slave-updates选项，你可以再B上使用“show variables like 'log%';”来确认是否已经生效。
	#master主机标示，整数，必须唯一，一般配置ip最后一段 
	server-id=63
	#可配
	#N次事务提交之后，进行磁盘同步指令,将binlog_cache中的数据强制写入磁盘.默认0性能最好，但安全风险也最大
	sync_binlog=1 
	log-error=err.log
	#对所有执行语句进行记录
	log=default.log
	#参数缺省0，不允许function同步
	log_bin_trust_function_creators=1
	#将查询返回较慢的语句进行记录
	log-slow-queries=slow.log
	#执行超过多久的sql会被log下来 ,单位秒.mysql5.1开始为微秒
	long_query_time =1
	
	
	#选配
	#必须先开启bin-log
	#log-update=update.log
	#没有使用索引的query
	log-queries-not-using-indexes = nouseindex.log
	log-warnings=2
	#自动清理,或用show slave status命令确认一下相关日志是否已经无用后手动删除(PURGE MASTER LOGS BEFORE DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY); )。
	#运行时修改show binary logs;(MASTER和BINARY是同义词)show variables like '%log%'; set global expire_logs_days = 10; 
	expire_logs_days=10
	
	#主机，读写都可以
	read-only=0
	#用于master-slave,需要进行同步的数据库，多个写多行,全部库都同步可不填,建议填写以尽量减少master到slave的binlog网络流量和线程io量，从而改善slave的数据延时
	binlog-do-db=svnManager 
	#不需要同步的数据库
	binlog-ignore-db=test
	#是否在transaction提交时对日志文件进行flush操作，参数对于InnoDB存储引擎写入操作的性能有重大影响.参数默认值1是最安全的选项，但也是性能最差的选项
	#0不会把log buffer的数据写入到日志文件，也不对日志文件进行flush操作。这是很不安全的。MySQL程序或者操作系统崩溃后，最后一秒钟的交易数据就会丢失
	#1把log buffer的数据写入到日志文件，并对日志文件进行flush操作。只要磁盘不损坏，即使MySQL程序或者操作系统崩溃，都不会丢失任何交易数据
	#2把log buffer的数据写入到日志文件，但并不对日志文件进行flush操作。当MySQL程序崩溃，交易数据并不会丢失，但当操作系统崩溃时，就会丢失最后一秒钟的交易数据。
	innodb_flush_log_at_trx_commit=2 
	#缓存innodb表的索引，数据，插入数据时的缓冲,系统可用内存的70%-80%,设置过大或导致系统变慢降低sql查询效率.
	innodb_buffer_pool_size=512M
	#默认值是空值，在这种设置下是可以允许一些非法操作的
	#STRICT_TRANS_TABLES在该模式下，如果一个值不能插入到一个事务表中，则中断当前的操作，对非事务表不做限制
	#NO_ZERO_IN_DATE在严格模式下，不允许日期和月份为零
	sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO
	lower_case_table_names=1






添加专门用于replication的用户

	CREATE USER admin IDENTIFIED BY 'admin';  
	GRANT FILE,SELECT,REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO admin@192.168.2.63 IDENTIFIED BY 'admin'; 
	--GRANT ALL PRIVILEGES ON *.* TO 'admin'@'192.168.18.20' ; 
	FLUSH PRIVILEGES;
	show grants for 'admin'
重启mysql

	net stop mysql;
	net start mysql

查看master状态(当前bin-log的文件名和偏移量)：
	
	SHOW MASTER STATUS;
记录下 FILE 及 Position 的值

说明：查询结果为空,执行SHOW VARIABLES LIKE '%log_bin%' 查询为off，说明日志信息没有设置,设置log-bin参数配置

锁表
	
	flush tables with read lock; 
使用mysqldump命令创建一个数据快照：

	mysqldump -uroot -p  --all-databases  --triggers --routines  >databases.sql
	-- mysqldump -uroot -p -A>all.sql
备注：
	
如果是MYISAM或者既有MYISAM又有INNODB的话就在主服务器上使用如下命令导出服务器的一个快照：

	mysqldump -uroot -p --lock-tables --events --triggers --routines --flush-logs --master-data=2 --databases test > db.sql
	试过只有INNODB的话就是用如下命令：
	mysqldump -uroot -p --single-transaction --events --triggers --routines --flush-logs --master-data=2 --databases test > db.sql
	这里需要注意几个参数的使用：
	--single-transaction 这个参数只对innodb适用。
	--databases 后面跟除mysql以后的其他所有数据库的库名，我这里只有一个test库。
	--master-data 参数会记录导出快照时候的mysql二进制日志位置，一会会用到。

解锁

	unlock tables;


从服务器：修改mysql.ini

	server-id=20
	log_bin=mysql-bin.log
	log-error=err.log
	#版本允许最好打开sync_binlog选项
	sync_binlog=1
	
	#选配项
	#如果从服务器发现主服务器断掉，重新连接的时间差(秒)
	#master-connect-retry=5
	#设定需要复制的数据库（Schema）
	#replicate_do_db
	
	#没有使用replicate-do-db或者replicate-ignore-db来过滤需要同步的数据库和不需要同步的数据库。原因：能同步所有跨数据库的更新；增加其他数据库同步不需要重启
	replicate-wild-ignore-table=mysql.%
	#这个有需要可以开启
	#log-slave-updates  
	#最好在从服务器的my.cnf里设置read_only选项
	slave-skip-errors=all
	#slave-skip-errors=1062
	slave-net-timeout=60
	#对所有执行语句进行记录
	log=mysql.log

登陆mysql
	
	mysql -uroot -p -h127.0.0.1 -P3306 < databases.sql
	mysql -uroot -p

-- stop slave;
	change master to master_host='192.168.2.210',master_port=3306,master_user='root',master_password='goldensoft',master_log_file='mysql-bin.000007',master_log_pos=349061;
正确执行后启动Slave同步进程

	start slave;
主从同步检查

	show slave status\G
其中Slave_IO_Running 与 Slave_SQL_Running 的值都必须为YES，才表明状态正常。

Slave_SQL_Running:no原因：

1.程序可能在slave上进行了写操作 
2.也可能是slave机器重起后，事务回滚造成的.
解决办法I：首先停掉Slave服务：slave stop;然后到主服务器上查看主机状态：记录File和Position对应的值。最后到从服务器上执行change master to...
解决办法II：

	 slave stop;
	 set GLOBAL SQL_SLAVE_SKIP_COUNTER=1;
	 slave start;
解决办法III:以上两种办法无效的情况下，在主服务器上导出数据库导入到从服务器上
 
测试主从复制

在主数据库创建数据库
	
	mysql>create database db1;
在从数据库查看数据库,显示db1复制正常

	mysql> show databases;


其他备忘命令：

	STOP SLAVE IO_THREAD;    #停止IO进程
	STOP SLAVE SQL_THREAD;    #停止SQL进程
	STOP SLAVE;                 #停止IO和SQL进程
	load data from master;
重置MYSQL同步

	RESET SLAVE;

读写分离

目前读写分离有两种方案：

1、控制应用程序，写操作连接主库，读操作连接从库。
2、引入数据库中间件。如官方的mysql-proxy。好处是读写分离对应用程序完全透明，不需要对程序代码做任何修改。但是目前mysql-proxy依然只有alpha版本，并且官方也不推荐将其用在生产环境中。

其实对于方案一还有一个比较优雅的解决方案，那就是使用ReplicationDriver。MySQL的JDBC驱动中自带ReplicationDriver，它可以将JDBC中所有conn.setReadOnly(true)的连接路由到从库中，从而使得我们不必对程序代码动大手术。 配合Spring, 我们可以使用@Transactional(readOnly = true)注解。因为MySQL主从复制有延迟，所以对于实时性要求高的操作，我们可以将readOnly设为false来让ReplicationDriver从主库中读取数据，这也是一种可以接受的方案。

配置示例：

	<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">
	    <property name="driverClassName" value="com.mysql.jdbc.ReplicationDriver" />
	    <property name="url" value="jdbc:mysql:replication://主库IP:3306,从库IP:3306/test" />
	    <property name="username" value="root" />
	    <property name="password" value="root" />
	    </bean>


mysql proxy 下载地址：
http://mysql.cdpa.nsysu.edu.tw/Downloads/MySQL-Proxy/
在线文档：
http://dev.mysql.com/doc/refman/5.1/en/mysql-proxy.html


下载解压，配置环境变量
安装服务：
http://dev.mysql.com/doc/refman/5.1/en/mysql-proxy-configuration-windows.html

sc create "Proxy" DisplayName= "MySQL Proxy" start= "auto"   binPath= "D:\Java\mysql-proxy-0.8.4-win32-x86\bin\mysql-proxy-svc.exe --defaults-file=D:\Java\mysql-proxy-0.8.4-win32-x86\mysql-proxy.cnf"
net start proxy

mysql proxy配置文档：http://dev.mysql.com/doc/refman/5.1/en/mysql-proxy-configuration.html

典型案例：
@echo off
set host1=192.168.2.210:3306
set host2=192.168.2.63:3307

1、
echo 代理%host%单个数据库服务器,代理服务端口4040
mysql-proxy  ---proxy-backend-addresses=%host1%

2、
echo 代理多个数据库服务器，其中一台(%host1%)停止服务自动连接下一台(%host2%)
mysql-proxy --proxy-backend-addresses=%host1% --proxy-backend-addresses=%host2%

3、
echo 数据库读写分离，%host1%写入,%host2%负责读取数据
mysql-proxy --proxy-backend-addresses=%host1% --proxy-read-only-backend-addresses=192.168.18.107:3306 -–proxy-lua-script=../lua/rw-splitting.lua

说明：--proxy-read-only-backend-addresses不能区分哪些是发往从服务器的，还需要自己用脚本控制–proxy-lua-script
Lua 脚本能很好的控制连接和分布, 以及查询及返回的结果集.
连接代理服务器时乱码，mysql server必须设置
[mysqld]
skip-character-set-client-handshake
init-connect=’SET NAMES utf8′
default-character-set=utf8