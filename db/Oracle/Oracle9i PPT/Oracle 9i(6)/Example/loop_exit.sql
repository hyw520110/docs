declare 
i number(2,0):=1;
j number(2,0):=0;
begin
dbms_output.enable;
loop
j:=1;
     loop
     dbms_output.put('* ');
     j:=j+1;
     exit when j>i;
     end loop;
i:=i+1;
dbms_output.put_line(' ');  
EXIT WHEN i>10;
end loop;
end;
/