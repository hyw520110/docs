declare 
cursor temp_record
IS SELECT * FROM M_WAREHOUSE;
begin
dbms_output.enable;
for new_warehouse in temp_record loop
    dbms_output.put(new_warehouse.warehouse_id);
    dbms_output.put(new_warehouse.city);
    dbms_output.put(new_warehouse.area);
    dbms_output.put_line('');
end loop;
commit;
end;
/