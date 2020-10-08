data laund;
infile "H:\laund" firstobs= 2;
input IRI_KEY WEEK SY GE VEND  ITEM  UNITS DOLLARS   F $  D PR;
run;
proc import datafile= " H:\prod.csv" 
out= sec 
dbms= csv
;
run;
proc sql ;
create table final as 
select s.l4 as company,s.l5 as brand, s.l9 as SKU, l.units, l.dollars as total, l.dollars/l.units as unit_price,l.f as feat,l.d as dis
from laund l join sec s on l.vend = s.vend and l.item = s.item and s.sy=l.sy  and s.ge = l.ge ;
group by company,brand,SKU;
quit;
proc sql ;
create table top7 as 
select case when brand in (select brand from q111) then brand else 'others' end as brand,unit_price,feat,dis from final  
order by brand;
quit;
proc freq data = top7;
Tables brand*feat;


run;
proc freq data = top7;
Tables brand*dis;


run;
proc sql;
select brand, avg(unit_price) as avg_unit 
from top7
group by brand;
quit;
proc sql; 
create table sub11 as
select brand,sum(total) as total_rev
from final
group by brand
order by total_rev desc;
quit;
proc sql ; /* Answer for Q1.1*/
create table q111 as 
select * from sub11(obs=6);
quit;

proc sql; /* Answer Q1.1.2 */ 
create table q112 as 
select brand, round((total_rev * 100.00/(select sum(total_rev) from q111)),0.01) as market_share
from q111
group by brand
order by market_share desc;
quit;
proc sql outobs = 5; /* Answer 1.2.1 */
create table q121 as
select company, sum(total) as total_rev
from final
group by company
order by total_rev desc; 
quit; 
proc sql; /* Answer q1.2.2 */
create table q122 as 
select distinct company,brand 
from final;
quit;
proc sql;
create table q13 as 
select case when brand in (select brand from q111) then brand else 'Others' end as brand_name, sum(total) as total_rev
from final
group by brand_name
order by total_rev desc;
quit;
data delstores;
infile "H:\Delivery" firstobs= 2;
input IRI_KEY 1-7 OU $ 9-10 EST_ACV 11-18  Market_Name $ 20-45 Open 46-50 Clsd 50-54 MskdName $;
run;
proc sql;
create table final2 as 
select d.Market_Name as Region ,d.MskdName as MKT_Name,sum(l.dollars) as total_rev
from Delstores d join laund l on d.iri_key = l.iri_key 
group by Region,MKT_Name 
order by total_rev desc;
quit;
proc sql outobs=10; /*Answer 1.6 */
create table q16 as 
select MKT_Name, total_rev from final2;
quit;
proc sql outobs=5; /*Answer 1.5 */
create table q15 as 
select region, sum(total_rev) as total from final2
group by region 
order by total desc;
quit;
proc sql;
create table q18sub as
select l.iri_key as shop_key,s.l5 as brand, sum(l.dollars) as total_rev 
from laund l join sec s on (l.vend = s.vend and l.item = s.item and s.sy=l.sy  and s.ge = l.ge)
group by shop_key, brand;
quit;
proc sql ; /*Answer 1.8 */
create table q18 as 
select case when q.brand in (select brand from q111) then q.brand else 'others' end as brandfinal,  d.Market_Name as region,sum(q.total_rev) as total_rev,sum(q.total_rev)* 100.00 / sub.total_rev as per
from q18sub q join Delstores d on(d.iri_key = q.shop_key) 
left join q111 sub on (sub.brand = q.brand) 
group by brandfinal, region
/*having brandfinal = 'PUREX'*/
order by per desc ;
quit;

proc sql;
create table q182 as 
select distinct brandfinal,region,per 
from q18
where per > 3
order by brandfinal ,per desc;
quit;

proc sql ; /*Answer 1.8 */
create table q183 as 
select case when q.brand in (select brand from q111) then q.brand else 'others' end as brandfinal,  d.MskdName as market,sum(q.total_rev) as total_rev,sum(q.total_rev)* 100.00 / sub.total_rev as per
from q18sub q join Delstores d on(d.iri_key = q.shop_key) 
left join q111 sub on (sub.brand = q.brand) 
group by brandfinal, market
/*having brandfinal = 'PUREX'*/
order by per desc ;
quit;

proc sql;
create table q184 as 
select distinct brandfinal,market,per 
from q183
where per > 1
order by brandfinal ,per desc;
quit;


