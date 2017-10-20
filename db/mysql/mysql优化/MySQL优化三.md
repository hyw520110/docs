7.2.2 估算查询性能


在大多数情况下，可以通过统计磁盘搜索次数来估算查询的性能。对小表来说，通常情况下只需要搜索一次磁盘就能找到对应的记录（因为索引可能已经缓存起来了）。对大表来说，大致可以这么估算，它使用B树做索引，想要找到一条记录大概需要搜索的次数为：log(row_count) / log(index_block_length / 3 * 2 / (index_length + data_pointer_length)) + 1。

在MySQL中，一个索引块通常是1024bytes，数据指针通常是4bytes。对于一个有500,000条记录、索引长度为3bytes（medium integer）的表来说，根据上面的公式计算得到需要做 log(500,000)/log(1024/3*2/(3+4)) + 1 = 4 次搜索。

这个表的索引大概需要 500,000 * 7 * 3/2 = 5.2MB的存储空间（假定典型的索引缓冲区的2/3），因此应该会有更多的索引在内存中，并且可能只需要1到2次调用就能找到对应的记录。

对于写来说，大概需要4次（甚至更多）搜索才能找到新的索引位置，更新记录时通常需要2次搜索。

请注意，前面的讨论中并没有提到应用程序的性能会因为log N的值越大而下降。只要所有的东西都能由操作系统或者SQL服务器缓存起来，那么性能只会因为数据表越大而稍微下降。当数据越来越大之后，就不能全部放到缓存中去了，就会越来越慢了，除非应用程序是被磁盘搜索约束的（它跟随着的log N值增加而增加）。为了避免这种情况，可以在数据量增大以后也随着增大索引缓存容量。对 MyISAM 类型表来说，索引缓存容量是由系统变量 key_buffer_size 控制的。详情请看"7.5.2 Tuning Server Parameters"。

7.2.3 SELECT 查询的速度

通常情况下，想要让一个比较慢的 SELECT ... WHERE 查询变得更快的第一件事就是，先检查看看是否可以增加索引。所有对不同表的访问都通常使用索引。可以使用 EXPLAIN 语句来判断 SELECT 使用了哪些索引。详情请看"7.4.5 How MySQL Uses Indexes"和"7.2.1 EXPLAIN Syntax (Get Information About a SELECT)"。

以下是几个常用的提高 MyISAM 表查询速度的忠告：

想要让MySQL将查询优化的速度更快些，可以在数据表已经加载完全部数据后执行行 ANALYZE TABLE 或运行 myisamchk --analyze 命令。它更新了每个索引部分的值，这个值意味着相同记录的平均值（对于唯一索引来说，这个值则一直都是 1）。MySQL就会在当你使用基于一个非恒量表达式的两表连接时，根据这个值来决定使用哪个索引。想要查看结果，可以在分析完数据表后运行 SHOW INDEX FROM tbl_name 查看 Cardinality 字段的值。myisamchk --description --verbose 显示了索引的分布信息。
想要根据一个索引来排序数据，可以运行 myisamchk --sort-index --sort-records=1 （如果想要在索引 1 上做排序）。这对于有一个唯一索引并且想根据这个索引的顺序依次读取记录的话来说是一个提高查询速度的好办法。不过要注意的是，第一次在一个大表上做排序的话将会耗费很长时间。

7.2.4 MySQL如何优化 WHERE 子句

这个章节讲述了优化程序如何处理 WHERE 子句。例子中使用了 SELECT 语句，但是在 DELETE 和 UPDATE 语句中对 WHERE 子句的优化是一样的。

注意，关于MySQL优化的工作还在继续，因此本章节还没结束。MySQL做了很多优化工作，而不仅仅是文档中提到的这些。

MySQL的一些优化做法如下：

去除不必要的括号：
   ((a AND b) AND c OR (((a AND b) AND (c AND d))))
-> (a AND b AND c) OR (a AND b AND c AND d)
  
展开常量：
   (a<b AND b=c) AND a=5
-> b>5 AND b=c AND a=5
  
去除常量条件（在展开常量时需要）：
   (B>=5 AND B=5) OR (B=6 AND 5=5) OR (B=7 AND 5=6)
-> B=5 OR B=6
  
常量表达示在索引中只计算一次
在单独一个表上做 COUNT(*) 而不使用 WHERE 时， 对于 MyISAM 和 HEAP 表就会直接从表信息中检索结果。在单独一个表上做任何表 NOT NULL 达式查询时也是这样做。
预先探测无效的常量表达式。MySQL会快速探测一些不可能的 SELECT 语句并且不返回任何记录。
当没用 GROUP BY 或分组函数时，HAVING 和 WHERE 合并（COUNT(), MIN() 等也是如此）。
为表连接中的每个表构造一个简洁的 WHERE 语句，以得到更快的 WHERE 计算值并且尽快跳过记录。
查询中所有的常量表都会比其他表更早读取。一个常量表符合以下几个条件：

