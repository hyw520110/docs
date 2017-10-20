7.4优化数据库结构

7.4.1设计选择

MySQL将记录数据和索引数据分别存放在不同的文件里。其他很多（几乎所有）数据库都将这记录和索引数据存在同一个文件中。我们相信MySQL的选择对于现在更大范围的系统更合适。

另一个存储记录数据的方法是将每个字段的信息保存在独立的区域中（例如 SDBM 和Focus）。这当每个查询都要访问不只一个字段的时候会打击性能。由于当访问越多的字段后，性能下降的越厉害，因此我们认为这种模式不适合正常目的的数据库。

更多的情况是把索引和数据保存在一起(例如 Oracle/Sysbase等)。这样的话，就能在索引的叶子页面找到记录的信息。这种布局的有利之处在于，很多时候由于索引被缓存的比较好，因此就能节省磁盘读取，不过也有如下缺点：

由于需要通过读取索引才能得到数据，因此扫描表就更慢了。
查询时只能根据索引来取得数据。
需要更多的磁盘空间，因为必须从节点中复制索引(不能将记录保存在节点中)。
删除会使表变得更慢(因为删除时并没有更新节点中的索引)。
很难只缓存索引数据。
7.4.2让数据变得更小巧灵活

优化的最基本原则之一就是尽可能把数据表设计的占用更少磁盘空间。这能得到巨大的性能改善，因为磁盘读取比较快，并且越小的表在处理查询内容时只需更少的主内存。在小点的字段上做索引也只需更少的资源负载。

MySQL支持很多种不同的表类型以及记录格式。可以决定每个表要采用那种存储引擎/索引方式。根据不同的应用程序选择适当的表格式能大大提高性能。详情请看“15MySQL Storage Engines and Table Types”。

用以下方法可以提高表性能同时节省存储空间：

尽可能使用最有效(最小的)数据类型。MySQL有好几种特定的类型能节省磁盘和内存。
尽可能使用更小的整数类型。例如，MEDIUMINT通常比更合适 INT。
尽可能定义字段类型为 NOT NULL。这会运行的更快，而且每个字段都会节省1个bit。如果在应用程序中确实需要用到 NULL，那么就明确的指定它。不过要避免所有的字段默认值是 NULL。
在 MyISAM 表中，如果没有用到任何变长字段(VARCHAR, TEXT, 或 BLOB字段)的话，那么就采用固定大小的记录格式。这样速度更快，不过可能会浪费点空间。详情请看“15.1.3 MyISAMTable Storage Formats”。
表的主索引应尽可能短。这样的话会每条记录都有名字标识且更高效。
只创建确实需要的索引。索引有利于检索记录，但是不利于快速保存记录。如果总是要在表的组合字段上做搜索，那么就在这些字段上创建索引。索引的第一部分必须是最常使用的字段.如果总是需要用到很多字段，首先就应该多复制这些字段，使索引更好的压缩。
一个字段很有可能在最开始的一些数量字符是各不相同的，因此在这些字符上做索引更合适。MySQL支持在一个字段的最左部分字符做索引。索引越短，速度越快，不仅是因为它占用更少的磁盘空间，也因为这提高了索引缓存的命中率，由此减少了磁盘搜索。详情请看“7.5.2Tuning Server Parameters”。
在某些情况下，把一个频繁扫描的表分割成两个更有利。在对动态格式表扫描以取得相关记录时，它可能使用更小的静态格式表的情况下更是如此。
7.4.3字段索引

所有的MySQL字段类型都能被索引。在相关字段上做索引对提高 SELECT 语句的性能最有效。

每个表的最大索引长度以及最多索引数量是由各自的存储引擎定义好了的。详情请看“15 MySQL Storage Engines and Table Types”。所有的存储引擎对每个表都至少可以支持16个索引，索引长度最小是 256 字节。大部分存储引擎的限制更高。

索引格式中使用 col_name(length) 语法，就能只对 CHAR 或 VARCHAR 字段最前面的 length 个字符做索引。象类似这样只对字段的前缀部分做索引能让索引文件更小。

MyISAM 和 InnoDB (从MySQL 4.0.14开始)存储引擎还支持在 BLOB 和 TEXT 字段上做索引，但是必须指定索引的前缀长度，例如：

CREATE TABLE test (blob_col BLOB, INDEX(blob_col(10))); 
前缀的长度可以多达255字节(从MySQL 4.1.2开始，MyISAM 和 InnoDB 表支持1000字节)。注意，前缀长度限制是以字节数衡量的，然而 CREATE TABLE 语句中的前缀长度理解成为字符个数。因此在指定字段索引前缀长度时要考虑到使用多字节字符集字段的情况了。

从MySQL 3.23.23开始，就可以创建 FULLTEXT 索引了，它们使用全文搜索。只有 MyISAM 表支持对 CHAR,VARCHAR 和 TEXT 字段做 FULLTEXT 索引。只对整个字段检索有效，不支持部分(前缀)检索。详情请看“13.6 Full-Text Search Functions”。

从MySQL 4.1.0开始，还可以空间类型字段上做索引。目前，只有 MyISAM 存储引擎支持空间类型。空间索引使用R树索引。

MEMORY (HEAP) 存储引擎支持哈希索引，从MySQL 4.1.0开始，它也支持B树索引。

7.4.4 多字段索引

MySQL可以在多个字段上创建索引，可以由多达15个字段组成。对特定的字段类型，还可以使用前缀索引(详情请看"7.4.3 Column Indexes”)。

多字段索引可以认为是由索引字段的值连接在一起而成，且经过排序之后的数组。

MySQL以如下方法使用多字段索引：在 WHERE 子句中指定了已知数量的索引的第一个字段，查询就很快了，甚至无需指定其他字段的值。

假定一个表结构如下：

CREATE TABLE test (
    id INT NOT NULL,
    last_name CHAR(30) NOT NULL,
    first_name CHAR(30) NOT NULL,
    PRIMARY KEY (id),
    INDEX name (last_name,first_name));
索引 name 覆盖了 last_name 和 first_name 字段。这个索引在字段 last_name 上或 last_name 和 first_name 一起的指定范围内查询时能起到作用。因此这个索引在以下几个查询中都会被用到：

SELECT * FROM test WHERE last_name='Widenius';

SELECT * FROM test
    WHERE last_name='Widenius' AND first_name='Michael';

SELECT * FROM test
    WHERE last_name='Widenius'
    AND (first_name='Michael' OR first_name='Monty');

SELECT * FROM test
    WHERE last_name='Widenius'
    AND first_name >='M' AND first_name < 'N';

不过，索引 name 在以下几个查询中不会被用到：

SELECT * FROM test WHERE first_name='Michael';

SELECT * FROM test
    WHERE last_name='Widenius' OR first_name='Michael';
关于MySQL如何使用索引来改善查询性能的方式在下个章节中具体讨论。