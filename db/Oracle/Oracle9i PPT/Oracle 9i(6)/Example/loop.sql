declare 
i number(2,0):=1;
s number(2,0):=0;
begin
dbms_output.enable;
loop
s:=s+i;
i:=i+1;  
EXIT WHEN i>10;
end loop;
dbms_output.put_line('s='||s); 
end;
/