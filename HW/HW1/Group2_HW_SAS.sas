/*BUAN6337.002 Group2_HW1 */

proc import datafile = 'c:\Users\dxk180020\desktop\car_insurance.csv' 
out = cars
dbms = CSV; run;

/*Q1: [gchart] the distribution of gender, vehicle size, and vehicle class*/
proc freq data=cars; table gender;run;
proc gchart data=cars; vbar gender; run;
proc freq data=cars; table vehicle_size;run;
proc gchart data=cars; vbar vehicle_size; run;
proc freq data=cars; table vehicle_class;run;
proc gchart data=cars; vbar vehicle_class; run;

/*Q2: [means] average customer lifetime value of each level of gender, vehicle size, and vehicle class*/
proc means data=cars; var customer_lifetime_value; class gender;run;
proc means data=cars; var customer_lifetime_value; class vehicle_size;run;
proc means data=cars; var customer_lifetime_value; class vehicle_class; run;

/*Q3: [t-test] Vehicle sizes(Large vs Medsize) in customer lifetime value*/
data t1;set cars;if vehicle_size="Large" or vehicle_size="Medsize";
proc ttest data=t1;var customer_lifetime_value;class vehicle_size;run;

/*Q4: [t-test] Gender in customer lifetime value*/
proc ttest data=cars;var customer_lifetime_value;class gender;run;

/*Q5: [ANOVA] Sales Channels in customer lifetime value*/
proc anova data=cars; class sales_channel; model customer_lifetime_value = sales_channel; run; 



/*Q6: [ANOVA] Demographic Factors(education, income, marital status) and customer lifetime value*/
proc anova data=cars; class education; model customer_lifetime_value = education;run;
proc corr data=cars; var customer_lifetime_value income; run;
proc anova data=cars; class marital_status; model customer_lifetime_value = marital_status;run;

/*Q7: [chi-test]The relationship between renew_offer_type and response*/
proc freq data = cars; tables renew_offer_type*response /chisq; run;

/*Q8: [ANOVA]renew_offer_type in lifetime value*/
proc anova data=cars; class renew_offer_type; model customer_lifetime_value = renew_offer_type;run;
proc anova data=cars;
	TITLE 'Question 8 Anova';
	class Renew_Offer_Type;
	model Customer_Lifetime_Value = Renew_Offer_Type;
	run;
proc means data=cars;
	TITLE 'Question 8 Anova';
	var Customer_Lifetime_Value;
	class Renew_Offer_Type; run;
data car_subset4; set cars; 
if Renew_Offer_Type = "Offer1" or Renew_Offer_Type = "Offer2" or Renew_Offer_Type = "Offer3";run;
proc anova data = car_subset4;
	TITLE 'Question 8 Anova';
	class Renew_Offer_Type;
	model Customer_Lifetime_Value = Renew_Offer_Type;
	run;

/* ttest */
data Offer_1_3; set cars;
if Renew_Offer_Type = "Offer1" or Renew_Offer_Type = "Offer3"; run;
proc ttest data = Offer_1_3;
	TITLE 'Question 8 ttest';
	var Customer_Lifetime_Value;
	class Renew_Offer_Type;
	run;
data offer_1_2;set cars; 
if Renew_Offer_Type = "Offer1" or Renew_Offer_Type = "Offer2"; run;
proc ttest data =offer_1_2;
	TITLE 'Question 8 ttest';
	var Customer_Lifetime_Value; 
	class Renew_Offer_Type;
	run;


/*Q9:[ANOVA] Different Renew Offer Type across different state in Customer Lifetime Value*/

proc anova data = cars;
class renew_offer_type state;
model customer_lifetime_value = renew_offer_type state renew_offer_type*state; run;

PROC GLM data=cars; CLASS renew_offer_type state;
MODEL customer_lifetime_value = renew_offer_type|state / EFFECTSIZE alpha=0.05;


/*Q10:Interesting insights & suggestions that can be obtained from the data*/
/*Hypothesis 1: Does car class affect the profitability or loss of the user? What is the top car class that makes the customer more profitable ? */
proc sql;
create table personal_prof as
select * from cars
where prxmatch("/Personal.*/",Policy) ;
run;
data personal_prof ;
set personal_prof;
loss_profit = Months_Since_Policy_Inception * Monthly_Premium_Auto - Total_Claim_Amount ;
run;
proc ANOVA data=personal_prof;
title "personal_prof";
class Vehicle_Class;
model loss_profit = Vehicle_Class;
means Vehicle_Class / SNK alpha=0.05;
run;

/*Hypothesis 2: Does car size affect the customer’s total claims? */
data car_Q10; set cars;
if Vehicle_Size = 'Small' or Vehicle_Size = 'Large'; run;
proc ttest;
	title “Income and Vehicle Size”;
	var Total_Claim_Amount;
	class Vehicle_Size;
	run;
/*Hypothesis 3: Do divorced people have a lower claim amount than married people? */
proc ttest; title 'Marital Status and Claim Amounts'; where Marital_Status in ('Married','Divorced'); class Marital_Status; var Total_Claim_Amount;
