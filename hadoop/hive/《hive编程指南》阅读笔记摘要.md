第一二章 基础知识、基础操作
hive的缺点
1、hive不支持记录级别的增删改操作，但是用户可以通过查询生成新表或者将查询结果导入到文件中。
2、Hive的查询延时很严重，因为MapReduce job的启动过程消耗很长时间，所以不能用在交互查询系统中。
3、hive不支持事务。

hive最适合做数据仓库
HiveQL不符合ansi sql标准，和mysql、oracle的sql有很多差异。

mapreduce处理输入的文档时，传给mapper的key是文档中这行的起始位置的字符偏移量，value是这行文本。
对程序员透明的事情，也是hadoop神奇的地方是，hadoop会自动执行排序sort和重新洗牌发牌shuffle的过程：对mapper输出的key/value进行排序，然后洗牌发牌：将相同键的key/value对发给同一个reducer。

访问hive的方式有Cli，HWI（web界面），JDBC，ODBC，thrift（hive有thrift服务器）等方式。
所有的查询和操作都会进入到Driver模块
hive不必和mapreduce服务部署在相同的节点上
hive的元数据metadata会保存在关系型数据库中，如Derby、mysql等，metadata包括表模式（表结构）等信息

HBase相对于hive的优点：
他有hive无法提供的数据库特性，如行级别的更新，快速的查询响应时间，支持行级事务（不支持多行事务）等

HBase和Hadoop什么关系：Hbase使用HDFS保存数据。
Hbase没有提供类似SQL的查询语言，但是有Hive on Hbase、phoenix等假设在hbase上的工具帮助实现了SQL功能

hivesql中的关键字是不区分大小写的
一个linux系统上，不同的用户可以有自己不同的数据仓库，可以使用下面的语句配置仓库的目录（在HDFS系统上），可以把下边这句命令写进用户主目录下.bashrc中就可以了：
set hive.metastore.warehouse.dir=/..................

存储元数据的数据库服务器：元数据的存储量其实非常的小，但是如果元数据服务器是单点的话，也会有单点问题，所以如果资源不紧张，也应该配置成主备模式。
仓库目录属性是hive.metastore.warehouse.dir，属性值最好是/hive/warehouse或/user/hive/warehouse，后者是默认值

hive --help
hive可以启动不同的服务，包括
Service List: beeline cleardanglingscratchdir cli hbaseimport hbaseschematool help hiveburninclient hiveserver2 hplsql hwi jar lineage llapdump llap llapstatus metastore metatool orcfiledump rcfilecat schemaTool version
cli是默认的
hiveserver/hiveserver2是监听其他进程的thrift连接的守护进程
hwi是一个web界面，因为hive通常不会安装到所有节点，使用hwi就不需要登录到那台安装了hive的节点去执行hql了（启动时会去寻找hwi的war包）

hive中几种命名空间
1、hivevar      可读/可写    用户自定义变量
2、hiveconf     可读/可写    hive相关的配置属性
3、system       可读/可写    java定义的配置属性
4、env          只可读       shell环境变量

hive> set;             打印出所有命名空间中的所有变量
hive> set -v;     打印更多，还会打印出hadoop定义的所有属性

执行查询的几种方式：
1、-e
$ hive -S -e "select * from mytable limit 3" > /home/will/hive/mydata.txt
-S表示静默执行，不打印到控制台，并且会去掉提示语句，只保留数据
-e 是执行查询语句
2、-f
按惯例，hive查询文件保存为.q或者.hql后缀的文件
$ hive -f /...../abc.hql
或者
hive> source /...../abc.hql          //类似shell中的source也是执行shell脚本文件

hive>         敲击TAB见可以显示所有关键字或函数名
cat  .hivehistory            到用户主目录下查看hive操作历史文件   .hivehistory

在hive cli环境中执行一些简单的shell命令
hive> ! ls /root;

在hive cli环境中执行hadoop dfs命令
hive> dfs -ls /;

hive脚本中以 --  双划线开头的行表示注释

