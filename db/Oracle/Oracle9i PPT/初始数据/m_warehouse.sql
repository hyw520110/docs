prompt PL/SQL Developer import file
prompt Created on 2007年1月10日 by isoftstone
set feedback off
set define off
prompt Creating M_WAREHOUSE...
create table M_WAREHOUSE
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
set feedback on
set define on
prompt Done.
