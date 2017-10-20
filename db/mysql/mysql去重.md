http://www.cnblogs.com/rainduck/archive/2013/05/15/3079868.html

mysql删除重复记录:

	id name value 
	1 a pp 
	2 a pp 
	3 b iii 
	4 b pp 
	5 b pp 
	6 c pp 
	7 c pp 
	8 c iii 
id是主键,要求得到这样的结果
	 
	id name value 
	1 a pp 
	3 b iii 
	4 b pp 
	6 c pp 
	8 c iii 
方法1 

	delete YourTable 
	where [id] not in ( 
	select max([id]) from YourTable 
	group by (name + value)) 
方法2 
	
	delete a 
	from 表 a left join( 
	select (id) from 表 group by name,value 
	)b on a.id=b.id 
	where b.id is null 
 
查询及删除重复记录的SQL语句 

1、查找表中多余的重复记录，重复记录是根据单个字段（peopleId）来判断 

	select * from people 
	where peopleId in (select peopleId from people group by peopleId having count(peopleId) > 1) 
2、删除表中多余的重复记录，重复记录是根据单个字段（peopleId）来判断，只留有rowid最小的记录 

	delete from people 
	where peopleId in (select peopleId from people group by peopleId having count(peopleId) > 1) 
	and rowid not in (select min(rowid) from people group by peopleId having count(peopleId )>1) 
3、查找表中多余的重复记录（多个字段） 

	select * from vitae a 
	where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1) 
4、删除表中多余的重复记录（多个字段），只留有rowid最小的记录 

	delete from vitae a 
	where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1) 
	and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1) 
5、查找表中多余的重复记录（多个字段），不包含rowid最小的记录 

	select * from vitae a 
	where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1) 
	and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1) 
(二) 不同记录之间的“name”值有可能会相同， 需要查询出在该表中的各记录之间，“name”值存在重复的项； 
	
	Select Name,Count(*) From A Group By Name Having Count(*) > 1 
如果还查性别也相同大则如下: 

	Select Name,sex,Count(*) From A Group By Name,sex Having Count(*) > 1 
(三)方法一 

	declare @max integer,@id integer 
	declare cur_rows cursor local for select 主字段,count(*) from 表名 group by 主字段 having count(*) >； 1 
	open cur_rows 
	fetch cur_rows into @id,@max 
	while @@fetch_status=0 
	begin 
	select @max = @max -1 
	set rowcount @max 
	delete from 表名 where 主字段 = @id 
	fetch cur_rows into @id,@max 
	end 
	close cur_rows 
	set rowcount 0 
方法二＂重复记录＂有两个意义上的重复记录，一是完全重复的记录，也即所有字段均重复的记录，二是部分关键字段重复的记录，比如Name字段重复，而其他字段不一定重复或都重复可以忽略。 

1、对于第一种重复，比较容易解决，使用 

	select distinct * from tableName 
就可以得到无重复记录的结果集。 

如果该表需要删除重复的记录（重复记录保留1条），可以按以下方法删除 

	select distinct * into #Tmp from tableName 
	drop table tableName 
	select * into tableName from #Tmp 
	drop table #Tmp 
发生这种重复的原因是表设计不周产生的，增加唯一索引列即可解决。 

2、这类重复问题通常要求保留重复记录中的第一条记录，操作方法如下 
假设有重复的字段为Name,Address，要求得到这两个字段唯一的结果集 

	select identity(int,1,1) as autoID, * into #Tmp from tableName 
	select min(autoID) as autoID into #Tmp2 from #Tmp group by Name,autoID 
	select * from #Tmp where autoID in(select autoID from #tmp2) 
最后一个select即得到了Name，Address不重复的结果集（但多了一个autoID字段，实际写时可以写在select子句中省去此列） 
(四)查询重复 
	
		select * from tablename where id in ( 
		select id from tablename 
		group by id 
		having count(id) > 1 
		) 
	
	 
		SQL> desc employee 
		Name Null? Type 
		----------------------------------------- -------- ------------------ 
		emp_id NUMBER(10) 
		emp_name VARCHAR2(20) 
		salary NUMBER(10,2) 
