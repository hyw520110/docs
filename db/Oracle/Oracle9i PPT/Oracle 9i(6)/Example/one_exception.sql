declare 
count_ex EXCEPTION;
counter number(2,0);
begin
select count(*) into counter from m_indent;
if counter >6 then
   raise count_ex;
end if;
EXCEPTION
         WHEN no_data_found then
              dbms_output.put_line('��������!');
         WHEN too_many_rows then
              dbms_output.put_line('��������!');
         WHEN count_ex then
              dbms_output.put_line('��ֵ����6����¼!');     
         WHEN OTHERS THEN
              null;
end;
/