ods pdf file="H:\WINDOWS\Group2_HW2_output.pdf";
DATA q1;
  INFILE 'H:\WINDOWS\93cars.dat';
  INPUT Manufacturer $ 1-14 Model $ 15-29 Type $ 30-36 Minimum_Price 38-41 Midrange_Price 43-46 Maximum_Price 48-51 City_MPG 53-54 Highway_MPG 56-57
	Air_Bags_standard 59-59 Drive_train_type 61-61 Number_of_cylinders 63-63 Engine_size 65-67 Horsepower 69-71 RPM 73-76
	#2 Engine_revolutions_per_mile 1-4 Manual_transmission_available 6-6 Fuel_tank_capacity 8-11 Passenger_capacity 13-13 Length 15-17 Wheelbase 19-21
	Width 23-24 U_turn_space 26-27 Rear_seat_room 29-32 Luggage_capacity 34-35 Weight 37-40 Domestic 42-42;
RUN;
proc print; run;
proc contents; run;
/*Question 1a*/
proc corr; var horsepower Midrange_Price; run;
/*Question 1b*/
data q1;
set q1;
if Air_Bags_Standard='1' then Air_Bag_Driver=1; else Air_Bag_Driver=0;
if Air_Bags_Standard='2' then Air_Bag_Driver_Passager=1; else Air_Bag_Driver_Passager=0;
proc reg; 
	MODEL Midrange_price = City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Manual_transmission_available Domestic;
	run;
/*STB*/
proc means; var Midrange_price City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Manual_transmission_available Domestic; run;
proc reg data=q1 plots=none;
   Orig: model Midrange_price = City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Manual_transmission_available Domestic / stb;
   ods select ParameterEstimates;
quit;
/*non-linear horsepower*/
data test2;
set q1;
Horsepower2=Horsepower**2;
run;
proc reg data=test2; 
	MODEL Midrange_price = City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Horsepower2 Manual_transmission_available Domestic;
	run;
/*Interaction of HP and Weight*/
proc glm data=q1;
model Midrange_price = City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Horsepower|Weight Manual_transmission_available Domestic / solution;
store contcont;
run;
/*MODEL 2*/
proc reg; 
	MODEL Midrange_price = City_MPG Air_Bag_Driver Air_Bag_Driver_Passager Horsepower Manual_transmission_available Domestic Engine_revolutions_per_mile;
	run;

DATA q2;
  INFILE 'H:\WINDOWS\diamond data.dat' FIRSTOBS=2;
  INPUT Cut $ Color $ Clarity $ carat price;
RUN;
proc print; run;
/*q2.1*/
PROC FREQ; TABLE Cut*Clarity / CHISQ; RUN;
/*q2.2*/
proc ttest; var price; class color; run;
/*q2.3*/
data q2;
set q2;
if Cut='Good' then Good=1; else Good=0;
if Cut='Fair' then Fair=1; else Fair=0;
if Cut='Ideal' then Ideal=1; else Ideal=0;
if Color='D' then D=1; else D=0;
if Clarity='VVS2' then VVS2=1; else VVS2=0;
if Clarity='VS1' then VS1=1; else VS1=0;
if Clarity='VS2' then VS2=1; else VS2=0;
proc print; run;
proc reg; model price=carat Good Fair Ideal D VVS2 VS1 VS2 / vif collin; run;

ods pdf close;
