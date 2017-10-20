
use test
select * from sysobjects where xtype='u'
select * from users
truncate table users --ɾ�����м�¼�����ܸ���delete

insert into users values(1,'admin')
go
insert into users values(2,'mrhu')
go
insert into users values(3,'kiss')

select count(*) as counts from users  --�Ƚ�truncate����ǰ��仯
go
truncate table users
go
select count(*) as counts from users  

print @@version  --ϵͳ�汾
print @@servername  --��������

insert into users values('a','a') --������
go
if @@error=245
	print 'insert wrong'

print @@language --�汾������Ϣ
print @@datefirst  --һ�ܵĵ�һ������ڼ�����
truncate table users
print @@cpu_busy

create table partment  --��ȡ�����ӵı�ʶ�е�ֵ
(
	pid int identity(3,10),
	pname varchar(20)
)
insert into partment(pname) values('������')
print @@identity
select * from partment

declare @num int --�ֲ�����
set @num=12
print @num

declare @strName varchar(20)
select @strName='state'
print @strName
select pid,@strName from partment --??

declare @i int --if�����ж�
set @i=9
if (@i>10)
	begin
		print 'i morethan 10'
	end
else
	begin
		print 'i lessthan 10'
	end

declare @i int --whileѭ������
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

--ʹ��case��֧�ж�
select username,'����Ա' as rank from users where username='admin'
select username,'��ͨ�û�' as rank from users where username='mrhu'

select username,
case username
  when 'admin' then '����Ա'
  when 'mrhu'  then '��ͨ�û�'
else username
end as rank
from users

--ϵͳ����
print ascii('ABC') --��ȡָ���ַ����������һ���ַ���ASC��
print char(75)  --���ݸ�����ASC���ȡ��Ӧ���ַ�
print len('abcde') --��ȡ�����ַ����ĳ���
print lower('ABCDE') --תСд
print upper('abcde') --ת��д
print ltrim('  abc abc d') --������ո�
print rtrim('  abc abc  ')	--�����ҿո�
print abs(-123) --����ֵ
print power(2,3) --2��3�η�
print rand()*1000  --��ȡ0--1000�������
print pi() --Բ����
print getdate() --ϵͳʱ��
print dateadd(day,-3,getdate()) --3��ǰʱ��
print dateadd(hh,4,getdate())  --����4Сʱ��hour/hh,minute/mi,second/ss
print datediff(year,'2005-1-1',getdate()) --ָ��ʱ�������ʱ������ 
print datediff(mi,'2005-1-1','2006-1-1')  --minute/mi,second/ss
print 'abc'+cast(456 as varchar) --�ַ���ת���ϲ�
print 'abc'+convert(varchar,456)  --�ַ�������Ҫ��������һ��
print convert(varchar(12), '2005-01-01')
print year(getdate())  --��ȡָ��ʱ�䲿�֣�year,month,day
print datepart(year,getdate())
print datepart(hh,getdate()) --Сʱ
print datepart(mi,getdate()) --����
print datepart(ss,'2005-2-1 12:30:50') --��
print datepart(ms,getdate()) --����
print host_id() --���ع���վ��ʶ��
print host_name() --��ȡ������
print db_id('master')  --��ȡ���ݿ���
print db_name(4) --��ȡ���ݿ���


create table student
(
	sname varchar(30),
	sbirthday datetime  --sbirthday datetime default (getdate())
)
-- ����ϵͳ������ΪĬ��ֵԼ��
alter table student add constraint df_student_sbirthday default (getdate()) for sbirthday
insert into student(sname) values('mrhu')
insert into student values('admin',default)
select * from student
alter table student drop df_student_sbirthday --ɾ��Լ��
sp_help student --��ʾ����Ϣ

select stuff('ABCDEF',2,1,'GH')as test  --��亯��

create function countstudent(@sname varchar(12)) --�Զ��庯��
returns int
 begin
	return (select count(*) from student where sname=@sname)
 end

select dbo.countstudent('admin') as counts --�����Զ��庯��
select * from sysobjects where xtype='FN'

create proc p_countstudent  --�洢���̴���
as
 select dbo.countstudent('mrhu') as counts
drop proc p_countstudent

exec p_countstudent 

sp_help student --�鿴��ṹ
sp_helptext p_countstudent  --�鿴�洢�������� 

if object_id('student2') is not null
	drop function student2
create function student2(@sname varchar(12))  --����������ֵ����
returns table
as
return
(
	select * from student where sname=@sname
)
select * from dbo.student2('admin') --���ú���

create function student3(@sname varchar(12))  --��ֵ����
returns @studentTest table
(
	�û��� varchar(12),
	ע��ʱ�� datetime
)
as
 begin
	insert @studentTest 
	select * from student as s where sname=@sname
	return
 end

select * from student3('mrhu') --���ú���
drop function student3

sp_helptext student

select distinct sname from student --�޳��ظ�

select * from users where id>all(select id from users where id<3)
select * from users where id>=any(select id from users)

if exists(select * from users where username='mrhu')
print 'exists'
else
print 'not exists'

select username,id from users where username='mrhu'
union
select '�ϼ�:',sum(id) from users

insert into users values(4,'number0')
insert into users values(5,'number1')
insert into users values(6,'number4')
insert into users values(7,'number3')
insert into users values(8,'number4')
sp_help users

select * from users
update users set username='number2' where id=6

declare @str varchar(200)  --ִ�д�������sql
declare @i int
set @i=4
set @str='select top '+cast(@i as nvarchar(20))+' from users'
--exec(@str)
exec sp_executesql @str

EXECUTE sp_executesql 
          N'select * from users where id=@i', --select top @i * from users ��������
          N'@i int',
		  @i = 4;

create proc usersPage  --��ҳ��ѯģ�����
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


declare cur_exp cursor for select * from users --�α궨��
open cur_exp
fetch cur_exp			--��ȡ�α�
fetch next from cur_exp 
close cur_exp
deallocate cur_exp  --�ͷ��α�
select @@fetch_status --�α�ִ��״̬0(fetchִ�г�)��-1(ִ��ʧ�ܻ��в�����)��-2(�в�����)

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
           ���²�����Ҫϸ��
=====================================================

--ʹ��ð�������ҳ�Book����������
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
print '�������ǣ�'+@title+' �۸�:'+convert(varchar(20),@price)

--ͨ���洢���̣�ʹ��ð������Ѱ��������
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
	print 'û��ͼ���¼'
	close cur_book
	deallocate cur_book
	return
  end
 fetch cur_book into @title_temp,@price_temp
 if @@fetch_status<>0
  begin
	print '�������ǣ�'+@title+' �۸�:'+convert(varchar(20),@price)
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
 print '�������ǣ�'+@title+' �۸�:'+convert(varchar(20),@price)

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

sp_helptrigger student --�鿴�����صĴ�����
select * from users


begin transaction
delete from users where id=12
if @@error <>0
	rollback tran
insert into users values(10,'test')
if @@error<>0
	begin
		print 'ִ�д���'
		rollback tran
	end
else
commit tran