空表或者只有一条记录。
与在一个 UNIQUE 索引、或一个 PRIMARY KEY 的 WHERE 子句一起使用的表，这里所有的索引部分和常数表达式做比较并且索引部分被定义为 NOT NULL。

以下的几个表都会被当成常量表：
SELECT * FROM t WHERE primary_key=1;
SELECT * FROM t1,t2
    WHERE t1.primary_key=1 AND t2.primary_key=t1.id;
  
MySQL会进各种可能找到表连接最好的连接方法。 如果在 ORDER BY 和 GROUP BY 子句中的所有字段都来自同一个表的话，那么在连接时这个表就会优先处理。
如果有 ORDER BY 子句和一个不同的 GROUP BY 子句，或者如果 ORDER BY 或 GROUP BY 中的字段都来自其他的表而非连接顺序中的第一个表的话，就会创建一个临时表了。
如果使用 SQL_SMALL_RESULT，MySQL就会使用内存临时表了。
所有的表索引都会查询，最好的情况就是所有的索引都会被用到，除非优化程序认为全表扫描的效率更高。同时，数据表扫描是基于判断最好的索引范围超过数据表的30%。 现在，优化程序复杂多了，它基于对一些附加因素的估计，例如表大小，记录总数，I/O块大小，因此就不能根据一个固定的百分比来决定是选择使用索引还是直接扫描数据表。
在某些情况下，MySQL可以直接从索引中取得记录而无需查询数据文件。如果所有在索引中使用的字段都是数字类型的话，只需要用索引树就能完成查询。
每条记录输出之前，那些没有匹配 HAVING 子句的就会被跳过。

以下几个查询速度非常快：
SELECT COUNT(*) FROM tbl_name;

SELECT MIN(key_part1),MAX(key_part1) FROM tbl_name;

SELECT MAX(key_part2) FROM tbl_name
    WHERE key_part1=constant;

SELECT ... FROM tbl_name
    ORDER BY key_part1,key_part2,... LIMIT 10;

SELECT ... FROM tbl_name
    ORDER BY key_part1 DESC, key_part2 DESC, ... LIMIT 10;
以下几个查询都是使用索引树，假使那些索引字段都是数字型：

SELECT key_part1,key_part2 FROM tbl_name WHERE key_part1=val;

SELECT COUNT(*) FROM tbl_name
    WHERE key_part1=val1 AND key_part2=val2;

SELECT key_part2 FROM tbl_name GROUP BY key_part1;
以下几个查询使用索引来取得经过顺序排序后的记录而无需经过独立的排序步骤：

SELECT ... FROM tbl_name
    ORDER BY key_part1,key_part2,... ;

SELECT ... FROM tbl_name
    ORDER BY key_part1 DESC, key_part2 DESC, ... ;
7.2.5 MySQL 如何优化 OR 子句


Index Merge 方法用于使用 ref, ref_or_null, 或 range 扫描取得的记录合并起来放到一起作为结果。这种方法在表条件是或条件 ref, ref_or_null, 或 range ，并且这些条件可以用不同的键时采用。
"join"类型的优化是从 MySQL 5.0.0 开始才有的，代表者在索引的性能上有着标志性的改进，因为使用老规则的话，数据库最多只能对每个引用表使用一个索引。
在 EXPLAIN 的结果中，这种方法在 type 字段中表现为 index_merge。这种情况下，key 字段包含了所有使用的索引列表，并且 key_len 字段包含了使用的索引的最长索引部分列表。
例如：
SELECT * FROM tbl_name WHERE key_part1 = 10 OR key_part2 = 20;

SELECT * FROM tbl_name
    WHERE (key_part1 = 10 OR key_part2 = 20) AND non_key_part=30;

SELECT * FROM t1,t2
    WHERE (t1.key1 IN (1,2) OR t1.key2 LIKE 'value%')
    AND t2.key1=t1.some_col;

SELECT * FROM t1,t2
    WHERE t1.key1=1
    AND (t2.key1=t1.some_col OR t2.key2=t1.some_col2);
  
7.2.6 MySQL 如何优化 IS NULL


MySQL在 col_name IS NULL 时做和 col_name = constant_value 一样的优化。例如，MySQL使用索引或者范围来根据 IS NUL L搜索 NULL。
SELECT * FROM tbl_name WHERE key_col IS NULL;

SELECT * FROM tbl_name WHERE key_col <=> NULL;

SELECT * FROM tbl_name
    WHERE key_col=const1 OR key_col=const2 OR key_col IS NULL;
如果一个 WHERE 子句包括了一个 col_name IS NULL 条件，并且这个字段声明为 NOT NULL，那么这个表达式就会被优化。当字段可能无论如何都会产生 NULL 值时，就不会再做优化了；例如，当它来自一个 LEFT JOIN 中右边的一个表时。

MySQL 4.1.1或更高会对连接 col_name = expr AND col_name IS NULL 做额外的优化， 常见的就是子查询。EXPLAIN 当优化起作用时会显示 ref_or_null。

优化程序会为任何索引部分处理 IS NULL。

以下几个例子中都做优化了，假使字段 a 和 表 t2 中 b 有索引了：

