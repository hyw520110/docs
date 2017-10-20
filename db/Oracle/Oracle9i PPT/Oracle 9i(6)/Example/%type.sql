declare
ckh m_warehouse.warehouse_id%type;
cs m_warehouse.city%type;
mj m_warehouse.area%type;
begin
ckh:='WH9';
cs:='дом╗';
mj:=886;
insert into m_warehouse(warehouse_id,city,area) values(ckh,cs,mj);
end;
/