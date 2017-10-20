从mysql5.5.x开始，默认的存储引擎更改为InnoDB Plugin引擎，提供了具有提交、回滚、和崩溃恢复能力的事务安全存储引擎；InnoDB锁定在行级，并且也在SELECT语句提供一个与Oracle风格一致的非锁定读，这些特性增加了多用户部署和性能。InnoDB存储引擎被完全整合到了mysql服务器中，不过，为了能在主内存中缓存数据和索引，InnoDB存储引擎会维持它自己的缓冲池。InnoDB会在一个表空间中存储它的表和索引

#预读算法的变化#
 
两种预读算法提高I/O性能，一种是线性预读，一种是随机预读；
 
线性预读：当顺序读取extent块（包含64个page）innodb_read_ahead_threshold设置的page页数量时，触发 一个异步读取请求，将下一个页提前读取到buffer pool中。在MySQL5.1.X版本中，顺序读取extent块最后一个页时，InnoDB决定是否将下一个页提前读取到 InnoDB_Buffer_Pool缓冲池中。

随机预读：如果在InnoDB_Buffer_Pool缓冲池中发现同一个extent块内有若干个页，那么会触发一个异步读取请求，把剩余的页读取进来，随机预读增加了不必要的复杂性，常常导致性能下降，因此，在MySQL5.5.X版本中已经将其删除了。

参数：

	innodb_read_ahead_threshold 默认是56.可动态修改  
	show engine innodb status\G; 可查看：

其中:

	Pages read ahead :表示每秒预读了多少页
	evicted without access :表示预读到页没有被访问，每秒被踢出了多少页
	如果发现有很多evicted without access，说明该参数到值太小，应该增大

#在linux上实现了异步I/O#
 
同步I/O：线程启动一个I/O操作后会立即进入等待状态，直到I/O操作完成才醒来继续执行；

异步I/O：线程启动一个I/O请求到内核后，然后继续处理其他到事情，内核完成I/O请求后，将会通知线程I/O完成。

5.5.x开始实现了异步I/O功能，也就是linux native aio，要想使用linux native aio，可以利用libaio库，libaio对linux native aio的系统调用进行了简单的封装，当然，也可以直接通过系统调用来使用linux native aio。
在使用libaio之前，需要现安装 libaio rpm包：

	yum install libaio -y
	rpm -qa | grep libaio
 
 
参数：

可以通过innodb_use_native _aio参数来选择是否启用异步I/O，默认是ON，即处于开启状态，此参数不支持动态修改
 
可通过cat /proc/slabinfo|grep kio命令，来查看异步I/O是否能正常工作
如果kiocb那项不为0，代表异步I/O已工作。

#恢复组工作#

背景：

一个事务提交时，采取的是先写日志后刷入磁盘的方式，假如此时有多个用户同时提交，那么按照顺序把写入的事务日志刷入磁盘上，就会导致磁盘做多次I/O操作，从而降低IOPS吞吐率。
 
方案：

从MySQL5.5.X版本开始，会采用组提交的方式来将事务刷入磁盘中，也就是说，如果有多个用户同时提交事务，那么就合并在一起一次性来刷入磁盘，大大提高了吞吐量。举个搬饮料放入库房的例子：以前，搬运工每次搬一箱饮料放入库房，这样进入库房的频率就很高，他来来回回的也很累，后来他索性每次搬5箱饮料，这样一次搬的东西多了，进出库房的频率也就变低了。

注意：

组提交工作模式只支持在sync_binlog = 0的情况下, 同样，innodb_support_xa也必须等于0。其目的是保证InnoDB存储引擎的redo log事务日志与binlog日志的顺序一致。
 
参数：

	sync_binlog=0
	innodb_support_xa=0
	保证innodb存储引擎的redo log事务日志与binlog日志顺序一致。

改善清除程序进度
 
