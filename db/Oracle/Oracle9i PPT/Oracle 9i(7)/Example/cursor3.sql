declare 
new_warehouse m_warehouse%rowtype;
cursor temp_record
IS SELECT * FROM M_WAREHOUSE;
begin
dbms_output.enable;
open temp_record;
IF temp_record%ISOPEN THEN
   loop
       fetch temp_record into new_warehouse;
       IF temp_record%FOUND THEN
          dbms_output.put(new_warehouse.warehouse_id);
          dbms_output.put(new_warehouse.city);
          dbms_output.put(new_warehouse.area);
          dbms_output.put_line('');
       END IF;
       EXIT WHEN temp_record%NOTFOUND;
   end loop;
ELSE
    dbms_output.put_line('游标打开过程中出错!');
END IF;
close temp_record;
end;
/