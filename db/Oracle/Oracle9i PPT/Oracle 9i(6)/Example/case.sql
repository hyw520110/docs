declare 
result_key char(1):='1';
begin
dbms_output.enable;
case 
     when result_key='0' then dbms_output.put_line('��ʼ��״̬');
     when result_key='1' then dbms_output.put_line('������״̬');
     when result_key='2' then dbms_output.put_line('������״̬');
     else dbms_output.put_line('�Ƿ���״̬');
end case;
end;
/