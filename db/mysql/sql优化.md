/*
Title: SQL优化
Sort: 0
*/


# 优化目标

## 减少IO次数:

IO永远是数据库最容易瓶颈的地方，这是由数据库的职责所决定的，大部分数据库操作中超过90%的时间都是 IO 操作所占用的，减少 IO 次数是 SQL 优化中需要第一优先考虑，当然，也是收效最明显的优化手段。

## 降低CPU计算:

除了 IO 瓶颈之外，SQL优化中需要考虑的就是 CPU 运算量的优化了。order by, group by,distinct … 都是消耗 CPU 的大户(这些操作基本上都是 CPU 处理内存中的数据比较运算)。当我们的 IO 优化做到一定阶段之后，降低 CPU 计算也就成为了我们 SQL 优化的重要目标

# 常用优化方法

## 通过show status 命令了解各种sql的执行效率

SHOW STATUS提供msyql服务器的状态信息,一般情况下，我们只需要了解以”Com”开头的指令

	--显示当前的连接的统计结果
	show session status like ‘Com%’;
	--显示自数据库上次启动至今的统计结果
	show global status like ‘Com%’;

其中Com_XXX表示XXX语句所执行的次数。重点注意：Com_select,Com_insert,Com_update,Com_delete通过这几个参数，可以容易地了解到当前数据库的应用是以插入更新为主还是以查询操作为主，以及各类的SQL大致的执行比例是多少。另外，还有几个参数需要注意下：
	
		--试图连接MySQL服务器的次数
		show status like ‘Connections’
		--服务器工作的时间（单位秒）
		show status like ‘Uptime’
		--慢查询的次数 
		show status like ‘Slow_queries’
		-- 查询mysql的慢查询时间(默认是10秒中就当做是慢查询)
		show variables like 'long_query_time';
		-- 修改mysql慢查询时间如果查询时间超过2秒就算作是慢查询
		set long_query_time=2 
## 定位执行效率较低的SQL语句

开启慢查询记录，打开 my.ini ,找到 [mysqld] 在其下面添加
		
	long_query_time = 2
	log-slow-queries = D:/logs/mysql-slow.log 
## 通过explain分析低效率的SQL语句的执行情况

用于分析sql语句的执行情况和成本预估

示例： 

	EXPLAIN SELECT * FROM t WHERE id=12345

会产生如下信息：

- select_type:表示查询的类型。
- table:输出结果集的表
- type:表示表的连接类型(system和const为佳)
- possible_keys:表示查询时，可能使用的索引
- key:表示实际使用的索引,NULL表示没有适用索引
- key_len:索引字段的长度
- rows:扫描的行数
- Extra:执行情况的描述和说明


type指标逐渐降低：	
		  							
	system>const>eq_ref>ref>fulltext>ref_or_null>index_merge>unique_subquery>index_subquery>range>index>all
- system 这是const联接类型的一个特例
	
	
		EXPLAIN SELECT * FROM (SELECT * FROM t1 WHERE id=1) a;

- const 如果是根据主键或唯一索引(where条件都是主键或都是UNIQUE)只取出确定的一行数据。是最快的一种。

		EXPLAIN SELECT * from t1 WHERE primary_key=1；
-  eq_ref 对于每个来自于前面的表的行组合，从该表中读取一行。除了const类型是最好的联接类型。它用在一个索引的所有部分被联接使用并且索引是UNIQUE或PRIMARY KEY。 

		SELECT * FROM ref_table,other_table WHERE ref_table.key_column=other_table.column;

		SELECT * FROM ref_table,other_table WHERE ref_table.key_column_part1=other_table.column AND ref_table.key_column_part2=1;

		create unique index  idx_t3_id on t3(id) ;
		explain select * from t3,t4 where t3.id=t4.accountid;		
- ref 对于每个来自于前面的表的行组合，所有有匹配索引值的行将从这张表中读取。如果联接只使用键的最左边的前缀，或如果键不是UNIQUE或PRIMARY KEY（换句话说，如果联接不能基于关键字选择单个行的话），则使用ref。如果使用的键仅仅匹配少量行，该联接类型是不错的。

		SELECT * FROM ref_table WHERE key_column=expr;

		SELECT * FROM ref_table,other_table WHERE ref_table.key_column=other_table.column;

		SELECT * FROM ref_table,other_table WHERE ref_table.key_column_part1=other_table.column AND ref_table.key_column_part2=1;

		drop index idx_t3_id on t3;
		create index idx_t3_id on t3(id) ;	
		explain select * from t3,t4 where t3.id=t4.accountid;
