
use test
select * from sysobjects where xtype='u'
select * from users
truncate table users --删除所有记录，性能高于delete

insert into users values(1,'admin')
go
insert into users values(2,'mrhu')
go
insert into users values(3,'kiss')

select count(*) as counts from users  --比较truncate操作前后变化
go
truncate table users
go
select count(*) as counts from users  

print @@version  --系统版本
print @@servername  --服务器名

insert into users values('a','a') --错误编号
go
if @@error=245
	print 'insert wrong'

print @@language --版本语言信息
print @@datefirst  --一周的第一天从星期几算起
truncate table users
print @@cpu_busy

create table partment  --获取最近添加的标识列的值
(
	pid int identity(3,10),
	pname varchar(20)
)
insert into partment(pname) values('技术部')
print @@identity
select * from partment

declare @num int --局部变量
set @num=12
print @num

declare @strName varchar(20)
select @strName='state'
print @strName
select pid,@strName from partment --??

declare @i int --if条件判断
set @i=9
if (@i>10)
	begin
		print 'i morethan 10'
	end
else
	begin
		print 'i lessthan 10'
	end

declare @i int --while循环控制
set @i=12
--print @i
while (@i<18)
  begin
	print @i
	set @i=@i+1
	if @i<17
		continue;
	if @i>15
		break;
  end

--使用case分支判断
select username,'管理员' as rank from users where username='admin'
select username,'普通用户' as rank from users where username='mrhu'

select username,
case username
  when 'admin' then '管理员'
  when 'mrhu'  then '普通用户'
else username
end as rank
from users

--系统函数
print ascii('ABC') --获取指定字符串中左起第一个字符的ASC码
print char(75)  --根据给定的ASC码获取相应的字符
print len('abcde') --获取给定字符串的长度
print lower('ABCDE') --转小写
print upper('abcde') --转大写
print ltrim('  abc abc d') --过滤左空格
print rtrim('  abc abc  ')	--过滤右空格
print abs(-123) --绝对值
print power(2,3) --2的3次方
print rand()*1000  --获取0--1000的随机数
print pi() --圆周率
print getdate() --系统时间
print dateadd(day,-3,getdate()) --3天前时间
print dateadd(hh,4,getdate())  --加上4小时，hour/hh,minute/mi,second/ss
print datediff(year,'2005-1-1',getdate()) --指定时间和现在时间的年差 
print datediff(mi,'2005-1-1','2006-1-1')  --minute/mi,second/ss
print 'abc'+cast(456 as varchar) --字符串转换合并
print 'abc'+convert(varchar,456)  --字符串连接要保持类型一致
print convert(varchar(12), '2005-01-01')
print year(getdate())  --获取指定时间部分，year,month,day
print datepart(year,getdate())
print datepart(hh,getdate()) --小时
print datepart(mi,getdate()) --分钟
print datepart(ss,'2005-2-1 12:30:50') --秒
print datepart(ms,getdate()) --毫秒
print host_id() --返回工作站标识号
print host_name() --获取主机名
print db_id('master')  --获取数据库编号
print db_name(4) --获取数据库名


create table student
(
	sname varchar(30),
	sbirthday datetime  --sbirthday datetime default (getdate())
)
-- 利用系统函数作为默认值约束
alter table student add constraint df_student_sbirthday default (getdate()) for sbirthday
insert into student(sname) values('mrhu')
insert into student values('admin',default)
select * from student
alter table student drop df_student_sbirthday --删除约束
sp_help student --显示表信息

select stuff('ABCDEF',2,1,'GH')as test  --填充函数

create function countstudent(@sname varchar(12)) --自定义函数
returns int
 begin
	return (select count(*) from student where sname=@sname)
 end

select dbo.countstudent('admin') as counts --调用自定义函数
select * from sysobjects where xtype='FN'

create proc p_countstudent  --存储过程创建
as
 select dbo.countstudent('mrhu') as counts
drop proc p_countstudent

exec p_countstudent 

sp_help student --查看表结构
sp_helptext p_countstudent  --查看存储过程内容 

if object_id('student2') is not null
	drop function student2
create function student2(@sname varchar(12))  --返回内联表值函数
returns table
as
return
(
	select * from student where sname=@sname
)
select * from dbo.student2('admin') --调用函数

create function student3(@sname varchar(12))  --表值函数
returns @studentTest table
(
	用户名 varchar(12),
	注册时间 datetime
)
as
 begin
	insert @studentTest 
	select * from student as s where sname=@sname
	return
 end

select * from student3('mrhu') --调用函数
drop function student3

sp_helptext student

select distinct sname from student --剔除重复

