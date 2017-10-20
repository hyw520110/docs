/*==============================================================*/
/* Database name:  ��������                                         */
/* DBMS name:      ORACLE Version 9i                            */
/* Created on:     2008-8-22 19:40:02                           */
/*==============================================================*/


drop index  index_rrcustfinal 
/


drop index  index_rrcustflow 
/


drop index  index_rrdiccustoption 
/


drop index  index_rrdicfaclev 
/


drop index  index_rrdicfactor 
/


drop index  index_rrdicreportfaclev 
/


drop index  index_rrdicreportfactor 
/


drop index  index_rrriskcalscore 
/


drop table  rrcustfinal  cascade constraints
/


drop table  rrcustflow  cascade constraints
/


drop table  rrdiccustlevel  cascade constraints
/


drop table  rrdiccustoption  cascade constraints
/


drop table  rrdiccusttype  cascade constraints
/


drop table  rrdicfaclev  cascade constraints
/


drop table  rrdicfactor  cascade constraints
/


drop table  rrdicreportfaclev  cascade constraints
/


drop table  rrdicreportfactor  cascade constraints
/


drop table  rrprojectreport  cascade constraints
/


drop table  rrreportscore  cascade constraints
/


drop table  rrriskcalscore  cascade constraints
/


drop table  rrdicbackward  cascade constraints
/


/*==============================================================*/
/* Table:  rrcustfinal                                          */
/*==============================================================*/


create table  rrcustfinal   (
    flowid              varchar2(40)                     not null,
    custid              varchar2(20)                     not null,
    regioncode          varchar2(6)                      not null,
    custname            varchar2(60),
    projectno           varchar2(40)                     not null,
    workitem            varchar2(20),
    custcode            varchar2(40),
    induscode           varchar2(5),
    indusname           varchar2(20),
    orgcode             varchar2(15),
    orgname             varchar2(60),
    scorequa            decimal(16,2),
    scorefin            decimal(16,2),
    scorecredit         decimal(16,2),
    scorecreditcheck    decimal(16,2),
    scoreassure         decimal(16,2),
    scoreassurecheck    decimal(16,2),
    scorecon            decimal(16,2),
    scoreconcheck       decimal(16,2),
    scoreabs            decimal(16,2),
    scoreabscheck       decimal(16,2),
    scoretotal          decimal(16,2),
    scoreadj            decimal(16,2),
    levelcal            varchar2(5),
    levelfin            varchar2(5),
    levellast           varchar2(5),
    leveladjreason      varchar2(200),
    reason              varchar2(500),
    state               varchar2(1)                      not null,
    bypjbz              varchar2(1),
    dpjbz               varchar2(1),
    newflag             varchar2(1),
    dateapp             varchar2(10)                     not null,
    datefrom            varchar2(10),
    dateto              varchar2(10),
    days                integer,
    terms               varchar2(6)                      not null,
    operatorid          varchar2(20)                     not null,
    crtype              varchar2(12)                     not null,
    custflag            varchar2(2)                      not null,
    custtype            varchar2(2),
    custtypename        varchar2(20),
    repattr             varchar2(2),
    repperiod           varchar2(2),
    reptype             varchar2(2),
    repcurrtype         varchar2(3),
    jzbbqs              varchar2(6),
    sqbbqs              varchar2(6),
    ssqbbqs             varchar2(6),
    fxxe                decimal(16,2),
    qygm                varchar2(4),
    bz                  varchar2(10),
    businesslevel       varchar2(4),
    contype             varchar2(4),
    busitype            varchar2(10),
    postcode            varchar2(6),
   constraint pk_rrcustfinal primary key ( flowid ,  custid ,  regioncode ,  projectno ,  terms )
)
/


comment on column  rrcustfinal . flowid  is
'������'
/


comment on column  rrcustfinal . custid  is
'�ͻ���'
/


comment on column  rrcustfinal . scorequa  is
'���Ե÷�'
/


comment on column  rrcustfinal . scorefin  is
'�����÷�'
/


comment on column  rrcustfinal . scoretotal  is
'�ܵ÷�'
/


comment on column  rrcustfinal . scoreadj  is
'ר�ҵ����÷�'
/


comment on column  rrcustfinal . levelcal  is
'ȷ������'
/


comment on column  rrcustfinal . levelfin  is
'����ȷ������'
/


comment on column  rrcustfinal . levellast  is
'������Ч���'
/


