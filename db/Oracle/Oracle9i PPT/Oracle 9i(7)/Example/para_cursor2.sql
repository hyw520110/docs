declare 
new_warehouse m_warehouse%rowtype;
cursor temp_record(new_city varchar2)
IS SELECT * FROM M_WAREHOUSE where city = new_city;
begin
dbms_output.enable;
open temp_record('武汉');
fetch temp_record into new_warehouse;
dbms_output.put_line(new_warehouse.warehouse_id);
dbms_output.put_line(new_warehouse.city);
dbms_output.put_line(new_warehouse.area);
close temp_record;
end;
/


更新数据库 (提供并发处理)
===============================================================
set serveroutput on
declare
cursor temp_cur(salary1 number) 
is select * from test_employee where salary > salary1 for update of salary; -- 定义游标
begin
for temp_employee in temp_cur(1230) loop 
   update test_employee set salary  = salary + 100 where current of temp_cur; 
end loop;
commit;
end;
/