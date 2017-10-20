7.5 优化 MySQL 服务器

7.5.1 调整系统因素及启动参数

我们从系统级别的因素开始说起，因为有些方面的因素必须尽早决定才能取得较大性能改进。其他情况下，只需要快速看一下本章节即可。不过，在这个级别看看能做什么以取得更高性能更合适。
使用默认的操作系统这很重要。想要最有效地使用多CPU机器，就使用Solaris(因为它的线程实现确实很好)或Linux(因为2.2的内核对SMP有良好的支持)。请注意，老版本的Linux内核默认会有2GB文件大小限制。如果使用这样的内核而文件又确实需要大于2GB，那么就必须对ext2文件系统打大文件支持(LFS)补丁。其他文件系统诸如 ReiserFS 和 XFS 则没有这个限制。
在MySQL投入生产之前，我们建议你在欲使用的平台上先做一下测试。

其他tips：


如果有足够的RAM(随机存储器)，则应该去掉所有的交换设备。有些操作系统在一些情景中尽管有剩余内存也会使用交换设备。
使用MySQL选项 --skip-external-locking 来避免外部锁。从MySQL 4.0开始，这个选项默认是打开的。在这之前，只有编译支持
MIT-pthreads 才能默认打开，因为在所有平台上的MIT-pthreads 不能全部都支持 flock()。这在Linux上也是默认打开的，因为Linux的文件锁还不安全。注意，--skip-external-locking 选项在服务器运行时并不会影响其功能性。只要记住在运行
myisamchk 前要关闭服务器(或者锁定并且刷新相关数据表)。在一些操作系统上这个选项是强制的，因为外部锁在任何情况下都无法使用。不能使用 --skip-external-locking 选项的唯一情况是：在同一个数据上运行多个MySQL服务器(不是客户端)，或者运行
myisamchk 检查(不是修复)数据表前没有先告诉服务器要刷新并且锁定该表。使用 --skip-external-locking 选项后依旧可以使用 LOCK TABLES 和 UNLOCK TABLES 语句。
7.5.2 调整服务器参数

可以使用以下 mysqld 命令(在MySQL 4.1以前，忽略 --verbose)来确定默认的缓冲大小：

shell> mysqld --verbose --help
这个命令产生了所有的 mysqld 选项以及可以配置的系统变量列表。结果中包括默认值，看起来像是如下：

back_log                 current value: 5
bdb_cache_size           current value: 1048540
binlog_cache_size        current value: 32768
connect_timeout          current value: 5
delayed_insert_limit     current value: 100
delayed_insert_timeout   current value: 300
delayed_queue_size       current value: 1000
flush_time               current value: 0
interactive_timeout      current value: 28800
join_buffer_size         current value: 131072
key_buffer_size          current value: 1048540
long_query_time          current value: 10
lower_case_table_names   current value: 0
max_allowed_packet       current value: 1048576
max_binlog_cache_size    current value: 4294967295
max_connect_errors       current value: 10
max_connections          current value: 100
max_delayed_threads      current value: 20
max_heap_table_size      current value: 16777216
max_join_size            current value: 4294967295
max_sort_length          current value: 1024
max_tmp_tables           current value: 32
max_write_lock_count     current value: 4294967295
myisam_sort_buffer_size  current value: 8388608
net_buffer_length        current value: 16384
net_read_timeout         current value: 30
net_retry_count          current value: 10
net_write_timeout        current value: 60
read_buffer_size         current value: 131072
read_rnd_buffer_size     current value: 262144
slow_launch_time         current value: 2
sort_buffer              current value: 2097116
table_cache              current value: 64
thread_concurrency       current value: 10
thread_stack             current value: 131072
tmp_table_size           current value: 1048576
wait_timeout             current value: 28800
如果当前有 mysqld 服务器在运行，可以连接上去用以下命令来查看实际使用的系统变量：

mysql> SHOW VARIABLES;
也可以用以下语句来查看运行中的系统的统计结果及状态报告：

mysql> SHOW STATUS;
系统变量以及状态信息也可以通过
mysqladmin 来得到：


shell> mysqladmin variables
shell> mysqladmin extended-status
在章节"5.2.3 Server System Variables"和"5.2.4 Server Status Variables"中可以找到全部的系统描述及状态变量。
MySQL使用的算法有高伸缩性，因此它通常可以只使用很少内存就能运行。不过，给MySQL更多的内存通常能取得更好的性能。
调整MySQL服务器时，两个最重要的变量就是 key_buffer_size 和 table_cache。在试图修改其他变量前应该首先确认已经合理设定这两个变量了。
以下例子展示了在不同的运行时配置一些典型的变量值。这些例子使用 mysqld_safe 脚本和 --var_name=value 语法来设定变量 var_name 的值为 value。这个语法在MySQL 4.0以后就可以用了，在旧版本的MySQL中，考虑到如下一些不同之处：