comment on column  rrcustfinal . state  is
'����״̬
1:��������
2���������'
/


comment on column  rrcustfinal . bypjbz  is
'����������־'
/


comment on column  rrcustfinal . dpjbz  is
'��������־'
/


comment on column  rrcustfinal . newflag  is
'0��������
1����Ч������
2��ʧЧ������

'
/


comment on column  rrcustfinal . dateapp  is
'��������'
/


comment on column  rrcustfinal . datefrom  is
'��������'
/


comment on column  rrcustfinal . dateto  is
'��������'
/


comment on column  rrcustfinal . operatorid  is
'����Ա��(��һ����λ�Ĳ���Ա��������Ա��'
/


comment on column  rrcustfinal . jzbbqs  is
'��׼��������'
/


comment on column  rrcustfinal . sqbbqs  is
'���ڱ�������'
/


comment on column  rrcustfinal . ssqbbqs  is
'�����ڱ�������'
/


comment on column  rrcustfinal . qygm  is
'��ҵ��ģ'
/


comment on column  rrcustfinal . bz  is
'0������
1������'
/


comment on column  rrcustfinal . contype  is
'���̿���/�����������'
/


/*==============================================================*/
/* Index:  index_rrcustfinal                                    */
/*==============================================================*/
create index  index_rrcustfinal  on  rrcustfinal  (
    flowid  asc,
    custid  asc,
    projectno  asc,
    terms  asc
)
/


/*==============================================================*/
/* Table:  rrcustflow                                           */
/*==============================================================*/


create table  rrcustflow   (
    flowid              varchar2(40)                     not null,
    workitem            varchar2(20)                     not null,
    custid              varchar2(20)                     not null,
    regioncode          varchar2(6)                      not null,
    projectno           varchar2(40)                     not null,
    scorecredit         decimal(16,2),
    scorecreditcheck    decimal(16,2),
    scorequa            decimal(16,2),
    scorefin            decimal(16,2),
    scoreassure         decimal(16,2),
    scoreassurecheck    decimal(16,2),
    scorecon            decimal(16,2),
    scoreconcheck       decimal(16,2),
    scoreabs            decimal(16,2),
    scoreabscheck       decimal(16,2),
    scoretotal          decimal(16,2),
    scoreadj            decimal(16,2),
    leveladj            varchar2(5),
    reason              varchar2(500),
    dateapp             varchar2(10),
    operatorid          varchar2(20)                     not null,
    bz                  varchar2(6),
    contype             varchar2(4),
    businesslevel       varchar2(4),
   constraint pk_rrcustflow primary key ( flowid ,  workitem ,  custid ,  regioncode ,  projectno )
)
/


comment on column  rrcustflow . flowid  is
'������'
/


comment on column  rrcustflow . workitem  is
'�������'
/


comment on column  rrcustflow . scorequa  is
'���Ե÷�'
/


comment on column  rrcustflow . scorefin  is
'�����÷�'
/


comment on column  rrcustflow . scoretotal  is
'�ܵ÷�'
/


comment on column  rrcustflow . scoreadj  is
'ר�ҵ����÷�'
/


comment on column  rrcustflow . leveladj  is
'��������󼶱�'
/


comment on column  rrcustflow . reason  is
'�������ԭ��'
/


comment on column  rrcustflow . dateapp  is
'��������'
/


comment on column  rrcustflow . operatorid  is
'����Ա��'
/


comment on column  rrcustflow . bz  is
'��1λ��
0��ֻ�������û��������
1������������
2������������

��2λ��
0���ͻ����ҳ��δѡ��
1���ͻ����ҳ����ѡ��

��3λ��
0������ҳ��δѡ��
1������ҳ����ѡ��

��4λ��
0������ҳ��δѡ��
1������ҳ����ѡ��


'
/


comment on column  rrcustflow . contype  is
'���̿���/�����������'
/


/*==============================================================*/
/* Index:  index_rrcustflow                                     */
/*==============================================================*/
create index  index_rrcustflow  on  rrcustflow  (
    flowid  asc,
    custid  asc,
    projectno  asc
)
/


/*==============================================================*/
/* Table:  rrdiccustlevel                                       */
/*==============================================================*/


create table  rrdiccustlevel   (
    crtype              varchar2(12)                     not null,
    custflag            varchar2(2)                      not null,
    custtype            varchar2(2),
    levelcode           varchar2(4)                      not null,
    levelname           varchar(12)                      not null,
    bottom              decimal(16,2)                    not null,
    top                 decimal(16,2)                    not null,
   constraint pk_xt_xydjzd primary key ( crtype ,  custflag ,  levelcode )
)
/