InnoDB中清除操作是一类定期回收无用数据的操作，在之前的版本中，清除操作是主线程的一部分，这意味着它在运行时可能会堵塞其他的数据操作，比如删除一张大表。
从5.5.x开始，该操作运行于独立的线程中，并支持更多的并发数。用户可以通过设置innodb_purge_threads配置参数来选择清除操作是否使用单独的线程，默认情况下设置为0（不使用单独线程），设置为1时表示使用单独的清除线程。

添加删除缓冲和清除缓冲

在对一个表进行增删改查操作时，里面到索引（聚集索引和非聚集索引）也会更新，其中，主键（聚集索引）是按照顺序进行插入的，而非聚集索引则会分散插入。
顺序读写的速度要比随机读写到速度快，表越大越明显，而插入到性能就会降低。

当一个表做insert操作来更新非聚集索引时：
 
如果该非聚集索引页被读入Innodb_Buffer_Pool缓冲池里，那么就直接更新非聚集索引，并使用正常的写脏数据块方法将其闪存到磁盘中；

如果没有读入缓冲池里，则使用插入缓冲区来缓存非聚集索引页的变化，直到该页被读入Innodb_Buffer_Pool缓冲池里，执行插入缓存合并操作，并使用正常的写脏数据块方法将其闪存到磁盘中，从而提高了插入性能。
 
 
然而，由于插入缓冲区占用部分Innodb_Buffer_Pool缓冲池，因此使得缓存数据页的可用内存减少了。如果数据和索引全部读入Innodb_Buffer_Pool缓冲池，并且表中有相对较少的非聚集索引，那么就可以关闭 InnoDB的插入缓冲功能。
 
 
如果该非聚集索引页被读入Innodb_Buffer_Pool缓冲池里，那么就会直接更新非聚集索引，并使用正常的写脏数据块方法将其闪存到磁盘中，这样一来，插入缓冲区就没有什么作用了，并且还占用一定的内存，这种情况下关闭该功能较好。
 
 
5.5.x可用来控制删除缓冲区和插入缓冲区功能，默认是all
参数：
SET GLOBAL innodb_change_buffering=all;
 
12.控制自旋锁Spin Lock轮训间隔
 
何谓自旋锁？
它是为保护共享资源而提出的一种锁机制。其实，自旋锁与互斥锁比较类似，它们都是为了解决对某项资源的互斥使用的。无论是互斥锁，还是 自旋锁，在任何时刻，最多只能有一个保持者，也就是说，在任何时刻最多只能有一个执行单元获得锁。但是两者在调度机制上略有不同。对于互斥锁，如果资源已 经被占用，资源申请者只能进入睡眠状态。但是自旋锁不会引起调用者睡眠，如果自旋锁已经被别的执行单元保持，调用者就一直循环在那里看该自旋锁的保持者是 否已经释放了锁，“自旋”一词就是因此而得名。
为了防止自旋锁循环过快，耗费CPU，在MySQL5.5.X版本里引入了innodb_spin_wait_delay参数，作用是控制轮训间 隔，也就是说在每次轮训的过程中，会休息一会儿然后再轮训。比如，在用一个死循环监控服务状态时，那么每次会睡眠5秒，然后再进行检查，代码如下所示： #!/bin/bash while true do  pstree -p MySQL > /dev/null  if [ $? -eq 0 ];then echo "OK. "
 else  echo "MySQL is down. " | mail -s "aleat" hechunyang@139.com  fi  sleep 5 done
注意
innodb_spin_wait_delay参数的值默认是6，可动态调整。
set global innodb_spin_wait_delay=6;
13.快速创建、删除、更改索引
 
背景：
在5.1.x版本里，创建和删除聚集索引的过程如下：
a.创建一个和原表结构一样的空表，然后创建聚集索引；
b.复制原表的数据到新表，这时会对原表加一个排他锁，其他的绘画dml操作会阻塞，从而保证数据的一致性；
c.复制完毕后删除原表，并把新表改名为原表。
 
