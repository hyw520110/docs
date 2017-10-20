prompt PL/SQL Developer import file
prompt Created on 2007年2月9日 by isoftstone
set feedback off
set define off
prompt Creating M_EMPLOYEE...


create table M_EMPLOYEE员工表
(
  WAREHOUSE_ID CHAR(4) not null,仓库号
  EMPLOYEE_ID  CHAR(3) not null,员工号
  SALARY       NUMBER(4) not null工资
)
tablespace ISS
  pctfree 
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 12K
    minextents 1
    maxextents unlimited
  );



prompt Creating M_INDENT...
create table M_INDENT
(
  EMPLOYEE_ID CHAR(3) not null,
  PROVIDER_ID CHAR(3),供应号
  INDENT_ID   CHAR(4) not null,交易号
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



prompt Creating M_PROVIDER...
create table M_PROVIDER供应商
(
  PROVIDER_ID      CHAR(3) not null,
  PROVIDER_NAME    VARCHAR2(20) not null,
  PROVIDER_ADDRESS CHAR(4) not null
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



prompt Creating M_WAREHOUSE...
create table M_WAREHOUSE仓库
(
  WAREHOUSE_ID CHAR(4) not null,
  CITY         CHAR(4) not null,
  AREA         NUMBER(4) not null
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



prompt Loading M_EMPLOYEE...
insert into M_EMPLOYEE (WAREHOUSE_ID, EMPLOYEE_ID, SALARY)
values ('WH2 ', 'E1 ', 1200);
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
insert into M_INDENT (EMPLOYEE_ID, PROVIDER_ID, INDENT_ID, INDENT_DATE)
values ('E8 ', 'S9 ', 'OR99', to_date('25-12-2006', 'dd-mm-yyyy'));
commit;
prompt 9 records loaded
prompt Loading M_PROVIDER...
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S3 ', '振华电子厂', '西安');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S4 ', '华通电子公司', '北京');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S6 ', '607工厂', '郑州');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S7 ', '爱华电子厂', '北京');
commit;
prompt 4 records loaded
prompt Loading M_WAREHOUSE...
insert into M_WAREHOUSE (WAREHOUSE_ID, CITY, AREA)
values ('WH1 ', '北京', 370);
insert into M_WAREHOUSE (WAREHOUSE_ID, CITY, AREA)
values ('WH2 ', '上海', 500);
insert into M_WAREHOUSE (WAREHOUSE_ID, CITY, AREA)
values ('WH3 ', '广州', 200);
insert into M_WAREHOUSE (WAREHOUSE_ID, CITY, AREA)
values ('WH4 ', '武汉', 400);
commit;
prompt 4 records loaded
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
