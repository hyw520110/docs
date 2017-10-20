prompt PL/SQL Developer import file
prompt Created on 2007Äê1ÔÂ10ÈÕ by isoftstone
set feedback off
set define off
prompt Creating M_EMPLOYEE...
create table M_EMPLOYEE
(
  WAREHOUSE_ID CHAR(4) not null,
  EMPLOYEE_ID  CHAR(3) not null,
  SALARY       NUMBER(4) not null
)
tablespace ISS
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 12K
    minextents 1
    maxextents unlimited
  );

prompt Loading M_EMPLOYEE...
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH2 ', 'E1 ', 1220);
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH1 ', 'E3 ', 1210);
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH2 ', 'E4 ', 1250);
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH3 ', 'E6 ', 1230);
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH1 ', 'E7 ', 1250);
commit;
prompt 5 records loaded
set feedback on
set define on
prompt Done.
