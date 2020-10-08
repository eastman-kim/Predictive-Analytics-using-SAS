/*import data that was cleaned through python*/
/*steps taken through python:
1. dropping variables which were missing 70+% of observations
2. Computed means of x variables for churners and non-churners separately and compute the percentage difference for each variable
3. Chose top 12 variables from steps above*/

proc import datafile="H:\Windows\final_df.csv"
	out=churn
	dbms=csv
	replace;
	getnames=yes;
run;
proc print data=churn(obs=20);run;

/*percentage of churn=1 and churn=0*/
proc freq;table churn;run; /* 49.91% Yes, 50.09% No)*/
proc contents;run;

/* create a training dataset */
proc surveyselect data=churn method=srs N=70000 out=train;run;

/* Create a test dataset */
data t2;set train;sel=1; keep Customer_ID sel;run;
proc print data=t2(obs=10);run;

data c1;merge churn t2;by Customer_id;run;
data test;set c1;if sel =".";
drop sel;run;proc print data=test(obs=10);run;

 /* how many 1s in train data? */
proc freq data=train;table Churn;run;

proc logistic data=train descending;
model churn(EVENT='1') = blck_dat_Mean callfwdv_Mean callwait_Mean change_mou comp_dat_Mean custcare_Mean eqpdays roam_Mean threeway_Mean asl_flag creditcd forgntvl refurb_new  / stb;
run;

/* use model to predict on test data */
proc logistic data=train;
model  churn(desc)=blck_dat_Mean callfwdv_Mean callwait_Mean change_mou comp_dat_Mean custcare_Mean eqpdays roam_Mean threeway_Mean asl_flag creditcd forgntvl refurb_new/ expb ctable pprob=(0.3, 0.5 to 0.8 by 0.1);
score data=test out=testpred;
run;

proc print data=testpred (obs=20);run;

data p1;set testpred;
if p_1 >.12 then outcome=1;else outcome=0;
proc freq;table churn*outcome;run;
