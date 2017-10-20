declare 
new_indent m_indent.indent_id%type;
begin
select indent_id into new_indent from m_indent where employee_id ='E3';
EXCEPTION
         WHEN no_data_found then
              dbms_output.put_line('查无数据!');
         WHEN too_many_rows then
              dbms_output.put_line('过多数据!');
         WHEN OTHERS THEN
              null;
end;
/