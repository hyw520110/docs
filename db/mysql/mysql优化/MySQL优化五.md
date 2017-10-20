7.3 锁

7.3.1 锁机制

当前MySQL已经支持 ISAM, MyISAM, MEMORY (HEAP) 类型表的表级锁了，BDB 表支持页级锁，InnoDB 表支持行级锁。
很多时候，可以通过经验来猜测什么样的锁对应用程序更合适，不过通常很难说一个锁比别的更好，这全都要依据应用程序来决定，不同的地方可能需要不同的锁。
想要决定是否需要采用一个支持行级锁的存储引擎，就要看看应用程序都要做什么，其中的查询、更新语句是怎么用的。例如，很多的web应用程序大量的做查询，很少删除，主要是基于索引的更新，只往特定的表中插入记录。采用基本的MySQL MyISAM 表就很合适了。
MySQL中对表级锁的存储引擎来说是释放死锁的。避免死锁可以这样做到：在任何查询之前先请求锁，并且按照请求的顺序锁表。
MySQL中用于 WRITE（写） 的表锁的实现机制如下：

如果表没有加锁，那么就加一个写锁。
否则的话，将请求放到写锁队列中。
MySQL中用于 READ（读） 的表锁的实现机制如下：

如果表没有加写锁，那么就加一个读锁。
否则的话，将请求放到读锁队列中。
当锁释放后，写锁队列中的线程可以用这个锁资源，然后才轮到读锁队列中的线程。
这就是说，如果表里有很多更新操作的话，那么 SELECT 必须等到所有的更新都完成了之后才能开始。
从 MySQL 3.23.33 开始，可以通过状态变量 Table_locks_waited 和 Table_locks_immediate 来分析系统中的锁表争夺情况：

mysql> SHOW STATUS LIKE 'Table%';
+-----------------------+---------+
| Variable_name         | Value   |
+-----------------------+---------+
| Table_locks_immediate | 1151552 |
| Table_locks_waited    | 15324   |
+-----------------------+---------+
在 MySQL 3.23.7（在Windows上是3.23.25）以后，在 MyISAM 表中只要没有冲突的 INSERT 操作，就可以无需使用锁表自由地并行执行 INSERT 和 SELECT 语句。也就是说，可以在其它客户端正在读取 MyISAM 表记录的同时时插入新记录。如果数据文件的中间没有空余的磁盘块的话，就不会发生冲突了，因为这种情况下所有的新记录都会写在数据文件的末尾（当在表的中间做删除或者更新操作时，就可能导致空洞）。当空洞被新数据填充后，并行插入特性就会自动重新被启用了。
如果想要在一个表上做大量的 INSERT 和 SELECT 操作，但是并行的插入却不可能时，可以将记录插入到临时表中，然后定期将临时表中的数据更新到实际的表里。可以用以下命令实现：

mysql> LOCK TABLES real_table WRITE, insert_table WRITE;
mysql> INSERT INTO real_table SELECT * FROM insert_table;
mysql> TRUNCATE TABLE insert_table;
mysql> UNLOCK TABLES;
InnoDB 使用行级锁，BDB 使用页级锁。对于 InnoDB 和 BDB 存储引擎来说，是可能产生死锁的。这是因为 InnoDB 会自动捕获行锁，BDB 会在执行 SQL 语句时捕获页锁的，而不是在事务的开始就这么做。
行级锁的优点有：

在很多线程请求不同记录时减少冲突锁。
事务回滚时减少改变数据。
使长时间对单独的一行记录加锁成为可能。
行级锁的缺点有：

比页级锁和表级锁消耗更多的内存。
当在大量表中使用时，比页级锁和表级锁更慢，因为他需要请求更多的所资源。
当需要频繁对大部分数据做 GROUP BY 操作或者需要频繁扫描整个表时，就明显的比其它锁更糟糕。
使用更高层的锁的话，就能更方便的支持各种不同的类型应用程序，因为这种锁的开销比行级锁小多了。
表级锁在下列几种情况下比页级锁和行级锁更优越：

很多操作都是读表。
在严格条件的索引上读取和更新，当更新或者删除可以用单独的索引来读取得到时：
UPDATE tbl_name SET column=value WHERE unique_key_col=key_value;
DELETE FROM tbl_name WHERE unique_key_col=key_value;
SELECT 和 INSERT 语句并发的执行，但是只有很少的 UPDATE 和 DELETE 语句。
很多的扫描表和对全表的 GROUP BY 操作，但是没有任何写表。
表级锁和行级锁或页级锁之间的不同之处还在于：
将同时有一个写和多个读的地方做版本（例如在MySQL中的并发插入）。也就是说，数据库/表支持根据开始访问数据时间点的不同支持各种不同的试图。其它名有：时间行程，写复制，或者是按需复制。
原文： Versioning (such as we use in MySQL for concurrent inserts) where you can have one writer at the same time as many readers. This means that the database/table supports different views for the data depending on when you started to access it. Other names for this are time travel, copy on write, or copy on demand.
按需复制在很多情况下比页级锁或行级锁好多了。尽管如此，最坏情况时还是比其它正常锁使用了更多的内存。
可以用应用程序级锁来代替行级锁，例如MySQL中的 GET_LOCK() 和 RELEASE_LOCK()。但它们是劝告锁（原文：These are advisory locks），因此只能用于安全可信的应用程序中。

