/*Q11*/

/*Importing & Sorting & Merging*/
data a1;infile 'c:\Users\dxk180020\desktop\hw5\laundet_groc_1114_1165.dat' firstobs=2;
input IRI_KEY WEEK SY GE VEND ITEM UNITS DOLLARS F $ D $ PR;
run;
proc print data=a1(obs=10); run;

DATA b1;
INFILE "C:\Users\dxk180020\Desktop\hw5\prod_laundet.csv" DLM=',' firstobs=2;
INPUT L1 $ L2 $ L3 $ L4 $ L5 $ L9 $ Level UPC $ SY GE VEND ITEM STUBSPEC $ VOL_EQ;
RUN;
proc print data=b1(obs=10); run;

data b2;set b1;
UPC2=SY||GE||VEND||ITEM;
upc3=cats(SY,GE,VEND,ITEM);run;
run;

data a2;set a1;
length sy 3 ge 3 vend 5 item 5;
UPC2=sy||ge||vend||item;
upc3=cats(sy,ge,vend,item);
drop UPC;run;
proc print data=a2(obs=20);run;

DATA c1;
infile "C:\Users\dxk180020\Desktop\hw5\Delivery_Stores" DLM='' firstobs=2;
INPUT IRI_KEY 1-7 OU $8-10 EST_ACV 11-19 Market_Name $21-40 Open Clsd MskdName $;
RUN;
proc print data=c1(obs=10); run;

proc sort data=a2 out=s_a2; by SY GE VEND ITEM; run;
proc sort data=b2 out=s_b2; by SY GE VEND ITEM; run;
data m1; merge s_a2(in=aa) s_b2(in=bb); by SY GE VEND ITEM; if aa and bb; run;

proc print data=m1(obs=10);run;

/*
proc sort data=a1 out=s_a1; by SY GE VEND ITEM; run;
proc sort data=b1 out=s_b1; by SY GE VEND ITEM; run;
data m1; merge s_a1(in=aa) s_b1(in=bb); by SY GE VEND ITEM; if aa and bb; run;
*/

proc sort data=m1 out=s_m1; by IRI_KEY; run;
proc sort data=c1 out=s_c1; by IRI_KEY; run;
data m2; merge s_m1(in=cc) s_c1(in=dd); by IRI_KEY; if cc and dd; run;
proc print data=m2(obs=10);run;

/* My brand: GAIN (Powder) */
data gain_powder; set m2; if L2 = "POWDER L" and L5 ='GAIN'; run;

/* Convert Display, Feature, Price Reduction to dummy variables */
data final_df; set gain_powder;
IF D = 0 THEN D_0 = 1; 
    ELSE D_0 = 0;
IF D = 1 or D = 2 THEN D_1 = 1; 
    ELSE D_1 = 0;
IF F = 'NONE' THEN F_0 = 1; 
    ELSE F_0 = 0;
IF F = 'A' or F='B' or F = 'C' or F='A+' THEN F_1 = 1; 
    ELSE F_1 = 0;
IF PR = 0 THEN PR_0 = 1; 
    ELSE PR_0 = 0;
IF PR = 1 THEN PR_1 = 1; 
    ELSE PR_1 = 0;
run;

/* Price per OZ and Price per Unit */
data final_df2; set final_df;
SIZE = VOL_EQ * 16;
PRICE_PER_OZ = (DOLLARS/SIZE)/UNITS;
PRICE_PER_UNIT= (DOLLARS/SIZE);
run;
proc print data=final_df2(obs=10); run;

/* sum of total dollar sales, display, feature, and price reduction(5781992, 4936, 8478, 20199 resepectively

proc sql; 
	select sum(DOLLARS), sum(D_1), sum(F_1), sum(PR_1)
	from final_df2;
quit;
*/

