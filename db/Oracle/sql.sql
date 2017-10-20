 
     

select * from VW_GRADE_QUANT_MODEL
for update

select * from ARMS_CREDIT_BASE
select * from arms_model_scope
select * from arms_model_rule
select * from ARMS_RESEARCH_REPORT
select * from ARMS_CREDIT_EXT


select   USER_ID,TRANS_DT,GRADE,QUANT,TIME_STAMP,DATE_ID  	FROM VW_GRADE_QUANT_MODEL
			WHERE  1=1 
    --  and user in('2088101011882143')
      and 	TRANS_DT>= to_date('20101221','yyyyMMdd')
      and TRANS_DT <= to_date('20101228','yyyyMMdd') 
     
     
 
select (case when max(id) is null  then 1 else max(id) end ) as id from ARMS_RESEARCH_REPORT

select distinct user_id,quant,trans_dt,line,time_stamp from 
(
select a.user_id,a.quant,a.trans_dt,b.line, b.upscroe,b.downscroe,b.time_stamp from 
 VW_GRADE_QUANT_MODEL a left join VO_ARMS_SCORE b on (a.quant>b.downscroe and a.quant<=b.upscroe)
 ) c    order by time_stamp desc
 
 

                   
     --先建视图：v_model_score
select a.user_id,a.quant,a.trans_dt,b.line, b.upscroe,b.downscroe,b.time_stamp from  VW_GRADE_QUANT_MODEL a left join VO_ARMS_SCORE b on (a.quant>b.downscroe and a.quant<=b.upscroe)
  --查询结果
   select * from v_model_score v1 where time_stamp=(select max(time_stamp) from v_model_score v2 where v1.time_stamp=v2.time_stamp)
 )

临时表
 select * from user_recyclebin
 清空临时表
 purge recyclebin;