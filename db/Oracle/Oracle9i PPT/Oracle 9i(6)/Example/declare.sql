declare
counter number; -- 主块内定义变量
begin
dbms_output.enable;
counter:=201;
dbms_output.put_line('主块内变量: Counter:='||counter);
   declare
   counter number(6,2);
   begin
   counter:=980.50;
   dbms_output.put_line('子块内变量: Counter:='||counter);
   end;
end;
/