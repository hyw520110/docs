declare
result_key char(1):='0';
begin
dbms_output.enable;
if result_key='0' then
   dbms_output.put_line('��ʼ��״̬');
elsif result_key='1' then
   dbms_output.put_line('������״̬');
else
   dbms_output.put_line('�Ƿ���״̬');
end if;
end;
/