declare 
i number(2,0):=1;
j number(2,0):=0;
begin
dbms_output.enable;
while i<=10 loop
     j:=1;
     while j<=i loop
           dbms_output.put('* ');
           j:=j+1;
     end loop;
     i:=i+1;
     dbms_output.put_line(' ');  
end loop;
end;
/