#java 连接/配置异常：

	 JedisDataException: DENIED Redis is running in protected mode because protected mode is enabled, no bind address was specified, no authentication password is requested to clients. In this mode connections are only accepted from the loopback interface. If you want to connect from external computers to Redis you may adopt one of the following solutions: 1) Just disable protected mode sending the command 'CONFIG SET protected-mode no' from the loopback interface by connecting to Redis from the same host the server is running, however MAKE SURE Redis is not publicly accessible from internet if you do so. Use CONFIG REWRITE to make this change permanent. 2) Alternatively you can just disable the protected mode by editing the Redis configuration file, and setting the protected mode option to 'no', and then restarting the server. 3) If you started the server manually just for testing, restart it with the '--protected-mode no' option. 4) Setup a bind address or an authentication password. NOTE: You only need to do one of the above things in order for the server to start accepting connections from the outside.

解决：
	
- 根据提示内网环境可以关闭protected mode
- 修改redis配置绑定ip/host地址，设置密码



	JedisConnectionException: Could not get a resource from the pool

可能原因：
- redis服务没启动 
- 防火墙
- ip或端口错误
- 连接未释放，查看连接数netstat -apn |grep redis-server
- 连接池MaxWaitMillis设置过低

#redis报错：

	MISCONF Redis is configured to save RDB snapshots, but is currently not able to persist on disk. Commands that may modify the data set are disabled. Please check Redis logs for details about the error．
意思：misconf redis被配置以保存数据库快照，但misconf redis目前不能在硬盘上持久化。用来修改数据集合的命令不能用，请使用日志的错误详细信息。

这是由于强制停止redis快照，不能持久化引起的，运行info命令查看redis快照的状态

	# Persistence
	rdb_last_bgsave_status:err

解决：运行命令

	config set stop-writes-on-bgsave-error no
关闭配置项stop-writes-on-bgsave-error,这仅仅是让程序忽略了这个异常，使得程序能够继续往下运行，但实际上数据还是会存储到硬盘失败！


查看日志，如看到有一行警告提示：

	“WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.”

意思：过量使用内存设置为0！在低内存环境下，后台保存可能失败。为了修正这个问题，请在/etc/sysctl.conf 添加一项 'vm.overcommit_memory = 1' ，然后重启（或者运行命令'sysctl vm.overcommit_memory=1' ）使其生效。
查看日志如看到以下提示：

	Can’t save in background: fork: Cannot allocate memory	
意思是"Fork进程时内存不够用了！"

查看系统内存有空闲内存，Redis会说内存不够呢？

网上查了一下，有人也遇到类似的问题，并且给出了很好的分析（详见：http://www.linuxidc.com/Linux/2012-07/66079.htm），简单地说：Redis在保存数据到硬盘时为了避免主进程假死，需要Fork一份主进程，然后在Fork进程内完成数据保存到硬盘的操作，如果主进程使用了4GB的内存，Fork子进程的时候需要额外的4GB，此时内存就不够了，Fork失败，进而数据保存硬盘也失败了。



Redis VS. Memcached 均不适合数据量高于1千万条，且保证数据完整的key-value存储
http://blog.csdn.net/yumengkk/article/details/7902103