select * from users where id>all(select id from users where id<3)
select * from users where id>=any(select id from users)

if exists(select * from users where username='mrhu')
print 'exists'
else
print 'not exists'

select username,id from users where username='mrhu'
union
select '合计:',sum(id) from users

insert into users values(4,'number0')
insert into users values(5,'number1')
insert into users values(6,'number4')
insert into users values(7,'number3')
insert into users values(8,'number4')
sp_help users

select * from users
update users set username='number2' where id=6

declare @str varchar(200)  --执行带变量的sql
declare @i int
set @i=4
set @str='select top '+cast(@i as nvarchar(20))+' from users'
--exec(@str)
exec sp_executesql @str

EXECUTE sp_executesql 
          N'select * from users where id=@i', --select top @i * from users 出错？？？
          N'@i int',
		  @i = 4;

create proc usersPage  --分页查询模拟测试
@CurrentPageSize int,
@PageSize int,
@CurrentPage int
as
Declare @strSql nvarchar(400)
set @strSql = 'select * from
  (select top ' + convert(nvarchar(4), @CurrentPageSize) + ' * 
  from (select top ' + convert(nvarchar(4),(@PageSize * @CurrentPage)) + ' * from users) as tt
  order by id desc) as stt
  order by id'
exec sp_executesql @strSql    
                                   
exec userspage 4,3,2

use test
select * from sysobjects where type like '%f%'

sp_helptext usersPage 
sp_helptext ProcTest


declare cur_exp cursor for select * from users --游标定义
open cur_exp
fetch cur_exp			--提取游标
fetch next from cur_exp 
close cur_exp
deallocate cur_exp  --释放游标
select @@fetch_status --游标执行状态0(fetch执行成)，-1(执行失败或行不存在)，-2(行不存在)

create table Book 
(
	title varchar(50),
	price numeric(9,3)
)
insert into Book values('book1',95.00)
insert into Book values('book2',45.00)
insert into Book values('book3',65.00)
insert into Book values('book4',99.00)
update Book set price=155.00 where title='book2'
delete  from Book
select * from Book


=====================================================
           以下部分需要细看
=====================================================

--使用冒泡排序找出Book表中最贵的书
declare cur_book cursor for select title,price from Book 
open cur_book 
declare @title varchar(50)
declare @price numeric(9,3)
declare @title_temp varchar(50)
declare @price_temp numeric(9,3)
fetch cur_book into @title,@price
fetch cur_book into @title_temp,@price_temp
while @@fetch_status=0
 begin
	if @price<@price_temp
	  begin
		set @title=@title_temp
		set @price=@price_temp
	  end
	fetch cur_book into @title_temp,@price_temp
 end
close cur_book
deallocate cur_book
print '最贵的书是：'+@title+' 价格:'+convert(varchar(20),@price)

--通过存储过程，使用冒泡排序寻找最贵的书
create proc Book_GetMaxprice
as
 declare cur_book cursor for select title,price from Book
 open cur_book
 declare @title varchar(50)
 declare @price numeric(9,3)
 declare @title_temp varchar(50)
 declare @price_temp numeric(9,3)
 fetch cur_book into @title,@price
 if @@fetch_status<>0
  begin
	print '没有图书记录'
	close cur_book
	deallocate cur_book
	return
  end
 fetch cur_book into @title_temp,@price_temp
 if @@fetch_status<>0
  begin
	print '最贵的书是：'+@title+' 价格:'+convert(varchar(20),@price)
	close cur_book
	deallocate cur_book
	return
  end
 while @@fetch_status=0
 begin
	if @price<@price_temp
	  begin
		set @title=@title_temp
		set @price=@price_temp
	  end
	fetch cur_book into @title_temp,@price_temp
 end
 close cur_book
 deallocate cur_book
 print '最贵的书是：'+@title+' 价格:'+convert(varchar(20),@price)

drop proc Book_GetMaxprice
exec Book_GetMaxprice

select * from users
insert into users values(10,'2;5;9')
delete from users where id=10
select * from users where username like '%'+cast(id as varchar(12))+'%'

create trigger myTrigger
select * from sys.triggers
select * from 


create trigger mytrigger
on student
for insert
as	 												
insert into student(sname) values('mrhu')			
drop trigger mytrigger
sp_helptext mytrigger			
	
alter database test set recursive_triggers off												

create table emp_mgr
(
	Emp int primary key
)
select * from student
insert into student(sname) values('admin')

sp_helptrigger student --查看与表相关的触发器
select * from users


begin transaction
delete from users where id=12
if @@error <>0
	rollback tran
insert into users values(10,'test')
if @@error<>0
	begin
		print '执行错误！'
		rollback tran
	end
else
commit tran
