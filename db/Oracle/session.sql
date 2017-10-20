select *
  from (select parsing_user_id,
               executions,
               sorts command_type,
               disk_reads,
               sql_text
          from v$sqlarea
         order by disk_reads desc)
 where rownum < 10

SELECT *
  FROM v$sqltext a
 WHERE a.sql_id = '9g1f91rhftth4';

SELECT   b.SID, b.serial#, b.username, b.program, b.machine, b.status,
         b.logon_time, a.sql_text
    FROM v$sqlarea a, v$session b
   WHERE a.sql_id = b.prev_sql_id AND username = 'nacecsns'
ORDER BY logon_time;



 select count(*)  from v$session  where username in ('ECOALCHINA' );
 select count(*) from v$process where username in ('ECOALCHINA' );
 --,'GOLDENSNS','NACEC'
 select  *  from v$session where username in ('ECOALCHINA')
 
 select sid, serial#, status, machine, osuser, program, logon_time
   from v$session
  where status = upper('inactive')
  and username in ('ECOALCHINA')
  order by logon_time asc
  
  SELECT REPLACE(SQL_TEXT, CHR(13), CHR(10) || CHR(13))
    FROM v$sqltext a
   WHERE (a.HASH_VALUE, a.ADDRESS) IN
         (SELECT decode(sql_hash_value, 0, prev_hash_value, sql_hash_value),
                 decode(sql_hash_value, 0, prev_sql_addr, sql_address)
            FROM v$session b
           where b.sid = 110 and b.serial# =2165)
   order by rownum desc

 
 select b.MACHINE, b.PROGRAM, count(*)
   from v$process a, v$session b
  where a.ADDR = b.PADDR
    and b.USERNAME is not null
  group by b.MACHINE, b.PROGRAM
  order by count(*) desc;
  
  
select * from v$locked_object; 

select A.SID,B.SPID,A.SERIAL#,a.lockwait,A.USERNAME,A.OSUSER,a.logon_time,a.last_call_et/3600 LAST_HOUR,A.STATUS, 
'orakill '||sid||' '||spid HOST_COMMAND,
'alter system kill session '''||A.sid||','||A.SERIAL#||'''' SQL_COMMAND
from v$session A,V$PROCESS B where A.PADDR=B.ADDR AND SID>6 and a.username='ECOALCHINA'

alter system kill session '124,645'
 

select buffer_gets,sql_text
from (select sql_text,buffer_gets,
   dense_rank() over
     (order by buffer_gets desc) buffer_gets_rank
   from v$sql)
where buffer_gets_rank<=5;


select disk_reads,sql_text
from (select sql_text,disk_reads,
   dense_rank() over
     (order by disk_reads desc) disk_reads_rank
   from v$sql)
where disk_reads_rank <=5;


select sql_text,executions
from (select sql_text,executions,
   rank() over
    (order by executions desc) exec_rank
   from v$sql)
where exec_rank <=5;


select b.username username,a.disk_reads reads,
    a.executions exec,a.disk_reads/decode(a.executions,0,1,a.executions) rds_exec_ratio,
    a.sql_text Statement
from  v$sqlarea a,dba_users b
where a.parsing_user_id=b.user_id
 and a.disk_reads > 100000
order by a.disk_reads desc;


select a.CPU_TIME,--CPU时间 百万分之一（微秒）
       a.OPTIMIZER_MODE,--优化方式
       a.EXECUTIONS,--执行次数
       a.DISK_READS,--读盘次数
       a.SHARABLE_MEM,--占用shared pool的内存多少
       a.BUFFER_GETS,--读取缓冲区的次数
       a.COMMAND_TYPE,--命令类型(3:select,2:insert;6:update;7delete;47:pl/sql程序单元)
       a.SQL_TEXT,--Sql语句
       a.SHARABLE_MEM,
       a.PERSISTENT_MEM,
       a.RUNTIME_MEM,
       a.PARSE_CALLS,
       a.DISK_READS,
       a.DIRECT_WRITES,
       a.CONCURRENCY_WAIT_TIME,
       a.USER_IO_WAIT_TIME
  from SYS.V_$SQLAREA a
 WHERE PARSING_SCHEMA_NAME = 'CHEA_FILL'--表空间
 order by a.CPU_TIME desc



select sql_text from v$sqltext a where a.hash_value = (select sql_hash_value from v$session b where b.sid = '&sid'    )
order by piece asc


select SE.SID,SE.SERIAL#,PR.SPID,
SE.USERNAME,SE.STATUS,SE.TERMINAL,
SE.PROGRAM,SE.MODULE,
SE.SQL_ADDRESS,ST.EVENT,
ST.P1TEXT,SI.PHYSICAL_READS,SI.BLOCK_CHANGES from v$session se,v$session_wait st,
v$sess_io si,v$process pr
where st.SID=se.SID and st.SID=si.SID
AND SE.PADDR=PR.ADDR
AND SE.SID>6
AND ST.WAIT_TIME=0
AND ST.EVENT NOT LIKE '%SQL%'
ORDER BY PHYSICAL_READS DESC;
SELECT sql_address FROM V$SESSION SS,V$SQLTEXT TT
WHERE SS.SQL_HASH_VALUE=TT.HASH_VALUE 
AND SID=439;

SELECT A.OWNER,A.OBJECT_NAME,B.XIDUSN,B.XIDSLOT,B.XIDSQN,B.SESSION_ID,B.ORACLE_USERNAME, B.OS_USER_NAME,B.PROCESS, B.LOCKED_MODE, C.MACHINE,C.STATUS,C.SERVER,C.SID,C.SERIAL#,C.PROGRAM   
FROM ALL_OBJECTS A,V$LOCKED_OBJECT B,SYS.GV_$SESSION C   
WHERE ( A.OBJECT_ID = B.OBJECT_ID ) AND (B.PROCESS = C.PROCESS ) ORDER BY 1,2
SELECT s1.sid,s1.SERIAL# ,s1.username,totalwork,last_update_time,elapsed_seconds,message
FROM v$session s1, v$session_longops s2
WHERE 
s1.serial#=s2.serial# and s1.sid=s2.sid
and s2.username<>'SYSTEM' and s2.username<>'SYS'
--and elapsed_seconds >20
ORDER BY 6 desc




 
select machine,username,count(*)  from v$session  
where username in ('ECOALCHINA')
-- machine='MSHOME\P4KBHKJWLNDQVRP'
group by machine,username 
order by  machine 
 
  

select osuser,
       a.username,
       cpu_time / executions / 1000000 || 's',
       sql_fulltext,
       machine
  from v$session a, v$sqlarea b
 where a.sql_address = b.address   order by cpu_time / executions desc;
 
 
select a.USERNAME,a.sid,spid,status,substr(a.program,1,40) prog,a.terminal,osuser,value/60/100 value
     from v$session a,v$process b,v$sesstat c
     where c.statistic#=12 and c.sid=a.sid and a.paddr=b.addr 
     and a.USERNAME='NACECSNS'
     order by value desc;
     
 
    
     
 SELECT osuser, username, sql_text from v$session a, v$sqltext b
     where a.sql_address =b.address order by address, piece;
     
     
     SELECT TABLESPACE_NAME,INITIAL_EXTENT,NEXT_EXTENT,MIN_EXTENTS,          
MAX_EXTENTS,PCT_INCREASE,MIN_EXTLEN,STATUS,CONTENTS,LOGGING,
EXTENT_MANAGEMENT,   -- Columns not available in v8.0.x
ALLOCATION_TYPE,     -- Remove these columns if running
PLUGGED_IN,           -- against a v8.0.x database
SEGMENT_SPACE_MANAGEMENT --use only in v9.2.x or later 
FROM
DBA_TABLESPACES   ORDER BY TABLESPACE_NAME;
     
     SELECT T.TABLESPACE_NAME,D.FILE_NAME,         D.AUTOEXTENSIBLE,D.BYTES,D.MAXBYTES,D.STATUS   FROM DBA_TABLESPACES T,       DBA_DATA_FILES   D   WHERE T. TABLESPACE_NAME =D. TABLESPACE_NAME   ORDER BY TABLESPACE_NAME,FILE_NAME  
     
     
     SELECT D.TABLESPACE_NAME,
            SPACE "SUM_SPACE(M)",
            BLOCKS SUM_BLOCKS,
            SPACE - NVL(FREE_SPACE, 0) "USED_SPACE(M)",
            ROUND((1 - NVL(FREE_SPACE, 0) / SPACE) * 100, 2) "USED_RATE(%)",
            FREE_SPACE "FREE_SPACE(M)"
       FROM (SELECT TABLESPACE_NAME,
                    ROUND(SUM(BYTES) / (1024 * 1024), 2) SPACE,
                    SUM(BLOCKS) BLOCKS
               FROM DBA_DATA_FILES
              GROUP BY TABLESPACE_NAME) D,
            (SELECT TABLESPACE_NAME,
                    ROUND(SUM(BYTES) / (1024 * 1024), 2) FREE_SPACE
               FROM DBA_FREE_SPACE
              GROUP BY TABLESPACE_NAME) F
      WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)
     UNION ALL --if have tempfile   
     SELECT D.TABLESPACE_NAME,SPACE "SUM_SPACE(M)",BLOCKS SUM_BLOCKS,   USED_SPACE "USED_SPACE(M)",ROUND(NVL(USED_SPACE,0)/SPACE*100,2) "USED_RATE(%)",   NVL(FREE_SPACE,0) "FREE_SPACE(M)"   FROM   (SELECT TABLESPACE_NAME,ROUND(SUM(BYTES)/(1024*1024),2) SPACE,SUM(BLOCKS) BLOCKS   FROM DBA_TEMP_FILES   GROUP BY TABLESPACE_NAME) D,   (SELECT TABLESPACE_NAME,ROUND(SUM(BYTES_USED)/(1024*1024),2) USED_SPACE,   ROUND(SUM(BYTES_FREE)/(1024*1024),2) FREE_SPACE   FROM V$TEMP_SPACE_HEADER   GROUP BY TABLESPACE_NAME) F   WHERE   D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)

 SELECT S.OWNER,S.SEGMENT_NAME,S.SEGMENT_TYPE,S.PARTITION_NAME,   ROUND(BYTES/(1024*1024),2) "USED_SPACE(M)",   EXTENTS USED_EXTENTS,S.MAX_EXTENTS,S.BLOCKS ALLOCATED_BLOCKS,   S.BLOCKS USED_BOLCKS,S.PCT_INCREASE,S.NEXT_EXTENT/1024 "NEXT_EXTENT(K)"   FROM DBA_SEGMENTS S   WHERE S.OWNER NOT IN ('SYS','SYSTEM')   ORDER BY Used_Extents DESC  
 
 SELECT a.VALUE + b.VALUE logical_reads,   c.VALUE phys_reads,   round(100*(1-c.value/(a.value+b.value)),4) hit_ratio   FROM v$sysstat a,v$sysstat b,v$sysstat c   WHERE a.NAME='db block gets'   AND b.NAME='consistent gets'   AND c.NAME='physical reads'  
 SELECT SUM(pins) total_pins,SUM(reloads) total_reloads,   SUM(reloads)/SUM(pins)*100 libcache_reload_ratio   FROM   v$librarycache  
 
 
    SELECT s.username,   decode(l.type,'TM','TABLE LOCK',                 'TX','ROW LOCK',                 NULL) LOCK_LEVEL,   o.owner,o.object_name,o.object_type,   s.sid,s.serial#,s.terminal,s.machine,s.program,s.osuser   FROM v$session s,v$lock l,dba_objects o   WHERE l.sid = s.sid   AND l.id1 = o.object_id(+)   AND s.username is NOT NULL  
   
