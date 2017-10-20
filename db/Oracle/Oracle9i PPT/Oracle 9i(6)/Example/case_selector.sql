declare 
result_key char(1):='0';
begin
dbms_output.enable;
case result_key
     when '0' then dbms_output.put_line('初始化状态');
     when '1' then dbms_output.put_line('启用中状态');
     when '2' then dbms_output.put_line('禁用中状态');
     else dbms_output.put_line('非法者状态');
end case;
end;
/