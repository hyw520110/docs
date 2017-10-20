prompt PL/SQL Developer import file
prompt Created on 2007Äê1ÔÂ10ÈÕ by isoftstone
set feedback off
set define off
prompt Creating O_INDENT...
create table O_INDENT
(
  EMPLOYEE_ID CHAR(3) not null,
  PROVIDER_ID CHAR(3),
  INDENT_ID   CHAR(4) not null,
  INDENT_DATE DATE,
  ALL_AMOUNT  NUMBER(10,4)
)
tablespace ISS
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

prompt Loading O_INDENT...
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E3 ', 'S7 ', 'OR67', to_date('23-06-2001', 'dd-mm-yyyy'), 35000);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E7 ', 'S4 ', 'OR76', to_date('25-05-2001', 'dd-mm-yyyy'), 12000);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E6 ', null, 'OR77', null, 7250);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E3 ', 'S4 ', 'OR79', to_date('13-06-2001', 'dd-mm-yyyy'), 6000);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E3 ', null, 'OR90', null, 30050);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E3 ', 'S3 ', 'OR91', to_date('13-07-2001', 'dd-mm-yyyy'), 25600);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E1 ', 'S4 ', 'OR73', to_date('28-07-2001', 'dd-mm-yyyy'), 7690);
insert into O_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE, ALL_AMOUNT)
values ('E1 ', null, 'OR80', to_date('09-01-2007', 'dd-mm-yyyy'), 12560);
commit;
prompt 8 records loaded
set feedback on
set define on
prompt Done.
