7.2.1 EXPLAIN 语法（得到SELECT 的相关信息）

EXPLAIN tbl_name
或者:

EXPLAIN SELECT select_options
EXPLAIN 语句可以被当作 DESCRIBE 的同义词来用，也可以用来获取一个MySQL要执行的 SELECT 语句的相关信息。

EXPLAIN tbl_name 语法和 DESCRIBE tbl_name 或 SHOW COLUMNS FROM tbl_name 一样。
当在一个 SELECT 语句前使用关键字 EXPLAIN 时，MYSQL会解释了即将如何运行该 SELECT 语句，它显示了表如何连接、连接的顺序等信息。
本章节主要讲述了第二种 EXPLAIN 用法。

在 EXPLAIN 的帮助下，您就知道什么时候该给表添加索引，以使用索引来查找记录从而让 SELECT 运行更快。

如果由于不恰当使用索引而引起一些问题的话，可以运行 ANALYZE TABLE 来更新该表的统计信息，例如键的基数，它能帮您在优化方面做出更好的选择。详情请看"14.5.2.1 ANALYZE TABLE Syntax"。

您还可以查看优化程序是否以最佳的顺序来连接数据表。为了让优化程序按照 SELECT 语句中的表名的顺序做连接，可以在查询的开始使用 SELECT STRAIGHT_JOIN 而不只是 SELECT。

EXPLAIN 返回了一行记录，它包括了 SELECT 语句中用到的各个表的信息。这些表在结果中按照MySQL即将执行的查询中读取的顺序列出来。MySQL用一次扫描多次连接（single-sweep, multi-join） 的方法来解决连接。这意味着MySQL从第一个表中读取一条记录，然后在第二个表中查找到对应的记录，然后在第三个表中查找，依次类推。当所有的表都扫描完了，它输出选择的字段并且回溯所有的表，直到找不到为止，因为有的表中可能有多条匹配的记录下一条记录将从该表读取，再从下一个表开始继续处理。

在MySQL version 4.1中，EXPLAIN 输出的结果格式改变了，使得它更适合例如 UNION 语句、子查询以及派生表的结构。更令人注意的是，它新增了2个字段： id 和 select_type。当你使用早于MySQL 4.1的版本就看不到这些字段了。

EXPLAIN 结果的每行记录显示了每个表的相关信息，每行记录都包含以下几个字段：

id
本次 SELECT 的标识符。在查询中每个 SELECT 都有一个顺序的数值。
select_type
SELECT 的类型，可能会有以下几种：
SIMPLE
简单的 SELECT （没有使用 UNION 或子查询）
PRIMARY
最外层的 SELECT。
UNION
第二层，在SELECT 之后使用了 UNION 。
DEPENDENT UNION
UNION 语句中的第二个 SELECT，依赖于外部子查询
SUBQUERY
子查询中的第一个 SELECT
DEPENDENT SUBQUERY
子查询中的第一个 SUBQUERY 依赖于外部的子查询
DERIVED
派生表 SELECT（FROM 子句中的子查询）
table
记录查询引用的表。
type
表连接类型。以下列出了各种不同类型的表连接，依次是从最好的到最差的：
system
表只有一行记录（等于系统表）。这是 const 表连接类型的一个特例。
const
表中最多只有一行匹配的记录，它在查询一开始的时候就会被读取出来。由于只有一行记录，在余下的优化程序里该行记录的字段值可以被当作是一个恒定值。const 表查询起来非常快，因为只要读取一次！const 用于在和 PRIMARY KEY 或 UNIQUE 索引中有固定值比较的情形。下面的几个查询中，tbl_name 就是 const 表了：
SELECT * FROM tbl_name WHERE primary_key=1;
SELECT * FROM tbl_name
WHERE primary_key_part1=1 AND primary_key_part2=2;
eq_ref
从该表中会有一行记录被读取出来以和从前一个表中读取出来的记录做联合。与 const 类型不同的是，这是最好的连接类型。它用在索引所有部分都用于做连接并且这个索引是一个 PRIMARY KEY 或 UNIQUE 类型。eq_ref 可以用于在进行"="做比较时检索字段。比较的值可以是固定值或者是表达式，表达式中可以使用表里的字段，它们在读表之前已经准备好了。以下的几个例子中，MySQL使用了 eq_ref 连接来处理 ref_table：

