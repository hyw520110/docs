declare
result_key char(1):='0';
begin
dbms_output.enable;
if result_key='0' then
   dbms_output.put_line('初始化状态');
elsif result_key='1' then
   dbms_output.put_line('启用中状态');
else
   dbms_output.put_line('非法者状态');
end if;
end;
/