执行查询时，显示表头，即表字段名称
hive> set hive.cli.print.header=true;


第三章 数据类型和文件格式
hive中的数据类型包括基本数据类型和集合数据类型（array、map、struct），通常，关系型数据库中没有集合数据类型，而是用关系表关联表示集合。
原因在于：hive中将相关数据存储在一起，来减少磁盘寻址操作，提高性能。

基本数据类型都是对java中接口的实现，所以类型的具体行为细节和java中对应的类型完全一致，如string类型实现的就是java中String类型
TIMESTAMP表示UTC时间，可以是整数（距离unix新纪元时间的秒数）；浮点数（距离unix新纪元时间的秒数，小数部分表示纳秒）；字符串（JDBC兼容的java.sql.Timestamp格式，YYYY-MM-DD hh:mm:ss:fffffffff）
如果一个表的表结构中有3列，而实际的数据文件中每行记录有5列，那么在hive中最后两列会被省略掉

CSV：Comma-Separated Values，逗号分隔值
TSV：Tab-Separated Values，制表符分隔值

hive中默认的行分隔符和字段分隔符
\n         文本文件中每行是一条记录
^A(\001)   用于分隔字段,\001是^A的八进制数
^B(\002)   用于分隔array或struct中的元素，或者作为map中每对key/value之间的分隔符
^C(\003)   用于分隔map中每对key/value中的key和value
在创建表结构时，如果使用默认的分隔符，就不必声明，否则，需要显式地声明
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
COLLECTION ITEMS TERMINATED BY '\002'
MAP KEYS TERMINATED BY '\003'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

写时模式：数据在写入数据库时对模式进行检查，传统数据库都是写时模式；
读时模式：在查询阶段做数据验证，hive使用此模式；
对于hive表结构和文件不匹配的情况，hive会尽量做适配：
    文件中字段数量少于表字段数量，字段值就用null表示
    文件中字段数量多余表字段数量，文件中多余的字段自动截取
    表字段是数值型，文件中字段值有非数值型的字符串，字段值用null表示


第四章 HiveQL：数据定义

hive中的数据库本质上只是表的一个目录或者命名空间，用来组织表
hive有一个默认的数据库default，如果没有显式地指定数据库，默认是default库
创建数据库
create database if not exists test;
显示所有数据库
show databases;
show databases like 't*';

hive会为每个数据库创建一个目录，数据库中的表对应该目录下的子目录
default数据库是个例外，这个数据库没有自己的目录，所以default下的表会直接在仓库目录下创建子目录，如/hive/warehouse/tablename1/
如test库目录是/hive/warehouse/test.db或/usr/hive/warehouse/test.db
当执行create database操作时，hive会创建目录，如/hive/warehouse/test.db

创建数据库时可以指定描述信息：
create database if not exists databasename comment 'aaaaaaaaaaaaaaa';
create database if not exists databasename1 with dbproperties ('a'='b','c'='d');
describe database extended databasename1;        可以显示出数据库的属性信息
drop database databasename;
drop database if exists databasename;
默认情况下，hive不允许删除一个包含表的数据库；解决办法，一是可以先手动删除表再删除数据库；二是使用cascade关键字
drop database if exists databasename cascade;
数据库被删除时，对应的hdfs上的目录也会被删除；

drop table if exists abc;
create table abc(
  aaa        string comment ‘aaaaaaaaa’, 
  bbb        date
)
comment 'description of abc'
row format delimited
fields terminated by '\001'
lines terminated by '\n'
stored as textfile;

hive会自动为表添加两个属性：
last_modified_by    最后修改表的用户名
last_modified_time  最后修改表的新纪元时间秒

show tables;
show tables in databasename;
describe dim_time;
describe extended dim_time;
describe formatted dim_time;     信息更详细，可读性更强