SELECT * FROM ref_table,other_table
WHERE ref_table.key_column=other_table.column;
SELECT * FROM ref_table,other_table
WHERE ref_table.key_column_part1=other_table.column
AND ref_table.key_column_part2=1;
ref
该表中所有符合检索值的记录都会被取出来和从上一个表中取出来的记录作联合。ref 用于连接程序使用键的最左前缀或者是该键不是 PRIMARY KEY 或 UNIQUE 索引（换句话说，就是连接程序无法根据键值只取得一条记录）的情况。当根据键值只查询到少数几条匹配的记录时，这就是一个不错的连接类型。ref 还可以用于检索字段使用 = 操作符来比较的时候。以下的几个例子中，MySQL将使用 ref 来处理 ref_table：
SELECT * FROM ref_table WHERE key_column=expr;
SELECT * FROM ref_table,other_table
WHERE ref_table.key_column=other_table.column;
SELECT * FROM ref_table,other_table
WHERE ref_table.key_column_part1=other_table.column
AND ref_table.key_column_part2=1;
ref_or_null
这种连接类型类似 ref，不同的是MySQL会在检索的时候额外的搜索包含 NULL 值的记录。这种连接类型的优化是从MySQL 4.1.1开始的，它经常用于子查询。在以下的例子中，MySQL使用 ref_or_null 类型来处理 ref_table：
SELECT * FROM ref_table
WHERE key_column=expr OR key_column IS NULL;
详情请看"7.2.6 How MySQL Optimizes IS NULL"。

index_merge
这种连接类型意味着使用了 Index Merge 优化方法。这种情况下，key字段包括了所有使用的索引，key_len 包括了使用的键的最长部分。详情请看"7.2.5 How MySQL Optimizes OR Clauses"。
unique_subquery
这种类型用例如一下形式的 IN 子查询来替换 ref：
value IN (SELECT primary_key FROM single_table WHERE some_expr)
unique_subquery 只是用来完全替换子查询的索引查找函数效率更高了。

index_subquery
这种连接类型类似 unique_subquery。它用子查询来代替 IN，不过它用于在子查询中没有唯一索引的情况下，例如以下形式：
value IN (SELECT key_column FROM single_table WHERE some_expr)
range
只有在给定范围的记录才会被取出来，利用索引来取得一条记录。key 字段表示使用了哪个索引。key_len 字段包括了使用的键的最长部分。这种类型时 ref 字段值是 NULL。range 用于将某个字段和一个定植用以下任何操作符比较时 =, <>, >, >=, <, <=, IS NULL, <=>, BETWEEN, 或 IN：
SELECT * FROM tbl_name
WHERE key_column = 10;

SELECT * FROM tbl_name
WHERE key_column BETWEEN 10 and 20;

SELECT * FROM tbl_name
WHERE key_column IN (10,20,30);

SELECT * FROM tbl_name
WHERE key_part1= 10 AND key_part2 IN (10,20,30);
index
连接类型跟 ALL 一样，不同的是它只扫描索引树。它通常会比 ALL 快点，因为索引文件通常比数据文件小。MySQL在查询的字段知识单独的索引的一部分的情况下使用这种连接类型。
ALL
将对该表做全部扫描以和从前一个表中取得的记录作联合。这时候如果第一个表没有被标识为 const 的话就不大好了，在其他情况下通常是非常糟糕的。正常地，可以通过增加索引使得能从表中更快的取得记录以避免 ALL。
possible_keys
possible_keys 字段是指MySQL在搜索表记录时可能使用哪个索引。注意，这个字段完全独立于 EXPLAIN 显示的表顺序。这就意味着 possible_keys 里面所包含的索引可能在实际的使用中没用到。如果这个字段的值是 NULL，就表示没有索引被用到。这种情况下，就可以检查 WHERE 子句中哪些字段那些字段适合增加索引以提高查询的性能。就这样，创建一下索引，然后再用 EXPLAIN 检查一下。详细的查看章节"14.2.2 ALTER TABLE Syntax"。想看表都有什么索引，可以通过 SHOW INDEX FROM tbl_name 来看。
 