SELECT * FROM t1 WHERE t1.a=expr OR t1.a IS NULL;

SELECT * FROM t1,t2 WHERE t1.a=t2.a OR t2.a IS NULL;

SELECT * FROM t1,t2
    WHERE (t1.a=t2.a OR t2.a IS NULL) AND t2.b=t1.b;

SELECT * FROM t1,t2
    WHERE t1.a=t2.a AND (t2.b=t1.b OR t2.b IS NULL);

SELECT * FROM t1,t2
    WHERE (t1.a=t2.a AND t2.a IS NULL AND ...)
    OR (t1.a=t2.a AND t2.a IS NULL AND ...);
ref_or_null 首先读取引用键，然后独立扫描键值为 NULL 的记录。

请注意，优化程序只会处理一个 IS NULL 级别。下面的查询中，MySQL只会使用键来查询表达式 (t1.a=t2.a AND t2.a IS NULL) 而无法使在 b 上使用索引部分：

SELECT * FROM t1,t2
     WHERE (t1.a=t2.a AND t2.a IS NULL)
     OR (t1.b=t2.b AND t2.b IS NULL);
  
7.2.7 MySQL 如何优化 DISTINCT

在很多情况下，DISTINCT 和 ORDER BY 一起使用时就会创建一个临时表。

注意，由于 DISTINCT 可能需要用到 GROUP BY，就需要明白MySQL在 ORDER BY 或 HAVING 子句里的字段不在选中的字段列表中时是怎么处理的。详情请看"13.9.3 GROUP BY with Hidden Fields"。

当 LIMIT row_count 和 DISTINCT 一起使用时，MySQL在找到 row_count 不同记录后就会立刻停止搜索了。

如果没有用到来自查询中任何表的字段时，MySQL在找到第一个匹配记录后就会停止搜索这些没没用到的表了。在下面的情况中，假使 t1 在 t2 前就使用了（可以通过 EXPLAIN 分析知道），MySQL就会在从 t2 中找到第一条记录后就不再读 t2 了（为了能和中 t1 的任何特定记录匹配）：

SELECT DISTINCT t1.a FROM t1,t2 where t1.a=t2.a;
7.2.8 MySQL 如何优化 LEFT JOIN 和 RIGHT JOIN


A LEFT JOIN B join_condition 在MySQL中实现如下：
表 B 依赖于表 A 以及其依赖的所有表。
表 A 依赖于在 LEFT JOIN 条件中的所有表（除了 B）。
LEFT JOIN 条件用于决定如何从表 B 中读取记录了（换句话说，WHERE 子句中的任何条件都对此不起作用）。
所有标准的连接优化都会执行，例外的情况是有一个表总是在它依赖的所有表之后被读取。如果这是一个循环的依赖关系，那么MySQL会认为这是错误的。
所有的标准 WHERE 优化都会执行。
如果 A 中有一条记录匹配了 WHERE 子句，但是 B 中没有任何记录匹配 ON 条件，那么就会产生一条 B 记录，它的字段值全都被置为 NULL。
如果使用 LEFT JOIN 来搜索在一些表中不存在的记录，并且 WHERE 部分中有检测条件：col_name IS NULL，col_name 字段定义成 NOT NULL 的话，MySQL就会在找到一条匹配 LEFT JOIN 条件的记录（用于和特定的索引键做联合）后停止搜索了。

RIGHT JOIN 的实现和 LEFT JOIN 类似，不过表的角色倒过来了。
连接优化程序计算了表连接的次序。表读取的顺序是由 LEFT JOIN 强行指定的，而且使用 STRAIGHT_JOIN 能帮助连接优化程序更快地执行，因为这就会有更少的表排队检查了。注意，这里是指如果你执行下面这种类型的查询后，MySQL就会对 b 做一次全表扫描，因为 LEFT JOIN 强制要求了必须在读 d 之前这么做：
SELECT *
    FROM a,b LEFT JOIN c ON (c.key=a.key) LEFT JOIN d ON (d.key=a.key)
    WHERE b.key=d.key;
解决这种情况的方法是按照如下方式重写查询：

SELECT *
    FROM b,a LEFT JOIN c ON (c.key=a.key) LEFT JOIN d ON (d.key=a.key)
    WHERE b.key=d.key;
从4.0.14开始，MySQL做如下 LEFT JOIN 优化：如果对产生的 NULL 记录 WHERE 条件总是 假，那么 LEFT JOIN 就会变成一个普通的连接。
例如，下面的查询中如果 t2.column1 的值是 NULL 的话，WHERE 子句的结果就是假了：

SELECT * FROM t1 LEFT JOIN t2 ON (column1) WHERE t2.column2=5;
因此，这就可以安全的转换成一个普通的连接查询：

SELECT * FROM t1,t2 WHERE t2.column2=5 AND t1.column1=t2.column1;
这查询起来就更快了，因为如果能有一个更好的查询计划的话，MySQL就会在 t1 之前就用到 t2 了。想要强行指定表顺序的话，可以使用 STRAIGHT_JOIN。