comment on table  rrdiccustlevel  is
'���õȼ��ֵ��'
/


comment on column  rrdiccustlevel . levelcode  is
'�ȼ�����'
/


comment on column  rrdiccustlevel . levelname  is
'�ȼ�����'
/


comment on column  rrdiccustlevel . bottom  is
'����ֵ'
/


comment on column  rrdiccustlevel . top  is
'����ֵ'
/


/*==============================================================*/
/* Table:  rrdiccustoption                                      */
/*==============================================================*/


create table  rrdiccustoption   (
    crtype              varchar2(12)                     not null,
    custflag            varchar2(2)                      not null,
    custtype            varchar2(2)                      not null,
    pageid              varchar2(2)                      not null,
    pagetype            varchar2(4),
    pagename            varchar2(30),
    pageurl             varchar2(100),
    operateflag         varchar2(2)                      not null,
   bz                   varchar2(6),
   constraint pk_rrdiccustoption primary key ( crtype ,  custtype ,  custflag ,  pageid )
)
/


comment on table  rrdiccustoption  is
'�������д���Ϳͻ��ĶԹ��������ԣ�
����Ӧ��ҳ���������'
/


comment on column  rrdiccustoption . custflag  is
'0������
1���Թ�
'
/


comment on column  rrdiccustoption . custtype  is
'0������
1���Թ�
'
/


comment on column  rrdiccustoption . pageid  is
'���������ҳ�����
01:���������
02������
03������'
/


comment on column  rrdiccustoption . operateflag  is
'��ҳ�������еĲ���
00 ����ʾ��������ҳ��
01 : ��ʾҳ�����
'
/


/*==============================================================*/
/* Index:  index_rrdiccustoption                                */
/*==============================================================*/
create index  index_rrdiccustoption  on  rrdiccustoption  (
    crtype  asc,
    custflag  asc,
    custtype  asc
)
/


/*==============================================================*/
/* Table:  rrdiccusttype                                        */
/*==============================================================*/


create table  rrdiccusttype   (
    ratingmodel         varchar2(5)                      not null,
    custflag            varchar2(2)                      not null,
    custflagname        varchar2(20)                     not null,
    custtype            varchar2(2)                      not null,
    custtypename        varchar2(50)                     not null,
   constraint pk_rrdiccusttype primary key ( ratingmodel ,  custflag ,  custtype )
)
/


comment on column  rrdiccusttype . ratingmodel  is
'0:��ݸ����;1:��������'
/


comment on column  rrdiccusttype . custflag  is
'�ͻ��ĸ��˶Թ�����
0������
1���Թ�'
/


comment on column  rrdiccusttype . custflagname  is
'�ͻ��ĸ��˶Թ�����'
/


comment on column  rrdiccusttype . custtype  is
'�����Ŀͻ�����'
/


/*==============================================================*/
/* Table:  rrdicfaclev                                          */
/*==============================================================*/


create table  rrdicfaclev   (
    crtype              varchar2(12)                     not null,
    custtype            varchar2(4)                      not null,
    custflag            varchar2(1)                      not null,
    factorcode          varchar2(4)                      not null,
    factorname          varchar2(32),
    factortype          varchar2(1)                      not null,
    sectiontype         varchar2(4)                      not null,
    sectionname         varchar2(60),
    valuetop            decimal(16,2)                    not null,
    valuebottom         decimal(16,2)                    not null,
    power               decimal(16,2)                    not null,
    stdvalue            decimal(16,2),
    scoretop            decimal(16,2),
    scorebottom         decimal(16,2),
    descmean            varchar2(200),
   constraint pk_rrdicfaclev primary key ( crtype ,  custtype ,  custflag ,  factorcode ,  factortype ,  sectiontype )
)
/


comment on column  rrdicfaclev . custtype  is
'01�����ز���
02��������ҵ'
/


comment on column  rrdicfaclev . custflag  is
'0:����
1:�Թ�'
/


comment on column  rrdicfaclev . factorcode  is
'�������ش���'
/


comment on column  rrdicfaclev . factortype  is
'0������
1������'
/


comment on column  rrdicfaclev . valuetop  is
'ָ��ֵ����'
/


comment on column  rrdicfaclev . valuebottom  is
'ָ��ֵ����'
/