- ref_or_null 该联接类型如同ref，但是添加了MySQL可以专门搜索包含NULL值的行。在解决子查询中经常使用该联接类型的优化。

		SELECT * FROM ref_table WHERE key_column=expr OR key_column IS NULL;
- index_merge 该联接类型表示使用了索引合并优化方法。在这种情况下，key列包含了使用的索引的清单，key_len包含了使用的索引的最长的关键元素。

		explain select * from t4 where id=3952602 or accountid=31754306 ;
- unique_subquery子查询使用了unique或者primary key

		value IN (SELECT primary_key FROM single_table WHERE some_expr)
- index_subquery 子查询使用了普通索引
该联接类型类似于unique_subquery。可以替换IN子查询，但只适合下列形式的子查询中的非唯一索引：

	value IN (SELECT key_column FROM single_table WHERE some_expr)
- range 索引或主键，在某个范围内时 

		explain select * from t3 where id=3952602 or id=3952603 ;
- index 仅仅只有索引被扫描,比ALL快，因为索引文件通常比数据文件小。 
- all 全表扫描，最糟糕的

要尽量避免让type的结果为all，extra的结果为：using filesort
## 确定问题并采取相应的优化措施

常用的优化措施是添加索引。添加索引，查询速度就可能提高百倍千倍。但是查询速度的提高是以插入、更新、删除的速度为代价的，写操作会增加大量的I/O。

### 建立索引的几个准则：

- 合理的建立索引能够加速数据读取效率，不合理的建立索引反而会拖慢数据库的响应速度。
- 索引越多，更新数据的速度越慢。
- 尽量在采用MyIsam作为引擎的时候使用索引（因为MySQL以BTree存储索引），而不是InnoDB。但MyISAM不支持Transcation。
- 较频繁的作为查询条件字段应该创建索引
- 唯一性太差的字段不适合单独创建索引，即使频繁作为查询条件
- 更新非常频繁的字段不适合创建索引
- 不会出现在WHERE子句中字段不该创建索引
- 当你的程序和数据库结构/SQL语句已经优化到无法优化的程度，而程序瓶颈并不能顺利解决，那就是应该考虑使用分布式缓存。
- 习惯和强迫自己用EXPLAIN来分析你SQL语句的性能。

**索引的类型：**

- PRIMARY 索引      => 在主键上自动创建
- INDEX 索引          => 就是普通索引
- UNIQUE 索引        => 相当于INDEX + Unique
- FULLTEXT            => 只在MYISAM 存储引擎支持, 目的是全文索引，在内容系统中用的多， 在全英文网站用多(英文词独立). 

**优化策略：**

1. 对查询进行优化，要尽量避免全表扫描，首先应考虑在where及order by涉及的列上建立索引。
2. 应尽量避免在where子句中对字段进行null值判断，否则将导致引擎放弃使用索引而进行全表扫描.最好不要给数据库留NULL，尽可能的使用默认值填充数据库,不要以为NULL不需要空间,NULL在定长字段上是占空间的.
3. 应尽量避免在where子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。
4. 应尽量避免在where子句中使用or来连接条件，如果一个字段有索引，一个字段没有索引，将导致引擎放弃使用索引而进行全表扫描(可以改为union all),示例：

	select id from t where num=10 or Name = 'admin'
	可以改为：
	select id from t where num = 10
	union all
	select id from t where Name = 'admin'
