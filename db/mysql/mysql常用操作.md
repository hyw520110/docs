#安装：

从官网下载解压版,解压缩，在根目录下复制my-default.ini 为my.ini，在my.ini文件中，加入：

	
	[mysqld]	
	basedir = D:/Java/mysql-5.7.17-winx64
	datadir = e:/mysql-data
	port = 3306	
	log-error=e:/mysql-data/mysql-error.log	
	sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 

注意：

以上配置中的目录需手动创建 

WIN7及以上版本,一定要用管理员身份,cmd进入bin目录执行以下命令

初始化mysql目录，生成无密码的root用户

	 mysqld --initialize --user=mysql --console 
拷贝数据库的初始密码

安装服务

	mysqld --install MySQL
启动mysql

	mysqld --standalone --console
	or
	net start mysql

登录

	mysql -uroot -p   
粘贴密码,进入mysql控制台

修改密码

	SET PASSWORD = PASSWORD('123456'); 

查看错误控制台或日志文件，如提示警告(可忽略)：

	TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp se
加入：
	
	[mysqld]
	explicit_defaults_for_timestamp=true
	




修改root用户密码：

	use mysql	
	update user set authentication_string= password ('123456') WHERE user='root';
	FLUSH PRIVILEGES;
输入quit;退出mysql控制台，去掉my.ini文件中skip-grant-tables(如有)，重新启动mysql，现在就可以用root和你的新密码登录了。

密码不过期配置：在my.ini 中加入：default_password_lifetime=0   ，设置为：0  表示密码永不过期

创建用户

	create user admin identified by 'admin';

分配权限

	grant all on test.*  to 'root'@'localhost' indentified by '123456' with grant option;
	grant all on test.*  to 'root'@'127.0.0.1' indentified by '123456' with grant option;
	or
	GRANT ALL PRIVILEGES ON test.* TO root @'%' IDENTIFIED BY '123456';

	flush privileges; 
	
	 
常见错误：
	
	ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
	执行：SET PASSWORD = PASSWORD('heyiwu');
查看系统变量：

	SHOW VARIABLES;

系统的统计报告：

	SHOW STATUS;
	或cmd下执行：
	mysqladmin  variables
	mysqladmin extended-status
	有用户名密码时，需添加用户信息参数-uuser -ppassword
	
校对规则：

	SHOW COLLATION 指令来查看数据库支持的校对规则
	大小写敏感（latin1_general_cs）和不敏感（latin1_general_ci）是两种校对规则

mysql设置编码命令

	SET character_set_client = utf8;
	SET character_set_connection = utf8;
	SET character_set_database = utf8;
	SET character_set_results = utf8;
	SET character_set_server = utf8;
	
	SET collation_connection = utf8_bin;
	SET collation_database = utf8_bin;
	SET collation_server = utf8_bin;

my.ini中配置默认编码

	default-character-set=utf8
连接数据库设置编码

	jdbc:mysql://192.168.0.5:3306/test?characterEncoding=utf8
	java中的常用编码UTF-8;GBK;GB2312;ISO-8859-1;
	对应mysql数据库中的编码utf8;gbk;gb2312;latin1

查看帮助：

	mysqld  --verbose --help
安装服务：
	
	mysqld  --install MySQL --defaults-file=D:\Java\mysql-5.7.17-winx64\my.ini
卸载服务：

	mysqld --remove MySQL
	或sc delete MySQL

修改密码：
	
	mysqladmin -uroot -p password <新密码>
查看当前用户：

	select current_user();



生产批量删除表的语句：

	SELECT CONCAT( 'drop table IF EXISTS ', table_name, ';' ) 
	FROM information_schema.tables  WHERE table_name LIKE 'act_%';