comment on column  rrdicfaclev . power  is
'����ָ��Ȩ��'
/


comment on column  rrdicfaclev . scoretop  is
'�÷�'
/


/*==============================================================*/
/* Index:  index_rrdicfaclev                                    */
/*==============================================================*/
create index  index_rrdicfaclev  on  rrdicfaclev  (
    crtype  asc,
    custtype  asc,
    custflag  asc
)
/


/*==============================================================*/
/* Table:  rrdicfactor                                          */
/*==============================================================*/


create table  rrdicfactor   (
    crtype              varchar2(12)                     not null,
    custtype            varchar2(4)                      not null,
    custflag            varchar2(1)                      not null,
    factorcode          varchar2(4)                      not null,
    factortype          varchar2(1)                      not null,
    incode              varchar2(4),
    faclevel            int,
    supfactor           varchar2(4),
    factorchar          varchar2(1),
    form                varchar2(80),
    factorname          varchar2(32)                     not null,
    power               decimal(16,2)                    not null,
    scoretop            decimal(16,2),
    scorebottom         decimal(16,2),
    score               decimal(16,2),
    description         varchar2(200),
   constraint pk_rrdicfactor primary key ( crtype ,  custtype ,  custflag ,  factorcode ,  factortype )
)
/


comment on column  rrdicfactor . factortype  is
'0���ͻ���������
1��������������
2�����̿�������
3���ر������۷�'
/


comment on column  rrdicfactor . incode  is
'����ڲ�������'
/


comment on column  rrdicfactor . factorchar  is
'0������ָ��
1������ָ��'
/


comment on column  rrdicfactor . factorname  is
'��������'
/


comment on column  rrdicfactor . power  is
'����Ȩ��'
/


/*==============================================================*/
/* Index:  index_rrdicfactor                                    */
/*==============================================================*/
create index  index_rrdicfactor  on  rrdicfactor  (
    crtype  asc,
    custtype  asc,
    custflag  asc
)
/


/*==============================================================*/
/* Table:  rrdicreportfaclev                                    */
/*==============================================================*/


create table  rrdicreportfaclev   (
    crtype              varchar2(12)                     not null,
    reporttype          varchar2(4)                      not null,
    factorcode          varchar2(4)                      not null,
    factorname          varchar2(40),
    sectiontype         varchar2(4)                      not null,
    sectionname         varchar2(60),
    valuetop            decimal(16,2)                    not null,
    valuebottom         decimal(16,2)                    not null,
    power               decimal(16,2)                    not null,
    stdvalue            decimal(16,2),
    scoretop            decimal(16,2),
    scorebottom         decimal(16,2),
    descmean            varchar2(200),
   constraint pk_rrdicreportfaclev primary key ( crtype ,  reporttype ,  factorcode ,  sectiontype )
)
/


comment on column  rrdicreportfaclev . reporttype  is
'01�����ز���
02��������ҵ'
/


comment on column  rrdicreportfaclev . factorcode  is
'�������ش���'
/


comment on column  rrdicreportfaclev . valuetop  is
'ָ��ֵ����'
/


comment on column  rrdicreportfaclev . valuebottom  is
'ָ��ֵ����'
/


comment on column  rrdicreportfaclev . power  is
'����ָ��Ȩ��'
/


comment on column  rrdicreportfaclev . scoretop  is
'�÷�'
/


/*==============================================================*/
/* Index:  index_rrdicreportfaclev                              */
/*==============================================================*/
create index  index_rrdicreportfaclev  on  rrdicreportfaclev  (
    crtype  asc,
    reporttype  asc
)
/


/*==============================================================*/
/* Table:  rrdicreportfactor                                    */
/*==============================================================*/


create table  rrdicreportfactor   (
    crtype              varchar2(12)                     not null,
    reporttype          varchar2(4)                      not null,
    factorcode          varchar2(4)                      not null,
    faclevel            int,
    supfactor           varchar2(4),
    form                varchar2(80),
    factorname          varchar2(32),
    power               decimal(16,2)                    not null,
    scoretop            decimal(16,2),
    scorebottom         decimal(16,2),
    score               decimal(16,2),
    description         varchar2(200),
   constraint pk_rrdicreportfactor primary key ( crtype ,  reporttype ,  factorcode )
)
/


comment on column  rrdicreportfactor . factorname  is
'��������'
/


comment on column  rrdicreportfactor . power  is
'����Ȩ��'
/