5. in 和 not in 也要慎用，否则会导致全表扫描，对于连续的数值，能用between就不要用in,很多时候用exists代替in是一个好的选择.
6. like查询也将导致全表扫描,若要提高效率，可以考虑全文检索
	- 首选是否适用全文检索需根据实际情况考虑，因为全文索引和LIKE语句是不同的,全文索引的单位是词，而LIKE匹配的是字符，全文检索适用于大段文本根据词来搜索,很短或无意义的文本like更适合.适用like查询时,不要习惯性的使用 ‘%L%’,可以使用`L%’相对来说更好
	- 全文检索只能用在MyISAM表格的char、varchar和text的字段。
	- innoDB这种表的类型不支持全文检索，所以要先改变其类型为MyISAM。
	- 全文索引的index可以在create table、alter table和create index时产生
	- 导大量数据时有全文索引会非常慢，可以先去掉全文索引index，导完在加上
		alter table t engine=MyISAM;
		--如需对多个字段进行检索,可以添加多个字段空格隔开,如是中文需添加   
		ALTER TABLE tt ADD FULLTEXT INDEX(NAME);
7. 如果在where子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。
	- 如下面语句将进行全表扫描：

			select id from t where num = @num
			--可以改为强制查询使用索引：
			select id from t with(index(索引名)) where num = @num
	- 应尽量避免在where子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如：

			select id from t where num/2 = 100
			--应改为:
			select id from t where num = 100*2
8. 应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如：

		select id from t where substring(name,1,3) = ’abc’      
		应改为:
		select id from t where name like 'abc%'

9. 不要在where子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。
  
10. 在使用索引字段作为条件时，如果该索引是复合索引，那么必须使用到该索引中的第一个字段作为条件时才能保证系统使用该索引，否则该索引将不会被使用，并且应尽可能的让字段顺序与索引顺序相一致。

11. 不要写一些没有意义的查询，如需要生成一个空表结构：

		select col1,col2 into #t from t where 1=0
		--这类代码不会返回任何结果集，但是会消耗系统资源的，应改成这样：
		create table #t(…)

12. Update语句，如果只更改1、2个字段，不要Update全部字段，否则频繁调用会引起明显的性能消耗，同时带来大量日志。

13. 对于多张大数据量（这里几百条就算大了）的表JOIN，要先分页再JOIN，否则逻辑读会很高，性能很差。

14. select count(*) from table；这样不带任何条件的count会引起全表扫描，并且没有任何业务意义，是一定要杜绝的。

15. 索引并不是越多越好，索引固然可以提高相应的select的效率，但同时也降低了insert及update的效率，因为insert或update时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有必要。

16. 应尽可能的避免更新clustered索引数据列，因为clustered索引数据列的顺序就是表记录的物理存储顺序，一旦该列值改变将导致整个表记录的顺序的调整，会耗费相当大的资源。若应用系统需要频繁更新clustered索引数据列，那么需要考虑是否应将该索引建为clustered索引。

17. 尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。

18. 尽可能的使用varchar/nvarchar代替char/nchar ，因为首先变长字段存储空间小，可以节省存储空间，其次对于查询来说，在一个相对较小的字段内搜索效率显然要高些。

19. 任何地方都不要使用select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段。

20. 尽量使用表变量来代替临时表。如果表变量包含大量数据，请注意索引非常有限（只有主键索引）。

21. 避免频繁创建和删除临时表，以减少系统表资源的消耗。临时表并不是不可使用，适当地使用它们可以使某些例程更有效，例如，当需要重复引用大型表或常用表中的某个数据集时。但是，对于一次性事件， 最好使用导出表。

22. 在新建临时表时，如果一次性插入数据量很大，那么可以使用 select into 代替 create table，避免造成大量 log ，以提高速度；如果数据量不大，为了缓和系统表的资源，应先create table，然后insert。

23. 如果使用到了临时表，在存储过程的最后务必将所有的临时表显式删除，先 truncate table ，然后 drop table ，这样可以避免系统表的较长时间锁定。

24. 尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。

25. 使用基于游标的方法或临时表方法之前，应先寻找基于集的解决方案来解决问题，基于集的方法通常更有效。

26. 与临时表一样，游标并不是不可使用。对小型数据集使用 FAST_FORWARD 游标通常要优于其他逐行处理方法，尤其是在必须引用几个表才能获得所需的数据时。在结果集中包括“合计”的例程通常要比使用游标执行的速度快。如果开发时 间允许，基于游标的方法和基于集的方法都可以尝试一下，看哪一种方法的效果更好。

27. 在所有的存储过程和触发器的开始处设置 SET NOCOUNT ON ，在结束时设置 SET NOCOUNT OFF 。无需在执行存储过程和触发器的每个语句后向客户端发送DONE_IN_PROC消息。

28. 尽量避免大事务操作，提高系统并发能力。

29. 尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。拆分大的 DELETE 或INSERT 语句，批量提交SQL语句
		-- 如果你有一个大的处理，你一定把其拆分，使用LIMIT条件是一个好的方法。
	 
		while(1){
		 --每次只做1000条
		 mysql_query(“delete from logs where log_date <= ’2012-11-01’ limit 1000”);
		 if(mysql_affected_rows() == 0){
		 //删除完成，退出！
		 break；
		}
		//每次暂停一段时间，释放表让其他进程/线程访问。
		usleep(50000)
		}
30.  尽量不要用SELECT INTO语句(新建临时表的情况除外),SELECT INTO 语句会导致表锁定，阻止其他用户访问该表
31.  UPDATE语句建议：
- 尽量不要修改主键字段。
- 当修改VARCHAR型字段时，尽量使用相同长度内容的值代替。
- 尽量最小化对于含有UPDATE触发器的表的UPDATE操作。
- 避免UPDATE将要复制到其他数据库的列。
- 避免UPDATE建有很多索引的列。
- 避免UPDATE在WHERE子句条件中的列。

**常见误区**
 

1. count(1)和count(primary_key)优于count(*)
  
很多人为了统计记录条数，就使用 count(1) 和 count(primary_key) 而不是count(*) ，他们认为这样性能更好，其实这是一个误区。对于有些场景，这样做可能性能会更差，应为数据库对 count(*) 计数操作做了一些特别的优化。

 

2.count(column) 和 count(*) 是一样的


这个误区甚至在很多的资深工程师或者是 DBA 中都普遍存在，很多人都会认为这是理所当然的。实际上，count(column) 和 count(*) 是一个完全不一样的操作，所代表的意义也完全不一样。


count(column) 是表示结果集中有多少个column字段不为空的记录

count(*) 是表示整个结果集有多少条记录

 

3.select a,b from … 比 select a,b,c from … 可以让数据库访问更少的数据量

这个误区主要存在于大量的开发人员中，主要原因是对数据库的存储原理不是太了解。

实际上，大多数关系型数据库都是按照行(row)的方式存储，而数据存取操作都是以一个固定大小的IO单元(被称作 block 或者 page)为单位，一般为4KB，8KB… 大多数时候，每个IO单元中存储了多行，每行都是存储了该行的所有字段(lob等特殊类型字段除外)。

所以，我们是取一个字段还是多个字段，实际上数据库在表中需要访问的数据量其实是一样的。

当然，也有例外情况，那就是我们的这个查询在索引中就可以完成，也就是说当只取 a,b两个字段的时候，不需要回表，而c这个字段不在使用的索引中，需要回表取得其数据。在这样的情况下，二者的IO量会有较大差异。

 

4.order by 一定需要排序操作

我们知道索引数据实际上是有序的，如果我们的需要的数据和某个索引的顺序一致，而且我们的查询又通过这个索引来执行，那么数据库一般会省略排序操作，而直接将数据返回，因为数据库知道数据已经满足我们的排序需求了。

实际上，利用索引来优化有排序需求的 SQL，是一个非常重要的优化手段

延伸阅读：MySQL ORDER BY 的实现分析，MySQL 中 GROUP BY 基本实现原理以及 MySQL DISTINCT 的基本实现原理这3篇文章中有更为深入的分析，尤其是第一篇

 

5.执行计划中有 filesort 就会进行磁盘文件排序

有这个误区其实并不能怪我们，而是因为 MySQL 开发者在用词方面的问题。filesort 是我们在使用 explain 命令查看一条 SQL 的执行计划的时候可能会看到在 “Extra” 一列显示的信息。

实际上，只要一条 SQL 语句需要进行排序操作，都会显示“Using filesort”，这并不表示就会有文件排序操作。

 

基本原则

1.尽量少 join

MySQL 的优势在于简单，但这在某些方面其实也是其劣势。MySQL 优化器效率高，但是由于其统计信息的量有限，优化器工作过程出现偏差的可能性也就更多。对于复杂的多表 Join，一方面由于其优化器受限，再者在 Join 这方面所下的功夫还不够，所以性能表现离 Oracle 等关系型数据库前辈还是有一定距离。但如果是简单的单表查询，这一差距就会极小甚至在有些场景下要优于这些数据库前辈。

 

2.尽量少排序

排序操作会消耗较多的 CPU 资源，所以减少排序可以在缓存命中率高等 IO 能力足够的场景下会较大影响 SQL 的响应时间。

对于MySQL来说，减少排序有多种办法，比如：

上面误区中提到的通过利用索引来排序的方式进行优化

减少参与排序的记录条数

非必要不对数据进行排序

　　
3.尽量避免 select *

很多人看到这一点后觉得比较难理解，上面不是在误区中刚刚说 select 子句中字段的多少并不会影响到读取的数据吗?

是的，大多数时候并不会影响到 IO 量，但是当我们还存在 order by 操作的时候，select 子句中的字段多少会在很大程度上影响到我们的排序效率。

此外，上面误区中不是也说了，只是大多数时候是不会影响到 IO 量，当我们的查询结果仅仅只需要在索引中就能找到的时候，还是会极大减少 IO 量的。

 

4.尽量用 join 代替子查询

虽然 Join 性能并不佳，但是和 MySQL 的子查询比起来还是有非常大的性能优势。MySQL 的子查询执行计划一直存在较大的问题，虽然这个问题已经存在多年，但是到目前已经发布的所有稳定版本中都普遍存在，一直没有太大改善。虽然官方也在很早就承认这一问题，并且承诺尽快解决，但是至少到目前为止我们还没有看到哪一个版本较好的解决了这一问题。

 

5.尽量少 or

当 where 子句中存在多个条件以“或”并存的时候，MySQL 的优化器并没有很好的解决其执行计划优化问题，再加上 MySQL 特有的 SQL 与 Storage 分层架构方式，造成了其性能比较低下，很多时候使用 union all 或者是union(必要的时候)的方式来代替“or”会得到更好的效果。

 

6.尽量用 union all代替union

union和 union all 的差异主要是前者需要将两个(或者多个)结果集合并后再进行唯一性过滤操作，这就会涉及到排序，增加大量的CPU 运算，加大资源消耗及延迟。所以当我们可以确认不可能出现重复结果集或者不在乎重复结果集的时候，尽量使用 union all 而不是 union。

 

7.尽量早过滤

这一优化策略其实最常见于索引的优化设计中(将过滤性更好的字段放得更靠前)。


在 SQL 编写中同样可以使用这一原则来优化一些 Join 的 SQL。比如我们在多个表进行分页数据查询的时候，我们最好是能够在一个表上先过滤好数据分好页，然后再用分好页的结果集与另外的表 Join，这样可以尽可能多的减少不必要的 IO 操作，大大节省 IO 操作所消耗的时间。

 

8.避免类型转换


这里所说的“类型转换”是指 where 子句中出现 column 字段的类型和传入的参数类型不一致的时候发生的类型转换：


人为在column_name 上通过转换函数进行转换


直接导致 MySQL(实际上其他数据库也会有同样的问题)无法使用索引，如果非要转换，应该在传入的参数上进行转换


由数据库自己进行转换

如果我们传入的数据类型和字段类型不一致，同时我们又没有做任何类型转换处理，MySQL 可能会自己对我们的数据进行类型转换操作，也可能不进行处理而交由存储引擎去处理，这样一来，就会出现索引无法使用的情况而造成执行计划问题。

 

9.优先优化高并发的 SQL，而不是执行频率低某些“大”SQL


对于破坏性来说，高并发的 SQL 总是会比低频率的来得大，因为高并发的 SQL 一旦出现问题，甚至不会给我们任何喘息的机会就会将系统压跨。而对于一些虽然需要消耗大量 IO 而且响应很慢的 SQL，由于频率低，即使遇到，最多就是让整个系统响应慢一点，但至少可能撑一会儿，让我们有缓冲的机会。

 

10.从全局出发优化，而不是片面调整


SQL优化不能是单独针对某一个进行，而应充分考虑系统中所有的SQL，尤其是在通过调整索引优化SQL 的执行计划的时候，千万不能顾此失彼，因小失大。

 

11.尽可能对每一条运行在数据库中的SQL进行 explain


优化SQL，需要做到心中有数，知道SQL的执行计划才能判断是否有优化余地，才能判断是否存在执行计划问题。在对数据库中运行的 SQL 进行了一段时间的优化之后，很明显的问题 SQL 可能已经很少了，大多都需要去发掘，这时候就需要进行大量的 explain 操作收集执行计划，并判断是否需要进行优化。
　　 

