                           
---SUBQUERY, CASE WHEN
create table p1 as
select *,
	case when (name like '%1G%' or name = 'DP') and name not like '%T%' then '1G' 
	when name like '%10G%' and name not like '%T%' then '10G'
	when name like '%Un%'  and name not like '%T%' then 'UN'
	when name like '%T%' or name like '%UNKNOWN%' or name like '%SW%' then 'T'
	else 'ERROR' end as type
from (
	select *,
			date(date_parse(cast(fiscal_year as varchar)||'-'||cast(fiscal_month as varchar)||'-'||'21','%Y-%m-%d')) as cycle_end,
			date_add('month',-1,date(date_parse(cast(fiscal_year as varchar)||'-'||cast(fiscal_month as varchar)||'-'||'21','%Y-%m-%d'))) as cycle_start,
			CONCAT(name1,' ',name2) as name
	from t1
	)



---CROSS JOIN
create table P2 as
select 
T1.*, DIM.FISCAL_MONTH_END_DATE
from T1 
cross join DATE_DIM DIM 
where END_DATE >= CONNECT_DATE and END_DATE <= DATE '2021-10-21'
group by 1,2,3,4


--- WINDOW: RANK()
create table P3 as 
select * from 
(select  id, 
	type,
	date,
	count,
	rank() over (partition by id, type order by count ) as group_rank
from t1
) 
where group_rank = 1 



--- WINDOW FUNCTION: NTILE()
create table  P4  as
select  id,
	type,
	NTILE(4) OVER(PARTITION by type,ID ORDER BY count desc) as group25,
	NTILE(10) OVER(PARTITION by type,ID ORDER BY count desc) as group10,
	NTILE(20) OVER(PARTITION by type,ID ORDER BY count desc) as group5,
	NTILE(100) OVER(PARTITION by type,ID ORDER BY count desc) as group1
	from t1
	where ind = 'F'
				


--- MEDIAN
create table P5 as
select 
	date,
	type,
	approx_percentile(total_usage, 0.5) as median 
from T1
group by 1,2

