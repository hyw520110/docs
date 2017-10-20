#基于Atlas2.2实现

Ubuntu 12.04.5 LTS
MySQL 5.5.47
Atlas2.2
安装Atlas2.2
	
	wget https://github.com/Qihoo360/Atlas/releases/download/2.2/Atlas-2.2-debian7.0-x86_64.deb
	sudo dpkg -i Atlas-2.2-debian7.0-x86_64.deb
分别在主库从库创建帐号并授权
	
	grant all on *.* to atlas@'192.168.64.%' identified by 'atlas';
	flush privileges;
使用encrypt加密密码
	
	ubuntu@s4:/usr/local/mysql-proxy/bin$ ./encrypt atlas
	KsWNCR6qyNk=
atlas为数据库原始密码，KsWNCR6qyNk=为加密后的密码，该值在配置文件的pwds项中将用到。

修改配置
	
	[mysql-proxy]

	#管理接口的用户名
	admin-username = mysqlproxy
	
	#管理接口的密码
	admin-password = mysqlproxy
	
	#实现管理接口的Lua脚本所在路径
	admin-lua-script = /usr/local/mysql-proxy/lib/mysql-proxy/lua/admin.lua
	
	#Atlas后端连接的MySQL主库的IP和端口，可设置多项，用逗号分隔
	proxy-backend-addresses = 192.168.64.131:3306
	
	#Atlas后端连接的MySQL从库的IP和端口，@后面的数字代表权重，用来作负载均衡，若省略则默认为1，可设置多项，用逗号分隔
	proxy-read-only-backend-addresses = 192.168.64.132:3306@1
	
	#设置Atlas的运行方式，设为true时为守护进程方式，设为false时为前台方式，一般开发调试时设为false，线上运行时设为true
	daemon = true
	
	#设置Atlas的运行方式，设为true时Atlas会启动两个进程，一个为monitor，一个为worker，monitor在worker意外退出后会自动将其重启，设为false时只有worker，没有monitor，一般开发调试时设为false，线上运行时设为true
	keepalive = true
	
	#工作线程数，推荐设置与系统的CPU核数相等
	event-threads = 4
	
	#日志级别，分为message、warning、critical、error、debug五个级别
	log-level = message
	
	#日志存放的路径
	log-path = /usr/local/mysql-proxy/log
	
	#SQL日志的开关，可设置为OFF、ON、REALTIME，OFF代表不记录SQL日志，ON代表记录SQL日志，REALTIME代表记录SQL日志且实时写入磁盘，默认为OFF
	sql-log = REALTIME
	
	#实例名称，用于同一台机器上多个Atlas实例间的区分
	instance = test
	
	#Atlas监听的工作接口IP和端口
	proxy-address = 0.0.0.0:1234
	
	#Atlas监听的管理接口IP和端口
	admin-address = 0.0.0.0:2345
	
	#连接池的最小空闲连接数，应设为event-threads的整数倍，可根据业务请求量大小适当调大或调小
	min-idle-connections = 8
	
	#分表设置，此例中person为库名，mt为表名，id为分表字段，3为子表数量，可设置多项，以逗号分隔，若不分表则不需要设置该项
	#tables = person.mt.id.3
	
	#用户名与其对应的加密过的MySQL密码，密码使用PREFIX/bin目录下的加密程序encrypt加密，此设置项用于多个用户名同时访问同一个Atlas实例的情况，若只有一个用户名则不需要设置该项
	#pwds = user1:+jKsgB3YAG8=, user2:GS+tr4TPgqc=
	#用户名为atlas密码为明文使用encrypt加密后的串 需要分别在主从库中创建该帐号并授权，否则使用atals客户端连接不上
	pwds = atlas:KsWNCR6qyNk=
	
	#默认字符集，若不设置该项，则默认字符集为latin1
	#charset = utf8
	
	#允许连接Atlas的客户端的IP，可以是精确IP，也可以是IP段，以逗号分隔，若不设置该项则允许所有IP连接，否则只允许列表中的IP连接
	#client-ips = 127.0.0.1, 192.168.1
	
	#Atlas前面挂接的LVS的物理网卡的IP(注意不是虚IP)，若有LVS且设置了client-ips则此项必须设置，否则可以不设置
	#lvs-ips = 192.168.1.1

启动Atlas
	
	ubuntu@s4:/usr/local/mysql-proxy/bin$ sudo ./mysql-proxyd test start
	OK: MySQL-Proxy of test is started
	ubuntu@s4:/usr/local/mysql-proxy/bin$ sudo ./mysql-proxyd test stop    #停止
	ubuntu@s4:/usr/local/mysql-proxy/bin$ sudo ./mysql-proxyd test restart #重启
注意：
(1). 运行文件是：mysql-proxyd(不是mysql-proxy)。
(2). test是conf目录下配置文件的名字，也是配置文件里instance项的名字，三者需要统一。

查看Atlas进程

	ps -ef | grep mysql-proxy|grep -v grep

查看Atlas端口

	sudo netstat -ntlp |grep mysql-proxy

其中1234为代理端口，2345为管理端口

