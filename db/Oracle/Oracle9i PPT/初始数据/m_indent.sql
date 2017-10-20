prompt PL/SQL Developer import file
prompt Created on 2007Äê1ÔÂ10ÈÕ by isoftstone
set feedback off
set define off
prompt Creating M_INDENT...
create table M_INDENT
(
  EMPLOYEE_ID CHAR(3) not null,
  PROVIDER_ID CHAR(3),
  INDENT_ID   CHAR(4) not null,
  INDENT_DATE DATE
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

prompt Loading M_INDENT...
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E3 ', 'S7 ', 'OR67', to_date('23-06-2001', 'dd-mm-yyyy'));
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E7 ', 'S4 ', 'OR76', to_date('25-05-2001', 'dd-mm-yyyy'));
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E6 ', null, 'OR77', null);
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E3 ', 'S4 ', 'OR79', to_date('13-06-2001', 'dd-mm-yyyy'));
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E3 ', null, 'OR90', null);
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E3 ', 'S3 ', 'OR91', to_date('13-07-2001', 'dd-mm-yyyy'));
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E1 ', 'S4 ', 'OR73', to_date('28-07-2001', 'dd-mm-yyyy'));
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E1 ', null, 'OR80', to_date('09-01-2007', 'dd-mm-yyyy'));
commit;
prompt 8 records loaded
set feedback on
set define on
prompt Done.
