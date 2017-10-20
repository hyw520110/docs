declare 
i number(2,0):=1;
j number(2,0):=0;
begin
dbms_output.enable;
for i in 1..10 loop
     for j in 1..i loop
           dbms_output.put('* ');
     end loop;
     dbms_output.put_line(' ');  
end loop;
end;
/