使用 safe_mysqld 脚本而非 mysqld_safe。
使用 --set-variable=var_name=value 或 -O var_name=value 语法来设置变量。
如果变量名以 _size 结尾，就必须去掉 _size。例如，一个旧变量名为 sort_buffer_size 就是 sort_buffer，旧变量名read_buffer_size 就是 record_buffer。用 mysqld --help来要看那些变量是当前服务器版本可以识别的。
如果至少有256MB内存，且有大量的数据表，还想要在有中等数量的客户端连接时能有最大性能，可以这么设定：

shell> mysqld_safe --key_buffer_size=64M --table_cache=256 \
           --sort_buffer_size=4M --read_buffer_size=1M &
如果只有128MB内存，且只有少量表，但是需要做大量的排序，可以这么设定：

shell> mysqld_safe --key_buffer_size=16M --sort_buffer_size=1M
如果有大量的并发连接，除非 mysqld 已经设置成对每次连接只是用很少的内存，否则可能发生交换问题。mysqld 在对每次连接都有足够内存时性能更好。


如果只有很少内存且有大量连接，可以这么设定：

shell> mysqld_safe --key_buffer_size=512K --sort_buffer_size=100K \
           --read_buffer_size=100K &
甚至这样：


shell> mysqld_safe --key_buffer_size=512K --sort_buffer_size=16K \
           --table_cache=32 --read_buffer_size=8K \
           --net_buffer_length=1K &
如果在一个比可用内存大很多的标上做 GROUP BY 或 ORDER BY 操作时，那么最好加大 read_rnd_buffer_size 的值以加速排序操作后的读数据。
安装MySQL后，在 `support-files' 目录下会有一些不同的 `my.cnf' 样例文件： `my-huge.cnf', `my-large.cnf', `my-medium.cnf' 和 `my-small.cnf'。可以把它们作为优化系统的蓝本。
注意，如果是通过命令行给 mysqld 或 mysqld_safe 指定参数，那么它只在那次启动服务器时有效。想要让这些选项在服务器启动时都有效，可以把它们放到配置文件中。
想要看参数改变后的效果，可以用以下方法(在MySQL 4.1以前，忽略 --verbose)：

shell> mysqld --key_buffer_size=32M --verbose --help

这个变量就会在结果的靠近末尾列出来。确认 --verbose 和 --help 选项是放在最后面，否则，在命令行上列出来的结果中在它们之后的其他选项效果就不会被反映出来了。
关于调整 InnoDB 存储引擎的详细信息请参考"16.12 InnoDB Performance Tuning Tips"。


7.5.3 控制查询优化性能

查询优化程序的任务就是找到最佳的执行SQL查询的方法。因为"好"和"坏"方法之间的性能差异可能有数量级上的区别(也就是说，秒相对小时，甚至是天)，MySQL中的大部分查询优化程序或多或少会穷举搜索可能的优化方法，从中找到最佳的方法来执行。拿连接查询来说，MySQL优化程序搜索的可能方法会随着查询中引用表数量的增加而指数增加。如果表数量较少(通常少于7-10个)，那么这基本上不是问题。不过，当提交一个很大的查询时，服务器的性能主要瓶颈很容易就花费在优化查询上。
MySQL 5.0.1引进了一个更灵活的方法，它允许用户控制在查询优化程序穷举搜索最佳优化方法的数量。一般的考虑是，优化程序搜索的方法越少，那么在编译查询时耗费的时间就越少。另一个方面，由于优化程序可能会忽略一些方法，因此可能错过找到最佳优化方法。

关于控制优化程序评估优化方法的数量可以通过以下两个系统变量：


变量 optimizer_prune_level 告诉优化程序在估算要访问的每个表的记录数基础上忽略一定数量的方法。我们的经验表明，这种"学习猜测"方法很少会错过最佳方法，因为它可能戏剧性地减少编译时间。这就是为什么这个选项默认是打开的(optimizer_prune_level=1)。不过，如果确信优化程序会错过更好的方法，这个选项可以关上(optimizer_prune_level=0)，不过要注意编译查询的时间可能会更长了。要注意尽管是用了这种试探方法，优化程序仍会调查指数级的方法。
变量 optimizer_search_depth
告诉优化程序"将来"的每次顺序调查不完全的方法是否需要扩充的更远的深度。optimizer_search_depth 的值越小，可能会导致查询编译时间的越少。例如，有一个12-13或更多表的查询很容易就需要几小时甚至几天的时间来编译，如果 optimizer_search_depth 的值和表数量相近的话。同样，如果 optimizer_search_depth 的值等于3或4，则编译器可能至需要花不到几分钟的时间就完成编译了。如果不能确定 optimizer_search_depth 的值多少才合适，就把它设置为0，让优化程序来自动决定。