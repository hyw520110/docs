declare 
result_key char(1):='1';
begin
dbms_output.enable;
case 
     when result_key='0' then dbms_output.put_line('初始化状态');
     when result_key='1' then dbms_output.put_line('启用中状态');
     when result_key='2' then dbms_output.put_line('禁用中状态');
     else dbms_output.put_line('非法者状态');
end case;
end;
/