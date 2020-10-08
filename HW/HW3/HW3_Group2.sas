  ODS HTML FILE='wage.html'; 
/* Data Import */
data wage;
infile "H:\wage.dat" missover firstobs=2;
input Edu Hr Wage Famearn Self Sal Mar Numkid Age unemp;run;
proc print data=wage(obs=10);run;

/* Concat Year */
data year;
do i = 1 to 334;
dummy = 1983;
year = 0;
	do j = 1 to 3;
	id = i;
	year = dummy + j;
output;
end;
end;
drop i j dummy;	
run;

/* Final Data */ 
data wage_year;
merge year wage;
run;

/* Log(wage) */
data wage_year;
set wage_year;
lnwage = log(wage);
run;

/*Q1*/
/* [PROC REG] Linear Regression(all variables)*/
PROC REG DATA = wage_year;
MODEL lnwage = Edu Hr Self Sal Mar Numkid Age unemp/ VIF collin stb white;
title " Linear Regression(all variables)";
run;

/* [PROC REG] Linear Regression(without Numkid & unemp)*/
PROC REG DATA = wage_year;
MODEL lnwage = Edu Hr Self Sal Age Mar/ VIF collin stb white; 
title " Linear Regression(without Numkid & unemp)";
run;
/* [PROC MODEL] Linear Regression(white test)*/
PROC model DATA = wage_year;
parms intercept Edu_ Hr_ Self_ Sal_ Mar_ Age_;
lnwage = intercept + Edu_*Edu + Hr_*Hr + Self_* Self + Sal_*Sal + Mar_*Mar + Age_*Age;
fit lnwage/ white breusch=(1 Edu Hr Self Sal Mar Age);
title "Linear Regression(white test)";
run;


/* Q2 */
/* Make numerical variables squared */
data nl;
set wage_year;
Edu_sq = Edu*Edu;
Hr_sq = Hr*Hr;
Numkid_sq = Numkid*Numkid;
Age_sq = Age*Age;
unemp_sq = unemp*unemp;
run;
/* [PROC REG] Non-linear Regression (without Mar & Age_sq) */
PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Hr_sq Self Sal Age/ VIF collin stb white acov; /* drop Hr_sq */
title "Non-linear Regression (without Mar & Age_sq)";
run;

/* different models we have run
PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Self Sal Mar Age Age_sq/ VIF collin stb white;
run;

PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Self Sal Mar Age Age_sq/ VIF collin stb white acov; 
run;

PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Hr_sq Self Sal Mar Age/ VIF collin stb white acov; 
run;

PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Hr_sq Self Sal Mar Age Age_sq/ VIF collin stb white acov;
run;

PROC REG DATA = nl;
MODEL lnwage = Edu Hr Hr_sq Self Sal Mar Age Age_sq/ VIF collin stb white acov;
run;

PROC REG DATA = nl;
MODEL lnwage = Edu Edu_sq Hr Hr_sq Self Sal Mar Age/ VIF collin stb white acov;
run;
*/

/* [PROC MODEL] Non-linear Regression (white test)*/
PROC model DATA = nl;
parms intercept Edu_ Edu_sq_ Hr_ Hr_sq_ Self_ Sal_ Age_;
lnwage = intercept + Edu_*Edu + Edu_sq_*Edu_sq + Hr_*Hr + Hr_sq_*Hr_sq + Self_*Self + Sal_*Sal + Age_*Age;
fit lnwage/ gmm kernel=(bart,1,0) white breusch=(1 Edu Edu_sq Hr Hr_sq Self Sal Age);
title "Non-linear Regression (white test)";
run;

/*White test
PROC model DATA = nl;
parms b0 b1 b2 b3 b4 b5 b6 b7 b8 b9;
lnwage = b0 + b1*Edu + b2*Edu_sq + b3*Hr + b4*Hr_sq + b5* Self + b6*Sal + b7*Mar + b8*Age + b9*Age_sq;
fit lnwage/ white breusch=(1 Edu Hr Hr_sq Self Sal Mar Age Age_sq);
ods output acovest=covmat parameterestimates=parms;
run;
*/

/* Q4 */
/* [PROC PANEL] Mixed Effect Models */
proc panel data=nl; 
id id year; 
MODEL lnwage = Edu Hr Self Sal Age /fixone ranone fixtwo rantwo;
title 
run;

/* different modesl we have run 
proc panel data=nl; 
id id year; 
MODEL lnwage = Edu Edu_sq Hr Hr_sq Self Sal Age /fixone ranone fixtwo rantwo;    
run;
proc panel data=nl; 
id id year; 
MODEL lnwage = Edu Edu_sq Hr Self Sal Mar Age Age_sq /fixone ranone fixtwo rantwo;  
run;

*/
proc panel data = Wage_year; /* RANONE*/ 
id  id year; 
model lnwage = Edu Hr Self Sal Age Mar/ RANONE;
title "Hausman test for random effect RANONE ";
run;
proc panel data = Wage_year ;/* Run RANTWO model*/
id  id year; 
model lnwage =Edu Hr Self Sal Age Mar /RANTWO;
title "RANTWO model ";
run;
proc panel data = Wage_year ;/* Run FIXONE model*/
id  id year; 
model lnwage = Edu Hr Self Sal Age Mar/FIXONE;
title "FixOne model ";
run;
proc panel data = Wage_year ;/* Run FIXTWO model*/
id  id year; 
model lnwage = Edu Hr Self Sal Age Mar/FIXTWO;
title "FixTWO model ";
run;
ods html close;