以上创建的都是hive内部表，也叫管理表，因为hive或多或少控制着数据的生命周期，如删除表会同时删除表中的数据；hive内部表不利于使用其他工具如pig共同操作数据;
hive外部表：hive不认为它完全拥有这张表，所以删除表时不会删除数据，只会删除表的元数据;
其实，对于hive内部表，只要知道文件位置，其他工具如pig也是可以操作的，但是从管理角度考虑，明确区分内部表和外部表更便于管理。
create external table abc(
  aaa        string comment ‘aaaaaaaaa’, 
  bbb        date
)
comment 'description of abc'
row format delimited
fields terminated by '\001'
lines terminated by '\n'
location '/newpath/';

HiveQL语法结构不是全部适用于外部表
在表描述中，管理表显示为：
Table Type:             MANAGED_TABLE
外部表显示为：
Table Type:             EXTERNAL_TABLE


拷贝表结构（不会拷贝数据）：
create table if not exists test3 like test;       //如果老表是内部表，新表也是内部表；老表是外部表，新表也是外部表；
create external table if not exists test3 like test;      //无论老表是内部表还是外部表，新表都是外部表；

内部分区表
对数据进行分区，最重要的原因就是为了更快地查询。特定的查询可以只扫描特定的分区目录就可以了，其他目录都可以忽略。
分区表的定义中加上：
partitioned by (country string, state string);
分区表改变了hive对数据存储的组织方式。
以前的目录结构是
/hive/warehouse/test.db/table1
现在分区后变成：
/hive/warehouse/test.db/table1/country=US/state=LA
/hive/warehouse/test.db/table1/country=US/state=NY
/hive/warehouse/test.db/table1/country=CA/state=AB
/hive/warehouse/test.db/table1/country=CA/state=BC

表描述中，会有分区信息：
# Partition Information          
# col_name                data_type               comment             
country                      string
state                         string

如果表中数据和分区数量都非常大，执行一个全分区的查询会触发一个巨大的mapreduce任务。强烈建议:
set hive.mapred.mode=strict;   //如果查询分区表时where子句没有加分区过滤，会禁止提交这个任务
显示分区表的所有分区：
show partitions tablename;
show partitions bdm_apilog partition(country='US');

在内部表中，可以通过载入数据的方式创建分区。
LOAD DATA LOCAL INPATH '${env:HOME}/california-employees' 
INTO TABLE employees
PARTITION (country='US', state='CA');
hive汇创建目录.../employees/country=US/state=CA,
${env:HOME}/california-employees目录下的文件会拷贝到这个目录下

外部分区表
create external table if not exists log_messages(
a string,
b string,
c int,
d int)
partitioned by (year int, month int, day int)
row format delimited fileds terminated by '\t';
增加分区
alter table log_messages add partition(year=2012, month=1, day=3)
location 'hdfs://master_server/data/log_messages/2012/1/3';

查看分区所在的文件系统路径
describe extended log_messages partition (year=2012,month=1,day=3);

hive使用一个inputformat对象将输入流分割成记录；使用一个outputformat对象将记录格式化为输出流，使用序列化/反序列化器SerDe做记录的解析（记录和列的转换）；

删除表
drop tablename;

表重命名
alter table log_messages rename to logmsgs;
增加分区
alter table log_messages add if not exists
partition (year=2011, month=1, day=1) location '/logs/2011/1/1' 
partition (year=2011, month=1, day=2) location '/logs/2011/1/2';
修改分区的路径
alter table log_messages partition (year=2011, month=1, day=1) 
set location '/new_logs/2011/1/2';
删除分区
alter table log_messages drop if exists partition(year=2011, month=1, day=1) ;
修改列信息
alter table log_messages
change column fieldname newfieldname int
comment 'comment............'
after field2;     将字段转移到field2字段的后边
增加列
alter table log_messages add columns (
a string comment 'aaaaaaa',
b int comment 'bbbbbbbbb');

hive提供了各种保护：
防止分区被删除
alter table log_messages
partition (year=2011, month=1, day=1) enable no_drop;
防止分区被查询
alter table log_messages
partition (year=2011, month=1, day=1) enable offline;
disable和enable是反向操作