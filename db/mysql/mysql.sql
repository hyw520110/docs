SHOW VARIABLES;  
SHOW GLOBAL STATUS;  
SHOW VARIABLES LIKE '%slow%';   
SHOW GLOBAL STATUS LIKE '%slow%';   

SHOW  PROCESSLIST;

SHOW VARIABLES LIKE '%max_connections%';
SHOW GLOBAL STATUS LIKE 'Max_used_connections';
-- max_used_connections / max_connections * 100% = 99.6% （理想值 ≈ 85%） 

SET GLOBAL max_connections=1500; 

-- key_buffer_size是对MyISAM表性能影响最大的一个参数, 不过数据库中多为Innodb 
SHOW VARIABLES LIKE 'key_buffer_size';   
SHOW GLOBAL STATUS LIKE 'key_read%';   

-- 索引未命中缓存的概率： key_cache_miss_rate ＝ Key_reads / Key_read_requests * 100% =0.27% 

SHOW GLOBAL STATUS LIKE 'key_blocks_u%';  
-- Key_blocks_unused表示未使用的缓存簇(blocks)数，Key_blocks_used表示曾经用到的最大的blocks数 
-- Key_blocks_used / (Key_blocks_unused + Key_blocks_used) * 100% ≈ 18% （理想值 ≈ 80%） 

SHOW GLOBAL STATUS LIKE 'created_tmp%';   
-- 创建的临时文件文件数： Created_tmp_disk_tables / Created_tmp_tables * 100% ＝ 99% （理想值<= 25%） 

SHOW VARIABLES WHERE Variable_name IN ('tmp_table_size', 'max_heap_table_size');   

SHOW GLOBAL STATUS LIKE 'open%tables%';  

-- Open_tables 表示打开表的数量，Opened_tables表示打开过的表数量，如果Opened_tables数量过大，
-- 说明配置中 table_cache(5.1.3之后这个值叫做table_open_cache)值可能太小，我们查询一下服务器table_cache值  
SHOW VARIABLES LIKE 'table_open_cache';   
-- Open_tables / Opened_tables * 100% =69% 理想值 （>= 85%） 
-- Open_tables / table_cache * 100% = 100% 理想值 (<= 95%) 

SHOW GLOBAL STATUS LIKE 'Thread%';   

-- 如果我们在MySQL服务器配置文件中设置了thread_cache_size，当客户端断开之后，
-- 服务器处理此客户的线程将会缓存起来以响应下一个客户而不是销毁（前提是缓存数未达上限）。
-- Threads_created表示创建过的线程数，如果发现Threads_created值过大的话，表明 MySQL服务器一直在创建线程，
-- 这也是比较耗资源，可以适当增加配置文件中thread_cache_size值，查询服务器 thread_cache_size配置： 


SHOW VARIABLES LIKE 'thread_cache_size';   

SHOW GLOBAL STATUS LIKE 'qcache%';   


SELECT @@profiling;  

-- bi库表数
SELECT COUNT(3) FROM information_schema.TABLES WHERE table_schema='bi';

SELECT * FROM information_schema.TABLES WHERE table_schema='tzgdev31';
-- 查看表大小
SELECT table_schema,table_name,table_rows,data_length FROM information_schema.tables ORDER BY table_rows DESC;
-- 查看所有数据大小
SELECT CONCAT(ROUND(SUM(DATA_LENGTH/1024/1024), 2),'MB')  AS DATA FROM information_schema.TABLES;
-- 查看数据库大小
SELECT CONCAT(ROUND(SUM(DATA_LENGTH/1024/1024), 2),'MB')  AS DATA FROM information_schema.TABLES WHERE table_schema='tzgdev31';
-- 查看单表大小
SELECT CONCAT(ROUND(SUM(DATA_LENGTH/1024/1024), 2),'MB')  AS DATA FROM information_schema.TABLES WHERE table_schema='tzgdev31' AND table_name='tbfinancialrecord';


DESC   tbChannel ;
SHOW INDEX FROM tbChannel;
SELECT * FROM tbChannel;;
EXPLAIN  SELECT * FROM tbChannel;

SHOW profiles;  
SHOW profile FOR QUERY 23;  

SELECT vcname,vcarea FROM tbChannel WHERE id IN (1,2);  
EXPLAIN SELECT vcname,vcarea FROM tbChannel WHERE id IN (1,2);  
 SHOW profiles;  
 SHOW profile FOR QUERY 35;  
 
-- 设置步长值和起始值
SET auto_increment_increment=2;
SET auto_increment_offset = 1;


SHOW VARIABLES LIKE 'collation_%';
SHOW VARIABLES LIKE 'character_set_%';

alter database mydb character set utf-8;
create database mydb character set utf-8;

SET character_set_client=utf8;
SET character_set_connection=utf8;
SET character_set_database=utf8;
SET character_set_results=utf8;
SET character_set_server=utf8;
SET character_set_system=utf8;
SET collation_connection=utf8;
SET collation_database=utf8;
SET collation_server=utf8;


-- SET NAMES 'utf8';  相当于
SET character_set_client = utf8;
SET character_set_results = utf8;
SET character_set_connection = utf8;