创建和删除非聚集索引的过程如下：
a.创建一个和原表一样的空表，然后创建非聚集索引；
b.复制原表的数据到新表，这时会对原表加一个共享锁，其他的会话不能更新，但可以查询数据，从而保证数据的一致性；
c.复制完毕后删除原表，并把新表改名为原表。
 
 
5.5.x版本开始，创建和删除非聚集索引不用复制整个表的内容，只须更新表的索引页；和之前相比，速度会更快，但创建聚集索引(主键)或者是外键时，还是需要复制表的内容，因为聚集索引是把primary key以及row data保存在一起的，而secondary index则是单独存放的，有个指针指向primary key。
 
14.支持创建压缩数据页
 
 
从MySQL5.5.X版本开始支持InnoDB数据页压缩，数据页的压缩使数据文件体积变小，减少磁盘I/O，提高吞吐量，小成本地提高了CPU利用率。尤其是对读多写少的应用来说最为有效，同样的内存可以存储更多的数据，充分地“榨干”内存利用率。
 
 
工作原理是：当用户获取数据时，如果压缩的页没有在Innodb_Buffer_Pool缓冲池里，那么会从磁盘加载进去，并且会在 Innodb_Buffer_Pool缓冲池里开辟一个新的未压缩的16 KB的数据页来解压缩，为了减少磁盘I/O以及对页的解压操作，在缓冲池里同时存在着被压缩的和未压缩的页。为了给其他需要的数据页腾出空间，缓冲池里会 把未压缩的数据页踢出去，而保留压缩的页在内存中，如果未压缩的页在一段时间内没有被访问，那么会直接写入磁盘中，因此缓冲池中可能有压缩和未压缩的页， 也可能只有压缩页。
 
 
 
InnoDB采用最近最少使用（LRU）算法，将经常被访问的热数据放入内存里。当访问一个压缩表时，InnoDB会通过自适应的LRU算法来实现内存中 压缩页和未压缩页的平衡，其目的是避免当CPU繁忙时花费太多的时间在解压缩上，也是为了避免在CPU空闲时在解压缩操作上做过多的I/O操作。
 
 
当系统处于I/O瓶颈时，这个算法会踢出未压缩的页，而不是未压缩和压缩的页，从而为更多的页注入内存腾出空间；
 
 
而当系统处于CPU瓶颈时，这个算法会同时踢出未压缩的页和压缩的页，留出更多的内存来存放热数据，减少解压缩带来的开销。
 
 
 
在以前的版本中，一个数据页是16 KB，现在可以在建表时指定压缩的页是1 KB、2 KB、4 KB还是8 KB，如果设置过小，会导致消耗更多的CPU，通常设置为8 KB。
 
 
注意，必须采用Barracuda文件格式且独立表空间，才支持数据页压缩，如下所示： innodb_file_format = Barracuda innodb_file_per_table = 1
要设置数据页为8 KB，在建表的时候加入ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8即可，代码如下： CREATE TABLE 'compressed' ( 'id' int(10) unsigned NOT NULL AUTO_INCREMENT, 'k' int(10) unsigned NOT NULL DEFAULT '0', 'c' char(120) NOT NULL DEFAULT '',
'pad' char(60) NOT NULL DEFAULT '', PRIMARY KEY ('id'), KEY 'k' ('k') ) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8
15.动态关闭innodb更新元数据的统计功能
 
innodb_stats_on_metadata参数的作用是：每当查询information_schema元数据库里的表时，InnoDB还 会随机提取其他数据库每个表索引页的部分数据，从而更新information_schema.STATISTICS表，并返回刚才查询的结果。当你的表 很大，且数量很多时，耗费的时间就会很长，很多经常不访问的数据也会进入Innodb_Buffer_Pool缓冲池里，那么就会污染缓冲池，并且 ANALYZE TABLE和SHOW TABLE STATUS语句也会造成InnoDB随机提取数据。
从MySQL5.5.X版本开始，你可以动态关闭innodb_stats_on_metadata，不过默认是开启的。关闭方式如下：
set global innodb_stats_on_metadata=O


http://www.oschina.net/translate/the-road-to-500k-qps-with-mysql-5-7?cmp