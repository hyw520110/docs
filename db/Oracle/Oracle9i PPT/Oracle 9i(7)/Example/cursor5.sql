declare
CURSOR temp_cursor
IS 
SELECT * from mytable order by salary
FOR UPDATE OF salary;
temp_num number:=0;  -- �洢ִ�и��²�������
temp_record mytable%rowtype; -- ����ִ�и��²����ļ�¼���ͱ���
all_salary number:=0;   -- �洢�ܹ��ʶ�
begin
     dbms_output.enable;
     OPEN temp_cursor;
     select sum(salary) into all_salary from mytable;
     while all_salary <8000
     loop
         fetch temp_cursor into temp_record;
         EXIT WHEN temp_cursor%NOTFOUND;
         all_salary:=all_salary + temp_record.salary*0.1;
         UPDATE mytable set salary = salary * 1.1 where current of temp_cursor;
         temp_num:=temp_num + 1;
     end loop;
     CLOSE temp_cursor;
     dbms_output.put_line('������:'||temp_num);
     commit;
end;
/