declare 
new_warehouse m_warehouse%rowtype;
cursor temp_record 
IS SELECT * FROM M_WAREHOUSE;
begin
dbms_output.enable;
open temp_record;
fetch temp_record into new_warehouse;
dbms_output.put_line(new_warehouse.warehouse_id);
dbms_output.put_line(new_warehouse.city);
dbms_output.put_line(new_warehouse.area);
close temp_record;
end;
/