可以通过下面的语句查询重复的记录：
 
		SQL> select * from employee; 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		1 sunshine 10000 
		2 semon 20000 
		2 semon 20000 
		3 xyz 30000 
		2 semon 20000 
		SQL> select distinct * from employee; 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		2 semon 20000 
		3 xyz 30000 
		SQL> select * from employee group by emp_id,emp_name,salary having count (*)>1 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		2 semon 20000 
		SQL> select * from employee e1 
		where rowid in (select max(rowid) from employe e2 
		where e1.emp_id=e2.emp_id and 
		e1.emp_name=e2.emp_name and e1.salary=e2.salary); 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		3 xyz 30000 
		2 semon 20000 
2. 删除的几种方法： 
（1）通过建立临时表来实现 
	
	SQL>create table temp_emp as (select distinct * from employee) 
	SQL> truncate table employee; (清空employee表的数据） 
	SQL> insert into employee select * from temp_emp; (再将临时表里的内容插回来） 
( 2）通过唯一rowid实现删除重复记录.在Oracle中，每一条记录都有一个rowid，rowid在整个数据库中是唯一的，rowid确定了每条记录是在Oracle中的哪一个数据文件、块、行上。在重复的记录中，可能所有列的内容都相同，但rowid不会相同，所以只要确定出重复记录中那些具有最大或最小rowid的就可以了，其余全部删除。 
	
	SQL>delete from employee e2 where rowid not in ( 
	select max(e1.rowid) from employee e1 where 
	e1.emp_id=e2.emp_id and e1.emp_name=e2.emp_name and e1.salary=e2.salary);--这里用min(rowid)也可以。 
	SQL>delete from employee e2 where rowid <( 
	select max(e1.rowid) from employee e1 where 
	e1.emp_id=e2.emp_id and e1.emp_name=e2.emp_name and 
	e1.salary=e2.salary); 
（3）也是通过rowid，但效率更高。 
	
		SQL>delete from employee where rowid not in ( 
		select max(t1.rowid) from employee t1 group by 
		t1.emp_id,t1.emp_name,t1.salary);--这里用min(rowid)也可以。 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		3 xyz 30000 
		2 semon 20000 
		SQL> desc employee 
		Name Null? Type 
		----------------------------------------- -------- ------------------ 
		emp_id NUMBER(10) 
		emp_name VARCHAR2(20) 
		salary NUMBER(10,2) 
可以通过下面的语句查询重复的记录： 

		SQL> select * from employee; 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		1 sunshine 10000 
		2 semon 20000 
		2 semon 20000 
		3 xyz 30000 
		2 semon 20000 
		SQL> select distinct * from employee; 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		2 semon 20000 
		3 xyz 30000 
		SQL> select * from employee group by emp_id,emp_name,salary having count (*)>1 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		2 semon 20000 
		SQL> select * from employee e1 
		where rowid in (select max(rowid) from employe e2 
		where e1.emp_id=e2.emp_id and 
		e1.emp_name=e2.emp_name and e1.salary=e2.salary); 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		3 xyz 30000 
		2 semon 20000 
2. 删除的几种方法： 
（1）通过建立临时表来实现 

	SQL>create table temp_emp as (select distinct * from employee) 
	SQL> truncate table employee; (清空employee表的数据） 
	SQL> insert into employee select * from temp_emp; (再将临时表里的内容插回来） 
( 2）通过唯一rowid实现删除重复记录.在Oracle中，每一条记录都有一个rowid，rowid在整个数据库中是唯一的，rowid确定了每条记录是在Oracle中的哪一个数据文件、块、行上。在重复的记录中，可能所有列的内容都相同，但rowid不会相同，所以只要确定出重复记录中那些具有最大或最小rowid的就可以了，其余全部删除。 

		SQL>delete from employee e2 where rowid not in ( 
		select max(e1.rowid) from employee e1 where 
		e1.emp_id=e2.emp_id and e1.emp_name=e2.emp_name and e1.salary=e2.salary);--这里用min(rowid)也可以。 
		SQL>delete from employee e2 where rowid <( 
		select max(e1.rowid) from employee e1 where 
		e1.emp_id=e2.emp_id and e1.emp_name=e2.emp_name and 
		e1.salary=e2.salary); 
		（3）也是通过rowid，但效率更高。 
		SQL>delete from employee where rowid not in ( 
		select max(t1.rowid) from employee t1 group by 
		t1.emp_id,t1.emp_name,t1.salary);--这里用min(rowid)也可以。 
		EMP_ID EMP_NAME SALARY 
		---------- ---------------------------------------- ---------- 
		1 sunshine 10000 
		3 xyz 30000 
		2 semon 20000
