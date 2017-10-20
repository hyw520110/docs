https://docs.mongodb.com/manual/reference/configuration-options/

mongodb的管理主要有4个方面：

1．  安装部署

2．  状态监控

3．  安全认证

4．  备份和恢复，

一：安装部署

在mongodb里面提供了一个叫做“服务寄宿”的模式
	
	mongod --dbpath=xxx --logpath=xxx --port 2222 --install
	net start mongodb

查看命令帮助：

	mongod --help
	mongo --help

二：状态监控

监控可以让我们实时的了解数据库的健康状况以及性能调优，在mongodb里面给我们提供了三种方式。

1、http监视器，端口默认为服务端口+1000，如默认端口为27017，则http服务端口为28017

2、serverStatus()

这个函数可以获取到mongodb的服务器统计信息，其中包括 ：全局锁，索引，用户操作行为等等这些统计信息，对管理员来说非常重要，具体的参数含义可以参考：

	http://www.cnblogs.com/xuegang/archive/2011/10/13/2210339.html
3、mongostat命令

前面那些统计信息都是静态统计，不能让我观看实时数据变化，mongodb里面提供了mongodstat监视器，每秒刷新获取mongodb的当前运行状态，并输出。如果你发现数据库突然变慢或者有其他问题的话，你第一手的操作就考虑采用mongostat来查看mongo的状态。

4、mongotop也是mongodb下的一个内置工具，mongotop提供了一个方法，用来跟踪一个MongoDB的实例，查看哪些大量的时间花费在读取和写入数据。 mongotop提供每个集合的水平的统计数据。默认情况下，mongotop返回值的每一秒。

可以指定<sleeptime>参数，等待的时间长度，以秒为单位.如mongotop 10
![image](http://i.imgur.com/q0NB3Ts.png)
输出结果字段说明：

ns：包含数据库命名空间，后者结合了数据库名称和集合。


报告每个数据库的锁的使用中，使用mongotop --locks ,这将产生以下输出：
![image](http://i.imgur.com/zzXpGgw.png)

输出结果字段说明：

- ns：包含数据库命名空间，后者结合了数据库名称和集合。
- db：包含数据库的名称。名为 . 的数据库针对全局锁定，而非特定数据库。
- total：mongod花费的时间工作在这个命名空间提供总额。
- read：提供这个命名空间进行读操作，这mongod花费在执行读操作，在此命名空间。
- write：提供这个命名空间进行写操作，这mongod花了大量的时间。

三: 安全认证

作为数据库软件，我们肯定不想谁都可以访问，为了确保数据的安全，mongodb也会像其他的数据库软件一样可以采用用户验证的方法，那么该怎么做呢？其实很简单，mongodb提供了addUser方法，还有一个注意点就是如果在admin数据库中添加将会被视为“超级管理员”。mongodb3.xaddUser方法变为createUser方法

添加好用户、认证之后使用--reinstall重启服务并以--auth验证模式登陆

	mongod --dbpath=xxx --logpath=xxx --port 2222 --auth --reinstall
	net start mongodb

四：备份和恢复

mongodb备份常用手段有3种。

1： 直接copy

这个算是最简单的了，不过要注意一点，在服务器运行的情况下直接copy是很有风险的，可能copy出来时，数据已经遭到破坏，唯一能保证的就是要暂时关闭下服务器，copy完后重开。

2：mongodump和mongorestore

使用mongodump命令来备份MongoDB数据。该命令可以导出所有数据到指定目录中。

mongodump命令可以通过参数指定导出的数据量级转存的服务器。

mongodump命令脚本语法如下：

	mongodump -h dbhost -d dbname -o dbdirectory
- -h：MongDB所在服务器地址，例如：127.0.0.1，当然也可以指定端口号：127.0.0.1:27017
- -d：需要备份的数据库实例，例如：test
- -o：备份的数据存放位置，例如：c:\data\dump，当然该目录需要提前建立，在备份完成后，系统自动在dump目录下建立一个test目录，这个目录里面存放该数据库实例的备份数据。


这个是mongo给我们提供的内置工具，很好用，能保证在不关闭服务器的情况下copy数据。为了操作方便，我们先删除授权用户。
	/*登陆执行 */
	db.system.users.find()
	db.system.users.remove({})
	/*  备份test数据库到d:\backup目录.(cmd进入mongodb的bin目录下执行) */
	mongodump --port 2222 -d test -o d:\backup
	/* 恢复test数据库 drop选项恢复前先删除原有数据 */
	mongorestore --port 2222 -d test --drop d:\backup
	/* 备份指定数据库的集合 */		
	mongodump --collection mycol --db test

前面2种方法都不能保证数据的实时性。因为在备份的时候可能还有数据灌在内存中不出来，mongodb提供fsync+lock机制把数据暴力的刷到硬盘上，fsync+lock首先会把缓冲区数据暴力刷入硬盘，然后给数据库一个写入锁，其他实例的写入操作全部被阻塞，直到fsync+lock释放锁为止。

	加锁：db.runCommand({"fsync":1,"lock":1})
	释放锁:db.$cmd.unlock.findOne()

数据恢复

mongodb使用 mongorestore 命令来恢复备份的数据。

mongorestore命令脚本语法如下：
	
	mongorestore -h dbhost -d dbname --directoryperdb dbdirectory

- -h：MongoDB所在服务器地址
- -d：需要恢复的数据库实例，例如：test，当然这个名称也可以和备份时候的不一样
- --directoryperdb：备份数据所在位置
- --drop：恢复的时候，先删除当前数据，然后恢复备份的数据,慎用哦！	