declare
counter number; -- �����ڶ������
begin
dbms_output.enable;
counter:=201;
dbms_output.put_line('�����ڱ���: Counter:='||counter);
   declare
   counter number(6,2);
   begin
   counter:=980.50;
   dbms_output.put_line('�ӿ��ڱ���: Counter:='||counter);
   end;
end;
/