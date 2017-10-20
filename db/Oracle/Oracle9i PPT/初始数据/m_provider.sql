prompt PL/SQL Developer import file
prompt Created on 2007��1��10�� by isoftstone
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
values ('S3 ', '�񻪵��ӳ�          ', '����');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S4 ', '��ͨ���ӹ�˾        ', '����');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S6 ', '607��               ', '֣��');
insert into M_PROVIDER (PROVIDER_ID, PROVIDER_NAME, PROVIDER_ADDRESS)
values ('S7 ', '�������ӳ�          ', '����');
commit;
prompt 4 records loaded
set feedback on
set define on
prompt Done.