7.3.2 锁表

为了能有快速的锁，MySQL除了 InnoDB 和 BDB 这两种存储引擎外，所有的都是用表级锁（而非页、行、列级锁）。
对于 InnoDB 和 BDB 表，MySQL只有在指定用 LOCK TABLES 锁表时才使用表级锁。在这两种表中，建议最好不要使用 LOCK TABLES，因为 InnoDB 自动采用行级锁，BDB 用页级锁来保证事务的隔离。
如果数据表很大，那么在大多数应用中表级锁会比行级锁好多了，不过这有一些陷阱。
表级锁让很多线程可以同时从数据表中读取数据，但是如果另一个线程想要写数据的话，就必须要先取得排他访问。正在更新数据时，必须要等到更新完成了，其他线程才能访问这个表。
更新操作通常认为比读取更重要，因此它的优先级更高。不过最好要先确认，数据表是否有很高的 SELECT 操作，而更新操作并非很‘急需’。
表锁锁在一个线程在等待，因为磁盘空间满了，但是却需要有空余的磁盘空间，这个线程才能继续处理时就有问题了。这种情况下，所有要访问这个出问题的表的线程都会被置为等待状态，直到有剩余磁盘空间了。
表锁在以下设想情况中就不利了：

一个客户端提交了一个需要长时间运行的 SELECT 操作。
其他客户端对同一个表提交了 UPDATE 操作，这个客户端就要等到 SELECT 完成了才能开始执行。
其他客户端也对同一个表提交了 SELECT 请求。由于 UPDATE 的优先级高于 SELECT，所以 SELECT 就会先等到 UPDATE 完成了之后才开始执行，它也在等待第一个 SELECT 操作。
下列所述可以减少表锁带来的资源争夺：

让 SELECT 速度尽量快，这可能需要创建一些摘要表。
启动 mysqld 时使用参数 --low-priority-updates。这就会让更新操作的优先级低于 SELECT。这种情况下，在上面的假设中，第二个 SELECT 就会在 INSERT 之前执行了，而且也无需等待第一个SELECT 了。
可以执行 SET LOW_PRIORITY_UPDATES=1 命令，指定所有的更新操作都放到一个指定的链接中去完成。详情请看“14.5.3.1 SET Syntax”。
用 LOW_PRIORITY 属性来降低 INSERT，UPDATE，DELETE 的优先级。
用 HIGH_PRIORITY 来提高 SELECT 语句的优先级。详情请看“14.1.7 SELECT Syntax”。
从MySQL 3.23.7 开始，可以在启动 mysqld 时指定系统变量 max_write_lock_count 为一个比较低的值，它能强制临时地提高表的插入数达到一个特定值后的所有 SELECT 操作的优先级。它允许在 WRITE 锁达到一定数量后有 READ 锁。
当 INSERT 和 SELECT 一起使用出现问题时，可以转而采用 MyISAM 表，它支持并发的SELECT 和 INSERT 操作。
当在同一个表上同时有插入和删除操作时，INSERT DELAYED 可能会很有用。详情请看“14.1.4.2 INSERT DELAYED Syntax”。
当 SELECT 和 DELETE 一起使用出现问题时，DELETE 的 LIMIT 参数可能会很有用。详情请看“14.1.1 DELETE Syntax”
执行 SELECT 时使用 SQL_BUFFER_RESULT 有助于减短锁表的持续时间.详情请看“14.1.7 SELECT Syntax”。
可以修改源代码 `mysys/thr_lock.c'，只用一个所队列。这种情况下，写锁和读锁的优先级就一样了，这对一些应用可能有帮助。
以下是MySQL锁的一些建议：

只要对同一个表没有大量的更新和查询操作混在一起，目前的用户并不是问题。
执行 LOCK TABLES 来提高速度（很多更新操作放在一个锁之中比没有锁的很多更新快多了）。将数据拆分开到多个表中可能也有帮助。
当MySQL碰到由于锁表引起的速度问题时，将表类型转换成 InnoDB 或 BDB 可能有助于提高性能。详情请看“16 The InnoDB Storage Engine”和“15.4 The BDB (BerkeleyDB) Storage Engine”。