key
key 字段显示了MySQL实际上要用的索引。当没有任何索引被用到的时候，这个字段的值就是 NULL。想要让MySQL强行使用或者忽略在 possible_keys 字段中的索引列表，可以在查询语句中使用关键字FORCE INDEX, USE INDEX, 或 IGNORE INDEX。如果是 MyISAM 和 BDB 类型表，可以使用 ANALYZE TABLE 来帮助分析使用使用哪个索引更好。如果是 MyISAM 类型表，运行命令 myisamchk --analyze 也是一样的效果。详细的可以查看章节"14.5.2.1 ANALYZE TABLE Syntax"和"5.7.2 Table Maintenance and Crash Recovery"。
key_len
key_len 字段显示了MySQL使用索引的长度。当 key 字段的值为 NULL 时，索引的长度就是 NULL。注意，key_len 的值可以告诉你在联合索引中MySQL会真正使用了哪些索引。
ref
ref 字段显示了哪些字段或者常量被用来和 key 配合从表中查询记录出来。
rows
rows 字段显示了MySQL认为在查询中应该检索的记录数。
Extra
本字段显示了查询中MySQL的附加信息。以下是这个字段的几个不同值的解释：
Distinct
MySQL当找到当前记录的匹配联合结果的第一条记录之后，就不再搜索其他记录了。
Not exists
MySQL在查询时做一个 LEFT JOIN 优化时，当它在当前表中找到了和前一条记录符合 LEFT JOIN 条件后，就不再搜索更多的记录了。下面是一个这种类型的查询例子：
SELECT * FROM t1 LEFT JOIN t2 ON t1.id=t2.id
WHERE t2.id IS NULL;
假使 t2.id 定义为 NOT NULL。这种情况下，MySQL将会扫描表 t1 并且用 t1.id 的值在 t2 中查找记录。当在 t2 中找到一条匹配的记录时，这就意味着 t2.id 肯定不会都是 NULL，就不会再在 t2 中查找相同 id 值的其他记录了。也可以这么说，对于 t1 中的每个记录，MySQL只需要在 t2 中做一次查找，而不管在 t2 中实际有多少匹配的记录。

