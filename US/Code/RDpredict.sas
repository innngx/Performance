%let path=C:\Users\Xgao\Documents\GitHub\Performance\US\Data;  /*define path*/
libname Review "&path";

*pay;
PROC IMPORT OUT= pay 
            DATAFILE= "&path\pay.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
PROC IMPORT OUT= insurance 
            DATAFILE= "&path\insurance.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;
PROC IMPORT OUT= performance 
            DATAFILE= "&path\PerformanceRD.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
     guessingrows=32767;  /*set max length to avoid merge problem*/
RUN;
proc sort;
	by Payroll_Name;
run;

data predict;
	merge performance pay insurance;
	by Payroll_Name;
	if VS=. then delete;
run;
*proc export data=predict outfile="&path\PorformanceRD0.csv" dbms=csv replace;
*run;

data mydata (keep=Payroll_Name Age Children VS Gender Sub_Department MBO M_Status Edu Pay R_2015 HSA);
	set predict;
	if R_2015=. then delete;
	if Gender='M' then Gender=1;
		else Gender=0;
	if Marital_Status='Married' then M_Status=1;
		else M_Status=0;
	if Education='PhD Level' then Edu=4;
		else if Education='Master Level' then Edu=3;
		else if Education='Bachelor Level' then Edu=2;
		else if Education='Associate Level' then Edu=1;
		else Edu=0;
	if Medical_plan_name='HSA' then HSA=1; *HSA no effect;
		else HSA=0;
	if Pay=. then delete;
run;

*proc export data=mydata outfile="&path\PorformanceRD1.csv" dbms=csv replace;
*run;

quit;

*pay reg;
data reg;
	set mydata;
	lnpay=log(pay);
	if Gender=1 then Sex=1;
	else Sex=0;
	drop Gender;
run;

ods graphics on;
title 'Regression Model with no Transformation';
proc reg data=reg plots=(RESIDUALBYPREDICTED QQ);
	model pay=Age Children VS Sex M_Status Edu R_2015 HSA / selection=stepwise;
	output residual=r predicted=p out=Bn;
run;

title 'Regression Model with Transformation';
proc reg data=reg plots=(RESIDUALBYPREDICTED QQ);
	model lnpay=Age Children VS Sex M_Status Edu R_2015 HSA / selection=stepwise;
	output residual=r predicted=p out=B;
run;
title;
ods graphics off;

proc gchart data=reg;
	vbar pay / type=PCT inside=FREQ outside=PCT;
run;
proc gchart data=reg;
	vbar lnpay / type=PCT inside=FREQ outside=PCT;
run;

quit;
