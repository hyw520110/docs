declare 
result_key char(1):='0';
begin
dbms_output.enable;
case result_key
     when '0' then dbms_output.put_line('��ʼ��״̬');
     when '1' then dbms_output.put_line('������״̬');
     when '2' then dbms_output.put_line('������״̬');
     else dbms_output.put_line('�Ƿ���״̬');
end case;
end;
/