range checked for each record (index map: #)
MySQL没找到合适的可用的索引。取代的办法是，对于前一个表的每一个行连接，它会做一个检验以决定该使用哪个索引（如果有的话），并且使用这个索引来从表里取得记录。这个过程不会很快，但总比没有任何索引时做表连接来得快。
Using filesort
MySQL需要额外的做一遍从而以排好的顺序取得记录。排序程序根据连接的类型遍历所有的记录，并且将所有符合 WHERE 条件的记录的要排序的键和指向记录的指针存储起来。这些键已经排完序了，对应的记录也会按照排好的顺序取出来。详情请看"7.2.9 How MySQL Optimizes ORDER BY"。
Using index
字段的信息直接从索引树中的信息取得，而不再去扫描实际的记录。这种策略用于查询时的字段是一个独立索引的一部分。
Using temporary
MySQL需要创建临时表存储结果以完成查询。这种情况通常发生在查询时包含了GROUP BY 和 ORDER BY 子句，它以不同的方式列出了各个字段。
Using where
WHERE 子句将用来限制哪些记录匹配了下一个表或者发送给客户端。除非你特别地想要取得或者检查表种的所有记录，否则的话当查询的 Extra 字段值不是 Using where 并且表连接类型是 ALL 或 index 时可能表示有问题。

如果你想要让查询尽可能的快，那么就应该注意 Extra 字段的值为Using filesort 和 Using temporary 的情况。
你可以通过 EXPLAIN 的结果中 rows 字段的值的乘积大概地知道本次连接表现如何。它可以粗略地告诉我们MySQL在查询过程中会查询多少条记录。如果是使用系统变量 max_join_size 来取得查询结果，这个乘积还可以用来确定会执行哪些多表 SELECT 语句。详情请看"7.5.2 Tuning Server Parameters"。

下面的例子展示了如何通过 EXPLAIN 提供的信息来较大程度地优化多表联合查询的性能。

假设有下面的 SELECT 语句，正打算用 EXPLAIN 来检测：

EXPLAIN SELECT tt.TicketNumber, tt.TimeIn,
            tt.ProjectReference, tt.EstimatedShipDate,
            tt.ActualShipDate, tt.ClientID,
            tt.ServiceCodes, tt.RepetitiveID,
            tt.CurrentProcess, tt.CurrentDPPerson,
            tt.RecordVolume, tt.DPPrinted, et.COUNTRY,
            et_1.COUNTRY, do.CUSTNAME
        FROM tt, et, et AS et_1, do
        WHERE tt.SubmitTime IS NULL
            AND tt.ActualPC = et.EMPLOYID
            AND tt.AssignedPC = et_1.EMPLOYID
            AND tt.ClientID = do.CUSTNMBR;
在这个例子中，先做以下假设：


要比较的字段定义如下：
Table	Column	Column Type
tt	ActualPC	CHAR(10)
tt	AssignedPC	CHAR(10)
tt	ClientID	CHAR(10)
et	EMPLOYID	CHAR(15)
do	CUSTNMBR	CHAR(15)

数据表的索引如下：
Table	Index
tt	ActualPC
tt	AssignedPC
tt	ClientID
et	EMPLOYID (primary key)
do	CUSTNMBR (primary key)

tt.ActualPC 的值是不均匀分布的。

在任何优化措施未采取之前，经过 EXPLAIN 分析的结果显示如下：
table type possible_keys key  key_len ref  rows  Extra
et    ALL  PRIMARY       NULL NULL    NULL 74
do    ALL  PRIMARY       NULL NULL    NULL 2135
et_1  ALL  PRIMARY       NULL NULL    NULL 74
tt    ALL  AssignedPC,   NULL NULL    NULL 3872
           ClientID,
           ActualPC
      range checked for each record (key map: 35)
由于字段 type 的对于每个表值都是 ALL，这个结果意味着MySQL对所有的表做一个迪卡尔积；这就是说，每条记录的组合。这将需要花很长的时间，因为需要扫描每个表总记录数乘积的总和。在这情况下，它的积是 74 * 2135 * 74 * 3872 = 45,268,558,720 条记录。如果数据表更大的话，你可以想象一下需要多长的时间。

在这里有个问题是当字段定义一样的时候，MySQL就可以在这些字段上更快的是用索引（对 ISAM 类型的表来说，除非字段定义完全一样，否则不会使用索引）。在这个前提下，VARCHAR 和 CHAR是一样的除非它们定义的长度不一致。由于 tt.ActualPC 定义为 CHAR(10)，et.EMPLOYID 定义为 CHAR(15)，二者长度不一致。
为了解决这个问题，需要用 ALTER TABLE 来加大 ActualPC 的长度从10到15个字符：

mysql> ALTER TABLE tt MODIFY ActualPC VARCHAR(15);
现在 tt.ActualPC 和 et.EMPLOYID 都是 VARCHAR(15)
了。再来执行一次 EXPLAIN 语句看看结果：

table type   possible_keys key     key_len ref         rows    Extra
tt    ALL    AssignedPC,   NULL    NULL    NULL        3872    Using
             ClientID,                                         where
             ActualPC
do    ALL    PRIMARY       NULL    NULL    NULL        2135
      range checked for each record (key map: 1)
et_1  ALL    PRIMARY       NULL    NULL    NULL        74
      range checked for each record (key map: 1)
et    eq_ref PRIMARY       PRIMARY 15      tt.ActualPC 1
这还不够，它还可以做的更好：现在 rows 值乘积已经少了74倍。这次查询需要用2秒钟。
第二个改变是消除在比较 tt.AssignedPC = et_1.EMPLOYID 和 tt.ClientID = do.CUSTNMBR 中字段的长度不一致问题：

mysql> ALTER TABLE tt MODIFY AssignedPC VARCHAR(15),
    ->                MODIFY ClientID   VARCHAR(15);
现在 EXPLAIN 的结果如下：

table type   possible_keys key      key_len ref           rows Extra
et    ALL    PRIMARY       NULL     NULL    NULL          74
tt    ref    AssignedPC,   ActualPC 15      et.EMPLOYID   52   Using
             ClientID,                                         where
             ActualPC
et_1  eq_ref PRIMARY       PRIMARY  15      tt.AssignedPC 1
do    eq_ref PRIMARY       PRIMARY  15      tt.ClientID   1
这看起来已经是能做的最好的结果了。
遗留下来的问题是，MySQL默认地认为字段tt.ActualPC 的值是均匀分布的，然而表 tt 并非如此。幸好，我们可以很方便的让MySQL分析索引的分布：

mysql> ANALYZE TABLE tt;
到此为止，表连接已经优化的很完美了，EXPLAIN 的结果如下：

table type   possible_keys key     key_len ref           rows Extra
tt    ALL    AssignedPC    NULL    NULL    NULL          3872 Using
             ClientID,                                        where
             ActualPC
et    eq_ref PRIMARY       PRIMARY 15      tt.ActualPC   1
et_1  eq_ref PRIMARY       PRIMARY 15      tt.AssignedPC 1
do    eq_ref PRIMARY       PRIMARY 15      tt.ClientID   1
请注意，EXPLAIN 结果中的 rows 字段的值也是MySQL的连接优化程序大致猜测的，请检查这个值跟真实值是否基本一致。如果不是，可以通过在 SELECT 语句中使用 STRAIGHT_JOIN 来取得更好的性能，同时可以试着在 FROM
分句中用不同的次序列出各个表。