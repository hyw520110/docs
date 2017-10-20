prompt PL/SQL Developer import file
prompt Created on 2007年1月10日 by isoftstone
set feedback off
set define off
prompt Creating M_PROVIDER...
create table M_PROVIDER
(
  PROVIDER_ID      CHAR(3) not null,
  PROVIDER_NAME    CHAR(20) not null,
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

prompt Loading M_PROVIDER...
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S3 ', '振华电子厂          ', '西安');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S4 ', '华通电子公司        ', '北京');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S6 ', '607厂               ', '郑州');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S7 ', '爱华电子厂          ', '北京');
commit;
prompt 4 records loaded
set feedback on
set define on
prompt Done.
