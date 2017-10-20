CPU 100%

使用DMV来分析SQL Server启动以来累计使用CPU资源最多的语句。例如下面的语句就可以列出前50名。

	select
	c.last_execution_time,c.execution_count,c.total_logical_reads,c.total_logical_writes,c.total_elapsed_time,c.last_elapsed_time,
	q.[text]
	from
	(select top 50 qs.*
	from sys.dm_exec_query_stats qs
	order by qs.total_worker_time desc) as c
	cross apply sys.dm_exec_sql_text(plan_handle) as q
	order by c.total_worker_time desc
	go





我们也可以找到最经常做重编译的存储过程。

	select top 25 sql_text.text, sql_handle, plan_generation_num, execution_count,
	
	dbid, objectid
	
	from sys.dm_exec_query_stats a
	
	cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
	
	where plan_generation_num &gt;1
	
	order by plan_generation_num desc
	
	go

	SELECT TOP 10
  		[session_id],
    	[request_id],
    	[start_time] AS '开始时间',
		[status] AS '状态',
    	[command] AS '命令',
    	dest.[text] AS 'sql语句', 
    	DB_NAME([database_id]) AS '数据库名',
    	[blocking_session_id] AS '正在阻塞其他会话的会话ID',
		der.[wait_type] AS '等待资源类型',
		[wait_time] AS '等待时间',
		[wait_resource] AS '等待的资源',
		[dows].[waiting_tasks_count] AS '当前正在进行等待的任务数',
		[reads] AS '物理读次数',
		[writes] AS '写次数',
		[logical_reads] AS '逻辑读次数',
		[row_count] AS '返回结果行数'
	FROM sys.[dm_exec_requests] AS der 
	INNER JOIN [sys].[dm_os_wait_stats] AS dows 
	ON der.[wait_type]=[dows].[wait_type]
	CROSS APPLY 
	sys.[dm_exec_sql_text](der.[sql_handle]) AS dest 
	WHERE [session_id]>50  
	ORDER BY [cpu_time] DESC


   查询CPU占用高的语句

	SELECT TOP 10
      total_worker_time/execution_count AS avg_cpu_cost, plan_handle,
      execution_count,
      (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
         (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), text)) * 2
            ELSE statement_end_offset
         END - statement_start_offset)/2)
      FROM sys.dm_exec_sql_text(sql_handle)) AS query_text
	FROM sys.dm_exec_query_stats
	ORDER BY [avg_cpu_cost] DESC

查询缺失索引

	SELECT 
      DatabaseName = DB_NAME(database_id)
      ,[Number Indexes Missing] = count(*) 
	FROM sys.dm_db_missing_index_details
	GROUP BY DB_NAME(database_id)
	ORDER BY 2 DESC;

	SELECT  TOP 10 
           [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
           , avg_user_impact
           , TableName = statement
           , [EqualityUsage] = equality_columns 
           , [InequalityUsage] = inequality_columns
           , [Include Cloumns] = included_columns
	FROM        sys.dm_db_missing_index_groups g 
	INNER JOIN    sys.dm_db_missing_index_group_stats s 
         ON s.group_handle = g.index_group_handle 
	INNER JOIN    sys.dm_db_missing_index_details d 
         ON d.index_handle = g.index_handle
	ORDER BY [Total Cost] DESC;