/* The Case of Price per Unit */
proc sql;
	create table test as
		select upc3, sum(PRICE_PER_UNIT) as sum_price, 
					 sum(D_1) as display_per_UPC, sum(D_1)/4936 as d_weight,
					 sum(F_1) as feature_per_UPC, sum(F_1)/8478 as f_weight,
					 sum(PR_1) as price_reduction_per_UPC, sum(PR_1)/20199 as pr_weight
		from final_df2
		group by upc3
		order by upc3;
quit;
proc print data=test(obs=10); run; 

proc sort data=final_df2 out=s_final_df2; by UPC3; run;
proc sort data=test out=s_test; by UPC3; run;
data m3; merge s_final_df2(in=ee) s_test(in=ff); by upc3; if ee and ff; run;
proc print data=m3(obs=10); run;


proc sql;
	create table test1 as
		select WEEK, sum(units) as units_sold, avg(sum_price) as avg_price, avg(D_1) as avg_display, avg(F_1) as avg_feature, avg(PR_1) as avg_pr
		from m3
		group by WEEK
		order by WEEK;
quit;
proc print data=test1(obs=10); run; 

/* Regression */
proc reg data=test1;
model units_sold = avg_price avg_display avg_feature / vif stb white collin;
run;

/* test interactions between variables */
data test1;
set test1;
price_display = avg_price*avg_display;
price_feature = avg_price*avg_feature;
display_feature = avg_display*avg_feature;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_display price_feature display_feature/ vif stb white collin;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_feature display_feature/ vif stb white collin;
run;

/* test non non-linear effect on avg_price */
data test1;
set test1;
avg_price_sq = avg_price*avg_price;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_feature display_feature avg_price_sq / vif stb white collin;
run;

/* whites test */
proc model data=test1;
parms b0 b1 b2 b3;
units_sold=b0+b1*avg_price+ b2*avg_display+ b3*avg_feature;
fit units_sold / white out=resid1 outresid;run;


/* The Case of Price per OZ */
proc sql;
	create table test as
		select upc3, sum(PRICE_PER_OZ) as sum_price, 
					 sum(D_1) as display_per_UPC, sum(D_1)/4936 as d_weight,
					 sum(F_1) as feature_per_UPC, sum(F_1)/8478 as f_weight,
					 sum(PR_1) as price_reduction_per_UPC, sum(PR_1)/20199 as pr_weight
		from final_df2
		group by upc3
		order by upc3;
quit;
proc print data=test(obs=10); run; 

proc sort data=final_df2 out=s_final_df2; by UPC3; run;
proc sort data=test out=s_test; by UPC3; run;
data m3; merge s_final_df2(in=ee) s_test(in=ff); by upc3; if ee and ff; run;
proc print data=m3(obs=10); run;


proc sql;
	create table test1 as
		select WEEK, sum(units) as units_sold, avg(sum_price) as avg_price, avg(D_1) as avg_display, avg(F_1) as avg_feature, avg(PR_1) as avg_pr
		from m3
		group by WEEK
		order by WEEK;
quit;
proc print data=test1(obs=10); run; 

/* Regression */
proc reg data=test1;
model units_sold = avg_price avg_display avg_feature / vif stb white collin;
run;

/* test interactions between variables */
data test1;
set test1;
price_display = avg_price*avg_display;
price_feature = avg_price*avg_feature;
display_feature = avg_display*avg_feature;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_display price_feature display_feature/ vif stb white collin;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_feature display_feature/ vif stb white collin;
run;

/* test non non-linear effect on avg_price */
data test1;
set test1;
avg_price_sq = avg_price*avg_price;
run;

proc reg data=test1;
model units_sold = avg_price avg_display avg_feature price_feature display_feature avg_price_sq / vif stb white collin;
run;

/* whites test */
proc model data=test1;
parms b0 b1 b2 b3;
units_sold=b0+b1*avg_price+ b2*avg_display+ b3*avg_feature;
fit units_sold / white out=resid1 outresid;run;