连接Atlas管理界面

	ubuntu@s4:/usr/local/mysql-proxy/bin$ mysql -umysqlproxy -pmysqlproxy -h192.168.64.131 -P2345
	select * from help;     
	SELECT * FROM backends;
	可以看到192.168.64.131:3306可读写，192.168.64.132:3306只读

客户端测试

连接atlas代理客户端，插入6条数据，检查能否查询到数据。
	
	mysql -uatlas -patlas -P1234 -h192.168.64.131  
	mysql> show tables;

不使用atlas代理连192.168.64.131，查询数据是否写入

	mysql> select * from t;
发现数据已写入192.168.64.131库中。

不使用atlas代理连192.168.64.132，查询数据是否写入数据
	
	# 查询132是否有数据存在，若不存在则证明使用atlas代理连接查询数据读的是132上的数据
	mysql> select * from t;
	# 插入4条数据
	mysql> insert into t values(7);
	Query OK, 1 row affected (0.02 sec)
	
	mysql> insert into t values(8);
	Query OK, 1 row affected (0.00 sec)
	
	mysql> insert into t values(9);
	Query OK, 1 row affected (0.00 sec)
	
	mysql> insert into t values(10);
	Query OK, 1 row affected (0.00 sec)
	
	mysql> select * from t;

不使用atlas代理连192.168.64.131，查询数据是否写入

	mysql> select * from t;

数据确实再次写入到131中至此证明atlas数据读写分离成功。

通过日志也可以观察到数据读写分离情况

	ubuntu@s4:/usr/local/mysql-proxy/bin$ sudo tail -f ../log/sql_test.log 
可见所有的查询操作在132上。增、删、改操作在131上。

参考文档

http://blog.itpub.net/27000195/viewspace-1421262/



#基于mysql-proxy实现

下载解压

	wget http://mirror.bit.edu.cn/mysql/Downloads/MySQL-Proxy/mysql-proxy-0.8.4-linux-glibc2.3-x86-64bit.tar.gz
	tar zxvf mysql-proxy-0.8.4-linux-glibc2.3-x86-64bit.tar.gz

创建mysql-proxy帐号并授权

分别在主从数据库中创建mysqlproxy帐号
	
	mysql> grant all on *.* to mysqlproxy@'192.168.64.%' identified by 'mysqlproxy';
	mysql> flush privileges;
	mysql> use mysql;
	mysql> select User,Password,Host from user;

启动mysql-proxy
	
	sudo ./mysql-proxy \
	--daemon \
	--log-level=debug \
	--keepalive \
	--log-file=/var/log/mysql-proxy.log \
	--plugins="proxy" \
	--proxy-backend-addresses="192.168.64.131:3306" \
	--proxy-read-only-backend-addresses="192.168.64.132:3306" \
	--proxy-lua-script="/home/ubuntu/apps/mysql-proxy-0.8.4/share/doc/mysql-proxy/rw-splitting.lua" \
	--plugins="admin" \
	--admin-username="admin" \
	--admin-password="admin" \
	--admin-lua-script="/home/ubuntu/apps/mysql-proxy-0.8.4/lib/mysql-proxy/lua/admin.lua"

查看mysql-proxy进程

	ubuntu@s4:~/apps/mysql-proxy-0.8.4/bin$ ps -ef | grep mysql-proxy


查看mysql-proxy端口

	ubuntu@s4:~/apps/mysql-proxy-0.8.4/bin$ sudo netstat -ntlp | grep mysql-proxy

4040是proxy端口，4041是admin端口

连接管理端口

	mysql> mysql -uadmin -padmin -h192.168.64.131 -P4041 连接管理端口

具体如下

	ubuntu@s4:~/apps/mysql-proxy-0.8.4/bin$ mysql -uadmin -padmin -h192.168.64.131 -P4041

	mysql> show databases;
	mysql> SELECT * FROM help;
	mysql> SELECT * FROM backends;

多开几个客户端后其状态变为

	  SELECT * FROM backends;

state都为up表正常

连接同步端口

	mysql> mysql -umysqlproxy -pmysqlproxy -h192.168.64.131 -P4040 

多开启几个同步端口，在同步端口连接的客户端中插入和查询数据，观察读写分离。

结论：192.168.64.131:3306只写，192.168.64.132:3306只读。

操作演示

不使用proxy连接数据库，查询192.168.64.131:3306上的数据

	mysql> select * from zhang;

不使用proxy连接数据库，查询192.168.64.132:3306上的数据

	mysql> select * from zhang;

使用proxy连接数据库，执行查询和插入操作

	ubuntu@s4:~/apps$ mysql -umysqlproxy -pmysqlproxy -h192.168.64.131 -P4040

	mysql> use crm;
	
	mysql> select * from zhang;
	
	# 此处数据为192.168.64.132:3306中的数据
	
	mysql> insert into zhang values('8','zhang','this_is_master');
	
	# 该数据将插入192.168.64.131:3306数据库中
	
	mysql> select * from zhang;
	# 该数据仍来自192.168.64.132:3306中数据

不使用proxy连接192.168.64.131:3306观察数据是否插入

	mysql> select * from zhang; 

由此可见使用mysql-proxy读写分离成功。

参考文档

	http://blog.itpub.net/22039464/viewspace-1708258/