/*==============================================================*/
/* Index:  index_rrdicreportfactor                              */
/*==============================================================*/
create index  index_rrdicreportfactor  on  rrdicreportfactor  (
    crtype  asc,
    reporttype  asc
)
/


/*==============================================================*/
/* Table:  rrprojectreport                                      */
/*==============================================================*/


create table  rrprojectreport   (
    flowid              varchar2(40)                     not null,
    custid              varchar2(20)                     not null,
    regioncode          varchar2(6)                      not null,
    custname            varchar2(60),
    projectno           varchar2(40)                     not null,
    workitem            varchar2(20),
    scorecredit         decimal(16,2),
    scorecreditcheck    decimal(16,2),
    scoreassure         decimal(16,2),
    scoreassurecheck    decimal(16,2),
    dateapp             varchar2(10),
    apppersonid         varchar2(20),
    instcode            varchar2(20),
    deptcode            varchar2(20),
   constraint pk_rrprojectreport primary key ( flowid ,  custid ,  regioncode ,  projectno )
)
/


comment on column  rrprojectreport . flowid  is
'������'
/


comment on column  rrprojectreport . custid  is
'�ͻ���'
/


/*==============================================================*/
/* Table:  rrreportscore                                        */
/*==============================================================*/


create table  rrreportscore   (
    flowid              varchar2(40)                     not null,
    workitem            varchar2(20)                     not null,
    factor              varchar2(4)                      not null,
    section             varchar2(4)                      not null,
    factortype          varchar2(1)                      not null,
    facvalue            decimal(16,2),
    score               decimal(16,2),
    bz                  varchar2(200),
    faclevel            int,
   constraint pk_rrreportscore primary key ( flowid ,  workitem ,  factor ,  factortype )
)
/


comment on column  rrreportscore . flowid  is
'������'
/


comment on column  rrreportscore . workitem  is
'�������'
/


comment on column  rrreportscore . factor  is
'���ش���'
/


comment on column  rrreportscore . section  is
'ָ�����'
/


comment on column  rrreportscore . facvalue  is
'����ָ��ʵ��ֵ'
/


/*==============================================================*/
/* Table:  rrriskcalscore                                       */
/*==============================================================*/


create table  rrriskcalscore   (
    flowid              varchar2(40)                     not null,
    workitem            varchar2(20)                     not null,
    factor              varchar2(4)                      not null,
    section             varchar2(4)                      not null,
    factortype          varchar2(1)                      not null,
    facvalue            decimal(16,2),
    scorea              decimal(16,2),
    score               decimal(16,2),
    bz                  varchar2(200),
    businesslevel       varchar2(4),
    faclevel            int,
   constraint pk_rrriskcalscore primary key ( flowid ,  workitem ,  factor ,  factortype )
)
/


comment on column  rrriskcalscore . flowid  is
'������'
/


comment on column  rrriskcalscore . workitem  is
'�������'
/


comment on column  rrriskcalscore . factor  is
'���ش���'
/


comment on column  rrriskcalscore . section  is
'ָ�����'
/


comment on column  rrriskcalscore . facvalue  is
'����ָ��ʵ��ֵ'
/


comment on column  rrriskcalscore . scorea  is
'ָ��÷�'
/


comment on column  rrriskcalscore . businesslevel  is
'�������ֿ��������������߱����ܵ�����'
/


/*==============================================================*/
/* Index:  index_rrriskcalscore                                 */
/*==============================================================*/
create index  index_rrriskcalscore  on  rrriskcalscore  (
    flowid  asc,
    workitem  asc
)
/


/*==============================================================*/
/* Table:  rrdicbackward                                        */
/*==============================================================*/


create table  rrdicbackward   (
    crtype              varchar2(12)                     not null,
    busitype            varchar2(5)                      not null,
    custflag            varchar2(1)                      not null,
    factorcode          varchar2(4)                      not null,
    levelcode           varchar2(4)                      not null,
    factorname          varchar2(32),
    description         varchar2(500),
    sparechar1          varchar2(20),
    sparechar2          varchar2(20),
    sparechar3          varchar2(20),
    sparechar4          varchar2(20),
    sparechar5          varchar2(20),
    sparechar6          varchar2(20),
   constraint pk_rrdicbackward primary key ( crtype ,  busitype ,  custflag ,  factorcode )
)
/


comment on column  rrdicbackward . levelcode  is
'����ڲ�������'
/


comment on column  rrdicbackward . factorname  is
'��������'
/

