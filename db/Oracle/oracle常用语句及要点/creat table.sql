/*==============================================================*/
/* Database name:  担保流程                                         */
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
'任务编号'
/


comment on column  rrcustfinal . custid  is
'客户号'
/


comment on column  rrcustfinal . scorequa  is
'定性得分'
/


comment on column  rrcustfinal . scorefin  is
'定量得分'
/


comment on column  rrcustfinal . scoretotal  is
'总得分'
/


comment on column  rrcustfinal . scoreadj  is
'专家调整得分'
/


comment on column  rrcustfinal . levelcal  is
'确定级别'
/


comment on column  rrcustfinal . levelfin  is
'最终确定级别'
/


comment on column  rrcustfinal . levellast  is
'上期有效结果'
/


comment on column  rrcustfinal . state  is
'评级状态
1:正在评定
2：评定完成'
/


comment on column  rrcustfinal . bypjbz  is
'不予评级标志'
/


comment on column  rrcustfinal . dpjbz  is
'待评级标志'
/


comment on column  rrcustfinal . newflag  is
'0：旧评级
1：有效新评级
2：失效新评级

'
/


comment on column  rrcustfinal . dateapp  is
'评级日期'
/


comment on column  rrcustfinal . datefrom  is
'评级日期'
/


comment on column  rrcustfinal . dateto  is
'评级日期'
/


comment on column  rrcustfinal . operatorid  is
'操作员号(第一个岗位的操作员，初评人员）'
/


comment on column  rrcustfinal . jzbbqs  is
'基准报表期数'
/


comment on column  rrcustfinal . sqbbqs  is
'上期报表期数'
/


comment on column  rrcustfinal . ssqbbqs  is
'上上期报表期数'
/


comment on column  rrcustfinal . qygm  is
'企业规模'
/


comment on column  rrcustfinal . bz  is
'0：初评
1：重评'
/


comment on column  rrcustfinal . contype  is
'过程控制/反担保物控制'
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
'任务编号'
/


comment on column  rrcustflow . workitem  is
'流程序号'
/


comment on column  rrcustflow . scorequa  is
'定性得分'
/


comment on column  rrcustflow . scorefin  is
'定量得分'
/


comment on column  rrcustflow . scoretotal  is
'总得分'
/


comment on column  rrcustflow . scoreadj  is
'专家调整得分'
/


comment on column  rrcustflow . leveladj  is
'级别调整后级别'
/


comment on column  rrcustflow . reason  is
'级别调整原因'
/


comment on column  rrcustflow . dateapp  is
'调整日期'
/


comment on column  rrcustflow . operatorid  is
'操作员号'
/


comment on column  rrcustflow . bz  is
'第1位：
0：只有意见，没有评级；
1：初次评级；
2：重新评级；

第2位：
0：客户检查页面未选择
1：客户检查页面已选择

第3位：
0：定性页面未选择
1：定性页面已选择

第4位：
0：定性页面未选择
1：定性页面已选择


'
/


comment on column  rrcustflow . contype  is
'过程控制/反担保物控制'
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
'信用等级字典表'
/


comment on column  rrdiccustlevel . levelcode  is
'等级代码'
/


comment on column  rrdiccustlevel . levelname  is
'等级名称'
/


comment on column  rrdiccustlevel . bottom  is
'下限值'
/


comment on column  rrdiccustlevel . top  is
'上限值'
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
'根据银行代码和客户的对公个人属性，
所对应的页面操作种类'
/


comment on column  rrdiccustoption . custflag  is
'0：个人
1：对公
'
/


comment on column  rrdiccustoption . custtype  is
'0：个人
1：对公
'
/


comment on column  rrdiccustoption . pageid  is
'评级所需的页面代码
01:不予待评级
02：定量
03：定性'
/


comment on column  rrdiccustoption . operateflag  is
'对页面所进行的操作
00 ：表示不经过该页面
01 : 表示页面存在
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
'0:东莞商行;1:济南商行'
/


comment on column  rrdiccusttype . custflag  is
'客户的个人对公属性
0：个人
1：对公'
/


comment on column  rrdiccusttype . custflagname  is
'客户的个人对公属性'
/


comment on column  rrdiccusttype . custtype  is
'评级的客户类型'
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
'01：房地产类
02：其他行业'
/


comment on column  rrdicfaclev . custflag  is
'0:个人
1:对公'
/


comment on column  rrdicfaclev . factorcode  is
'财务因素代码'
/


comment on column  rrdicfaclev . factortype  is
'0：定量
1：定性'
/


comment on column  rrdicfaclev . valuetop  is
'指标值上限'
/


comment on column  rrdicfaclev . valuebottom  is
'指标值下限'
/


comment on column  rrdicfaclev . power  is
'财务指标权重'
/


comment on column  rrdicfaclev . scoretop  is
'得分'
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
'0：客户信用评分
1：反担保物评分
2：过程控制评分
3：必备条件扣分'
/


comment on column  rrdicfactor . incode  is
'针对于财务因素'
/


comment on column  rrdicfactor . factorchar  is
'0：基础指标
1：修正指标'
/


comment on column  rrdicfactor . factorname  is
'因素名称'
/


comment on column  rrdicfactor . power  is
'因素权重'
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
'01：房地产类
02：其他行业'
/


comment on column  rrdicreportfaclev . factorcode  is
'财务因素代码'
/


comment on column  rrdicreportfaclev . valuetop  is
'指标值上限'
/


comment on column  rrdicreportfaclev . valuebottom  is
'指标值下限'
/


comment on column  rrdicreportfaclev . power  is
'财务指标权重'
/


comment on column  rrdicreportfaclev . scoretop  is
'得分'
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
'因素名称'
/


comment on column  rrdicreportfactor . power  is
'因素权重'
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
'任务编号'
/


comment on column  rrprojectreport . custid  is
'客户号'
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
'任务编号'
/


comment on column  rrreportscore . workitem  is
'流程序号'
/


comment on column  rrreportscore . factor  is
'因素代码'
/


comment on column  rrreportscore . section  is
'指标代码'
/


comment on column  rrreportscore . facvalue  is
'财务指标实际值'
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
'任务编号'
/


comment on column  rrriskcalscore . workitem  is
'流程序号'
/


comment on column  rrriskcalscore . factor  is
'因素代码'
/


comment on column  rrriskcalscore . section  is
'指标代码'
/


comment on column  rrriskcalscore . facvalue  is
'财务指标实际值'
/


comment on column  rrriskcalscore . scorea  is
'指标得分'
/


comment on column  rrriskcalscore . businesslevel  is
'用来区分可行性审批，或者保后监管等流程'
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
'针对于财务因素'
/


comment on column  rrdicbackward . factorname  is
'因素名称'
/

